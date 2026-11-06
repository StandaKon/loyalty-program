# B6 — Member Portal Foundation

**Status:** Draft  
**Phase:** Implementation II  
**Depends on:** B1, B2  
**Solution design references:** Chapters 8 and 13

## Objective

Create a secure, branded Experience Cloud portal in which a member can register, sign in, and view only their own loyalty information.

## Required Scope

- Configure an Experience Cloud site for Customer Community users.
- Implement self-registration that creates a Person Account and a User linked through `PersonContactId`.
- Provide login, navigation, logout, and recovery paths supported by the chosen site template/licence.
- Apply the EneOil brand kit, design tokens, typography, responsive behavior, and Czech user-facing copy.
- Provide Overview, point balance, point history, active campaigns (“Akce”), and navigation placeholders for rewards and vouchers.
- Build required LWCs and Apex controllers using secure sharing and field/object access checks.
- Configure sharing sets and access so a member sees only their own records.
- Handle empty, loading, and error states without exposing internal details.

## Decisions and Questions to Close

- Confirm site template, domain, licence, registration fields, and registration verification approach.
- Confirm exact pages, navigation, responsive layouts, and design source of truth.
- Confirm sharing-set mappings for every member-owned object.
- Confirm whether email verification, consent text, terms, and privacy links are required.
- Confirm campaign visibility rules and the point-history fields exposed to members.

## Expected Deliverables

- Experience Cloud site configuration and branding.
- Self-registration and member-user provisioning.
- Portal LWCs, Apex controllers, labels, navigation, and sharing configuration.
- Portal permission set/profile configuration.
- Security and functional test evidence.

## Definition of Ready

- UX, registration, licence, identity, sharing, and privacy decisions are reviewed with the AI assistant and approved.
- B1 and B2 data/service interfaces are stable.
- Detailed implementation and test steps are documented.

## Verification

- Register a new member and verify Person Account/User linkage and unique member number.
- Sign in as multiple members and prove strict record isolation.
- Verify balance, ledger history, campaigns, empty states, mobile layout, and Czech labels.
- Run Apex/controller tests and a manual Experience Cloud security review.

## Working Record

### 0. Current State (2026-11-06)

| Item | State |
| --- | --- |
| Site | `EneOil` (Network) / `EneOil1` (DigitalExperienceBundle), template **Build Your Own (LWR)**, status `UnderConstruction`, URL prefix `EneOilMembershipvforcesite` |
| Branding set | Applied: accent `#FFA41B` (text on it `#1D2C38`), text `#1D2C38`, link `#2D6E22`, background `#F6F7F8`; logo and pictures uploaded. Fonts are still template defaults |
| Pages | Template defaults only: Home, Login, Register, Forgot Password, Check Password, Error, News Detail, Service Not Available, Too Many Requests |
| Identity | Self-registration **off**, no self-reg profile, members = `admin` profile only, welcome email on |
| Language | Only `en_US`; Czech (`cs`) not yet added |
| Org | Person Accounts enabled; Customer Community / Customer Community Login profiles available |
| B1 dependency | **Not deployed** — no `Member_Number__c`, `Point_Ledger__c`, campaign object, `Voucher__c` in org; OP-06 (campaign storage) still open |
| Repo | Site metadata retrieved into `force-app/main/default` (`networks`, `sites`, `digitalExperiences`, `digitalExperienceConfigs`, `navigationMenus`) |

### 1. Final Assignment (proposal — awaiting approval)

**In scope**
1. Finish the existing LWR site `EneOil`: Czech as default language, EneOil fonts (Archivo / Noto Sans / Noto Sans Mono), mobile-first theme (360 px, tap targets ≥ 44 px), header with logo + navigation + logout, footer with terms/privacy links.
2. Self-registration on one screen (SD ch. 8): first name, last name, e-mail, password, terms consent (required), marketing consent (optional). Creates **Person Account + Customer Community User** linked via `PersonContactId`; `Member_Number__c` is assigned by B1 logic.
3. Login, forgot password, and logout using the LWR standard pages, with Czech copy.
4. Pages: **Přehled** (greeting, balance, progress to the nearest reward, last 5 movements, active Akce), **Historie bodů** (full ledger, newest first, paged), **Akce** (active campaigns). Navigation placeholders: **Získej body** (B7), **Odměny** and **Moje vouchery** (B8), **Profil** (B7).
5. LWCs + one `with sharing` Apex controller per area, using `WITH USER_MODE` queries and DTOs that expose only member-facing fields.
6. Portal permission set `Loyalty_Member` + profile `EneOil Member` (cloned from Customer Community User); sharing set on the member's own Account so Point Ledger (master-detail) and Vouchers are visible only to their owner.
7. Loading, empty, and error states with generic Czech messages (no exception text shown).
8. All member-facing text in Custom Labels (Czech), tykání tone, formats per SD ch. 13 (`1 240 bodů`, `+109`, `−500`, `6. 11. 2026`).

**Out of scope (other blocks):** portal activities and profile (B7), reward redemption and vouchers (B8), membership card with QR code (SHOULD — later), point engine (B2), data model (B1).

**Acceptance criteria**
- AC1: A new registration creates exactly one Person Account and one active User; `User.ContactId = Account.PersonContactId`; `Member_Number__c` is filled and unique.
- AC2: Member A cannot see member B's Account, ledger, or vouchers — not via the UI, Apex, or direct record URL/API.
- AC3: Přehled shows the correct balance (= roll-up of ledger) and the last 5 movements; Historie shows all movements of the member only.
- AC4: Akce shows only campaigns that are active and valid today, with member-facing text only.
- AC5: Every page works at 360 px width without horizontal scroll; all texts are Czech.
- AC6: An empty ledger, an empty campaign list, and an Apex error each show a friendly Czech state.
- AC7: Apex controller tests ≥ 90 % coverage, including a run-as portal user isolation test.

### 2. Resolved Open Points

| Question | Proposal | Decision | Approved by/date |
| --- | --- | --- | --- |
| Site template | Keep existing Build Your Own (LWR) | ❓ | |
| Domain / URL prefix | Rename `EneOilMembershipvforcesite` → `klub` while site is under construction | ❓ | |
| Licence / profile | Customer Community (named user); profile `EneOil Member` cloned from `Customer Community User` | ❓ | |
| Registration build | Custom LWC + Apex using `Site.createExternalUser` with no account → platform creates Person Account (Person Account record type set in Network self-reg settings) | ❓ | |
| Email verification | Off for MVP (member logs in immediately after registration); welcome email on | ❓ | |
| Terms / privacy links | Required checkbox with link to placeholder pages "Podmínky" and "Ochrana osobních údajů" (static text pages in site) | ❓ | |
| Consent storage | Terms + marketing consent with date stored on Person Account (fields from B1); +50 pts for marketing consent handled by B7 | ❓ | |
| Pages and navigation | Přehled · Historie bodů · Akce · Získej body* · Odměny* · Moje vouchery* · Profil* (*placeholder) | ❓ | |
| Design source of truth | SD ch. 13 tokens + brand kit; no separate Figma | ❓ | |
| Sharing set mappings | Account: `User.AccountId = Account.Id` (Read); Point_Ledger__c via master-detail (controlled by parent); Voucher__c: `User.AccountId = Voucher__c.Member__c` (Read); Loyalty_Transaction__c not exposed | ❓ | |
| Campaign visibility | Active = true AND Valid_From ≤ today ≤ Valid_To; exposed fields: name, member text, valid to. Read via Apex DTO (does not depend on OP-06 outcome) | ❓ | |
| Point-history fields | Date, type (translated), description/source label, points (+/−) | ❓ | |

### 3. Implementation Steps (draft)

1. **Prerequisite:** B1 objects/fields deployed (Person Account loyalty fields, `Point_Ledger__c`, campaign storage, `Voucher__c`). Until then, LWCs are built against agreed field API names and deployed after B1.
2. Site settings: add `cs` language as default, rename URL prefix, set self-reg profile + Person Account record type, enable self-registration, add `EneOil Member` to members.
3. Profile `EneOil Member` + permission set `Loyalty_Member` (read on Account loyalty fields, ledger, vouchers; Apex class access).
4. Sharing sets per section 2.
5. Custom Labels (Czech) for all portal text.
6. Apex: `PortalRegistrationController` (guest, validates input, `Site.createExternalUser`), `PortalMemberController` (balance, ledger, campaigns) + selectors; tests incl. `System.runAs` portal users.
7. LWCs: `portalRegistration`, `portalOverview`, `portalPointHistory`, `portalCampaigns`, shared `portalStateMessage` (loading/empty/error), placeholder page component.
8. Site pages, routes, navigation menu, theme fonts/header/footer; retrieve back into repo.
9. Deploy to the default org, run Apex tests, manual security review (guest user access, direct URL access, API access as portal user).
10. Record results in section 4; suggest seed data (portal test members) for `/data`.

### 4. Implementation and Test Results

_Record components, security checks, test results, deviations, and follow-up work._
