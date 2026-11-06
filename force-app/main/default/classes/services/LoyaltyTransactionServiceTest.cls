@IsTest
private class LoyaltyTransactionServiceTest {
    private static final String MEMBERSHIP_BLOCKED = 'Blocked';
    private static final Integer BULK_SIZE = 251;

    @TestSetup
    static void setup() {
        LoyaltyTestDataFactory.createMember(LoyaltyTransactionService.MEMBERSHIP_ACTIVE);
        insert LoyaltyTestDataFactory.buildReferenceCampaigns();
    }

    @IsTest
    static void shouldCreateLedgerAndBalanceOf109_WhenAcceptanceExampleImported() {
        // Given
        Account member = getMember();
        Loyalty_Transaction__c loyaltyTransaction = LoyaltyTestDataFactory.buildTransaction(member.Id, 'POS-T01', 45, 180);

        // When
        Test.startTest();
        insert loyaltyTransaction;
        Test.stopTest();

        // Then
        Loyalty_Transaction__c processed = getTransaction(loyaltyTransaction.Id);
        Assert.areEqual(LoyaltyTransactionService.STATUS_PROCESSED, processed.Processing_Status__c, 'Valid purchase is processed');
        Assert.areEqual(109, processed.Total_Points__c, 'Transaction shows 109 points');
        Assert.areEqual(new List<Decimal>{ 5, 50, 54 }, getLedgerPoints(loyaltyTransaction.Id), 'Base entry plus one entry per campaign');
        Assert.areEqual(109, getMember().Points_Balance__c, 'Balance is the roll-up of ledger entries');
    }

    @IsTest
    static void shouldNotAwardTwice_WhenSamePosIdImportedAgain() {
        // Given
        Account member = getMember();
        insert LoyaltyTestDataFactory.buildTransaction(member.Id, 'POS-T21', 45, 180);

        // When
        Test.startTest();
        Database.SaveResult duplicateResult = Database.insert(LoyaltyTestDataFactory.buildTransaction(member.Id, 'POS-T21', 45, 180), false);
        Test.stopTest();

        // Then
        Assert.isFalse(duplicateResult.isSuccess(), 'Duplicate POS ID must be rejected');
        Assert.areEqual(3, [SELECT COUNT() FROM Point_Ledger__c], 'Only the first import created ledger entries');
        Assert.areEqual(109, getMember().Points_Balance__c, 'Balance is not increased by the duplicate');
    }

    @IsTest
    static void shouldRejectImportRow_WhenAmountsDoNotAddUp() {
        // Given (T20)
        Loyalty_Transaction__c loyaltyTransaction = LoyaltyTestDataFactory.buildTransaction(getMember().Id, 'POS-T20', 45, 180);
        loyaltyTransaction.Total_Amount__c += 1;

        // When
        Test.startTest();
        Database.SaveResult saveResult = Database.insert(loyaltyTransaction, false);
        Test.stopTest();

        // Then
        assertRejected(saveResult);
    }

    @IsTest
    static void shouldMarkErrorWithoutPoints_WhenMemberIsBlocked() {
        // Given
        Account blockedMember = getMember();
        blockedMember.Membership_Status__c = MEMBERSHIP_BLOCKED;
        update blockedMember;
        Loyalty_Transaction__c loyaltyTransaction = LoyaltyTestDataFactory.buildTransaction(blockedMember.Id, 'POS-BLOCKED', 45, 180);

        // When
        Test.startTest();
        insert loyaltyTransaction;
        Test.stopTest();

        // Then
        assertError(loyaltyTransaction.Id, Label.Loyalty_Tx_Error_Member_Inactive);
    }

    @IsTest
    static void shouldRejectImportRow_WhenPurchaseIsInFuture() {
        // Given
        Loyalty_Transaction__c loyaltyTransaction = LoyaltyTestDataFactory.buildTransaction(getMember().Id, 'POS-FUTURE', 45, 180);
        loyaltyTransaction.Purchased_At__c = Datetime.now().addDays(1);

        // When
        Test.startTest();
        Database.SaveResult saveResult = Database.insert(loyaltyTransaction, false);
        Test.stopTest();

        // Then
        assertRejected(saveResult);
    }

    @IsTest
    static void shouldProcessAndAwardPoints_WhenErrorTransactionIsSavedAgain() {
        // Given: purchase of a blocked member ends in Error, then the member is reactivated
        Account member = getMember();
        member.Membership_Status__c = MEMBERSHIP_BLOCKED;
        update member;
        Loyalty_Transaction__c loyaltyTransaction = LoyaltyTestDataFactory.buildTransaction(member.Id, 'POS-RETRY', 45, 180);
        insert loyaltyTransaction;
        member.Membership_Status__c = LoyaltyTransactionService.MEMBERSHIP_ACTIVE;
        update member;

        // When
        Test.startTest();
        update loyaltyTransaction;
        Test.stopTest();

        // Then
        Loyalty_Transaction__c processed = getTransaction(loyaltyTransaction.Id);
        Assert.areEqual(LoyaltyTransactionService.STATUS_PROCESSED, processed.Processing_Status__c, 'Error purchase is reprocessed on save');
        Assert.isNull(processed.Processing_Error__c, 'Error reason is cleared');
        Assert.areEqual(109, getMember().Points_Balance__c, 'Points are awarded once after reprocessing');
    }

    @IsTest
    static void shouldRejectChange_WhenTransactionAlreadyProcessed() {
        // Given
        Loyalty_Transaction__c loyaltyTransaction = LoyaltyTestDataFactory.buildTransaction(getMember().Id, 'POS-LOCKED', 45, 180);
        insert loyaltyTransaction;

        // When
        Test.startTest();
        loyaltyTransaction.Liters__c = 60;
        Database.SaveResult updateResult = Database.update(loyaltyTransaction, false);
        Test.stopTest();

        // Then
        Assert.isFalse(updateResult.isSuccess(), 'Processed purchase must be locked');
        Assert.areEqual(3, [SELECT COUNT() FROM Point_Ledger__c], 'No additional ledger entries');
        Assert.areEqual(109, getMember().Points_Balance__c, 'Balance is unchanged');
    }

    @IsTest
    static void shouldProcessAllWithinLimits_WhenBulkImport() {
        // Given
        Id memberId = getMember().Id;
        List<Loyalty_Transaction__c> transactions = new List<Loyalty_Transaction__c>();
        for (Integer index = 0; index < BULK_SIZE; index++) {
            transactions.add(LoyaltyTestDataFactory.buildTransaction(memberId, 'POS-BULK-' + index, 45, 180));
        }

        // When
        Test.startTest();
        insert transactions;
        Test.stopTest();

        // Then
        Assert.areEqual(BULK_SIZE, [SELECT COUNT() FROM Loyalty_Transaction__c WHERE Processing_Status__c = :LoyaltyTransactionService.STATUS_PROCESSED], 'All purchases are processed');
        Assert.areEqual(BULK_SIZE * 3, [SELECT COUNT() FROM Point_Ledger__c], 'Three ledger entries per purchase');
        Assert.areEqual(BULK_SIZE * 109, getMember().Points_Balance__c, 'Balance equals the sum of all awards');
    }

    @IsTest
    static void shouldMarkErrorWithoutCalculation_WhenSettingsInvalid() {
        // Given
        LoyaltySettingsSelector settingsSelector = (LoyaltySettingsSelector) Test.createStub(LoyaltySettingsSelector.class, new InvalidSettingsStub());
        LoyaltyTransactionService service = new LoyaltyTransactionService(new AccountSelector(), new LoyaltyCampaignSelector(), settingsSelector);
        Loyalty_Transaction__c loyaltyTransaction = LoyaltyTestDataFactory.buildTransaction(getMember().Id, 'POS-SETTINGS', 45, 180);

        // When
        Test.startTest();
        service.processTransactions(new List<Loyalty_Transaction__c>{ loyaltyTransaction });
        Test.stopTest();

        // Then
        Assert.areEqual(LoyaltyTransactionService.STATUS_ERROR, loyaltyTransaction.Processing_Status__c, 'Invalid settings stop processing');
        Assert.areEqual(Label.Loyalty_Tx_Error_Invalid_Settings, loyaltyTransaction.Processing_Error__c, 'Reason names the settings');
        Assert.isNull(loyaltyTransaction.Base_Fuel_Points__c, 'No points are calculated');
    }

    @IsTest
    static void shouldWriteTierBonusEntry_WhenMemberIsHighwayTier() {
        // Given
        Account member = getMember();
        member.Loyalty_Tier__c = LoyaltyTierService.TIER_HIGHWAY;
        update member;
        Loyalty_Transaction__c loyaltyTransaction = LoyaltyTestDataFactory.buildTransaction(member.Id, 'POS-HIGHWAY', 45, 180);
        Integer expectedTierBonus = (45 * Loyalty_Settings__mdt.getInstance('Default').Tier_Highway_Fuel_Multiplier__c).round(System.RoundingMode.FLOOR).intValue() - 45;

        // When
        Test.startTest();
        insert loyaltyTransaction;
        Test.stopTest();

        // Then
        Point_Ledger__c tierEntry = [SELECT Points__c, Unique_Key__c FROM Point_Ledger__c WHERE Transaction__c = :loyaltyTransaction.Id AND Entry_Type__c = :LoyaltyTransactionService.ENTRY_TYPE_TIER_BONUS];
        Assert.areEqual(expectedTierBonus, tierEntry.Points__c, 'Tier bonus entry holds the extra fuel points');
        Assert.areEqual('TX:' + loyaltyTransaction.Id + ':TIER', tierEntry.Unique_Key__c, 'One tier entry per purchase');
        Assert.areEqual(109 + expectedTierBonus, getTransaction(loyaltyTransaction.Id).Total_Points__c, 'Transaction total includes the tier bonus');
        Assert.areEqual(109 + expectedTierBonus, getMember().Points_Balance__c, 'Balance includes the tier bonus');
    }

    @IsTest
    static void shouldUpgradeToHighway_WhenPurchasesReachThreshold() {
        // Given: enough 109-point purchases inside the qualification period
        Id memberId = getMember().Id;
        Integer threshold = Loyalty_Settings__mdt.getInstance('Default').Tier_Highway_Threshold__c.intValue();
        List<Loyalty_Transaction__c> transactions = new List<Loyalty_Transaction__c>();
        for (Integer index = 0; index * 109 < threshold; index++) {
            Loyalty_Transaction__c loyaltyTransaction = LoyaltyTestDataFactory.buildTransaction(memberId, 'POS-TIER-' + index, 45, 180);
            loyaltyTransaction.Purchased_At__c = Datetime.now().addDays(-1);
            transactions.add(loyaltyTransaction);
        }

        // When
        Test.startTest();
        insert transactions;
        Test.stopTest();

        // Then
        Assert.areEqual(LoyaltyTierService.TIER_HIGHWAY, [SELECT Loyalty_Tier__c FROM Account WHERE Id = :memberId].Loyalty_Tier__c, 'Member is upgraded right after reaching the threshold');
        Assert.areEqual(0, [SELECT COUNT() FROM Point_Ledger__c WHERE Entry_Type__c = :LoyaltyTransactionService.ENTRY_TYPE_TIER_BONUS], 'Purchases of the same import keep the previous tier');
    }

    private static void assertRejected(Database.SaveResult saveResult) {
        Assert.isFalse(saveResult.isSuccess(), 'Invalid row is rejected by the B1 validation rules');
        Assert.areEqual(0, [SELECT COUNT() FROM Loyalty_Transaction__c], 'Nothing is stored');
        Assert.areEqual(0, [SELECT COUNT() FROM Point_Ledger__c], 'No ledger entries');
    }

    private static void assertError(Id transactionId, String expectedError) {
        Loyalty_Transaction__c failed = getTransaction(transactionId);
        Assert.areEqual(LoyaltyTransactionService.STATUS_ERROR, failed.Processing_Status__c, 'Invalid purchase ends in Error');
        Assert.areEqual(expectedError, failed.Processing_Error__c, 'Error reason is stored');
        Assert.areEqual(0, [SELECT COUNT() FROM Point_Ledger__c WHERE Transaction__c = :transactionId], 'No ledger entries for an invalid purchase');
        Assert.areEqual(0, getMember().Points_Balance__c, 'Balance is unchanged');
    }

    private static Account getMember() {
        return [SELECT Id, Membership_Status__c, Points_Balance__c FROM Account WHERE Member_Number__c != NULL LIMIT 1];
    }

    private static Loyalty_Transaction__c getTransaction(Id transactionId) {
        return [SELECT Processing_Status__c, Processing_Error__c, Total_Points__c FROM Loyalty_Transaction__c WHERE Id = :transactionId];
    }

    private static List<Decimal> getLedgerPoints(Id transactionId) {
        List<Decimal> points = new List<Decimal>();
        for (Point_Ledger__c entry : [SELECT Points__c FROM Point_Ledger__c WHERE Transaction__c = :transactionId ORDER BY Points__c]) {
            points.add(entry.Points__c);
        }
        return points;
    }

    private class InvalidSettingsStub implements System.StubProvider {
        public Object handleMethodCall(Object stubbedObject, String methodName, Type returnType, List<Type> paramTypes, List<String> paramNames, List<Object> args) {
            return new Loyalty_Settings__mdt(Fuel_Points_Per_Liter__c = 0, Other_CZK_Per_Point__c = 20);
        }
    }
}
