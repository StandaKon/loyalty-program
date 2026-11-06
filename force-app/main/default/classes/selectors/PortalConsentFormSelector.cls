/**
 * Encapsulates all SOQL for AuthorizationForm records (consent text versions).
 */
public inherited sharing class PortalConsentFormSelector {
    /**
     * SYSTEM_MODE because registration runs as the site guest user, who has no access to consent
     * evidence objects. Only form and text Ids leave this method.
     */
    public List<AuthorizationForm> selectEffectiveByConsentTypes(Set<String> consentTypes, Date day) {
        if (consentTypes == null || consentTypes.isEmpty() || day == null) {
            return new List<AuthorizationForm>();
        }
        return [
            SELECT Id, Consent_Type__c, DefaultAuthFormTextId
            FROM AuthorizationForm
            WHERE Consent_Type__c IN :consentTypes
                AND DefaultAuthFormTextId != NULL
                AND (EffectiveFromDate = NULL OR EffectiveFromDate <= :day)
                AND (EffectiveToDate = NULL OR EffectiveToDate >= :day)
            WITH SYSTEM_MODE
            ORDER BY EffectiveFromDate DESC NULLS LAST, CreatedDate DESC
        ];
    }
}
