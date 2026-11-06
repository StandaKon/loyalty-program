/**
 * Test data for member portal tests: Person Account members, ledger entries and portal users.
 */
@IsTest
public class PortalTestDataFactory {
    public static final String PORTAL_PROFILE_NAME = 'EneOil Member';
    public static final String FALLBACK_PORTAL_PROFILE_NAME = 'Customer Community User';
    public static final Set<String> PORTAL_PERMISSION_SETS = new Set<String>{ 'Loyalty_Member', 'Loyalty_Member_Portal' };
    public static final String LEDGER_TYPE_ADJUSTMENT = 'Adjustment';
    public static final String CONSENT_TYPE_TERMS = 'Terms';
    public static final String CONSENT_TYPE_MARKETING = 'Marketing';

    private static Integer uniqueCounter = 0;

    public static User createAccountOwner() {
        UserRole role = new UserRole(Name = 'EneOil Portal Owner ' + nextSuffix());
        insert role;
        User owner = buildUser(
            [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            'owner'
        );
        owner.UserRoleId = role.Id;
        insert owner;
        return owner;
    }

    public static Account buildMember(String firstName) {
        String suffix = nextSuffix();
        return new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(),
            FirstName = firstName,
            LastName = 'Member' + suffix,
            PersonEmail = firstName.toLowerCase() + suffix + '@eneoil-test.cz',
            Member_Number__c = 'ENE-TEST-' + suffix,
            Membership_Status__c = 'Active',
            Joined_At__c = Datetime.now().addDays(-30)
        );
    }

    /**
     * Uses Adjustment entries because they need no source transaction, campaign or voucher (B1 model 4.5).
     */
    public static List<Point_Ledger__c> buildLedgerEntries(Id memberId, List<Integer> pointsList) {
        List<Point_Ledger__c> entries = new List<Point_Ledger__c>();
        for (Integer index = 0; index < pointsList.size(); index++) {
            entries.add(
                new Point_Ledger__c(
                    Member__c = memberId,
                    Points__c = pointsList[index],
                    Entry_Type__c = LEDGER_TYPE_ADJUSTMENT,
                    Reason__c = 'Portal test data',
                    Unique_Key__c = 'ADJ:' + memberId + ':' + index + ':' + nextSuffix(),
                    Occurred_At__c = Datetime.now().addDays(-index)
                )
            );
        }
        return entries;
    }

    /**
     * Creates one effective consent text version per consent type, as B4 seed data will.
     */
    public static void createEffectiveConsentForms() {
        for (String consentType : new List<String>{ CONSENT_TYPE_TERMS, CONSENT_TYPE_MARKETING }) {
            AuthorizationForm form = new AuthorizationForm(
                Name = 'EneOil Klub ' + consentType + ' v1',
                RevisionNumber = '1',
                EffectiveFromDate = Date.today().addDays(-1),
                Consent_Type__c = consentType
            );
            insert form;
            AuthorizationFormText formText = new AuthorizationFormText(
                Name = 'EneOil Klub ' + consentType + ' v1 cs',
                AuthorizationFormId = form.Id,
                Locale = 'cs_CZ',
                SummaryAuthFormText = consentType + ' text'
            );
            insert formText;
            form.DefaultAuthFormTextId = formText.Id;
            update form;
        }
    }

    public static User createPortalUser(Account member) {
        Account personAccount = [SELECT PersonContactId FROM Account WHERE Id = :member.Id];
        User portalUser = buildUser(getPortalProfileId(), 'member');
        portalUser.ContactId = personAccount.PersonContactId;
        insert portalUser;

        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for (PermissionSet permissionSet : [SELECT Id FROM PermissionSet WHERE Name IN :PORTAL_PERMISSION_SETS]) {
            assignments.add(new PermissionSetAssignment(AssigneeId = portalUser.Id, PermissionSetId = permissionSet.Id));
        }
        insert assignments;
        return portalUser;
    }

    private static Id getPortalProfileId() {
        Map<String, Id> profileIdsByName = new Map<String, Id>();
        for (Profile portalProfile : [
            SELECT Id, Name
            FROM Profile
            WHERE Name IN (:PORTAL_PROFILE_NAME, :FALLBACK_PORTAL_PROFILE_NAME)
        ]) {
            profileIdsByName.put(portalProfile.Name, portalProfile.Id);
        }
        return profileIdsByName.containsKey(PORTAL_PROFILE_NAME)
            ? profileIdsByName.get(PORTAL_PROFILE_NAME)
            : profileIdsByName.get(FALLBACK_PORTAL_PROFILE_NAME);
    }

    private static User buildUser(Id profileId, String prefix) {
        String suffix = nextSuffix();
        String username = prefix + suffix + '@eneoil-test.cz.portal';
        return new User(
            ProfileId = profileId,
            Username = username,
            Email = prefix + suffix + '@eneoil-test.cz',
            LastName = 'Test' + suffix,
            Alias = (prefix + suffix).left(8),
            CommunityNickname = prefix + suffix,
            LanguageLocaleKey = 'cs',
            LocaleSidKey = 'cs_CZ',
            TimeZoneSidKey = 'Europe/Prague',
            EmailEncodingKey = 'UTF-8'
        );
    }

    private static String nextSuffix() {
        uniqueCounter++;
        return String.valueOf(uniqueCounter) + String.valueOf(Math.abs(Math.mod(Crypto.getRandomInteger(), 100000)));
    }
}
