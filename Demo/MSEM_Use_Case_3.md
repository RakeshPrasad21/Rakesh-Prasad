# MSEM Use Case 3 – User Account Is a Choke Point

## 1. Use Case

**Requirement:**

> Identify user accounts that act as a critical dependency or choke point for multiple resources, identities, or attack paths and notify the IAM/Security Team.

### Notification Target

| Finding                       | Notification                 |
| ----------------------------- | ---------------------------- |
| User account is a choke point | **IAM Team + Security Team** |

---

# 2. What Is a Choke Point?

A user account can be considered a potential **choke point** when multiple resources, permissions, identities, or attack paths depend on that account.

Example:

```text
                         User Account
                              |
             +----------------+----------------+
             |                |                |
             v                v                v
          Server01         Server02         Application
             |                |                |
             v                v                v
          Database         Critical VM      Sensitive Data
```

If the user account is compromised, the attacker may gain access to multiple downstream resources.

Therefore:

```text
One Identity
      |
      +----> Multiple Resources
      |
      +----> Multiple Privileges
      |
      +----> Multiple Attack Paths
```

can represent a potential choke point.

---

# 3. MSEM Data Used

The primary table is:

```text
ExposureGraphEdges
```

The important relationships to investigate are:

```text
has role on
member of
can authenticate to
authenticate as
credentials of
permissions
affecting
```

Your tenant already contains these relationship types, so they are good candidates for identifying identity dependencies.

---

# 4. Step 1 – Discover Identity Relationships

Start with:

```kql
ExposureGraphEdges
| where EdgeLabel in~ (
    "has role on",
    "member of",
    "can authenticate to",
    "authenticate as",
    "credentials of",
    "permissions",
    "affecting"
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

This confirms which relationships are actually being used by identities in your tenant.

---

# 5. Step 2 – Count Relationships Per User

The simplest choke-point indicator is the number of downstream relationships associated with an identity.

```kql
ExposureGraphEdges
| where SourceNodeLabel in~ (
    "identity",
    "user",
    "user_account"
)
| summarize
    RelationshipCount = count()
    by
    SourceNodeId,
    SourceNodeName,
    SourceNodeLabel
| order by RelationshipCount desc
```

### Example

```text
User                    RelationshipCount
------------------------------------------
john@company.com        157
rahul@company.com         94
amit@company.com          63
user4@company.com         12
```

A high relationship count makes the account a **candidate choke point**, but it does not by itself prove that the account is a security choke point.

---

# 6. Step 3 – Focus on Security-Relevant Relationships

Instead of counting every relationship, focus on relationships that could create meaningful access.

```kql
ExposureGraphEdges
| where SourceNodeLabel in~ (
    "identity",
    "user",
    "user_account"
)
| where EdgeLabel in~ (
    "has role on",
    "member of",
    "can authenticate to",
    "authenticate as",
    "credentials of",
    "permissions"
)
| summarize
    RelationshipCount = count(),
    RelationshipTypes = make_set(EdgeLabel)
    by
    SourceNodeId,
    SourceNodeName,
    SourceNodeLabel
| order by RelationshipCount desc
```

This gives a much better indicator.

Example:

```text
User              Count   RelationshipTypes
------------------------------------------------------------
john@company.com   82     has role on, permissions,
                           can authenticate to

rahul@company.com  51     member of, can authenticate to

amit@company.com   43     has role on, authenticate as
```

---

# 7. Step 4 – Identify Potential Choke Points

For an initial implementation, use a threshold.

Example:

```kql
let ChokePointThreshold = 20;

ExposureGraphEdges
| where SourceNodeLabel in~ (
    "identity",
    "user",
    "user_account"
)
| where EdgeLabel in~ (
    "has role on",
    "member of",
    "can authenticate to",
    "authenticate as",
    "credentials of",
    "permissions"
)
| summarize
    RelationshipCount = count(),
    RelationshipTypes = make_set(EdgeLabel)
    by
    SourceNodeId,
    SourceNodeName,
    SourceNodeLabel
| where RelationshipCount >= ChokePointThreshold
| extend
    Severity = case(
        RelationshipCount >= 100, "Critical",
        RelationshipCount >= 50, "High",
        RelationshipCount >= 20, "Medium",
        "Low"
    )
| project
    User = SourceNodeName,
    UserNodeId = SourceNodeId,
    RelationshipCount,
    RelationshipTypes,
    Severity
| order by RelationshipCount desc
```

---

# 8. Important: Relationship Count Alone Is Not Enough

This is very important for production.

Consider:

```text
User A
  |
  +-- 100 normal resources
```

versus:

```text
User B
  |
  +-- 5 critical resources
```

User A has more relationships, but User B may represent a much higher security risk.

Therefore, the final choke-point detection should consider:

```text
Relationship Count
        +
Privilege
        +
Critical Resource
        +
Authentication Dependency
        +
Attack Path
```

---

# 9. Recommended Choke Point Scoring

For the management/SOC use case, you can define:

| Condition                                    | Points |
| -------------------------------------------- | -----: |
| User has relationship to critical resource   |     +5 |
| User has privileged role                     |     +5 |
| User can authenticate to critical resource   |     +5 |
| User is member of privileged group           |     +4 |
| User has `credentials of` relationship       |     +5 |
| User participates in attack path             |     +5 |
| More than 20 security-relevant relationships |     +3 |
| More than 50 relationships                   |     +5 |
| More than 100 relationships                  |    +10 |

Then:

```text
0–9       → Normal
10–19     → Medium
20–29     → High
30+       → Critical
```

This is an **implementation scoring model**, not an MSEM-native score.

---

# 10. Better Detection – Security-Relevant Relationship Count

For your first version, I recommend this simpler KQL:

```kql
let ChokePointThreshold = 20;

ExposureGraphEdges
| where SourceNodeLabel in~ (
    "identity",
    "user",
    "user_account"
)
| where EdgeLabel in~ (
    "has role on",
    "member of",
    "can authenticate to",
    "authenticate as",
    "credentials of",
    "permissions"
)
| summarize
    RelationshipCount = count(),
    RelationshipTypes = make_set(EdgeLabel)
    by
    SourceNodeId,
    SourceNodeName,
    SourceNodeLabel
| where RelationshipCount >= ChokePointThreshold
| extend
    Severity = case(
        RelationshipCount >= 100, "Critical",
        RelationshipCount >= 50, "High",
        "Medium"
    )
| extend
    NotificationRequired = "Yes"
| project
    User = SourceNodeName,
    UserNodeId = SourceNodeId,
    RelationshipCount,
    RelationshipTypes,
    Severity,
    NotificationRequired
| order by RelationshipCount desc
```

---

# 11. Example Output

```text
User                  Count   Severity    Notification
-------------------------------------------------------
john@company.com      157     Critical    Yes
rahul@company.com      76     High        Yes
amit@company.com       31     Medium      Yes
```

This gives the IAM/Security team a starting list of identities that deserve investigation.

---

# 12. Recommended Enhancement – Critical Resources

The detection becomes much stronger if we can identify the target resources.

Conceptually:

```text
User
 |
 +----> Server01
 |
 +----> Server02
 |
 +----> Domain Controller
 |
 +----> SQL Database
 |
 +----> Critical Application
```

Then the result should be:

| User                                          | Relationships | Critical Resources | Severity |
| --------------------------------------------- | ------------: | -----------------: | -------- |
| [john@company.com](mailto:john@company.com)   |           157 |                  8 | Critical |
| [rahul@company.com](mailto:rahul@company.com) |            76 |                  4 | High     |
| [amit@company.com](mailto:amit@company.com)   |            31 |                  1 | Medium   |

This is much better than simply saying:

> User has 157 relationships.

---

# 13. Notification Workflow

```text
                   MSEM
                    |
            Exposure Graph
                    |
                    v
          Identity Relationships
                    |
                    v
        Choke Point Detection
                    |
                    v
       High/Critical Identity
                    |
             +------+------+
             |             |
             v             v
        IAM Team       Security Team
```

Unlike Use Case #1 and #2, **I would not necessarily notify the user** for this use case.

The requirement is:

> **IAM/Security Team**

because being a choke point is primarily an architectural/security condition rather than necessarily an action the end user can remediate.

---

# 14. Recommended IAM/Security Notification

Example:

```text
Subject:
MSEM – Potential Identity Choke Point Detected

User:
john@company.com

Severity:
Critical

Security-Relevant Relationships:
157

Relationship Types:
has role on
can authenticate to
permissions
member of

Potential Impact:
Multiple resources and/or security relationships
depend on this identity.

Recommended Action:

1. Review the user's privileges.
2. Identify critical resources associated with the account.
3. Validate whether the access is required.
4. Review alternative identities/service accounts.
5. Consider reducing unnecessary privilege or dependencies.
```

---

# 15. Recommended Production Architecture

```text
             MSEM Exposure Graph
                     |
                     v
             ExposureGraphEdges
                     |
                     v
             Identity Filtering
                     |
                     v
       Security-Relevant Relationships
                     |
                     v
          Relationship Aggregation
                     |
             +-------+-------+
             |               |
             v               v
       High Relationship   Critical
          Count            Resources
             |               |
             +-------+-------+
                     |
                     v
             Choke Point Score
                     |
             +-------+-------+
             |               |
             v               v
          IAM Team       Security Team
```

---

# 16. Important Validation Before Production

Do not immediately use `20`, `50`, or `100` as production thresholds.

First run:

```kql
ExposureGraphEdges
| where SourceNodeLabel in~ (
    "identity",
    "user",
    "user_account"
)
| where EdgeLabel in~ (
    "has role on",
    "member of",
    "can authenticate to",
    "authenticate as",
    "credentials of",
    "permissions"
)
| summarize
    RelationshipCount = count()
    by SourceNodeName
| summarize
    Users = count(),
    MinRelationships = min(RelationshipCount),
    AvgRelationships = avg(RelationshipCount),
    MaxRelationships = max(RelationshipCount)
```

This will show the actual distribution in your tenant.

Then we can determine a sensible threshold instead of arbitrarily choosing `20`.

---

# 17. Summary of MSEM Notification Use Cases

At this point your three use cases are:

| # | MSEM Finding                   | Notification         |
| - | ------------------------------ | -------------------- |
| 1 | User is part of an attack path | User + Security Team |
| 2 | User has excessive privilege   | User + IAM Team      |
| 3 | User account is a choke point  | IAM + Security Team  |

### Detection model

```text
#1 Attack Path
Graph Path Analysis
        |
        v
User → Attack Path → Critical Asset


#2 Excessive Privilege
Privilege Analysis
        |
        v
User → Role/Permission → Resource


#3 Choke Point
Dependency Analysis
        |
        v
User → Multiple Security-Relevant Relationships
```

The key point for **#3** is that the first version should identify **potential choke points**, not claim that a high relationship count alone proves an account is a choke point. The next refinement should correlate the identity with **critical assets and attack paths**.
