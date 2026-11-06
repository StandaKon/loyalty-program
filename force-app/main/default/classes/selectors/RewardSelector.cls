public inherited sharing class RewardSelector {
    public List<Reward__c> getAvailable(Date availabilityDate) {
        return [
            SELECT Id, Name, Description__c, Partner__c, Partner__r.Name, Points_Cost__c, Value_CZK__c,
                Sort_Order__c, Available_From__c, Available_Until__c
            FROM Reward__c
            WHERE Is_Active__c = TRUE
                AND (Available_From__c = NULL OR Available_From__c <= :availabilityDate)
                AND (Available_Until__c = NULL OR Available_Until__c >= :availabilityDate)
            WITH SYSTEM_MODE
            ORDER BY Sort_Order__c ASC NULLS LAST, Points_Cost__c ASC, Name ASC
        ];
    }

    public Reward__c getById(Id rewardId) {
        List<Reward__c> rewards = [
            SELECT Id, Name, Description__c, Partner__c, Partner__r.Name, Points_Cost__c, Value_CZK__c,
                Is_Active__c, Available_From__c, Available_Until__c
            FROM Reward__c
            WHERE Id = :rewardId
            WITH SYSTEM_MODE
            LIMIT 1
        ];
        return rewards.isEmpty() ? null : rewards[0];
    }
}
