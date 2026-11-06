# B3 transaction seed build record

Design and scope: `docs/adlc/specs/2026-11-06-b3-transaction-seed.md`.
Mode: one implementer, independent final review. Only the parent operates the shared default org.
Branch: `feature/B3-transaction-input`, based on `e222efd`.

- T1 complete: generator, three fictional members, two campaigns, 12 scenarios, 251 bulk purchases, seven rejection/replay inputs and 263 expected outcomes. CSV regeneration is byte-for-byte deterministic.
- T2 complete: CLI-backed setup/import/verifier, production guard, per-row errors, content-aware idempotency, batches of 200. Twelve local unit tests passed. CSV/API timestamp comparison supports Python 3.9.
- T3 complete: user explicitly requested `PersonAccount.PersonAccount` visibility in the assigned `Loyalty_Manager` permission set. Generator and metadata updated. Successful final deployment `0Afaj00000qc2BsCAI`; REST describe confirms the record type is available to the assigned manager.
- T4 complete: three members, two campaigns and 263 purchases created. All input fields, member assignments and expected outcomes verified. There are 262 processed purchases, one expected blocked-member error, 270 ledger entries and 6,907 points. Balances: B3-MEMBER-001 = 3,385; B3-MEMBER-002 = 3,522; B3-MEMBER-003 = 0.
- Rejection verification complete: seven input rows produce zero inserts, one identical existing purchase and six rejected rows. Detailed row-level reports remain in ignored `.localdevserver/`.
- Replay verification complete: setup created zero members/campaigns; both purchase files created zero transactions and recognized all 263 existing inputs. Ledger count and balances remained unchanged.
- T5 complete: 17/17 existing B2 tests passed (`PointsCalculatorTest`, `LoyaltyTransactionServiceTest`), test run `707aj00001QL27N`. Test-run coverage 96%; reported org-wide coverage 45%. No Apex code was deployed. Artifacts are scoped to the B3 feature branch; no merge or release is included.

During verification another developer deployed a newer `Loyalty_Manager`, removing the newly added record-type access. Retrieved its current complete metadata, preserved its 80 field grants and three class grants, added only the requested record-type visibility and redeployed. The versioned B3 delta remains limited to the record-type grant. Later merges/deployments of the manager permission set must retain it. A no-op setup replay does not require creation privileges, but still compares all existing fixture fields.

Final live metadata retrieval confirmed no existing permission nodes were removed or changed; the sole addition is `PersonAccount.PersonAccount` visibility.

Independent review found one verification gap: transaction ownership was not compared with source member numbers. Fixed by checking all three expected seed members and every original transaction input against the CSV. Added a regression test proving correct points credited to a wrong member are rejected. Independent re-review passed with no remaining findings.

Unrelated B1 Czech translation work is excluded from this change. Only the record-type visibility hunk in its metadata generator belongs to B3.
