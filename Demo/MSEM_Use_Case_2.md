# MSEM Use Case 2 – User Has Excessive Privilege

## 1. Use Case

**Requirement:**

> Identify users who have excessive or highly privileged access and notify both the affected user and the IAM/Security team.

### Notification Target

| Finding                      | Notification        |
| ---------------------------- | ------------------- |
| User has excessive privilege | **User + IAM Team** |

---

## 2. Objective

Microsoft Security Exposure Management (MSEM) provides exposure information through the Enterprise Exposure Graph.

The objective of this use case is to identify relationships such as:

```text
User
  |
  +-- has role on --> Resource
  |
  +-- member of ----> Privileged Group
  |
  +-- permissions --> Resource
```

The detection should prioritize privileges that can create significant security exposure.

---

## 3. Important Design Principle

Having a privileged role does **not automatically mean that the privilege is excessive**.

For example:

```text
User
  |
  +-- Security Administrator
```

may be legitimate.

Therefore, the production solution should eventually consider:

* Privilege type
* Privilege scope
* Resource criticality
* User/identity type
* Privileged group membership
* Attack-path involvement
* Business justification
* Whether the access is required

For the initial MSEM implementation, we can identify **potentially excessive privilege** and send it for IAM review.

---

# 4. Step 1 – Discover Available Privilege Relationships

Before creating the final detection rule, run:

```kql
ExposureGraphEdges
| where EdgeLabel in~ (
    "has role on",
    "member of",
    "permissions"
)
| summarize
    Count = count()
    by
    EdgeLabel,
    SourceNodeLabel,
    TargetNodeLabel
| order by Count desc
```

### Purpose

This query determines how MSEM represents privilege-related relationships in the current tenant.

Example output:

| EdgeLabel   | SourceNodeLabel | TargetNodeLabel | Count |
| ----------- | --------------- | --------------- | ----: |
| has role on | identity        | resource        |   500 |
| member of   | identity        | group           |   300 |
| permissions | identity        | resource        |   100 |

The actual values must come from the tenant.

---

# 5. Step 2 – Inspect `has role on`

Since `has role on` is already present in the tenant, inspect the actual records:

```kql
ExposureGraphEdges
| where EdgeLabel =~ "has role on"
| project *
| take 50
```

### Why this is required

Do not assume that the graph contains fields such as:

```text
SourceNodeEntityIds
TargetNodeEntityIds
```

if those fields are not present.

We should use only the fields actually available in the tenant.

---

# 6. Step 3 – Identify Users/Identities with Role Relationships

Once the available columns are confirmed, the basic detection can be:

```kql
ExposureGraphEdges
| where EdgeLabel =~ "has role on"
| where SourceNodeLabel in~ (
    "identity",
    "user",
    "user_account"
)
| project
    User = SourceNodeName,
    UserNodeId = SourceNodeId,
    Role = TargetNodeName,
    RoleNodeId = TargetNodeId,
    RoleType = TargetNodeLabel,
    TargetCategories = TargetNodeCategories,
    Relationship = EdgeLabel
```

### Expected output

```text
User                    Role                  RoleType
------------------------------------------------------------
john@company.com        Global Administrator  role
rahul@company.com       Security Administrator role
amit@company.com        Owner                 role
```

The exact `NodeLabel` values should be confirmed from the tenant data.

---

# 7. Step 4 – Identify Potentially Excessive Privileges

After confirming the actual role values, filter high-impact privileges.

Example:

```kql
ExposureGraphEdges
| where EdgeLabel =~ "has role on"
| where SourceNodeLabel in~ (
    "identity",
    "user",
    "user_account"
)
| where
    TargetNodeName contains "Admin"
    or TargetNodeName contains "Owner"
    or TargetNodeName contains "Privileged"
| project
    User = SourceNodeName,
    UserNodeId = SourceNodeId,
    Privilege = TargetNodeName,
    PrivilegeType = TargetNodeLabel,
    Resource = TargetNodeName,
    ResourceNodeId = TargetNodeId,
    Relationship = EdgeLabel
```

> **Note:** The `TargetNodeName` filtering above is a starting point only. Once we inspect your actual MSEM records, replace these generic string filters with the exact privilege/role attributes available in your tenant.

Identify the users associated with these groups
```
let CandidateGroups =
    ExposureGraphNodes
    | where NodeLabel =~ "group"
    | where NodeName contains "Admin"
        or NodeName contains "Administrator"
        or NodeName contains "Privileged"
        or NodeName contains "PRIV"
        or NodeName contains "Owner"
    | project
        GroupNodeId = NodeId,
        GroupName = NodeName;
ExposureGraphEdges
| where EdgeLabel =~ "has role on"
| where SourceNodeLabel =~ "user"
| where TargetNodeLabel =~ "group"
| join kind=inner CandidateGroups
    on $left.TargetNodeId == $right.GroupNodeId
| project
    User = SourceNodeName,
    UserNodeId = SourceNodeId,
    GroupName,
    GroupNodeId,
    Relationship = EdgeLabel
| distinct User, UserNodeId, GroupName, GroupNodeId, Relationship
| order by GroupName asc
```
KQL — Identify candidate privileged groups and associated users

Run this query first. It uses the relationship direction observed in your tenant and includes the group names found in your screenshot.
```
let CandidateGroups =
    ExposureGraphNodes
    | where NodeLabel =~ "group"
    | where
        NodeName contains "Admin"
        or NodeName contains "Administrator"
        or NodeName contains "Privileged"
        or NodeName contains "PRIV"
        or NodeName contains "Owner"
    | project
        GroupNodeId = NodeId,
        GroupName = NodeName,
        GroupProperties = NodeProperties;
let UserGroupRelationships =
    ExposureGraphEdges
    | where EdgeLabel =~ "has role on"
    | where SourceNodeLabel =~ "user"
    | where TargetNodeLabel =~ "group"
    | project
        User = SourceNodeName,
        UserNodeId = SourceNodeId,
        GroupNodeId = TargetNodeId,
        Relationship = EdgeLabel;
UserGroupRelationships
| join kind=inner CandidateGroups on GroupNodeId
| summarize
    CandidateGroups = make_set(GroupName),
    GroupCount = dcount(GroupNodeId)
    by User, UserNodeId
| project
    User,
    UserNodeId,
    GroupCount,
    CandidateGroups
| order by GroupCount desc
```
Investigate the service account associated with 220 groups
```
let CandidateGroups =
    ExposureGraphNodes
    | where NodeLabel =~ "group"
    | where
        NodeName contains "Admin"
        or NodeName contains "Administrator"
        or NodeName contains "Privileged"
        or NodeName contains "PRIV"
        or NodeName contains "Owner"
    | project GroupNodeId = NodeId, GroupName = NodeName;
ExposureGraphEdges
| where EdgeLabel =~ "has role on"
| where SourceNodeLabel =~ "user"
| where TargetNodeLabel =~ "group"
| project
    User = SourceNodeName,
    UserNodeId = SourceNodeId,
    GroupNodeId = TargetNodeId
| join kind=inner CandidateGroups on GroupNodeId
| summarize
    CandidateGroupCount = dcount(GroupNodeId),
    CandidateGroups = make_set(GroupName, 250)
    by User, UserNodeId
| where CandidateGroupCount >= 20
| project User, UserNodeId, CandidateGroupCount, CandidateGroups
```
---

# 8. Recommended Severity Model

For the initial dashboard and notification solution:

| Privilege                        | Suggested Severity | Notification    |
| -------------------------------- | ------------------ | --------------- |
| Global Administrator             | Critical           | User + IAM      |
| Domain Administrator             | Critical           | User + IAM      |
| Enterprise Administrator         | Critical           | User + IAM      |
| Owner on critical resource       | High               | User + IAM      |
| Security Administrator           | High               | User + IAM      |
| Privileged group membership      | High               | User + IAM      |
| Contributor on critical resource | Medium             | IAM review      |
| Normal user access               | Low/None           | No notification |

This is a **notification prioritization model**, not a statement that every listed role is inherently excessive.

---

# 9. Recommended Production Output

The KQL should ultimately produce a normalized result like:

| Column               | Purpose                |
| -------------------- | ---------------------- |
| User                 | User display name/UPN  |
| UserNodeId           | MSEM identity node     |
| Privilege            | Assigned privilege     |
| PrivilegeType        | Type of role/access    |
| Resource             | Resource affected      |
| ResourceNodeId       | MSEM resource node     |
| Severity             | Critical/High/Medium   |
| Reason               | Why it requires review |
| NotificationRequired | Yes/No                 |

Example:

```text
User:                 john@company.com
Privilege:            Owner
Resource:             Production Subscription
Severity:             High
Reason:               Highly privileged access
NotificationRequired: Yes
```

---

# 10. Logic App Integration

The KQL result can feed the notification workflow:

```text
MSEM Exposure Graph
        |
        v
ExposureGraphEdges
        |
        v
Privilege Detection KQL
        |
        v
Potential Excessive Privilege
        |
        v
Sentinel / Scheduled Logic App
        |
        +----------------------+
        |                      |
        v                      v
Affected User              IAM Team
        |                      |
        v                      v
Teams / Email              Teams / Email
```

---

# 11. User Notification

Example Teams/Email message:

```text
Subject:
MSEM – Privileged Access Review Required

Hello <User>,

Microsoft Security Exposure Management has identified
privileged access associated with your account that
requires review.

Privilege:
<Privilege>

Resource:
<Resource>

Severity:
<Severity>

Please review this access with the IAM team.

Security Operations
```

---

# 12. IAM Team Notification

```text
Subject:
MSEM – Potential Excessive Privilege Detected

User:
<UPN>

Privilege:
<Privilege>

Resource:
<Resource>

Severity:
<Severity>

Reason:
<Reason>

Recommended Action:
Review whether the privilege is required and
remove or reduce access where appropriate.
```

---

# 13. Important Difference from Attack Path Use Case

### Use Case 1 – User is part of an attack path

The primary logic is:

```text
Entry Point
     |
     v
   User
     |
     v
Critical Asset
```

This requires **graph traversal / path analysis**.

### Use Case 2 – User has excessive privilege

The primary logic is:

```text
User
 |
 +-- has role on --> Resource
 |
 +-- member of ----> Privileged Group
 |
 +-- permissions --> Resource
```

This initially requires **privilege/relationship analysis**.

Graph traversal can be added later to determine whether the privilege actually contributes to an attack path.

---

# 14. Recommended Implementation Approach

For the first version, implement it in three stages.

### Stage 1 – Discovery

Run:

```kql
ExposureGraphEdges
| where EdgeLabel in~ (
    "has role on",
    "member of",
    "permissions"
)
| summarize
    Count = count()
    by
    EdgeLabel,
    SourceNodeLabel,
    TargetNodeLabel
| order by Count desc
```

### Stage 2 – Data Validation

Inspect:

```kql
ExposureGraphEdges
| where EdgeLabel =~ "has role on"
| project *
| take 50
```

Confirm:

* User field
* Role field
* Resource field
* Node IDs
* Node labels
* Categories
* Any privilege/criticality properties

### Stage 3 – Production Detection

After confirming the schema:

```text
MSEM Graph
     |
     v
Privilege Relationship
     |
     v
High-impact privilege
     |
     v
Risk/Scope evaluation
     |
     v
Notification Required
     |
     +---------> User
     |
     +---------> IAM Team
```

---

## 15. Final Recommendation

Do **not** finalize the production KQL based only on:

```kql
TargetNodeName contains "Admin"
```

That would generate noisy results.

The better architecture is:

```text
                 MSEM
                  |
          Exposure Graph
                  |
          +-------+-------+
          |               |
       Identity        Resource
          |               |
          +-------+-------+
                  |
          Privilege Relationship
                  |
        +---------+---------+
        |                   |
   High Privilege      Broad Scope
        |                   |
        +---------+---------+
                  |
          Potential Excessive
              Privilege
                  |
        +---------+---------+
        |                   |
       User              IAM Team
```

The next step is to inspect **one or two real `has role on` records** from your `ExposureGraphEdges` table. Once those columns are known, the final KQL can be written against the **actual MSEM schema in your tenant**, without using unsupported fields such as `SourceNodeEntityIds`.
