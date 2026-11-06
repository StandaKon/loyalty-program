@IsTest
private class PortalRegistrationControllerTest {
    @IsTest
    static void shouldReturnUserFacingMessage_WhenTermsAreNotAccepted() {
        PortalRegistrationRequest request = new PortalRegistrationRequest();
        request.firstName = 'Jana';
        request.lastName = 'Nováková';
        request.email = 'jana@example.cz';
        request.password = 'Tankuj2026';
        request.termsAccepted = false;

        Test.startTest();
        try {
            PortalRegistrationController.registerMember(request);
            Assert.fail('Expected AuraHandledException');
        } catch (AuraHandledException ex) {
            Assert.areEqual(System.Label.Portal_Register_Error_TermsRequired, ex.getMessage(), 'Validation message should reach the member');
        }
        Test.stopTest();
    }
}
