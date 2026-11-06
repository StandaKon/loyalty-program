/**
 * Builds the member 360 view of the back office (B5): lifetime KPIs, 12-month points trend (Europe/Prague months),
 * vehicle/profile and latest consent per type, and the most recent point movements.
 * Earned/redeemed follow the B1 §7 KPI definitions.
 */
public inherited sharing class Member360Service {
    private static final String PROGRAM_TIME_ZONE = 'Europe/Prague';
    private static final Set<String> EARNING_TYPES = new Set<String>{ 'PurchaseBase', 'CampaignBonus', 'ProfileBonus', 'MarketingBonus' };
    private static final Integer TREND_MONTHS = 12;
    private static final Integer RECENT_ENTRIES = 10;

    private final Member360Selector selector;
    private final TimeZone programTimeZone = TimeZone.getTimeZone(PROGRAM_TIME_ZONE);

    public Member360Service() {
        this(new Member360Selector());
    }

    @TestVisible
    private Member360Service(Member360Selector selector) {
        this.selector = selector;
    }

    public class Kpis {
        @AuraEnabled
        public Decimal balance;
        @AuraEnabled
        public Decimal earned;
        @AuraEnabled
        public Decimal redeemed;
        @AuraEnabled
        public Integer purchases;
        @AuraEnabled
        public Decimal totalSpend;
        @AuraEnabled
        public Datetime lastPurchase;
        @AuraEnabled
        public Integer activeVouchers;
    }

    public class Profile {
        @AuraEnabled
        public String vehicle;
        @AuraEnabled
        public String fuelType;
        @AuraEnabled
        public Decimal vehicleYear;
        @AuraEnabled
        public String registration;
        @AuraEnabled
        public Boolean isComplete;
        @AuraEnabled
        public Boolean hasMarketingConsent;
    }

    public class ConsentRow {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String consentType;
        @AuraEnabled
        public String formName;
        @AuraEnabled
        public String revision;
        @AuraEnabled
        public String action;
        @AuraEnabled
        public Boolean isAccepted;
        @AuraEnabled
        public Datetime capturedAt;
    }

    public class TimelineRow {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String entryType;
        @AuraEnabled
        public String entryTypeLabel;
        @AuraEnabled
        public Decimal points;
        @AuraEnabled
        public Datetime occurredAt;
        @AuraEnabled
        public String detail;
        @AuraEnabled
        public Id sourceId;
        @AuraEnabled
        public String sourceName;
    }

    public class Member360 {
        @AuraEnabled
        public Kpis kpis = new Kpis();
        @AuraEnabled
        public Profile profile = new Profile();
        @AuraEnabled
        public Boolean canReadConsents = true;
        @AuraEnabled
        public List<ConsentRow> consents = new List<ConsentRow>();
        @AuraEnabled
        public List<LoyaltyDashboardService.TrendPoint> trend = new List<LoyaltyDashboardService.TrendPoint>();
        @AuraEnabled
        public List<TimelineRow> timeline = new List<TimelineRow>();
    }

    public Member360 getMember360(Id memberId) {
        Account member = selector.getMember(memberId);
        if (member == null || String.isBlank(member.Member_Number__c)) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_Not_Member);
        }
        Member360 view = new Member360();
        fillKpis(view.kpis, member);
        fillProfile(view.profile, member);
        fillConsents(view, memberId);
        fillTrend(view.trend, memberId);
        fillTimeline(view.timeline, memberId);
        return view;
    }

    private void fillKpis(Kpis kpis, Account member) {
        Map<String, Decimal> points = selector.sumPointsByEntryType(member.Id);
        Decimal earned = 0;
        for (String entryType : EARNING_TYPES) {
            earned += points.get(entryType) ?? 0;
        }
        AggregateResult purchases = selector.summarizePurchases(member.Id);
        kpis.balance = member.Points_Balance__c ?? 0;
        kpis.earned = earned;
        kpis.redeemed = Math.abs(points.get('Redemption') ?? 0) - (points.get('Refund') ?? 0);
        kpis.purchases = (Integer) purchases.get('purchaseCount');
        kpis.totalSpend = (Decimal) purchases.get('totalSpend') ?? 0;
        kpis.lastPurchase = (Datetime) purchases.get('lastPurchase');
        kpis.activeVouchers = selector.countActiveVouchers(member.Id);
    }

    private void fillProfile(Profile profile, Account member) {
        List<String> vehicleParts = new List<String>();
        for (String part : new List<String>{ member.Vehicle_Make__c, member.Vehicle_Model__c }) {
            if (String.isNotBlank(part)) {
                vehicleParts.add(part);
            }
        }
        profile.vehicle = String.join(vehicleParts, ' ');
        profile.fuelType = member.Vehicle_Fuel_Type__c;
        profile.vehicleYear = member.Vehicle_Year__c;
        profile.registration = member.Vehicle_Registration__c;
        profile.isComplete = member.Profile_Complete__c;
        profile.hasMarketingConsent = member.Marketing_Consent__c;
    }

    // Shows the latest event per consent type; users without read access to consent objects see a notice instead.
    private void fillConsents(Member360 view, Id memberId) {
        List<AuthorizationFormConsent> consents;
        try {
            consents = selector.getConsents(memberId);
        } catch (QueryException missingAccess) {
            view.canReadConsents = false;
            return;
        }
        Set<String> seenTypes = new Set<String>();
        for (AuthorizationFormConsent consent : consents) {
            AuthorizationForm form = consent.AuthorizationFormText?.AuthorizationForm;
            String consentType = form?.Consent_Type__c ?? '';
            if (seenTypes.contains(consentType)) {
                continue;
            }
            seenTypes.add(consentType);
            ConsentRow row = new ConsentRow();
            row.id = consent.Id;
            row.consentType = consentType;
            row.formName = form?.Name;
            row.revision = form?.RevisionNumber;
            row.action = consent.Consent_Action__c;
            row.isAccepted = consent.Status == 'Signed';
            row.capturedAt = consent.ConsentCapturedDateTime;
            view.consents.add(row);
        }
    }

    private void fillTrend(List<LoyaltyDashboardService.TrendPoint> trend, Id memberId) {
        Date currentMonth = Date.valueOf(System.now().format('yyyy-MM-dd', PROGRAM_TIME_ZONE)).toStartOfMonth();
        Date firstMonth = currentMonth.addMonths(1 - TREND_MONTHS);
        Map<Date, LoyaltyDashboardService.TrendPoint> pointsByMonth = new Map<Date, LoyaltyDashboardService.TrendPoint>();
        for (Integer index = 0; index < TREND_MONTHS; index++) {
            LoyaltyDashboardService.TrendPoint point = new LoyaltyDashboardService.TrendPoint();
            point.monthStart = firstMonth.addMonths(index);
            point.awarded = 0;
            point.redeemed = 0;
            pointsByMonth.put(point.monthStart, point);
            trend.add(point);
        }
        Datetime gmtMidnight = Datetime.newInstanceGmt(firstMonth, Time.newInstance(0, 0, 0, 0));
        Datetime fromTime = gmtMidnight.addSeconds(-programTimeZone.getOffset(gmtMidnight) / 1000);
        for (Point_Ledger__c entry : selector.getEntriesSince(memberId, fromTime)) {
            Date month = Date.valueOf(entry.Occurred_At__c.format('yyyy-MM-dd', PROGRAM_TIME_ZONE)).toStartOfMonth();
            LoyaltyDashboardService.TrendPoint point = pointsByMonth.get(month);
            if (point == null) {
                continue;
            }
            if (EARNING_TYPES.contains(entry.Entry_Type__c)) {
                point.awarded += entry.Points__c;
            } else if (entry.Entry_Type__c == 'Redemption') {
                point.redeemed += Math.abs(entry.Points__c);
            } else if (entry.Entry_Type__c == 'Refund') {
                point.redeemed -= entry.Points__c;
            }
        }
    }

    private void fillTimeline(List<TimelineRow> timeline, Id memberId) {
        for (Point_Ledger__c entry : selector.getRecentEntries(memberId, RECENT_ENTRIES)) {
            TimelineRow row = new TimelineRow();
            row.id = entry.Id;
            row.entryType = entry.Entry_Type__c;
            row.entryTypeLabel = PicklistOptions.getLabel(Point_Ledger__c.Entry_Type__c, entry.Entry_Type__c);
            row.points = entry.Points__c;
            row.occurredAt = entry.Occurred_At__c;
            if (entry.Transaction__c != null) {
                row.sourceId = entry.Transaction__c;
                row.sourceName = entry.Transaction__r.Name;
                row.detail = entry.Campaign__r?.Name;
            } else if (entry.Voucher__c != null) {
                row.sourceId = entry.Voucher__c;
                row.sourceName = entry.Voucher__r.Name;
                row.detail = entry.Voucher__r.Reward_Name__c;
            } else {
                row.detail = entry.Reason__c;
            }
            timeline.add(row);
        }
    }
}
