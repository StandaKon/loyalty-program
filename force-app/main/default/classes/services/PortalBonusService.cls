/**
 * Writes the one-time portal activity bonuses ProfileBonus and MarketingBonus (B1 4.5).
 * Each bonus exists at most once per membership, guarded by the unique key MEM:<account-id>:PROFILE|MARKETING.
 * Callers serialize work on one member with the Account row lock; the unique key is the final guard against races.
 */
public inherited sharing class PortalBonusService {
    public static final String ENTRY_TYPE_PROFILE = 'ProfileBonus';
    public static final String ENTRY_TYPE_MARKETING = 'MarketingBonus';

    private static final String UNIQUE_KEY_PREFIX = 'MEM:';
    private static final Map<String, String> KEY_SUFFIX_BY_ENTRY_TYPE = new Map<String, String>{
        ENTRY_TYPE_PROFILE => 'PROFILE',
        ENTRY_TYPE_MARKETING => 'MARKETING'
    };

    private final PointLedgerSelector ledgerSelector;
    private final LoyaltySettingsSelector settingsSelector;

    public PortalBonusService() {
        this(new PointLedgerSelector(), new LoyaltySettingsSelector());
    }

    @TestVisible
    private PortalBonusService(PointLedgerSelector ledgerSelector, LoyaltySettingsSelector settingsSelector) {
        this.ledgerSelector = ledgerSelector;
        this.settingsSelector = settingsSelector;
    }

    public Boolean hasBonus(Id memberId, String entryType) {
        return ledgerSelector.getByUniqueKey(buildUniqueKey(memberId, entryType)) != null;
    }

    public Integer getBonusPoints(String entryType) {
        Loyalty_Settings__mdt settings = settingsSelector.getDefault();
        Decimal points = entryType == ENTRY_TYPE_PROFILE ? settings?.Profile_Bonus_Points__c : settings?.Marketing_Bonus_Points__c;
        if (points == null || points <= 0) {
            throw new PortalBonusException('Loyalty_Settings__mdt Default has no positive points for ' + entryType);
        }
        return points.intValue();
    }

    /**
     * @return awarded points, or 0 when the member already has this bonus
     */
    public Integer awardOnce(Id memberId, String entryType) {
        String uniqueKey = buildUniqueKey(memberId, entryType);
        if (ledgerSelector.getByUniqueKey(uniqueKey) != null) {
            return 0;
        }
        Integer points = getBonusPoints(entryType);
        Database.SaveResult result = Database.insert(
            new Point_Ledger__c(
                Member__c = memberId,
                Points__c = points,
                Entry_Type__c = entryType,
                Occurred_At__c = System.now(),
                Unique_Key__c = uniqueKey
            ),
            false,
            AccessLevel.SYSTEM_MODE
        );
        if (result.isSuccess()) {
            return points;
        }
        if (isDuplicateKey(result)) {
            return 0;
        }
        throw new PortalBonusException('Bonus ' + uniqueKey + ' was not written: ' + result.getErrors()[0].getMessage());
    }

    private static String buildUniqueKey(Id memberId, String entryType) {
        String suffix = KEY_SUFFIX_BY_ENTRY_TYPE.get(entryType);
        if (memberId == null || suffix == null) {
            throw new PortalBonusException('Unsupported bonus ' + entryType + ' for member ' + memberId);
        }
        return UNIQUE_KEY_PREFIX + memberId + ':' + suffix;
    }

    private static Boolean isDuplicateKey(Database.SaveResult result) {
        for (Database.Error error : result.getErrors()) {
            if (error.getStatusCode() == StatusCode.DUPLICATE_VALUE) {
                return true;
            }
        }
        return false;
    }

    public class PortalBonusException extends Exception {
    }
}
