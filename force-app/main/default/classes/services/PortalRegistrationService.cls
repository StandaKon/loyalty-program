/**
 * Member self-registration: creates a Person Account (member number, join date, status), records
 * terms and marketing consent events (AuthorizationFormConsent), the one-time marketing bonus (B7)
 * and a Customer Community user
 * linked through PersonContactId, then signs the member in.
 *
 * Runs WITHOUT sharing on purpose: it executes as the site guest user, who has no access to
 * Account or User records. Input is fully validated here and only a login URL is returned.
 */
public without sharing class PortalRegistrationService {
    private static final String PERSON_ACCOUNT_RECORD_TYPE = 'PersonAccount';
    private static final String MEMBER_NUMBER_PREFIX = 'ENE-';
    private static final String MEMBERSHIP_STATUS_ACTIVE = 'Active';
    private static final String CONSENT_TYPE_TERMS = 'Terms';
    private static final String CONSENT_TYPE_MARKETING = 'Marketing';
    private static final String CONSENT_ACTION_ACCEPTED = 'Accepted';
    private static final String CONSENT_ACTION_DECLINED = 'Declined';
    private static final String CONSENT_STATUS_SIGNED = 'Signed';
    private static final String CONSENT_STATUS_REJECTED = 'Rejected';
    private static final String CONSENT_SOURCE = 'EneOil Klub portal - registration';
    private static final String CONSENT_SOURCE_TYPE = 'Web';
    private static final Set<String> MEMBER_PERMISSION_SETS = new Set<String>{ 'Loyalty_Member', 'Loyalty_Member_Portal' };
    private static final String CZECH_LANGUAGE = 'cs';
    private static final String CZECH_LOCALE = 'cs_CZ';
    private static final String PRAGUE_TIME_ZONE = 'Europe/Prague';
    private static final String EMAIL_ENCODING = 'UTF-8';
    private static final Integer FIRST_NAME_MAX_LENGTH = 40;
    private static final Integer LAST_NAME_MAX_LENGTH = 80;
    private static final Integer EMAIL_MAX_LENGTH = 80;
    private static final Integer NICKNAME_PREFIX_MAX_LENGTH = 30;
    private static final Integer NICKNAME_SUFFIX_UPPER_BOUND = 1000000;
    private static final Pattern EMAIL_PATTERN = Pattern.compile('^[A-Za-z0-9._%+\\-]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,}$');

    private final PortalUserSelector userSelector;
    private final PortalConsentFormSelector authorizationFormSelector;
    private final PortalSiteGateway siteGateway;
    private final PortalBonusService bonusService = new PortalBonusService();

    public PortalRegistrationService() {
        this(new PortalUserSelector(), new PortalConsentFormSelector(), new PortalSiteGateway());
    }

    @TestVisible
    private PortalRegistrationService(PortalUserSelector userSelector, PortalConsentFormSelector authorizationFormSelector, PortalSiteGateway siteGateway) {
        this.userSelector = userSelector;
        this.authorizationFormSelector = authorizationFormSelector;
        this.siteGateway = siteGateway;
    }

    /**
     * @return URL the browser should open to finish the login, or null when the member must log in manually
     * @throws PortalRegistrationException with a user-facing (translated) message
     */
    public String register(PortalRegistrationRequest request) {
        String email = validate(request);
        User newUser = buildUser(request, email);
        validatePassword(newUser, request.password);
        ensureUsernameIsFree(email);

        Savepoint savepoint = Database.setSavepoint();
        try {
            Map<String, Id> consentTextIdsByType = getEffectiveConsentTextIds();
            Datetime registeredAt = Datetime.now();
            Account member = insertMember(request, email, registeredAt);
            insertConsents(member.Id, request.marketingConsent == true, consentTextIdsByType, registeredAt);
            if (request.marketingConsent == true) {
                bonusService.awardOnce(member.Id, PortalBonusService.ENTRY_TYPE_MARKETING);
            }
            Id userId = siteGateway.createExternalUser(newUser, member.Id, request.password);
            if (userId == null) {
                throw new PortalRegistrationException('Site.createExternalUser returned no user Id.');
            }
            assignMemberPermissionSets(new Set<Id>{ userId });
        } catch (Exception ex) {
            Database.rollback(savepoint);
            System.debug(LoggingLevel.ERROR, 'Self-registration failed: ' + ex.getTypeName() + ': ' + ex.getMessage());
            throw new PortalRegistrationException(System.Label.Portal_Register_Error_Generic);
        }
        return loginNewMember(email, request.password);
    }

    /**
     * The account already exists at this point, so a failed auto-login must not report a failed
     * registration. Returning null lets the UI send the member to the login page instead.
     */
    private String loginNewMember(String email, String password) {
        try {
            return siteGateway.login(email, password);
        } catch (Exception ex) {
            System.debug(LoggingLevel.WARN, 'Auto-login after self-registration failed: ' + ex.getMessage());
            return null;
        }
    }

    /**
     * Async because PermissionSetAssignment is a setup object and cannot be inserted in the same
     * transaction as the member Account (mixed DML).
     */
    @future
    private static void assignMemberPermissionSets(Set<Id> userIds) {
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for (PermissionSet permissionSet : new PortalPermissionSetSelector().selectByNames(MEMBER_PERMISSION_SETS)) {
            for (Id userId : userIds) {
                assignments.add(new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = permissionSet.Id));
            }
        }
        Database.insert(assignments, true, AccessLevel.SYSTEM_MODE);
    }

    private String validate(PortalRegistrationRequest request) {
        if (request == null || String.isBlank(request.firstName) || String.isBlank(request.lastName)
            || String.isBlank(request.email) || String.isBlank(request.password)) {
            throw new PortalRegistrationException(System.Label.Portal_Register_Error_Required);
        }
        if (request.firstName.trim().length() > FIRST_NAME_MAX_LENGTH || request.lastName.trim().length() > LAST_NAME_MAX_LENGTH) {
            throw new PortalRegistrationException(System.Label.Portal_Register_Error_Required);
        }
        if (request.termsAccepted != true) {
            throw new PortalRegistrationException(System.Label.Portal_Register_Error_TermsRequired);
        }
        String email = request.email.trim().toLowerCase();
        if (email.length() > EMAIL_MAX_LENGTH || !EMAIL_PATTERN.matcher(email).matches()) {
            throw new PortalRegistrationException(System.Label.Portal_Register_Error_InvalidEmail);
        }
        return email;
    }

    private void validatePassword(User newUser, String password) {
        try {
            siteGateway.validatePassword(newUser, password);
        } catch (Exception ex) {
            throw new PortalRegistrationException(System.Label.Portal_Register_Error_Password);
        }
    }

    private void ensureUsernameIsFree(String email) {
        if (!userSelector.selectByUsernames(new Set<String>{ email }).isEmpty()) {
            throw new PortalRegistrationException(System.Label.Portal_Register_Error_EmailTaken);
        }
    }

    private Map<String, Id> getEffectiveConsentTextIds() {
        Map<String, Id> textIdsByType = new Map<String, Id>();
        for (AuthorizationForm form : authorizationFormSelector.selectEffectiveByConsentTypes(
            new Set<String>{ CONSENT_TYPE_TERMS, CONSENT_TYPE_MARKETING },
            Date.today()
        )) {
            if (!textIdsByType.containsKey(form.Consent_Type__c)) {
                textIdsByType.put(form.Consent_Type__c, form.DefaultAuthFormTextId);
            }
        }
        if (!textIdsByType.containsKey(CONSENT_TYPE_TERMS) || !textIdsByType.containsKey(CONSENT_TYPE_MARKETING)) {
            throw new PortalRegistrationException('No effective Terms or Marketing AuthorizationForm with a default text.');
        }
        return textIdsByType;
    }

    private Account insertMember(PortalRegistrationRequest request, String email, Datetime registeredAt) {
        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(PERSON_ACCOUNT_RECORD_TYPE)
            ?.getRecordTypeId();
        Account member = new Account(
            RecordTypeId = personAccountRecordTypeId,
            FirstName = request.firstName.trim(),
            LastName = request.lastName.trim(),
            PersonEmail = email,
            Membership_Status__c = MEMBERSHIP_STATUS_ACTIVE,
            Joined_At__c = registeredAt,
            Marketing_Consent__c = request.marketingConsent == true
        );
        Database.insert(member, true, AccessLevel.SYSTEM_MODE);

        // The member number is derived from the Account Id, which exists only after insert (B1 decision D11).
        member.Member_Number__c = MEMBER_NUMBER_PREFIX + member.Id;
        Database.update(new Account(Id = member.Id, Member_Number__c = member.Member_Number__c), true, AccessLevel.SYSTEM_MODE);
        return member;
    }

    private void insertConsents(Id memberId, Boolean hasMarketingConsent, Map<String, Id> consentTextIdsByType, Datetime capturedAt) {
        List<AuthorizationFormConsent> consents = new List<AuthorizationFormConsent>{
            buildConsent(memberId, CONSENT_TYPE_TERMS, consentTextIdsByType.get(CONSENT_TYPE_TERMS), true, capturedAt),
            buildConsent(memberId, CONSENT_TYPE_MARKETING, consentTextIdsByType.get(CONSENT_TYPE_MARKETING), hasMarketingConsent, capturedAt)
        };
        Database.insert(consents, true, AccessLevel.SYSTEM_MODE);
    }

    private AuthorizationFormConsent buildConsent(Id memberId, String consentType, Id textId, Boolean isAccepted, Datetime capturedAt) {
        return new AuthorizationFormConsent(
            Name = consentType + ' - ' + (isAccepted ? CONSENT_ACTION_ACCEPTED : CONSENT_ACTION_DECLINED),
            ConsentGiverId = memberId,
            AuthorizationFormTextId = textId,
            Status = isAccepted ? CONSENT_STATUS_SIGNED : CONSENT_STATUS_REJECTED,
            Consent_Action__c = isAccepted ? CONSENT_ACTION_ACCEPTED : CONSENT_ACTION_DECLINED,
            ConsentCapturedDateTime = capturedAt,
            ConsentCapturedSource = CONSENT_SOURCE,
            ConsentCapturedSourceType = CONSENT_SOURCE_TYPE
        );
    }

    private User buildUser(PortalRegistrationRequest request, String email) {
        String nicknamePrefix = email.substringBefore('@').left(NICKNAME_PREFIX_MAX_LENGTH);
        return new User(
            Username = email,
            Email = email,
            FirstName = request.firstName.trim(),
            LastName = request.lastName.trim(),
            CommunityNickname = nicknamePrefix + Math.abs(Math.mod(Crypto.getRandomInteger(), NICKNAME_SUFFIX_UPPER_BOUND)),
            LanguageLocaleKey = CZECH_LANGUAGE,
            LocaleSidKey = CZECH_LOCALE,
            TimeZoneSidKey = PRAGUE_TIME_ZONE,
            EmailEncodingKey = EMAIL_ENCODING
        );
    }

    public class PortalRegistrationException extends Exception {
    }
}
