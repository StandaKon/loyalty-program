public with sharing class VoucherVerificationController {
    @TestVisible
    private static VoucherRedemptionService service = new VoucherRedemptionService();

    public class VoucherView {
        @AuraEnabled public String code;
        @AuraEnabled public String rewardName;
        @AuraEnabled public String status;
        @AuraEnabled public String statusLabel;
        @AuraEnabled public Datetime issuedAt;
        @AuraEnabled public Datetime redeemedAt;
        @AuraEnabled public String serviceLocation;
        @AuraEnabled public String serviceOrderNumber;
        @AuraEnabled public Datetime cancelledAt;
        @AuraEnabled public Boolean canRedeem;
    }

    @AuraEnabled
    public static VoucherView findVoucher(String code) {
        try {
            Voucher__c voucher = service.find(code);
            return voucher == null ? null : toView(voucher);
        } catch (Exception caughtException) {
            throw LoyaltyControllerErrors.toAuraException(caughtException);
        }
    }

    @AuraEnabled
    public static VoucherView redeemVoucher(String code, String serviceLocation, String serviceOrderNumber) {
        try {
            return toView(service.redeem(code, serviceLocation, serviceOrderNumber));
        } catch (Exception caughtException) {
            throw LoyaltyControllerErrors.toAuraException(caughtException);
        }
    }

    private static VoucherView toView(Voucher__c voucher) {
        VoucherView view = new VoucherView();
        view.code = voucher.Code__c;
        view.rewardName = voucher.Reward_Name__c;
        view.status = voucher.Status__c;
        view.statusLabel = PicklistOptions.getLabel(Voucher__c.Status__c, voucher.Status__c);
        view.issuedAt = voucher.Issued_At__c;
        view.redeemedAt = voucher.Redeemed_At__c;
        view.serviceLocation = voucher.Service_Location__c;
        view.serviceOrderNumber = voucher.Service_Order_Number__c;
        view.cancelledAt = voucher.Cancelled_At__c;
        view.canRedeem = voucher.Status__c == 'Issued';
        return view;
    }
}
