@IsTest
private class TransactionReversalServiceTest {
    private static final String MANAGER_PERMISSION_SET = 'Loyalty_Manager';
    private static final String REASON_RETURN = 'Return';

    @TestSetup
    static void setup() {
        Account member = TestDataFactory.member('reversal');
        insert member;
        insert LoyaltyTestDataFactory.buildTransaction(member.Id, 'POS-REVERSAL', 45, 0);
    }

    @IsTest
    static void shouldRemoveAllPurchasePointsOnce_WhenManagerReverses() {
        // Given
        User manager = createUser(true);
        Loyalty_Transaction__c purchase = getPurchase();
        Integer removed;
        TransactionReversalController.ReversalContext context;
        String secondAttemptError;

        // When
        System.runAs(manager) {
            Test.startTest();
            context = TransactionReversalController.getContext(purchase.Id);
            removed = TransactionReversalController.reverseTransaction(purchase.Id, REASON_RETURN, 'Customer returned goods');
            try {
                TransactionReversalController.reverseTransaction(purchase.Id, REASON_RETURN, null);
            } catch (AuraHandledException ex) {
                secondAttemptError = ex.getMessage();
            }
            Test.stopTest();
        }

        // Then
        Assert.areEqual(45, context.points, 'Context shows the purchase points');
        Assert.isTrue(context.canReverse, 'Manager may reverse');
        Assert.areEqual(45, removed, 'All purchase points are removed');
        Point_Ledger__c reversal = [SELECT Points__c, Unique_Key__c, Reason__c FROM Point_Ledger__c WHERE Entry_Type__c = :TransactionReversalService.ENTRY_TYPE_REVERSAL];
        Assert.areEqual(-45, reversal.Points__c, 'Reversal entry is negative');
        Assert.areEqual(TransactionReversalService.buildUniqueKey(purchase.Id), reversal.Unique_Key__c, 'One reversal per purchase');
        Assert.isTrue(reversal.Reason__c.endsWith('Customer returned goods'), 'Reason keeps the comment');
        Assert.isNotNull(secondAttemptError, 'Second reversal is rejected');
        Assert.areEqual(0, [SELECT Points_Balance__c FROM Account WHERE Id = :purchase.Member__c].Points_Balance__c, 'Balance is back to zero');
    }

    @IsTest
    static void shouldRejectWithoutChange_WhenBalanceIsInsufficient() {
        // Given
        User manager = createUser(true);
        Loyalty_Transaction__c purchase = getPurchase();
        insert TestDataFactory.adjustment(purchase.Member__c, -40, 'ADJ-REVERSAL-TEST');
        String error;

        // When
        System.runAs(manager) {
            Test.startTest();
            try {
                TransactionReversalController.reverseTransaction(purchase.Id, REASON_RETURN, null);
            } catch (AuraHandledException ex) {
                error = ex.getMessage();
            }
            Test.stopTest();
        }

        // Then
        Assert.areEqual(String.format(Label.Loyalty_BO_Reversal_Error_Balance, new List<Object>{ 5 }), error, 'Message names the balance');
        Assert.areEqual(0, [SELECT COUNT() FROM Point_Ledger__c WHERE Entry_Type__c = :TransactionReversalService.ENTRY_TYPE_REVERSAL], 'Nothing is written');
    }

    @IsTest
    static void shouldReject_WhenUserHasNoPermission() {
        // Given
        User user = createUser(false);
        Loyalty_Transaction__c purchase = getPurchase();
        String error;

        // When
        System.runAs(user) {
            Test.startTest();
            try {
                TransactionReversalController.reverseTransaction(purchase.Id, REASON_RETURN, null);
            } catch (AuraHandledException ex) {
                error = ex.getMessage();
            }
            Test.stopTest();
        }

        // Then
        Assert.areEqual(Label.Loyalty_BO_Error_No_Permission, error, 'Permission is required');
    }

    private static Loyalty_Transaction__c getPurchase() {
        return [SELECT Id, Member__c FROM Loyalty_Transaction__c WHERE POS_Transaction_Id__c = 'POS-REVERSAL'];
    }

    private static User createUser(Boolean isManager) {
        String suffix = String.valueOf(Math.abs(Crypto.getRandomInteger()));
        User user = new User(
            Username = 'reversal' + suffix + '@example.com.test',
            Email = 'reversal' + suffix + '@example.com',
            LastName = 'Reversal ' + suffix,
            Alias = 'rev' + suffix.left(5),
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'Europe/Prague',
            LocaleSidKey = 'cs_CZ',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8'
        );
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert user;
            if (isManager) {
                insert new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = :MANAGER_PERMISSION_SET].Id);
            }
        }
        return user;
    }
}
