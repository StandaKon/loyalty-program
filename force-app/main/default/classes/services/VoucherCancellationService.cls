/**
 * Cancellation of an unused voucher by the loyalty manager (B5, rules per B8 specification).
 * Status Issued -> Cancelled and the Refund ledger entry reversing the original Redemption are written atomically.
 * Required B1 audit fields (Cancellation_Reason__c, Reason__c) get the comment, or the category label when no comment is given.
 */
public inherited sharing class VoucherCancellationService {
    private static final String STATUS_ISSUED = 'Issued';
    private static final String STATUS_CANCELLED = 'Cancelled';
    private static final String ENTRY_TYPE_REFUND = 'Refund';
    private static final Integer MAX_COMMENT_LENGTH = 255;

    private final AccountSelector accountSelector;
    private final VoucherSelector voucherSelector;
    private final PointLedgerSelector ledgerSelector;

    public VoucherCancellationService() {
        this(new AccountSelector(), new VoucherSelector(), new PointLedgerSelector());
    }

    @TestVisible
    private VoucherCancellationService(AccountSelector accountSelector, VoucherSelector voucherSelector, PointLedgerSelector ledgerSelector) {
        this.accountSelector = accountSelector;
        this.voucherSelector = voucherSelector;
        this.ledgerSelector = ledgerSelector;
    }

    public List<PicklistOptions.Option> getCategories() {
        return PicklistOptions.getOptions(Voucher__c.Cancellation_Category__c);
    }

    /**
     * Returns the number of refunded points.
     */
    public Decimal cancel(Id voucherId, String category, String comment) {
        LoyaltyPermissions.requireAdjustPoints();
        validate(category, comment);

        Voucher__c voucher = voucherSelector.getById(voucherId);
        if (voucher == null) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_Voucher_Not_Found);
        }
        // Lock order member -> voucher matches redemption in B8, so concurrent balance changes of the member wait for this action.
        accountSelector.getMemberByIdForUpdate(voucher.Member__c);
        voucher = voucherSelector.getByIdForUpdate(voucherId);
        if (voucher.Status__c != STATUS_ISSUED) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_Voucher_Not_Issued);
        }
        Point_Ledger__c redemption = ledgerSelector.getRedemptionByVoucherId(voucherId);
        if (redemption == null) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_Redemption_Missing);
        }

        Datetime now = System.now();
        String reason = String.isNotBlank(comment) ? comment.trim() : PicklistOptions.getLabel(Voucher__c.Cancellation_Category__c, category);
        Savepoint savepoint = Database.setSavepoint();
        try {
            Database.update(
                new Voucher__c(
                    Id = voucher.Id,
                    Status__c = STATUS_CANCELLED,
                    Cancelled_At__c = now,
                    Cancellation_Category__c = category,
                    Cancellation_Reason__c = reason
                ),
                AccessLevel.SYSTEM_MODE
            );
            Database.insert(
                new Point_Ledger__c(
                    Member__c = voucher.Member__c,
                    Points__c = -redemption.Points__c,
                    Entry_Type__c = ENTRY_TYPE_REFUND,
                    Voucher__c = voucher.Id,
                    Reverses_Entry__c = redemption.Id,
                    Reason__c = reason,
                    Occurred_At__c = now,
                    Unique_Key__c = 'VCH:' + voucher.Id + ':REFUND'
                ),
                AccessLevel.SYSTEM_MODE
            );
        } catch (DmlException dmlException) {
            Database.rollback(savepoint);
            throw dmlException;
        }
        return -redemption.Points__c;
    }

    private void validate(String category, String comment) {
        if (!PicklistOptions.isValid(Voucher__c.Cancellation_Category__c, category)) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_Category_Required);
        }
        if (String.isNotBlank(comment) && comment.trim().length() > MAX_COMMENT_LENGTH) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_Comment_Too_Long);
        }
    }
}
