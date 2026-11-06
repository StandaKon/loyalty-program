# B11 — Implementation (hackathon bonus features)

**Branch:** `feature/B6-block` · **Date:** 2026-11-06 · **Status:** deployed to org `hackathon` (Developer Edition); jobs **not scheduled**; site not yet published; not committed  
**Related:** [README.md](README.md), [marketing brief NAJETO](B11%20Volitelné%20funkce%20marketingové%20zadání%20NAJETO.md), [B1 data model](../B1-data-model-config/data-model-config.md), [B6](../B6-member-portal-base/IMPLEMENTATION.md), [B7](../B7-portal-activities/IMPLEMENTATION.md), [B8](../B8-rewards-vouchers/IMPLEMENTATION.md)

## 0. Scope and decisions (2026-11-06)

| Candidate | Delivered | Decision source |
| --- | --- | --- |
| Voucher PDF / image | **No** — vouchers excluded | user |
| Points expiry | Portal warning + daily batch writing `Expiration` entries | user; rules from brief ch. 2 |
| Membership tiers Okreska / Dálnice | Tier on member, immediate upgrade, monthly evaluation, fuel × 1.2 in the B2 engine, portal tier card | user (B2 engine change allowed); brief ch. 3 |
| Purchase storno | Back-office quick action on the purchase, `Reversal` entry | user; brief ch. 4 |
| Configuration | New fields on `Loyalty_Settings__mdt` | user |
| E-mails (expiry 30/7 days, tier change, storno) | **Not built** — follow-up | scope |

Rules applied (brief "návrh" values unless noted):

| Rule | Implementation |
| --- | --- |
| Validity | `Points_Validity_Months__c = 12`; credit date in Europe/Prague; `Date.addMonths` (29 Feb → 28 Feb) |
| Points before the rule | `Expiry_Effective_Date__c` (blank in org = every point expires 12 months after credit). **Set it before scheduling** if the "effective date + 1 year" proposal is approved |
| FIFO | Due points on date D = credits expiring ≤ D − all debits (redemption, expiration, reversal, negative adjustment), min 0 |
| Refund of cancelled voucher | New validity from refund date (it is a new credit) |
| Warning | Portal, `Expiry_Warning_Days__c = 30` before the nearest expiry |
| Tiers | Road (Okreska, also blank) and Highway (Dálnice); `Tier_Highway_Threshold__c = 2000`, `Tier_Qualification_Months__c = 12` rolling |
| Qualifying points | `PurchaseBase` + `CampaignBonus` in the period, minus `Reversal` of purchases in the period; **not** activity bonuses, adjustments, **tier bonus** (brief: "nutno ověřit" → excluded) |
| Upgrade / downgrade | Upgrade right after the purchase import (Queueable); monthly batch upgrades or downgrades; balance never changes |
| Highway benefit | `Tier_Highway_Fuel_Multiplier__c = 1.2`: extra `floor(fuel × 1.2) − fuel`, own ledger entry, not multiplied by campaigns (45 l → +9, as in the brief) |
| Storno | Full only; loyalty manager (custom permission `Loyalty_Adjust_Points`, same as manual adjustment); reasons Vrácení nákupu / Chybně zaúčtovaný nákup / Duplicitní nákup; once per purchase; refused when balance < points (manual adjustment instead); purchase record unchanged (B1 `Processed_Transaction_Immutable`) |

## 1. Changes to existing org metadata (B1 / B2) — all additive or extended

Base files were retrieved from the org (B1 metadata) and from `origin/feature/points-engine` (B2/B5 Apex, identical to the org) before editing.

| Component | Change |
| --- | --- |
| `Point_Ledger__c.Entry_Type__c` | + values `TierBonus`, `Expiration`, `Reversal` (cs: Bonus úrovně Dálnice, Propadlé body, Storno nákupu) |
| VR `Point_Ledger__c.Signs_Valid` | + `TierBonus > 0`, `Expiration`/`Reversal < 0` |
| VR `Point_Ledger__c.Source_Required` | `TierBonus` and `Reversal` require `Transaction__c`; `Reversal`/`Expiration` require `Reason__c` |
| `Loyalty_Transaction__c.Total_Points__c` | formula + `Tier_Bonus_Points__c` |
| `Loyalty_Settings__mdt` + record `Default` | 6 new fields (above); existing values unchanged |
| `Loyalty_Transaction_Record_Page` | + action *Reverse Purchase* after Edit/Delete, visible with `Loyalty_Adjust_Points` |
| Permission sets `Loyalty_Member`, `Loyalty_Manager`, `Loyalty_Back_Office` | + read FLS `Account.Loyalty_Tier__c`, `Loyalty_Transaction__c.Tier_Bonus_Points__c`; Manager + class `TransactionReversalController` |
| B2 `PointsCalculator` | new overload `calculate(tx, campaigns, isHighwayTier)`, `PointsResult.tierBonusPoints` (old signature unchanged) |
| B2 `LoyaltyTransactionService` | stores `Tier_Bonus_Points__c`, writes `TierBonus` entry `TX:<id>:TIER`, enqueues tier upgrade |
| B2 `AccountSelector.getMembersByIds` | + `Loyalty_Tier__c` |
| B6 `PortalMemberService/Controller/Dto`, `portalOverview`, `portalUtils` | + `getLoyaltyStatus`, tier/expiry component, 3 movement types |

Copied unchanged into the branch (dependencies, identical to org): `LoyaltyActionException`, `LoyaltyPermissions`, `LoyaltyControllerErrors`, `LoyaltyCampaignSelector`, `LoyaltyTransactionSelector`, `LoyaltyTestDataFactory`, `TestDataFactory`, LWC `loyaltyActionUtils`, `loyaltyBrandStyles`.

## 2. New components

| Area | Component |
| --- | --- |
| Fields | `Account.Loyalty_Tier__c` (restricted picklist Road/Highway, cs Okreska/Dálnice), `Loyalty_Transaction__c.Tier_Bonus_Points__c` |
| Apex – selectors | `LoyaltyLedgerAnalysisSelector` (qualifying points, member ledger, purchase entries), `LoyaltyMemberSelector` (members, `FOR UPDATE`, batch locator) |
| Apex – tiers | `LoyaltyTierService`, `LoyaltyTierUpgradeQueueable`, `LoyaltyTierEvaluationBatch` (Batchable + Schedulable) |
| Apex – expiry | `PointExpiryService` (FIFO, forecast, idempotent key `EXP:<member>:<date>`), `PointExpiryBatch` (Batchable + Schedulable) |
| Apex – storno | `TransactionReversalService` (lock member, key `TX:<id>:REVERSAL`), `TransactionReversalController` |
| LWC | `portalLoyaltyStatus` (expiry warning + tier card on Přehled), `transactionReversalAction` (quick action) |
| Quick action | `Loyalty_Transaction__c.Reverse_Transaction` |
| Labels | 14 `Portal_Tier_*`, `Portal_Expiry_*`, `Portal_MovementType_*`; 14 `Loyalty_BO_Reversal_*` (en_US + cs, texts from the brief) |
| Scripts | `scripts/apex/schedule-b11-jobs.apex`, `scripts/apex/preview-b11-expiry.apex` |
| Tests | `LoyaltyTierServiceTest`, `PointExpiryServiceTest` (brief FIFO example 100/−80/50 → 20 and 50), `TransactionReversalServiceTest`; extended `PointsCalculatorTest`, `LoyaltyTransactionServiceTest`, `PortalMemberControllerTest` |

## 3. Validation (org `hackathon`)

| Check | Result |
| --- | --- |
| Deploy ID `0Afaj00000qdGq9CAE` | Succeeded |
| Tests (B2 engine, B3 POS import, B6/B7 portal, B11) | **46/46 passed** |
| Coverage | `LoyaltyTransactionService` 98 %, `PointsCalculator` 95 %, `PointExpiryService` 95 %, `LoyaltyTierService` 94 %, `TransactionReversalService` 92 %, controller 90 %, selectors 100 %, batches 78 % |
| LWC lint | Pass |
| **Pre-existing failures (not B11)** | `LoyaltyCzechTranslationsTest` (expects "Nákup", org label "Transakce"), `LoyaltyDataModelTest` (expects 109, gets 163 — test inserts ledger entries on top of B2 trigger entries), `LoyaltyMemberAccessTest` (expects 1 ledger row, gets 2 — same cause). Same failures without B11 changes, therefore excluded from the deploy test run |

Deployed scope: `objects`, `objectTranslations`, `customMetadata`, `quickActions`, `flexipages`, `labels`, `translations`, the 3 permission sets, the changed/new classes from sections 1–2 and LWCs `portalLoyaltyStatus`, `portalOverview`, `portalUtils`, `transactionReversalAction`. Test level `RunSpecifiedTests`: `PointsCalculatorTest`, `LoyaltyTransactionServiceTest`, `LoyaltyTierServiceTest`, `PointExpiryServiceTest`, `TransactionReversalServiceTest`, `PortalMemberControllerTest`, `PortalActivityControllerTest`, `PortalRegistrationServiceTest`, `PortalRegistrationControllerTest`, `PosTransactionRestResourceTest`.

## 4. Before the demo

1. Decide `Expiry_Effective_Date__c` (blank = seeded history older than 12 months **expires on the first run**). Ledger entries are immutable, so check first: run `scripts/apex/preview-b11-expiry.apex` as a user with `Loyalty_Manager`.
2. Schedule jobs: `sf apex run --file scripts/apex/schedule-b11-jobs.apex` (daily expiry 01:30, tier evaluation on the 1st at 02:00).
3. Existing members have blank tier (= Okreska). Optionally run the tier evaluation once: `Database.executeBatch(new LoyaltyTierEvaluationBatch());`.
4. Publish the site (Přehled shows the tier card and expiry warning).

## 5. Follow-ups

- E-mails: expiry 30 and 7 days before, tier upgrade/downgrade, storno confirmation (texts ready in the brief).
- B9 reporting: expired points per month, members per tier, reversed points.
- Portal history detail for storno ("Storno nákupu z 5. 11. 2026, důvod…") and "Stornováno" marker on the purchase.
- Open brief decisions still apply: effective date and T&C URL (legal), tier-bonus in qualification, approval of storno, limit for refunding expired points.
- Merge note: B1/B2 files in this branch are org versions with B11 edits; `origin/feature/points-engine` / `feature/data-model` hold the same files in single-line XML format — resolve conflicts in favour of these versions.
