public with sharing class TransactionReversalController {
    @TestVisible
    private static TransactionReversalService service = new TransactionReversalService();

    public class ReversalContext {
        @AuraEnabled
        public String transactionName;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Integer points;
        @AuraEnabled
        public Boolean isReversed;
        @AuraEnabled
        public Boolean canReverse;
        @AuraEnabled
        public List<PicklistOptions.Option> reasons;
    }

    @AuraEnabled
    public static ReversalContext getContext(Id transactionId) {
        try {
            Loyalty_Transaction__c loyaltyTransaction = service.getTransaction(transactionId);
            TransactionReversalService.ReversalState state = service.getState(transactionId);
            ReversalContext context = new ReversalContext();
            context.transactionName = loyaltyTransaction.Name;
            context.status = loyaltyTransaction.Processing_Status__c;
            context.points = state.points;
            context.isReversed = state.isReversed;
            context.canReverse = LoyaltyPermissions.canAdjustPoints();
            context.reasons = service.getReasons();
            return context;
        } catch (Exception caughtException) {
            throw LoyaltyControllerErrors.toAuraException(caughtException);
        }
    }

    @AuraEnabled
    public static Integer reverseTransaction(Id transactionId, String reasonCode, String comment) {
        try {
            return service.reverse(transactionId, reasonCode, comment);
        } catch (Exception caughtException) {
            throw LoyaltyControllerErrors.toAuraException(caughtException);
        }
    }
}
