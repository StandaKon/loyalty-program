# Implementation Blocks

This directory contains the working documentation for the implementation blocks defined in [`../main/LOYALTY_PROGRAM.md`](../main/LOYALTY_PROGRAM.md#3-implementation-blocks).

## Mandatory Delivery Workflow

Every contributor must complete the following stages in order for each block:

1. **Finalize the assignment** — turn the high-level scope into an explicit, testable assignment and record assumptions, acceptance criteria, exclusions, and dependencies in the block README.
2. **Resolve open points** — review every unresolved question with the AI assistant and record the approved decisions. Do not start implementation while a decision that affects the design remains open.
3. **Prepare implementation steps** — document the metadata, code, configuration, data, security, deployment, and test steps in execution order.
4. **Implement and verify** — implement only the approved scope, execute the planned tests, and record results and deviations in the block README.

If the scope or an approved decision changes during implementation, return to the relevant earlier stage and update the documentation before continuing.

## Blocks

| Block | Description | Depends on |
| --- | --- | --- |
| [B0](B0-org-project-setup/README.md) | Org and project setup | — |
| [B1](B1-data-model-config/README.md) | Data model and configuration | B0 |
| [B2](B2-points-engine/README.md) | Points engine | B1 |
| [B3](B3-transaction-input/README.md) | Transaction input | B2 |
| [B4](B4-test-data-engine-tests/README.md) | Test data and engine tests | B2, B3 |
| [B5](B5-back-office-app/README.md) | Back-office application | B1 |
| [B6](B6-member-portal-base/README.md) | Member portal foundation | B1, B2 |
| [B7](B7-portal-activities/README.md) | Portal activities | B6 |
| [B8](B8-rewards-vouchers/README.md) | Rewards and vouchers | B6 |
| [B9](B9-management-report/README.md) | Management report | B4 |
| [B10](B10-testing-demo/README.md) | End-to-end testing and demo | All implementation blocks |
| [B11](B11-bonuses/README.md) | Optional features | B2, B8 |

## Status Legend

- `Draft` — the assignment is not final.
- `Ready` — assignment and decisions are approved; implementation steps are complete.
- `In progress` — implementation has started.
- `Blocked` — work cannot continue until a recorded blocker is resolved.
- `Done` — implementation and verification are complete.
