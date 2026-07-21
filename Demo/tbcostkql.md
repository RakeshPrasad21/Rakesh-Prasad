```
let CommitmentTier = 200.0;
let DailyCommitmentCost = 164.25;
let OverageCostPerGB = 0.82;

Usage
| where TimeGenerated >= ago(30d)
| where IsBillable == true
| summarize IngestionGB = round(sum(Quantity)/1000,2)
    by Day = bin(StartTime,1d)
| extend
    IncludedGB = CommitmentTier,
    OverageGB = max_of(0.0, IngestionGB - CommitmentTier),
    EstimatedCost = round(
        DailyCommitmentCost + (OverageGB * OverageCostPerGB), 2)
| project Day, IngestionGB, IncludedGB, OverageGB, EstimatedCost
| order by Day desc
```

```
let DailyBenefit = 27.2 + 3.4;   // Average M365 + Defender benefit per day
let Commitment = 200.0;
let Price = 0.82;

Usage
| where TimeGenerated > ago(31d)
| where IsBillable == true
| summarize TotalGB = sum(Quantity)/1000 by Day=bin(StartTime,1d)
| extend BillableGB = max_of(TotalGB - DailyBenefit, 0.0)
| extend OverageGB = max_of(BillableGB - Commitment, 0.0)
| extend EstimatedCost = 164.25 + (OverageGB * Price)
| project Day, TotalGB=round(TotalGB,2), BillableGB=round(BillableGB,2), OverageGB=round(OverageGB,2), EstimatedCost=round(EstimatedCost,2)
```
```
let CommitmentGB = 200.0;
let DailyCommitmentCost = 164.25;
let OverageCostPerGB = 0.82;

let DailyTotals =
Usage
| where TimeGenerated >= ago(30d)
| where IsBillable == true
| summarize TotalGB = sum(Quantity)/1000
    by Day = bin(StartTime, 1d);

let DailyByTable =
Usage
| where TimeGenerated >= ago(30d)
| where IsBillable == true
| summarize TableGB = sum(Quantity)/1000
    by Day = bin(StartTime,1d), DataType;

DailyByTable
| join kind=inner DailyTotals on Day
| extend
    OverageGB = max_of(0.0, TotalGB - CommitmentGB),
    DailyCost = DailyCommitmentCost + (OverageGB * OverageCostPerGB),
    PercentOfIngestion = round((TableGB / TotalGB) * 100, 2),
    EstimatedTableCost = round((TableGB / TotalGB) * DailyCost, 2)
| project
    Day,
    DataType,
    TableGB = round(TableGB,2),
    PercentOfIngestion,
    EstimatedTableCost
| order by Day desc, EstimatedTableCost desc
```
