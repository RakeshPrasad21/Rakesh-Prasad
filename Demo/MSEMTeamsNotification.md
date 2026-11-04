# MSEM Daily Teams Exposure Summary

This folder contains a daily Azure Logic App that queries MSEM exposure records in a Log Analytics custom table and builds a Teams Adaptive Card summary.

## Files

| File | Purpose |
|---|---|
| `LA-MSEM-Teams-Notifications.json` | ARM template for the daily Consumption Logic App. |
| `MSEM-Teams-Daily-Digest-Card.json` | Adaptive Card definition used by the Logic App's `Compose_Daily_Adaptive_Card` action. |

The workflow builds the card only. It does **not** create a Teams connection or post the card. Add the Teams action manually after deployment (see [Add Teams delivery](#add-teams-delivery)).

## What the Logic App does

1. Runs once a day. The default schedule is **09:00 UTC**; the deployment parameters `dailyNotificationHour` and `dailyNotificationTimeZone` control the schedule.
2. Queries `MSEMLogs_CL` through the Azure Monitor Logs Query API using the Logic App's system-assigned managed identity.
3. Includes records from the previous 24 hours whose status is `New` or `Active`, and ignores rows without a `RecoreId`.
4. Keeps the latest row for each `RecoreId`.
5. Calculates total and severity counts, use-case counts, distinct affected identity/device/critical-asset counts, and the three highest-priority findings.
6. Builds a summary card with:
   - Environment and report timestamp (timestamp is displayed in UTC).
   - Total, Critical, High, Medium, and Low findings.
   - Findings by use-case category.
   - Top three priority findings, details, and suggested actions.
   - Affected identity, device, and critical-asset counts.
   - Recommended next actions for SOC, IAM, endpoint, and asset-owner teams.
7. Skips card creation when there are no matching records.

## KQL used by the Logic App

The `Query_Daily_MSEM_Records` HTTP action runs this query against `MSEMLogs_CL`. The query covers the previous 24 hours, filters to `New` and `Active` records, deduplicates by `RecoreId`, maps records to card categories, ranks priority findings, and returns the summary fields used by the Adaptive Card.

```kusto
MSEMLogs_CL
| where TimeGenerated > ago(1d) and TimeGenerated <= now()
| where Status in~ ("New", "Active")
| where isnotempty(RecoreId)
| summarize arg_max(TimeGenerated, *) by RecoreId
| extend UseCaseLabel = case(
    SubCategory contains "High-Risk Identity" or UseCase =~ "UC-09", "High-Risk Identity",
    UseCase =~ "UC-08" and SubCategory !contains "High-Risk Identity", "Attack Path Reaches User",
    UseCase =~ "UC-01" or Category contains "Attack Path" or SubCategory contains "Attack Path", "Attack Path",
    UseCase =~ "UC-02" or SubCategory contains "Excessive Privilege", "Excessive Privilege",
    UseCase =~ "UC-03" or SubCategory contains "Choke Point", "User Choke Point",
    UseCase =~ "UC-04" or SubCategory contains "Device Exposure", "Device Exposure",
    UseCase =~ "UC-05" or SubCategory contains "Critical Asset", "Critical Asset Association",
    UseCase =~ "UC-06" or SubCategory contains "Credential Exposure", "Credential Exposure",
    UseCase =~ "UC-07" or SubCategory contains "Risky Group", "Risky Group Membership",
    "Other"
)
| extend SeverityRank = case(
    Severity =~ "Critical", 0,
    Severity =~ "High", 1,
    Severity =~ "Medium", 2,
    3
)
| sort by SeverityRank asc, TimeGenerated desc
| serialize PriorityRank = row_number()
| extend PriorityLine = strcat(
    tostring(PriorityRank), ". ", tostring(Severity), " – ", tostring(UseCaseLabel),
    "\n   Asset: ", tostring(AssetName),
    "\n   Details: ", substring(tostring(Details), 0, 180),
    "\n   Action: ",
    case(
        UseCaseLabel == "Attack Path" or UseCaseLabel == "Attack Path Reaches User", "Investigate the attack path and reduce exposure.",
        UseCaseLabel == "Excessive Privilege", "Review privileges and remove unnecessary access.",
        UseCaseLabel == "User Choke Point", "Review identity dependencies and reduce concentration of access.",
        UseCaseLabel == "Device Exposure", "Review and remediate the device security posture.",
        UseCaseLabel == "Critical Asset Association", "Review exposure with the critical asset owner.",
        UseCaseLabel == "Credential Exposure", "Investigate and rotate exposed credentials.",
        UseCaseLabel == "Risky Group Membership", "Review group membership and privileged access.",
        "Review this high-risk identity and its connected exposures."
    )
)
| summarize
    TotalFindings = count(),
    CriticalFindings = countif(Severity =~ "Critical"),
    HighFindings = countif(Severity =~ "High"),
    MediumFindings = countif(Severity =~ "Medium"),
    LowFindings = countif(Severity =~ "Low"),
    AttackPathCount = countif(UseCaseLabel == "Attack Path"),
    ExcessivePrivilegeCount = countif(UseCaseLabel == "Excessive Privilege"),
    ChokePointCount = countif(UseCaseLabel == "User Choke Point"),
    DeviceExposureCount = countif(UseCaseLabel == "Device Exposure"),
    CriticalAssetAssociationCount = countif(UseCaseLabel == "Critical Asset Association"),
    CredentialExposureCount = countif(UseCaseLabel == "Credential Exposure"),
    RiskyGroupMembershipCount = countif(UseCaseLabel == "Risky Group Membership"),
    AttackPathReachesUserCount = countif(UseCaseLabel == "Attack Path Reaches User"),
    HighRiskIdentityCount = countif(UseCaseLabel == "High-Risk Identity"),
    IdentityCount = dcountif(AssetName, AssetType in~ ("User", "Identity", "ServiceAccount")),
    DeviceCount = dcountif(AssetName, AssetType =~ "Device"),
    CriticalAssetCount = dcountif(AssetName, SubCategory contains "Critical Asset"),
    TopPrioritySummary = strcat_array(make_list_if(PriorityLine, PriorityRank <= 3), "\n\n")
| project
    TotalFindings,
    CriticalFindings,
    HighFindings,
    MediumFindings,
    LowFindings,
    AttackPathCount,
    ExcessivePrivilegeCount,
    ChokePointCount,
    DeviceExposureCount,
    CriticalAssetAssociationCount,
    CredentialExposureCount,
    RiskyGroupMembershipCount,
    AttackPathReachesUserCount,
    HighRiskIdentityCount,
    IdentityCount,
    DeviceCount,
    CriticalAssetCount,
    TopPrioritySummary
```

### Use-case categorization

The KQL maps `UseCase` and `SubCategory` values to the categories shown on the card. UC-08 is labeled **Attack Path Reaches User**, unless its subcategory identifies a **High-Risk Identity**; UC-09 and that subcategory are labeled **High-Risk Identity**. Unknown records are counted under `Other` internally and are not represented by a separate card line. Keep this mapping aligned with the records produced by the ingestion Logic App.

### Digest and priority behavior

- The digest can include findings that were already reported by a separate notification workflow.
- The top-priority section lists at most three findings; the total count includes all matching records.
- Priority is calculated from the query's ranking: Critical first, then High, Medium, and other severities, with more recent findings first within a severity.
- Asset counts use `AssetName` and the `AssetType` / `SubCategory` values supplied by the ingestion workflow. They count distinct names, not authoritative asset inventory entities.

## Prerequisites

- An Azure resource group where you can deploy a Logic App and assign access to its managed identity.
- The `MSEMLogs_CL` custom table in a Log Analytics workspace, with the columns used by the KQL: `TimeGenerated`, `UseCase`, `RecoreId`, `AssetName`, `AssetType`, `Severity`, `Status`, `Category`, `SubCategory`, and `Details`.
- A Teams destination and permission to create or use a Teams connection.
- Azure CLI (`az`) if deploying with the command below.

## Deploy

The ARM template intentionally does not ask for either the workspace ARM resource ID or workspace ID. Those are configured after deployment. It also does not create a workspace role assignment.

Example deployment using Azure CLI:

```powershell
az deployment group create `
  --resource-group <logic-app-resource-group> `
  --template-file .\LA-MSEM-Teams-Notifications.json `
  --parameters `
    dailyNotificationHour=9 `
    dailyNotificationTimeZone="UTC" `
    environmentName="Production"
```

Optional template parameters:

| Parameter | Default | Description |
|---|---|---|
| `logicAppName` | `LA-MSEM-Teams-Notifications` | Logic App name. |
| `location` | Resource group location | Azure region for the Logic App. |
| `dailyNotificationHour` | `9` | Local hour, 0-23, when the daily run starts. |
| `dailyNotificationTimeZone` | `UTC` | Windows time-zone name used for the recurrence schedule. |
| `environmentName` | `Production` | Environment label shown on the card. |

The timestamp printed on the card is UTC regardless of the recurrence time zone.

## Configure workspace access after deployment

### 1. Set the workspace ID workflow parameter

The workflow parameter `workspaceId` is blank by default. Set it to the **Workspace ID GUID** shown in the Log Analytics workspace **Overview** page. Do not enter the workspace ARM resource ID here.

In the Logic App designer, open **Parameters**, set `workspaceId`, and save the workflow. The query URL uses this value:

```text
https://api.loganalytics.io/v1/workspaces/<workspaceId>/query
```

### 2. Grant Log Analytics Reader

Grant the Logic App's system-assigned managed identity the **Log Analytics Reader** role on the Log Analytics workspace. Find the identity under the Logic App's **Identity > System assigned** page. Assign the role at workspace scope in **Access control (IAM)**.

The role assignment is deliberately manual; the template doesn't require the workspace ARM resource ID.

## Add Teams delivery

1. Open the Logic App in the designer.
2. Open the **If_Daily_Records_Exist** condition's **True** branch.
3. Add a Teams action after `Compose_Daily_Adaptive_Card`, such as **Post adaptive card in a chat or channel**.
4. Create or select your Teams connection and choose the destination team/channel.
5. Use the `Compose_Daily_Adaptive_Card` output as the Adaptive Card payload. If the action asks for the card object rather than text, use the Compose output as an object/dynamic value, not as a quoted JSON string.
6. Save, then run a test with matching records in `MSEMLogs_CL`.

The card contains no dashboard or incident links; add tenant-specific URLs if needed.

## Troubleshooting

| Symptom | Check |
|---|---|
| Log query returns an authorization error | Confirm `workspaceId` is the Workspace ID GUID, and the Logic App managed identity has **Log Analytics Reader** at the workspace scope. |
| Query reports a missing table or column | Confirm the workspace contains `MSEMLogs_CL` and that the table schema matches the columns in the KQL. |
| No card is composed | The query only includes `New` or `Active` records generated in the previous 24 hours with a non-empty `RecoreId`. Check the query action output and time window. |
| Card is composed but not delivered | The template does not post to Teams. Add and configure the Teams action in the True branch as described above. |
| A use-case count is zero or unexpected | Compare the ingested `UseCase` and `SubCategory` values with the mapping in `Query_Daily_MSEM_Records`. |


<img width="263" height="313" alt="image" src="https://github.com/user-attachments/assets/018698c6-99aa-4560-9744-3eeebea6d3be" />
<img width="263" height="317" alt="image" src="https://github.com/user-attachments/assets/3980debb-bb02-4ec2-aa49-d39725140844" />

