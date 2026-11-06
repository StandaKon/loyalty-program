/**
 * Encapsulates all SOQL for Reward__c records.
 */
public inherited sharing class PortalRewardSelector {
    public List<Reward__c> selectActiveOrderedByPointsCost() {
        return [
            SELECT Id, Name, Points_Cost__c
            FROM Reward__c
            WHERE Is_Active__c = TRUE AND Points_Cost__c > 0
            WITH USER_MODE
            ORDER BY Points_Cost__c ASC
        ];
    }

    public List<Reward__c> selectActiveCatalog() {
        return [
            SELECT Id, Name, Description__c, Points_Cost__c, Value_CZK__c
            FROM Reward__c
            WHERE Is_Active__c = TRUE AND Points_Cost__c > 0
            WITH USER_MODE
            ORDER BY Sort_Order__c ASC NULLS LAST, Points_Cost__c ASC, Name ASC
        ];
    }
}
