# Use Case #7 — User Belongs to Risky Group

## 1. Use Case

**User belongs to a risky group → User + Group Owner**

### Objective

Identify users who are members of groups that create elevated security exposure, such as:

* Privileged groups
* Groups with access to critical assets
* Groups involved in attack paths
* Groups associated with security findings
* Groups providing excessive permissions
* Groups with high-risk exposure relationships

The notification should go to:

* **User** — awareness/remediation
* **Group Owner** — review membership and access

---

# 2. Example Scenario

```text
User Account
     |
     | member of
     v
User Group
     |
     +----> has role on ----> Critical Resource
     |
     +----> can authenticate to ----> Critical Resource
     |
     +----> Attack Path
     |
     +----> Security Finding
```

Example:

```text
User: john@contoso.com
Group: Finance-Privileged-Access
Risk: High
Reason: Group provides access to critical resources

Notification:
    ├── User
    └── Group Owner
```

---

# 3. MSEM Data Sources

Primary tables:

```text
ExposureGraphNodes
ExposureGraphEdges
```

The environment already contains relevant node categories such as:

```text
user_group
user_account
identity
identities
finding
security_finding
access
```

Relevant relationships to investigate include:

```text
member of
has role on
can authenticate to
permissions
affecting
```

---

# 4. Step 1 — Identify Groups

First determine how groups are represented in your tenant.

```kql
ExposureGraphNodes
| where NodeLabel contains "group"
| summarize Count=count() by NodeLabel
| order by Count desc
```

Then inspect the group nodes:

```kql
ExposureGraphNodes
| where NodeLabel contains "group"
| project
    NodeId,
    NodeLabel,
    NodeName,
    Categories,
    NodeProperties
| take 100
```

This tells us which `NodeLabel` should be used in the production query.

---

# 5. Step 2 — Identify User → Group Relationships

Your environment already contains the `member of` relationship.

First validate its direction:

```kql
ExposureGraphEdges
| where EdgeLabel =~ "member of"
| summarize Count=count()
    by SourceNodeLabel,
       TargetNodeLabel,
       EdgeLabel
| order by Count desc
```

We want to establish whether the graph represents:

```text
User → member of → Group
```

or the reverse.

Do not assume the direction until this query confirms it.

---

# 6. Step 3 — Inspect Actual Membership

```kql
ExposureGraphEdges
| where EdgeLabel =~ "member of"
| project
    SourceNodeId,
    SourceNodeName,
    SourceNodeLabel,
    TargetNodeId,
    TargetNodeName,
    TargetNodeLabel
| take 100
```

Ideally we should see something similar to:

```text
SourceNodeLabel = user_account
TargetNodeLabel = user_group
EdgeLabel       = member of
```

---

# 7. Step 4 — Identify Potentially Risky Groups

There are several ways to define a risky group.

## Method A — Group has privileged access

Find groups involved in `has role on` relationships:

```kql
ExposureGraphEdges
| where EdgeLabel =~ "has role on"
| where SourceNodeLabel contains "group"
| summarize
    RelationshipCount=count()
    by SourceNodeId,
       SourceNodeName,
       SourceNodeLabel,
       TargetNodeLabel
| order by RelationshipCount desc
```

These groups are candidates for further risk analysis.

---

# 8. Method B — Group Can Access Resources

```kql
ExposureGraphEdges
| where EdgeLabel in~ (
    "can authenticate to",
    "has role on",
    "permissions"
)
| where SourceNodeLabel contains "group"
| summarize
    RelationshipCount=count(),
    RelationshipTypes=make_set(EdgeLabel)
    by SourceNodeId,
       SourceNodeName,
       SourceNodeLabel
| order by RelationshipCount desc
```

A group with access to a large number of resources may deserve review.

However, **relationship count alone should not be considered proof of risk**.

---

# 9. Method C — Group Is Associated With Findings

Investigate groups connected to security findings:

```kql
ExposureGraphEdges
| where EdgeLabel =~ "affecting"
| where SourceNodeLabel contains "group"
    or TargetNodeLabel contains "group"
| summarize
    Count=count()
    by SourceNodeLabel,
       TargetNodeLabel,
       EdgeLabel
| order by Count desc
```

Inspect actual records:

```kql
ExposureGraphEdges
| where EdgeLabel =~ "affecting"
| where SourceNodeLabel contains "group"
    or TargetNodeLabel contains "group"
| project *
| take 100
```

---

# 10. Method D — Group Is Part of an Attack Path

This is one of the strongest indicators.

Look for group relationships participating in exposure paths:

```kql
ExposureGraphEdges
| where SourceNodeLabel contains "group"
    or TargetNodeLabel contains "group"
| where EdgeLabel in~ (
    "member of",
    "has role on",
    "can authenticate to",
    "permissions",
    "affecting"
)
| project
    SourceNodeId,
    SourceNodeName,
    SourceNodeLabel,
    EdgeLabel,
    TargetNodeId,
    TargetNodeName,
    TargetNodeLabel
| take 200
```

The goal is to establish:

```text
User
 ↓
Risky Group
 ↓
Access / Privilege
 ↓
Critical Asset / Finding
```

---

# 11. Candidate Detection Logic

Once the `member of` direction is confirmed, the detection can be constructed around:

```text
User
  ↓
member of
  ↓
Risky Group
  ↓
Security Exposure
```

For example, if the graph confirms:

```text
User → member of → Group
```

a candidate query can start with:

```kql
let UserGroups =
    ExposureGraphEdges
    | where EdgeLabel =~ "member of"
    | where SourceNodeLabel in~ ("user", "user_account", "identity")
    | where TargetNodeLabel contains "group"
    | project
        UserNodeId = SourceNodeId,
        UserName = SourceNodeName,
        GroupNodeId = TargetNodeId,
        GroupName = TargetNodeName;

let RiskyGroups =
    ExposureGraphEdges
    | where EdgeLabel in~ (
        "has role on",
        "can authenticate to",
        "permissions",
        "affecting"
    )
    | where SourceNodeLabel contains "group"
    | summarize
        RiskRelationshipCount = count(),
        RiskRelationshipTypes = make_set(EdgeLabel)
        by GroupNodeId = SourceNodeId,
           GroupName = SourceNodeName;

UserGroups
| join kind=inner RiskyGroups on GroupNodeId
| project
    UserName,
    UserNodeId,
    GroupName,
    GroupNodeId,
    RiskRelationshipCount,
    RiskRelationshipTypes
| order by RiskRelationshipCount desc
```

### Important

This is a **candidate detection**, not yet the final production rule.

The definition of `RiskyGroups` should eventually be based on validated MSEM risk characteristics rather than only the number of relationships.

---

# 12. Better Risk Classification

I recommend assigning risk based on the group's actual exposure.

| Group condition                                                | Suggested severity |
| -------------------------------------------------------------- | ------------------ |
| Group has access to normal resources                           | Low                |
| Group has excessive permissions                                | Medium             |
| Group provides privileged access                               | High               |
| Group can authenticate to critical asset                       | High               |
| Group participates in attack path                              | High               |
| Group provides privileged access to critical asset             | Critical           |
| Group associated with active security finding + critical asset | Critical           |

This gives the management dashboard a meaningful risk signal.

---

# 13. Recommended Production Model

Instead of:

```text
User ∈ Group = Alert
```

use:

```text
User
  |
  | member of
  v
Group
  |
  | risky relationship
  v
Resource / Finding / Attack Path
```

Therefore:

```text
ALERT =
User is member of Group
+
Group has validated risky exposure
```

This significantly reduces false positives.

---

# 14. Group Owner Resolution

The **Group Owner** may not necessarily be represented directly in the MSEM graph.

First investigate owner relationships:

```kql
ExposureGraphEdges
| where EdgeLabel contains "owner"
    or EdgeLabel contains "manage"
    or EdgeLabel contains "responsib"
| summarize
    Count=count()
    by EdgeLabel,
       SourceNodeLabel,
       TargetNodeLabel
| order by Count desc
```

If MSEM contains a usable group-owner relationship, use it.

Otherwise, use an authoritative identity source such as:

```text
Microsoft Entra ID
        ↓
Group
```
