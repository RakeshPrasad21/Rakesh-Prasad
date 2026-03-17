# MSEM Advanced Hunting KQL Queries

Test these queries in **Microsoft 365 Defender Advanced Hunting Portal**:  
🔗 https://security.microsoft.com/v2/advanced-hunting

---

## 📋 Table of Contents
1. [Schema Discovery Queries](#schema-discovery-queries)
2. [Critical Assets Monitoring](#critical-assets-monitoring)
3. [Attack Paths Detection](#attack-paths-detection)
4. [New Attack Paths Detection](#new-attack-paths-detection)
5. [Simplified Test Queries](#simplified-test-queries)
6. [SecurityRecommendation Table Alternatives](#securityrecommendation-table-alternatives)

⚠️ **Important**: 
- If `SecurityRecommendation` table is not available, see [SecurityRecommendation-Table-Guide.md](SecurityRecommendation-Table-Guide.md) for alternatives.
- **NodeProperties.deviceId may not exist** in your environment. Use NodeName-based matching or pure graph analysis instead (see queries below).

---

## ⚠️ Critical Note: DeviceId in ExposureGraphNodes

**Issue**: `NodeProperties.deviceId` may not be available in all MSEM environments.

**Solution**: Use one of these approaches:
1. **NodeName matching**: Match `ExposureGraphNodes.NodeName` to `DeviceInfo.DeviceName`
2. **Pure graph analysis**: Work only with MSEM data (NodeId, NodeName, Categories, EdgeLabel)
3. **Discover available properties**: Run this first to see what's available:

```kql
ExposureGraphNodes
| extend NodePropsKeys = bag_keys(NodeProperties)
| mv-expand NodePropsKeys
| summarize SampleValues = take_any(NodeProperties), Count = count() by tostring(NodePropsKeys)
| order by Count desc
```

---

## Schema Discovery Queries

### Check if MSEM tables exist and have data

```kql
// Check ExposureGraphNodes
ExposureGraphNodes
| count
```

```kql
// Check ExposureGraphEdges
ExposureGraphEdges
| count
```

```kql
// See ExposureGraphNodes schema
ExposureGraphNodes
| getschema
```

```kql
// See ExposureGraphEdges schema
ExposureGraphEdges
| getschema
```

```kql
// Sample data from ExposureGraphNodes
ExposureGraphNodes
| take 5
```

```kql
// Sample data from ExposureGraphEdges
ExposureGraphEdges
| take 5
```

---

## Critical Assets Monitoring

**Purpose:** Find critical devices with exposure risks and vulnerabilities  
**Used in:** `LogicApp-MSEM-ARM-Template.json`

⚠️ **Two versions provided**: Use DeviceId version if available, otherwise use NodeName-based matching

### Version 1: Using DeviceId (If NodeProperties.deviceId exists)
```kql
let CriticalDevices = DeviceInfo
    | where Timestamp > ago(1d)
    | where isnotempty(DeviceId)
    | summarize arg_max(Timestamp, *) by DeviceId
    | where DeviceCategory in ('Server', 'Domain Controller') or AdditionalFields contains 'Critical'
    | project DeviceId, DeviceName, DeviceType, OSPlatform, LastSeen = Timestamp;
let CurrentExposure = ExposureGraphNodes
    | where NodeLabel in ('Device', 'Server')
    | extend DeviceId = tostring(NodeProperties.deviceId), CategoriesCount = array_length(Categories)
    | where isnotempty(DeviceId)
    | summarize TotalCategories = sum(CategoriesCount) by DeviceId, NodeName
    | extend ExposureScore = TotalCategories * 10, AttackPathsCount = TotalCategories;
let VulnerabilityCount = SecurityRecommendation
    | where Timestamp > ago(1d)
    | where Status == 'Active'
    | where Severity in ('High', 'Critical')
    | where isnotempty(DeviceId)
    | summarize VulnerabilitiesCount = count() by DeviceId;
CriticalDevices
| join kind=leftouter (CurrentExposure) on DeviceId
| join kind=leftouter (VulnerabilityCount) on DeviceId
| where isnotempty(ExposureScore) or isnotempty(VulnerabilitiesCount)
| project 
    Timestamp = LastSeen,
    AssetId = DeviceId,
    AssetName = coalesce(NodeName, DeviceName),
    AssetType = DeviceType,
    ExposureScore = coalesce(ExposureScore, 0),
    AttackPathsCount = coalesce(AttackPathsCount, 0),
    VulnerabilitiesCount = coalesce(VulnerabilitiesCount, 0)
| extend Severity = case(
    ExposureScore >= 85 or VulnerabilitiesCount >= 10, 'Critical',
    AttackPathsCount >= 5 or VulnerabilitiesCount >= 5, 'High',
    'Medium')
| order by ExposureScore desc
```

### Version 2: Using NodeName Matching (If DeviceId NOT available) ⭐ RECOMMENDED
```kql
let CriticalDevices = DeviceInfo
    | where Timestamp > ago(1d)
    | where isnotempty(DeviceName)
    | summarize arg_max(Timestamp, *) by DeviceName
    | where DeviceCategory in ('Server', 'Domain Controller') or AdditionalFields contains 'Critical'
    | project DeviceName, DeviceType, OSPlatform, LastSeen = Timestamp;
let CurrentExposure = ExposureGraphNodes
    | where NodeLabel in ('Device', 'Server')
    | extend CategoriesCount = array_length(Categories)
    | summarize TotalCategories = sum(CategoriesCount) by NodeName
    | extend ExposureScore = TotalCategories * 10, AttackPathsCount = TotalCategories;
let VulnerabilityCount = SecurityRecommendation
    | where Timestamp > ago(1d)
    | where Status == 'Active'
    | where Severity in ('High', 'Critical')
    | where isnotempty(DeviceName)
    | summarize VulnerabilitiesCount = count() by DeviceName;
CriticalDevices
| join kind=leftouter (CurrentExposure) on $left.DeviceName == $right.NodeName
| join kind=leftouter (VulnerabilityCount) on DeviceName
| where isnotempty(ExposureScore) or isnotempty(VulnerabilitiesCount)
| project 
    Timestamp = LastSeen,
    AssetName = DeviceName,
    AssetType = DeviceType,
    ExposureScore = coalesce(ExposureScore, 0),
    AttackPathsCount = coalesce(AttackPathsCount, 0),
    VulnerabilitiesCount = coalesce(VulnerabilitiesCount, 0),
    OSPlatform
| extend Severity = case(
    ExposureScore >= 85 or VulnerabilitiesCount >= 10, 'Critical',
    AttackPathsCount >= 5 or VulnerabilitiesCount >= 5, 'High',
    'Medium')
| order by ExposureScore desc
```

### Version 3: Pure MSEM Data (No DeviceInfo correlation)
**Use when**: You only want MSEM exposure data without device details

```kql
ExposureGraphNodes
| where NodeLabel in ('Device', 'Server')
| extend CategoriesCount = array_length(Categories)
| summarize TotalCategories = sum(CategoriesCount) by NodeName, NodeLabel
| extend 
    ExposureScore = TotalCategories * 10,
    AttackPathsCount = TotalCategories
| where ExposureScore >= 50  // Only show exposed assets
| extend Severity = case(
    ExposureScore >= 85, 'Critical',
    ExposureScore >= 70, 'High',
    'Medium')
| project 
    Timestamp = now(),
    AssetName = NodeName,
    AssetType = NodeLabel,
    ExposureScore,
    AttackPathsCount,
    Severity
| order by ExposureScore desc
```

### Simplified Test Version
```kql
// Step 1: Find critical devices
DeviceInfo
| where Timestamp > ago(1d)
| where DeviceCategory in ('Server', 'Domain Controller')
| summarize arg_max(Timestamp, *) by DeviceId
| project DeviceId, DeviceName, DeviceCategory, OSPlatform
| take 10
```

```kql
// Step 2: Check what's available in NodeProperties
ExposureGraphNodes
| where NodeLabel in ('Device', 'Server')
| project NodeId, NodeName, NodeLabel, NodeProperties, Categories
| take 5
```

```kql
// Step 3: Check exposure data (without deviceId dependency)
ExposureGraphNodes
| where NodeLabel in ('Device', 'Server')
| extend CategoriesCount = array_length(Categories)
| project NodeName, NodeLabel, CategoriesCount, Categories
| order by CategoriesCount desc
| take 10
```

```kql
// Step 3: Count vulnerabilities (if SecurityRecommendation is available)
SecurityRecommendation
| where Timestamp > ago(7d)
| where Status == 'Active'
| where Severity in ('High', 'Critical')
| summarize VulnerabilitiesCount = count() by Severity
```

```kql
// Step 3 Alternative: Use DeviceTvmSoftwareVulnerabilities if SecurityRecommendation not available
DeviceTvmSoftwareVulnerabilities
| where Timestamp > ago(7d)
| where VulnerabilitySeverityLevel in ('High', 'Critical')
| summarize VulnerabilitiesCount = count() by VulnerabilitySeverityLevel
```

---

## Attack Paths Detection

**Purpose:** Identify attack paths to critical assets  
**Used in:** `LogicApp-AttackPaths-ARM-Template.json`

### Full Query (Production)
```kql
let Yesterday = ago(1d);
let CriticalAssets = DeviceInfo
    | where Timestamp > Yesterday
    | where DeviceCategory in ('Server', 'Domain Controller') or AdditionalFields contains 'Critical'
    | distinct DeviceId, DeviceName;
let AttackPaths = ExposureGraphEdges
    | where EdgeLabel in ('CanAuthenticate', 'CanMove', 'HasPermission', 'CanExecute')
    | extend SourceNodeId = tostring(SourceNodeId), TargetNodeId = tostring(TargetNodeId)
    | summarize PathCount = count(), EdgeTypes = make_set(EdgeLabel) by SourceNodeId, TargetNodeId;
let NodeDetails = ExposureGraphNodes
    | extend NodeId = tostring(NodeId)
    | project NodeId, NodeName, NodeLabel, Categories, NodeProperties;
AttackPaths
| join kind=inner (NodeDetails) on $left.SourceNodeId == $right.NodeId
| project-rename SourceName = NodeName, SourceType = NodeLabel, SourceCategories = Categories
| join kind=inner (NodeDetails) on $left.TargetNodeId == $right.NodeId
| project-rename TargetName = NodeName, TargetType = NodeLabel, TargetCategories = Categories, TargetProperties = NodeProperties
| extend PathInvolvesCriticalAsset = TargetNodeId in~ (toscalar(CriticalAssets | summarize make_set(DeviceId)))
| project 
    Timestamp = now(),
    AttackPathId = strcat(SourceNodeId, '_to_', TargetNodeId),
    PathName = strcat(SourceName, ' → ', TargetName),
    SourceNode = SourceName,
    TargetNode = TargetName,
    PathLength = PathCount,
    PathRisk = PathCount * 10,
    EdgeTypes,
    SourceCategories,
    TargetCategories,
    PathInvolvesCriticalAsset
| extend Severity = case(
    PathInvolvesCriticalAsset and PathLength > 3, 'Critical',
    PathInvolvesCriticalAsset, 'High',
    'Medium')
| order by PathLength desc
```

### Simplified Test Version
```kql
// Step 1: See attack path edges
ExposureGraphEdges
| where EdgeLabel in ('CanAuthenticate', 'CanMove', 'HasPermission', 'CanExecute')
| extend SourceNodeId = tostring(SourceNodeId), TargetNodeId = tostring(TargetNodeId)
| take 10
```

```kql
// Step 2: Count edges by type
ExposureGraphEdges
| summarize EdgeCount = count() by EdgeLabel
| order by EdgeCount desc
```

```kql
// Step 3: Find nodes involved in paths
ExposureGraphNodes
| extend NodeId = tostring(NodeId)
| project NodeId, NodeName, NodeLabel, Categories
| take 10
```

---

## New Attack Paths Detection

**Purpose:** Identify newly discovered attack paths  
**Used in:** P1 notifications for new attack path alerts  
**UI Location:** MSEM → Attack Surface Management → Attack Paths

⚠️ **Note**: ExposureGraphEdges is a snapshot table with no Status or Timestamp columns. NodeProperties may not contain deviceId.

### First: Discover What's in NodeProperties

```kql
// Check what properties are available in NodeProperties
ExposureGraphNodes
| extend NodePropsKeys = bag_keys(NodeProperties)
| mv-expand NodePropsKeys
| summarize count() by tostring(NodePropsKeys)
| order by count_ desc
```

```kql
// See sample NodeProperties values
ExposureGraphNodes
| where NodeLabel == 'Device'
| project NodeId, NodeName, NodeLabel, NodeProperties
| take 10
```

---

### Method 1: Count-Based Detection (Recommended for Logic Apps)
**Best for**: Automated monitoring without complex correlation  
**How it works**: Store baseline attack path count, alert when it increases significantly

```kql
// Get current attack path statistics - run this in Logic App
ExposureGraphEdges
| where EdgeLabel in ('can authenticate as', 'can rdp', 'can admin to', 'has permission to', 'can execute code')
| summarize 
    TotalPaths = count(),
    UniqueSourceNodes = dcount(SourceNodeId),
    UniqueTargetNodes = dcount(TargetNodeId),
    AuthPaths = countif(EdgeLabel == 'can authenticate as'),
    RdpPaths = countif(EdgeLabel == 'can rdp'),
    AdminPaths = countif(EdgeLabel == 'can admin to'),
    PermissionPaths = countif(EdgeLabel == 'has permission to'),
    ExecutePaths = countif(EdgeLabel == 'can execute code')
| extend 
    Timestamp = now(),
    HighRiskPaths = AuthPaths + RdpPaths + AdminPaths
| project Timestamp, TotalPaths, HighRiskPaths, UniqueSourceNodes, UniqueTargetNodes, AuthPaths, RdpPaths, AdminPaths, PermissionPaths, ExecutePaths
```

**Logic App Implementation**:
1. Run query hourly/daily
2. Store `TotalPaths` value in variable
3. On next run, compare: `CurrentPaths - PreviousPaths`
4. Alert if increase > 10 new paths OR > 5% growth
5. Update stored value

---

### Method 2: High-Risk Attack Paths (Pure Graph Analysis)
**Best for**: Identifying critical paths without device correlation  
**How it works**: Find paths with multiple hops or high category counts

```kql
// Find complex attack paths (multi-hop, high exposure)
let HighExposureNodes = ExposureGraphNodes
    | extend NodeId = tostring(NodeId), CategoriesCount = array_length(Categories)
    | where CategoriesCount >= 3  // Nodes with multiple exposure categories
    | project NodeId, NodeName, NodeLabel, CategoriesCount, Categories;
let AttackPaths = ExposureGraphEdges
    | where EdgeLabel in ('can authenticate as', 'can rdp', 'can admin to', 'has permission to', 'can execute code')
    | extend SourceNodeId = tostring(SourceNodeId), TargetNodeId = tostring(TargetNodeId)
    | summarize EdgeCount = count(), EdgeTypes = make_set(EdgeLabel) by SourceNodeId, TargetNodeId;
AttackPaths
| join kind=inner (HighExposureNodes) on $left.TargetNodeId == $right.NodeId
| extend 
    PathRisk = EdgeCount * CategoriesCount * 10,
    Severity = case(
        CategoriesCount >= 5 and EdgeCount >= 3, 'Critical',
        CategoriesCount >= 3 or EdgeCount >= 5, 'High',
        'Medium'
    )
| project 
    Timestamp = now(),
    TargetNode = NodeName,
    TargetNodeType = NodeLabel,
    SourceNodeId,
    PathRisk,
    EdgeCount,
    CategoriesCount,
    Categories,
    EdgeTypes,
    Severity
| order by PathRisk desc
| take 50
```

---

### Method 3: NodeName-Based Matching (If DeviceId Not Available)
**Best for**: Correlating with DeviceInfo using names  
**How it works**: Match NodeName to DeviceName for recent activity detection

```kql
// Find paths involving recently seen devices (name-based matching)
let RecentDeviceNames = DeviceInfo
    | where Timestamp > ago(6h)
    | distinct DeviceName;
let NodeNamesList = ExposureGraphNodes
    | extend NodeId = tostring(NodeId)
    | where NodeName in (RecentDeviceNames)
    | distinct NodeId, NodeName;
let AttackPaths = ExposureGraphEdges
    | where EdgeLabel in ('can authenticate as', 'can rdp', 'can admin to', 'has permission to', 'can execute code')
    | extend SourceNodeId = tostring(SourceNodeId), TargetNodeId = tostring(TargetNodeId)
    | summarize EdgeCount = count(), EdgeTypes = make_set(EdgeLabel) by SourceNodeId, TargetNodeId;
AttackPaths
| join kind=inner (NodeNamesList) on $left.TargetNodeId == $right.NodeId
| project 
    Timestamp = now(),
    TargetDevice = NodeName,
    TargetNodeId,
    EdgeCount,
    EdgeTypes
| extend Severity = case(
    EdgeCount > 5, 'High',
    EdgeCount > 2, 'Medium',
    'Low')
| order by EdgeCount desc
```

---

### Method 4: Edge Type Distribution Changes
**Best for**: Detecting changes in attack path patterns  
**How it works**: Compare edge type distribution over time

```kql
// Current edge distribution by type and node labels
ExposureGraphEdges
| where EdgeLabel in ('can authenticate as', 'can rdp', 'can admin to', 'has permission to', 'can execute code')
| extend SourceNodeId = tostring(SourceNodeId), TargetNodeId = tostring(TargetNodeId)
| join kind=inner (
    ExposureGraphNodes 
    | extend NodeId = tostring(NodeId)
    | project NodeId, TargetLabel = NodeLabel
) on $left.TargetNodeId == $right.NodeId
| summarize 
    PathCount = count(),
    UniqueTargets = dcount(TargetNodeId)
    by EdgeLabel, TargetLabel
| extend 
    Timestamp = now(),
    PathDensity = round(todouble(PathCount) / todouble(UniqueTargets), 2)
| order by PathCount desc
```

---

### Simplified Test Queries

```kql
// Test 1: Get total attack paths (baseline)
ExposureGraphEdges
| where EdgeLabel in ('can authenticate as', 'can rdp', 'can admin to', 'has permission to', 'can execute code')
| summarize TotalAttackPaths = count()
```

```kql
// Test 2: Attack paths by edge type
ExposureGraphEdges
| where EdgeLabel in ('can authenticate as', 'can rdp', 'can admin to', 'has permission to', 'can execute code')
| summarize PathCount = count() by EdgeLabel
| order by PathCount desc
```

```kql
// Test 3: Top targets (nodes with most incoming paths)
ExposureGraphEdges
| where EdgeLabel in ('can authenticate as', 'can rdp', 'can admin to', 'has permission to', 'can execute code')
| extend TargetNodeId = tostring(TargetNodeId)
| summarize IncomingPaths = count() by TargetNodeId
| join kind=inner (
    ExposureGraphNodes 
    | extend NodeId = tostring(NodeId)
    | project NodeId, NodeName, NodeLabel
) on $left.TargetNodeId == $right.NodeId
| project NodeName, NodeLabel, IncomingPaths
| order by IncomingPaths desc
| take 20
```

---

### Recommended Approach for Logic Apps

**Use Method 1 (Count-Based Detection)** - it's the most reliable and doesn't require deviceId:

1. **Hourly/Daily run**: Execute count-based query
2. **Store metrics**: Save TotalPaths, HighRiskPaths, AuthPaths, etc.
3. **Compare**: Calculate delta from previous run
4. **Alert conditions**:
   - New paths > 10 AND growth > 5%
   - HighRiskPaths increased by > 3
   - AuthPaths or RdpPaths increased (critical)
5. **Update**: Store newbaseline for next comparison

**Sample Logic App variable storage**:
```json
{
  "LastRun": "2026-03-17T10:00:00Z",
  "TotalPaths": 1847,
  "HighRiskPaths": 234,
  "AuthPaths": 156,
  "RdpPaths": 42,
  "AdminPaths": 36
}
```

---

## Simplified Test Queries

Use these to verify your environment has the required data:

### 1. Check Device Information
```kql
DeviceInfo
| where Timestamp > ago(24h)
| summarize Devices = dcount(DeviceId), Categories = dcount(DeviceCategory) by OSPlatform
```

### 2. Check Exposure Graph Nodes (MSEM)
```kql
ExposureGraphNodes
| summarize 
    TotalNodes = count(),
    NodeTypes = dcount(NodeLabel),
    SampleNodeLabels = make_set(NodeLabel, 10)
```

### 3. Check Exposure Graph Edges (MSEM)
```kql
ExposureGraphEdges
| summarize 
    TotalEdges = count(),
    EdgeTypes = dcount(EdgeLabel),
    SampleEdgeLabels = make_set(EdgeLabel, 10)
```

### 4. Check Security Recommendations
```kql
SecurityRecommendation
| where Timestamp > ago(7d)
| summarize 
    ActiveRecommendations = countif(RemediationStatus == 'Active'),
    TotalRecommendations = count()
    by RecommendationSeverity
```

### 5. Find Critical Servers
```kql
DeviceInfo
| where Timestamp > ago(1d)
| where DeviceCategory in ('Server', 'Domain Controller')
| summarize LastSeen = max(Timestamp) by DeviceId, DeviceName, DeviceCategory, OSPlatform
| order by LastSeen desc
| take 20
```

---

## 🔍 Troubleshooting

### If you get "Table not found" errors:

1. **ExposureGraphNodes / ExposureGraphEdges**: Requires Microsoft Security Exposure Management (MSEM) license
2. **DeviceInfo**: Available with Microsoft Defender for Endpoint
3. **SecurityRecommendation**: Requires Microsoft Defender Vulnerability Management
   - **How to enable**: 
     1. License: Microsoft 365 E5 or Defender for Endpoint Plan 2
     2. Navigate to: https://security.microsoft.com/tvm_dashboard
     3. Onboard devices to Defender for Endpoint
     4. Wait 24-48 hours for initial scan
   - **Alternative if not available**: Use `DeviceTvmSoftwareVulnerabilities` table (see examples below)
4. **DeviceTvmSoftwareVulnerabilities**: Same requirements as SecurityRecommendation
   - **How to enable**: Same as SecurityRecommendation (Defender Vulnerability Management)
   - **Test availability**: Run `DeviceTvmSoftwareVulnerabilities | take 1`
   - **Alternative**: Remove vulnerability components or use MSEM exposure scores only
5. **IdentityInfo**: Available with Microsoft Defender for Identity or Microsoft 365 E5

### If you get "Column not found" errors:

Run the schema discovery queries at the top to see actual column names in your environment.

**Common column name variations**:
- SecurityRecommendation: `Status` (not `RemediationStatus`), `Severity` (not `RecommendationSeverity`), `Category` (not `RecommendationCategory`)
- IdentityInfo: May not have `AuthenticationMethods` or `LastSeenDate` - use `Timestamp` instead

### If no data is returned:

```kql
// Check data age across MSEM tables
union 
    (ExposureGraphNodes | summarize MaxTime = now(), MinTime = now(), Count = count() | extend Table = "ExposureGraphNodes"),
    (ExposureGraphEdges | summarize MaxTime = now(), MinTime = now(), Count = count() | extend Table = "ExposureGraphEdges"),
    (DeviceInfo | where Timestamp > ago(30d) | summarize MaxTime = max(Timestamp), MinTime = min(Timestamp), Count = count() | extend Table = "DeviceInfo")
| project Table, Count, MinTime, MaxTime
```

---

## High Exposure Devices and Identities

**Purpose:** Find devices and identities with high exposure scores  
**Used in:** P1 notifications for high-risk assets

### Devices with High Exposure
```kql
let HighExposureDevices = ExposureGraphNodes
    | where NodeLabel == 'Device'
    | extend DeviceId = tostring(NodeProperties.deviceId), CategoriesCount = array_length(Categories)
    | where isnotempty(DeviceId)
    | summarize 
        TotalCategories = sum(CategoriesCount)
        by DeviceId, EntityName = NodeName
    | extend ExposureScore = TotalCategories * 10, AttackPathsCount = TotalCategories
    | where ExposureScore >= 70;
let DeviceDetails = DeviceInfo
    | where Timestamp > ago(1d)
    | summarize arg_max(Timestamp, *) by DeviceId
    | project DeviceId, DeviceType, OSPlatform, DeviceCategory;
HighExposureDevices
| join kind=inner (DeviceDetails) on DeviceId
| extend EntityType = 'Device'
| project EntityName, EntityType, DeviceId, ExposureScore, AttackPathsCount, DeviceType, OSPlatform, DeviceCategory
| order by ExposureScore desc
```

### Identities with High Exposure
```kql
let HighExposureIdentities = ExposureGraphNodes
    | where NodeLabel in ('User', 'Identity')
    | extend AccountUpn = tostring(NodeProperties.userPrincipalName), CategoriesCount = array_length(Categories)
    | where isnotempty(AccountUpn)
    | summarize 
        TotalCategories = sum(CategoriesCount)
        by AccountUpn, EntityName = NodeName
    | extend ExposureScore = TotalCategories * 10, AttackPathsCount = TotalCategories
    | where ExposureScore >= 70;
let IdentityDetails = IdentityInfo
    | where Timestamp > ago(7d)
    | summarize arg_max(Timestamp, *) by AccountUpn
    | project AccountUpn, IsAccountEnabled, AssignedRoles, Department;
HighExposureIdentities
| join kind=leftouter (IdentityDetails) on AccountUpn
| extend EntityType = 'Identity'
| project EntityName, EntityType, AccountUpn, ExposureScore, AttackPathsCount, IsAccountEnabled, AssignedRoles, Department
| order by ExposureScore desc
```

---

## Exposure Score Changes

**Purpose:** Detect significant changes in overall exposure score  
**Used in:** P1 notifications for exposure spikes

```kql
// Note: SecureScore table tracks overall security score, not MSEM exposure score
// For MSEM exposure changes, monitor ExposureGraphNodes count and Categories changes
let CurrentNodes = ExposureGraphNodes
    | extend CategoriesCount = array_length(Categories)
    | summarize 
        TotalNodes = count(),
        AverageCategoriesPerNode = avg(CategoriesCount),
        HighExposureNodes = countif(CategoriesCount >= 5),
        TotalCategories = sum(CategoriesCount);
let ExposureMetrics = CurrentNodes
    | extend 
        EstimatedExposureScore = (HighExposureNodes * 100.0) / TotalNodes,
        ExposureLevel = case(
            HighExposureNodes > 100, 'Critical',
            HighExposureNodes > 50, 'High',
            HighExposureNodes > 20, 'Medium',
            'Low'
        );
ExposureMetrics
| project 
    Timestamp = now(),
    TotalExposedNodes = TotalNodes,
    HighExposureNodes,
    EstimatedExposureScore,
    ExposureLevel,
    TotalCategories,
    AverageCategoriesPerNode
```

---

## Security Initiative Progress

**Purpose:** Track security recommendation remediation progress  
**Used in:** P2 notifications for initiative tracking

```kql
let Yesterday = ago(1d);
let CurrentRecommendations = SecurityRecommendation
    | where Timestamp > Yesterday
    | summarize arg_max(Timestamp, *) by RecommendationId
    | extend 
        Category = coalesce(Category, "Uncategorized"),
        IsComplete = Status == 'Completed',
        IsActive = Status == 'Active',
        IsFailed = Status == 'Failed'
    | summarize 
        TotalRecommendations = count(),
        CompletedCount = countif(IsComplete),
        ActiveCount = countif(IsActive),
        FailedCount = countif(IsFailed),
        HighPriorityCount = countif(Severity == 'High'),
        LastUpdate = max(Timestamp)
        by InitiativeName = Category
    | extend CompletionPercentage = round((todouble(CompletedCount) / todouble(TotalRecommendations)) * 100, 2);
CurrentRecommendations
| where CompletionPercentage < 80 or FailedCount > 0
| project InitiativeName, TotalRecommendations, CompletedCount, ActiveCount, FailedCount, CompletionPercentage, HighPriorityCount, LastUpdate
| order by HighPriorityCount desc, CompletionPercentage asc
```

---

## Device Exposure Trends

**Purpose:** Monitor trends in device exposure over time  
**Used in:** P2 notifications for trend analysis

```kql
// Current exposed devices count
let CurrentExposedDevices = ExposureGraphNodes
    | where NodeLabel == 'Device'
    | extend DeviceId = tostring(NodeProperties.deviceId), CategoriesCount = array_length(Categories)
    | where isnotempty(DeviceId)
    | summarize ExposureScore = sum(CategoriesCount) * 10 by DeviceId
    | where ExposureScore > 50
    | summarize CurrentCount = dcount(DeviceId);
// Exposure level breakdown
let ExposureBreakdown = ExposureGraphNodes
    | where NodeLabel == 'Device'
    | extend DeviceId = tostring(NodeProperties.deviceId), CategoriesCount = array_length(Categories)
    | where isnotempty(DeviceId)
    | summarize ExposureScore = sum(CategoriesCount) * 10 by DeviceId
    | extend ExposureLevel = case(
        ExposureScore >= 85, 'Critical',
        ExposureScore >= 70, 'High',
        ExposureScore >= 50, 'Medium',
        'Low'
    )
    | summarize DeviceCount = count() by ExposureLevel;
ExposureBreakdown
| extend TotalExposedDevices = toscalar(CurrentExposedDevices)
| project ExposureLevel, DeviceCount, TotalExposedDevices
| order by case(ExposureLevel == 'Critical', 1, ExposureLevel == 'High', 2, ExposureLevel == 'Medium', 3, 4)
```

---

## Identity Exposure Trends

**Purpose:** Monitor identity exposure and privileged account risks  
**Used in:** P2 notifications for identity security

```kql
let HighExposureIdentities = ExposureGraphNodes
    | where NodeLabel in ('User', 'Identity')
    | extend AccountUpn = tostring(NodeProperties.userPrincipalName), CategoriesCount = array_length(Categories)
    | where isnotempty(AccountUpn)
    | summarize 
        TotalCategories = sum(CategoriesCount)
        by AccountUpn
    | extend ExposureScore = TotalCategories * 10, AttackPathsCount = TotalCategories
    | where ExposureScore >= 70;
let IdentityDetails = IdentityInfo
    | where Timestamp > ago(7d)
    | summarize arg_max(Timestamp, *) by AccountUpn
    | extend 
        IsPrivileged = AssignedRoles has_any ('Global Administrator', 'Security Administrator', 'Exchange Administrator', 'SharePoint Administrator'),
        HasMFA = isnotempty(AccountUpn),
        DaysSinceLastSignIn = datetime_diff('day', now(), Timestamp),
        IsDormant = datetime_diff('day', now(), Timestamp) > 90
    | project AccountUpn, IsPrivileged, HasMFA, IsDormant, DaysSinceLastSignIn, Department, IsAccountEnabled, AssignedRoles;
HighExposureIdentities
| join kind=inner (IdentityDetails) on AccountUpn
| extend 
    RiskLevel = case(
        IsPrivileged and not(HasMFA), 'Critical',
        IsPrivileged and IsDormant, 'Critical',
        IsPrivileged, 'High',
        IsDormant, 'Medium',
        'Low'
    )
| project AccountUpn, ExposureScore, AttackPathsCount, IsPrivileged, HasMFA, IsDormant, DaysSinceLastSignIn, RiskLevel, Department, AssignedRoles
| order by case(RiskLevel == 'Critical', 1, RiskLevel == 'High', 2, RiskLevel == 'Medium', 3, 4), ExposureScore desc
```

---

## Security Recommendations (Quick Wins)

**Purpose:** Identify high-impact, low-effort security recommendations  
**Used in:** P2 notifications for actionable recommendations

```kql
let OpenRecommendations = SecurityRecommendation
    | where Timestamp > ago(1d)
    | where Status == 'Active'
    | summarize 
        arg_max(Timestamp, *)
        by RecommendationId
    | extend 
        AffectedEntitiesCount = 1,
        DaysOpen = datetime_diff('day', now(), Timestamp),
        ImpactLevel = Severity,
        EffortLevel = case(
            RecommendationName has_any ('Enable', 'Turn on', 'Configure'), 'Low',
            RecommendationName has_any ('Update', 'Patch', 'Install'), 'Medium',
            'High'
        );
let QuickWins = OpenRecommendations
    | extend 
        IsQuickWin = ImpactLevel in ('High', 'Critical') and EffortLevel == 'Low',
        IsOverdue = DaysOpen > 30 and ImpactLevel in ('High', 'Critical'),
        Priority = case(
            ImpactLevel == 'Critical' and EffortLevel == 'Low', 1,
            ImpactLevel == 'Critical', 2,
            ImpactLevel == 'High' and EffortLevel == 'Low', 3,
            ImpactLevel == 'High', 4,
            5
        )
    | where IsQuickWin or IsOverdue;
QuickWins
| project 
    RecommendationName,
    ImpactLevel,
    EffortLevel,
    Priority,
    AffectedEntitiesCount,
    DaysOpen,
    IsQuickWin,
    IsOverdue,
    RecommendationCategory
| order by Priority asc, AffectedEntitiesCount desc
| take 20
```

---

## SecurityRecommendation Table Alternatives

⚠️ **If SecurityRecommendation table is not available in your environment**, use these modified queries:

### Critical Assets Monitoring (Without SecurityRecommendation)

```kql
let CriticalDevices = DeviceInfo
    | where Timestamp > ago(1d)
    | where isnotempty(DeviceId)
    | summarize arg_max(Timestamp, *) by DeviceId
    | where DeviceCategory in ('Server', 'Domain Controller') or AdditionalFields contains 'Critical'
    | project DeviceId, DeviceName, DeviceType, OSPlatform, LastSeen = Timestamp;
let CurrentExposure = ExposureGraphNodes
    | where NodeLabel in ('Device', 'Server')
    | extend DeviceId = tostring(NodeProperties.deviceId), CategoriesCount = array_length(Categories)
    | where isnotempty(DeviceId)
    | summarize TotalCategories = sum(CategoriesCount) by DeviceId, NodeName
    | extend ExposureScore = TotalCategories * 10, AttackPathsCount = TotalCategories;
CriticalDevices
| join kind=inner (CurrentExposure) on DeviceId
| project 
    Timestamp = LastSeen,
    AssetId = DeviceId,
    AssetName = coalesce(NodeName, DeviceName),
    AssetType = DeviceType,
    ExposureScore,
    AttackPathsCount
| extend Severity = case(
    ExposureScore >= 85, 'Critical',
    AttackPathsCount >= 50, 'High',
    'Medium')
| order by ExposureScore desc
```

### Using DeviceTvmSoftwareVulnerabilities (Alternative)

⚠️ **Important**: Both SecurityRecommendation and DeviceTvmSoftwareVulnerabilities require **Microsoft Defender Vulnerability Management**.

**To enable these tables**:
1. License: Microsoft 365 E5, Microsoft 365 E5 Security, or Defender for Endpoint Plan 2
2. Go to: https://security.microsoft.com/tvm_dashboard
3. Onboard devices via: Settings → Endpoints → Onboarding
4. Wait 24-48 hours for vulnerability assessment to populate
5. Test with: `DeviceTvmSoftwareVulnerabilities | take 1`

If SecurityRecommendation is not available but DeviceTvmSoftwareVulnerabilities is:

```kql
let CriticalDevices = DeviceInfo
    | where Timestamp > ago(1d)
    | where isnotempty(DeviceId)
    | summarize arg_max(Timestamp, *) by DeviceId
    | where DeviceCategory in ('Server', 'Domain Controller') or AdditionalFields contains 'Critical'
    | project DeviceId, DeviceName, DeviceType, OSPlatform, LastSeen = Timestamp;
let CurrentExposure = ExposureGraphNodes
    | where NodeLabel in ('Device', 'Server')
    | extend DeviceId = tostring(NodeProperties.deviceId), CategoriesCount = array_length(Categories)
    | where isnotempty(DeviceId)
    | summarize TotalCategories = sum(CategoriesCount) by DeviceId, NodeName
    | extend ExposureScore = TotalCategories * 10, AttackPathsCount = TotalCategories;
let VulnerabilityCount = DeviceTvmSoftwareVulnerabilities
    | where Timestamp > ago(7d)
    | where VulnerabilitySeverityLevel in ('High', 'Critical')
    | where isnotempty(DeviceId)
    | summarize VulnerabilitiesCount = count() by DeviceId;
CriticalDevices
| join kind=leftouter (CurrentExposure) on DeviceId
| join kind=leftouter (VulnerabilityCount) on DeviceId
| where isnotempty(ExposureScore) or isnotempty(VulnerabilitiesCount)
| project 
    Timestamp = LastSeen,
    AssetId = DeviceId,
    AssetName = coalesce(NodeName, DeviceName),
    AssetType = DeviceType,
    ExposureScore = coalesce(ExposureScore, 0),
    AttackPathsCount = coalesce(AttackPathsCount, 0),
    VulnerabilitiesCount = coalesce(VulnerabilitiesCount, 0)
| extend Severity = case(
    ExposureScore >= 85 or VulnerabilitiesCount >= 10, 'Critical',
    AttackPathsCount >= 50 or VulnerabilitiesCount >= 5, 'High',
    'Medium')
| order by ExposureScore desc
```

### Security Recommendations (Without SecurityRecommendation)

Since SecurityRecommendation is the primary table for this query, use Secure Score instead:

```kql
// Alternative: Use SecureScore control profiles
SecureScoreControlProfiles
| where ControlName != ""
| extend 
    ImpactLevel = case(
        Tier == "Essential", "Critical",
        Tier == "Advanced", "High",
        "Medium"
    ),
    EffortLevel = case(
        ImplementationCost == "Low", "Low",
        ImplementationCost == "Moderate", "Medium",
        "High"
    )
| where ImpactLevel in ("Critical", "High")
| project 
    RecommendationName = ControlName,
    ImpactLevel,
    EffortLevel,
    Category = ControlCategory,
    AffectedEntitiesCount = UserImpact,
    Score = ScoreInPercentage
| order by ImpactLevel, EffortLevel
| take 20
```

**Note**: SecureScore tables have a different schema. See [SecurityRecommendation-Table-Guide.md](SecurityRecommendation-Table-Guide.md) for full details.

---

## 📝 Notes

- **MSEM tables** (ExposureGraphNodes, ExposureGraphEdges) are **snapshot tables** - no Timestamp or Status columns in raw data
- **New attack path detection**: Use time-based correlation with recently active devices (see New Attack Paths Detection section)
- **DeviceInfo** and **SecurityRecommendation** have Timestamp columns - filter with `ago()`
- **No Risk column** - Calculate exposure scores using `array_length(Categories) * 10`
- **No dcount() on Categories** - Use `array_length()` and `sum()` instead
- **SecurityRecommendation requires Defender Vulnerability Management** - See SecurityRecommendation-Table-Guide.md for alternatives
- Always test queries in the portal before using in Logic Apps
- Queries are optimized for Logic App HTTP POST to: `https://api.security.microsoft.com/api/advancedhunting/run`

---

## ✅ Validation Checklist

Before deploying Logic Apps, verify:

- [ ] All queries run without errors in Advanced Hunting portal
- [ ] ExposureGraphNodes returns data
- [ ] ExposureGraphEdges returns data  
- [ ] DeviceInfo has recent data (last 24 hours)
- [ ] SecurityRecommendation is available OR alternative approach selected
- [ ] IdentityInfo table is available (for identity queries)
- [ ] SecureScore table is available (for score tracking)
- [ ] Your account has permission to run Advanced Hunting queries
- [ ] Managed Identity has **AdvancedHunting.Read.All** permission assigned
