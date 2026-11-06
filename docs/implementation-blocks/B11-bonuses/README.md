# B11 — Optional Features

**Status:** Draft  
**Phase:** If time / separate option  
**Depends on:** B2, B8  
**Solution design reference:** Chapter 2, E10  
**Open points:** OP-13, OP-14, Q8, Q9

**Marketing input:** [Zadání pro volitelné funkce programu](OPTIONAL_FEATURES_MARKETING_BRIEF.md)

## Objective

Evaluate and, only after explicit approval, implement optional loyalty features without destabilizing the required solution.

## Candidate Scope and Priority

1. **Voucher PDF or image** — generate a branded voucher artifact containing the unique code.
2. **Points expiration** — expire unused credited points exactly one year after credit, with FIFO consumption and an expired-points reporting metric.
3. **Membership tiers** — implement Okreska/Dálnice or another approved model based on qualifying points and defined benefits.
4. **Transaction reversal** — reverse a transaction and its point effects through compensating ledger entries without deleting audit history.

Each candidate must be treated as a separate mini-scope with its own approved assignment, decisions, implementation steps, tests, and release decision. Do not implement a candidate merely because time remains.

## Decisions and Questions to Close

- **OP-14:** Select which optional features, if any, are approved and establish their order.
- **OP-13:** Confirm return/storno business rules and whether partial reversal is required.
- **Q8:** Confirm exact expiration, notification, FIFO, timezone, and already-redeemed-point behavior.
- **Q9:** Confirm tier thresholds, qualification period, downgrade rules, benefits, and recalculation schedule.
- For voucher files, confirm format, storage, access, regeneration, email attachment, and accessibility requirements.
- Confirm impact on B1 data model, B2 ledger, B6/B8 portal, B9 reporting, and B10 tests.

## Expected Deliverables per Approved Candidate

- Approved detailed scope and architecture decision.
- Data-model/security/reporting impact assessment.
- Implementation and migration/backfill plan.
- Metadata/code/UI changes and automated tests.
- Updated portal, back-office, report, and demo documentation where affected.
- Explicit release and rollback considerations.

## Definition of Ready

- OP-13, OP-14, Q8, Q9, and all candidate-specific rules are reviewed with the AI assistant and approved.
- Required blocks are stable and regression tests pass.
- The candidate has a complete implementation and regression-test plan.

## Verification

- Voucher file: verify branding, code accuracy, member-only access, email delivery, and repeat generation.
- Expiration: verify FIFO, exact anniversary boundary, batch bulk behavior, balance/ledger reconciliation, and reporting.
- Tiers: verify boundaries, upgrades, downgrades, recalculation, benefits, and member display.
- Reversal: verify full/partial rules, idempotency, campaign reversal, insufficient already-spent balance behavior, and audit trail.
- Run regression tests for required B2, B6, B8, B9, and B10 behavior.

## Working Record

### 1. Final Assignment

_Create a separate approved subsection for every selected optional feature._

### 2. Resolved Open Points

| ID/question | Decision | Approved by/date |
| --- | --- | --- |
| OP-13 | | |
| OP-14 | | |
| Q8 | | |
| Q9 | | |

### 3. Implementation Steps

_List data, code, UI, batch, reporting, migration, test, and deployment steps for each approved candidate._

### 4. Implementation and Test Results

_Record components, regression results, deviations, release decision, and follow-up work._
