# B5 — Back-Office Application

**Status:** Draft  
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

_To be completed and approved before implementation._

### 2. Resolved Open Points

| Question | Decision | Approved by/date |
| --- | --- | --- |
| | | |

### 3. Implementation Steps

_List app, FlexiPage, action, Flow/Apex, label, security, test, and deployment steps in order._

### 4. Implementation and Test Results

_Record components, persona tests, results, deviations, and follow-up work._
