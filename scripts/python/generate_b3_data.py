#!/usr/bin/env python3
"""Generate portable, deterministic B3 CSV fixtures without contacting an org."""

import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / "data/B3-transaction-input"
FIELDS = ["POS_Transaction_Id__c", "Member_Number__c", "Purchased_At__c",
          "Total_Amount__c", "Fuel_Amount__c", "Liters__c", "Other_Amount__c"]
EXPECTED = ["POS_Transaction_Id__c", "Processing_Status__c", "Base_Fuel_Points__c",
            "Base_Other_Points__c", "Campaign_Points__c", "Total_Points__c",
            "Ledger_Count", "Scenario"]


def write_csv(name, fields, rows):
    with (DATA / name).open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def generate():
    DATA.mkdir(parents=True, exist_ok=True)
    members = [
        {"Member_Number__c": f"B3-MEMBER-{i:03}", "FirstName": "B3 Test",
         "LastName": name, "PersonEmail": f"b3-member-{i:03}@example.invalid",
         "Membership_Status__c": status, "Joined_At__c": "2026-09-01T08:00:00Z"}
        for i, name, status in [(1, "Alfa", "Active"), (2, "Beta", "Active"),
                                (3, "Blocked", "Blocked")]
    ]
    write_csv("members.csv", list(members[0]), members)
    campaigns = [
        {"Name": "B3 - Natankuj plnou - 2026-10", "Is_Enabled__c": "true",
         "Start_Date__c": "2026-10-01", "End_Date__c": "2026-10-31",
         "Condition_Field__c": "Liters", "Threshold__c": "40",
         "Reward_Type__c": "FixedBonus", "Reward_Value__c": "50"},
        {"Name": "B3 - Zastavka na ceste - 2026-10", "Is_Enabled__c": "true",
         "Start_Date__c": "2026-10-01", "End_Date__c": "2026-10-31",
         "Condition_Field__c": "OtherAmount", "Threshold__c": "150",
         "Reward_Type__c": "BaseMultiplier", "Reward_Value__c": "1.1"},
    ]
    write_csv("campaigns.csv", list(campaigns[0]), campaigns)
    # Explicit expected values are acceptance fixtures, not a calculation engine.
    cases = [
        ("acceptance-109", "2026-10-15T10:00:00Z", "1890.00", "1710.00", "45.000", "180.00", 45, 9, 55, 109, 3),
        ("no-campaign", "2026-09-15T10:00:00Z", "1890.00", "1710.00", "45.000", "180.00", 45, 9, 0, 54, 1),
        ("fuel-below-40", "2026-10-15T10:00:00Z", "1519.96", "1519.96", "39.999", "0.00", 39, 0, 0, 39, 1),
        ("fuel-at-40", "2026-10-15T10:00:00Z", "1520.00", "1520.00", "40.000", "0.00", 40, 0, 50, 90, 2),
        ("other-below-150", "2026-10-15T10:00:00Z", "149.99", "0.00", "0.000", "149.99", 0, 7, 0, 7, 1),
        ("other-at-150-zero-bonus", "2026-10-15T10:00:00Z", "150.00", "0.00", "0.000", "150.00", 0, 7, 0, 7, 2),
        ("round-down", "2026-09-15T10:00:00Z", "1947.95", "1747.96", "45.999", "199.99", 45, 9, 0, 54, 1),
        ("zero-base", "2026-10-15T10:00:00Z", "19.99", "0.00", "0.000", "19.99", 0, 0, 0, 0, 1),
        ("campaign-start-prague", "2026-09-30T22:00:00Z", "1890.00", "1710.00", "45.000", "180.00", 45, 9, 55, 109, 3),
        ("campaign-end-prague", "2026-10-31T22:59:59Z", "1890.00", "1710.00", "45.000", "180.00", 45, 9, 55, 109, 3),
        ("after-campaign-prague", "2026-10-31T23:00:00Z", "1890.00", "1710.00", "45.000", "180.00", 45, 9, 0, 54, 1),
    ]
    transactions, expected = [], []
    for i, (scenario, date, total, fuel, liters, other, fp, op, cp, points, ledger) in enumerate(cases, 1):
        key = f"B3:SCENARIO:{i:03}"
        transactions.append(dict(zip(FIELDS, [key, f"B3-MEMBER-{1 + (i % 2):03}", date, total, fuel, liters, other])))
        expected.append(dict(zip(EXPECTED, [key, "Processed", fp, op, cp, points, ledger, scenario])))
    key = "B3:SCENARIO:012"
    transactions.append(dict(zip(FIELDS, [key, "B3-MEMBER-003", "2026-10-15T10:00:00Z", "1890.00", "1710.00", "45.000", "180.00"])))
    expected.append(dict(zip(EXPECTED, [key, "Error", "", "", "", 0, 0, "blocked-member"])))
    write_csv("transactions.csv", FIELDS, transactions)
    bulk = []
    for i in range(1, 252):
        key = f"B3:BULK:{i:04}"
        bulk.append(dict(zip(FIELDS, [key, f"B3-MEMBER-{1 + (i % 2):03}", "2026-10-16T10:00:00Z", "860.00", "760.00", "20.000", "100.00"])))
        expected.append(dict(zip(EXPECTED, [key, "Processed", 20, 5, 0, 25, 1, "bulk"])))
    write_csv("transactions-bulk.csv", FIELDS, bulk)
    write_csv("expected.csv", EXPECTED, expected)
    invalid = []
    for number, changes in enumerate([
        {"Member_Number__c": "B3-MEMBER-UNKNOWN"},
        {"Total_Amount__c": "1.00"},
        {"Other_Amount__c": "-1.00", "Total_Amount__c": "1709.00"},
        {"Purchased_At__c": "2099-01-01T10:00:00Z"},
        {"Liters__c": "0.000"},
    ], 1):
        invalid.append({**transactions[0], "POS_Transaction_Id__c": f"B3:INVALID:{number:03}", **changes})
    invalid.extend([transactions[0].copy(), {**transactions[0], "Liters__c": "46.000"}])
    write_csv("transactions-invalid.csv", FIELDS, invalid)
    print(f"Generated {len(members)} members, {len(campaigns)} campaigns, {len(expected)} purchases and {len(invalid)} rejection/replay inputs.")


if __name__ == "__main__":
    generate()
