# B0 — Org and Project Setup

**Status:** Draft  
**Phase:** Implementation I  
**Depends on:** None  
**Solution design reference:** Chapter 4

## Objective

Prepare a safe Salesforce environment and repository baseline on which all other blocks can be implemented and tested.

## Required Scope

- Confirm that the selected non-production org supports Sales Cloud and Experience Cloud.
- Perform an impact review before enabling Person Accounts because the change is irreversible.
- Enable and verify Person Accounts and Experience Cloud.
- Verify that the Salesforce DX project uses the API version defined in `sfdx-project.json`.
- Verify the locally selected default target org without changing or explicitly selecting a target org.
- Establish the metadata deployment and validation approach for the project.
- Confirm repository, branch, and pull-request conventions. Never work directly on `main` or `master`.
- Record environment prerequisites, missing licences, and manual setup steps.

## Decisions and Questions to Close

- Which non-production org is approved for implementation?
- Are Person Accounts already enabled, and has the irreversible-change impact been accepted?
- Is an Experience Cloud domain already configured?
- Which deployment validation and test commands are required for pull requests?

## Expected Deliverables

- Verified org capability checklist.
- Documented Person Account and Experience Cloud setup.
- Working Salesforce DX project baseline.
- Documented validation/deployment procedure for non-production environments.
- List of manual org steps that cannot be represented as metadata.

## Definition of Ready

- The final assignment and exclusions are written below.
- All org-impacting decisions have been reviewed with the AI assistant and approved.
- The implementation steps are complete and safe for a non-production org.
- The default target org has been independently confirmed by the developer.

## Verification

- Confirm Person Account record types and `PersonContactId` behavior.
- Confirm Experience Cloud can be configured and published in the approved non-production org.
- Run a metadata validation using the documented project procedure.
- Record evidence and any manual follow-up.

## Working Record

### 1. Final Assignment

_To be completed and approved before implementation._

### 2. Resolved Open Points

| Question | Decision | Approved by/date |
| --- | --- | --- |
| | | |

### 3. Implementation Steps

_To be completed after the assignment and decisions are approved._

### 4. Implementation and Test Results

_Record components, commands, results, deviations, and follow-up work._
