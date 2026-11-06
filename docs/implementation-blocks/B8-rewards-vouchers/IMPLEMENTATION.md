# B8 — Implementation (part 1: reward catalog in the portal)

**Branch:** `feature/B6-block` · **Date:** 2026-11-06 · **Status:** reward catalog deployed to org `hackathon`; site not yet published; redemption, vouchers and e-mail **not started**; not committed  
**Related:** [README.md](README.md) (assignment), [B6 implementation](../B6-member-portal-base/IMPLEMENTATION.md), [B7 implementation](../B7-portal-activities/IMPLEMENTATION.md), [B1 data model](../B1-data-model-config/data-model-config.md)

## 0. Scope of this part

Show the rewards loaded on `Reward__c` on the portal page **Odměny** (replaces the B6 placeholder). Read-only: no redeem button, no voucher, no point deduction. Covers the first README bullet: "Show active rewards with … point cost, CZK value, description, and member affordability state" — **except the partner** (see 4).

## 1. Org state (read-only check 2026-11-06)

| Item | Finding |
| --- | --- |
| `Reward__c` records | 5 records loaded by B4 seed (Barbora Dlapalová): *Mala sleva*, *Kontrola vozidla*, *Prezuti*, *Servisni sleva*, *Servisni prohlidka* |
| Fields | `Partner__c`, `Points_Cost__c`, `Value_CZK__c`, `Is_Active__c`, `Description__c`, `Sort_Order__c` |
| Validations | `Required_Program_Fields` (partner, cost, value), `Reward_Values_Valid` (cost > 0, value ≥ 0, partner = Business Account `Type = Partner`, active needs description) |
| Sharing | Internal and external OWD **Read** (Public Read Only) |
| `Loyalty_Member` (B1) | Read on `Reward__c` + all six fields |
| Note | The deploying user has no FLS on the reward fields, so active flags / costs of the 5 records could not be read from the CLI — the page shows exactly the records that are `Is_Active__c = true` with `Points_Cost__c > 0` |

## 2. Delivered components

| Area | Component | Change |
| --- | --- | --- |
| Apex – selector | `PortalRewardSelector.selectActiveCatalog()` — active, cost > 0, USER_MODE, ordered by `Sort_Order__c` (nulls last), cost, name | Method added |
| Apex – service | `PortalMemberService.getRewardCatalog()` — member from `UserInfo`, balance from roll-up, per reward: affordable, missing points, progress % | Method added |
| Apex – controller | `PortalMemberController.getRewardCatalog()` (not cacheable, same friendly-error handling) | Method added |
| Apex – DTO | `PortalMemberDto.RewardCatalog`, `PortalMemberDto.Reward` | Classes added |
| Apex – test | `PortalMemberControllerTest.shouldShowActiveRewardsWithAffordability_WhenMemberOpensCatalog` (inactive hidden, sort order, affordable / missing points) | Test added |
| LWC | `portalRewards` — balance, card per reward (name, cost, CZK value, description, progress bar, "Máte dostatek bodů" / "Chybí vám X bodů"), loading / error / empty / not-member states | New |
| Labels | `Portal_Rewards_Intro`, `_Balance`, `_Empty`, `_Value`, `_Affordable`, `_PointsMissing` (en_US + cs) | New |
| Site | View `odmeny`: `c:portalPlaceholder` → `c:portalRewards` (no other change vs. org) | Definition swapped |

Not changed: `Reward__c` metadata and records, permission sets (controller access already in `Loyalty_Member_Portal`), other pages; `portalPlaceholder` still used by Moje vouchery.

## 3. Validation results (org `hackathon`)

| Check | Result |
| --- | --- |
| Deploy (ID `0Afaj00000qckIRCAY`) | Succeeded |
| Apex tests `PortalMemberControllerTest`, `PortalActivityControllerTest`, `PortalRegistrationServiceTest`, `PortalRegistrationControllerTest` | **12/12 passed** |
| Coverage | `PortalRewardSelector` 100 %, `PortalMemberDto` 100 %, `PortalMemberController` 86 %, `PortalMemberService` 85 % |
| LWC lint | Pass |

Deploy command (default org):

```bash
D=force-app/main/default
sf project deploy start --test-level RunSpecifiedTests \
  --tests PortalMemberControllerTest --tests PortalActivityControllerTest \
  --tests PortalRegistrationServiceTest --tests PortalRegistrationControllerTest \
  -d $D/classes/selectors/PortalRewardSelector.cls -d $D/classes/PortalMemberDto.cls \
  -d $D/classes/services/PortalMemberService.cls -d $D/classes/controllers/PortalMemberController.cls \
  -d $D/classes/controllers/PortalMemberControllerTest.cls -d $D/lwc/portalRewards \
  -d $D/labels -d $D/translations -d $D/digitalExperiences/site/EneOil1/sfdc_cms__view/odmeny
```

Then publish the site.

## 4. Open / next steps (rest of B8)

- **Partner name not shown:** partner is a Business Account (OWD Private, members see only their own Account). Showing it needs a decision: system-mode read of `Partner__r.Name` only, or a copied text field on the reward.
- **Check the 5 seeded rewards** in the org: `Is_Active__c = true` and filled `Description__c`, otherwise they are hidden.
- Redemption (lock, balance check, `Redemption` ledger `VCH:<voucher-id>:REDEEM`, voucher `ENE-XXXX-XXXX`, `Request_Key__c`), Moje vouchery page, e-mail, operator flow — still subject to OP-09, OP-10, Q3.
