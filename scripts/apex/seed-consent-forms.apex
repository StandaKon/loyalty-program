// B6 prerequisite: one effective Czech consent text for Terms and for Marketing (B1 model 4.8).
// Registration fails with a generic error until both exist. Replace the [PLACEHOLDER] texts with approved legal copy.
// Idempotent: skips a consent type that already has a form.
// Consent_Type__c is accessed dynamically because no permission set grants Edit on it (B1): static references
// fail to compile without FLS, while Apex DML and dynamic SOQL do not enforce FLS by default.
String consentTypeField = 'Consent_Type__c';
Map<String, String> textsByType = new Map<String, String>{
    'Terms' => '[PLACEHOLDER] Souhlasím s podmínkami EneOil Klubu a beru na vědomí informace o zpracování osobních údajů.',
    'Marketing' => '[PLACEHOLDER] Souhlasím se zasíláním novinek a akcí EneOil Klubu e-mailem.'
};
Set<String> existingTypes = new Set<String>();
for (SObject form : Database.query('SELECT ' + consentTypeField + ' FROM AuthorizationForm')) {
    existingTypes.add((String) form.get(consentTypeField));
}
for (String consentType : textsByType.keySet()) {
    if (existingTypes.contains(consentType)) {
        continue;
    }
    AuthorizationForm form = new AuthorizationForm(
        Name = 'EneOil Klub ' + consentType + ' v1',
        RevisionNumber = '1',
        EffectiveFromDate = Date.today()
    );
    form.put(consentTypeField, consentType);
    insert form;
    AuthorizationFormText formText = new AuthorizationFormText(
        Name = 'EneOil Klub ' + consentType + ' v1 cs',
        AuthorizationFormId = form.Id,
        Locale = 'cs_CZ',
        SummaryAuthFormText = textsByType.get(consentType)
    );
    insert formText;
    form.DefaultAuthFormTextId = formText.Id;
    update form;
}
System.debug('Consent forms ready for: ' + textsByType.keySet() + ', already existed: ' + existingTypes);
