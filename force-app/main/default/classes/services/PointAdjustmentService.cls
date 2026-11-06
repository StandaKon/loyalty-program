/**
 * Manual point adjustment by the loyalty manager (B5, SHOULD).
 * Writes one immutable Adjustment ledger entry; the balance is never edited directly (B1 D06).
 * The member row lock plus the ADJ:<request-uuid> unique key make the action safe against double clicks and concurrent deductions.
 */
public inherited sharing class PointAdjustmentService {
    private static final String ENTRY_TYPE_ADJUSTMENT = 'Adjustment';
    private static final String UNIQUE_KEY_PREFIX = 'ADJ:';
    private static final Integer MAX_COMMENT_LENGTH = 255;
    private static final Pattern REQUEST_KEY_PATTERN = Pattern.compile('^[0-9a-fA-F-]{36}$');

    private final AccountSelector accountSelector;
    private final PointLedgerSelector ledgerSelector;

    public PointAdjustmentService() {
        this(new AccountSelector(), new PointLedgerSelector());
    }

    @TestVisible
    private PointAdjustmentService(AccountSelector accountSelector, PointLedgerSelector ledgerSelector) {
        this.accountSelector = accountSelector;
        this.ledgerSelector = ledgerSelector;
    }

    public List<PicklistOptions.Option> getCategories() {
        return PicklistOptions.getOptions(Point_Ledger__c.Adjustment_Category__c);
    }

    /**
     * Returns the member balance after the adjustment. A repeated request with the same key returns the current balance without a new entry.
     */
    public Decimal adjust(Id memberId, Integer points, String category, String comment, String requestKey) {
        LoyaltyPermissions.requireAdjustPoints();
        validate(points, category, comment, requestKey);

        Account member = accountSelector.getMemberByIdForUpdate(memberId);
        if (member == null || String.isBlank(member.Member_Number__c)) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_Not_Member);
        }
        Decimal balance = member.Points_Balance__c ?? 0;
        String uniqueKey = UNIQUE_KEY_PREFIX + requestKey.toLowerCase();
        if (ledgerSelector.getByUniqueKey(uniqueKey) != null) {
            return balance;
        }
        if (balance + points < 0) {
            throw new LoyaltyActionException(String.format(Label.Loyalty_BO_Error_Insufficient_Balance, new List<Object>{ balance.intValue() }));
        }

        Database.insert(
            new Point_Ledger__c(
                Member__c = member.Id,
                Points__c = points,
                Entry_Type__c = ENTRY_TYPE_ADJUSTMENT,
                Adjustment_Category__c = category,
                Reason__c = comment.trim(),
                Occurred_At__c = System.now(),
                Unique_Key__c = uniqueKey
            ),
            AccessLevel.SYSTEM_MODE
        );
        return balance + points;
    }

    private void validate(Integer points, String category, String comment, String requestKey) {
        if (String.isBlank(requestKey) || !REQUEST_KEY_PATTERN.matcher(requestKey).matches()) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_Invalid_Request);
        }
        if (points == null || points == 0) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_Points_Zero);
        }
        if (!PicklistOptions.isValid(Point_Ledger__c.Adjustment_Category__c, category)) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_Category_Required);
        }
        if (String.isBlank(comment)) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_Comment_Required);
        }
        if (comment.trim().length() > MAX_COMMENT_LENGTH) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_Comment_Too_Long);
        }
    }
}
