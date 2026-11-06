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

_To be completed and approved before implementation._

### 2. Resolved Open Points

| ID/question | Decision | Approved by/date |
| --- | --- | --- |
| OP-11 | | |
| OP-09 | | |

### 3. Implementation Steps

_List data contract, connection, report, security, reconciliation, fallback, and release steps in order._

### 4. Implementation and Test Results

_Record artifact/configuration, reconciliations, stakeholder results, deviations, and follow-up work._
