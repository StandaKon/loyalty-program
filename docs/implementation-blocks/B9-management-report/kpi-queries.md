# B9 KPI Control Queries

Control SOQL for every KPI in the B9 data contract (README, section 1). The management report artifact must return the same numbers as these queries for the same period. Run all of them with [`scripts/bash/b9-kpi-queries.sh`](../../../scripts/bash/b9-kpi-queries.sh).

## Conventions

- **Period** is half-open: `>= {{PERIOD_START}}` and `< {{PERIOD_END}}`, as DateTime literals with the `Europe/Prague` offset (for example October 2026 = `2026-10-01T00:00:00+02:00` to `2026-11-01T00:00:00+01:00`).
- **Previous period** uses the same queries with `{{PREV_START}}` / `{{PREV_END}}`.
- **Budget year** = `{{BUDGET_YEAR}}`; **campaign** = `{{CAMPAIGN_NAME}}` (business name, decision 9).
- Monthly trends use `convertTimezone()` so months follow the user time zone (`Europe/Prague` for the report user).
- Only business dates are used: `Joined_At__c`, `Occurred_At__c`, `Purchased_At__c`, `Issued_At__c`. Never `CreatedDate`.
- No query selects member names, emails or member numbers (only `Member_Number__c != null` as a filter).
- Earned entry types: `PurchaseBase`, `CampaignBonus`, `ProfileBonus`, `MarketingBonus`. `Adjustment` is reported separately.

Derived KPIs (computed in the artifact from query results):

| KPI | Formula | From |
| --- | --- | --- |
| Points earned | Sum of K03 rows | K03 |
| Points redeemed | `ABS(Redemption) − Refund` | K05 |
| Redemption rate (period) | Points redeemed / points earned; "—" if earned = 0 | K03, K05 |
| Redemption rate (cumulative) | Same with K06 | K06 |
| Weighted point value (CZK/point) | `czk / pts` | K08 |
| Outstanding balance in CZK | K07 × weighted point value | K07, K08 |
| Budget used (%) | K10 issued CZK / K11 budget | K10, K11 |
| Year-end estimate | YTD issued CZK / elapsed days × days in year | K10 |
| Campaign share | K14 qualifying transactions / K15 all processed transactions in the run | K14, K15 |
| Campaign cost (CZK) | Bonus points × weighted point value | K14, K08 |
| CFO projection | `AVG(K18 monthly points) × 12 × cumulative redemption rate × point value`; scenarios rate −10 pp / actual / +10 pp | K18, K06, K08 |

## Membership

### K01 Members total (as of period end)

Decision 8: registered up to the period end and currently `Active`.

```sql
SELECT COUNT(Id) members FROM Account WHERE Member_Number__c != null AND Membership_Status__c = 'Active' AND Joined_At__c < {{PERIOD_END}}
```

### K02 New registrations by month

```sql
SELECT CALENDAR_YEAR(convertTimezone(Joined_At__c)) y, CALENDAR_MONTH(convertTimezone(Joined_At__c)) m, COUNT(Id) registrations FROM Account WHERE Member_Number__c != null AND Joined_At__c >= {{PERIOD_START}} AND Joined_At__c < {{PERIOD_END}} GROUP BY CALENDAR_YEAR(convertTimezone(Joined_At__c)), CALENDAR_MONTH(convertTimezone(Joined_At__c)) ORDER BY CALENDAR_YEAR(convertTimezone(Joined_At__c)), CALENDAR_MONTH(convertTimezone(Joined_At__c))
```

## Points

### K03 Points earned by source

`CampaignBonus` rows are split per campaign. Zero bonuses are counted in `entries`.

```sql
SELECT Entry_Type__c, Campaign__r.Name campaign, SUM(Points__c) pts, COUNT(Id) entries FROM Point_Ledger__c WHERE Entry_Type__c IN ('PurchaseBase','CampaignBonus','ProfileBonus','MarketingBonus') AND Occurred_At__c >= {{PERIOD_START}} AND Occurred_At__c < {{PERIOD_END}} GROUP BY Entry_Type__c, Campaign__r.Name
```

### K04 Base points split: fuel vs. till

Must equal the `PurchaseBase` sum from K03 (`fuel + till`).

```sql
SELECT SUM(Base_Fuel_Points__c) fuel, SUM(Base_Other_Points__c) till, COUNT(Id) transactions FROM Loyalty_Transaction__c WHERE Processing_Status__c = 'Processed' AND Purchased_At__c >= {{PERIOD_START}} AND Purchased_At__c < {{PERIOD_END}}
```

### K05 Points redeemed, refunds and adjustments

```sql
SELECT Entry_Type__c, SUM(Points__c) pts, COUNT(Id) entries FROM Point_Ledger__c WHERE Entry_Type__c IN ('Redemption','Refund','Adjustment') AND Occurred_At__c >= {{PERIOD_START}} AND Occurred_At__c < {{PERIOD_END}} GROUP BY Entry_Type__c
```

### K06 Cumulative earned vs. redeemed since launch

```sql
SELECT Entry_Type__c, SUM(Points__c) pts FROM Point_Ledger__c WHERE Occurred_At__c < {{PERIOD_END}} GROUP BY Entry_Type__c
```

### K07 Outstanding balance

Current value, not filtered by period.

```sql
SELECT SUM(Points_Balance__c) balance, COUNT(Id) members FROM Account WHERE Member_Number__c != null
```

## Rewards and budget

### K08 Weighted point value since launch

```sql
SELECT SUM(Value_CZK__c) czk, SUM(Points_Spent__c) pts FROM Voucher__c WHERE Status__c != 'Cancelled'
```

### K09 Vouchers by reward

`Status__c = 'Redeemed'` / non-cancelled = share redeemed at the service.

```sql
SELECT Reward_Name__c, Partner__r.Name partner, Status__c, COUNT(Id) vouchers, SUM(Points_Spent__c) pts, SUM(Value_CZK__c) czk FROM Voucher__c WHERE Issued_At__c >= {{PERIOD_START}} AND Issued_At__c < {{PERIOD_END}} GROUP BY Reward_Name__c, Partner__r.Name, Status__c
```

### K10 Voucher value in the budget year by month

Cancelled vouchers are reported in the same result on their own rows.

```sql
SELECT Partner__r.Name partner, Status__c, CALENDAR_MONTH(convertTimezone(Issued_At__c)) m, COUNT(Id) vouchers, SUM(Value_CZK__c) czk FROM Voucher__c WHERE CALENDAR_YEAR(convertTimezone(Issued_At__c)) = {{BUDGET_YEAR}} GROUP BY Partner__r.Name, Status__c, CALENDAR_MONTH(convertTimezone(Issued_At__c))
```

### K11 Partner budget

```sql
SELECT Name, Voucher_Budget_CZK__c, Voucher_Budget_Year__c FROM Account WHERE Voucher_Budget_Year__c = {{BUDGET_YEAR}}
```

## Campaigns

### K12 Campaign runs

```sql
SELECT Id, Name, Start_Date__c, End_Date__c, Condition_Field__c, Threshold__c, Reward_Type__c, Reward_Value__c FROM Loyalty_Campaign__c ORDER BY Name, Start_Date__c
```

### K13 Campaign performance in the period

```sql
SELECT Campaign__r.Name campaign, COUNT_DISTINCT(Transaction__c) transactions, COUNT_DISTINCT(Member__c) members, SUM(Points__c) pts FROM Point_Ledger__c WHERE Entry_Type__c = 'CampaignBonus' AND Occurred_At__c >= {{PERIOD_START}} AND Occurred_At__c < {{PERIOD_END}} GROUP BY Campaign__r.Name
```

### K14 Campaign performance per run (all runs of one campaign)

```sql
SELECT Campaign__c, Campaign__r.Start_Date__c, COUNT_DISTINCT(Transaction__c) transactions, COUNT_DISTINCT(Member__c) members, SUM(Points__c) pts FROM Point_Ledger__c WHERE Entry_Type__c = 'CampaignBonus' AND Campaign__r.Name = '{{CAMPAIGN_NAME}}' GROUP BY Campaign__c, Campaign__r.Start_Date__c
```

### K15 All processed transactions during the campaign

Denominator for the campaign share. The artifact runs it once per run with the run dates from K12; the control query uses the report period.

```sql
SELECT COUNT(Id) transactions, AVG(Total_Amount__c) avg_amount FROM Loyalty_Transaction__c WHERE Processing_Status__c = 'Processed' AND Purchased_At__c >= {{PERIOD_START}} AND Purchased_At__c < {{PERIOD_END}}
```

### K16 Average value of qualifying transactions

```sql
SELECT COUNT(Id) transactions, AVG(Total_Amount__c) avg_amount FROM Loyalty_Transaction__c WHERE Processing_Status__c = 'Processed' AND Purchased_At__c >= {{PERIOD_START}} AND Purchased_At__c < {{PERIOD_END}} AND Id IN (SELECT Transaction__c FROM Point_Ledger__c WHERE Entry_Type__c = 'CampaignBonus' AND Campaign__r.Name = '{{CAMPAIGN_NAME}}')
```

### K17 Average value of other transactions

The report must label the K16 vs. K17 comparison as indicative (no control group, no non-member sales).

```sql
SELECT COUNT(Id) transactions, AVG(Total_Amount__c) avg_amount FROM Loyalty_Transaction__c WHERE Processing_Status__c = 'Processed' AND Purchased_At__c >= {{PERIOD_START}} AND Purchased_At__c < {{PERIOD_END}} AND Id NOT IN (SELECT Transaction__c FROM Point_Ledger__c WHERE Entry_Type__c = 'CampaignBonus' AND Campaign__r.Name = '{{CAMPAIGN_NAME}}')
```

## CFO projection

### K18 Earned points per month, last 12 full months

`LAST_N_MONTHS:12` excludes the current month.

```sql
SELECT CALENDAR_YEAR(convertTimezone(Occurred_At__c)) y, CALENDAR_MONTH(convertTimezone(Occurred_At__c)) m, SUM(Points__c) pts FROM Point_Ledger__c WHERE Entry_Type__c IN ('PurchaseBase','CampaignBonus','ProfileBonus','MarketingBonus') AND Occurred_At__c = LAST_N_MONTHS:12 GROUP BY CALENDAR_YEAR(convertTimezone(Occurred_At__c)), CALENDAR_MONTH(convertTimezone(Occurred_At__c)) ORDER BY CALENDAR_YEAR(convertTimezone(Occurred_At__c)), CALENDAR_MONTH(convertTimezone(Occurred_At__c))
```

## SHOULD

### K19 Active members (at least one transaction in the last 90 days)

```sql
SELECT COUNT_DISTINCT(Member__c) active_members FROM Loyalty_Transaction__c WHERE Processing_Status__c = 'Processed' AND Purchased_At__c = LAST_N_DAYS:90
```

### K20 Engagement: profile and marketing consent

`Profile_Complete__c` and `Marketing_Consent__c` are **not** readable in `Loyalty_Reporting`; add read access before the production report user uses this KPI.

```sql
SELECT Profile_Complete__c, Marketing_Consent__c, COUNT(Id) members FROM Account WHERE Member_Number__c != null GROUP BY Profile_Complete__c, Marketing_Consent__c
```
