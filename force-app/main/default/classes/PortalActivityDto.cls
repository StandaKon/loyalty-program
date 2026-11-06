/**
 * Member-facing data shapes of the portal activities (B7): vehicle profile and marketing consent.
 */
public with sharing class PortalActivityDto {
    public class Activities {
        @AuraEnabled
        public VehicleProfile vehicle;
        @AuraEnabled
        public List<PicklistOptions.Option> fuelTypeOptions;
        @AuraEnabled
        public Boolean isProfileComplete;
        @AuraEnabled
        public Boolean hasProfileBonus;
        @AuraEnabled
        public Integer profileBonusPoints;
        @AuraEnabled
        public Boolean hasMarketingConsent;
        @AuraEnabled
        public Boolean hasMarketingBonus;
        @AuraEnabled
        public Integer marketingBonusPoints;
        @AuraEnabled
        public Integer awardedPoints;
    }

    public class VehicleProfile {
        @AuraEnabled
        public String make { get; set; }
        @AuraEnabled
        public String model { get; set; }
        @AuraEnabled
        public String fuelType { get; set; }
        @AuraEnabled
        public Integer year { get; set; }
        @AuraEnabled
        public String registration { get; set; }
    }
}
