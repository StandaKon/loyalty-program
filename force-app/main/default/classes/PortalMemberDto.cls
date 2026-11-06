/**
 * Member-facing data shapes returned to portal LWCs. Contains only fields a member may see.
 */
public with sharing class PortalMemberDto {
    public class Overview {
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String memberNumber;
        @AuraEnabled
        public Integer balance;
        @AuraEnabled
        public NextReward nextReward;
        @AuraEnabled
        public Boolean hasReachedAllRewards;
        @AuraEnabled
        public List<Movement> recentMovements;
        @AuraEnabled
        public List<Campaign> activeCampaigns;
    }

    public class NextReward {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Integer pointsCost;
        @AuraEnabled
        public Integer pointsMissing;
        @AuraEnabled
        public Integer progressPercent;
    }

    public class Movement {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public Date movementDate;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public Integer points;
    }

    public class Campaign {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String memberText;
        @AuraEnabled
        public Date validTo;
    }

    public class LoyaltyStatus {
        @AuraEnabled
        public Boolean isHighway;
        @AuraEnabled
        public Integer qualifyingPoints;
        @AuraEnabled
        public Integer threshold;
        @AuraEnabled
        public Integer qualificationMonths;
        @AuraEnabled
        public Integer pointsToHighway;
        @AuraEnabled
        public Integer progressPercent;
        @AuraEnabled
        public Integer fuelBonusPercent;
        @AuraEnabled
        public Date nextEvaluationDate;
        @AuraEnabled
        public Integer expiringPoints;
        @AuraEnabled
        public Date expiryDate;
    }

    public class RewardCatalog {
        @AuraEnabled
        public Integer balance;
        @AuraEnabled
        public List<Reward> rewards;
    }

    public class Reward {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public Integer pointsCost;
        @AuraEnabled
        public Decimal valueCzk;
        @AuraEnabled
        public Boolean isAffordable;
        @AuraEnabled
        public Integer pointsMissing;
        @AuraEnabled
        public Integer progressPercent;
    }

    public class HistoryPage {
        @AuraEnabled
        public List<Movement> movements;
        @AuraEnabled
        public Integer totalCount;
        @AuraEnabled
        public Boolean hasMore;
    }
}
