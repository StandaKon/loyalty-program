"""Check import failure modes locally without Salesforce credentials."""

import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import load_b3_data as loader
from generate_b3_data import DATA, FIELDS


class ImportTests(unittest.TestCase):
    def setUp(self):
        self.row = loader.csv_rows(DATA / "transactions.csv")[1][0]

    def load_rows(self, rows, existing=(), responses=None):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "input.csv"
            import csv
            with source.open("w", newline="") as stream:
                writer = csv.DictWriter(stream, fieldnames=FIELDS)
                writer.writeheader()
                writer.writerows(rows)
            report = Path(directory) / "report.json"
            members = [{"Id": "member-id", "Member_Number__c": self.row["Member_Number__c"]}]
            with patch.object(loader, "query", side_effect=[members, list(existing)]), \
                    patch.object(loader, "insert_records", return_value=responses or []) as insert:
                result = loader.load(source, report)
                return result, json.loads(report.read_text()), insert.call_args.args[1]

    def test_identical_existing_purchase_is_not_written(self):
        record = {**loader.prepare(self.row), "Member__c": "member-id"}
        counts, _, pending = self.load_rows([self.row], [record])
        self.assertEqual(counts, {"inserted": 0, "existing": 1, "rejected": 0})
        self.assertEqual(pending, [])

    def test_conflicting_existing_purchase_is_rejected(self):
        record = {**loader.prepare(self.row), "Member__c": "member-id", "Liters__c": "46.000"}
        counts, report, pending = self.load_rows([self.row], [record])
        self.assertEqual(counts["rejected"], 1)
        self.assertIn("conflict", report["rows"][0]["error"])
        self.assertEqual(pending, [])

    def test_unknown_member_is_rejected_with_line(self):
        counts, report, pending = self.load_rows([{**self.row, "Member_Number__c": "unknown"}])
        self.assertEqual(counts["rejected"], 1)
        self.assertEqual(report["rows"][0]["line"], 2)
        self.assertIn("Unknown member", report["rows"][0]["error"])
        self.assertEqual(pending, [])

    def test_duplicate_pending_purchase_is_not_reported_as_existing(self):
        failure = {"success": False, "errors": [{"message": "Rejected by B1"}]}
        counts, report, pending = self.load_rows([self.row, self.row], responses=[failure])
        self.assertEqual(counts, {"inserted": 0, "existing": 0, "rejected": 2})
        self.assertEqual(len(pending), 1)
        self.assertIn("Duplicate POS", report["rows"][1]["error"])

    def test_nonfinite_or_overprecision_inputs_are_rejected(self):
        for value in ["NaN", "Infinity", "0.001", "1,00"]:
            with self.subTest(value=value):
                with self.assertRaises((ValueError, loader.InvalidOperation)):
                    loader.prepare({**self.row, "Other_Amount__c": value})

    def test_timestamps_require_timezone(self):
        with self.assertRaisesRegex(ValueError, "timezone"):
            loader.prepare({**self.row, "Purchased_At__c": "2026-10-15T10:00:00"})

    def test_salesforce_and_csv_timestamp_formats_match(self):
        self.assertEqual(loader.timestamp("2026-10-15T10:00:00.000+0000"),
                         loader.timestamp("2026-10-15T10:00:00Z"))

    def test_setup_replay_requires_no_record_type_grant_when_members_exist(self):
        members = [{**row, "RecordTypeId": "person-type"}
                   for row in loader.csv_rows(DATA / "members.csv")[1]]
        campaigns = loader.csv_rows(DATA / "campaigns.csv")[1]
        with patch.object(loader, "query", side_effect=[
                [{"Id": "person-type", "DeveloperName": "PersonAccount"}], members, campaigns]), \
                patch.object(loader, "sf", return_value={"recordTypeInfos": []}), \
                patch.object(loader, "insert_records", return_value=[]) as insert:
            loader.setup()
            self.assertTrue(all(call.args[1] == [] for call in insert.call_args_list))

    def test_setup_rejects_missing_record_type_grant_before_creation(self):
        with patch.object(loader, "query", side_effect=[
                [{"Id": "person-type", "DeveloperName": "PersonAccount"}], []]), \
                patch.object(loader, "sf", return_value={"recordTypeInfos": []}), \
                patch.object(loader, "insert_records") as insert:
            with self.assertRaisesRegex(RuntimeError, "grant record-type access"):
                loader.setup()
            insert.assert_not_called()

    def test_batching_spans_two_requests(self):
        batches = []

        def request(*args, **kwargs):
            body_path = args[args.index("--body") + 1][1:]
            body = json.loads(Path(body_path).read_text())
            batches.append(len(body["records"]))
            return [{"success": True, "id": str(i)} for i in range(len(body["records"]))]

        with patch.object(loader, "sf", side_effect=request):
            self.assertEqual(len(loader.insert_records("Loyalty_Transaction__c", [{}] * 251)), 251)
        self.assertEqual(batches, [200, 51])

    def test_production_guard_prevents_write(self):
        with patch.object(loader, "query", return_value=[{"Id": "prod", "IsSandbox": False, "OrganizationType": "Enterprise Edition"}]):
            with self.assertRaisesRegex(RuntimeError, "restricted"):
                loader.check_org()

    def test_verifier_rejects_correct_points_credited_to_wrong_member(self):
        fixture = loader.csv_rows(DATA / "expected.csv")[1][0]
        row = {**loader.prepare(self.row), "Id": "tx-id", "Member__c": "wrong-member",
               "Processing_Status__c": "Processed", "Processing_Error__c": None,
               "Base_Fuel_Points__c": 45, "Base_Other_Points__c": 9,
               "Campaign_Points__c": 55, "Total_Points__c": 109}
        ledger = [{"Transaction__c": "tx-id", "Member__c": "wrong-member", "Points__c": points}
                  for points in [54, 5, 50]]
        members = [{"Id": str(i), "Member_Number__c": f"B3-MEMBER-{i:03}", "Points_Balance__c": 0}
                   for i in range(1, 4)]
        read_csv = loader.csv_rows

        def read_fixture(path):
            fields, rows = read_csv(path)
            return (fields, [fixture]) if Path(path).name == "expected.csv" else (fields, rows)

        with patch.object(loader, "csv_rows", side_effect=read_fixture), \
                patch.object(loader, "query", side_effect=[[row], ledger, members, *[[{"total": 0}]] * 3]):
            with self.assertRaisesRegex(RuntimeError, "member do not match"):
                loader.verify()


if __name__ == "__main__":
    unittest.main()
