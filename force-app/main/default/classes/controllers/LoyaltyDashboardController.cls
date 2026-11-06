public with sharing class LoyaltyDashboardController {
    private static final Set<String> PERIODS = new Set<String>{
        LoyaltyDashboardService.PERIOD_THIS_MONTH,
        LoyaltyDashboardService.PERIOD_LAST_MONTH,
        LoyaltyDashboardService.PERIOD_LAST_30_DAYS,
        LoyaltyDashboardService.PERIOD_THIS_YEAR
    };

    @TestVisible
    private static LoyaltyDashboardService service = new LoyaltyDashboardService();

    @AuraEnabled(cacheable=true)
    public static LoyaltyDashboardService.Dashboard getDashboard(String period) {
        try {
            if (!PERIODS.contains(period)) {
                throw new LoyaltyActionException(Label.Loyalty_BO_Error_Invalid_Request);
            }
            return service.getDashboard(period);
        } catch (Exception caughtException) {
            throw LoyaltyControllerErrors.toAuraException(caughtException);
        }
    }
}
