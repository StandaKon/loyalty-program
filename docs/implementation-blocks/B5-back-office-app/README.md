# B5 — Back-Office Application

**Status:** In progress  
**Phase:** Implementation II  
**Depends on:** B1  
**Solution design reference:** Chapter 9

## Objective

Provide loyalty managers and back-office users with a focused Lightning application for managing members, campaigns, rewards, vouchers, and operational exceptions.

## Required Scope

- Create the “EneOil Klub” Lightning application with appropriate navigation and branding.
- Create a member 360-degree record page showing membership data, balance, transactions, ledger history, vouchers, and relevant actions.
- Provide list views for operational work and exception handling.
- Provide safe campaign and reward management experiences based on the B1 configuration model.
- Add the SHOULD manual-point-adjustment action only if approved; require reason, audit trail, and appropriate permission.
- Add validation and help text that prevents invalid campaign or reward configuration.
- Apply least-privilege access for loyalty manager and back-office personas.
- Use Czech Custom Labels for user-facing text.

## Decisions and Questions to Close

- Confirm persona permissions and which records each role may edit.
- Confirm whether manual point adjustment is in scope and its approval/audit rules.
- Confirm required list views, highlights, quick actions, and operational error queues.
- Confirm whether a dedicated campaign/reward wizard is needed or standard pages are sufficient.

## Expected Deliverables

- Lightning application metadata.
- Member, campaign, reward, voucher, and related FlexiPages as approved.
- List views, actions, labels, and permission-set updates.
- Manual-adjustment automation and audit behavior if included.
- Admin/operator usage notes and functional test results.

## Definition of Ready

- Personas, screen content, edit rights, and SHOULD scope are reviewed with the AI assistant and approved.
- B1 data and security contracts are stable.
- Detailed component and test steps are documented.

## Verification

- Test each persona’s navigation, visibility, edit rights, and restricted actions.
- Verify the member 360-degree view with representative data.
- Verify campaign/reward validation and effective dates.
- If included, verify positive/negative adjustments, insufficient-balance behavior, reason capture, and ledger audit.

## Working Record

### 1. Final Assignment

**Goal:** Loyalty managers and back-office users run the whole program from one focused Lightning app "Najeto": they see a member 360° view, resolve complaints without leaving the member record, work operational queues, and configure campaigns and rewards safely, without a developer.

**Personas**
- *Loyalty manager* (`Loyalty_Manager`): full back-office work, member status, manual point adjustment, voucher cancellation, campaign and reward configuration.
- *Back office* (`Loyalty_Back_Office`): reads program data, edits member contact and vehicle data, simulates purchases.
- *EneServis operator* is **not** an app user; voucher verification is a narrow B8 action.

**Scope**
1. Lightning app "Najeto" (Manager + Back Office): Home · Accounts · Transactions · Point Ledger · Campaigns · Rewards · Vouchers · Reports · Dashboards. No Stations tab (D12 deferred). Brand header colour and NAJETO logo.
2. Member 360° record page (org default for Person Account): highlights (Member Number, Membership Status, Points Balance, Joined At, Profile Complete, Marketing Consent); tabs Point Ledger · Transactions · Vouchers · Consents · Details; standard Dynamic Related Lists only.
3. Member actions: *Manual point adjustment* (LWC, Manager only), *Change membership status* (quick action, Manager only), *Edit profile* (quick action, contact + vehicle, Manager + BO), *Simulate purchase* (LWC, Manager + BO, Active members only).
4. Voucher action *Cancel voucher* (LWC, Manager only): `Issued → Cancelled` + `Refund` ledger entry.
5. List views (shared with all internal users): see decision table.
6. Campaign/reward record pages (Dynamic Forms sections), help texts on configuration fields, Apex lock of calculation fields of a campaign after first use.
7. Czech UI: base metadata in English, `cs` object translations, Custom Labels for LWC/Apex texts; back-office tone is factual, no "tykání".

**Out of scope:** campaign/reward wizard, changes to existing validation rules, approval process for adjustments, operator voucher verification (B8), CSV import (B3), Stations.

**Acceptance criteria**
- Each persona sees only the permitted tabs, fields and actions; restricted actions are hidden and rejected server-side.
- Manual adjustment: positive/negative entry with category + comment, deduction above balance rejected, 0 rejected, ledger entry `Adjustment` with `ADJ:<uuid>` key; double-click creates one entry.
- Voucher cancellation: only `Issued` vouchers, category required, exactly one `Refund` (`VCH:<id>:REFUND`) with `Reverses_Entry__c`, balance restored.
- Simulate purchase: produces the same result as an imported transaction (T01 = 109 points) and shows base/bonus/total or the processing error.
- Campaign used by any `CampaignBonus` entry rejects changes of condition, threshold, reward type/value and dates; name, description and enable flag remain editable.

**Testing:** functional persona tests in the org per Verification; no Apex unit tests and no Jest tests in this block (owner decision). Note: production deployment would require ≥ 75 % Apex coverage.

### 2. Resolved Open Points

| Question | Decision | Approved by/date |
| --- | --- | --- |
| Branch / prerequisites | B1 merged to `master` (PR #3) and merged into the working branch. B1 objects and permission sets verified in the default org (`LOYALTY`). | Stanislav Konopásek, 2026-11-06 |
| App personas | App assigned to `Loyalty_Manager` and `Loyalty_Back_Office`. EneServis operator excluded (B8 narrow action, no member data). | Stanislav Konopásek, 2026-11-06 |
| Back-office edit rights | BO gets Edit on Account limited by FLS to contact (`PersonEmail`, `PersonMobilePhone`) and vehicle fields. Member number, status, balance, consents stay read-only. | Stanislav Konopásek, 2026-11-06 |
| Membership status | Only Manager may change `Membership_Status__c` (FLS + quick action visibility). | Stanislav Konopásek, 2026-11-06 |
| Manual adjustment – scope & rights | In scope (SHOULD). Manager only via new custom permission `Loyalty_Adjust_Points`, checked in UI and Apex. | Stanislav Konopásek, 2026-11-06 |
| Manual adjustment – reason | New field `Point_Ledger__c.Adjustment_Category__c` (restricted picklist `Complaint`, `ImportError`, `Goodwill`, `Other`), required for `Adjustment`; `Reason__c` holds the required comment. | Stanislav Konopásek, 2026-11-06 |
| Manual adjustment – technology | LWC quick action + Apex service (account lock `FOR UPDATE`, balance check, `ADJ:<uuid>` key). | Stanislav Konopásek, 2026-11-06 |
| Manual adjustment – approval | No approval and no limit. Immediate write; audit = immutable ledger entry (author, time, category, comment). Deduction max. up to balance, 0 not allowed. Allowed also for Blocked/Cancelled members (controlled corrections per B1). | Stanislav Konopásek, 2026-11-06 |
| Member 360 – highlights | Member Number, Membership Status, Points Balance, Joined At, Profile Complete, Marketing Consent. | Stanislav Konopásek, 2026-11-06 |
| Member 360 – layout | Tabs Point Ledger · Transactions · Vouchers · Consents · Details, standard components only (no summary LWC). | Stanislav Konopásek, 2026-11-06 |
| Member 360 – assignment | Org default for Person Account record type. | Stanislav Konopásek, 2026-11-06 |
| Member actions | Manual adjustment, Change membership status, Edit profile (+ Simulate purchase, see below). | Stanislav Konopásek, 2026-11-06 |
| Voucher cancellation | Implemented fully in B5 (LWC quick action + Apex, Manager only); B8 reuses it. | Stanislav Konopásek, 2026-11-06 |
| Cancellation reason | New field `Voucher__c.Cancellation_Category__c` (restricted picklist `MemberRequest`, `IssuedInError`, `PartnerUnavailable`, `ProgramEnded` per B8 spec), required; existing `Cancellation_Reason__c` becomes an optional comment. | Stanislav Konopásek, 2026-11-06 |
| List views | Members: *New registrations (last 7 days)*, *Blocked members*. Transactions: *Transactions with error*, *Pending transactions*. Vouchers: *Issued vouchers*, *Voucher e-mail error*. Campaigns: *Active campaigns*. Rewards: *Active rewards*. Point Ledger: *Manual adjustments*. Plus one "All …" view per object (*Všichni členové*, *Všechny transakce*, *Všechny pohyby bodů*, *Všechny kampaně*, *Všechny odměny*, *Všechny vouchery*). Labels in Czech. Shared with all internal users. | Stanislav Konopásek, 2026-11-06 |
| Campaign/reward wizard | Not needed; standard record pages with Dynamic Forms sections. | Stanislav Konopásek, 2026-11-06 |
| Campaign lock after first use | Apex before-update check: if any `CampaignBonus` ledger entry references the campaign, changes of `Condition_Field__c`, `Threshold__c`, `Reward_Type__c`, `Reward_Value__c`, `Start_Date__c`, `End_Date__c` are rejected. | Stanislav Konopásek, 2026-11-06 |
| Validation rules | Existing B1 validation rules stay unchanged; no new VRs. | Stanislav Konopásek, 2026-11-06 |
| Help texts | Added to campaign and reward configuration fields. | Stanislav Konopásek, 2026-11-06 |
| Navigation & branding | Standard tabs without Stations; header colour Navy `#1D2C38` (brand kit `ink`); app logo = provided NAJETO logo ([NAJETO_logo_transparentni.png](NAJETO_logo_transparentni.png), resized, uploaded as ContentAsset). | Stanislav Konopásek, 2026-11-06 |
| Brand colours | All colours from the brand kit tokens (`brand/eneoil-tokens.css`), which match the logo exactly. App header `ink` `#1D2C38`. LWC quick actions use SLDS styling hooks mapped to tokens: primary button `brand` `#FFA41B` with `on-brand` `#1D2C38` text (never white on orange), added points `plus` `#2D6E22`, deducted points/errors `minus` `#B4382A`, info boxes `brand-soft` `#FFF1DB` / `green-soft` `#E8F3E4`, muted text `ink-muted` `#505F6B`. Fonts stay SLDS defaults in back office. | Stanislav Konopásek, 2026-11-06 |
| App name | App label "Najeto" (API `Najeto`), aligned with the program name NAJETO from B8 and the logo (changed from the original "EneOil Klub"). | Stanislav Konopásek, 2026-11-06 |
| Czech language | English base metadata + `cs` objectTranslations (objects, fields, picklists, help texts, VR messages); Custom Labels for LWC and Apex texts. | Stanislav Konopásek, 2026-11-06 |
| Simulate purchase | Moved from B3 to B5. LWC quick action on member, Manager + BO, Active members only; POS ID generated server-side (`SIM:<uuid>`); B2 engine processes it via the existing trigger; result (base/bonus/total or error) shown. | Stanislav Konopásek, 2026-11-06 |

### 3. Implementation Steps

1. **Data model additions:** `Point_Ledger__c.Adjustment_Category__c`, `Voucher__c.Cancellation_Category__c`; custom permission `Loyalty_Adjust_Points`; help texts on campaign/reward fields.
2. **Security:** update `Loyalty_Manager` (adjust permission, new field FLS, status edit) and `Loyalty_Back_Office` (Account Edit + contact/vehicle FLS, new field read); app visibility for both permission sets.
3. **Apex (services/selectors/controllers):** `PointAdjustmentService` (+ controller), `VoucherCancellationService` (+ controller), `PurchaseSimulationService` (+ controller), campaign lock handler on `Loyalty_Campaign__c` following the existing trigger pattern.
4. **LWC quick actions:** `pointAdjustmentAction`, `voucherCancelAction`, `purchaseSimulationAction` (Custom Labels for all texts).
5. **Quick actions:** `Account.Change_Membership_Status`, `Account.Edit_Member_Profile`, plus LWC action definitions.
6. **Compact layouts & FlexiPages:** Person Account compact layout; Member 360 record page; Campaign, Reward, Voucher, Transaction record pages.
7. **List views** as per decision table.
8. **App:** `Najeto` CustomApplication, logo (ContentAsset), header colour, navigation, FlexiPage assignment.
9. **Translations & labels:** `cs` objectTranslations and Custom Labels.
10. **Deploy** to the default org, assign permission sets, run functional persona tests (Verification), record results in section 4.

### 4. Implementation and Test Results

**Deployed to the default org (`LOYALTY`, Developer Edition) on 2026-11-06.**

| Area | Components |
| --- | --- |
| Data model | `Point_Ledger__c.Adjustment_Category__c`, `Voucher__c.Cancellation_Category__c`, help texts on 8 campaign and 6 reward fields, custom permission `Loyalty_Adjust_Points` |
| Apex | Services `PointAdjustmentService`, `VoucherCancellationService`, `PurchaseSimulationService`, `LoyaltyCampaignService`; selectors `PointLedgerSelector`, `VoucherSelector`, `LoyaltyTransactionSelector` (shared with B3), `AccountSelector.getMemberByIdForUpdate`; controllers `PointAdjustmentController`, `VoucherCancellationController`, `PurchaseSimulationController`, `LoyaltyControllerErrors`; helpers `PicklistOptions`, `LoyaltyPermissions`, `LoyaltyActionException`; trigger `LoyaltyCampaignTrigger` + `LoyaltyCampaignTriggerHandler` |
| LWC | `pointAdjustmentAction`, `voucherCancelAction`, `purchaseSimulationAction`, shared `loyaltyActionUtils`, `loyaltyBrandStyles` (brand tokens via SLDS styling hooks) |
| UI | Quick actions `Account.Manual_Point_Adjustment`, `Account.Simulate_Purchase`, `Account.Change_Membership_Status`, `Account.Edit_Member_Profile`, `Voucher__c.Cancel_Voucher`; compact layout `PersonAccount.Loyalty_Member`; record pages `Loyalty_Member/Voucher/Campaign/Reward/Transaction_Record_Page` (org default View overrides); Person Account layout related lists; 9 list views; app `Najeto` with logo asset `Najeto_Logo` |
| Security | `Loyalty_Manager` (app, 3 controllers, `Loyalty_Adjust_Points`, new fields), `Loyalty_Back_Office` (app, simulation controller, Account/Contact Edit, vehicle + e-mail/mobile FLS edit, new fields read) |
| Language | 56 Custom Labels (en_US base) + `cs` translations of all program labels, quick actions, object/field labels, picklists, help texts and validation messages |

**Smoke test** – [scripts/apex/b5-back-office-smoke.apex](../../../scripts/apex/b5-back-office-smoke.apex), run as `Loyalty_Manager`, all changes rolled back: **14/14 PASS**.

| ID | Scenario | Result |
| --- | --- | --- |
| A1–A2 | +100 points; replay of the same request key | Balance +100; replay creates no second entry |
| A3–A6 | Deduction above balance, 0 points, invalid category, missing comment | All rejected with the Czech/English label message |
| A7 | −40 points | Balance updated |
| B1 | Simulated purchase 45 l / 1 710 + 180 CZK with a 5-point campaign | Processed: base 45 + 9, campaign 5, total 59 (same as B2 engine) |
| B2 | Litres without fuel amount | Rejected |
| C1–C2 | Threshold change / rename of a campaign with awarded points | Change rejected; rename allowed |
| D1–D2 | Cancel issued voucher (50 points); cancel again | Status Cancelled, +50 refund, reason = category label; second attempt rejected |
| E1 | Simulation for a blocked member | Rejected |

**Not yet verified:** UI click-through of the three LWC actions, and persona tests with a dedicated Back Office user (no such user exists in the org). Lint was not run (`node_modules` not installed); Apex and Jest unit tests are out of scope by decision.

**Deviations from the approved design**
1. *Edit profile* quick action covers vehicle fields only (label "Edit Vehicle"): Salesforce does not allow person contact fields (`PersonEmail`, `PersonMobilePhone`) in quick action layouts. Back office edits e-mail and mobile via standard Edit, controlled by FLS.
2. *Consents* related list is not possible: `AuthorizationFormConsent.ConsentGiverId` is polymorphic and has no related list on Account. Follow-up: small read-only LWC.
3. Member 360 page uses the CLI template tabs (Related · Details · Activity); point ledger, transactions, vouchers and field history are related lists of the Person Account layout, sorted by business date. Only the header action list of the generated pages was extended (dynamic actions with visibility rules).
4. Record page assignment is the org default for the whole Account object (object-level override cannot target a record type without profiles), so the partner Business Account also uses the member page.
5. The compact layout must live under the `PersonAccount` object; an unused `Account.Loyalty_Member` compact layout remains in the org from a first deploy attempt (removal needs a destructive deploy).
6. Manager-only actions (adjust points, change membership status, cancel voucher) share the custom permission `Loyalty_Adjust_Points`.
7. When no comment is given, `Cancellation_Reason__c` and the refund `Reason__c` get the category label, because B1 validation rules require them.
8. List view labels are written directly in Czech (owner decision, exception from English base metadata). Other active org users keep language `en_US`, so Czech translations show only for users switched to Czech.
10. Org theme `NAJETO` (BrandingSet + LightningExperienceTheme, activated via LightningExperienceSettings): brand colour `#FFA41B`, page background `#F6F7F8`, NAJETO logo. Applies org-wide; app Najeto now uses the org theme (`shouldOverrideOrgTheme=false`). Owner accepted white text on orange despite low contrast against the brand kit rule.
9. The working directory also contained parallel B3 work (`PosTransactionService`, `PosTransactionRestResource`); it was deployed together with the B5 classes, and `LoyaltyTransactionSelector` now serves both blocks (`getById`, `getByPosTransactionId`).

**Rerun in Czech (2026-11-06):** user Stanislav Konopásek switched to language `cs` and assigned `Loyalty_Back_Office` in addition to `Loyalty_Manager` (no dedicated persona users due to licences). Smoke test 14/14 PASS with Czech messages; custom permission, app visibility and Czech object, field, picklist and label translations verified. UI click-through is done by the owner.

**Extension – manager home dashboard (approved 2026-11-06)**
- Scope: KPI tiles, to-do queue, 6-month points chart, top campaigns and recent manual adjustments; period switch (this month / last month / last 30 days / this year) compared with the previous period of the same length; Europe/Prague business dates; home page as app default in Najeto (Tab override for `standard-home`).
- Components: `LoyaltyDashboardSelector` (without sharing, aggregates only), `LoyaltyDashboardService`, `LoyaltyDashboardController` (cacheable); LWC `najetoManagerDashboard` + `najetoPointsChart` (SVG, legend, hover tooltip, table view; colours `#2D6E22` / `#E8901A` validated for CVD); FlexiPage `Najeto_Home_Page` (dashboard, list view cards *Transakce s chybou*, *Vydané vouchery*, *Nové registrace*, recent items); 43 dashboard Custom Labels with `cs` translations.
- Verified: service returns data for all four periods in the org (≈22 SOQL per call).
- **Pending:** `Loyalty_Manager` permission set (class access `LoyaltyDashboardController`) is not deployed, because the file now also contains parallel B8 field permissions (`Reward__c.Available_From__c`, `Available_Until__c`, `Voucher__c.Service_Location__c`, `Service_Order_Number__c`) for fields not yet in the org, placed before `applicationVisibilities` (invalid order). Deploy together with B8 after moving those lines below `description`. Users with `Loyalty_Back_Office` already have access.

**Follow-up**
- Persona separation (Back Office without Manager) can only be verified with a user holding `Loyalty_Back_Office` alone.
- Consents LWC on the member page; optional destructive removal of `Account.Loyalty_Member` compact layout.
- Seed data (B4): include rewards, a partner and vouchers so voucher cancellation can be demonstrated.
