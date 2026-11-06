@IsTest
private class PortalActivityControllerTest {
    private static final String FIRST_NAME = 'Vera';
    private static final Integer PROFILE_BONUS_POINTS = Loyalty_Settings__mdt.getInstance('Default').Profile_Bonus_Points__c.intValue();
    private static final Integer MARKETING_BONUS_POINTS = Loyalty_Settings__mdt.getInstance('Default').Marketing_Bonus_Points__c.intValue();

    @TestSetup
    static void setup() {
        User owner = PortalTestDataFactory.createAccountOwner();
        System.runAs(owner) {
            Account member = PortalTestDataFactory.buildMember(FIRST_NAME);
            insert member;
            PortalTestDataFactory.createPortalUser(member);
        }
        // Setup objects (User) and consent records cannot share a transaction context (mixed DML).
        System.runAs(owner) {
            PortalTestDataFactory.createEffectiveConsentForms();
        }
    }

    private static User getPortalUser() {
        return [SELECT Id, AccountId FROM User WHERE Contact.FirstName = :FIRST_NAME AND IsActive = TRUE LIMIT 1];
    }

    private static PortalActivityDto.VehicleProfile buildVehicle(String make, String model, String fuelType, Integer year) {
        PortalActivityDto.VehicleProfile vehicle = new PortalActivityDto.VehicleProfile();
        vehicle.make = make;
        vehicle.model = model;
        vehicle.fuelType = fuelType;
        vehicle.year = year;
        return vehicle;
    }

    private static List<Point_Ledger__c> getBonuses(Id memberId, String entryType) {
        return [SELECT Points__c, Unique_Key__c FROM Point_Ledger__c WHERE Member__c = :memberId AND Entry_Type__c = :entryType];
    }

    @IsTest
    static void shouldAwardProfileBonusOnce_WhenProfileBecomesComplete() {
        // Given
        User portalUser = getPortalUser();
        PortalActivityDto.Activities partial;
        PortalActivityDto.Activities completed;
        PortalActivityDto.Activities edited;

        // When
        System.runAs(portalUser) {
            Test.startTest();
            partial = PortalActivityController.saveVehicleProfile(buildVehicle('Škoda', null, null, null));
            completed = PortalActivityController.saveVehicleProfile(buildVehicle('Škoda', 'Octavia', 'Diesel', 2019));
            edited = PortalActivityController.saveVehicleProfile(buildVehicle('Škoda', 'Superb', 'Diesel', 2020));
            Test.stopTest();
        }

        // Then
        Assert.areEqual(0, partial.awardedPoints, 'Incomplete profile must not earn the bonus');
        Assert.isFalse(partial.isProfileComplete, 'Profile with make only is incomplete');
        Assert.areEqual(PROFILE_BONUS_POINTS, completed.awardedPoints, 'First complete profile earns the bonus');
        Assert.isTrue(completed.hasProfileBonus, 'Bonus state should be returned');
        Assert.areEqual(0, edited.awardedPoints, 'Later edits must not earn the bonus again');
        List<Point_Ledger__c> bonuses = getBonuses(portalUser.AccountId, PortalBonusService.ENTRY_TYPE_PROFILE);
        Assert.areEqual(1, bonuses.size(), 'Exactly one profile bonus entry');
        Assert.areEqual('MEM:' + portalUser.AccountId + ':PROFILE', bonuses[0].Unique_Key__c, 'B1 unique key format');
        Assert.areEqual('Superb', [SELECT Vehicle_Model__c FROM Account WHERE Id = :portalUser.AccountId].Vehicle_Model__c, 'Latest profile is stored');
    }

    @IsTest
    static void shouldRejectProfileWithoutSaving_WhenYearIsInvalid() {
        // Given
        User portalUser = getPortalUser();
        String errorMessage;
        String expectedMessage;

        // When
        System.runAs(portalUser) {
            expectedMessage = System.Label.Portal_Profile_Error_Invalid;
            Test.startTest();
            try {
                PortalActivityController.saveVehicleProfile(buildVehicle('Škoda', 'Octavia', 'Diesel', 1800));
                Assert.fail('Expected AuraHandledException');
            } catch (AuraHandledException ex) {
                errorMessage = ex.getMessage();
            }
            Test.stopTest();
        }

        // Then
        Assert.areEqual(expectedMessage, errorMessage, 'Member sees the translated validation message');
        Assert.isNull([SELECT Vehicle_Make__c FROM Account WHERE Id = :portalUser.AccountId].Vehicle_Make__c, 'Nothing is saved');
        Assert.isTrue(getBonuses(portalUser.AccountId, PortalBonusService.ENTRY_TYPE_PROFILE).isEmpty(), 'No bonus is written');
    }

    @IsTest
    static void shouldAwardMarketingBonusOnce_WhenConsentIsGrantedWithdrawnAndRegranted() {
        // Given
        User portalUser = getPortalUser();
        PortalActivityDto.Activities granted;
        PortalActivityDto.Activities repeated;
        PortalActivityDto.Activities withdrawn;
        PortalActivityDto.Activities regranted;

        // When
        System.runAs(portalUser) {
            Test.startTest();
            granted = PortalActivityController.setMarketingConsent(true);
            repeated = PortalActivityController.setMarketingConsent(true);
            withdrawn = PortalActivityController.setMarketingConsent(false);
            regranted = PortalActivityController.setMarketingConsent(true);
            Test.stopTest();
        }

        // Then
        Assert.areEqual(MARKETING_BONUS_POINTS, granted.awardedPoints, 'First consent earns the bonus');
        Assert.areEqual(0, repeated.awardedPoints, 'Repeated submission earns nothing');
        Assert.isFalse(withdrawn.hasMarketingConsent, 'Consent is withdrawn');
        Assert.isTrue(withdrawn.hasMarketingBonus, 'Withdrawal keeps the awarded bonus');
        Assert.areEqual(0, regranted.awardedPoints, 'Re-grant earns nothing');
        Assert.areEqual(1, getBonuses(portalUser.AccountId, PortalBonusService.ENTRY_TYPE_MARKETING).size(), 'Exactly one marketing bonus entry');
        Assert.areEqual(
            new List<String>{ 'Accepted', 'Withdrawn', 'Accepted' },
            getConsentActions(portalUser.AccountId),
            'Each state change is one consent event; the repeated submission adds none'
        );
        Account member = [SELECT Marketing_Consent__c, Points_Balance__c FROM Account WHERE Id = :portalUser.AccountId];
        Assert.isTrue(member.Marketing_Consent__c, 'Current consent state is stored on the member');
        Assert.areEqual(MARKETING_BONUS_POINTS, member.Points_Balance__c, 'Balance contains the bonus once');
    }

    @IsTest
    static void shouldReturnNotMemberCode_WhenUserIsNotMember() {
        // Given
        User internalUser = PortalTestDataFactory.createAccountOwner();
        String errorMessage;

        // When
        System.runAs(internalUser) {
            Test.startTest();
            try {
                PortalActivityController.getActivities();
                Assert.fail('Expected AuraHandledException');
            } catch (AuraHandledException ex) {
                errorMessage = ex.getMessage();
            }
            Test.stopTest();
        }

        // Then
        Assert.areEqual(PortalMemberController.ERROR_CODE_NOT_MEMBER, errorMessage, 'Not-member code expected');
    }

    private static List<String> getConsentActions(Id memberId) {
        List<String> actions = new List<String>();
        for (AuthorizationFormConsent consent : [
            SELECT Consent_Action__c
            FROM AuthorizationFormConsent
            WHERE ConsentGiverId = :memberId
            ORDER BY ConsentCapturedDateTime, CreatedDate, Id
        ]) {
            actions.add(consent.Consent_Action__c);
        }
        return actions;
    }
}
