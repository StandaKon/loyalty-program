public inherited sharing class VoucherRedemptionService {
    private static final String STATUS_ISSUED = 'Issued';
    private static final String STATUS_REDEEMED = 'Redeemed';
    private static final Integer MAX_LOCATION_LENGTH = 80;
    private static final Integer MAX_ORDER_LENGTH = 80;
    private final VoucherSelector voucherSelector;

    public VoucherRedemptionService() {
        this(new VoucherSelector());
    }

    @TestVisible
    private VoucherRedemptionService(VoucherSelector voucherSelector) {
        this.voucherSelector = voucherSelector;
    }

    public Voucher__c find(String suppliedCode) {
        LoyaltyPermissions.requireServiceOperator();
        String code = normalize(suppliedCode);
        return code == null ? null : voucherSelector.getByCode(code);
    }

    public Voucher__c redeem(String suppliedCode, String serviceLocation, String serviceOrderNumber) {
        LoyaltyPermissions.requireServiceOperator();
        String code = normalize(suppliedCode);
        if (code == null) {
            throw new LoyaltyActionException(Label.Loyalty_Voucher_Error_Invalid_Code);
        }
        validateDetails(serviceLocation, serviceOrderNumber);
        Voucher__c voucher = voucherSelector.getByCodeForUpdate(code);
        if (voucher == null) {
            throw new LoyaltyActionException(Label.Loyalty_Voucher_Error_Not_Found);
        }
        if (voucher.Status__c != STATUS_ISSUED) {
            throw new LoyaltyActionException(Label.Loyalty_Voucher_Error_Not_Active);
        }
        Database.update(
            new Voucher__c(
                Id = voucher.Id,
                Status__c = STATUS_REDEEMED,
                Redeemed_At__c = System.now(),
                Redeemed_By__c = UserInfo.getUserId(),
                Service_Location__c = serviceLocation.trim(),
                Service_Order_Number__c = serviceOrderNumber.trim()
            ),
            AccessLevel.SYSTEM_MODE
        );
        return voucherSelector.getByCode(code);
    }

    public static String normalize(String suppliedCode) {
        if (String.isBlank(suppliedCode)) {
            return null;
        }
        String compact = suppliedCode.replaceAll('[^A-Za-z0-9]', '').toUpperCase();
        if (compact.startsWith('ENE')) {
            compact = compact.substring(3);
        }
        if (!Pattern.matches('[ABCDEFGHJKMNPQRSTUVWXYZ23456789]{8}', compact)) {
            return null;
        }
        return 'ENE-' + compact.substring(0, 4) + '-' + compact.substring(4);
    }

    private void validateDetails(String serviceLocation, String serviceOrderNumber) {
        if (String.isBlank(serviceLocation) || serviceLocation.trim().length() > MAX_LOCATION_LENGTH ||
            String.isBlank(serviceOrderNumber) || serviceOrderNumber.trim().length() > MAX_ORDER_LENGTH) {
            throw new LoyaltyActionException(Label.Loyalty_Voucher_Error_Redemption_Details);
        }
    }
}
