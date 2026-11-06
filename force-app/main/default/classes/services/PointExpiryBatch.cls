/**
 * Daily points expiry of all members (B11, BR-61).
 * Schedule: System.schedule('Loyalty points expiry', '0 30 1 * * ?', new PointExpiryBatch());
 */
public inherited sharing class PointExpiryBatch implements Database.Batchable<SObject>, Schedulable {
    private static final Integer BATCH_SIZE = 200;

    public void execute(SchedulableContext context) {
        Database.executeBatch(new PointExpiryBatch(), BATCH_SIZE);
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return new LoyaltyMemberSelector().getMembersQueryLocator();
    }

    public void execute(Database.BatchableContext context, List<Account> members) {
        new PointExpiryService().expire(new Map<Id, Account>(members).keySet(), PointsCalculator.toProgramDate(System.now()));
    }

    public void finish(Database.BatchableContext context) {
        return;
    }
}
