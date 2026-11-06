# B7 — Portal Activities

**Status:** Draft  
**Phase:** Implementation II  
**Depends on:** B6  
**Solution design reference:** Chapter 6.3  
**Open points:** Q4, Q5

## Objective

Allow members to earn the two one-time portal activity bonuses securely: 100 points for completing the approved vehicle profile and 50 points for granting marketing consent.

## Required Scope

- Present the eligible activities and completion state in the member portal.
- Define and validate the required vehicle/profile fields for the 100-point award.
- Capture marketing consent, timestamp, source, and the approved audit attributes.
- Award each activity at most once using a durable unique/idempotency key.
- Create auditable ledger entries and update the balance atomically.
- Perform eligibility and award checks server-side; do not trust client state.
- Prevent double-click, retry, concurrency, and field-toggling exploits.
- Use Czech labels and accessible success/error feedback.

## Decisions and Questions to Close

- **Q4:** Confirm which profile and vehicle fields constitute profile completion.
- **Q5:** Confirm consent capture, withdrawal behavior, evidence, and whether withdrawal ever reverses awarded points.
- Confirm the ledger type/source and unique key format for each activity.
- Confirm whether historical members can receive bonuses after deployment.

## Acceptance Criteria

- First valid profile completion awards exactly 100 points; later edits do not award again.
- First valid marketing consent awards exactly 50 points; repeated submission does not award again.
- Concurrent/retried requests cannot create duplicate ledger entries.
- A failed update does not create a partial profile, consent, ledger, or balance result.

## Expected Deliverables

- Portal activity LWC/UI.
- Secure Apex service/controller and required metadata.
- Unique/idempotency enforcement and ledger integration.
- Apex and functional tests for eligibility, repeat, concurrency, and error paths.

## Definition of Ready

- Q4, Q5, audit, reversal, and historical-member rules are reviewed with the AI assistant and approved.
- B6 identity and portal-security patterns are available.
- Detailed implementation and test steps are documented.

## Verification

- Test incomplete and complete profiles, repeated edits, consent grant/withdraw/regrant, double-click, and concurrent requests.
- Verify member isolation and server-side authorization.
- Reconcile ledger entries and balance changes.

## Working Record

### 1. Final Assignment

_To be completed and approved before implementation._

### 2. Resolved Open Points

| ID/question | Decision | Approved by/date |
| --- | --- | --- |
| Q4 | | |
| Q5 | | |

### 3. Implementation Steps

_List data, LWC, Apex, security, test, and deployment steps in order._

### 4. Implementation and Test Results

_Record components, test results, reconciliation, deviations, and follow-up work._
