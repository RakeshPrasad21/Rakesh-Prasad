# Use Case #9 — High-Risk Identity Exposure

## 1. Use Case

**High-risk identity exposure → User + IAM/Security Team**

### Objective

Identify user accounts/identities that have multiple security exposures or a combination of high-impact relationships in the MSEM exposure graph.

Notify:

* **User** — awareness/remediation
* **IAM Team** — identity, privilege and access remediation
* **Security Team** — investigation where the exposure indicates attack-path or compromise risk

---

# 2. Why This Use Case Is Different

The previous use cases identify individual conditions:

```text
User → excessive privilege
User → risky group
User → exposed credential
User → attack path
User → critical asset
```

This use case combines those signals:

```text
                 User Identity
                       |
       ┌───────────────┼────────────────┐
       ▼               ▼                ▼
   Privilege       Credential       Attack Path
       |             Exposure            |
       ▼               ▼                ▼
    Risky Group    Security Finding   Critical Asset
       |
       └───────────────┬────────────────┘
                       ▼
              HIGH-RISK IDENTITY
                       |
                ┌──────┴──────┐
                ▼             ▼
               IAM          Security
```

---

# 3. Example Scenario

A user may not be critical because of one relationship alone.

For example:

```text
User
 |
 +-- member of --> Privileged Group
 |
 +-- credentials of --> Exposed Credential
 |
 +-- can authenticate to --> Critical Asset
 |
 +-- associated with --> Attack Path
```

This should be prioritized much higher than a user who simply belongs to a normal group.

---

# 4. MSEM Data Sources

Primary tables:

```text
ExposureGraphNodes
ExposureGraphEdges
```

Relevant node categories already observed in the environment include:

```text
identity
identities
user_account
user_group
device
computer_account
secret
cookies
finding
security_finding
access
```

Relevant relationships include:

```text
member of
has role on
can authenticate to
authenticate as
credentials of
permissions
affecting
```

---

# 5. Step 1 — Identify Identity Nodes

```kql id="4w8x2p"
ExposureGraphNodes
| where NodeLabel in~ (
    "identity",
    "identities",
    "user_account",
    "user"
)
| summarize Count=count() by NodeLabel
| order by Count desc
```

Inspect the identities:

```kql id="j2q7nf"
ExposureGraphNodes
| where NodeLabel in~ (
    "identity",
    "identities",
    "user_account",
    "user"
)
| project
    NodeId,
    NodeLabel,
    NodeName,
    Categories,
    NodeProperties
| take 100
```

---

# 6. Step 2 — Identify Identity Risk Relationships

Start by measuring the security-relevant relationships associated with identities.

```kql id="b8t3m1"
ExposureGraphEdges
| where SourceNodeLabel in~ (
    "identity",
    "identities",
    "user_account",
    "user"
)
    or TargetNodeLabel in~ (
        "identity",
        "identities",
        "user_account",
        "user"
    )
| where EdgeLabel in~ (
    "member of",
    "has role on",
    "can authenticate to",
    "authenticate as",
    "credentials of",
    "permissions",
    "affecting"
)
| summarize
    RelationshipCount=count(),
    RelationshipTypes=make_set(EdgeLabel)
    by SourceNodeId,
       SourceNodeName,
       SourceNodeLabel
| order by RelationshipCount desc
```

This is a **discovery query**, not yet a risk score.

---

# 7. Step 3 — Build Individual Risk Signals

The recommended approach is to calculate separate signals.

## Signal A — Privileged Access

```kql id="0u6y4r"
ExposureGraphEdges
| where EdgeLabel =~ "has role on"
| where SourceNodeLabel in~ (
    "identity",
    "identities",
    "user_account",
    "user"
)
| summarize
    PrivilegeRelationshipCount=count()
    by UserNodeId=SourceNodeId,
       UserName=SourceNodeNa
```
