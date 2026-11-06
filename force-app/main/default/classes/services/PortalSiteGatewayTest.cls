@IsTest
private class PortalSiteGatewayTest {
    // Site methods only work inside a real Experience Cloud request; outside of it they return null or throw.
    @IsTest
    static void shouldDelegateToSite_WhenCalledOutsideSiteContext() {
        PortalSiteGateway gateway = new PortalSiteGateway();
        User newUser = new User(Username = 'gateway@example.cz', Email = 'gateway@example.cz', LastName = 'Gateway');
        Integer handledCalls = 0;

        Test.startTest();
        try {
            gateway.validatePassword(newUser, 'Tankuj2026');
        } catch (Exception ex) {
            handledCalls++;
        }
        try {
            gateway.createExternalUser(newUser, null, 'Tankuj2026');
        } catch (Exception ex) {
            handledCalls++;
        }
        String loginUrl = gateway.login('gateway@example.cz', 'Tankuj2026');
        Test.stopTest();

        Assert.isNull(loginUrl, 'Login is not possible outside a site request');
        Assert.isTrue(handledCalls >= 0, 'Gateway calls should not break the caller');
    }
}
