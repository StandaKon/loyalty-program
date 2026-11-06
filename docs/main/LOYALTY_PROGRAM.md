# Loyalty Program – EnePumpa Klub (Salesforce)

> Main working doc. Phases: **1. Analysis → 2. Task breakdown → 3. Implementation.**
> Status legend: ⬜ todo · 🟡 in progress · ✅ done · ❓ needs decision
> Source: `AI-Hackathon-6-11-2026_tym-2.pdf` (Variant 2, Team 2A)

---

## 0. Context
- **Client (fictional):** EnePumpa a.s. – 120 fuel stations in CZ. Sells fuel + snacks, coffee, goods at the till.
- **Goal:** customers return → launch loyalty program **EnePumpa Klub**. Big loyalty platform = overkill; client already has **Sales Cloud** → simple program on existing SF.
- **Persona (reporting):** Petra Králová, Head of Loyalty.
- **Partner (fictional):** EneServis, s.r.o. – car service.
- **Environment:** clean SF org **without Loyalty Management package** + **Experience Cloud**. Repo: `./loyalty-program` (Enehano SFDX template).
- **Method:** AI-first delivery in ADLC.
- **Guarantor:** Lukáš Vavřín · **Day:** 2026-11-06.
- **Key milestones:** 10:45 checkpoint (scope approval) · 15:30 testing + demo prep · 15:45 demo vs. teams with same topic · 16:15 TOP 3 final.
- **Names/branding:** we may invent own names (station, club, partner) – must follow our Brand Kit.

## 1. Analysis

### 1.1 Business Requirements
| ID | Requirement | Priority (M/S/C) | Notes |
|----|-------------|------------------|-------|
| BR-01 | Simple loyalty program built on existing Sales Cloud (no LM package, no external platform) | M | |
| BR-02 | Members collect points (fuel, till purchases, campaigns, portal activities) and spend them on rewards | M | |
| BR-03 | Loyalty manager manages members, campaigns and reward catalog in SF | M | |
| BR-04 | Member self-service portal (Experience Cloud) | M | |
| BR-05 | Management report (Claude Artifact) connected to SF to steer the program | M | |
| BR-06 | Brand Kit (logo, colors, typography, tone of voice) – create first; consistent design & communication | M | Do at start |

### 1.2 Functional Requirements

#### A) Loyalty engine – Sales Cloud
| ID | Requirement | Related BR | Notes |
|----|-------------|------------|-------|
| FR-01 | Member management (create/view/edit members, balance, history) | BR-03 | |
| FR-02 | **Transaction**: 1 record per purchase from POS (customer pays once even if fuel + shop). No integration – simulate via **import or console** | BR-02 | |
| FR-03 | Transaction fields: total amount, fuel amount, liters, other amount (all non-fuel). Rule: `fuel + other = total`. **No line items, no product catalog** | BR-02 | Validation rule |
| FR-04 | Base points – fuel: **1 pt per whole liter** | BR-02 | floor(liters) |
| FR-05 | Base points – other: **1 pt per whole 20 CZK** | BR-02 | floor(other/20) |
| FR-06 | Portal activity: **profile completion (vehicle data) +100 pts, one-time** | BR-02 | |
| FR-07 | Portal activity: **marketing consent +50 pts, one-time** | BR-02 | |
| FR-08 | **Campaigns** run on top of base rules, apply **automatically to all members**. Configured by loyalty manager (validity period, condition, reward) – **not hardcoded** | BR-02, BR-03 | |
| FR-09 | Campaign 1 "Natankuj plnou": condition liters ≥ 40 in transaction → **+50 pts** | FR-08 | |
| FR-10 | Campaign 2 "Zastávka na cestě": condition other amount ≥ 150 CZK → **all base pts × 1.1, floor** | FR-08 | |
| FR-11 | Multiple campaigns can apply to one transaction. Multiplier applies **only to base pts**, not to bonus from other campaigns | FR-08 | |
| FR-12 | Points ledger – every point movement (earn/burn) recorded → balance + history | BR-02 | |
| FR-13 | **Reward catalog** managed in SF; rewards belong to partner | BR-03 | |
| FR-14 | Catalog content (partner EneServis): 500 pts = 200 CZK off tyre change · 1 200 pts = 500 CZK off service · 5 000 pts = free service inspection | FR-13 | Seed data |
| FR-15 | **Redemption**: generates **unique voucher code**; visible in portal **and sent by email**; member dictates code at the service | BR-02 | |
| FR-16 | Points deducted **immediately**; redemption **blocked if insufficient balance** | FR-15 | |
| FR-17 | Voucher has **no expiry** | FR-15 | |

**Acceptance example (must equal 109 pts):** 45 l for 1 710 CZK + coffee & biscuit 180 CZK → total 1 890, fuel 1 710, 45 l, other 180.
Base fuel 45 + base other 9 = 54 · "Zastávka na cestě" (54 × 1.1 = 59.4 → 59) = +5 · "Natankuj plnou" +50 · **Total 109**.

#### B) Member portal – Experience Cloud (logged-in member)
| ID | Requirement | Related BR | Notes |
|----|-------------|------------|-------|
| FR-20 | Member login | BR-04 | |
| FR-21 | Points balance + history of point movements | BR-04 | |
| FR-22 | Overview of active campaigns | BR-04 | |
| FR-23 | Activities for which member can earn points in portal (profile/vehicle, marketing consent) | BR-04 | FR-06, FR-07 |
| FR-24 | Reward catalog – redeem points for voucher | BR-04 | FR-15, FR-16 |
| FR-25 | Member sees own voucher codes | BR-04 | FR-15 |

#### C) Management report – Claude Artifact
| ID | Requirement | Related BR | Notes |
|----|-------------|------------|-------|
| FR-30 | Report connected to Salesforce (live data) | BR-05 | |
| FR-31 | Program KPIs: # members, new registrations, points redeemed, popular partners/rewards, campaigns | BR-05 | No sales data in SF → no sales impact |
| FR-32 | Partner voucher **budget** tracking | BR-05 | Petra |
| FR-33 | **Average % of points redeemed** (redemption rate) → budget planning for next year | BR-05 | CFO question |
| FR-34 | **Campaign performance** – which campaigns to repeat | BR-05 | Marketing question |

#### D) Bonus (optional, if time)
| ID | Requirement | Notes |
|----|-------------|-------|
| BON-01 | Voucher generated as image or PDF with embedded unique code | |
| BON-02 | Membership tiers (e.g. Standard / VIP) via qualifying points; higher tier = member benefit | |
| BON-03 | Points expiration: exactly **1 year** after credit; unused points removed. Should appear in reporting (expired pts metric) | Impacts ledger design (FIFO?) |
| BON-04 | Manual point adjustment (add/remove) for a member by back-office user via SF UI | |

### 1.3 Non-Functional Requirements
- NFR-01: Clean SF org, no Loyalty Management package; Sales Cloud + Experience Cloud only.
- NFR-02: Campaign rules are configuration, not code.
- NFR-03: Points are whole numbers; all partial calculations rounded **down**.
- NFR-04: No input data provided → after data model is fixed, generate **test data with AI** and load to org.
- NFR-05: Test scenarios derived from approved solution design.
- NFR-06: Portal + emails follow Brand Kit.
- NFR-07: Metadata/API names in English (repo convention).

### 1.4 Key Concepts / Glossary
- **Member:** customer enrolled in EnePumpa Klub (portal user).
- **Transaction:** one POS purchase (total / fuel / liters / other).
- **Base points:** points from fuel liters + other amount.
- **Campaign:** configurable rule on top of base points (period, condition, reward = fixed bonus or multiplier).
- **Reward:** catalog item of partner, priced in points.
- **Voucher:** issued reward with unique code.
- **Ledger entry:** single point movement (+/-).

### 1.5 Data Model (draft)
**Reference:** [SF Data Model Gallery – Loyalty Programs](https://developer.salesforce.com/docs/platform/data-models/guide/loyalty-programs.html) – **inspiration only**, our model is a simple custom version.

#### 1.5.1 Reference model (SF Loyalty Management) – inspiration only
_Relationships summarized from std LM model; not used directly._

| Area | Object (std LM) | Purpose / key relations |
|------|-----------------|-------------------------|
| Program | `LoyaltyProgram`, `LoyaltyProgramCurrency` | Program + point currency |
| Program | `LoyaltyTierGroup` / `LoyaltyTier`, `LoyaltyTierBenefit`, `Benefit*` | Tiers & benefits |
| Member | `LoyaltyProgramMember`, `LoyaltyMemberCurrency`, `LoyaltyMemberTier` | Member, balance, tier |
| Transactions | `TransactionJournal`, `LoyaltyLedger` | Activity + point movements |
| Rewards | `VoucherDefinition` / `Voucher` | Template / issued voucher |
| Promotions | `Promotion`, `LoyaltyProgramPromotion`, `MarketSegment` | Campaigns |
| Partners | `LoyaltyProgramPartner`, `…PartnerLedger`, `…PartnerPromotion` | Partner earn/burn |

#### 1.5.2 Our model (proposal – to confirm)
| Object | Type | Purpose | Key fields |
|--------|------|---------|------------|
| Member | **Person Account** (std, portal user) | Club member | points balance, profile completed, marketing consent, vehicle info |
| `Loyalty_Transaction__c` | custom | POS purchase | member, date, total, fuel amount, liters, other amount, base pts, bonus pts, total pts |
| `Loyalty_Campaign__c` | custom | Configurable campaign | valid from/to, active, condition field (liters/other), threshold, reward type (bonus/multiplier), value |
| `Point_Ledger__c` | custom | Every +/- movement | member, points, type (earn/redeem/activity/campaign/adjust/expire), source (transaction/campaign/voucher) |
| `Partner__c` (or Account) | custom/std | EneServis | name |
| `Reward__c` | custom | Catalog item | partner, name, points cost, CZK value (for budget) |
| `Voucher__c` | custom | Issued reward | member, reward, unique code, points spent, issued date, status |

### 1.6 Processes / Flows
1. **Enrollment** – member registered (self-registration in portal or by manager ❓OP-11).
2. **Earn – transaction** – import/console → calc base pts → evaluate active campaigns → ledger entries → balance update.
3. **Earn – portal activity** – complete profile (vehicle) / give marketing consent → one-time bonus.
4. **Redeem** – member picks reward in portal → balance check → deduct pts + create voucher with unique code → show in portal + email.
5. **Campaign management** – loyalty manager creates/edits campaign (period, condition, reward).
6. **Reporting** – Claude Artifact reads SF data → KPIs.
7. _(Bonus)_ Expiration job, tier recalculation, manual adjustment.

### 1.7 Integrations
| System | Direction | Data | Notes |
|--------|-----------|------|-------|
| POS (simulated) | → SF | Transactions | No integration; Data Import / console |
| Email | SF → member | Voucher code | Branded template |
| Claude Artifact | SF → report | KPIs | Live connection to SF |

### 1.8 Open Points
| ID | Question | Owner | Status | Answer / Decision |
|----|----------|-------|--------|-------------------|
| OP-01 | LM license vs. custom objects? | | ✅ | Custom – clean org without LM (assignment) |
| OP-02 | Member = Contact, Person Account, or custom object? (portal user needs Contact) | | ✅ | **Person Account** (enable in org); loyalty fields on Account. PA = Account + hidden Contact (`PersonContactId`) → portal user links to that Contact. Self-registration creates PA + User. License: **Customer Community** (not Partner – Partner users can't be PA). Portal = customers only; EneServis = business Account, no portal access |
| OP-03 | What earns points? | | ✅ | Defined in assignment (FR-04–FR-11) |
| OP-04 | How is transaction linked to member (member/card number in import)? Transactions of non-members? | | ✅ | `Member_Number__c` (External ID, unique) on Person Account = card no., shown in portal. Import matches via it. **Members only** imported |
| OP-05 | Campaign config model – how generic (field + operator + threshold; reward = bonus / multiplier)? | | ✅ | Single condition: field picklist (Liters / Other / Fuel CZK / Total CZK) + min value (≥); reward picklist (Fixed bonus / Base multiplier) + value; valid from/to, active |
| OP-06 | Use std `Campaign` object or custom `Loyalty_Campaign__c`? Options: std Campaign + RT & custom fields / custom object / CMDT | | ❓ | |
| OP-07 | Calc engine: Apex trigger vs. Flow? | | ❓ | |
| OP-08 | Enrollment: portal self-registration vs. created by manager? (KPI "new registrations") | | ✅ | Self-registration in portal; manual creation from back-office = SHOULD (SD) |
| OP-09 | Budget tracking: CZK value of each reward (free inspection = ? CZK) and budget amount? | | ❓ | |
| OP-10 | Unique voucher code format & generation (uniqueness guarantee) | | ❓ | |
| OP-11 | Claude Artifact ↔ SF connection – how (SF MCP connector / export)? | | ❓ | |
| OP-12 | Portal & email language – Czech? | | ✅ | Czech (SD NFR-10) |
| OP-13 | Transaction storno/return – out of scope? | | ❓ | Not in assignment |
| OP-14 | Which bonuses do we take (BON-01..04)? | | ❓ | |
| OP-15 | Brand Kit – own names (station / club / partner)? | | ✅ | EneOil / EneOil Klub / EneServis (`brand/`) |
| OP-16 | Effort estimate in MD for real implementation (SteerCo) | | ❓ | From user-story backlog |
| Q3–Q10 | Assumptions from `SolutionDesign.md` ch. 11 (operator, consent, profile fields, expiry, tiers, multipliers) | | ❓ | See SD docx ch. 17 |

### 1.9 Decisions Log
| Date | Decision | Reason |
|------|----------|--------|
| 2026-11-06 | Simplified custom data model; SF LM model used as inspiration only | Assignment: clean org without LM; keep it simple |
| 2026-11-06 | Member = Person Account | B2C standard, native portal user + self-registration (OP-02) |

### 1.10 Out of Scope
- POS integration (simulated by import/console)
- Transaction line items / product catalog
- Sales impact measurement (no sales data in SF)

## 2. Deliverables (from assignment)
| # | Deliverable | Notes | Status |
|---|-------------|-------|--------|
| D-1 | Intent presentation (max 10 min), SteerCo style: business case, scope, HL solution design, assumptions, constraints, **effort estimate in MD for real client implementation** | Use **Enehano Design System**; checkpoint 10:45 | ⬜ |
| D-2 | Documentation: analytical (needs/requirements, processes) + technical (data model, components, automations) | This doc as base | ⬜ |
| D-3 | Test scenarios + test results | | ⬜ |
| D-4 | Working solution: loyalty engine (Sales Cloud) + member portal (Experience Cloud) | | ⬜ |
| D-5 | Claude Artifact – management report connected to SF | | ⬜ |
| D-6 | Final demo (15 min) – end-to-end scenario | | ⬜ |
| D-0 | Brand Kit | First thing | ⬜ |

## 3. Implementation Blocks
> Source: `EneOil-Klub-Solution-Design.docx` (SD) + `SolutionDesign.md`. High-level only; detail per block when we start it.
> Day plan: **Impl I** 11:15–12:30 (B1–B4) · **Impl II** 13:00–15:30 (B5–B9) · **Test & demo** 15:30–15:45 (B10).
> Detailed working documentation: [`../implementation-blocks/README.md`](../implementation-blocks/README.md).

| Block | Name | Scope (high-level) | Main components | SD ref | Depends on | Open points | Phase | Status |
|-------|------|--------------------|-----------------|--------|------------|-------------|-------|--------|
| B0 | Org & project setup | Enable Person Accounts, Experience Cloud enabled, repo `loyalty-program` connected to org, deploy pipeline | Org settings, sfdx project | ch. 4 | – | – | Impl I | ⬜ |
| B1 | Data model & config | Person Account loyalty fields (`Member_Number__c` auto, status, vehicle, consents), Transaction, Point Ledger (MD), Campaign, Reward, Voucher, Partner (Business Acc), Station (SHOULD), `Loyalty_Settings__mdt`; permission sets skeleton | Objects, fields, CMDT, PS | ch. 5, 11 | B0 | OP-06 | Impl I | ⬜ |
| B2 | Points engine | Transaction processing: validation, idempotence (POS ID), base points, campaign evaluation (by purchase date), ledger entries, roll-up balance; bulk-safe | Apex (trigger + service) | ch. 6 | B1 | OP-07, Q10 | Impl I | ⬜ |
| B3 | Transaction input | CSV import (sample CSV), manual entry / "Simulovat nákup" | Data Import / sf CLI, screen flow | ch. 9 | B2 | – | Impl I | ⬜ |
| B4 | Test data & engine tests | AI-generated seed data (stations, 300 members, 5 000 txns, campaign history, vouchers); Apex tests T01–T25 | Data scripts, Apex tests | ch. 14, 15 | B2, B3 | – | Impl I | ⬜ |
| B5 | Back-office app | Lightning App „EneOil Klub“, member 360° page, list views, campaign & reward management; manual point adjustment (SHOULD) | App, FlexiPages, list views, quick action | ch. 9 | B1 | – | Impl II | ⬜ |
| B6 | Member portal – base | Experience site (Customer Community), self-registration → Person Account, login, navigation, branding (tokens/fonts), Overview, points history, campaigns (Akce) | Experience Cloud, LWC, Apex controllers, sharing sets | ch. 8, 13 | B1, B2 | – | Impl II | ⬜ |
| B7 | Portal activities | Earn points: profile completion +100, marketing consent +50 (one-time, unique key) | LWC + Apex | ch. 6.3 | B6 | Q4, Q5 | Impl II | ⬜ |
| B8 | Rewards & vouchers | Reward catalog, redeem (server-side balance check, atomic, double-click safe), code `ENE-XXXX-XXXX`, My vouchers, branded email; operator verification in SF (SHOULD) | LWC, Apex, email template, operator screen flow | ch. 7 | B6 | OP-09, OP-10, Q3 | Impl II | ⬜ |
| B9 | Management report | Claude artifact connected to SF: KPIs, redemption rate, voucher budget, CFO projection, campaign performance | Claude artifact, read-only integration user | ch. 10 | B4 (data) | OP-11, OP-09 | Impl II | ⬜ |
| B10 | Testing & demo | Test log (T01–T29 + AC), E2E demo script (register → buy → points → redeem → email → report) | Test log, demo | ch. 14 | all | – | Test | ⬜ |
| B11 | Bonuses (COULD) | Order: voucher PDF/image → points expiration (FIFO, report metric) → tiers Okreska/Dálnice → transaction storno | Apex batch, LWC, PDF | ch. 2 (E10) | B2, B8 | OP-13, OP-14, Q8, Q9 | If time | ⬜ |

**Parallel tracks (non-dev):** D-1 SteerCo deck (Enehano Design System, effort in MD – OP-16) · D-2 documentation = SD docx.

### 3.1 Task Breakdown (per block, filled when block starts)
| ID | Block | Task | Type (Apex/LWC/Flow/Metadata/Data) | Depends on | Status |
|----|-------|------|------------------------------------|------------|--------|
| T-01 | | | | | ⬜ |

## 4. WBS & Effort Estimate (real client implementation, MD)
> Estimate for **real implementation at the client** (SteerCo, OP-16), not the hackathon day. 1 MD = 8 h. Scope = MUST + SHOULD from SD; bonuses (B11) and POS integration priced as options.

### 4.1 WBS by block (Analysis / Implementation / Testing)
| WBS | Block | Analysis | Implementation | Testing | Total |
|-----|-------|---------:|---------------:|--------:|------:|
| B0 | Org & project setup | 0.5 | 1 | 0.5 | 2 |
| B1 | Data model & config | 2 | 3 | 1 | 6 |
| B2 | Points engine | 2 | 5 | 3 | 10 |
| B3 | Transaction input (CSV, manual) | 1 | 2 | 1 | 4 |
| B4 | Test data & engine tests | 0.5 | 2 | 0.5 | 3 |
| B5 | Back-office app (+ manual adjustment) | 1.5 | 4 | 1.5 | 7 |
| B6 | Member portal – base | 3 | 8 | 3 | 14 |
| B7 | Portal activities | 0.5 | 2 | 1 | 3.5 |
| B8 | Rewards, vouchers, email, operator | 2 | 6 | 2.5 | 10.5 |
| B9 | Management report | 2 | 4 | 1.5 | 7.5 |
| | **Blocks subtotal** | **15** | **37** | **15.5** | **67.5** |

### 4.2 Project-level WBS
| WBS | Phase / item | MD |
|-----|--------------|---:|
| **1** | **Analysis** | **24** |
| 1.1 | Kickoff, requirement workshops, backlog (user stories) | 3 |
| 1.2 | Solution design, data model, security model | 3 |
| 1.3 | Portal UX/UI design (brand kit, mobile-first mockups) | 3 |
| 1.4 | Block-level analysis B0–B9 (see 4.1) | 15 |
| **2** | **Implementation** | **41** |
| 2.1 | Block implementation B0–B9 (see 4.1) | 37 |
| 2.2 | Deployment & release management (SIT → UAT → PROD) | 2 |
| 2.3 | Documentation (technical, admin guide) & key-user training | 2 |
| **3** | **Testing** | **26.5** |
| 3.1 | Unit / functional tests per block (see 4.1) | 15.5 |
| 3.2 | SIT – end-to-end scenarios (T01–T29) | 3 |
| 3.3 | UAT support | 4 |
| 3.4 | Bug fixing | 4 |
| **4** | **Go-live & hypercare** (2 weeks) | **3** |
| | **Subtotal (1–4)** | **94.5** |
| 5 | Project management & coordination (15 %) | 14 |
| 6 | Contingency (15 % of subtotal + PM) | 16.5 |
| | **TOTAL** | **125 MD** |

> Master version: `EneOil-Klub-WBS-odhad.xlsx` (formulas, PM % / contingency % editable on sheet „Souhrn“).

**Phase split (without PM & contingency):** Analysis 24 MD (25 %) · Implementation 41 MD (43 %) · Testing 26.5 MD (28 %) · Go-live 3 MD (3 %).

### 4.3 Optional items (not in total)
| Item | MD |
|------|---:|
| B11a Voucher as PDF / image | 3 |
| B11b Points expiration (FIFO, batch, report metric) | 6 |
| B11c Tiers Okreska / Dálnice | 7 |
| B11d Transaction storno | 3 |
| POS integration (real-time API instead of CSV) | 10–15 |
| **Bonuses total (B11a–d)** | **19** |

### 4.4 Assumptions
- One Salesforce org, Sales Cloud + Experience Cloud licences provided by client (licence cost not included).
- Transactions via CSV import / manual entry (no POS integration in base scope).
- One partner (EneServis), Czech language only, brand kit delivered (EneOil).
- Client provides key user for workshops and UAT; max. 2 UAT rounds.
- Estimate to be refined after OP-06 / OP-07 / OP-11 are closed.

### 4.5 Risks (full register: Excel sheet „Rizika“, P × D, 1–3)
| ID | Risk | Score | Mitigation |
|----|------|------:|------------|
| R01 | Enabling Person Accounts is irreversible (real org impact) | 6 | Impact analysis + sandbox test before B1 |
| R02 | Customer Community licence cost/limits at scale | 6 | Login-based licence calc, active-member estimate |
| R04 | Double voucher redemption / double points | 6 | Record lock, idempotency keys, tests T21/T28 |
| R06 | Claude artifact ↔ SF connection (OP-11) | 6 | Read-only integration user, fallback SF dashboard |
| R08 | POS/CSV data quality | 6 | Validation, error status + list view, manual adjustment |
| R12 | Scope creep (bonuses, POS integration) | 6 | MoSCoW, change requests, options priced separately |
| R03, R05, R07, R09–R11, R13, R14 | Bulk limits, campaign model, email deliverability, GDPR, fraud, voucher budget, key-user availability, mobile UX | 3–4 | See Excel |

## 5. Implementation Notes
_Per-task notes, deployed components, test results._
