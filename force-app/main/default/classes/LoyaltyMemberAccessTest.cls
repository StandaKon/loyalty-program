@IsTest
private with sharing class LoyaltyMemberAccessTest {
    @IsTest
    static void shouldIsolateAccountsTransactionsLedgerAndVouchers_WhenTwoCustomersSignIn() {
        UserRole role = new UserRole(Name = 'B1 test account owner');
        Database.insert(role, true, AccessLevel.SYSTEM_MODE);
        User owner = internalOwner(role.Id);
        Database.insert(owner, true, AccessLevel.SYSTEM_MODE);
        List<Account> members = new List<Account>();
        List<Voucher__c> vouchers = new List<Voucher__c>();
        System.runAs(owner) {
            members.add(TestDataFactory.member('access-one'));
            members.add(TestDataFactory.member('access-two'));
            Database.insert(members, true, AccessLevel.SYSTEM_MODE);
            createMemberRecords(members, vouchers);
        }
        List<User> customers = createCustomers(members);
        Set<Id> memberIds = new Map<Id, Account>(members).keySet();
        Test.startTest();
        for (Integer index = 0; index < customers.size(); index++) {
            System.runAs(customers[index]) {
                assertOwnDataOnly(members[index].Id, vouchers[index].Code__c, memberIds);
            }
        }
        Test.stopTest();
    }

    private static User internalOwner(Id roleId) {
        String token = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
        return new User(Username = 'b1-owner-' + token + '@example.com',
            Email = 'b1-owner@example.com', Alias = 'b1owner', LastName = 'B1 Owner',
            TimeZoneSidKey = 'Europe/Prague', LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
            ProfileId = UserInfo.getProfileId(), UserRoleId = roleId);
    }

    private static void createMemberRecords(List<Account> members, List<Voucher__c> vouchers) {
        Account partner = new Account(Name = 'Access test partner', Type = 'Partner');
        Database.insert(partner, true, AccessLevel.SYSTEM_MODE);
        Reward__c reward = TestDataFactory.reward(partner.Id);
        Database.insert(reward, true, AccessLevel.SYSTEM_MODE);
        List<Loyalty_Transaction__c> purchases = new List<Loyalty_Transaction__c>();
        List<Point_Ledger__c> funding = new List<Point_Ledger__c>();
        for (Account member : members) {
            purchases.add(TestDataFactory.purchase(member.Id, 'access-purchase-' + member.Id));
            funding.add(TestDataFactory.adjustment(member.Id, 740, 'access-funding-' + member.Id));
            vouchers.add(TestDataFactory.voucher(member.Id, reward));
        }
        vouchers[1].Code__c = 'ENE-EFGH-6789';
        Database.insert(purchases, true, AccessLevel.SYSTEM_MODE);
        Database.insert(funding, true, AccessLevel.SYSTEM_MODE);
        Database.insert(vouchers, true, AccessLevel.SYSTEM_MODE);
    }

    private static List<User> createCustomers(List<Account> members) {
        Set<Id> memberIds = new Map<Id, Account>(members).keySet();
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, PersonContactId FROM Account
            WHERE Id IN :memberIds WITH SYSTEM_MODE]);
        // B0 provisions a custom community profile after the standard profiles.
        Id profileId = [SELECT Id FROM Profile WHERE UserLicense.LicenseDefinitionKey = 'PID_Customer_Community'
            WITH SYSTEM_MODE ORDER BY CreatedDate DESC LIMIT 1].Id;
        Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Loyalty_Member'
            WITH SYSTEM_MODE LIMIT 1].Id;
        List<User> customers = new List<User>();
        for (Account member : members) {
            customers.add(new User(Username = 'b1-customer-' + member.Id + '@example.com',
                Email = 'b1-customer@example.com', Alias = 'b1cust', LastName = 'B1 Customer',
                CommunityNickname = 'b1-' + member.Id, ContactId = accounts.get(member.Id).PersonContactId,
                ProfileId = profileId, TimeZoneSidKey = 'Europe/Prague', LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US'));
        }
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Database.insert(customers, true, AccessLevel.SYSTEM_MODE);
            List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
            for (User customer : customers) {
                assignments.add(new PermissionSetAssignment(AssigneeId = customer.Id,
                    PermissionSetId = permissionSetId));
            }
            Database.insert(assignments, true, AccessLevel.SYSTEM_MODE);
        }
        return customers;
    }

    private static void assertOwnDataOnly(Id ownId, String ownCode, Set<Id> memberIds) {
        List<Account> accounts = [SELECT Id FROM Account WHERE Id IN :memberIds WITH USER_MODE];
        List<Loyalty_Transaction__c> purchases = [SELECT Member__c FROM Loyalty_Transaction__c
            WHERE Member__c IN :memberIds WITH USER_MODE];
        List<Point_Ledger__c> entries = [SELECT Member__c FROM Point_Ledger__c
            WHERE Member__c IN :memberIds WITH USER_MODE];
        List<Voucher__c> vouchers = [SELECT Member__c, Code__c FROM Voucher__c
            WHERE Member__c IN :memberIds WITH USER_MODE];
        Assert.areEqual(1, accounts.size(), 'A customer must see only their own Account.');
        Assert.areEqual(ownId, accounts[0].Id, 'The visible Account must belong to the signed-in customer.');
        Assert.areEqual(1, purchases.size(), 'The sharing set must expose only the customer purchase.');
        Assert.areEqual(ownId, purchases[0].Member__c, 'A foreign purchase must remain hidden.');
        Assert.areEqual(1, entries.size(), 'Ledger must inherit access only from the customer Account.');
        Assert.areEqual(ownId, entries[0].Member__c, 'A foreign ledger entry must remain hidden.');
        Assert.areEqual(1, vouchers.size(), 'The sharing set must expose only the customer voucher.');
        Assert.areEqual(ownCode, vouchers[0].Code__c, 'A foreign voucher code must remain hidden.');
        Assert.isFalse(Point_Ledger__c.SObjectType.getDescribe().isCreateable(),
            'A customer must not create points directly.');
        Assert.isFalse(Voucher__c.SObjectType.getDescribe().isCreateable(),
            'A customer must not issue vouchers directly.');
    }
}
