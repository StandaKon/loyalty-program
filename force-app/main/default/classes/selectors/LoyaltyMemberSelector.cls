/**
 * Member (Person Account) reads of the optional B11 features.
 * System mode: tier and expiry processes evaluate any member; the portal passes only the member resolved from UserInfo.
 */
public inherited sharing class LoyaltyMemberSelector {
    public Database.QueryLocator getMembersQueryLocator() {
        return Database.getQueryLocator(
            [
                SELECT Id
                FROM Account
                WHERE Member_Number__c != NULL AND IsPersonAccount = TRUE
                WITH SYSTEM_MODE
            ]
        );
    }

    public List<Account> getByIds(Set<Id> memberIds) {
        return [
            SELECT Id, Member_Number__c, Membership_Status__c, Loyalty_Tier__c, Points_Balance__c
            FROM Account
            WHERE Id IN :memberIds AND Member_Number__c != NULL
            WITH SYSTEM_MODE
        ];
    }

    // Row locks serialize point-changing operations of the members (B1 4.5).
    public List<Account> getByIdsForUpdate(Set<Id> memberIds) {
        return [
            SELECT Id, Member_Number__c, Membership_Status__c, Loyalty_Tier__c, Points_Balance__c
            FROM Account
            WHERE Id IN :memberIds AND Member_Number__c != NULL
            WITH SYSTEM_MODE
            FOR UPDATE
        ];
    }
}
