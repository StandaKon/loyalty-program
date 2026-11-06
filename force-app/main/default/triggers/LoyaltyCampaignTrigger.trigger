trigger LoyaltyCampaignTrigger on Loyalty_Campaign__c(before update) {
    new LoyaltyCampaignTriggerHandler().run(Trigger.operationType, Trigger.new, Trigger.oldMap);
}
