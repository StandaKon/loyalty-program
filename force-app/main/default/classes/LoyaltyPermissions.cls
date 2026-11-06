/**
 * Custom permission checks of the EneOil Klub back office (B5).
 */
public inherited sharing class LoyaltyPermissions {
    private static final String ADJUST_POINTS = 'Loyalty_Adjust_Points';
    private static final String SERVICE_OPERATOR = 'Loyalty_Service_Operator';

    public static Boolean canAdjustPoints() {
        return FeatureManagement.checkPermission(ADJUST_POINTS);
    }

    public static void requireAdjustPoints() {
        if (!canAdjustPoints()) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_No_Permission);
        }
    }

    public static Boolean canRedeemVouchers() {
        return FeatureManagement.checkPermission(SERVICE_OPERATOR);
    }

    public static void requireServiceOperator() {
        if (!canRedeemVouchers()) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_No_Permission);
        }
    }
}
