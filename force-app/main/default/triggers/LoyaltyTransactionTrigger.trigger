trigger LoyaltyTransactionTrigger on Loyalty_Transaction__c(before insert, before update, after insert, after update) {
    new LoyaltyTransactionTriggerHandler().run(Trigger.operationType, Trigger.new, Trigger.oldMap);
}
