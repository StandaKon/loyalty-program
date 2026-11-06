# B8 — Rewards and Vouchers

**Status:** Draft  
**Phase:** Implementation II  
**Depends on:** B6  
**Solution design reference:** Chapter 7  
**Open points:** OP-09, OP-10, Q3

## Objective

Let members securely redeem points for partner rewards, receive a unique voucher in the portal and by email, and give authorized operators a controlled way to verify it.

## Required Scope

- Show active rewards with partner, point cost, CZK value, description, and member affordability state.
- Validate balance and reward eligibility server-side.
- Lock the relevant member/balance records and perform point deduction, ledger entry, and voucher creation atomically.
- Prevent double-click and replay from creating duplicate redemption or spend.
- Generate a unique code in the approved `ENE-XXXX-XXXX` format or an approved alternative.
- Show issued vouchers and their statuses only to the owning member.
- Send a branded Czech email containing the voucher code after successful redemption.
- Define email retry/failure behavior without duplicating the redemption.
- If approved as SHOULD, provide an operator verification/redemption Screen Flow in Salesforce.
- Record reward CZK value at issue time if needed for stable budget reporting.

## Decisions and Questions to Close

- **OP-09:** Define reward CZK values, free-inspection value, partner budget, and budget enforcement versus reporting only.
- **OP-10:** Approve code format, generation algorithm, uniqueness constraint, collision handling, and case sensitivity.
- **Q3:** Define operator verification and voucher status transitions.
- Confirm email sender, template, deliverability prerequisites, and retry behavior.
- Confirm reward availability rules, voucher cancellation, and whether vouchers truly have no expiry.

## Acceptance Criteria

- Redemption is blocked without sufficient points and changes no data.
- Successful redemption deducts points immediately and creates one ledger entry and one unique voucher.
- Concurrent/repeated requests cannot spend the same balance twice.
- The member sees the voucher and receives the approved email.
- Voucher budget values remain historically accurate if the reward later changes.

## Expected Deliverables

- Reward catalogue and My Vouchers portal LWCs.
- Secure redemption service/controller and required selectors.
- Voucher-code generator and uniqueness enforcement.
- Branded email template and sending automation.
- Optional operator verification Flow and access configuration.
- Automated and functional test evidence.

## Definition of Ready

- OP-09, OP-10, Q3, email, status, and concurrency behavior are reviewed with the AI assistant and approved.
- Reward/voucher model and B6 portal security are stable.
- Detailed implementation and test steps are documented.

## Verification

- Test exact balance, insufficient balance, repeated clicks, concurrent redemption, inactive reward, and code collision.
- Verify atomic rollback, ledger/balance reconciliation, member isolation, voucher display, and email output.
- If included, verify operator status transitions and permissions.

## Working Record

### 1. Final Assignment

Implement the v1 reward catalogue, atomic point redemption, unique text vouchers, member voucher list, service email, operator verification/redemption, and existing loyalty-manager cancellation. Use the preferred decisions from the marketing specification while client-owned contacts, locations, budget, and legal approval remain configurable rollout items.

### 2. Resolved Open Points

| ID/question | Decision                                                                                                                                                                      | Approved by/date                         |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- |
| OP-09       | Store 200/500/2,000 CZK snapshots; report budget without blocking issuance.                                                                                                   | Marketing specification v0.9, 2026-11-06 |
| OP-10       | `ENE-XXXX-XXXX`, 31-character alphabet, case-insensitive unique field, five generated candidates before a controlled failure.                                                 | Marketing specification v0.9, 2026-11-06 |
| Q3          | API states remain `Issued`, `Redeemed`, `Cancelled`; Czech UI translates them to Aktivní, Uplatněný, Zrušený. Operator redemption requires location and service-order number. | Marketing specification v0.9, 2026-11-06 |

### 3. Implementation Steps

1. Extend reward availability and voucher redemption audit metadata.
2. Add selectors, code generator, atomic redemption service, asynchronous service email, and controllers.
3. Add Experience Cloud catalogue and My Vouchers LWCs.
4. Add the least-privilege operator verification LWC and permission-set access. A Flow is not used because code normalization, row locking, and the terminal state transition are centralized in the same tested Apex service.
5. Add Czech labels/translations, seed script, Apex tests, and Jest tests.
6. Validate locally, deploy to the configured non-production default org, and run the specified Apex tests.

### 4. Implementation and Test Results

Implementation is in progress. Test and deployment evidence will be recorded after validation.
