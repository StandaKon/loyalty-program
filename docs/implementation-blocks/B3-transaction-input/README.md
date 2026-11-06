# B3 — Transaction Input

**Status:** Draft  
**Phase:** Implementation I  
**Depends on:** B2  
**Solution design reference:** Chapter 9

## Objective

Provide repeatable CSV and manual-entry paths for simulating member POS purchases without building a real POS integration.

## Required Scope

- Define a sample CSV format with POS transaction ID, member number, purchase date, total amount, fuel amount, litres, and other amount.
- Map members by unique external `Member_Number__c`; import member transactions only.
- Provide a documented import procedure using supported Salesforce tooling.
- Provide a Czech manual-entry or “Simulate Purchase” experience, preferably as a Screen Flow if it fits the approved design.
- Reuse B2 validation and processing; do not duplicate point-calculation logic in the input layer.
- Present actionable validation errors for unknown members, duplicates, and invalid amounts.
- Define access permissions for import operators and back-office users.

## Decisions and Questions to Close

- Which CSV tool and import sequence will be used for the demo and for repeatable test-data loading?
- Is manual entry a Screen Flow, standard record action, or another approved UI?
- Should failed imports create error records, remain unprocessed with an error status, or be rejected before insert?
- What locale and decimal/date formats are accepted in the CSV?

## Expected Deliverables

- Versioned sample CSV and field-mapping documentation.
- Reusable import script or exact CLI/import instructions.
- Manual transaction-entry UI and permissions.
- Error-handling and operator instructions.
- Functional tests for both input paths.

## Definition of Ready

- CSV schema, manual-entry UX, and failure behavior are reviewed with the AI assistant and approved.
- B2 exposes a stable processing contract.
- Detailed implementation and verification steps are recorded.

## Verification

- Import valid single and bulk transaction files.
- Verify member matching, duplicate protection, and clear rejected-row handling.
- Submit a manual transaction and confirm identical calculations to CSV input.
- Confirm the 109-point acceptance example through both applicable paths.

## Working Record

### 1. Final Assignment

_To be completed and approved before implementation._

### 2. Resolved Open Points

| Question | Decision | Approved by/date |
| --- | --- | --- |
| | | |

### 3. Implementation Steps

_List data format, Flow/UI, permissions, import, test, and deployment steps in order._

### 4. Implementation and Test Results

_Record artifacts, import results, test evidence, deviations, and follow-up work._
