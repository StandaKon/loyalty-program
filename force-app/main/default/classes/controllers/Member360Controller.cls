public with sharing class Member360Controller {
    @TestVisible
    private static Member360Service service = new Member360Service();

    @AuraEnabled(cacheable=true)
    public static Member360Service.Member360 getMember360(Id memberId) {
        try {
            return service.getMember360(memberId);
        } catch (Exception caughtException) {
            throw LoyaltyControllerErrors.toAuraException(caughtException);
        }
    }
}
