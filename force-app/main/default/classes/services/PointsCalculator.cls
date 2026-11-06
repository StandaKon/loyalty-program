/**
 * Calculates base, campaign and tier points for one purchase. Pure logic without SOQL or DML.
 * All partial results are rounded down (NFR-03); arithmetic is Decimal only.
 */
public inherited sharing class PointsCalculator {
    public static final String CONDITION_LITERS = 'Liters';
    public static final String CONDITION_OTHER_AMOUNT = 'OtherAmount';
    public static final String CONDITION_FUEL_AMOUNT = 'FuelAmount';
    public static final String CONDITION_TOTAL_AMOUNT = 'TotalAmount';
    public static final String REWARD_FIXED_BONUS = 'FixedBonus';
    public static final String REWARD_BASE_MULTIPLIER = 'BaseMultiplier';

    private static final String PROGRAM_TIME_ZONE = 'Europe/Prague';

    private final Loyalty_Settings__mdt settings;

    public PointsCalculator(Loyalty_Settings__mdt settings) {
        this.settings = settings;
    }

    public PointsResult calculate(Loyalty_Transaction__c loyaltyTransaction, List<Loyalty_Campaign__c> campaigns) {
        return calculate(loyaltyTransaction, campaigns, false);
    }

    // Highway tier (B11): extra fuel points only; campaigns keep using base points without the tier bonus (Q9).
    public PointsResult calculate(Loyalty_Transaction__c loyaltyTransaction, List<Loyalty_Campaign__c> campaigns, Boolean isHighwayTier) {
        PointsResult result = new PointsResult();
        result.fuelPoints = floor(loyaltyTransaction.Liters__c) * floor(settings.Fuel_Points_Per_Liter__c);
        result.otherPoints = floor(loyaltyTransaction.Other_Amount__c / settings.Other_CZK_Per_Point__c);

        Date purchaseDate = toProgramDate(loyaltyTransaction.Purchased_At__c);
        for (Loyalty_Campaign__c campaign : campaigns) {
            if (isApplicable(campaign, loyaltyTransaction, purchaseDate)) {
                result.campaignBonuses.add(new CampaignBonus(campaign, calculateBonus(campaign, result.getBasePoints())));
            }
        }
        Decimal tierMultiplier = settings.Tier_Highway_Fuel_Multiplier__c ?? 1;
        if (isHighwayTier && tierMultiplier > 1) {
            result.tierBonusPoints = floor(result.fuelPoints * tierMultiplier) - result.fuelPoints;
        }
        return result;
    }

    public static Date toProgramDate(Datetime moment) {
        return Date.valueOf(moment.format('yyyy-MM-dd', PROGRAM_TIME_ZONE));
    }

    private Boolean isApplicable(Loyalty_Campaign__c campaign, Loyalty_Transaction__c loyaltyTransaction, Date purchaseDate) {
        Decimal conditionValue = getConditionValue(campaign.Condition_Field__c, loyaltyTransaction);
        return campaign.Is_Enabled__c &&
            campaign.Start_Date__c <= purchaseDate &&
            campaign.End_Date__c >= purchaseDate &&
            conditionValue != null &&
            conditionValue >= campaign.Threshold__c;
    }

    private Decimal getConditionValue(String conditionField, Loyalty_Transaction__c loyaltyTransaction) {
        switch on conditionField {
            when 'Liters' {
                return loyaltyTransaction.Liters__c;
            }
            when 'OtherAmount' {
                return loyaltyTransaction.Other_Amount__c;
            }
            when 'FuelAmount' {
                return loyaltyTransaction.Fuel_Amount__c;
            }
            when 'TotalAmount' {
                return loyaltyTransaction.Total_Amount__c;
            }
            when else {
                return null;
            }
        }
    }

    // Each multiplier is applied to base points only, never to bonuses of other campaigns (FR-11, Q10).
    private Integer calculateBonus(Loyalty_Campaign__c campaign, Integer basePoints) {
        if (campaign.Reward_Type__c == REWARD_BASE_MULTIPLIER) {
            return floor(basePoints * campaign.Reward_Value__c) - basePoints;
        }
        if (campaign.Reward_Type__c == REWARD_FIXED_BONUS) {
            return floor(campaign.Reward_Value__c);
        }
        return 0;
    }

    private static Integer floor(Decimal value) {
        return (value ?? 0).round(System.RoundingMode.FLOOR).intValue();
    }

    public class PointsResult {
        public Integer fuelPoints = 0;
        public Integer otherPoints = 0;
        public List<CampaignBonus> campaignBonuses = new List<CampaignBonus>();
        public Integer tierBonusPoints = 0;

        public Integer getBasePoints() {
            return fuelPoints + otherPoints;
        }

        public Integer getCampaignPoints() {
            Integer campaignPoints = 0;
            for (CampaignBonus campaignBonus : campaignBonuses) {
                campaignPoints += campaignBonus.points;
            }
            return campaignPoints;
        }

        public Integer getTotalPoints() {
            return getBasePoints() + getCampaignPoints() + tierBonusPoints;
        }
    }

    public class CampaignBonus {
        public Loyalty_Campaign__c campaign;
        public Integer points;

        public CampaignBonus(Loyalty_Campaign__c campaign, Integer points) {
            this.campaign = campaign;
            this.points = points;
        }
    }
}
