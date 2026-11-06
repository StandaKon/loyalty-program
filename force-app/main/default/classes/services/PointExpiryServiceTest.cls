@IsTest
private class PointExpiryServiceTest {
    @TestSetup
    static void setup() {
        Account fifoMember = TestDataFactory.member('expiry-fifo');
        Account oldMember = TestDataFactory.member('expiry-old');
        insert new List<Account>{ fifoMember, oldMember };
        // Example from the functional brief: +100 on 1 Jan, -80 on 1 Feb, +50 on 1 Mar 2026.
        insert new List<Point_Ledger__c>{
            entry(fifoMember.Id, 100, Date.newInstance(2026, 1, 1), 'EXP-TEST-1'),
            entry(fifoMember.Id, -80, Date.newInstance(2026, 2, 1), 'EXP-TEST-2'),
            entry(fifoMember.Id, 50, Date.newInstance(2026, 3, 1), 'EXP-TEST-3'),
            entry(oldMember.Id, 30, Date.newInstance(2024, 1, 1), 'EXP-TEST-4')
        };
    }

    @IsTest
    static void shouldExpireOldestPointsFirst_WhenFifoExampleIsEvaluated() {
        // Given
        Id memberId = getMemberId('B1 expiry-fifo');
        PointExpiryService service = new PointExpiryService();
        Date firstExpiry = Date.newInstance(2027, 1, 1);
        Date secondExpiry = Date.newInstance(2027, 3, 1);

        // When
        Test.startTest();
        PointExpiryService.Forecast forecast = service.getForecast(memberId, Date.newInstance(2026, 12, 10));
        Integer firstRun = service.expire(new Set<Id>{ memberId }, firstExpiry);
        Integer repeatedRun = service.expire(new Set<Id>{ memberId }, firstExpiry);
        Integer dueLater = service.getDuePoints(new Set<Id>{ memberId }, secondExpiry).get(memberId);
        Test.stopTest();

        // Then
        Assert.areEqual(firstExpiry, forecast.expiryDate, 'Warning names the next expiry date');
        Assert.areEqual(20, forecast.points, '100 - 80 points of 1 Jan remain to expire');
        Assert.areEqual(1, firstRun, 'One member expired');
        Assert.areEqual(0, repeatedRun, 'Same-day rerun writes nothing');
        Assert.areEqual(-20, [SELECT Points__c FROM Point_Ledger__c WHERE Member__c = :memberId AND Entry_Type__c = :PointExpiryService.ENTRY_TYPE_EXPIRATION].Points__c, 'Expiration entry removes 20 points');
        Assert.areEqual(50, dueLater, 'Points of 1 Mar expire on 1 Mar 2027');
        Assert.areEqual(50, [SELECT Points_Balance__c FROM Account WHERE Id = :memberId].Points_Balance__c, 'Balance after expiry');
    }

    @IsTest
    static void shouldExpireAllMembers_WhenDailyBatchRuns() {
        // When
        Test.startTest();
        Database.executeBatch(new PointExpiryBatch());
        Test.stopTest();

        // Then
        Assert.areEqual(0, [SELECT Points_Balance__c FROM Account WHERE LastName = 'B1 expiry-old'].Points_Balance__c, 'Points older than the validity are expired');
        Assert.areEqual(1, [SELECT COUNT() FROM Point_Ledger__c WHERE Entry_Type__c = :PointExpiryService.ENTRY_TYPE_EXPIRATION], 'Only the old member had due points');
    }

    private static Point_Ledger__c entry(Id memberId, Integer points, Date occurredOn, String key) {
        Point_Ledger__c ledgerEntry = TestDataFactory.adjustment(memberId, points, key);
        ledgerEntry.Occurred_At__c = Datetime.newInstance(occurredOn, Time.newInstance(12, 0, 0, 0));
        return ledgerEntry;
    }

    private static Id getMemberId(String lastName) {
        return [SELECT Id FROM Account WHERE LastName = :lastName].Id;
    }
}
