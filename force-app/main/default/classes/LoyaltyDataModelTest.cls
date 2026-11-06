@IsTest
private with sharing class LoyaltyDataModelTest {
    @TestSetup
    static void setupData() {
        Account member = TestDataFactory.member('member');
        Account other = TestDataFactory.member('other');
        Account partner = new Account(Name = 'B1 EneServis', Type = 'Partner');
        Database.insert(new List<Account>{member, other, partner}, true, AccessLevel.SYSTEM_MODE);
        Database.insert(TestDataFactory.reward(partner.Id), true, AccessLevel.SYSTEM_MODE);
    }

    private static Account member() {
        return [SELECT Id, PersonContactId FROM Account WHERE Member_Number__c = 'TEST-member'
            WITH SYSTEM_MODE LIMIT 1];
    }

    private static void assertRejected(Database.SaveResult result, String expected) {
        Assert.isFalse(result.isSuccess(), 'Invalid data must be rejected: ' + expected);
        Assert.isTrue(result.getErrors()[0].getMessage().contains(expected),
            'Expected ' + expected + ', got ' + result.getErrors()[0].getMessage());
    }

    @IsTest
    static void shouldRollUp109Points_WhenPurchaseAndTwoCampaignsAreRecorded() {
        Account account = member();
        Loyalty_Transaction__c purchase = TestDataFactory.purchase(account.Id, 'sample-109');
        Loyalty_Campaign__c campaign = TestDataFactory.campaign('Fixed bonus');
        Database.insert(purchase, true, AccessLevel.SYSTEM_MODE);
        Database.insert(campaign, true, AccessLevel.SYSTEM_MODE);
        List<Point_Ledger__c> entries = new List<Point_Ledger__c>();
        entries.add(new Point_Ledger__c(Member__c = account.Id, Points__c = 54,
            Entry_Type__c = 'PurchaseBase', Unique_Key__c = 'BASE-109',
            Transaction__c = purchase.Id, Occurred_At__c = purchase.Purchased_At__c));
        for (Integer bonus : new List<Integer>{5, 50}) {
            entries.add(new Point_Ledger__c(Member__c = account.Id, Points__c = bonus,
                Entry_Type__c = 'CampaignBonus', Unique_Key__c = 'CAM-' + bonus,
                Transaction__c = purchase.Id, Campaign__c = campaign.Id,
                Occurred_At__c = purchase.Purchased_At__c, Applied_Condition_Field__c = 'Liters',
                Applied_Threshold__c = 40, Applied_Reward_Type__c = 'FixedBonus',
                Applied_Reward_Value__c = bonus));
        }
        Test.startTest();
        Database.insert(entries, true, AccessLevel.SYSTEM_MODE);
        Test.stopTest();
        Assert.areEqual(109, [SELECT Points_Balance__c FROM Account WHERE Id = :account.Id
            WITH SYSTEM_MODE].Points_Balance__c, 'The roll-up must equal 54 + 5 + 50.');
    }

    @IsTest
    static void shouldSupportBulkRollup_When251EntriesAreInserted() {
        Id memberId = member().Id;
        List<Point_Ledger__c> entries = new List<Point_Ledger__c>();
        for (Integer index = 0; index < 251; index++) {
            entries.add(TestDataFactory.adjustment(memberId, 1, 'BULK-' + index));
        }
        Test.startTest();
        Database.insert(entries, true, AccessLevel.SYSTEM_MODE);
        Test.stopTest();
        Assert.areEqual(251, [SELECT Points_Balance__c FROM Account WHERE Id = :memberId
            WITH SYSTEM_MODE].Points_Balance__c, 'All 251 entries must be summarized.');
    }

    @IsTest
    static void shouldRejectInvalidTotalsAndDuplicates_WhenPurchaseIsInserted() {
        Id memberId = member().Id;
        Loyalty_Transaction__c invalid = TestDataFactory.purchase(memberId, 'invalid');
        invalid.Total_Amount__c = 1;
        Loyalty_Transaction__c valid = TestDataFactory.purchase(memberId, 'same-pos');
        Test.startTest();
        assertRejected(Database.insert(invalid, false, AccessLevel.SYSTEM_MODE), 'Amounts');
        Database.insert(valid, true, AccessLevel.SYSTEM_MODE);
        Database.SaveResult duplicate = Database.insert(
            TestDataFactory.purchase(memberId, 'same-pos'), false, AccessLevel.SYSTEM_MODE);
        Test.stopTest();
        Assert.isFalse(duplicate.isSuccess(), 'The POS external ID must be unique.');
        Assert.areEqual(StatusCode.DUPLICATE_VALUE, duplicate.getErrors()[0].getStatusCode(),
            'A duplicate purchase must fail at the database constraint.');
    }

    @IsTest
    static void shouldRejectMutationAndOverdraft_WhenLedgerIsWritten() {
        Id memberId = member().Id;
        Point_Ledger__c original = TestDataFactory.adjustment(memberId, 100, 'funding');
        Database.insert(original, true, AccessLevel.SYSTEM_MODE);
        original.Points__c = 101;
        Test.startTest();
        assertRejected(Database.update(original, false, AccessLevel.SYSTEM_MODE), 'cannot be edited');
        assertRejected(Database.insert(TestDataFactory.adjustment(memberId, -101, 'overdraft'),
            false, AccessLevel.SYSTEM_MODE), 'negative');
        Test.stopTest();
        Assert.areEqual(100, [SELECT Points_Balance__c FROM Account WHERE Id = :memberId
            WITH SYSTEM_MODE].Points_Balance__c, 'Failed operations must not change the balance.');
    }

    @IsTest
    static void shouldPreserveVoucherSnapshot_WhenRewardChanges() {
        Id memberId = member().Id;
        Reward__c reward = [SELECT Id, Name, Partner__c, Points_Cost__c, Value_CZK__c,
            Description__c FROM Reward__c WITH SYSTEM_MODE LIMIT 1];
        Database.insert(TestDataFactory.adjustment(memberId, 740, 'voucher-funding'), true, AccessLevel.SYSTEM_MODE);
        Voucher__c voucher = TestDataFactory.voucher(memberId, reward);
        Test.startTest();
        Database.insert(voucher, true, AccessLevel.SYSTEM_MODE);
        Database.insert(new Point_Ledger__c(Member__c = memberId, Points__c = -500,
            Entry_Type__c = 'Redemption', Voucher__c = voucher.Id, Unique_Key__c = 'voucher-spend',
            Occurred_At__c = System.now()), true, AccessLevel.SYSTEM_MODE);
        reward.Value_CZK__c = 300;
        Database.update(reward, true, AccessLevel.SYSTEM_MODE);
        Test.stopTest();
        Assert.areEqual(240, [SELECT Points_Balance__c FROM Account WHERE Id = :memberId
            WITH SYSTEM_MODE].Points_Balance__c, 'The voucher must deduct 500 points.');
        Assert.areEqual(200, [SELECT Value_CZK__c FROM Voucher__c WHERE Id = :voucher.Id
            WITH SYSTEM_MODE].Value_CZK__c, 'Existing voucher value must remain 200 CZK.');
    }

    @IsTest
    static void shouldRejectDuplicateActivity_WhenUniqueKeyIsRepeated() {
        Id memberId = member().Id;
        Point_Ledger__c first = new Point_Ledger__c(Member__c = memberId, Points__c = 100,
            Entry_Type__c = 'ProfileBonus', Unique_Key__c = 'MEM:' + memberId + ':PROFILE',
            Occurred_At__c = System.now());
        Database.insert(first, true, AccessLevel.SYSTEM_MODE);
        Point_Ledger__c duplicate = first.clone(false, false, false, false);
        Test.startTest();
        Database.SaveResult result = Database.insert(duplicate, false, AccessLevel.SYSTEM_MODE);
        Test.stopTest();
        Assert.isFalse(result.isSuccess(), 'An activity key cannot be inserted twice.');
        Assert.areEqual(StatusCode.DUPLICATE_VALUE, result.getErrors()[0].getStatusCode(),
            'The database must reject a repeated activity key.');
    }

    @IsTest
    static void shouldRejectSourceMismatch_WhenEntryBelongsToAnotherMember() {
        Id memberId = member().Id;
        Id otherId = [SELECT Id FROM Account WHERE Member_Number__c = 'TEST-other'
            WITH SYSTEM_MODE LIMIT 1].Id;
        Loyalty_Transaction__c purchase = TestDataFactory.purchase(otherId, 'other-member');
        Database.insert(purchase, true, AccessLevel.SYSTEM_MODE);
        Point_Ledger__c entry = new Point_Ledger__c(Member__c = memberId, Points__c = 1,
            Entry_Type__c = 'PurchaseBase', Transaction__c = purchase.Id,
            Unique_Key__c = 'wrong-member', Occurred_At__c = System.now());
        Test.startTest();
        assertRejected(Database.insert(entry, false, AccessLevel.SYSTEM_MODE), 'same member');
        Test.stopTest();
    }

    @IsTest
    static void shouldRejectInvalidCampaign_WhenFixedBonusIsFractional() {
        Loyalty_Campaign__c campaign = TestDataFactory.campaign('Invalid bonus');
        campaign.Reward_Value__c = 1.5;
        Test.startTest();
        assertRejected(Database.insert(campaign, false, AccessLevel.SYSTEM_MODE), 'campaign');
        Test.stopTest();
    }

    @IsTest
    static void shouldExposeReadOnlyMemberPermissions() {
        Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Loyalty_Member'
            WITH SYSTEM_MODE LIMIT 1].Id;
        Test.startTest();
        List<ObjectPermissions> permissions = [SELECT SObjectType, PermissionsRead,
            PermissionsCreate, PermissionsEdit, PermissionsDelete, PermissionsViewAllRecords,
            PermissionsModifyAllRecords FROM ObjectPermissions WHERE ParentId = :permissionSetId
            WITH SYSTEM_MODE];
        Test.stopTest();
        Assert.areEqual(7, permissions.size(), 'The member set must grant Account, Contact, and five custom objects.');
        for (ObjectPermissions permission : permissions) {
            Assert.isTrue(permission.PermissionsRead, 'Member object permissions must be readable.');
            Assert.isFalse(permission.PermissionsCreate || permission.PermissionsEdit ||
                permission.PermissionsDelete || permission.PermissionsViewAllRecords ||
                permission.PermissionsModifyAllRecords, 'Member access must be read only without global access.');
        }
    }
}
