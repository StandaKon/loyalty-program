/**
 * Encapsulates all SOQL for Account (loyalty member = Person Account) records.
 */
public inherited sharing class PortalAccountSelector {
    public List<Account> selectMembersByIds(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return new List<Account>();
        }
        return [
            SELECT Id, FirstName, Member_Number__c, Points_Balance__c
            FROM Account
            WHERE Id IN :accountIds
            WITH USER_MODE
        ];
    }

    public List<Account> selectActivityStateByIds(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return new List<Account>();
        }
        return [
            SELECT
                Id,
                Vehicle_Make__c,
                Vehicle_Model__c,
                Vehicle_Fuel_Type__c,
                Vehicle_Year__c,
                Vehicle_Registration__c,
                Profile_Complete__c,
                Marketing_Consent__c
            FROM Account
            WHERE Id IN :accountIds
            WITH USER_MODE
        ];
    }
}
