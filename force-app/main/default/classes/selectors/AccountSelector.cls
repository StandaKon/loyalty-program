public inherited sharing class AccountSelector {
    // System mode: the points engine validates membership for any purchase, independent of the importing user's FLS.
    public Map<Id, Account> getMembersByIds(Set<Id> accountIds) {
        return new Map<Id, Account>(
            [
                SELECT Id, IsPersonAccount, Member_Number__c, Membership_Status__c
                FROM Account
                WHERE Id IN :accountIds
                WITH SYSTEM_MODE
            ]
        );
    }
}
