/**
 * Portal activities (B7): the member edits the own vehicle profile and marketing consent and earns the
 * one-time ProfileBonus and MarketingBonus.
 *
 * Runs WITHOUT sharing on purpose: members have Read Only access to their Account (sharing set) and no access
 * to consent objects, while B1 (4.8, 5) lets them change the own profile and consent through this server action.
 * The member is always resolved from the running user; the client never sends a record Id.
 */
public without sharing class PortalActivityService {
    private static final String MEMBERSHIP_STATUS_ACTIVE = 'Active';
    private static final String CONSENT_TYPE_MARKETING = 'Marketing';
    private static final String CONSENT_ACTION_ACCEPTED = 'Accepted';
    private static final String CONSENT_ACTION_WITHDRAWN = 'Withdrawn';
    private static final String CONSENT_STATUS_SIGNED = 'Signed';
    private static final String CONSENT_STATUS_REJECTED = 'Rejected';
    private static final String CONSENT_SOURCE = 'EneOil Klub portal - profile';
    private static final String CONSENT_SOURCE_TYPE = 'Web';
    private static final Integer MAKE_MAX_LENGTH = 80;
    private static final Integer MODEL_MAX_LENGTH = 80;
    private static final Integer REGISTRATION_MAX_LENGTH = 20;
    private static final Integer MIN_VEHICLE_YEAR = 1900;

    private final PortalUserSelector userSelector;
    private final PortalAccountSelector portalAccountSelector;
    private final AccountSelector accountSelector;
    private final PortalConsentFormSelector consentFormSelector;
    private final PortalBonusService bonusService;

    public PortalActivityService() {
        this(new PortalUserSelector(), new PortalAccountSelector(), new AccountSelector(), new PortalConsentFormSelector(), new PortalBonusService());
    }

    @TestVisible
    private PortalActivityService(
        PortalUserSelector userSelector,
        PortalAccountSelector portalAccountSelector,
        AccountSelector accountSelector,
        PortalConsentFormSelector consentFormSelector,
        PortalBonusService bonusService
    ) {
        this.userSelector = userSelector;
        this.portalAccountSelector = portalAccountSelector;
        this.accountSelector = accountSelector;
        this.consentFormSelector = consentFormSelector;
        this.bonusService = bonusService;
    }

    public PortalActivityDto.Activities getActivities() {
        return buildActivities(getCurrentMemberId(), 0);
    }

    public PortalActivityDto.Activities saveVehicleProfile(PortalActivityDto.VehicleProfile vehicle) {
        Account profile = toValidatedProfile(vehicle);
        Account member = lockCurrentMember();
        profile.Id = member.Id;
        Database.update(profile, true, AccessLevel.SYSTEM_MODE);

        Integer awardedPoints = 0;
        if (isActive(member) && getActivityState(member.Id).Profile_Complete__c) {
            awardedPoints = bonusService.awardOnce(member.Id, PortalBonusService.ENTRY_TYPE_PROFILE);
        }
        return buildActivities(member.Id, awardedPoints);
    }

    /**
     * Only a change of the consent state creates a new consent event; the bonus is awarded on the first grant
     * of an active member. Withdrawal never reverses points (B1 4.8).
     */
    public PortalActivityDto.Activities setMarketingConsent(Boolean isGranted) {
        if (isGranted == null) {
            throw new PortalActivityException(System.Label.Portal_Error_Generic);
        }
        Account member = lockCurrentMember();
        if (getActivityState(member.Id).Marketing_Consent__c == isGranted) {
            return buildActivities(member.Id, 0);
        }

        Datetime capturedAt = Datetime.now();
        Database.insert(buildMarketingConsent(member.Id, isGranted, capturedAt), true, AccessLevel.SYSTEM_MODE);
        Database.update(new Account(Id = member.Id, Marketing_Consent__c = isGranted), true, AccessLevel.SYSTEM_MODE);

        Integer awardedPoints = 0;
        if (isGranted && isActive(member)) {
            awardedPoints = bonusService.awardOnce(member.Id, PortalBonusService.ENTRY_TYPE_MARKETING);
        }
        return buildActivities(member.Id, awardedPoints);
    }

    private PortalActivityDto.Activities buildActivities(Id memberId, Integer awardedPoints) {
        Account state = getActivityState(memberId);

        PortalActivityDto.VehicleProfile vehicle = new PortalActivityDto.VehicleProfile();
        vehicle.make = state.Vehicle_Make__c;
        vehicle.model = state.Vehicle_Model__c;
        vehicle.fuelType = state.Vehicle_Fuel_Type__c;
        vehicle.year = state.Vehicle_Year__c?.intValue();
        vehicle.registration = state.Vehicle_Registration__c;

        PortalActivityDto.Activities activities = new PortalActivityDto.Activities();
        activities.vehicle = vehicle;
        activities.fuelTypeOptions = PicklistOptions.getOptions(Account.Vehicle_Fuel_Type__c);
        activities.isProfileComplete = state.Profile_Complete__c;
        activities.hasProfileBonus = bonusService.hasBonus(memberId, PortalBonusService.ENTRY_TYPE_PROFILE);
        activities.profileBonusPoints = bonusService.getBonusPoints(PortalBonusService.ENTRY_TYPE_PROFILE);
        activities.hasMarketingConsent = state.Marketing_Consent__c;
        activities.hasMarketingBonus = bonusService.hasBonus(memberId, PortalBonusService.ENTRY_TYPE_MARKETING);
        activities.marketingBonusPoints = bonusService.getBonusPoints(PortalBonusService.ENTRY_TYPE_MARKETING);
        activities.awardedPoints = awardedPoints;
        return activities;
    }

    private Account toValidatedProfile(PortalActivityDto.VehicleProfile vehicle) {
        if (vehicle == null) {
            throw new PortalActivityException(System.Label.Portal_Profile_Error_Invalid);
        }
        String make = vehicle.make?.trim();
        String model = vehicle.model?.trim();
        String fuelType = vehicle.fuelType?.trim();
        String registration = vehicle.registration?.trim();
        Integer year = vehicle.year;
        Boolean isValid =
            (make ?? '').length() <= MAKE_MAX_LENGTH &&
            (model ?? '').length() <= MODEL_MAX_LENGTH &&
            (registration ?? '').length() <= REGISTRATION_MAX_LENGTH &&
            (String.isBlank(fuelType) || PicklistOptions.isValid(Account.Vehicle_Fuel_Type__c, fuelType)) &&
            (year == null || (year >= MIN_VEHICLE_YEAR && year <= Date.today().year() + 1));
        if (!isValid) {
            throw new PortalActivityException(System.Label.Portal_Profile_Error_Invalid);
        }
        return new Account(
            Vehicle_Make__c = String.isBlank(make) ? null : make,
            Vehicle_Model__c = String.isBlank(model) ? null : model,
            Vehicle_Fuel_Type__c = String.isBlank(fuelType) ? null : fuelType,
            Vehicle_Year__c = year,
            Vehicle_Registration__c = String.isBlank(registration) ? null : registration
        );
    }

    private AuthorizationFormConsent buildMarketingConsent(Id memberId, Boolean isGranted, Datetime capturedAt) {
        List<AuthorizationForm> forms = consentFormSelector.selectEffectiveByConsentTypes(new Set<String>{ CONSENT_TYPE_MARKETING }, Date.today());
        if (forms.isEmpty()) {
            throw new PortalActivityException(System.Label.Portal_Error_Generic);
        }
        String action = isGranted ? CONSENT_ACTION_ACCEPTED : CONSENT_ACTION_WITHDRAWN;
        return new AuthorizationFormConsent(
            Name = CONSENT_TYPE_MARKETING + ' - ' + action,
            ConsentGiverId = memberId,
            AuthorizationFormTextId = forms[0].DefaultAuthFormTextId,
            Status = isGranted ? CONSENT_STATUS_SIGNED : CONSENT_STATUS_REJECTED,
            Consent_Action__c = action,
            ConsentCapturedDateTime = capturedAt,
            ConsentCapturedSource = CONSENT_SOURCE,
            ConsentCapturedSourceType = CONSENT_SOURCE_TYPE
        );
    }

    // Row lock serializes all point-changing operations of one member (B1 4.5).
    private Account lockCurrentMember() {
        Id memberId = getCurrentMemberId();
        Account member = accountSelector.getMemberByIdForUpdate(memberId);
        if (member == null || String.isBlank(member.Member_Number__c)) {
            throw new PortalMemberService.PortalNotMemberException('Account is not a loyalty member: ' + memberId);
        }
        return member;
    }

    private Account getActivityState(Id memberId) {
        List<Account> members = portalAccountSelector.selectActivityStateByIds(new Set<Id>{ memberId });
        if (members.isEmpty()) {
            throw new PortalMemberService.PortalNotMemberException('Member account is not accessible for user ' + UserInfo.getUserId());
        }
        return members[0];
    }

    private Id getCurrentMemberId() {
        List<User> users = userSelector.selectByIds(new Set<Id>{ UserInfo.getUserId() });
        Id memberId = users.isEmpty() ? null : users[0].AccountId;
        if (memberId == null) {
            throw new PortalMemberService.PortalNotMemberException('Running user is not linked to a member account: ' + UserInfo.getUserId());
        }
        return memberId;
    }

    private static Boolean isActive(Account member) {
        return member.Membership_Status__c == MEMBERSHIP_STATUS_ACTIVE;
    }

    // Message is a translated Custom Label, safe to show to the member.
    public class PortalActivityException extends Exception {
    }
}
