# B6 — Member Portal Foundation

**Status:** Draft  
**Phase:** Implementation II  
**Depends on:** B1, B2  
**Solution design references:** Chapters 8 and 13

## Objective

Create a secure, branded Experience Cloud portal in which a member can register, sign in, and view only their own loyalty information.

## Required Scope

- Configure an Experience Cloud site for Customer Community users.
- Implement self-registration that creates a Person Account and a User linked through `PersonContactId`.
- Provide login, navigation, logout, and recovery paths supported by the chosen site template/licence.
- Apply the EneOil brand kit, design tokens, typography, responsive behavior, and Czech user-facing copy.
- Provide Overview, point balance, point history, active campaigns (“Akce”), and navigation placeholders for rewards and vouchers.
- Build required LWCs and Apex controllers using secure sharing and field/object access checks.
- Configure sharing sets and access so a member sees only their own records.
- Handle empty, loading, and error states without exposing internal details.

## Decisions and Questions to Close

- Confirm site template, domain, licence, registration fields, and registration verification approach.
- Confirm exact pages, navigation, responsive layouts, and design source of truth.
- Confirm sharing-set mappings for every member-owned object.
- Confirm whether email verification, consent text, terms, and privacy links are required.
- Confirm campaign visibility rules and the point-history fields exposed to members.

## Expected Deliverables

- Experience Cloud site configuration and branding.
- Self-registration and member-user provisioning.
- Portal LWCs, Apex controllers, labels, navigation, and sharing configuration.
- Portal permission set/profile configuration.
- Security and functional test evidence.

## Definition of Ready

- UX, registration, licence, identity, sharing, and privacy decisions are reviewed with the AI assistant and approved.
- B1 and B2 data/service interfaces are stable.
- Detailed implementation and test steps are documented.

## Verification

- Register a new member and verify Person Account/User linkage and unique member number.
- Sign in as multiple members and prove strict record isolation.
- Verify balance, ledger history, campaigns, empty states, mobile layout, and Czech labels.
- Run Apex/controller tests and a manual Experience Cloud security review.

## Working Record

### 1. Final Assignment

_To be completed and approved before implementation._

### 2. Resolved Open Points

| Question | Decision | Approved by/date |
| --- | --- | --- |
| | | |

### 3. Implementation Steps

_List site, identity, LWC, Apex, sharing, labels, test, and deployment steps in order._

### 4. Implementation and Test Results

_Record components, security checks, test results, deviations, and follow-up work._
