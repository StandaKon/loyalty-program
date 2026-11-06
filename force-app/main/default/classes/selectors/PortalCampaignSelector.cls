/**
 * Encapsulates all SOQL for Loyalty_Campaign__c records.
 */
public inherited sharing class PortalCampaignSelector {
    public List<Loyalty_Campaign__c> selectEnabledOn(Date day) {
        if (day == null) {
            return new List<Loyalty_Campaign__c>();
        }
        return [
            SELECT Id, Name, Member_Description__c, End_Date__c
            FROM Loyalty_Campaign__c
            WHERE Is_Enabled__c = TRUE AND Start_Date__c <= :day AND End_Date__c >= :day
            WITH USER_MODE
            ORDER BY End_Date__c ASC, Name ASC
        ];
    }
}
