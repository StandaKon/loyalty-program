public inherited sharing class LoyaltyCampaignSelector {
    // System mode: campaign rules are evaluated by the server for every purchase, independent of the importing user.
    public List<Loyalty_Campaign__c> getEnabledOverlapping(Date fromDate, Date toDate) {
        return [
            SELECT Id, Name, Is_Enabled__c, Start_Date__c, End_Date__c, Condition_Field__c, Threshold__c, Reward_Type__c, Reward_Value__c
            FROM Loyalty_Campaign__c
            WHERE Is_Enabled__c = TRUE AND Start_Date__c <= :toDate AND End_Date__c >= :fromDate
            WITH SYSTEM_MODE
            ORDER BY Start_Date__c, Name
        ];
    }
}
