## About
When using Azure Arc for Servers, if the agent installed on your servers experiences a disconnection, you can track this event by observing the “ResourceHealth” entries in the AzureActivity table. If the connection is lost, the ActivityStatusValue for these entries will be set to “Active“. Once the connection is reestablished, the ActivityStatusValue will be changed to “Resolved“. By analyzing this data, we can determine how frequently and for how long each server was disconnected. While brief disconnections may be acceptable, prolonged disconnections warrant further investigation.

To assist in this analysis, I have created the following KQL query.

```
AzureActivity
| where CategoryValue == "ResourceHealth"
| where ActivityStatusValue == "Active"
| extend ResourceType = Properties_d.resourceProviderValue
| where ResourceType == "MICROSOFT.HYBRIDCOMPUTE"
| extend StartTime = TimeGenerated
| extend ServerName = Properties_d.resource
| join kind=leftouter (AzureActivity
    | where ActivityStatusValue == "Resolved"
    | extend ResourceType = Properties_d.resourceProviderValue
    | where ResourceType == "MICROSOFT.HYBRIDCOMPUTE"
    | extend EndTime = TimeGenerated
)
    on CorrelationId
| extend ["Minutes Offline"] = datetime_diff('minute',EndTime,StartTime)
| project ServerName,StartTime,EndTime,["Minutes Offline"],CorrelationId
```
