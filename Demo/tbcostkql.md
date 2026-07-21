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
