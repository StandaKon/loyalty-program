/**
 * API for the portal activity LWCs (portalEarnPoints, portalProfile).
 * Methods are not cacheable so bonus state and balance are always fresh.
 */
public with sharing class PortalActivityController {
    @TestVisible
    private static PortalActivityService activityService = new PortalActivityService();

    @AuraEnabled
    public static PortalActivityDto.Activities getActivities() {
        try {
            return activityService.getActivities();
        } catch (Exception ex) {
            throw toFriendlyException(ex);
        }
    }

    @AuraEnabled
    public static PortalActivityDto.Activities saveVehicleProfile(PortalActivityDto.VehicleProfile vehicle) {
        try {
            return activityService.saveVehicleProfile(vehicle);
        } catch (Exception ex) {
            throw toFriendlyException(ex);
        }
    }

    @AuraEnabled
    public static PortalActivityDto.Activities setMarketingConsent(Boolean isGranted) {
        try {
            return activityService.setMarketingConsent(isGranted);
        } catch (Exception ex) {
            throw toFriendlyException(ex);
        }
    }

    private static AuraHandledException toFriendlyException(Exception ex) {
        String message = System.Label.Portal_Error_Generic;
        if (ex instanceof PortalMemberService.PortalNotMemberException) {
            message = PortalMemberController.ERROR_CODE_NOT_MEMBER;
        } else if (ex instanceof PortalActivityService.PortalActivityException) {
            message = ex.getMessage();
        } else {
            System.debug(LoggingLevel.ERROR, ex.getTypeName() + ': ' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        AuraHandledException friendly = new AuraHandledException(message);
        friendly.setMessage(message);
        return friendly;
    }
}
