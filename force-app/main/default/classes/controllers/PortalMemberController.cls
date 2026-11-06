/**
 * Read-only API for the member portal LWCs (portalOverview, portalPointHistory, portalCampaigns, portalRewards).
 * Methods are not cacheable so balances are always fresh after redemptions.
 */
public with sharing class PortalMemberController {
    // Stable code (not user-facing text) so the LWC can show the "not a member" state instead of an error.
    public static final String ERROR_CODE_NOT_MEMBER = 'PORTAL_NOT_MEMBER';

    @TestVisible
    private static PortalMemberService memberService = new PortalMemberService();

    @AuraEnabled
    public static PortalMemberDto.Overview getOverview() {
        try {
            return memberService.getOverview();
        } catch (Exception ex) {
            throw toFriendlyException(ex);
        }
    }

    @AuraEnabled
    public static PortalMemberDto.HistoryPage getPointHistory(Integer pageSize, Integer pageNumber) {
        try {
            return memberService.getPointHistory(pageSize, pageNumber);
        } catch (Exception ex) {
            throw toFriendlyException(ex);
        }
    }

    @AuraEnabled
    public static List<PortalMemberDto.Campaign> getActiveCampaigns() {
        try {
            return memberService.getActiveCampaigns();
        } catch (Exception ex) {
            throw toFriendlyException(ex);
        }
    }

    @AuraEnabled
    public static PortalMemberDto.LoyaltyStatus getLoyaltyStatus() {
        try {
            return memberService.getLoyaltyStatus();
        } catch (Exception ex) {
            throw toFriendlyException(ex);
        }
    }

    @AuraEnabled
    public static PortalMemberDto.RewardCatalog getRewardCatalog() {
        try {
            return memberService.getRewardCatalog();
        } catch (Exception ex) {
            throw toFriendlyException(ex);
        }
    }

    private static AuraHandledException toFriendlyException(Exception ex) {
        String message = System.Label.Portal_Error_Generic;
        if (ex instanceof PortalMemberService.PortalNotMemberException) {
            message = ERROR_CODE_NOT_MEMBER;
        } else {
            System.debug(LoggingLevel.ERROR, ex.getTypeName() + ': ' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        AuraHandledException friendly = new AuraHandledException(message);
        friendly.setMessage(message);
        return friendly;
    }
}
