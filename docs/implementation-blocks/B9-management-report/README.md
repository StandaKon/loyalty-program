# B9 — Management Report

**Status:** Ready  
**Phase:** Implementation II  
**Depends on:** B4 test data  
**Solution design reference:** Chapter 10  
**Open points:** OP-11, OP-09

## Objective

Provide Petra Králová and management with a read-only report based on Salesforce data for monitoring membership, point redemption, reward/partner budgets, and campaign performance.

## Required Scope

- Connect the Claude artifact to Salesforce using the approved secure read-only approach.
- Report member count and new registrations over a selected period.
- Report points earned, redeemed, and redemption rate using an explicitly documented formula.
- Report popular partners and rewards.
- Track issued voucher CZK value against partner budget.
- Show campaign participation and awarded points using measures that can be supported by the available data.
- Provide a CFO-oriented budget projection with documented assumptions.
- Provide filters, refresh timestamp, empty/error states, and clear metric definitions.
- Use a least-privilege integration user and avoid exposing personal member data unless explicitly required.
- Provide an approved fallback, such as Salesforce reports/dashboard or export, if live connectivity is unavailable.

## Decisions and Questions to Close

- **OP-11:** Select the supported Salesforce connection method, authentication, refresh model, and fallback.
- **OP-09:** Confirm reward values, partner budgets, and whether budget is informational or enforced.
- Define each KPI formula, grain, date basis, and time zone.
- Define “average percentage of points redeemed” and the CFO projection method.
- Define campaign-performance measures that are valid without external sales-impact data.

## Expected Deliverables

- KPI/data contract and source-field mapping.
- Read-only connection/integration configuration.
- Management report artifact with filters and explanatory labels.
- Fallback reporting approach.
- Reconciliation and stakeholder acceptance evidence.

## Definition of Ready

- OP-11, OP-09, KPI definitions, security, and fallback are reviewed with the AI assistant and approved.
- B4 provides representative and reconciled data.
- Detailed implementation and validation steps are documented.

## Verification

- Reconcile every KPI against direct Salesforce queries or approved reports.
- Test date filters, no-data cases, stale/error connection states, and access restrictions.
- Confirm that campaign metrics do not claim sales impact that the solution cannot measure.
- Review budget projection assumptions with the business owner.

## Working Record

### 1. Final Assignment

> **Approved 2026-11-06** (decisions in section 2; prepared from SD ch. 10, `context.md` FR-E9-01 to FR-E9-08, B1 spec ch. 7 and the deployed B1 metadata).

**Goal:** A read-only Claude artifact for Petra Králová that reads live Salesforce data through the claude.ai Salesforce connector and answers three questions: how the program is developing, how much the partner vouchers cost against budget (CFO), and which campaigns to repeat (Marketing).

**In scope (MUST):**

| Area | Content | Requirement |
| --- | --- | --- |
| Connection | Live read through the Salesforce connector, refresh button, last-refresh timestamp, empty/error/stale states | FR-E9-01 |
| Membership | Members total, new registrations in the period + trend by week/month | FR-E9-02 |
| Points | Points earned (split by source), points redeemed, redemption rate for the period and cumulative since launch, outstanding balance in points and CZK | FR-E9-02 |
| Rewards | Vouchers issued per reward: count, points, CZK value, share redeemed at the service | FR-E9-02 |
| Voucher budget | CZK value of issued vouchers by reward, cumulative for the year vs. partner annual budget (% used, year-end estimate) | FR-E9-03 |
| Campaigns | Per campaign: period, qualifying transactions, share of all member transactions, unique members, bonus points, estimated CZK cost, average qualifying vs. other transaction value + explicit "indicative only, no sales impact" note | FR-E9-04 |
| CFO panel | Average redemption rate, weighted CZK value per point, next-year projection with visible formula and inputs, low/expected/high scenarios (SHOULD) | FR-E9-05 |
| UX | Period filter (month, quarter, year, custom), comparison with previous period, KPI definitions shown in the report, brand kit "Manažerský report", laptop + tablet without horizontal scroll | FR-E9-02, FR-E9-07 |
| Fallback | Standard Salesforce reports + dashboard in a folder shared with the Reporting role | Block scope |

**SHOULD if time allows:** active members (≥ 1 transaction in the last 90 days), engagement (share of members with a complete profile and with marketing consent, activity points; FR-E9-06).

**Out of scope:** sales impact of campaigns, historical membership status as of a date, historical budget values, per-station reporting (`Station__c` does not exist), expiration/tier metrics (FR-E9-08, only if B11 is delivered), any member-level personal data in the artifact.

**Assumptions:**

- B4 loads 12 months of history (300 members, 5 000 transactions, 2–3 campaign runs, 60–80 vouchers) with business dates set (`Joined_At__c`, `Purchased_At__c`, `Occurred_At__c`, `Issued_At__c`).
- The claude.ai Salesforce connector can query custom objects with aggregate SOQL (to be verified in step 2).
- For the hackathon demo the connector is connected as the admin/developer user (decision 2); the dedicated `Loyalty_Reporting` user is the production target.

**Acceptance criteria:**

1. After a new transaction is processed and the report is refreshed, the affected KPIs change, and every KPI matches its control SOQL query (section KPI data contract).
2. "Sleva 200 Kč na přezutí": issued count × 200 CZK = displayed value.
3. The redemption rate is computed from point totals, not averaged monthly percentages, and shows "—" with a zero denominator.
4. The CFO formula and all its inputs are visible in the report.
5. The campaign section explicitly states that transaction-value comparison is indicative (no control group, no non-member sales).
6. An empty period, a connector error and a not-connected connector each show a clear state instead of zeros.
7. The artifact does not query member names, emails or member numbers (the read-only user restriction is a production item, see decision 2).

#### KPI data contract

Rules for all KPIs: periods are evaluated in `Europe/Prague`; always use the business date, never `CreatedDate`; amounts are whole points / CZK.

| KPI | Source and formula | Date basis |
| --- | --- | --- |
| Members total | `COUNT(Account)` where `Member_Number__c != null AND Joined_At__c <= period end AND Membership_Status__c = 'Active'` (current status; deviation from FR-E9-02, see decision 8) | `Joined_At__c` |
| New registrations | `COUNT(Account)` with `Member_Number__c != null`, grouped by week/month | `Joined_At__c` |
| Points earned | `SUM(Point_Ledger__c.Points__c)` where `Entry_Type__c IN ('PurchaseBase','CampaignBonus','ProfileBonus','MarketingBonus')`. Source split: fuel = `SUM(Loyalty_Transaction__c.Base_Fuel_Points__c)`, till = `SUM(Base_Other_Points__c)` (both on `Processing_Status__c = 'Processed'` transactions, by `Purchased_At__c`), campaigns = `CampaignBonus` by `Campaign__c`, activities = `ProfileBonus` + `MarketingBonus`. `Adjustment` is reported separately and not added to earned points. | `Occurred_At__c` |
| Points redeemed | `ABS(SUM(Points__c))` for `Redemption` minus `SUM(Points__c)` for `Refund` | `Occurred_At__c` |
| Redemption rate | Points redeemed / points earned in the same period; cumulative variant since launch. Empty when the denominator is 0; may exceed 100 %. | `Occurred_At__c` |
| Outstanding balance | `SUM(Account.Points_Balance__c)` of members; CZK = points × weighted point value | Now |
| Weighted point value (CZK/point) | `SUM(Voucher__c.Value_CZK__c) / SUM(Voucher__c.Points_Spent__c)` over non-cancelled vouchers since launch | `Issued_At__c` |
| Vouchers by reward | `COUNT`, `SUM(Points_Spent__c)`, `SUM(Value_CZK__c)` grouped by `Reward__c` (and `Partner__c`); redeemed share = `Status__c = 'Redeemed'` / non-cancelled | `Issued_At__c` |
| Voucher budget | `SUM(Value_CZK__c)` of vouchers with `Status__c != 'Cancelled'` issued in the budget year, per partner, vs. `Account.Voucher_Budget_CZK__c` for `Voucher_Budget_Year__c`. Cancelled value shown separately. Nominal value, not the settled partner cost. Year-end estimate = YTD value / elapsed days × days in year. | `Issued_At__c` |
| Campaign performance | `CampaignBonus` grouped by `Campaign__c`: `COUNT_DISTINCT(Transaction__c)`, `COUNT_DISTINCT(Member__c)`, `SUM(Points__c)` (zero bonuses count as qualifying); share = qualifying / all processed transactions in the campaign period; cost = bonus points × weighted point value; average `Total_Amount__c` of qualifying vs. other transactions | `Occurred_At__c` / `Purchased_At__c` |
| CFO projection | Average monthly earned points (last 12 full months) × 12 × cumulative redemption rate × weighted point value. Scenarios: rate −10 pp / expected / +10 pp. | Last 12 months |
| Campaign runs | Runs grouped by `Loyalty_Campaign__c.Name` for the repeated-campaign comparison | `Start_Date__c` |
| Last refresh | Time the artifact received the connector response (shown with `Europe/Prague` time) | — |

### 2. Resolved Open Points

| # | ID/question | Decision | Approved by/date |
| --- | --- | --- | --- |
| 1 | OP-11 Connection | The artifact uses the `mcp` capability with the official claude.ai **Salesforce** connector (`dispatch_readonly`, plus `describe`/`discover` if needed). Calls run under the OAuth credentials of whoever connected the connector, and tokens never reach the page. Refresh = on open + manual refresh button, with the last-refresh timestamp shown. **Pre-condition:** the spike in step 2 proves that custom objects and aggregate SOQL work. **Plan B (demo only):** local Salesforce DX MCP server declared as a `host:` server (works only in the Claude desktop app with an authenticated `sf` CLI). **Fallback:** Salesforce reports + dashboard "EneOil Klub – Management" (operational backup, not a replacement for the artifact). | Stanislav Konopasek, 2026-11-06 |
| 2 | OP-11 Report user | **Demo deviation:** the connector is connected as the admin/developer user. This does **not** meet the least-privilege requirement and does not prove that the report works with restricted rights. Mitigation: the artifact queries only aggregates and never member names, emails or member numbers. Production target: a dedicated report user with only `Loyalty_Reporting` + API Enabled (documented, not built in the hackathon). | Stanislav Konopasek, 2026-11-06 |
| 3 | OP-09 Free inspection value | "Servisní prohlídka zdarma" (5 000 points) = **2 000 CZK**, aligned with the B8 specification (`specifikace_b8-marketingove-zadani-odmeny.md`, R-01, R-02), which closed OP-09. Uniform point value of 0.40 CZK (the 1 200-point reward is 0.42 CZK). | Stanislav Konopasek, 2026-11-06 |
| 4 | OP-09 Budget | Annual budget for partner EneServis = **100 000 CZK** for the program year, stored on the partner Account (`Voucher_Budget_CZK__c`, `Voucher_Budget_Year__c`, set by B4 seed). **Informational only:** the report shows % used, trend and year-end estimate; redemption is not blocked. | Stanislav Konopasek, 2026-11-06 |
| 5 | Redemption rate | Ratio of totals: redeemed points (`Redemption` − `Refund`) / earned points (`PurchaseBase` + `CampaignBonus` + `ProfileBonus` + `MarketingBonus`) in the same period, plus a cumulative variant since launch (used for the CFO panel). "—" for a zero denominator; may exceed 100 %. | Stanislav Konopasek, 2026-11-06 |
| 6 | CFO projection | Average monthly earned points (last 12 full months) × 12 × cumulative redemption rate × weighted point value (`SUM(Value_CZK__c) / SUM(Points_Spent__c)` of non-cancelled vouchers). Formula and inputs visible. **Three scenarios:** low (rate −10 pp), expected (actual rate), high (rate +10 pp). | Stanislav Konopasek, 2026-11-06 |
| 7 | Campaign measures | Full FR-E9-04 set: qualifying transactions, share of all member transactions in the campaign period, unique members, bonus points, estimated cost in CZK, average transaction value qualifying vs. other, with a prominent "indicative only, no control group, no non-member sales" note. | Stanislav Konopasek, 2026-11-06 |
| 8 | Members total "as of period end" | Members with `Joined_At__c` ≤ end of period **and** current `Membership_Status__c = 'Active'`. Deviation from FR-E9-02: members blocked or cancelled after the period end are not counted for that period (no status history in B1). The report and this README state the deviation. | Stanislav Konopasek, 2026-11-06 |
| 9 | Repeated campaigns | Runs of the same campaign are grouped by `Loyalty_Campaign__c.Name` (exact match). **Naming convention:** every run of a campaign has the same business name without run suffix or block prefix (`Natankuj plnou`, `Zastávka na cestě`); runs are distinguished by `Start_Date__c`/`End_Date__c`. B4 seed renames the existing `B3 - … - 2026-10` records and creates 2–3 historical runs per campaign. No data model change. Risk of typos in names is noted in the report's KPI definitions. | Stanislav Konopasek, 2026-11-06 |

### 3. Implementation Steps

1. **Approve the assignment.** Close OP-11, OP-09 and the open questions above; set status to `Ready`.
2. **Connector spike (D4).** Connect the claude.ai Salesforce connector to the org with B4 data; verify `dispatch_readonly` returns results for `Point_Ledger__c`, `Voucher__c`, `Loyalty_Transaction__c` and aggregate queries (`SUM`, `COUNT_DISTINCT`, `GROUP BY`, date functions). Record the request/response shape. If it fails, switch to plan B and record the deviation.
3. **Security check.** Connect the connector as the admin/developer user (decision 2). Verify that the artifact queries contain no name, email or member number fields. Describe the production setup (dedicated user with only `Loyalty_Reporting` + API Enabled) in section 4.
3a. **Seed alignment (B4/B8).** Make sure seed data has `Reward__c.Value_CZK__c = 2000` for the free inspection, `Voucher_Budget_CZK__c = 100000` with the program year on EneServis, campaign runs named exactly `Natankuj plnou` and `Zastávka na cestě` (rename the existing `B3 - … - 2026-10` records) with 2–3 historical runs each, at least one `Reward__c` set (500/1 200/5 000 points) with 60–80 vouchers, and 12 months of transactions.
4. **Control queries.** One SOQL per KPI in [`kpi-queries.md`](kpi-queries.md) (K01–K20 + derived formulas); run them all with `scripts/bash/b9-kpi-queries.sh [start] [end] [campaign] [year]` against the default org and record the expected values once B4 data is final.
5. **Artifact.** Build the page with the `mcp` capability (`Salesforce`: `dispatch_readonly`): period filter + previous-period comparison, KPI cards, trends, voucher budget, campaign table, CFO panel with formula, KPI definitions, last-refresh timestamp, empty/error/not-connected states, brand kit "Manažerský report" (FR-E9-07).
6. **Fallback.** Create report folder "EneOil Klub – Management" (shared with the Reporting role), reports for members, points by entry type, vouchers by reward and campaign bonuses, and one dashboard.
7. **Reconciliation and tests.** Compare every artifact KPI with step 4; process a new transaction, refresh, confirm the change; test empty period, connector error/disconnected, and access restrictions; check that campaign metrics carry the indicative note.
8. **Stakeholder review.** Walk Petra (and the CFO view) through the projection assumptions; record acceptance and deviations in section 4.

### 4. Implementation and Test Results

_Record artifact/configuration, reconciliations, stakeholder results, deviations, and follow-up work._

#### 2026-11-06: Step 2 connector spike (plan B, `sf` CLI)

**Connector status:** the claude.ai Salesforce connector could not be used: after the user connected it, the connector registry still showed it as not connected and the session could not enable it. The spike therefore ran the same SOQL through the local `sf` CLI against the project default org (`LOYALTY`). **The connector itself is still unverified** and must be re-tested before the artifact is built.

| # | Check | Result |
| --- | --- | --- |
| 1 | Read custom object `Point_Ledger__c` | OK |
| 2 | `SUM` / `COUNT` with `GROUP BY Entry_Type__c` | OK (`PurchaseBase` 6 725 / 263, `CampaignBonus` 215 / 8, `MarketingBonus` 50 / 1) |
| 3 | `CALENDAR_YEAR/MONTH(convertTimezone(Occurred_At__c))` grouping | OK (Sep 217, Oct 6 690, Nov 83 points) |
| 4 | `COUNT_DISTINCT(Transaction__c)`, `COUNT_DISTINCT(Member__c)` by `Campaign__c` | OK |
| 5 | Vouchers by reward + partner budget | Query OK, but **0 vouchers and 0 rewards** in the org; budget OK (EneServis 100 000 CZK / 2026) |

**SOQL conclusion:** every aggregate needed by the KPI data contract is supported by SOQL.

**Data gaps (blockers for a meaningful report, owner B4/B8):**

- 307 members with registrations across 12 months: OK.
- Only 264 transactions (263 Processed, 1 Error) with ledger dates in Sep–Nov 2026 only, versus the planned 5 000 over 12 months.
- No `Reward__c` and no `Voucher__c` records: budget, popular rewards, point value and the CFO projection cannot be computed.
- Only one campaign run each (October 2026); no repeated runs to compare.
- **Decision 9 conflict (resolved 2026-11-06):** campaign names include the run (`B3 - Natankuj plnou - 2026-10`). Resolution: seed data uses the same business name for every run (decision 9 updated, step 3a).

#### 2026-11-06: Step 4 control queries

- [`kpi-queries.md`](kpi-queries.md) holds K01–K20 (MUST K01–K18, SHOULD K19–K20) and the formulas for derived KPIs. [`scripts/bash/b9-kpi-queries.sh`](../../../scripts/bash/b9-kpi-queries.sh) extracts the queries from the document, fills in the period, campaign and budget year, and runs them against the project default org.
- Test run for October 2026 (`LOYALTY` org): **all 20 queries run without errors**, including `convertTimezone`, `COUNT_DISTINCT`, relationship `GROUP BY` and semi-joins.
- First reconciliation check passes: K04 fuel 5 234 + till 1 296 = K03 `PurchaseBase` 6 530.
- B4 data was being loaded during the run (12 months of ledger history now exist in K18), so expected values are **not** recorded yet; record them once B4 is final.

**Findings for B4/B8:**

- No `Reward__c` / `Voucher__c` yet: K05, K08–K10 return empty results, so point value, budget and CFO projection are still blank.
- B4 campaign runs are named `B4 campaign 2026-07 fuel` / `… shop`, which again breaks decision 9. They must be named `Natankuj plnou` / `Zastávka na cestě`.
- Test campaigns `B4 campaign disabled` and `B4 campaign future` exist; the report lists only campaigns with at least one `CampaignBonus` entry, so they do not show up.
- `Profile_Complete__c` and `Marketing_Consent__c` (K20) are not readable in `Loyalty_Reporting`; add read access for the production report user.
