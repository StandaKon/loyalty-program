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

**Goal:** Every valid member purchase earns the correct points exactly once, every point is traceable to its source, and the member balance always equals the sum of ledger entries.

**Input (1 record = 1 POS purchase, delivered by B3):** POS transaction ID, purchase date/time, member number (`Member_Number__c`), station, total CZK, fuel CZK, litres, other CZK.

**Processing rules**
1. **Validation:** all values ≥ 0, total > 0, fuel + other = total (to the haléř), fuel > 0 ⇔ litres > 0, member exists and is Active, purchase date is not in the future. Invalid → status *Error* with a reason, no points.
2. **Idempotency:** the same POS ID is processed exactly once; re-import awards nothing.
3. **Base points:** `floor(litres)` + `floor(other CZK / 20)`; rates from `Loyalty_Settings__mdt`; Decimal arithmetic only.
4. **Campaigns:** apply automatically to all members when active, the purchase date (Europe/Prague) is within valid from–to (inclusive), and `field ≥ threshold` holds. Each campaign applies at most once per transaction; campaigns add up.
   - Fixed bonus: `+value`.
   - Multiplier: `floor(base × coefficient) − base`, always calculated from base points only; multiple multipliers are each calculated separately from base and summed.
5. **Output:** base, bonus and total points + status and error message on the transaction; one ledger entry for base points and one per matched campaign (including 0-point results), unique key per transaction + BASE / transaction + campaign; ledger date = purchase date; balance = roll-up of ledger.
6. **Integrity:** ledger entries are never edited or deleted; processing of a transaction is atomic (transaction + all its ledger entries, or nothing); 5 000 transactions in one import stay within governor limits.

**User impact**
- *Member (portal, B6):* sees the balance grow after a purchase and a history line per purchase plus a separate line per campaign, dated by purchase date.
- *Loyalty manager (back office, B5):* sees the points breakdown per transaction, sees failed transactions with a reason, fixes them and they are reprocessed; configures campaigns without a developer.

**Out of scope:** transaction input/import UI (B3), portal activities (B7 – reuse the same ledger), manual adjustment (B5), storno (OP-13), expiration and tiers (B11).

**Acceptance criteria:** reference calculations T01–T07 and T10 (SD ch. 14) match exactly – T01 = 109 (54 + 5 + 50); negative scenarios T20, T21, T23, T24 and bulk T25 pass; no failure leaves a partial ledger or balance change.

**Dependency:** B1 data model (incl. OP-06 campaign storage) must be stable; API names above are provisional until then.

### 2. Resolved Open Points

| ID/question | Decision | Approved by/date |
| --- | --- | --- |
| OP-07 | Apex via trigger-actions-framework (trigger action + service + selectors). Reason: bulk 5 000 transactions, idempotency via unique keys, full unit-test coverage of T01–T25. Campaigns and rates stay configurable as records/CMDT. | Stanislav Konopásek, 2026-11-06 |
| Q10 | Multiple multipliers: each calculated separately from base points, results summed (order-independent). | Stanislav Konopásek, 2026-11-06 |
| Zero bonus | A matched campaign with a 0-point result (e.g. T04) still creates a 0-point ledger entry, so campaign performance reporting (FR-34) counts every hit. | Stanislav Konopásek, 2026-11-06 |
| Errors & retry | Statuses `Pending → Processed / Error` (names per B1). An *Error* transaction is saved with a reason, can be corrected and is reprocessed on save. A *Processed* transaction is locked; corrections go through storno or manual adjustment. | Stanislav Konopásek, 2026-11-06 |
| Campaign change | Changes to a campaign apply only to transactions processed afterwards; already awarded points are never recalculated. | Stanislav Konopásek, 2026-11-06 |
| Backdated / future dates | Campaign eligibility by purchase date (Europe/Prague), regardless of import time; no backdating limit (historic seed data in B4). Future-dated purchase → *Error*. Simultaneous transactions: balance is a roll-up, so no shared counter is updated concurrently. | Stanislav Konopásek, 2026-11-06 |

**Alignment with B1 data model** ([data-model-config.md](../B1-data-model-config/data-model-config.md)): statuses are `Pending / Processed / Error`; ledger entry types `PurchaseBase` / `CampaignBonus`; unique keys `TX:<id>:BASE` and `TX:<id>:CAM:<campaignId>`; campaign snapshot copied to `Applied_*` fields. An unknown member number is rejected by the import itself (required lookup), not stored as *Error* (B1 §4.3).

### 3. Implementation Steps

1. **Prerequisite (B1, owned by the B1 colleague):** deploy fields of `Account` (`Member_Number__c`, `Membership_Status__c`, `Joined_At__c`, `Points_Balance__c` roll-up), `Loyalty_Transaction__c`, `Loyalty_Campaign__c` and `Point_Ledger__c` (incl. `Applied_*`) as specified in B1 §4. In the `LOYALTY` org only object shells exist today.
2. **Framework:** trigger-actions-framework, `dml` and `enehano-logger` are not installed in the org → plain trigger + handler, native `Database.*` DML with explicit `AccessLevel`; processing errors are stored on the transaction instead of logged (decision 2026-11-06).
3. **Apex components** (done, see §4).
4. **Deploy** B2 metadata after step 1 and run `PointsCalculatorTest`, `LoyaltyTransactionServiceTest`.
5. **Hand-over:** B3 imports into `Loyalty_Transaction__c` (upsert is not allowed for idempotency – plain insert); B4 extends tests to T23–T25 with seed data; B5 adds a list view of *Error* transactions.

### 4. Implementation and Test Results

| Component | Path | Purpose |
| --- | --- | --- |
| `LoyaltyTransactionTrigger` | `triggers/` | Routing only (before/after insert and update) |
| `LoyaltyTransactionTriggerHandler` | `classes/triggerActions/` | Dispatches trigger contexts; `without sharing` (server-side engine) |
| `LoyaltyTransactionService` | `classes/services/` | Validation, status, points breakdown (before save); ledger entries (after save); lock of processed purchases |
| `PointsCalculator` | `classes/services/` | Pure calculation of base points and campaign bonuses (floor, Europe/Prague purchase day) |
| `AccountSelector`, `LoyaltyCampaignSelector`, `LoyaltySettingsSelector` | `classes/selectors/` | SOQL / CMDT access, `WITH SYSTEM_MODE` |
| Custom Labels `Loyalty_Tx_Error_*` | `labels/` | Error reasons stored in `Processing_Error__c` (English base; Czech translation is follow-up) |
| `PointsCalculatorTest`, `LoyaltyTransactionServiceTest`, `LoyaltyTestDataFactory` | `classes/` | T01–T07, T10, T20, T21, multi-multiplier, date boundaries, retry, lock, bulk 251, invalid settings |

**Test execution:** not run yet – the B1 fields do not exist in the `LOYALTY` org, so the code cannot be compiled there.

**Follow-up:**
- Point_Ledger__c immutability (block update/delete) – B1 §6, not part of this change.
- If B1 adds a validation rule for `fuel + other = total`, an inconsistent row is rejected by the import instead of being stored as *Error*; the engine check remains as a safety net.
- Czech translations of the error labels.
