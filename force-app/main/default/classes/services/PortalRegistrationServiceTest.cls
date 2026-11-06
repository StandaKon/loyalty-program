@IsTest
private class PortalRegistrationServiceTest {
    private static final String EMAIL = 'jana.novakova@example.cz';
    private static final String LOGIN_URL = 'https://eneoil.example/secur/frontdoor.jsp';

    private static Id portalUserId;

    private class FakeSiteGateway extends PortalSiteGateway {
        private final Boolean isUserCreationFailing;

        FakeSiteGateway(Boolean isUserCreationFailing) {
            this.isUserCreationFailing = isUserCreationFailing;
        }

        public override void validatePassword(User user, String password) {
            return;
        }

        public override Id createExternalUser(User user, Id accountId, String password) {
            if (isUserCreationFailing) {
                throw new SecurityException('nickname taken');
            }
            return portalUserId;
        }

        public override String login(String username, String password) {
            return LOGIN_URL;
        }
    }

    @TestSetup
    static void setup() {
        User owner = PortalTestDataFactory.createAccountOwner();
        // Setup objects (UserRole, User) and consent records cannot share a transaction context (mixed DML).
        System.runAs(owner) {
            PortalTestDataFactory.createEffectiveConsentForms();
        }
    }

    // A real user without the portal permission sets stands in for the Site-created user, so the async assignment can run.
    private static void givenCreatedUser() {
        portalUserId = [SELECT Id FROM User WHERE Username LIKE 'owner%@eneoil-test.cz.portal' LIMIT 1].Id;
    }

    private static PortalRegistrationService buildService(Boolean isUserCreationFailing) {
        return new PortalRegistrationService(new PortalUserSelector(), new PortalConsentFormSelector(), new FakeSiteGateway(isUserCreationFailing));
    }

    private static PortalRegistrationRequest buildRequest() {
        PortalRegistrationRequest request = new PortalRegistrationRequest();
        request.firstName = 'Jana';
        request.lastName = 'Nováková';
        request.email = EMAIL;
        request.password = 'Tankuj2026';
        request.termsAccepted = true;
        request.marketingConsent = true;
        return request;
    }

    @IsTest
    static void shouldCreateMemberWithConsentsAndLogIn_WhenInputIsValid() {
        givenCreatedUser();
        Test.startTest();
        String result = buildService(false).register(buildRequest());
        Test.stopTest();

        Account member = [
            SELECT Id, Member_Number__c, Membership_Status__c, Joined_At__c, Marketing_Consent__c
            FROM Account
            WHERE PersonEmail = :EMAIL
        ];
        Assert.areEqual(LOGIN_URL, result, 'Login URL should be returned');
        Assert.areEqual('ENE-' + member.Id, member.Member_Number__c, 'Member number should be derived from Account Id');
        Assert.areEqual('Active', member.Membership_Status__c, 'New member should be active');
        Assert.isNotNull(member.Joined_At__c, 'Join time should be stored');
        Assert.isTrue(member.Marketing_Consent__c, 'Marketing consent flag should be set');
        Assert.areEqual(
            PortalTestDataFactory.PORTAL_PERMISSION_SETS.size(),
            [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId = :portalUserId AND PermissionSet.Name IN :PortalTestDataFactory.PORTAL_PERMISSION_SETS],
            'Portal permission sets should be assigned'
        );
        Assert.areEqual(
            2,
            [SELECT COUNT() FROM AuthorizationFormConsent WHERE ConsentGiverId = :member.Id AND Consent_Action__c = 'Accepted'],
            'Terms and marketing consent events should be recorded'
        );
        List<Point_Ledger__c> marketingBonuses = [
            SELECT Points__c, Unique_Key__c
            FROM Point_Ledger__c
            WHERE Member__c = :member.Id AND Entry_Type__c = :PortalBonusService.ENTRY_TYPE_MARKETING
        ];
        Assert.areEqual(1, marketingBonuses.size(), 'Marketing consent at registration earns one bonus');
        Assert.areEqual(Loyalty_Settings__mdt.getInstance('Default').Marketing_Bonus_Points__c, marketingBonuses[0].Points__c, 'Bonus points come from Loyalty_Settings__mdt');
        Assert.areEqual('MEM:' + member.Id + ':MARKETING', marketingBonuses[0].Unique_Key__c, 'B1 unique key format');
    }

    @IsTest
    static void shouldRejectRegistration_WhenTermsAreNotAccepted() {
        PortalRegistrationRequest request = buildRequest();
        request.termsAccepted = false;

        Test.startTest();
        try {
            buildService(false).register(request);
            Assert.fail('Expected PortalRegistrationException');
        } catch (PortalRegistrationService.PortalRegistrationException ex) {
            Assert.areEqual(System.Label.Portal_Register_Error_TermsRequired, ex.getMessage(), 'Terms message expected');
        }
        Test.stopTest();
    }

    @IsTest
    static void shouldRollBackMember_WhenUserCreationFails() {
        Test.startTest();
        try {
            buildService(true).register(buildRequest());
            Assert.fail('Expected PortalRegistrationException');
        } catch (PortalRegistrationService.PortalRegistrationException ex) {
            Assert.areEqual(System.Label.Portal_Register_Error_Generic, ex.getMessage(), 'Generic message expected');
        }
        Test.stopTest();

        Assert.areEqual(0, [SELECT COUNT() FROM Account WHERE PersonEmail = :EMAIL], 'Account must be rolled back');
    }
}
