# B2 — Points Engine

**Status:** Draft  
**Phase:** Implementation I  
**Depends on:** B1  
**Solution design reference:** Chapter 6  
**Open points:** OP-07, Q10

## Objective

Implement a bulk-safe and idempotent engine that validates loyalty transactions, calculates base and campaign points, creates an auditable ledger, and maintains the member balance.

## Required Scope

- Validate that fuel amount plus other amount equals total amount.
- Prevent duplicate processing through a unique POS transaction identifier.
- Calculate one base point per whole litre and one base point per whole CZK 20 of non-fuel spend.
- Evaluate active campaigns using the purchase date and configurable condition/reward fields.
- Support multiple campaigns on one transaction.
- Apply a multiplier only to base points and round all partial values down.
- Create auditable ledger entries for base points and campaign effects according to the approved ledger design.
- Maintain the member balance using the approved roll-up or service approach.
- Expose clear processing status and errors without producing partial or duplicate awards.
- Follow trigger-actions-framework and project Apex conventions where applicable.
- Keep queries and DML bulk-safe and enforce sharing/security at the appropriate boundaries.

## Decisions and Questions to Close

- **OP-07:** Select Apex trigger/service or Flow and document why it meets bulk, idempotency, and audit requirements.
- **Q10:** Confirm multiplier semantics and how the incremental campaign award is represented in the ledger.
- Confirm behavior when a campaign is changed after a transaction was processed.
- Confirm error handling, retry behavior, and transaction processing statuses.
- Confirm how backdated purchases and simultaneous transactions are handled.

## Acceptance Criteria

- The documented example produces exactly 109 points: 54 base points, 5 multiplier bonus points, and 50 fixed bonus points.
- Reprocessing the same POS transaction does not award points twice.
- Inserting transactions in bulk stays within Salesforce governor limits.
- A failure leaves no partial ledger or balance change.
- Every balance change is traceable to its source.

## Expected Deliverables

- Trigger/action and service-layer implementation or the approved declarative equivalent.
- Selectors and reusable calculation components.
- Transaction validation and idempotency controls.
- Ledger and balance update implementation.
- Apex unit tests, coordinated with B4.

## Definition of Ready

- OP-07, Q10, error behavior, and ledger semantics are reviewed with the AI assistant and approved.
- Campaign and data-model contracts from B1 are stable.
- Detailed implementation steps and test cases are documented.

## Verification

- Test no-campaign, fixed-bonus, multiplier, and multiple-campaign cases.
- Test boundaries immediately below, at, and above each threshold.
- Test duplicate POS IDs, invalid totals, backdated dates, and bulk input.
- Test rollback and concurrency-sensitive paths.

## Working Record

### 1. Final Assignment

_To be completed and approved before implementation._

### 2. Resolved Open Points

| ID/question | Decision | Approved by/date |
| --- | --- | --- |
| OP-07 | | |
| Q10 | | |

### 3. Implementation Steps

_List Apex/Flow, metadata, security, test, and deployment steps in execution order._

### 4. Implementation and Test Results

_Record components, test runs, coverage, results, deviations, and follow-up work._
