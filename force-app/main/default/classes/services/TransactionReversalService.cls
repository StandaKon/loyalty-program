/**
 * Full reversal (storno) of a processed purchase by the loyalty manager (B11, FR-E2-06).
 * Writes one immutable Reversal entry that removes the base, campaign and tier points of the purchase;
 * the purchase itself stays unchanged (it is immutable after processing). Partial reversals use manual adjustment.
 */
public inherited sharing class TransactionReversalService {
    public static final String ENTRY_TYPE_REVERSAL = 'Reversal';
    private static final Set<String> REVERSIBLE_ENTRY_TYPES = new Set<String>{ 'PurchaseBase', 'CampaignBonus', 'TierBonus' };
    private static final Integer MAX_COMMENT_LENGTH = 200;
    private static final Map<String, String> REASON_LABELS = new Map<String, String>{
        'Return' => Label.Loyalty_BO_Reversal_Reason_Return,
        'WrongPosting' => Label.Loyalty_BO_Reversal_Reason_WrongPosting,
        'Duplicate' => Label.Loyalty_BO_Reversal_Reason_Duplicate
    };

    private final AccountSelector accountSelector;
    private final LoyaltyTransactionSelector transactionSelector;
    private final LoyaltyLedgerAnalysisSelector ledgerSelector;

    public TransactionReversalService() {
        this(new AccountSelector(), new LoyaltyTransactionSelector(), new LoyaltyLedgerAnalysisSelector());
    }

    @TestVisible
    private TransactionReversalService(AccountSelector accountSelector, LoyaltyTransactionSelector transactionSelector, LoyaltyLedgerAnalysisSelector ledgerSelector) {
        this.accountSelector = accountSelector;
        this.transactionSelector = transactionSelector;
        this.ledgerSelector = ledgerSelector;
    }

    public static String buildUniqueKey(Id transactionId) {
        return 'TX:' + transactionId + ':REVERSAL';
    }

    public List<PicklistOptions.Option> getReasons() {
        List<PicklistOptions.Option> reasons = new List<PicklistOptions.Option>();
        for (String code : REASON_LABELS.keySet()) {
            reasons.add(new PicklistOptions.Option(REASON_LABELS.get(code), code));
        }
        return reasons;
    }

    public Loyalty_Transaction__c getTransaction(Id transactionId) {
        Loyalty_Transaction__c loyaltyTransaction = transactionSelector.getById(transactionId);
        if (loyaltyTransaction == null) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Reversal_Error_NotProcessed);
        }
        return loyaltyTransaction;
    }

    public ReversalState getState(Id transactionId) {
        ReversalState state = new ReversalState();
        for (Point_Ledger__c entry : ledgerSelector.getEntriesByTransactionId(transactionId)) {
            if (entry.Entry_Type__c == ENTRY_TYPE_REVERSAL) {
                state.isReversed = true;
            } else if (REVERSIBLE_ENTRY_TYPES.contains(entry.Entry_Type__c)) {
                state.points += (entry.Points__c ?? 0).intValue();
            }
        }
        return state;
    }

    /**
     * @return number of removed points
     */
    public Integer reverse(Id transactionId, String reasonCode, String comment) {
        LoyaltyPermissions.requireAdjustPoints();
        validate(reasonCode, comment);
        Loyalty_Transaction__c loyaltyTransaction = getTransaction(transactionId);
        if (loyaltyTransaction.Processing_Status__c != LoyaltyTransactionService.STATUS_PROCESSED) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Reversal_Error_NotProcessed);
        }

        Account member = accountSelector.getMemberByIdForUpdate(loyaltyTransaction.Member__c);
        ReversalState state = getState(transactionId);
        if (state.isReversed) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Reversal_Error_Already);
        }
        if (state.points <= 0) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Reversal_Error_Nothing);
        }
        Integer balance = (member?.Points_Balance__c ?? 0).intValue();
        if (balance < state.points) {
            throw new LoyaltyActionException(String.format(Label.Loyalty_BO_Reversal_Error_Balance, new List<Object>{ balance }));
        }

        String reason = REASON_LABELS.get(reasonCode) + (String.isNotBlank(comment) ? ': ' + comment.trim() : '');
        Database.insert(
            new Point_Ledger__c(
                Member__c = loyaltyTransaction.Member__c,
                Transaction__c = loyaltyTransaction.Id,
                Points__c = -state.points,
                Entry_Type__c = ENTRY_TYPE_REVERSAL,
                Reason__c = reason,
                Occurred_At__c = System.now(),
                Unique_Key__c = buildUniqueKey(loyaltyTransaction.Id)
            ),
            AccessLevel.SYSTEM_MODE
        );
        return state.points;
    }

    private void validate(String reasonCode, String comment) {
        if (String.isBlank(reasonCode) || !REASON_LABELS.containsKey(reasonCode)) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Reversal_Error_Reason);
        }
        if (String.isNotBlank(comment) && comment.trim().length() > MAX_COMMENT_LENGTH) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_Comment_Too_Long);
        }
    }

    public class ReversalState {
        public Boolean isReversed = false;
        public Integer points = 0;
    }
}
