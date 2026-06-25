# 🔄 Logic App Solution for MSEM Dashboard Data Collection

## 📋 Overview

This Logic App automatically collects Microsoft Security Exposure Management (MSEM) data and composes it into JSON format for your dashboard.

---

## ⚡ Quick Reference - Required Permissions

| **Who/What** | **Needs Permission** | **Where** | **Role/Permission** |
|--------------|---------------------|-----------|---------------------|
| **Your Account** (deployer) | Deploy resources | Resource Group | Contributor |
| **Your Account** (deployer) | Grant Graph API consent | Entra ID | Cloud Application Administrator |
| **Logic App Managed Identity** | Query Secure Score | Microsoft Graph API | SecurityEvents.Read.All ✓ |
| **Logic App Managed Identity** | Query Security Data | Microsoft Graph API | SecurityActions.Read.All ✓ |
| **Logic App Managed Identity** | Query Log Analytics | Log Analytics Workspace | Log Analytics Reader |
| **API Connection** | Execute queries | Log Analytics Workspace | Log Analytics Reader |

✓ = Requires admin consent

---

## 🎯 What It Does

1. **Queries Microsoft Graph API** for Secure Score
2. **Queries Log Analytics/Sentinel** for:
   - Critical incidents
   - Vulnerability trends
   - Log ingestion volumes
   - Alert statistics
   - **Device inventory** (NEW - from Defender for Endpoint)
3. **Determines environment type** automatically based on device count (Production, Enterprise, Large Scale, SMB, Development)
4. **Transforms data** into dashboard format with dynamic max score
5. **Creates JSON output** in Compose action (view in run history)
6. **Runs automatically** every hour

---

## � Required Permissions

### **1. Deployment Permissions (Your User Account)**

To deploy the Logic App, you need these Azure RBAC roles:

| **Resource** | **Required Role** | **Purpose** |
|--------------|-------------------|-------------|
| Resource Group | **Contributor** or **Owner** | Create/manage Logic App and connections |
| Subscription | **Reader** | List available resources |
| Log Analytics Workspace | **Reader** | Access workspace metadata |
| Entra ID | **Cloud Application Administrator** or **Global Administrator** | Grant Graph API permissions to Managed Identity |

#### **Check Your Current Permissions**

```powershell
# Check Resource Group permissions
Get-AzRoleAssignment -ResourceGroupName "YourRG" | Where-Object { $_.SignInName -eq (Get-AzContext).Account.Id }

# Check Entra ID role
az ad signed-in-user show --query '{displayName:displayName, userPrincipalName:userPrincipalName}'
az rest --method GET --url 'https://graph.microsoft.com/v1.0/me/memberOf' --query 'value[].displayName'
```

#### **If You Don't Have Permissions**

Contact your Azure administrator to request:
1. **Contributor** role on the target resource group
2. **Cloud Application Administrator** role in Entra ID (for Graph API consent)

---

### **2. Logic App Managed Identity Permissions**

After deployment, the Logic App's managed identity needs these permissions:

#### **A. Microsoft Graph API Permissions**

| **Permission** | **Type** | **Purpose** | **Admin Consent Required** |
|----------------|----------|-------------|---------------------------|
| `SecurityEvents.Read.All` | Application | Read security events and Secure Score | ✅ Yes |
| `SecurityActions.Read.All` | Application | Read security actions and recommendations | ✅ Yes |
| `ThreatIndicators.Read.All` | Application | Read threat intelligence indicators | ✅ Yes |

**How to Grant:**

```powershell
# Get Logic App's Managed Identity
$logicApp = Get-AzLogicApp -ResourceGroupName "YourRG" -Name "MSEM-Dashboard-Collector"
$principalId = $logicApp.Identity.PrincipalId

# Grant Graph API permissions (requires Global Admin or Cloud App Admin)
az rest --method POST \
  --url "https://graph.microsoft.com/v1.0/servicePrincipals/$principalId/appRoleAssignments" \
  --body "{
    'principalId': '$principalId',
    'resourceId': '$(az ad sp list --filter \"displayName eq 'Microsoft Graph'\" --query '[0].id' -o tsv)',
    'appRoleId': 'bf394140-e372-4bf9-a898-299cfc7564e5'
  }"
```

**Or via Azure Portal:**
1. Go to **Entra ID** → **Enterprise Applications**
2. Search for `MSEM-Dashboard-Collector`
3. Click **Permissions** → **Add Permission**
4. Select **Microsoft Graph** → **Application Permissions**
5. Add: `SecurityEvents.Read.All`, `SecurityActions.Read.All`, `ThreatIndicators.Read.All`
6. Click **Grant admin consent for [Your Organization]** ⚠️ Requires admin role

#### **B. Azure RBAC Permissions**

| **Resource** | **Required Role** | **Scope** | **Purpose** |
|--------------|-------------------|-----------|-------------|
| Log Analytics Workspace | **Log Analytics Reader** | Workspace level | Query SecurityIncident, SecurityAlert, Usage, SecurityRecommendation tables |
| Log Analytics Workspace | **Microsoft Sentinel Reader** (optional) | Workspace level | Enhanced Sentinel-specific queries |

**How to Grant:**

```powershell
# Get workspace resource ID
$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName "YourRG" -Name "YourWorkspace"
$workspaceId = $workspace.ResourceId

# Assign Log Analytics Reader role
New-AzRoleAssignment \
  -ObjectId $principalId \
  -RoleDefinitionName "Log Analytics Reader" \
  -Scope $workspaceId

# (Optional) Assign Sentinel Reader role
New-AzRoleAssignment \
  -ObjectId $principalId \
  -RoleDefinitionName "Microsoft Sentinel Reader" \
  -Scope $workspaceId
```

---

### **3. API Connection Permissions**

The Logic App uses API connections that need authorization:

#### **Azure Monitor Logs Connection**

- **Authorization**: Uses your user credentials OR managed identity
- **Required Permission**: Log Analytics Reader role on the workspace
- **Setup**: After deployment, open Logic App Designer → Click the Azure Monitor Logs action → Re-authorize with your credentials

**Alternative: Use Managed Identity for Connection**
```powershell
# Update connection to use managed identity
az resource update \
  --ids "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Web/connections/azuremonitorlogs" \
  --set properties.parameterValueSet.values.token.type="ManagedServiceIdentity"
```

---

### **4. Least Privilege Principle**

✅ **Recommended Setup:**
- Deploy with **Contributor** role (not Owner)
- Managed Identity gets **Reader** roles only
- Use **managed identity** for all connections (no stored credentials)
- Enable **diagnostic logs** for audit trail

❌ **Avoid:**
- Granting Owner role unnecessarily
- Using personal credentials in API connections
- Broad permissions like "Global Administrator"

---

### **5. Permission Verification Checklist**

Before running the Logic App, verify:

```powershell
# 1. Check Managed Identity exists
Get-AzLogicApp -ResourceGroupName "YourRG" -Name "MSEM-Dashboard-Collector" | Select-Object -ExpandProperty Identity

# 2. Check Graph API permissions
az ad sp show --id $principalId --query "appRoles[].{Role:value, Id:id}"

# 3. Check RBAC assignments
Get-AzRoleAssignment -ObjectId $principalId | Select-Object RoleDefinitionName, Scope

# 4. Test Graph API access
$token = (az account get-access-token --resource https://graph.microsoft.com --query accessToken -o tsv)
Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/security/secureScores?`$top=1" -Headers @{Authorization="Bearer $token"}

# 5. Test Log Analytics access
Invoke-AzOperationalInsightsQuery -WorkspaceId $workspace.CustomerId -Query "Usage | take 1"
```

---

## 🚀 Deployment Steps

### **Step 1: Prerequisites**

Ensure you have:
- ✅ Azure Subscription
- ✅ Microsoft Sentinel workspace (or Log Analytics with Defender for Endpoint)
- ✅ Log Analytics workspace with **DeviceInfo** table (from Defender for Endpoint)
- ✅ **Contributor** role on resource group
- ✅ **Cloud Application Administrator** role in Entra ID
- ✅ PowerShell Az module installed (`Install-Module Az`)

### **Step 2: Deploy the Logic App**

#### **Option A: PowerShell Script (Recommended)**

```powershell
# Run the automated deployment script
.\Deploy-MSEM-LogicApp.ps1 `
  -ResourceGroupName "YourResourceGroup" `
  -Location "eastus" `
  -WorkspaceName "YourSentinelWorkspace"
```

#### **Option B: Azure CLI**

```powershell
# Get workspace ID
$workspaceId = (az monitor log-analytics workspace show \
  --resource-group YourResourceGroup \
  --workspace-name YourWorkspace \
  --query customerId -o tsv)

# Deploy using Azure CLI
az deployment group create \
  --resource-group YourResourceGroup \
  --template-file MSEM-Dashboard-Logic-App.json \
  --parameters \
    logicAppName="MSEM-Dashboard-Collector" \
    workspaceId="$workspaceId"
```

#### **Option B: Azure Portal UI**

1. Go to **Azure Portal** → **Create a resource** → **Logic App**
2. Fill in:
   - **Name**: `MSEM-Dashboard-Collector`
   - **Region**: Same as your Sentinel workspace
   - **Plan**: Consumption
3. Click **Review + Create**

### **Step 3: Configure Managed Identity Permissions** ⚠️ **Requires Admin**

The managed identity is enabled automatically during deployment. Now grant it permissions:

#### **A. Grant Microsoft Graph API Permissions** (Portal Method)

1. Go to **Azure Portal** → **Entra ID** → **Enterprise Applications**
2. **Filter**: Application type = Managed Identities
3. **Search**: `MSEM-Dashboard-Collector`
4. Click on the application
5. Left menu → **Permissions**
6. Click **Add Permission** → **Microsoft Graph** → **Application permissions**
7. Search and add:
   - ✅ `SecurityEvents.Read.All`
   - ✅ `SecurityActions.Read.All`
   - ✅ `ThreatIndicators.Read.All`
8. Click **Add permissions**
9. Click **Grant admin consent for [Your Organization]** ⚠️ **Critical Step**
10. Confirm by clicking **Yes**

#### **B. Grant Microsoft Graph API Permissions** (PowerShell Method)

```powershell
# Get the Managed Identity
$logicApp = Get-AzLogicApp -ResourceGroupName "YourRG" -Name "MSEM-Dashboard-Collector"
$principalId = $logicApp.Identity.PrincipalId

# Get Microsoft Graph Service Principal
$graphSp = Get-AzADServicePrincipal -Filter "displayName eq 'Microsoft Graph'"

# Get the App Role IDs for the required permissions
$securityEventsRole = $graphSp.AppRole | Where-Object {$_.Value -eq "SecurityEvents.Read.All"}
$securityActionsRole = $graphSp.AppRole | Where-Object {$_.Value -eq "SecurityActions.Read.All"}
$threatIndicatorsRole = $graphSp.AppRole | Where-Object {$_.Value -eq "ThreatIndicators.Read.All"}

# Grant permissions (requires Cloud Application Administrator or Global Admin)
New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $principalId `
  -PrincipalId $principalId `
  -ResourceId $graphSp.Id `
  -AppRoleId $securityEventsRole.Id

New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $principalId `
  -PrincipalId $principalId `
  -ResourceId $graphSp.Id `
  -AppRoleId $securityActionsRole.Id

New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $principalId `
  -PrincipalId $principalId `
  -ResourceId $graphSp.Id `
  -AppRoleId $threatIndicatorsRole.Id
```

#### **C. Grant Log Analytics Reader Role**

```powershell
# Get workspace resource ID
$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName "YourRG" -Name "YourWorkspace"

# Assign Log Analytics Reader role
New-AzRoleAssignment `
  -ObjectId $principalId `
  -RoleDefinitionName "Log Analytics Reader" `
  -Scope $workspace.ResourceId

Write-Host "✅ Permissions configured successfully" -ForegroundColor Green
```

#### **D. Verify Permissions**

```powershell
# Check Graph API permissions
Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $principalId | 
  Select-Object AppRoleId, ResourceDisplayName, PrincipalDisplayName

# Check RBAC assignments
Get-AzRoleAssignment -ObjectId $principalId | 
  Select-Object RoleDefinitionName, Scope, ObjectType
```

---

## 🔧 Logic App Workflow Design

### **Visual Flow**

```
┌─────────────────────┐
│  Recurrence Trigger │ (Every 1 hour)
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Initialize Variable │ (dashboardData object)
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Query Secure Score  │ (Microsoft Graph API)
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Query Incidents     │ (Log Analytics KQL)
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Query Vulnerabilities│ (Log Analytics KQL)
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Query Log Volume    │ (Log Analytics KQL)
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Query Alerts        │ (Log Analytics KQL)
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Query Device        │ (Log Analytics KQL - NEW)
│ Inventory           │ (Defender for Endpoint data)
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Determine Environment│ (Logic based on device count)
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Compose JSON        │ (Transform to dashboard format)
└─────────────────────┘  View output in run history
```

---

## 📊 KQL Queries Used

### **1. Critical Incidents**
```kql
SecurityIncident
| where TimeGenerated > ago(30d)
| where Status != 'Closed'
| summarize 
    TotalIncidents = count(),
    CriticalThreats = countif(Severity == 'High'),
    ValidatedIncidents = countif(Classification != 'FalsePositive')
```

### **2. Vulnerability Trends**
```kql
SecurityRecommendation
| where TimeGenerated > ago(90d)
| summarize 
    NewVulnerabilities = countif(RecommendationState == 'Active'),
    Remediated = countif(RecommendationState == 'Completed')
| extend Month = format_datetime(TimeGenerated, 'yyyy-MM')
```

### **3. Log Analytics Volume**
```kql
Usage
| where TimeGenerated > ago(30d)
| where IsBillable == true
| summarize 
    TotalGB = sum(Quantity) / 1000,
    SecurityEventsGB = sumif(Quantity, DataType == 'SecurityEvent') / 1000,
    TotalEvents = sum(Quantity) * 1000000
```

### **4. Alerts & False Positives**
```kql
SecurityAlert
| where TimeGenerated > ago(30d)
| summarize 
    TotalAlerts = count(),
    FalsePositives = countif(AlertSeverity == 'Informational' or Status == 'Dismissed'),
    TruePositives = countif(Status == 'Active' or Status == 'InProgress')
| extend FalsePositiveRate = round((FalsePositives * 100.0) / TotalAlerts, 2)
```

### **5. Device Inventory & Risk Overview** (NEW)
```kql
DeviceInfo
| where TimeGenerated > ago(1d)
| summarize 
    TotalDevices = dcount(DeviceId),
    CriticalAssets = dcountif(DeviceId, DeviceCategory == 'Critical' or DeviceType in ('DomainController', 'Server')),
    HighRiskDevices = dcountif(DeviceId, RiskScore >= 7),
    HighExposureDevices = dcountif(DeviceId, ExposureLevel == 'High'),
    NotOnboardedDevices = dcountif(DeviceId, OnboardingStatus != 'Onboarded'),
    NewlyDiscoveredDevices = dcountif(DeviceId, TimeGenerated > ago(7d))
```

**Note**: This query requires **Microsoft Defender for Endpoint** data in Log Analytics. The `DeviceInfo` table is populated when Defender for Endpoint is connected to your workspace.

---

## 🌐 How to Use the Logic App Output

### **Option 1: View in Azure Portal (Default)**

1. Go to **Azure Portal** → **Logic Apps** → `MSEM-Dashboard-Collector`
2. Click **Runs history**
3. Click on a successful run (green checkmark)
4. Expand **Compose_Dashboard_JSON** action
5. View/copy the **Outputs** section

**Example Output**:
```json
{
  "environment": "Production",
  "gaugeScore": "85",
  "peerBenchmark": "75",
  "criticalThreats": "3",
  "validatedIncidents": "12",
  "telemetryEvents": "247",
  "logsIngested": "1.5",
  "eventsAnalyzed": "158",
  "alertsGenerated": "847",
  "falsePositiveRate": "8.2",
  "totalDevices": "8547",
  "criticalAssets": "342",
  "highRiskDevices": "128",
  "highExposureDevices": "215",
  "notOnboardedDevices": "87",
  "newlyDiscoveredDevices": "42",
  "lastUpdated": "2026-06-25T14:30:00Z",
  "financialExposure": 1.2,
  "roiIndex": 3.4,
  "criticalBreaches": 0
}
```

---

### **Option 2: Convert to HTTP API**

For real-time dashboard integration, modify the Logic App:

#### **Step 1: Add Response Action**

1. Open **Logic App Designer**
2. Add new step after **Compose_Dashboard_JSON**
3. Search for **Response**
4. Configure:
   - **Status Code**: `200`
   - **Headers**:
     ```json
     {
       "Content-Type": "application/json",
       "Access-Control-Allow-Origin": "*"
     }
     ```
   - **Body**: Select `Outputs` from Compose_Dashboard_JSON (dynamic content)

#### **Step 2: Change Trigger (Optional - for on-demand calls)**

1. Delete **Recurrence** trigger
2. Add **When a HTTP request is received** trigger
3. Method: **GET**
4. Save → Copy the generated **HTTP GET URL**

#### **Step 3: Call from Dashboard**

```javascript
// Add to your dashboard HTML
async function loadMSEMData() {
    try {
        const response = await fetch('YOUR_LOGIC_APP_URL_HERE');
        const data = await response.json();
        updateDashboard(data);
        console.log('✅ Dashboard updated from Logic App');
    } catch (error) {
        console.error('❌ Error loading data:', error);
    }
}

// Load on page load
window.addEventListener('DOMContentLoaded', loadMSEMData);

// Refresh every 5 minutes
setInterval(loadMSEMData, 5 * 60 * 1000);
```

---

### **Option 3: Export to External Storage**

Add actions to send data elsewhere:

#### **Power BI**
Add **Power BI - Add rows to a dataset** action after Compose

#### **Azure SQL**
Add **SQL Server - Insert row** action after Compose

#### **Cosmos DB**
Add **Azure Cosmos DB - Create or update document** action after Compose

#### **Azure Function**
Add **Azure Functions - Call an Azure function** action for custom processing

See [Logic-App-View-JSON-Output.md](Logic-App-View-JSON-Output.md) for detailed instructions on each option.

---

### **Option 4: Manual Integration**

Copy JSON from Portal run history and paste into your dashboard code:

```javascript
// Paste the JSON from Logic App output
const msemData = {
  "environment": "Production",
  "gaugeScore": "85",
  "peerBenchmark": "75",
  "criticalThreats": "3",
  "totalDevices": "8547",
  "criticalAssets": "342",
  "highRiskDevices": "128",
  "highExposureDevices": "215",
  "notOnboardedDevices": "87",
  "newlyDiscoveredDevices": "42",
  "logsIngested": "24.7",
  "eventsAnalyzed": "15.8",
  "alertsGenerated": "8432",
  "falsePositiveRate": "2.3",
  // ... rest of the data
};

// Update dashboard - environment will automatically adjust max score
updateDashboard(msemData);
```

---

## 📈 Data Mapping Reference

| **Dashboard Field** | **Logic App Query** | **Source** |
|---------------------|---------------------|------------|
| `environment` | `Determine_Environment` | Logic expression based on device count |
| `gaugeScore` | `currentScore` | Microsoft Graph Secure Score |
| `peerBenchmark` | `averageScore` | Microsoft Graph Secure Score |
| `criticalThreats` | `CriticalThreats` | SecurityIncident (High severity) |
| `validatedIncidents` | `ValidatedIncidents / 1000` | SecurityIncident (not false positive) |
| `telemetryEvents` | `TotalEvents / 1000000` | Usage table (millions) |
| `logsIngested` | `TotalGB` | Usage table (billions) |
| `eventsAnalyzed` | `SecurityEventsGB / 1000` | Usage table (millions) |
| `alertsGenerated` | `TotalAlerts` | SecurityAlert count |
| `falsePositiveRate` | `FalsePositiveRate` | Calculated percentage |
| `totalDevices` | `TotalDevices` | DeviceInfo (distinct count) |
| `criticalAssets` | `CriticalAssets` | DeviceInfo (critical/server devices) |
| `highRiskDevices` | `HighRiskDevices` | DeviceInfo (risk score >= 7) |
| `highExposureDevices` | `HighExposureDevices` | DeviceInfo (high exposure level) |
| `notOnboardedDevices` | `NotOnboardedDevices` | DeviceInfo (not onboarded) |
| `newlyDiscoveredDevices` | `NewlyDiscoveredDevices` | DeviceInfo (discovered last 7 days) |

### Environment Determination Logic

The Logic App automatically determines the environment type based on total device count:

| **Device Count** | **Environment** | **Max Score** |
|------------------|-----------------|---------------|
| >= 10,000 | Large Scale | 1500 |
| >= 5,000 | Production | 1500 |
| >= 1,000 | Enterprise | 1200 |
| >= 100 | SMB | 800 |
| < 100 | Development | 500 |

---

## 🧪 Testing the Logic App

### **Manual Test Run**

```powershell
# Trigger Logic App manually
az logic workflow run trigger \
    --resource-group YourResourceGroup \
    --name MSEM-Dashboard-Collector \
    --trigger-name Recurrence
```

### **View Run History**

1. Go to **Azure Portal** → **Logic Apps** → `MSEM-Dashboard-Collector`
2. Click **Overview** → **Runs history**
3. Click on a run to see detailed execution
4. Check each action's inputs/outputs
5. Look for green checkmarks (✅ success) or red X (❌ failure)

### **View Output JSON**

1. In run history, click on a successful run
2. Scroll to **Compose_Dashboard_JSON** action
3. Click to expand it
4. Click **Show raw outputs** to see clean JSON
5. Copy the JSON for use in your dashboard

### **Verify Data Quality**

```powershell
# Get the latest run
$runs = Get-AzLogicAppRunHistory -ResourceGroupName "YourRG" -Name "MSEM-Dashboard-Collector" -MaximumRunCount 1

# Get the Compose action output
$runId = $runs[0].Name
$action = Get-AzLogicAppRunAction -ResourceGroupName "YourRG" -WorkflowName "MSEM-Dashboard-Collector" -RunName $runId -ActionName "Compose_Dashboard_JSON"

# Display the output
$action.Outputs | ConvertTo-Json -Depth 10

# Verify device data
Write-Host "`n=== Data Quality Check ===" -ForegroundColor Cyan
$output = $action.Outputs
Write-Host "Environment: $($output.environment)" -ForegroundColor Yellow
Write-Host "Total Devices: $($output.totalDevices)" -ForegroundColor Yellow
Write-Host "Critical Assets: $($output.criticalAssets)" -ForegroundColor Yellow
Write-Host "Gauge Score: $($output.gaugeScore)" -ForegroundColor Yellow
Write-Host "Logs Ingested: $($output.logsIngested) B" -ForegroundColor Yellow

# Check for missing fields
$requiredFields = @("environment", "gaugeScore", "totalDevices", "criticalAssets", "logsIngested")
foreach ($field in $requiredFields) {
    if (-not $output.$field) {
        Write-Host "⚠️ Missing: $field" -ForegroundColor Red
    }
}
```

### **Common Test Scenarios**

| **Test** | **Expected Result** | **If Failed** |
|----------|---------------------|---------------|
| Manual trigger | Run appears in history | Check trigger permissions |
| Graph API query | Secure Score populated | Check Graph API permissions |
| Incident query | CriticalThreats > 0 or = 0 | Check Log Analytics access |
| Device inventory query | TotalDevices > 0 | Check Defender for Endpoint connection |
| Environment determination | Environment = Production/Enterprise/etc | Check device count logic |
| Compose action | JSON with all 20+ fields | Check previous action outputs |

---

## 🔔 Add Monitoring & Alerts

### **1. Enable Diagnostics**
```powershell
az monitor diagnostic-settings create \
    --name logic-app-diagnostics \
    --resource /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Logic/workflows/MSEM-Dashboard-Collector \
    --logs '[{"category":"WorkflowRuntime","enabled":true}]' \
    --metrics '[{"category":"AllMetrics","enabled":true}]' \
    --workspace /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace}
```

### **2. Create Alert for Failed Runs**
```powershell
az monitor metrics alert create \
    --name "Logic App Failed" \
    --resource-group YourResourceGroup \
    --scopes /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Logic/workflows/MSEM-Dashboard-Collector \
    --condition "count WorkflowRunFailedRate > 0" \
    --description "Alert when Logic App runs fail" \
    --evaluation-frequency 5m \
    --window-size 5m \
    --severity 2
```

---

## 💡 Pro Tips

1. **Schedule**: Run every hour during business hours, every 4 hours at night
2. **Error Handling**: Add Try-Catch scopes for each query to handle failures gracefully
3. **Notifications**: Add email/Teams notification on failure
4. **Cost**: Consumption plan = ~$0.000025/action × 100 actions/run × 24 runs/day = ~$0.06/day ($1.80/month)
5. **Permissions**: Review and audit permissions quarterly for security compliance
6. **Testing**: Use the provided `Test-LogicAppPermissions.ps1` script before production deployment

---

## 🆘 Troubleshooting

### **Permission Issues**

#### **Issue: "Forbidden" or "Unauthorized" when querying Graph API**

**Error Message**: `403 Forbidden` or `401 Unauthorized` in Graph API action

**Root Cause**: Managed Identity doesn't have Graph API permissions or admin consent not granted

**Solution**:
```powershell
# 1. Verify managed identity exists
$logicApp = Get-AzLogicApp -ResourceGroupName "YourRG" -Name "MSEM-Dashboard-Collector"
if (!$logicApp.Identity) {
    Write-Host "❌ Managed Identity not enabled!" -ForegroundColor Red
}

# 2. Check Graph API permissions
$principalId = $logicApp.Identity.PrincipalId
Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $principalId

# 3. If empty, grant permissions (see Step 3 above)
# 4. Ensure admin consent was granted in Entra ID portal
```

**Verify in Portal**:
1. Entra ID → Enterprise Applications → MSEM-Dashboard-Collector
2. Permissions → Check for green checkmark next to each permission
3. If red, click "Grant admin consent"

---

#### **Issue: "BadRequest" or "ResourceNotFound" when querying Log Analytics**

**Error Message**: `The workspace could not be found` or `Insufficient permissions`

**Root Cause**: Managed Identity lacks Log Analytics Reader role

**Solution**:
```powershell
# Get workspace
$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName "YourRG" -Name "YourWorkspace"

# Verify role assignment
Get-AzRoleAssignment -ObjectId $principalId -Scope $workspace.ResourceId

# If empty, assign role
New-AzRoleAssignment `
  -ObjectId $principalId `
  -RoleDefinitionName "Log Analytics Reader" `
  -Scope $workspace.ResourceId
```

**Test Access**:
```powershell
# Test query as managed identity
$token = (Get-AzAccessToken -ResourceUrl "https://api.loganalytics.io").Token
$query = "Usage | take 1"
$body = @{query=$query} | ConvertTo-Json
Invoke-RestMethod -Uri "https://api.loganalytics.io/v1/workspaces/$($workspace.CustomerId)/query" `
  -Method Post `
  -Headers @{Authorization="Bearer $token"} `
  -Body $body `
  -ContentType "application/json"
```

---

#### **Issue: "You do not have permissions to grant consent"**

**Error Message**: `Need admin approval` when granting Graph API permissions

**Root Cause**: Your user account lacks Cloud Application Administrator or Global Administrator role

**Solution**:
1. **Option A**: Contact your Entra ID administrator
   - Provide them the Logic App name: `MSEM-Dashboard-Collector`
   - Request they grant consent for: `SecurityEvents.Read.All`, `SecurityActions.Read.All`, `ThreatIndicators.Read.All`

2. **Option B**: Request temporary admin role
   ```powershell
   # Check your current Entra ID roles
   az ad signed-in-user show --query '{displayName:displayName, roles:@}'
   ```

3. **Option C**: Use Privileged Identity Management (PIM)
   - Request time-limited Cloud Application Administrator role
   - Activate role in Azure Portal → Entra ID → PIM

---

#### **Issue: API Connection "Unauthorized" or "Not Authorized"**

**Error Message**: Azure Monitor Logs connection shows "Unauthorized" in designer

**Root Cause**: Connection not properly authorized

**Solution**:
1. Open **Logic App Designer**
2. Click on any **Azure Monitor Logs** action (yellow warning ⚠️)
3. Click **Change connection** or **Add new**
4. Select **Connect with managed identity**
   - Authentication Type: **Managed Identity**
   - Managed Identity: **System-assigned**
5. **Save** the Logic App
6. Verify the managed identity has Log Analytics Reader role (see above)

---

### **Data Issues**

#### **Issue: "No data returned" from Log Analytics**

**Possible Causes**:
1. No data in the queried tables
2. Time range too narrow
3. Incorrect table names
4. KQL syntax errors

**Solution**:
```powershell
# Test each table manually
$tables = @("SecurityIncident", "SecurityAlert", "SecurityRecommendation", "Usage")

foreach ($table in $tables) {
    $query = "$table | take 1"
    Write-Host "Testing $table..." -ForegroundColor Cyan
    
    $result = Invoke-AzOperationalInsightsQuery -WorkspaceId $workspace.CustomerId -Query $query
    
    if ($result.Results.Count -gt 0) {
        Write-Host "✅ $table has data" -ForegroundColor Green
    } else {
        Write-Host "❌ $table is empty or doesn't exist" -ForegroundColor Red
    }
}
```

**Adjust KQL Queries**:
- Change time range: `ago(30d)` → `ago(90d)`
- Check table schema: `SecurityIncident | getschema`
- Verify column names match your environment

---

#### **Issue: DeviceInfo table returns no data or doesn't exist**

**Possible Causes**:
1. Microsoft Defender for Endpoint not connected to Log Analytics
2. No devices onboarded to Defender for Endpoint
3. Table name different in your environment

**Solution**:

**1. Check if Defender for Endpoint is connected:**
```powershell
# Verify DeviceInfo table exists
$query = "search * | where $table == 'DeviceInfo' | take 1"
Invoke-AzOperationalInsightsQuery -WorkspaceId $workspace.CustomerId -Query $query

# List all tables with "Device" in the name
$query = "search * | distinct $table | where $table contains 'Device'"
Invoke-AzOperationalInsightsQuery -WorkspaceId $workspace.CustomerId -Query $query
```

**2. Connect Defender for Endpoint to Log Analytics:**
- Go to **Microsoft 365 Defender** portal (security.microsoft.com)
- Settings → Endpoints → Advanced features
- Enable **Microsoft Defender for Cloud** integration
- Or in Azure Portal: Sentinel → Data connectors → Microsoft Defender for Endpoint → Connect

**3. Alternative query if DeviceInfo unavailable:**
```kql
// Fallback: Use Defender ATP data from Sentinel
DeviceNetworkInfo
| union DeviceProcessEvents
| union DeviceFileEvents
| summarize 
    TotalDevices = dcount(DeviceId),
    HighRiskDevices = dcountif(DeviceId, isnotempty(DeviceId))
    // Simplified metrics
```

**4. Manual fallback values:**
If Defender for Endpoint is not available, you can hardcode device values in the Logic App:
```json
"totalDevices": "8547",
"criticalAssets": "342",
"highRiskDevices": "128",
"highExposureDevices": "215",
"notOnboardedDevices": "87",
"newlyDiscoveredDevices": "42"
```

---

#### **Issue: Secure Score returns null or empty**

**Possible Causes**:
1. Organization doesn't have Secure Score enabled
2. Graph API permissions insufficient
3. No data yet (new tenant)

**Solution**:
```powershell
# Test Graph API manually
$token = (Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com").Token
$response = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/security/secureScores?`$top=1" `
  -Headers @{Authorization="Bearer $token"}

$response.value | ConvertTo-Json
```

**Alternative**: Use static fallback value in Logic App:
```json
"gaugeScore": "@{coalesce(body('Query_Secure_Score')?['value']?[0]?['currentScore'], 75)}"
```

---

### **Deployment Issues**

#### **Issue: ARM deployment fails**

**Error Message**: `ResourceGroupNotFound`, `InvalidTemplate`, or `MissingParameter`

**Solution**:
```powershell
# Validate template first
az deployment group validate `
  --resource-group YourResourceGroup `
  --template-file MSEM-Dashboard-Logic-App.json `
  --parameters workspaceId="your-workspace-guid"

# Check resource group exists
az group show --name YourResourceGroup

# Get workspace ID
az monitor log-analytics workspace show `
  --resource-group YourRG `
  --workspace-name YourWorkspace `
  --query customerId -o tsv
```

---

#### **Issue: Logic App deployed but won't start**

**Possible Causes**:
1. Connections not authorized
2. Managed identity permissions not configured
3. Workspace ID incorrect

**Solution**:
1. Open Logic App Designer → Check for warning icons ⚠️
2. Click on each action with warning → Re-authorize
3. Verify all managed identity permissions (see Step 3)
4. Test manual trigger:
```powershell
az logic workflow run trigger `
  --resource-group YourRG `
  --name MSEM-Dashboard-Collector `
  --trigger-name Recurrence
```

---

### **Runtime Issues**

#### **Issue: Logic App runs but actions fail**

**Check Run History**:
1. Azure Portal → Logic App → Runs history
2. Click on failed run (red X)
3. Expand each action to see error details
4. Common errors:
   - **400 Bad Request**: Invalid KQL syntax
   - **401 Unauthorized**: Missing permissions
   - **404 Not Found**: Resource doesn't exist
   - **429 Too Many Requests**: Rate limiting (add delay/retry)
   - **500 Internal Server Error**: Azure service issue (retry)

**Add Error Handling**:
```json
// In Logic App designer, wrap queries in Try-Catch scope
{
  "Try": {
    "actions": { "Query_Critical_Incidents": {...} }
  },
  "Catch": {
    "actions": {
      "Compose_Error": {
        "inputs": "Error querying incidents: @{actions('Query_Critical_Incidents')['error']}"
      }
    }
  }
}
```

---

## 🧪 Permission Testing Guide

### **Complete Permission Test Script**

Run this script after deployment to verify all permissions:

```powershell
#Requires -Modules Az.Accounts, Az.LogicApp, Az.OperationalInsights, Az.Resources

# Configuration
$ResourceGroup = "YourResourceGroup"
$LogicAppName = "MSEM-Dashboard-Collector"
$WorkspaceName = "YourWorkspace"

Write-Host "🔍 Testing Logic App Permissions..." -ForegroundColor Cyan

# 1. Get Logic App and Managed Identity
Write-Host "`n1️⃣ Checking Managed Identity..." -ForegroundColor Yellow
$logicApp = Get-AzLogicApp -ResourceGroupName $ResourceGroup -Name $LogicAppName
if ($logicApp.Identity.PrincipalId) {
    $principalId = $logicApp.Identity.PrincipalId
    Write-Host "✅ Managed Identity exists: $principalId" -ForegroundColor Green
} else {
    Write-Host "❌ Managed Identity NOT configured!" -ForegroundColor Red
    exit 1
}

# 2. Check Graph API Permissions
Write-Host "`n2️⃣ Checking Microsoft Graph API Permissions..." -ForegroundColor Yellow
$graphPerms = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $principalId -ErrorAction SilentlyContinue
if ($graphPerms) {
    Write-Host "✅ Graph API permissions assigned:" -ForegroundColor Green
    $graphPerms | ForEach-Object { Write-Host "   - $($_.ResourceDisplayName)" -ForegroundColor Gray }
} else {
    Write-Host "❌ No Graph API permissions found!" -ForegroundColor Red
    Write-Host "   Run: See Step 3A in deployment guide" -ForegroundColor Yellow
}

# 3. Check RBAC Permissions
Write-Host "`n3️⃣ Checking Azure RBAC Permissions..." -ForegroundColor Yellow
$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroup -Name $WorkspaceName
$rbacAssignments = Get-AzRoleAssignment -ObjectId $principalId -Scope $workspace.ResourceId

if ($rbacAssignments) {
    Write-Host "✅ RBAC roles assigned:" -ForegroundColor Green
    $rbacAssignments | ForEach-Object { Write-Host "   - $($_.RoleDefinitionName)" -ForegroundColor Gray }
} else {
    Write-Host "❌ No RBAC roles assigned!" -ForegroundColor Red
    Write-Host "   Run: New-AzRoleAssignment -ObjectId $principalId -RoleDefinitionName 'Log Analytics Reader' -Scope $($workspace.ResourceId)" -ForegroundColor Yellow
}

# 4. Test Log Analytics Query
Write-Host "`n4️⃣ Testing Log Analytics Query Access..." -ForegroundColor Yellow
try {
    $testQuery = Invoke-AzOperationalInsightsQuery -WorkspaceId $workspace.CustomerId -Query "Usage | take 1"
    if ($testQuery.Results) {
        Write-Host "✅ Log Analytics query successful" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Log Analytics query failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. Test Graph API Access (requires you to be logged in)
Write-Host "`n5️⃣ Testing Microsoft Graph API Access..." -ForegroundColor Yellow
try {
    $token = (Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com").Token
    $secureScore = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/security/secureScores?`$top=1" `
      -Headers @{Authorization="Bearer $token"} `
      -ErrorAction Stop
    
    if ($secureScore.value) {
        Write-Host "✅ Graph API query successful" -ForegroundColor Green
        Write-Host "   Current Secure Score: $($secureScore.value[0].currentScore)" -ForegroundColor Gray
    }
} catch {
    Write-Host "⚠️  Graph API test (as your user): $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "   Note: Managed Identity Graph access is tested when Logic App runs" -ForegroundColor Gray
}

# 6. Test Manual Logic App Run
Write-Host "`n6️⃣ Testing Manual Logic App Trigger..." -ForegroundColor Yellow
Write-Host "   Triggering Logic App (this may take 30-60 seconds)..." -ForegroundColor Gray

try {
    Invoke-AzResourceAction `
      -ResourceGroupName $ResourceGroup `
      -ResourceType "Microsoft.Logic/workflows" `
      -ResourceName $LogicAppName `
      -Action "triggers/Recurrence/run" `
      -ApiVersion "2019-05-01" `
      -Force `
      -ErrorAction Stop
    
    Write-Host "✅ Logic App triggered successfully" -ForegroundColor Green
    Write-Host "   Check run history in Azure Portal for results" -ForegroundColor Gray
} catch {
    Write-Host "❌ Failed to trigger Logic App: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n✅ Permission test complete!" -ForegroundColor Green
Write-Host "   Review any ❌ errors above and follow the suggested fixes.`n" -ForegroundColor Yellow
```

**Save as**: `Test-LogicAppPermissions.ps1`

**Run**:
```powershell
.\Test-LogicAppPermissions.ps1
```

---

## 📋 Updated Deployment Checklist

- [ ] **Prerequisites**
  - [ ] Contributor role on resource group
  - [ ] Cloud Application Administrator role in Entra ID
  - [ ] Az PowerShell module installed
  - [ ] Connected to Azure (`Connect-AzAccount`)

- [ ] **Deployment**
  - [ ] Deploy Logic App (ARM template or script)
  - [ ] Verify managed identity enabled

- [ ] **Permissions** ⚠️ **Critical**
  - [ ] Grant Graph API permissions (SecurityEvents.Read.All, SecurityActions.Read.All)
  - [ ] Grant admin consent in Entra ID
  - [ ] Assign Log Analytics Reader role
  - [ ] Verify permissions with test script

- [ ] **Connection Authorization**
  - [ ] Open Logic App Designer
  - [ ] Authorize Azure Monitor Logs connection
  - [ ] Save Logic App

- [ ] **Testing**
  - [ ] Run permission test script
  - [ ] Trigger manual run
  - [ ] Check run history for success
  - [ ] View Compose_Dashboard_JSON output

- [ ] **Monitoring** (Optional)
  - [ ] Enable diagnostic settings
  - [ ] Create failure alert
  - [ ] Set up email notifications

---

## 🆘 Getting Help

### **If permission errors persist:**

1. **Export diagnostic logs**:
```powershell
az monitor diagnostic-settings create `
  --name LogicAppDiagnostics `
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Logic/workflows/MSEM-Dashboard-Collector" `
  --logs '[{"category":"WorkflowRuntime","enabled":true}]' `
  --workspace "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace}"
```

2. **Query diagnostic logs**:
```kql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.LOGIC"
| where resource_workflowName_s == "MSEM-Dashboard-Collector"
| where Level == "Error"
| project TimeGenerated, resource_actionName_s, status_s, error_message_s
| order by TimeGenerated desc
```

3. **Contact support** with:
   - Logic App run ID (from run history)
   - Error message screenshot
   - Result of `Test-LogicAppPermissions.ps1`

---

## 🎓 Additional Resources

- [Azure Logic Apps Managed Identity](https://learn.microsoft.com/azure/logic-apps/create-managed-service-identity)
- [Microsoft Graph Permissions Reference](https://learn.microsoft.com/graph/permissions-reference)
- [Azure RBAC Built-in Roles](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles)
- [Log Analytics Reader Role](https://learn.microsoft.com/azure/azure-monitor/logs/manage-access#log-analytics-reader)
- [Grant admin consent for apps](https://learn.microsoft.com/entra/identity/enterprise-apps/grant-admin-consent)

---

## 📝 Permission Summary

### **Before Deployment**
Ensure you have:
- ✅ **Contributor** role on target resource group
- ✅ **Cloud Application Administrator** role in Entra ID
- ✅ Access to Log Analytics workspace

### **After Deployment**
Configure these permissions:
- ✅ **Graph API**: SecurityEvents.Read.All, SecurityActions.Read.All (with admin consent)
- ✅ **RBAC**: Log Analytics Reader role on workspace
- ✅ **Connection**: Authorize Azure Monitor Logs connection

### **Testing**
Verify with:
```powershell
.\Test-LogicAppPermissions.ps1
```

### **Common Permission Issues**
| **Error** | **Cause** | **Fix** |
|-----------|-----------|---------|
| 403 Forbidden | Missing Graph API permission | Grant SecurityEvents.Read.All + admin consent |
| 401 Unauthorized | Missing RBAC role | Assign Log Analytics Reader |
| Connection unauthorized | Connection not authorized | Re-authorize in Logic App Designer |

---

## ✅ You're Ready!

Your Logic App is now configured to:
- ✅ Automatically collect MSEM data every hour
- ✅ Query Microsoft Graph and Log Analytics securely
- ✅ Generate JSON output viewable in run history
- ✅ Operate with least-privilege permissions

**Next Steps**: See [Logic-App-View-JSON-Output.md](Logic-App-View-JSON-Output.md) for integration options. 🚀

---

**Document Version**: 2.0 (Updated with comprehensive permissions guide)  
**Last Updated**: 2026-06-24
