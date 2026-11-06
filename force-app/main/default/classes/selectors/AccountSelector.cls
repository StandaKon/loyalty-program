public inherited sharing class AccountSelector {
    // System mode: the points engine validates membership for any purchase, independent of the importing user's FLS.
    public Map<Id, Account> getMembersByIds(Set<Id> accountIds) {
        return new Map<Id, Account>(
            [
                SELECT Id, IsPersonAccount, Member_Number__c, Membership_Status__c, Loyalty_Tier__c
                FROM Account
                WHERE Id IN :accountIds
                WITH SYSTEM_MODE
            ]
        );
    }

    public Account getMemberByNumber(String memberNumber) {
        List<Account> members = [
            SELECT Id, Member_Number__c, Membership_Status__c, Points_Balance__c
            FROM Account
            WHERE Member_Number__c = :memberNumber AND IsPersonAccount = TRUE
            WITH SYSTEM_MODE
            LIMIT 1
        ];
        return members.isEmpty() ? null : members[0];
    }

    public Account getMemberById(Id memberId) {
        List<Account> members = [
            SELECT Id, Name, Member_Number__c, Membership_Status__c, Points_Balance__c
            FROM Account
            WHERE Id = :memberId AND IsPersonAccount = TRUE
            WITH SYSTEM_MODE
            LIMIT 1
        ];
        return members.isEmpty() ? null : members[0];
    }

    // Row lock serializes all balance-changing operations of one member (B1 §4.5), so the balance check stays valid until commit.
    public Account getMemberByIdForUpdate(Id memberId) {
        List<Account> members = [
            SELECT Id, Name, Member_Number__c, Membership_Status__c, Points_Balance__c
            FROM Account
            WHERE Id = :memberId AND IsPersonAccount = TRUE
            WITH SYSTEM_MODE
            LIMIT 1
            FOR UPDATE
        ];
        return members.isEmpty() ? null : members[0];
    }
}
