/**
 * Monthly tier evaluation of all members (B11, BR-60): upgrade or downgrade by the rolling qualifying points.
 * Schedule: System.schedule('Loyalty tier evaluation', '0 0 2 1 * ?', new LoyaltyTierEvaluationBatch());
 */
public inherited sharing class LoyaltyTierEvaluationBatch implements Database.Batchable<SObject>, Schedulable {
    private static final Integer BATCH_SIZE = 200;

    public void execute(SchedulableContext context) {
        Database.executeBatch(new LoyaltyTierEvaluationBatch(), BATCH_SIZE);
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return new LoyaltyMemberSelector().getMembersQueryLocator();
    }

    public void execute(Database.BatchableContext context, List<Account> members) {
        new LoyaltyTierService().evaluate(new Map<Id, Account>(members).keySet());
    }

    public void finish(Database.BatchableContext context) {
        return;
    }
}
