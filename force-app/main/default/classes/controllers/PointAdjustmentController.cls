public with sharing class PointAdjustmentController {
    @TestVisible
    private static AccountSelector accountSelector = new AccountSelector();
    @TestVisible
    private static PointAdjustmentService service = new PointAdjustmentService();

    public class AdjustmentContext {
        @AuraEnabled
        public String memberName;
        @AuraEnabled
        public String memberNumber;
        @AuraEnabled
        public Decimal balance;
        @AuraEnabled
        public Boolean canAdjust;
        @AuraEnabled
        public List<PicklistOptions.Option> categories;
    }

    @AuraEnabled
    public static AdjustmentContext getContext(Id memberId) {
        try {
            Account member = accountSelector.getMemberById(memberId);
            if (member == null || String.isBlank(member.Member_Number__c)) {
                throw new LoyaltyActionException(Label.Loyalty_BO_Error_Not_Member);
            }
            AdjustmentContext context = new AdjustmentContext();
            context.memberName = member.Name;
            context.memberNumber = member.Member_Number__c;
            context.balance = member.Points_Balance__c ?? 0;
            context.canAdjust = LoyaltyPermissions.canAdjustPoints();
            context.categories = service.getCategories();
            return context;
        } catch (Exception caughtException) {
            throw LoyaltyControllerErrors.toAuraException(caughtException);
        }
    }

    @AuraEnabled
    public static Decimal adjustPoints(Id memberId, Integer points, String category, String comment, String requestKey) {
        try {
            return service.adjust(memberId, points, category, comment, requestKey);
        } catch (Exception caughtException) {
            throw LoyaltyControllerErrors.toAuraException(caughtException);
        }
    }
}
