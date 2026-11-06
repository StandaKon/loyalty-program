/**
 * Converts exceptions of back-office actions into messages for LWC.
 * Business rule and validation rule messages are shown as they are; anything else gets a generic message with the cause.
 */
public with sharing class LoyaltyControllerErrors {
    public static AuraHandledException toAuraException(Exception caughtException) {
        String message;
        if (caughtException instanceof LoyaltyActionException) {
            message = caughtException.getMessage();
        } else if (caughtException instanceof DmlException) {
            message = ((DmlException) caughtException).getDmlMessage(0);
        } else {
            message = String.format(Label.Loyalty_BO_Error_Unexpected, new List<Object>{ caughtException.getMessage() });
        }
        AuraHandledException auraException = new AuraHandledException(message);
        auraException.setMessage(message);
        return auraException;
    }
}
