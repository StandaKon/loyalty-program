# B3 transaction seed data

## Problem and scope

The user requested versioned transaction test data on a new B3 feature branch and loading into the already configured development org. Size M, low risk, local to seed data and its loader. This implements the data/import slice of B3. The manual-entry UI, permissions changes and the 300-member/5,000-transaction B4 dataset remain outside this request.

## Design

Use portable CSV files and a Python standard-library loader invoking authenticated Salesforce CLI commands. A JSON tree-only dataset would not demonstrate the B3 CSV contract; anonymous Apex would add a second application input path. The loader resolves members by unique external member number and inserts purchases through the deployed B2 trigger. It never writes calculated points, balances, ledger entries or processing results.

Create three fictional Person Accounts, two dated October 2026 campaigns, twelve named scenarios and 251 bulk purchases. Stable B3-prefixed keys isolate the records. Campaigns use fixed dates so the dataset is deterministic. Positive scenarios cover the 109-point example, rounding, campaign thresholds and date boundaries. A blocked member exercises a stored business error. A separate rejected-row CSV covers unknown members, invalid totals, negative amounts, future dates and duplicate/conflicting POS IDs.

The loader checks that the default org is a sandbox or Developer Edition before writing. It does not select or change the target org. Repeated identical purchases are skipped after comparing their original inputs; conflicting keys fail without updates. Existing seed dependencies must match their defined configuration. Global campaigns can affect expected points, so verification reports discrepancies rather than changing other campaigns.

## Execution

The direct user request authorizes creating, loading and committing these seed artifacts. Run as one agent with an independent final review. Only the parent may write to or verify against the shared Salesforce org. No production writes, merge, or changes to pre-existing uncommitted B1 translation work. The user subsequently explicitly requested adding Person Account record-type access to the assigned `Loyalty_Manager` permission set. Deploy only that permission set and preserve this setting in its metadata generator.

1. Create `data/B3-transaction-input/` CSV fixtures, expected results and Czech instructions; add a deterministic generator under `scripts/python/`.
2. Add a CLI-backed loader and verifier under `scripts/python/`; use project API version and batches of at most 200 records.
3. Generate and inspect the CSV files, load dependencies and transactions, reconcile transaction results, ledger sums and member balances, then repeat the load to prove it creates no duplicates. Exercise rejected rows separately.
4. Record evidence in the B3 README and `.adlc/build/2026-11-06-b3-transaction-seed/progress.md`; commit only these paths on `feature/B3-transaction-input`.

## Verification

Expected results are explicit fixture values, not another points engine. Verify the 109-point breakdown as 45 fuel + 9 other + 55 campaign points, including separate campaign ledger awards of 5 and 50. Verify the blocked purchase has an error and no ledger, all other inputs produce their expected points, member balances equal ledger sums, the bulk set spans two API requests, rejected inputs have row-level errors and repeated loading leaves all counts and balances unchanged.
