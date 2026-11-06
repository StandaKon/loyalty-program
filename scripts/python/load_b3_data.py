#!/usr/bin/env python3
"""Load/verify B3 seed data using the locally configured Salesforce CLI target."""

import argparse
import csv
import json
import os
from collections import defaultdict
from datetime import datetime
from decimal import Decimal, InvalidOperation
from pathlib import Path
import subprocess
import sys
import tempfile

from generate_b3_data import DATA, FIELDS, ROOT

VERSION = json.loads((ROOT / "sfdx-project.json").read_text())["sourceApiVersion"]
NUMBERS = {"Total_Amount__c", "Fuel_Amount__c", "Liters__c", "Other_Amount__c",
           "Threshold__c", "Reward_Value__c"}


def sf(*args, as_json=True):
    command = ["sf", *args, *(["--json"] if as_json else [])]
    result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True,
                            env={**os.environ, "SF_DISABLE_LOG_FILE": "true"})
    if result.returncode:
        raise RuntimeError(result.stdout.strip() or result.stderr.strip())
    payload = json.loads(result.stdout)
    return payload["result"] if as_json else payload


def query(statement):
    result = sf("data", "query", "--api-version", VERSION, "--query", statement)
    if not result["done"]:
        raise RuntimeError("Query was truncated. Refine the seed-key filter before proceeding.")
    return result["records"]


def quote(value):
    return "'" + value.replace("\\", "\\\\").replace("'", "\\'") + "'"


def csv_rows(path):
    with Path(path).open(newline="", encoding="utf-8-sig") as stream:
        reader = csv.DictReader(stream)
        if not reader.fieldnames or len(set(reader.fieldnames)) != len(reader.fieldnames):
            raise ValueError(f"Missing or duplicate CSV headers in {path}")
        rows = list(reader)
        if any(None in row or any(v is None for v in row.values()) for row in rows):
            raise ValueError(f"Incorrect column count in {path}")
        return reader.fieldnames, rows


def timestamp(value):
    value = str(value).replace("Z", "+00:00")
    # Salesforce returns +0000; Python 3.9 requires the colon in +00:00.
    if len(value) >= 5 and value[-5] in "+-" and value[-4:].isdigit():
        value = value[:-2] + ":" + value[-2:]
    result = datetime.fromisoformat(value)
    if result.tzinfo is None:
        raise ValueError("Purchased_At__c must include a timezone.")
    return result


def normalize(field, value):
    if value is None:
        return None
    if field in NUMBERS:
        return Decimal(str(value))
    if field.endswith("_At__c"):
        return timestamp(value)
    if field == "Is_Enabled__c":
        return str(value).lower() == "true"
    return value


def matches(expected, actual):
    return all(normalize(key, value) == normalize(key, actual.get(key))
               for key, value in expected.items() if key != "attributes")


def insert_records(object_name, records):
    results = []
    for offset in range(0, len(records), 200):
        batch = [{**row, "attributes": {"type": object_name}} for row in records[offset:offset + 200]]
        with tempfile.TemporaryDirectory(prefix="b3-import-") as directory:
            body = Path(directory) / "request.json"
            body.write_text(json.dumps({"allOrNone": False, "records": batch}))
            response = sf("api", "request", "rest", f"/services/data/v{VERSION}/composite/sobjects",
                          "--method", "POST", "--body", f"@{body}", as_json=False)
        if not isinstance(response, list) or len(response) != len(batch):
            raise RuntimeError(f"Unexpected collection response: {response}")
        results.extend(response)
    return results


def check_org():
    org = query("SELECT Id, IsSandbox, OrganizationType FROM Organization WITH USER_MODE LIMIT 1")[0]
    if not org["IsSandbox"] and org["OrganizationType"] != "Developer Edition":
        raise RuntimeError("Seed writes/verification are restricted to sandbox or Developer Edition orgs.")
    print(f"Default org: {org['Id']} ({org['OrganizationType']})")


def setup():
    record_types = query("SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Account' "
                         "AND IsPersonType = true AND IsActive = true WITH USER_MODE")
    describe = sf("sobject", "describe", "--sobject", "Account", "--api-version", VERSION)
    available = {r["recordTypeId"] for r in describe["recordTypeInfos"] if r["available"]}
    preferred = [row for row in record_types if row["DeveloperName"] == "PersonAccount"]
    if len(preferred) == 1:
        record_type = preferred[0]["Id"]
    elif len(record_types) == 1:
        record_type = record_types[0]["Id"]
    else:
        raise RuntimeError("A unique Person Account record type is required.")
    for filename, object_name, key in [("members.csv", "Account", "Member_Number__c"),
                                        ("campaigns.csv", "Loyalty_Campaign__c", "Name")]:
        fields, rows = csv_rows(DATA / filename)
        if object_name == "Account":
            for row in rows:
                row["RecordTypeId"] = record_type
            fields.append("RecordTypeId")
        existing = query(f"SELECT Id, {', '.join(fields)} FROM {object_name} "
                         f"WHERE {key} IN ({','.join(quote(row[key]) for row in rows)}) WITH USER_MODE")
        by_key = defaultdict(list)
        for row in existing:
            by_key[row[key].casefold()].append(row)
        pending = []
        for row in rows:
            found = by_key[row[key].casefold()]
            if found and (len(found) != 1 or not matches(row, found[0])):
                raise RuntimeError(f"Seed dependency conflict: {row[key]}. No existing record was updated.")
            if not found:
                pending.append({k: (v.lower() == "true" if k == "Is_Enabled__c" else v) for k, v in row.items()})
        if object_name == "Account" and pending and record_type not in available:
            raise RuntimeError("No Person Account record type is available to the CLI user. "
                               "An administrator must grant record-type access before setup can create members.")
        results = insert_records(object_name, pending)
        failed = [r for r in results if not r["success"]]
        if failed:
            raise RuntimeError(f"{filename}: {json.dumps(failed)}")
        print(f"{filename}: created {len(pending)}, existing {len(rows) - len(pending)}")


def prepare(row):
    if any(not value.strip() for value in row.values()):
        raise ValueError("All seven purchase inputs must be populated, including explicit zeros.")
    for key in NUMBERS.intersection(row):
        amount = Decimal(row[key])
        scale = 3 if key == "Liters__c" else 2
        if not amount.is_finite() or amount != amount.quantize(Decimal(10) ** -scale):
            raise ValueError(f"{key}: expected a finite decimal with at most {scale} places.")
    timestamp(row["Purchased_At__c"])
    return {k: v for k, v in row.items() if k != "Member_Number__c"}


def load(path, report):
    fields, rows = csv_rows(path)
    if fields != FIELDS:
        raise ValueError(f"Expected CSV columns in this order: {','.join(FIELDS)}")
    members = query("SELECT Id, Member_Number__c FROM Account WHERE IsPersonAccount = true "
                    "AND Member_Number__c LIKE 'B3-MEMBER-%' WITH USER_MODE")
    members_by_number = {r["Member_Number__c"].casefold(): r["Id"] for r in members}
    existing = query(f"SELECT Id, Member__c, {', '.join(k for k in FIELDS if k != 'Member_Number__c')} "
                     "FROM Loyalty_Transaction__c WHERE POS_Transaction_Id__c LIKE 'B3:%' WITH USER_MODE")
    by_key = {r["POS_Transaction_Id__c"].casefold(): r for r in existing}
    pending, results, pending_keys = [], [], set()
    for line, row in enumerate(rows, 2):
        outcome = {"line": line, "pos_id": row["POS_Transaction_Id__c"]}
        try:
            if not row["POS_Transaction_Id__c"].startswith("B3:"):
                raise ValueError("This seed loader accepts only B3-prefixed POS IDs.")
            record = prepare(row)
            member = members_by_number.get(row["Member_Number__c"].casefold())
            if not member:
                raise ValueError(f"Unknown member: {row['Member_Number__c']}")
            record["Member__c"] = member
            key = row["POS_Transaction_Id__c"].casefold()
            if key in pending_keys:
                raise ValueError("Duplicate POS ID in this CSV; retain one purchase row per POS ID.")
            if key in by_key:
                if not matches(record, by_key[key]):
                    raise ValueError("POS ID conflict: existing purchase has different inputs.")
                outcome["result"] = "existing"
            else:
                by_key[key] = record
                pending_keys.add(key)
                pending.append((record, outcome))
                continue
        except (ValueError, InvalidOperation) as error:
            outcome.update(result="rejected", error=str(error))
        results.append(outcome)
    responses = insert_records("Loyalty_Transaction__c", [r for r, _ in pending])
    for (_, outcome), response in zip(pending, responses):
        outcome["result"] = "inserted" if response["success"] else "rejected"
        if response["success"]:
            outcome["id"] = response["id"]
        else:
            outcome["error"] = response["errors"]
        results.append(outcome)
    results.sort(key=lambda item: item["line"])
    report = Path(report)
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text(json.dumps({"file": str(path), "rows": results}, indent=2) + "\n")
    counts = {state: sum(r["result"] == state for r in results) for state in ("inserted", "existing", "rejected")}
    print(f"{Path(path).name}: {counts}; report: {report}")
    return counts


def verify():
    _, expected = csv_rows(DATA / "expected.csv")
    fields = ["Id", "Member__c", "POS_Transaction_Id__c", "Processing_Status__c", "Processing_Error__c",
              "Base_Fuel_Points__c", "Base_Other_Points__c", "Campaign_Points__c", "Total_Points__c"]
    fields = list(dict.fromkeys(fields + [field for field in FIELDS if field != "Member_Number__c"]))
    rows = query(f"SELECT {', '.join(fields)} FROM Loyalty_Transaction__c "
                 "WHERE POS_Transaction_Id__c LIKE 'B3:%' WITH USER_MODE")
    by_key = {r["POS_Transaction_Id__c"]: r for r in rows}
    ledger = query("SELECT Member__c, Transaction__c, Entry_Type__c, Points__c FROM Point_Ledger__c "
                   "WHERE Transaction__r.POS_Transaction_Id__c LIKE 'B3:%' WITH USER_MODE")
    by_transaction = defaultdict(list)
    for entry in ledger:
        by_transaction[entry["Transaction__c"]].append(entry)
    members = query("SELECT Id, Member_Number__c, Points_Balance__c FROM Account "
                    "WHERE Member_Number__c LIKE 'B3-MEMBER-%' WITH USER_MODE")
    member_ids = {m["Member_Number__c"]: m["Id"] for m in members}
    source_rows = csv_rows(DATA / "transactions.csv")[1] + csv_rows(DATA / "transactions-bulk.csv")[1]
    source_by_key = {r["POS_Transaction_Id__c"]: r for r in source_rows}
    failures = []
    expected_members = {r["Member_Number__c"] for r in csv_rows(DATA / "members.csv")[1]}
    if set(member_ids) != expected_members or len(members) != len(expected_members):
        failures.append("The loaded seed members do not match members.csv.")
    if set(by_key) != {r["POS_Transaction_Id__c"] for r in expected}:
        failures.append("The loaded POS ID set does not match expected.csv.")
    for fixture in expected:
        key = fixture["POS_Transaction_Id__c"]
        row = by_key.get(key)
        if row is None:
            failures.append(f"Missing {key}")
            continue
        source = source_by_key[key]
        original = {**prepare(source), "Member__c": member_ids.get(source["Member_Number__c"])}
        if original["Member__c"] is None or not matches(original, row):
            failures.append(f"{key}: purchase inputs or member do not match the source CSV")
        for field in ["Processing_Status__c", "Base_Fuel_Points__c", "Base_Other_Points__c", "Campaign_Points__c", "Total_Points__c"]:
            wanted = fixture[field]
            actual = row[field]
            ok = (actual == wanted if field == "Processing_Status__c" else
                  actual is None if wanted == "" else actual is not None and Decimal(str(actual)) == Decimal(wanted))
            if not ok:
                failures.append(f"{key} {field}: expected {wanted!r}, got {actual!r}")
        entries = by_transaction[row["Id"]]
        if len(entries) != int(fixture["Ledger_Count"]) or sum(Decimal(str(e["Points__c"])) for e in entries) != Decimal(fixture["Total_Points__c"]):
            failures.append(f"{key}: ledger count or sum mismatch")
        if any(e["Member__c"] != row["Member__c"] for e in entries):
            failures.append(f"{key}: ledger member mismatch")
        if fixture["Processing_Status__c"] == "Error" and not row["Processing_Error__c"]:
            failures.append(f"{key}: missing processing error")
        if key == "B3:SCENARIO:001" and sorted(e["Points__c"] for e in entries) != [5, 50, 54]:
            failures.append("109-point acceptance ledger must contain 54, 5 and 50.")
    balances = {}
    for member in members:
        # Include all ledger entries for these members, even later manual activity.
        totals = query(f"SELECT SUM(Points__c) total FROM Point_Ledger__c WHERE Member__c = {quote(member['Id'])} WITH USER_MODE")
        total = totals[0]["total"] or 0
        if Decimal(str(total)) != Decimal(str(member["Points_Balance__c"] or 0)):
            failures.append(f"{member['Member_Number__c']}: balance does not equal ledger")
        balances[member["Member_Number__c"]] = member["Points_Balance__c"]
    if failures:
        raise RuntimeError("\n".join(failures))
    print(json.dumps({"verified_transactions": len(rows), "ledger_entries": len(ledger),
                      "seed_points": sum(r["Total_Points__c"] or 0 for r in rows), "balances": balances}, indent=2))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["setup", "load", "verify"])
    parser.add_argument("--file", type=Path, default=DATA / "transactions.csv")
    parser.add_argument("--report", type=Path, default=ROOT / ".localdevserver/b3-import.json")
    args = parser.parse_args()
    check_org()
    if args.action == "setup":
        setup()
    elif args.action == "verify":
        verify()
    else:
        result = load(args.file, args.report)
        if result["rejected"]:
            return 1
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (RuntimeError, ValueError, InvalidOperation) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
