# B1 — Data Model and Configuration

**Status:** Draft  
**Phase:** Implementation I  
**Depends on:** B0  
**Solution design references:** Chapters 5 and 11  
**Open point:** OP-06

## Objective

Create the secure, extensible Salesforce data model and configuration required by the loyalty engine, portal, back office, rewards, vouchers, and reporting.

## Required Scope

- Add loyalty member fields to Person Account, including unique external member number, status, vehicle information, profile-completion state, and marketing consent.
- Define the member-number generation and uniqueness strategy.
- Create the transaction, point-ledger, reward, voucher, and loyalty-configuration metadata.
- Decide and implement the campaign model: standard `Campaign` with a record type and custom fields, custom `Loyalty_Campaign__c`, or another approved configuration approach.
- Represent EneServis as a Business Account and decide whether Station is included as a SHOULD item.
- Create `Loyalty_Settings__mdt` for values that must be configurable rather than hardcoded.
- Define relationships, required fields, external IDs, uniqueness constraints, validation rules, record ownership, sharing, and delete behavior.
- Create least-privilege permission-set skeletons for managers, back-office users, integration users, and portal users.
- Keep API names in English and user-facing Czech text in Custom Labels where applicable.
- Assess whether seed data in `/data` must be created or updated.

## Decisions and Questions to Close

- **OP-06:** Select the campaign storage model and document the rationale.
- Confirm whether Point Ledger uses master-detail and how the balance is derived.
- Confirm all member profile and vehicle fields required for profile completion.
- Confirm Partner as Business Account and whether Station is in the first release.
- Confirm data retention and deletion behavior for transactions, ledger entries, and vouchers.

## Expected Deliverables

- Custom objects, fields, relationships, validation rules, and configuration metadata.
- Permission sets and initial access model.
- Data dictionary and relationship overview.
- Seed-data impact decision.
- Deployable metadata with validation results.

## Definition of Ready

- The final object and field inventory is approved.
- OP-06 and all relationship/security decisions are reviewed with the AI assistant and recorded.
- Downstream needs of B2 and B5–B9 are represented.
- Implementation and migration steps are documented.

## Verification

- Validate metadata deployment in the configured non-production org.
- Test required fields, validation rules, unique values, and relationship behavior.
- Verify create/read/update/delete and field-level access for each persona.
- Confirm the model supports the acceptance example and reporting requirements.

## Working Record

### 1. Final Assignment

_To be completed and approved before implementation._

### 2. Resolved Open Points

| ID/question | Decision | Approved by/date |
| --- | --- | --- |
| OP-06 | | |

### 3. Implementation Steps

_List metadata, security, deployment, seed-data, and verification steps in execution order._

### 4. Implementation and Test Results

_Record deployed components, validation results, deviations, and follow-up work._
