/**
 * Guest-accessible API for the portalRegistration LWC.
 */
public with sharing class PortalRegistrationController {
    @TestVisible
    private static PortalRegistrationService registrationService = new PortalRegistrationService();

    /**
     * @return URL that completes the login of the newly registered member
     */
    @AuraEnabled
    public static String registerMember(PortalRegistrationRequest request) {
        try {
            return registrationService.register(request);
        } catch (PortalRegistrationService.PortalRegistrationException ex) {
            throw toAuraException(ex.getMessage());
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getTypeName() + ': ' + ex.getMessage() + '\n' + ex.getStackTraceString());
            throw toAuraException(System.Label.Portal_Register_Error_Generic);
        }
    }

    private static AuraHandledException toAuraException(String message) {
        AuraHandledException auraException = new AuraHandledException(message);
        auraException.setMessage(message);
        return auraException;
    }
}
