/**
 * Points expiry (B11, BR-61, Q8): every credited point expires Points_Validity_Months__c after its credit date
 * (program time zone). Spending is FIFO, so the points due on a date are the credits expiring by then minus
 * all debits (redemptions, expirations, reversals, negative adjustments), never below zero.
 * Points credited before Expiry_Effective_Date__c expire at that date + validity.
 */
public inherited sharing class PointExpiryService {
    public static final String ENTRY_TYPE_EXPIRATION = 'Expiration';
    private static final String UNIQUE_KEY_PREFIX = 'EXP:';

    private final LoyaltyMemberSelector memberSelector;
    private final LoyaltyLedgerAnalysisSelector ledgerSelector;
    private final LoyaltySettingsSelector settingsSelector;

    public PointExpiryService() {
        this(new LoyaltyMemberSelector(), new LoyaltyLedgerAnalysisSelector(), new LoyaltySettingsSelector());
    }

    @TestVisible
    private PointExpiryService(LoyaltyMemberSelector memberSelector, LoyaltyLedgerAnalysisSelector ledgerSelector, LoyaltySettingsSelector settingsSelector) {
        this.memberSelector = memberSelector;
        this.ledgerSelector = ledgerSelector;
        this.settingsSelector = settingsSelector;
    }

    public Map<Id, Integer> getDuePoints(Set<Id> memberIds, Date asOf) {
        Map<Id, Integer> dueByMemberId = new Map<Id, Integer>();
        for (MemberLedger ledger : buildLedgers(memberIds).values()) {
            dueByMemberId.put(ledger.memberId, ledger.getDue(asOf));
        }
        return dueByMemberId;
    }

    /**
     * Next expiry within the warning window after today, or null when nothing expires in it.
     */
    public Forecast getForecast(Id memberId, Date today) {
        Integer warningDays = (settingsSelector.getDefault()?.Expiry_Warning_Days__c ?? 0).intValue();
        MemberLedger ledger = buildLedgers(new Set<Id>{ memberId }).get(memberId);
        if (ledger == null || warningDays <= 0) {
            return null;
        }
        Integer alreadyDue = ledger.getDue(today);
        for (Date expiryDate : ledger.getExpiryDates()) {
            if (expiryDate <= today) {
                continue;
            }
            if (expiryDate > today.addDays(warningDays)) {
                break;
            }
            Integer points = ledger.getDue(expiryDate) - alreadyDue;
            if (points > 0) {
                return new Forecast(expiryDate, points);
            }
        }
        return null;
    }

    /**
     * Writes one Expiration entry per member with due points. Repeated runs on the same day write nothing new.
     * @return number of members whose points expired
     */
    public Integer expire(Set<Id> memberIds, Date asOf) {
        Set<Id> lockedMemberIds = new Map<Id, Account>(memberSelector.getByIdsForUpdate(memberIds)).keySet();
        List<Point_Ledger__c> expirations = new List<Point_Ledger__c>();
        Datetime now = System.now();
        for (MemberLedger ledger : buildLedgers(lockedMemberIds).values()) {
            Integer duePoints = ledger.getDue(asOf);
            if (duePoints > 0) {
                expirations.add(
                    new Point_Ledger__c(
                        Member__c = ledger.memberId,
                        Points__c = -duePoints,
                        Entry_Type__c = ENTRY_TYPE_EXPIRATION,
                        Occurred_At__c = now,
                        Reason__c = 'Points expired as of ' + String.valueOf(asOf),
                        Unique_Key__c = UNIQUE_KEY_PREFIX + ledger.memberId + ':' + String.valueOf(asOf)
                    )
                );
            }
        }
        Integer expiredMembers = 0;
        for (Database.SaveResult result : Database.insert(expirations, false, AccessLevel.SYSTEM_MODE)) {
            if (result.isSuccess()) {
                expiredMembers++;
            } else if (result.getErrors()[0].getStatusCode() != StatusCode.DUPLICATE_VALUE) {
                System.debug(LoggingLevel.ERROR, 'Points expiry failed: ' + result.getErrors()[0].getMessage());
            }
        }
        return expiredMembers;
    }

    public Integer getValidityMonths() {
        Decimal months = settingsSelector.getDefault()?.Points_Validity_Months__c;
        if (months == null || months <= 0) {
            throw new LoyaltyActionException('Loyalty_Settings__mdt Default has no positive Points_Validity_Months__c');
        }
        return months.intValue();
    }

    private Map<Id, MemberLedger> buildLedgers(Set<Id> memberIds) {
        Integer validityMonths = getValidityMonths();
        Date effectiveDate = settingsSelector.getDefault()?.Expiry_Effective_Date__c;
        Map<Id, MemberLedger> ledgersByMemberId = new Map<Id, MemberLedger>();
        for (Id memberId : memberIds) {
            ledgersByMemberId.put(memberId, new MemberLedger(memberId));
        }
        for (Point_Ledger__c entry : ledgerSelector.getEntriesByMemberIds(memberIds)) {
            Integer points = (entry.Points__c ?? 0).intValue();
            MemberLedger ledger = ledgersByMemberId.get(entry.Member__c);
            if (points > 0) {
                Date creditDate = PointsCalculator.toProgramDate(entry.Occurred_At__c);
                Date validFrom = (effectiveDate != null && creditDate < effectiveDate) ? effectiveDate : creditDate;
                ledger.addCredit(validFrom.addMonths(validityMonths), points);
            } else {
                ledger.debits -= points;
            }
        }
        return ledgersByMemberId;
    }

    public class Forecast {
        public Date expiryDate;
        public Integer points;

        public Forecast(Date expiryDate, Integer points) {
            this.expiryDate = expiryDate;
            this.points = points;
        }
    }

    private class MemberLedger {
        private final Id memberId;
        private final Map<Date, Integer> creditsByExpiryDate = new Map<Date, Integer>();
        private Integer debits = 0;

        MemberLedger(Id memberId) {
            this.memberId = memberId;
        }

        void addCredit(Date expiryDate, Integer points) {
            creditsByExpiryDate.put(expiryDate, (creditsByExpiryDate.get(expiryDate) ?? 0) + points);
        }

        List<Date> getExpiryDates() {
            List<Date> expiryDates = new List<Date>(creditsByExpiryDate.keySet());
            expiryDates.sort();
            return expiryDates;
        }

        Integer getDue(Date asOf) {
            Integer expiredCredits = 0;
            for (Date expiryDate : creditsByExpiryDate.keySet()) {
                if (expiryDate <= asOf) {
                    expiredCredits += creditsByExpiryDate.get(expiryDate);
                }
            }
            return Math.max(0, expiredCredits - debits);
        }
    }
}
