/**
 * Thin wrapper around the Site class so registration logic can be unit tested
 * (Site methods only work inside a real Experience Cloud request).
 */
public inherited sharing virtual class PortalSiteGateway {
    public virtual void validatePassword(User user, String password) {
        Site.validatePassword(user, password, password);
    }

    public virtual Id createExternalUser(User user, Id accountId, String password) {
        return Site.createExternalUser(user, accountId, password);
    }

    public virtual String login(String username, String password) {
        PageReference landingPage = Site.login(username, password, Site.getPathPrefix() + '/');
        return landingPage?.getUrl();
    }
}
