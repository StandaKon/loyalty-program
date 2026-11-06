/**
 * Protects the calculation rule of a campaign that has already awarded points (B1 §4.4, B5).
 * A new rule means a new campaign record; name, member description and the enable flag stay editable.
 */
public inherited sharing class LoyaltyCampaignService {
    private static final List<Schema.SObjectField> LOCKED_FIELDS = new List<Schema.SObjectField>{
        Loyalty_Campaign__c.Condition_Field__c,
        Loyalty_Campaign__c.Threshold__c,
        Loyalty_Campaign__c.Reward_Type__c,
        Loyalty_Campaign__c.Reward_Value__c,
        Loyalty_Campaign__c.Start_Date__c,
        Loyalty_Campaign__c.End_Date__c
    };

    private final PointLedgerSelector ledgerSelector;

    public LoyaltyCampaignService() {
        this(new PointLedgerSelector());
    }

    @TestVisible
    private LoyaltyCampaignService(PointLedgerSelector ledgerSelector) {
        this.ledgerSelector = ledgerSelector;
    }

    public void rejectRuleChangesOfUsedCampaigns(List<Loyalty_Campaign__c> campaigns, Map<Id, Loyalty_Campaign__c> oldCampaignsById) {
        Map<Id, Loyalty_Campaign__c> changedRulesById = new Map<Id, Loyalty_Campaign__c>();
        for (Loyalty_Campaign__c campaign : campaigns) {
            if (hasRuleChange(campaign, oldCampaignsById.get(campaign.Id))) {
                changedRulesById.put(campaign.Id, campaign);
            }
        }
        if (changedRulesById.isEmpty()) {
            return;
        }
        for (Id usedCampaignId : ledgerSelector.getCampaignIdsWithEntries(changedRulesById.keySet())) {
            Loyalty_Campaign__c campaign = changedRulesById.get(usedCampaignId);
            campaign.addError(String.format(Label.Loyalty_BO_Error_Campaign_Locked, new List<Object>{ campaign.Name }));
        }
    }

    private Boolean hasRuleChange(Loyalty_Campaign__c campaign, Loyalty_Campaign__c oldCampaign) {
        for (Schema.SObjectField field : LOCKED_FIELDS) {
            if (campaign.get(field) != oldCampaign.get(field)) {
                return true;
            }
        }
        return false;
    }
}
