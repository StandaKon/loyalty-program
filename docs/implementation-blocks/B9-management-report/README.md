# B9 — Management Report

**Status:** Draft  
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

> **Proposal, not yet approved** (prepared 2026-11-06 from SD ch. 10, `context.md` FR-E9-01 to FR-E9-08, B1 spec ch. 7 and the deployed B1 metadata). Decisions below are recommendations until the "Approved by/date" column is filled.

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
- The viewer of the artifact connects the connector as the dedicated report user (or an equivalent user with only `Loyalty_Reporting`).

**Acceptance criteria:**

1. After a new transaction is processed and the report is refreshed, the affected KPIs change, and every KPI matches its control SOQL query (section KPI data contract).
2. "Sleva 200 Kč na přezutí": issued count × 200 CZK = displayed value.
3. The redemption rate is computed from point totals, not averaged monthly percentages, and shows "—" with a zero denominator.
4. The CFO formula and all its inputs are visible in the report.
5. The campaign section explicitly states that transaction-value comparison is indicative (no control group, no non-member sales).
6. An empty period, a connector error and a not-connected connector each show a clear state instead of zeros.
7. The report user cannot create, edit or delete any loyalty record, and the artifact does not query member names, emails or member numbers.

#### KPI data contract

Rules for all KPIs: periods are evaluated in `Europe/Prague`; always use the business date, never `CreatedDate`; amounts are whole points / CZK.

| KPI | Source and formula | Date basis |
| --- | --- | --- |
| Members total | `COUNT(Account)` where `Member_Number__c != null AND Membership_Status__c = 'Active'`. Current status only (deviation from FR-E9-02 "as of period end", see open questions). | Now |
| New registrations | `COUNT(Account)` with `Member_Number__c != null`, grouped by week/month | `Joined_At__c` |
| Points earned | `SUM(Point_Ledger__c.Points__c)` where `Entry_Type__c IN ('PurchaseBase','CampaignBonus','ProfileBonus','MarketingBonus')`. Source split: fuel = `SUM(Loyalty_Transaction__c.Base_Fuel_Points__c)`, till = `SUM(Base_Other_Points__c)` (both on `Processing_Status__c = 'Processed'` transactions, by `Purchased_At__c`), campaigns = `CampaignBonus` by `Campaign__c`, activities = `ProfileBonus` + `MarketingBonus`. `Adjustment` is reported separately and not added to earned points. | `Occurred_At__c` |
| Points redeemed | `ABS(SUM(Points__c))` for `Redemption` minus `SUM(Points__c)` for `Refund` | `Occurred_At__c` |
| Redemption rate | Points redeemed / points earned in the same period; cumulative variant since launch. Empty when the denominator is 0; may exceed 100 %. | `Occurred_At__c` |
| Outstanding balance | `SUM(Account.Points_Balance__c)` of members; CZK = points × weighted point value | Now |
| Weighted point value (CZK/point) | `SUM(Voucher__c.Value_CZK__c) / SUM(Voucher__c.Points_Spent__c)` over non-cancelled vouchers since launch | `Issued_At__c` |
| Vouchers by reward | `COUNT`, `SUM(Points_Spent__c)`, `SUM(Value_CZK__c)` grouped by `Reward__c` (and `Partner__c`); redeemed share = `Status__c = 'Redeemed'` / non-cancelled | `Issued_At__c` |
| Voucher budget | `SUM(Value_CZK__c)` of vouchers with `Status__c != 'Cancelled'` issued in the budget year, per partner, vs. `Account.Voucher_Budget_CZK__c` for `Voucher_Budget_Year__c`. Cancelled value shown separately. Nominal value, not the settled partner cost. Year-end estimate = YTD value / elapsed days × days in year. | `Issued_At__c` |
| Campaign performance | `CampaignBonus` grouped by `Campaign__c`: `COUNT_DISTINCT(Transaction__c)`, `COUNT_DISTINCT(Member__c)`, `SUM(Points__c)` (zero bonuses count as qualifying); share = qualifying / all processed transactions in the campaign period; cost = bonus points × weighted point value; average `Total_Amount__c` of qualifying vs. other transactions | `Occurred_At__c` / `Purchased_At__c` |
| CFO projection | Average monthly earned points (last 12 full months) × 12 × cumulative redemption rate × weighted point value. Scenarios: rate −10 pp / expected / +10 pp (SHOULD). | Last 12 months |
| Last refresh | Time the artifact received the connector response (shown with `Europe/Prague` time) | — |

### 2. Resolved Open Points

| ID/question | Decision (proposal) | Approved by/date |
| --- | --- | --- |
| OP-11 | The artifact uses the `mcp` capability with the official claude.ai **Salesforce** connector (`dispatch_readonly`, plus `describe`/`discover` if needed). Calls run under the viewer's own OAuth credentials, and tokens never reach the page. Least privilege: a dedicated report user with only the `Loyalty_Reporting` permission set (+ API Enabled); the connector is connected as that user. Refresh = on open + manual refresh button, with the last-refresh timestamp shown. **Pre-condition:** spike in step 2 proves custom objects and aggregate SOQL work. **Plan B (demo only):** local Salesforce DX MCP server declared as a `host:` server (works only in the Claude desktop app with an authenticated `sf` CLI). **Fallback:** Salesforce reports + dashboard "EneOil Klub – Management" (operational backup, not a replacement for the artifact). | |
| OP-09 | Reward values 200 CZK / 500 CZK / **2 000 CZK** (free inspection, proposed). Budget = annual amount on the partner Account (`Voucher_Budget_CZK__c`, `Voucher_Budget_Year__c`), value set by B4 seed data. Budget is **informational only**: the report tracks it, redemption is not blocked. | |
| KPI formulas, grain, date basis, time zone | See the KPI data contract above; `Europe/Prague`, business dates only. | |
| "Average % of points redeemed" | Aggregate ratio redeemed / earned points (not an average of member or monthly percentages), per period and cumulative. | |
| CFO projection method | Formula from FR-E9-05 using the cumulative redemption rate and the weighted point value; inputs and formula visible; three scenarios as SHOULD. | |
| Campaign measures without sales data | Qualifying transactions, share, unique members, bonus points, estimated cost; transaction-value comparison labelled as indicative. | |

**Still open (need a decision before Ready):**

- **Historical membership status:** B1 does not store status history, so "members total as of period end" can only show the current status. Accept the deviation, or add status history in B1?
- **Repeated campaigns (FR-E3-03):** `Loyalty_Campaign__c` has no link between runs of the same campaign. Compare by name, or add a field in B1?
- **Free inspection value and budget amount:** the 2 000 CZK value and the annual budget need the guarantor's confirmation (Q1, Q2).

### 3. Implementation Steps

1. **Approve the assignment.** Close OP-11, OP-09 and the open questions above; set status to `Ready`.
2. **Connector spike (D4).** Connect the claude.ai Salesforce connector to the org with B4 data; verify `dispatch_readonly` returns results for `Point_Ledger__c`, `Voucher__c`, `Loyalty_Transaction__c` and aggregate queries (`SUM`, `COUNT_DISTINCT`, `GROUP BY`, date functions). Record the request/response shape. If it fails, switch to plan B and record the deviation.
3. **Report user and security.** Create the report user (Salesforce Integration or standard licence per org availability) with only `Loyalty_Reporting` + API Enabled. Verify it cannot edit any loyalty object, and that the artifact queries contain no name, email or member number fields.
4. **Control queries.** Write one SOQL per KPI from the data contract into `docs/implementation-blocks/B9-management-report/kpi-queries.soql`; run them against B4 data and record the expected values.
5. **Artifact.** Build the page with the `mcp` capability (`Salesforce`: `dispatch_readonly`): period filter + previous-period comparison, KPI cards, trends, voucher budget, campaign table, CFO panel with formula, KPI definitions, last-refresh timestamp, empty/error/not-connected states, brand kit "Manažerský report" (FR-E9-07).
6. **Fallback.** Create report folder "EneOil Klub – Management" (shared with the Reporting role), reports for members, points by entry type, vouchers by reward and campaign bonuses, and one dashboard.
7. **Reconciliation and tests.** Compare every artifact KPI with step 4; process a new transaction, refresh, confirm the change; test empty period, connector error/disconnected, and access restrictions; check that campaign metrics carry the indicative note.
8. **Stakeholder review.** Walk Petra (and the CFO view) through the projection assumptions; record acceptance and deviations in section 4.

### 4. Implementation and Test Results

_Record artifact/configuration, reconciliations, stakeholder results, deviations, and follow-up work._
