public with sharing class VoucherCancellationController {
    @TestVisible
    private static VoucherSelector voucherSelector = new VoucherSelector();
    @TestVisible
    private static VoucherCancellationService service = new VoucherCancellationService();

    public class CancellationContext {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String rewardName;
        @AuraEnabled
        public String memberName;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String statusLabel;
        @AuraEnabled
        public Decimal pointsSpent;
        @AuraEnabled
        public Boolean canCancel;
        @AuraEnabled
        public Boolean isIssued;
        @AuraEnabled
        public List<PicklistOptions.Option> categories;
    }

    @AuraEnabled
    public static CancellationContext getContext(Id voucherId) {
        try {
            Voucher__c voucher = voucherSelector.getById(voucherId);
            if (voucher == null) {
                throw new LoyaltyActionException(Label.Loyalty_BO_Error_Voucher_Not_Found);
            }
            CancellationContext context = new CancellationContext();
            context.code = voucher.Code__c;
            context.rewardName = voucher.Reward_Name__c;
            context.memberName = voucher.Member__r?.Name;
            context.status = voucher.Status__c;
            context.statusLabel = PicklistOptions.getLabel(Voucher__c.Status__c, voucher.Status__c);
            context.pointsSpent = voucher.Points_Spent__c;
            context.isIssued = voucher.Status__c == 'Issued';
            context.canCancel = LoyaltyPermissions.canAdjustPoints();
            context.categories = service.getCategories();
            return context;
        } catch (Exception caughtException) {
            throw LoyaltyControllerErrors.toAuraException(caughtException);
        }
    }

    @AuraEnabled
    public static Decimal cancelVoucher(Id voucherId, String category, String comment) {
        try {
            return service.cancel(voucherId, category, comment);
        } catch (Exception caughtException) {
            throw LoyaltyControllerErrors.toAuraException(caughtException);
        }
    }
}
