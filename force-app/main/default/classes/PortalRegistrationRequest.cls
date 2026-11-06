/**
 * Self-registration input sent from the portalRegistration LWC.
 */
public with sharing class PortalRegistrationRequest {
    @AuraEnabled
    public String firstName { get; set; }
    @AuraEnabled
    public String lastName { get; set; }
    @AuraEnabled
    public String email { get; set; }
    @AuraEnabled
    public String password { get; set; }
    @AuraEnabled
    public Boolean termsAccepted { get; set; }
    @AuraEnabled
    public Boolean marketingConsent { get; set; }
}
