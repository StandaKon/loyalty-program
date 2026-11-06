# B4 — Test Data and Engine Tests

**Status:** Draft  
**Phase:** Implementation I  
**Depends on:** B2, B3  
**Solution design references:** Chapters 14 and 15

## Objective

Provide deterministic test data and automated tests that demonstrate the points engine works for normal, boundary, failure, idempotency, and bulk scenarios.

## Required Scope

- Generate representative seed data for stations, approximately 300 members, 5,000 transactions, campaign history, rewards, and vouchers.
- Keep synthetic personal data clearly fictional and safe to share.
- Make generation and loading repeatable, with stable external IDs and documented load order.
- Implement Apex tests T01–T25 from the approved test design.
- Include the 109-point acceptance example and all rounding/threshold boundaries.
- Include bulk, duplicate, rollback, inactive/future/expired campaign, and multiple-campaign tests.
- Use project test-data factories and Apex mocking conventions where applicable.
- Keep unit tests isolated from org data and suitable for CI execution.

## Decisions and Questions to Close

- Confirm the exact T01–T25 test catalogue and expected results.
- Confirm the seed-data volumes that are practical for the target org and demo.
- Confirm whether generated transactions are loaded through B3 or directly for setup speed.
- Confirm how generated credentials or portal-user records are handled.

## Expected Deliverables

- Seed-data generator and/or versioned seed files under `/data`.
- Load and cleanup instructions that do not target production.
- Apex test classes and reusable test-data factory updates.
- Test result and coverage report.
- Known limitations and data-generation assumptions.

## Definition of Ready

- Test catalogue, expected outcomes, volumes, and load method are reviewed with the AI assistant and approved.
- B1–B3 contracts are stable enough to test.
- Implementation and execution steps are documented.

## Verification

- Recreate the data set from a clean supported non-production org state.
- Run targeted Apex tests and record failures and coverage.
- Confirm 251+ record bulk behavior where applicable.
- Reconcile generated ledger totals, balances, campaign awards, and vouchers.

## Working Record

### 1. Final Assignment

_To be completed and approved before implementation._

### 2. Resolved Open Points

| Question | Decision | Approved by/date |
| --- | --- | --- |
| | | |

### 3. Implementation Steps

_List generation, loading, Apex-test, validation, and reporting steps in order._

### 4. Implementation and Test Results

_Record data counts, commands, test results, coverage, deviations, and follow-up work._
