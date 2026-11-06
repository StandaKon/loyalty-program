# B7 — Implementation

**Branch:** `feature/B6-block` · **Date:** 2026-11-06 · **Status:** implemented and deployed to org `hackathon` (Developer Edition); site not yet published; not committed  
**Related:** [README.md](README.md) (assignment), [B6 implementation](../B6-member-portal-base/IMPLEMENTATION.md), [B1 data model](../B1-data-model-config/data-model-config.md)

## 0. Decisions applied

The open points were resolved from the B1 model deployed in the org and the following answers (2026-11-06):

| Question | Decision | Source |
| --- | --- | --- |
| **Q4** – fields for profile completion | `Vehicle_Make__c`, `Vehicle_Model__c`, `Vehicle_Fuel_Type__c`, `Vehicle_Year__c` (1900 – current year + 1). `Vehicle_Registration__c` optional. Completion = existing formula `Account.Profile_Complete__c` | B1 4.1 + formula in org |
| **Q5** – consent capture / withdrawal | Grant **and** withdraw in the portal (Profil page). Each state change = new `AuthorizationFormConsent` (`Accepted`/`Signed` or `Withdrawn`/`Rejected`, source `EneOil Klub portal - profile`, type `Web`, current effective Marketing text) + `Account.Marketing_Consent__c`. Withdrawal never reverses points; re-grant never awards again | B1 4.8, user decision |
| Ledger type / key | `ProfileBonus` `MEM:<account-id>:PROFILE`, `MarketingBonus` `MEM:<account-id>:MARKETING`; points from `Loyalty_Settings__mdt.Default` (100 / 50) | B1 4.5, 4.9 |
| Marketing consent at registration | B6 registration now awards `MarketingBonus` (+50) in the same transaction when the new member consents (label already promised "+50 bodů") | user decision |
| Historical members (consented before B7) | No catch-up job. Bonus is awarded only on a new grant (`false → true`) in the portal or at registration | user decision (only new registrations) |
| Blocked / Cancelled members | May edit profile and consent; no bonus is written | B1 4.1 |
| UI placement | Získej body = activity overview; Profil = vehicle form + consent | user decision |
| B2 classes | Reused from the org (`AccountSelector` with `FOR UPDATE`, `PointLedgerSelector`, `LoyaltySettingsSelector`, `PicklistOptions`) | user decision |

## 1. Org state checked before implementation (read-only)

| Item | Finding |
| --- | --- |
| B6 code in org vs. local | Identical (all `Portal*` classes and LWCs, whitespace only) |
| Account fields | `Vehicle_*`, `Profile_Complete__c` (formula), `Marketing_Consent__c`, validation `Vehicle_Year_Valid` exist |
| Ledger | Entry types `ProfileBonus`/`MarketingBonus`, unique `Unique_Key__c`; validations `Signs_Valid`, `Source_Required`, `Immutable_Entry`, `Member_Valid` |
| `Loyalty_Settings__mdt.Default` | `Profile_Bonus_Points__c = 100`, `Marketing_Bonus_Points__c = 50` |
| `Loyalty_Member` (B1) | Read-only FLS on vehicle + consent fields → writes must go through a server action |
| Consent forms | `EneOil Klub Terms v1`, `EneOil Klub Marketing v1` effective from 2026-11-06 |
| B2 classes in org | Not in this branch; identical to `origin/feature/points-engine` |

## 2. Delivered components

| Area | Components | Change |
| --- | --- | --- |
| Apex – B2 (copied unchanged from `origin/feature/points-engine` = org) | `selectors/AccountSelector`, `selectors/PointLedgerSelector`, `selectors/LoyaltySettingsSelector`, `PicklistOptions` | Added to branch only, **not modified, not redeployed** |
| Apex – controller | `PortalActivityController` (`getActivities`, `saveVehicleProfile`, `setMarketingConsent`) | New |
| Apex – services | `PortalActivityService` (`without sharing` – member has read-only access; member always from `UserInfo`; Account row lock; validation; consent events), `PortalBonusService` (one-time bonus: key check → insert → `DUPLICATE_VALUE` treated as already awarded) | New |
| Apex – selector | `PortalAccountSelector.selectActivityStateByIds` (USER_MODE) | Method added |
| Apex – DTO | `PortalActivityDto` (`Activities`, `VehicleProfile`) | New |
| Apex – registration | `PortalRegistrationService`: awards `MarketingBonus` after consent events, inside the existing savepoint | 3 lines + doc comment |
| Apex – tests | `PortalActivityControllerTest` (4 tests), `PortalRegistrationServiceTest` (bonus assertions added to the success test) | New / extended |
| LWC | `portalEarnPoints` (two activities, status, points, link to Profil), `portalProfile` (vehicle form, consent checkbox, success/bonus/error messages with `role="status"`/`role="alert"`, double-submit guard) | New |
| Labels | 26 `Portal_EarnPoints_*`, `Portal_Activity_*`, `Portal_Profile_*` (en_US) + Czech translation | New |
| Security | `Loyalty_Member_Portal`: Apex access `PortalActivityController` | Class access added |
| Site | Views `ziskejBody`, `profil`: `c:portalPlaceholder` → `c:portalEarnPoints` / `c:portalProfile` | Definition swapped |

Not changed: B1 metadata, B2 classes, `Loyalty_Member`, sharing set, other pages, `portalPlaceholder` (still used by Odměny / Moje vouchery).

## 3. How the requirements are met

| Requirement | Implementation |
| --- | --- |
| Server-side eligibility | Member resolved from `UserInfo` → `User.AccountId`; client sends only vehicle values or `true/false` |
| At most once | Unique `Unique_Key__c` + key check under lock; DB duplicate error swallowed as "already awarded" |
| Double click / retry / concurrency | `SELECT … FOR UPDATE` on the member Account (B2 `AccountSelector`) serializes requests; same consent state = no new event; UI disables actions while saving |
| Field-toggling exploit | Bonus key is per membership — clearing and refilling the profile or withdraw/regrant never awards again |
| Atomicity | One Apex transaction; any exception rolls back profile, consent, flag and ledger |
| Balance | Roll-up `Points_Balance__c` from the ledger (no direct balance write) |
| Czech + accessible feedback | Custom Labels with cs translation; status/alert roles; native inputs with labels |

## 4. Validation results (org `hackathon`)

| Check | Result |
| --- | --- |
| Deploy (ID `0Afaj00000qcuknCAA`) | Succeeded |
| Apex tests `PortalActivityControllerTest`, `PortalRegistrationServiceTest`, `PortalMemberControllerTest`, `PortalRegistrationControllerTest` | **11/11 passed** |
| Coverage | `PortalActivityService` 95 %, `PortalActivityController` 92 %, `PortalActivityDto` 100 %, `PortalBonusService` 79 %, `PortalAccountSelector` 82 %, `PortalRegistrationService` 92 % |
| LWC lint | Pass |
| Jest | Not added — B6 has no Jest suite; logic is covered server-side (only necessary tests) |
| Covered scenarios | incomplete → complete → edited profile (+100 once, key format); invalid year (nothing saved, translated message); grant / repeated grant / withdraw / re-grant (+50 once, events Accepted–Withdrawn–Accepted, balance 50); non-member code; registration with consent (+50, key format) |

Deviation from project standards (same as B6): `enehano-logger`, `dml` and `apex-mockery` are not installed in the org → `Database.*` with `AccessLevel`, `System.debug(LoggingLevel.ERROR, …)`, tests without mocks.

## 5. Deploy steps (default org)

```bash
D=force-app/main/default
V=$D/digitalExperiences/site/EneOil1/sfdc_cms__view
sf project deploy start --test-level RunSpecifiedTests \
  --tests PortalActivityControllerTest --tests PortalRegistrationServiceTest \
  --tests PortalMemberControllerTest --tests PortalRegistrationControllerTest \
  -d $D/classes/PortalActivityDto.cls -d $D/classes/services/PortalBonusService.cls \
  -d $D/classes/services/PortalActivityService.cls -d $D/classes/controllers/PortalActivityController.cls \
  -d $D/classes/controllers/PortalActivityControllerTest.cls -d $D/classes/selectors/PortalAccountSelector.cls \
  -d $D/classes/services/PortalRegistrationService.cls -d $D/classes/services/PortalRegistrationServiceTest.cls \
  -d $D/lwc/portalEarnPoints -d $D/lwc/portalProfile -d $D/labels -d $D/translations \
  -d $D/permissionsets/Loyalty_Member_Portal.permissionset-meta.xml -d $V/ziskejBody -d $V/profil
```

On an org without B2, deploy the four B2 classes first (`AccountSelector`, `PointLedgerSelector`, `LoyaltySettingsSelector`, `PicklistOptions`).

Then **publish the site** (Experience Builder → Publish) — not done yet.

## 6. Smoke test (after publish)

1. Register with marketing consent → ledger `MarketingBonus` +50, key `MEM:<id>:MARKETING`.
2. Získej body: profile activity open, marketing done.
3. Profil: save make only → "uloženo", no points; fill model, fuel, year → "+100 bodů"; edit again → no points.
4. Uncheck consent → "Souhlas byl odvolán…", balance unchanged; check again → no points.
5. Second member sees only own data; 360 px width.

## 7. Follow-ups

- Members who consented **before** B7 did not get +50 (no catch-up by decision). If needed later, a one-off script can award `MEM:<id>:MARKETING` to members whose latest Marketing consent event is `Accepted`.
- Marketing consent label in the portal is a Custom Label; the legal text is the `AuthorizationFormText` of the current Marketing form — keep them aligned (B6 follow-up still applies to the `[PLACEHOLDER]` texts).
- When the B2 branch is merged, the four copied classes are identical and merge without conflict.
- README "Working Record" sections can be filled from this document after review.

## 8. Najeto registration welcome email (2026-11-06)

**Status:** template deployed and selected as the site welcome email in org `hackathon` (2026-11-06). Real inbox delivery not yet verified.

### Delivered files

| File | Purpose |
| --- | --- |
| `force-app/main/default/email/unfiled$public/NajetoWelcome.email` | Czech HTML welcome email matching the supplied Najeto reference: dark ink, orange accents, text wordmark, account button and three QR-card onboarding steps |
| `force-app/main/default/email/unfiled$public/NajetoWelcome.email-meta.xml` | Classic Custom template settings, UTF-8 encoding, subject and equivalent plain-text body |
| `force-app/main/default/networks/EneOil.network-meta.xml` | `welcomeTemplate` changed from `unfiled$public/CommunityWelcomeEmailTemplate` to `unfiled$public/NajetoWelcome` (only change) |
| [HTML preview](../../email-templates/welcome-preview.html) | Browser preview with disabled account links |
| [Email setup notes](../../email-templates/README.md) | Design decisions, configuration instructions and inbox checks |

**Subject:** `Vítej v najeto. Tvoje cesta za odměnami začíná.`

The existing Experience Cloud welcome-email mechanism sends the message; no Apex sender or Flow was added. Salesforce replaces `{!Community_Url}` with the generated site URL at send time. The HTML uses tables and inline styles because email clients do not inherit LWC styles. The copy does not promise a points bonus or display fabricated member data. The greeting is generic to avoid missing-name and Czech name-inflection issues.

### Deployment

| Step | Result |
| --- | --- |
| Org check | Default org `hackathon` = Developer Edition (`IsSandbox = false`, not production) |
| Network in org vs. local | Retrieved `Network:EneOil` before the change — identical to local `EneOil.network-meta.xml`, so only `welcomeTemplate` was changed |
| Deploy (ID `0Afaj00000qd557CAA`, `NoTestRun`, no Apex) | Succeeded — `EmailTemplate unfiled$public/NajetoWelcome` created, `Network EneOil` changed |
| Verification | Re-retrieved network: `welcomeTemplate = unfiled$public/NajetoWelcome`, `sendWelcomeEmail = true`; template `Najeto - Welcome (CS)` active |

Deploy command (default org):

```bash
sf project deploy start --test-level NoTestRun \
  -d 'force-app/main/default/email/unfiled$public/NajetoWelcome.email-meta.xml' \
  -d force-app/main/default/networks/EneOil.network-meta.xml
```

The path is single-quoted so the shell keeps the literal `$public` folder name. Network settings take effect without site publish; publish is still needed for the B7 pages.

### Validation and risks

- Local inspection: balanced HTML tags, valid metadata XML, both account links use `{!Community_Url}`, and preview matches the HTML source except for disabled links.
- No tests were run, per repository instructions. No Apex changed, so no Apex tests were added.
- Deployment is verified; real inbox rendering remains unverified.
- **Delivery with B6 registration is unverified:** `PortalRegistrationService` calls the 3-argument `Site.createExternalUser(user, accountId, password)`. Whether Salesforce sends the welcome email for a user created with an explicit password must be checked by a real registration. If no email arrives, B6 needs the 4-argument variant with `sendEmailConfirmation = true` (code change, not done). Check a real development-org registration for delivery, one welcome message, resolved URL and login/password behavior; review mobile, Gmail, Apple Mail, Outlook and dark mode.
- QR checkout instructions follow the supplied reference; confirm the feature is available before selecting this template. No data model or seed-data change is required.
