public inherited sharing class LoyaltyTransactionSelector {
    // System mode: POS import (B3) and purchase simulation (B5) read back the points engine result of purchases they create.
    public Loyalty_Transaction__c getById(Id transactionId) {
        List<Loyalty_Transaction__c> transactions = [
            SELECT
                Id,
                Name,
                Member__c,
                Member__r.Member_Number__c,
                POS_Transaction_Id__c,
                Processing_Status__c,
                Processing_Error__c,
                Base_Fuel_Points__c,
                Base_Other_Points__c,
                Campaign_Points__c,
                Total_Points__c
            FROM Loyalty_Transaction__c
            WHERE Id = :transactionId
            WITH SYSTEM_MODE
            LIMIT 1
        ];
        return transactions.isEmpty() ? null : transactions[0];
    }

    public Loyalty_Transaction__c getByPosTransactionId(String posTransactionId) {
        List<Loyalty_Transaction__c> transactions = [
            SELECT
                Id,
                Name,
                Member__c,
                Member__r.Member_Number__c,
                POS_Transaction_Id__c,
                Processing_Status__c,
                Processing_Error__c,
                Base_Fuel_Points__c,
                Base_Other_Points__c,
                Campaign_Points__c,
                Total_Points__c
            FROM Loyalty_Transaction__c
            WHERE POS_Transaction_Id__c = :posTransactionId
            WITH SYSTEM_MODE
            LIMIT 1
        ];
        return transactions.isEmpty() ? null : transactions[0];
    }
}
