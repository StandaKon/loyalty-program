@IsTest
private class LoyaltyTierServiceTest {
    private static final Integer POINTS_PER_PURCHASE = 54;
    @TestSetup
    static void setup() {
        Account highwayWithoutPurchases = TestDataFactory.member('tier-down');
        highwayWithoutPurchases.Loyalty_Tier__c = LoyaltyTierService.TIER_HIGHWAY;
        Account roadWithPurchases = TestDataFactory.member('tier-up');
        insert new List<Account>{ highwayWithoutPurchases, roadWithPurchases };

        Integer threshold = new LoyaltyTierService().getThreshold();
        List<Loyalty_Transaction__c> purchases = new List<Loyalty_Transaction__c>();
        // 45 l + 180 CZK without campaigns = 45 + 9 points per purchase.
        for (Integer index = 0; index * POINTS_PER_PURCHASE < threshold; index++) {
            purchases.add(LoyaltyTestDataFactory.buildTransaction(roadWithPurchases.Id, 'POS-TIER-EVAL-' + index, 45, 180));
            purchases[index].Purchased_At__c = Datetime.now().addDays(-10);
        }
        insert purchases;
        // The import may already have queued an upgrade; reset so the monthly batch is what is tested.
        update new Account(Id = roadWithPurchases.Id, Loyalty_Tier__c = LoyaltyTierService.TIER_ROAD);
    }

    @IsTest
    static void shouldUpgradeAndDowngradeByRollingPoints_WhenMonthlyBatchRuns() {
        // When
        Test.startTest();
        Database.executeBatch(new LoyaltyTierEvaluationBatch());
        Test.stopTest();

        // Then
        Assert.areEqual(LoyaltyTierService.TIER_ROAD, getTier('B1 tier-down'), 'Highway member below the threshold is downgraded');
        Assert.areEqual(LoyaltyTierService.TIER_HIGHWAY, getTier('B1 tier-up'), 'Member reaching the threshold is upgraded');
    }

    @IsTest
    static void shouldKeepTier_WhenUpgradeOnlyAndMemberBelowThreshold() {
        // Given
        Id memberId = [SELECT Id FROM Account WHERE LastName = 'B1 tier-down'].Id;

        // When
        Test.startTest();
        new LoyaltyTierService().upgradeQualified(new Set<Id>{ memberId });
        Test.stopTest();

        // Then
        Assert.areEqual(LoyaltyTierService.TIER_HIGHWAY, getTier('B1 tier-down'), 'Immediate upgrade never downgrades');
    }

    @IsTest
    static void shouldReturnFirstDayOfNextMonth_WhenAskedForNextEvaluation() {
        Assert.areEqual(Date.newInstance(2026, 12, 1), LoyaltyTierService.getNextEvaluationDate(Date.newInstance(2026, 11, 6)), 'Evaluation runs on the 1st');
    }

    private static String getTier(String lastName) {
        return [SELECT Loyalty_Tier__c FROM Account WHERE LastName = :lastName].Loyalty_Tier__c;
    }
}
