public with sharing class PurchaseSimulationController {
    @TestVisible
    private static PurchaseSimulationService service = new PurchaseSimulationService();

    public class SimulationContext {
        @AuraEnabled
        public String memberName;
        @AuraEnabled
        public String memberNumber;
        @AuraEnabled
        public Decimal balance;
        @AuraEnabled
        public Boolean isActive;
    }

    public class SimulationResult {
        @AuraEnabled
        public Id transactionId;
        @AuraEnabled
        public String transactionName;
        @AuraEnabled
        public Boolean isProcessed;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public Decimal baseFuelPoints;
        @AuraEnabled
        public Decimal baseOtherPoints;
        @AuraEnabled
        public Decimal campaignPoints;
        @AuraEnabled
        public Decimal totalPoints;
        @AuraEnabled
        public Decimal newBalance;
    }

    @AuraEnabled
    public static SimulationContext getContext(Id memberId) {
        try {
            Account member = service.getMember(memberId);
            SimulationContext context = new SimulationContext();
            context.memberName = member.Name;
            context.memberNumber = member.Member_Number__c;
            context.balance = member.Points_Balance__c ?? 0;
            context.isActive = member.Membership_Status__c == LoyaltyTransactionService.MEMBERSHIP_ACTIVE;
            return context;
        } catch (Exception caughtException) {
            throw LoyaltyControllerErrors.toAuraException(caughtException);
        }
    }

    @AuraEnabled
    public static SimulationResult simulatePurchase(Id memberId, Decimal liters, Decimal fuelAmount, Decimal otherAmount, Datetime purchasedAt) {
        try {
            Loyalty_Transaction__c loyaltyTransaction = service.simulate(memberId, liters, fuelAmount, otherAmount, purchasedAt);
            SimulationResult result = new SimulationResult();
            result.transactionId = loyaltyTransaction.Id;
            result.transactionName = loyaltyTransaction.Name;
            result.isProcessed = loyaltyTransaction.Processing_Status__c == LoyaltyTransactionService.STATUS_PROCESSED;
            result.errorMessage = loyaltyTransaction.Processing_Error__c;
            result.baseFuelPoints = loyaltyTransaction.Base_Fuel_Points__c;
            result.baseOtherPoints = loyaltyTransaction.Base_Other_Points__c;
            result.campaignPoints = loyaltyTransaction.Campaign_Points__c;
            result.totalPoints = loyaltyTransaction.Total_Points__c;
            result.newBalance = service.getBalance(memberId);
            return result;
        } catch (Exception caughtException) {
            throw LoyaltyControllerErrors.toAuraException(caughtException);
        }
    }
}
