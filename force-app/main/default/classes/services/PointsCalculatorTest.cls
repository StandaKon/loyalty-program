@IsTest
private class PointsCalculatorTest {
    private static final Decimal FUEL_POINTS_PER_LITER = 1;
    private static final Decimal OTHER_CZK_PER_POINT = 20;

    @IsTest
    static void shouldAward109Points_WhenAcceptanceExample() {
        // Given
        Loyalty_Transaction__c loyaltyTransaction = buildTransaction(45, 180);

        // When
        Test.startTest();
        PointsCalculator.PointsResult result = buildCalculator().calculate(loyaltyTransaction, LoyaltyTestDataFactory.buildReferenceCampaigns());
        Test.stopTest();

        // Then
        Assert.areEqual(45, result.fuelPoints, 'Fuel points = floor(45 l)');
        Assert.areEqual(9, result.otherPoints, 'Other points = floor(180 / 20)');
        Assert.areEqual(2, result.campaignBonuses.size(), 'Both reference campaigns apply');
        Assert.areEqual(50, result.campaignBonuses[0].points, 'Natankuj plnou adds the fixed bonus');
        Assert.areEqual(5, result.campaignBonuses[1].points, 'Zastávka na cestě adds floor(54 * 1.1) - 54');
        Assert.areEqual(109, result.getTotalPoints(), 'Acceptance example must give 109 points');
    }

    @IsTest
    static void shouldMatchReferenceCalculations_WhenSolutionDesignScenarios() {
        // Given: id => {liters, other CZK, expected base, expected campaign points}
        Map<String, List<Decimal>> scenarios = new Map<String, List<Decimal>>{
            'T02' => new List<Decimal>{ 30.5, 0, 30, 0 },
            'T03' => new List<Decimal>{ 0, 149, 7, 0 },
            'T04' => new List<Decimal>{ 0, 150, 7, 0 },
            'T05' => new List<Decimal>{ 40.00, 0, 40, 50 },
            'T06' => new List<Decimal>{ 39.99, 0, 39, 0 },
            'T07' => new List<Decimal>{ 60, 300, 75, 57 },
            'T10' => new List<Decimal>{ 52.8, 155, 59, 55 }
        };
        PointsCalculator calculator = buildCalculator();
        List<Loyalty_Campaign__c> campaigns = LoyaltyTestDataFactory.buildReferenceCampaigns();

        // When / Then
        Test.startTest();
        for (String scenarioId : scenarios.keySet()) {
            List<Decimal> scenario = scenarios.get(scenarioId);
            PointsCalculator.PointsResult result = calculator.calculate(buildTransaction(scenario[0], scenario[1]), campaigns);
            Assert.areEqual(scenario[2].intValue(), result.getBasePoints(), scenarioId + ': base points');
            Assert.areEqual(scenario[3].intValue(), result.getCampaignPoints(), scenarioId + ': campaign points');
        }
        Test.stopTest();
    }

    @IsTest
    static void shouldReportMatchedCampaignWithZeroBonus_WhenMultiplierRoundsToZero() {
        // Given (T04)
        Loyalty_Transaction__c loyaltyTransaction = buildTransaction(0, 150);

        // When
        Test.startTest();
        PointsCalculator.PointsResult result = buildCalculator().calculate(loyaltyTransaction, LoyaltyTestDataFactory.buildReferenceCampaigns());
        Test.stopTest();

        // Then
        Assert.areEqual(1, result.campaignBonuses.size(), 'Matched multiplier campaign is kept for reporting');
        Assert.areEqual(0, result.campaignBonuses[0].points, 'floor(7 * 1.1) - 7 = 0');
    }

    @IsTest
    static void shouldApplyEachMultiplierToBaseOnly_WhenMultipleMultipliersMatch() {
        // Given: base 100 points, multipliers 1.1 and 1.2, fixed bonus 50
        Loyalty_Transaction__c loyaltyTransaction = buildTransaction(100, 0);
        List<Loyalty_Campaign__c> campaigns = new List<Loyalty_Campaign__c>{
            LoyaltyTestDataFactory.buildCampaign('A', PointsCalculator.CONDITION_LITERS, 1, PointsCalculator.REWARD_BASE_MULTIPLIER, 1.1),
            LoyaltyTestDataFactory.buildCampaign('B', PointsCalculator.CONDITION_LITERS, 1, PointsCalculator.REWARD_BASE_MULTIPLIER, 1.2),
            LoyaltyTestDataFactory.buildCampaign('C', PointsCalculator.CONDITION_LITERS, 1, PointsCalculator.REWARD_FIXED_BONUS, 50)
        };

        // When
        Test.startTest();
        PointsCalculator.PointsResult result = buildCalculator().calculate(loyaltyTransaction, campaigns);
        Test.stopTest();

        // Then
        Assert.areEqual(10 + 20 + 50, result.getCampaignPoints(), 'Multipliers are not compounded and ignore other bonuses');
        Assert.areEqual(180, result.getTotalPoints(), 'Total = base 100 + 80 campaign points');
    }

    @IsTest
    static void shouldSkipCampaign_WhenDisabledOrOutsideValidity() {
        // Given
        Loyalty_Campaign__c disabledCampaign = LoyaltyTestDataFactory.buildCampaign('Disabled', PointsCalculator.CONDITION_LITERS, 1, PointsCalculator.REWARD_FIXED_BONUS, 50);
        disabledCampaign.Is_Enabled__c = false;
        Loyalty_Campaign__c expiredCampaign = LoyaltyTestDataFactory.buildCampaign('Expired', PointsCalculator.CONDITION_LITERS, 1, PointsCalculator.REWARD_FIXED_BONUS, 50);
        expiredCampaign.End_Date__c = Date.newInstance(2026, 6, 14);

        // When
        Test.startTest();
        PointsCalculator.PointsResult result = buildCalculator().calculate(buildTransaction(45, 0), new List<Loyalty_Campaign__c>{ disabledCampaign, expiredCampaign });
        Test.stopTest();

        // Then
        Assert.isTrue(result.campaignBonuses.isEmpty(), 'Disabled and expired campaigns must not apply');
    }

    @IsTest
    static void shouldUsePragueCalendarDay_WhenPurchaseNearMidnightUtc() {
        // Given: 31 Dec 23:30 UTC is already 1 Jan in Prague; campaign ends 31 Dec
        Loyalty_Transaction__c loyaltyTransaction = buildTransaction(45, 0);
        loyaltyTransaction.Purchased_At__c = Datetime.newInstanceGmt(2026, 12, 31, 23, 30, 0);
        Loyalty_Campaign__c campaign = LoyaltyTestDataFactory.buildCampaign('Year end', PointsCalculator.CONDITION_LITERS, 1, PointsCalculator.REWARD_FIXED_BONUS, 50);

        // When
        Test.startTest();
        PointsCalculator.PointsResult result = buildCalculator().calculate(loyaltyTransaction, new List<Loyalty_Campaign__c>{ campaign });
        Test.stopTest();

        // Then
        Assert.areEqual(Date.newInstance(2027, 1, 1), PointsCalculator.toProgramDate(loyaltyTransaction.Purchased_At__c), 'Purchase date is evaluated in Europe/Prague');
        Assert.isTrue(result.campaignBonuses.isEmpty(), 'Campaign ending on 31 Dec must not apply to a 1 Jan purchase');
    }

    @IsTest
    static void shouldApplyCampaign_WhenPurchaseOnBoundaryDays() {
        // Given
        Loyalty_Campaign__c campaign = LoyaltyTestDataFactory.buildCampaign('Boundary', PointsCalculator.CONDITION_TOTAL_AMOUNT, 1, PointsCalculator.REWARD_FIXED_BONUS, 50);
        Loyalty_Transaction__c firstDayPurchase = buildTransaction(10, 0);
        firstDayPurchase.Purchased_At__c = Datetime.newInstanceGmt(2025, 12, 31, 23, 30, 0);
        Loyalty_Transaction__c lastDayPurchase = buildTransaction(10, 0);
        lastDayPurchase.Purchased_At__c = Datetime.newInstanceGmt(2026, 12, 31, 12, 0, 0);
        PointsCalculator calculator = buildCalculator();

        // When
        Test.startTest();
        Integer firstDayBonus = calculator.calculate(firstDayPurchase, new List<Loyalty_Campaign__c>{ campaign }).getCampaignPoints();
        Integer lastDayBonus = calculator.calculate(lastDayPurchase, new List<Loyalty_Campaign__c>{ campaign }).getCampaignPoints();
        Test.stopTest();

        // Then
        Assert.areEqual(50, firstDayBonus, 'Start date is inclusive (1 Jan in Prague)');
        Assert.areEqual(50, lastDayBonus, 'End date is inclusive');
    }

    private static PointsCalculator buildCalculator() {
        return new PointsCalculator(new Loyalty_Settings__mdt(Fuel_Points_Per_Liter__c = FUEL_POINTS_PER_LITER, Other_CZK_Per_Point__c = OTHER_CZK_PER_POINT));
    }

    private static Loyalty_Transaction__c buildTransaction(Decimal liters, Decimal otherAmount) {
        return LoyaltyTestDataFactory.buildTransaction(null, 'POS-CALC', liters, otherAmount);
    }
}
