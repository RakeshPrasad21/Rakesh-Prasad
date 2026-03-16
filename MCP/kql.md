# MSEM Advanced Hunting KQL Queries

Test these queries in **Microsoft 365 Defender Advanced Hunting Portal**:  
🔗 https://security.microsoft.com/v2/advanced-hunting

---

## 📋 Table of Contents
1. [Schema Discovery Queries](#schema-discovery-queries)
2. [Critical Assets Monitoring](#critical-assets-monitoring)
3. [Attack Paths Detection](#attack-paths-detection)
4. [Simplified Test Queries](#simplified-test-queries)
5. [SecurityRecommendation Table Alternatives](#securityrecommendation-table-alternatives)

⚠️ **Important**: If `SecurityRecommendation` table is not available, see [SecurityRecommendation-Table-Guide.md](SecurityRecommendation-Table-Guide.md) for alternatives.

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

### Full Query (Production)
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
    | where RemediationStatus == 'Active'
    | where RecommendationSeverity in ('High', 'Critical')
    | extend DeviceId = tostring(AdditionalFields.deviceId)
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
// Step 2: Check exposure data for devices
ExposureGraphNodes
| where NodeLabel in ('Device', 'Server')
| extend DeviceId = tostring(NodeProperties.deviceId)
| where isnotempty(DeviceId)
| project NodeId, NodeName, NodeLabel, DeviceId, Categories
| take 10
```

```kql
// Step 3: Count vulnerabilities
SecurityRecommendation
| where Timestamp > ago(7d)
| where RemediationStatus == 'Active'
| where RecommendationSeverity in ('High', 'Critical')
| summarize VulnerabilitiesCount = count() by RecommendationSeverity
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
| extend PathInvolvesCriticalAsset = TargetNodeId in (CriticalAssets | project DeviceId)
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
3. **SecurityRecommendation**: Available with Microsoft Defender Vulnerability Management

### If you get "Column not found" errors:

Run the schema discovery queries at the top to see actual column names in your environment.

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
    | summarize arg_max(Timestamp, *) by RecommendationId, RecommendationCategory
    | extend 
        IsComplete = RemediationStatus == 'Completed',
        IsActive = RemediationStatus == 'Active',
        IsFailed = RemediationStatus == 'Failed'
    | summarize 
        TotalRecommendations = count(),
        CompletedCount = countif(IsComplete),
        ActiveCount = countif(IsActive),
        FailedCount = countif(IsFailed),
        HighPriorityCount = countif(RecommendationSeverity == 'High'),
        LastUpdate = max(Timestamp)
        by InitiativeName = RecommendationCategory
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
        HasMFA = array_length(AuthenticationMethods) > 1,
        DaysSinceLastSignIn = datetime_diff('day', now(), LastSeenDate),
        IsDormant = datetime_diff('day', now(), LastSeenDate) > 90
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
    | where RemediationStatus == 'Active'
    | summarize 
        arg_max(Timestamp, *),
        AffectedEntitiesCount = dcount(coalesce(
            tostring(AdditionalFields.deviceId),
            tostring(AdditionalFields.userId),
            tostring(AdditionalFields.applicationId)
        ))
        by RecommendationId
    | extend 
        DaysOpen = datetime_diff('day', now(), Timestamp),
        ImpactLevel = RecommendationSeverity,
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

If you have Defender Vulnerability Management but SecurityRecommendation is missing, try:

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

- **MSEM tables** (ExposureGraphNodes, ExposureGraphEdges) are **snapshot tables** - no Timestamp column
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
