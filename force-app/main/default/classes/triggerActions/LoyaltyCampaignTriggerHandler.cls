/**
 * Routes Loyalty_Campaign__c trigger events to LoyaltyCampaignService.
 * Plain handler instead of trigger-actions-framework, which is not installed in the target org (same as B2).
 *
 * Runs without sharing on purpose: the lock must detect usage by any member's ledger entries, which the editing
 * manager may not be able to see through sharing.
 */
public without sharing class LoyaltyCampaignTriggerHandler {
    @TestVisible
    private LoyaltyCampaignService service;

    public LoyaltyCampaignTriggerHandler() {
        this(new LoyaltyCampaignService());
    }

    @TestVisible
    private LoyaltyCampaignTriggerHandler(LoyaltyCampaignService service) {
        this.service = service;
    }

    public void run(TriggerOperation operation, List<Loyalty_Campaign__c> newCampaigns, Map<Id, Loyalty_Campaign__c> oldCampaignsById) {
        if (operation == TriggerOperation.BEFORE_UPDATE) {
            service.rejectRuleChangesOfUsedCampaigns(newCampaigns, oldCampaignsById);
        }
    }
}
