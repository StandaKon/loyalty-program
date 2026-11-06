# B6 — Implementation

**Branch:** `feature/B6-block` · **Date:** 2026-11-06 · **Status:** implemented locally, aligned with the B1 data model deployed in org `hackathon`; not committed, B6 not deployed yet  
**Related:** [README.md](README.md) (assignment, decisions), [B1 data model](../B1-data-model-config/data-model-config.md)

## 0. Deviations from the README proposals

| Question | Proposal in README | Applied | Reason |
| --- | --- | --- | --- |
| Registration build | `Site.createExternalUser` without account → platform creates Person Account | Apex inserts the Person Account, sets `Member_Number__c`, records consent events, then calls `Site.createExternalUser(user, personAccountId, password)`; rolled back on failure. Permission sets are assigned right after in a `@future` call | Member number and consents are stored atomically; permission sets cannot be assigned in the same transaction (mixed DML) |
| Consent storage | Terms + marketing flags with dates on Account | Standard `AuthorizationFormConsent` events (Terms Accepted; Marketing Accepted / Declined) + `Account.Marketing_Consent__c` | B1 model D08 / 4.8 |
| Campaign visibility | `Active = true AND Valid_From ≤ today ≤ Valid_To`, SYSTEM_MODE | `Is_Enabled__c = true AND Start_Date__c ≤ today ≤ End_Date__c`, USER_MODE | Campaigns and rewards are Public Read Only in B1 |
| Point-history fields | Date, type, description, points | `Occurred_At__c` (date), `Entry_Type__c` (translated), campaign name for `CampaignBonus`, `Points__c` | B1 ledger has no description; `Reason__c` is internal |
| Permission set / sharing | B6 creates `Loyalty_Member` and its own sharing set | B6 **reuses** B1 `Loyalty_Member` and sharing set `EneOil_Member_Data`; adds only `Loyalty_Member_Portal` (Apex access) | B1 already grants all needed object/field access; avoid overwriting B1 metadata |
| Logging / DML / mocks | `enehano-logger`, `dml`, `apex-mockery` | Plain `Database.*` with `AccessLevel`, `System.debug(LoggingLevel.ERROR, …)`, tests without mocks | The packages are not installed in the org; consistent with existing B1/B2 code |

## 1. Deployed B1 data model used by B6 (org `hackathon`, read-only check 2026-11-06)

B1 metadata was read from the org (Tooling API + describe) and **not changed**.

| Object | Fields used by B6 | B6 access |
| --- | --- | --- |
| Account (Person Account) | `FirstName`, `LastName`, `PersonEmail`, `Member_Number__c` (Text 30, unique ext. ID), `Membership_Status__c` (`Active`/`Blocked`/`Cancelled`), `Joined_At__c`, `Marketing_Consent__c`, `Points_Balance__c` (roll-up) | Registration writes; portal reads |
| `Point_Ledger__c` | `Member__c` (MD), `Points__c`, `Entry_Type__c` (`PurchaseBase`, `CampaignBonus`, `ProfileBonus`, `MarketingBonus`, `Redemption`, `Refund`, `Adjustment`), `Occurred_At__c`, `Campaign__c` → `Name` | Read (USER_MODE) |
| `Loyalty_Campaign__c` | `Name`, `Is_Enabled__c`, `Start_Date__c`, `End_Date__c`, `Member_Description__c` | Read (USER_MODE) |
| `Reward__c` | `Name`, `Points_Cost__c`, `Is_Active__c` | Read (USER_MODE), progress bar only |
| `AuthorizationForm` | `Consent_Type__c` (`Terms`/`Marketing`), `EffectiveFromDate`, `EffectiveToDate`, `DefaultAuthFormTextId` | Read (SYSTEM_MODE, guest) |
| `AuthorizationFormText` | `AuthorizationFormId`, `Locale` (`cs_CZ`), `SummaryAuthFormText` | Seed script / tests only |
| `AuthorizationFormConsent` | `ConsentGiverId`, `AuthorizationFormTextId`, `Status` (`Signed`/`Rejected`), `Consent_Action__c` (`Accepted`/`Declined`/`Withdrawn`), `ConsentCapturedDateTime`, `ConsentCapturedSource`, `ConsentCapturedSourceType` (`Web`) | Created by registration |

Relevant B1 rules confirmed in the org:

| Item | Effect on B6 |
| --- | --- |
| OWD: Account Private (ext.), Point Ledger Controlled by Parent, Campaign / Reward Read, Transaction / Voucher Private | Member reads own data via sharing set; campaigns and rewards directly |
| Sharing set `EneOil_Member_Data` (profiles incl. `eneoil member`): Account, `Loyalty_Transaction__c.Member__c`, `Voucher__c.Member__c` | Reused, B6 has no own sharing set |
| Permission set `Loyalty_Member` (B1): read Account, Contact, ledger, campaigns, rewards, transactions, vouchers + FLS | Reused; assigned to new members at registration |
| Validation `Required_Program_Fields` (Account): member number needs status + join date | Registration sets status + join date on insert, number on the following update |
| Validation `Member_Number_Immutable`, `Member_Must_Be_Person` | Number set once, only on Person Account |
| Ledger validations `Required_Program_Fields`, `Source_Required`, `Signs_Valid`, `Member_Valid` | Test data uses `Adjustment` + `Reason__c` + `Unique_Key__c` on members with a number |
| No triggers / automation on Account | B6 registration generates `Member_Number__c` = `ENE-` + Account Id |
| Existing B2 classes `AccountSelector`, `LoyaltyCampaignSelector` | B6 selectors renamed with `Portal` prefix to avoid overwriting them |

## 2. Delivered components

| Area | Components |
| --- | --- |
| Apex – controllers | `PortalMemberController` (`getOverview`, `getPointHistory`, `getActiveCampaigns`), `PortalRegistrationController` (`registerMember`, guest) |
| Apex – services | `PortalMemberService` (member resolved from `UserInfo`; DTO mapping; progress to nearest reward; paging max 50), `PortalRegistrationService` (`without sharing` – guest; validation, duplicate e-mail check, PA + number + status + join date, consent events, `Site.createExternalUser`, savepoint rollback, async permission-set assignment, auto-login with fallback), `PortalSiteGateway` (wraps `Site`) |
| Apex – selectors | `PortalUserSelector`, `PortalAccountSelector`, `PortalPointLedgerSelector`, `PortalCampaignSelector`, `PortalRewardSelector` (USER_MODE); `PortalConsentFormSelector`, `PortalPermissionSetSelector`, `PortalUserSelector.selectByUsernames` (SYSTEM_MODE – guest / async) |
| Apex – DTOs | `PortalMemberDto`, `PortalRegistrationRequest` |
| Apex – tests (basic) | `PortalMemberControllerTest` (own data + isolation of two members, friendly error), `PortalRegistrationServiceTest` (success incl. consents and permission sets, missing terms, rollback), `PortalRegistrationControllerTest`, `PortalTestDataFactory` |
| LWC – pages | `portalOverview`, `portalPointHistory`, `portalCampaigns`, `portalRegistration`, `portalPlaceholder`, `portalStaticPage` |
| LWC – shared | `portalHeader`, `portalFooter`, `portalStateMessage`, `portalMovementList`, `portalCampaignList`, `portalUtils` |
| Labels | 69 `Portal_*` Custom Labels (en_US) + Czech translation |
| Security | Profile `EneOil Member`, permission sets `Loyalty_Member_Portal` (Apex for members), `Loyalty_Portal_Guest` (registration Apex for guest) and `Loyalty_Consent_Setup` (admin: edit consent type for seeding) |
| Site | Czech default language; header/footer in theme layout; Home → `portalOverview`; Register → `portalRegistration`; routes `historie-bodu`, `akce`, `ziskej-body`, `odmeny`, `moje-vouchery`, `profil`, `podminky`, `ochrana-osobnich-udaju`; Czech Login / Forgot Password / Check Email; brand tokens + fonts; CSP trusted sites for Google Fonts |
| Scripts | `scripts/apex/assign-portal-guest-permset.apex`, `scripts/apex/seed-consent-forms.apex` |

## 3. Validation results (dry run against org `hackathon`)

| Check | Result |
| --- | --- |
| Compile of all B6 metadata | Pass |
| Apex tests `PortalMemberControllerTest`, `PortalRegistrationControllerTest`, `PortalRegistrationServiceTest` | **6/6 passed** |
| Coverage | Portal classes 80–100 %, except `PortalSiteGateway` 0 % (wrapper around `Site`, not testable outside a site request). Deploy to the Developer Edition runs without tests |
| LWC lint | Pass |
| Not validated | `sfdc_cms__site/EneOil1` (original template file, rejected `geoBotsAllowed` — not deployed), Network (see step 2) |

## 4. Deploy steps (org alias `hackathon`)

Run from the repository root.

1. **Deploy B6 metadata** (no tests required in a Developer Edition):

   ```bash
   S=force-app/main/default/digitalExperiences/site/EneOil1
   sf project deploy start --target-org hackathon --ignore-conflicts --test-level NoTestRun \
     --source-dir force-app/main/default/classes \
     --source-dir force-app/main/default/lwc \
     --source-dir force-app/main/default/labels \
     --source-dir force-app/main/default/translations \
     --source-dir force-app/main/default/cspTrustedSites \
     --source-dir force-app/main/default/profiles \
     --source-dir force-app/main/default/permissionsets \
     --source-dir $S/sfdc_cms__route \
     --source-dir $S/sfdc_cms__view \
     --source-dir $S/sfdc_cms__themeLayout \
     --source-dir $S/sfdc_cms__styles \
     --source-dir $S/sfdc_cms__appPage \
     --source-dir $S/sfdc_cms__languageSettings
   ```

2. **Site members + self-registration:** Setup → Digital Experiences → All Sites → EneOil → Workspaces → Administration → **Members** → add profile **EneOil Member** → Save. Then deploy the network:

   ```bash
   sf project deploy start --target-org hackathon --ignore-conflicts --source-dir force-app/main/default/networks/EneOil.network-meta.xml
   ```

3. **Guest access + consent texts:**

   ```bash
   sf apex run --target-org hackathon --file scripts/apex/assign-portal-guest-permset.apex
   sf org assign permset --target-org hackathon --name Loyalty_Consent_Setup
   sf apex run --target-org hackathon --file scripts/apex/seed-consent-forms.apex
   ```

   `Loyalty_Consent_Setup` (admin only) gives Edit on `AuthorizationForm.Consent_Type__c` — B1 grants the field read-only to `Loyalty_Manager`, and anonymous Apex enforces FLS.

4. **Site settings:** Administration → Preferences/Settings → _Assign records created by guest users to a default owner_ → an internal user **with a role**.
5. **Publish:**

   ```bash
   sf community publish --name EneOil --target-org hackathon
   ```

6. **Smoke test:** register a new member → check Person Account (`Member_Number__c = ENE-<Id>`, status `Active`, join date), two `AuthorizationFormConsent` records, user with `Loyalty_Member` + `Loyalty_Member_Portal`; log in as two members and confirm each sees only own balance and history; check 360 px width.

## 5. Follow-ups

- **+50 marketing bonus** (`MarketingBonus`, key `MEM:<account-id>:MARKETING`) is not written at registration — B7 activity service must award it, including for consent given at registration.
- Consent text is resolved on the server (current effective version). Podmínky / Ochrana osobních údajů pages and the seed texts are `[PLACEHOLDER]` — replace with approved legal copy and keep them identical to `AuthorizationFormText`.
- URL prefix rename (`EneOilMembershipvforcesite` → `klub`) not applied — awaiting approval.
- Point history uses SOQL `OFFSET` (max 2 000 rows) — sufficient for MVP.
- B7/B8 replace placeholder pages (`Ziskej_body__c`, `Odmeny__c`, `Moje_vouchery__c`, `Profil__c`).
- When the B2 branch (`AccountSelector`, `LoyaltyCampaignSelector`, …) is merged, consider reusing its selectors instead of the `Portal*` ones.
