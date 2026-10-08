# Use Case #8 — Attack Path Reaches User's Account

## 1. Use Case

**Attack path reaches user's account → User + SOC**

### Objective

Identify when an MSEM attack path can reach or compromise a user's account/identity.

The detection should notify:

* **User** — awareness and immediate action
* **SOC** — investigation and threat response

This is a high-value identity exposure use case because the user account may represent the final target or an important step toward a critical resource.

---

# 2. Example Scenario

A simplified attack path could look like:

```text
Compromised Device
        |
        | can authenticate to
        v
User Account
        |
        | has role on
        v
Privileged Resource
        |
        v
Critical Asset
```

Or:

```text
External Exposure
       ↓
Compromised Endpoint
       ↓
Credential
       ↓
User Account
       ↓
Critical Resource
```

The important condition is:

```text
Attack Path → User Account
```

---

# 3. MSEM Data Sources

Primary tables:

```text
ExposureGraphNodes
ExposureGraphEdges
```

Relevant node categories in the current environment include:

```text
identity
identities
user_account
user_group
device
computer_account
finding
security_finding
access
```

Relevant relationships already observed include:

```text
can authenticate to
authenticate as
credentials of
member of
has role on
affecting
```

---

# 4. Step 1 — Identify User Account Nodes

First confirm the actual user node types in the tenant.

```kql id="8qk4dp"
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

Inspect sample records:

```kql id="5d7q8x"
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

# 5. Step 2 — Discover Relationships Involving User Accounts

```kql id="h6s2k3"
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
| summarize
    Count=count()
    by EdgeLabel,
       SourceNodeLabel,
       TargetNodeLabel
| order by Count desc
```

This gives us the relationships that can potentially form an attack path involving a user.

---

# 6. Step 3 — Identify Potential Attack-Path Relationships

Start with the security-relevant relationships:

```kql id="v2j9x4"
ExposureGraphEdges
| where EdgeLabel in~ (
    "can authenticate to",
    "authenticate as",
    "credentials of",
    "member of",
    "has role on",
    "permissions",
    "affecting"
)
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

This is a discovery query rather than the final detection.

---

# 7. Step 4 — Determine Whether the User Is the Target

The most important question is:

> Does the graph show an exposure relationship **ending at the user's account**?

For example:

```text
Device
   |
   | can authenticate to
   v
User Account
```

or:

```text
Credential
   |
   | credentials of
   v
User Account
```

Inspect relationships where the **target is a user**:

```kql id="k7w8fa"
ExposureGraphEdges
| where TargetNodeLabel in~ (
    "identity",
    "identities",
    "user_account",
    "user"
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

This is one of the most important validation queries for this use case.

---

# 8. Step 5 — Identify High-Risk Sources

Not every source reaching a user represents an attack path.

We should prioritize sources such as:

```text
finding
security_finding
device
computer_account
credential
secret
user_group
access
```

Example discovery query:

```kql id="1y5j9c"
ExposureGraphEdges
| where TargetNodeLabel in~ (
    "identity",
    "identities",
    "user_account",
    "user"
)
| where SourceNodeLabel in~ (
    "finding",
    "security_finding",
    "device",
    "computer_account",
    "secret",
    "user_group",
    "access"
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

---

# 9. Candidate Detection Logic

A basic candidate model is:

```text
Risky Source
     ↓
Security-relevant relationship
     ↓
User Account
```

For example:

```kql id="a6u4t2"
ExposureGraphEdges
| where TargetNodeLabel in~ (
    "identity",
    "identities",
    "user_account",
    "user"
)
| where SourceNodeLabel in~ (
    "finding",
    "security_finding",
    "device",
    "computer_account",
    "secret",
    "access"
)
| where EdgeLabel in~ (
    "can authenticate to",
    "authenticate as",
    "credentials of",
    "affecting",
    "permissions"
)
| project
    UserName = TargetNodeName,
    UserNodeId = TargetNodeId,
    UserNodeLabel = TargetNodeLabel,
    SourceNodeName,
    SourceNodeId,
    SourceNodeLabel,
    Relationship = EdgeLabel
```

This produces **candidate user exposures**.

---

# 10. Important Difference — Exposure vs Attack Path

The query above should **not automatically be called an attack-path detection**.

There is an important distinction:

### Exposure relationship

```text
Device → can authenticate to → User
```

### Attack path

```text
Internet Exposure
      ↓
Vulnerable Device
      ↓
Compromised Credential
      ↓
User Account
      ↓
Critical Asset
```

The second is significantly more meaningful.

Therefore, if the tenant exposes explicit attack-path/path information, use that information rather than assuming that every graph relationship constitutes an attack path.

---

# 11. Attack-Path Enrichment

Once a user is identified as being reachable, enrich the detection with additional relationships.

For example:

```text id="zq34kp"
User
 |
 +---- member of ----> Group
 |
 +---- has role on ---> Resource
 |
 +---- can authenticate to ---> Asset
 |
 +---- authenticate as ---> Identity
```

This allows us to answer:

> **Why is this user's account important?**

For example:

```text
User Account
     ↓
Member of Privileged Group
     ↓
Can access Critical Asset
```

This should increase the severity.

---

# 12. Suggested Severity

| Condition                                           | Severity | Notification |
| --------------------------------------------------- | -------- | ------------ |
| User has exposure relationship                      | Medium   | User + SOC   |
| User is reachable through risky device/credential   | High     | User + SOC   |
| User is part of attack path                         | High     | User + SOC   |
| Attack path reaches privileged user                 | Critical | User + SOC   |
| Attack path reaches user with critical asset access | Critical | User + SOC   |

---

# 13. Recommended Detection Logic

The production logic should ultimately look like:

```text id="gk4f8d"
IF

    Attack path reaches User Account

AND

    Source contains security-relevant exposure

THEN

    Create Security Event

    → Notify User
    → Notify SOC
```

For stronger prioritization:

```text id="q0z3m2"
IF

    Attack Path → User

AND

    User → Privileged Group

OR

    User → Critical Asset

THEN

    Severity = Critical
```

---

# 14. Logic App / Automation Flow

```text id="0x8h7v"
              MSEM
                |
                ▼
       Attack Path Detection
                |
                ▼
        Does path reach user?
                |
          ┌─────┴─────┐
         YES           NO
          |
          ▼
    Resolve User
          |
          ▼
   Enrich User Risk
          |
     ┌────┴─────┐
     ▼          ▼
   User        SOC
     |          |
     └────┬─────┘
          ▼
      Investigation
```

---

# 15. SOC Enrichment

The SOC notification should contain more than the user's name.

Recommended fields:

```text id="k3h7rs"
UserName
UserNodeId
SourceNodeName
SourceNodeId
SourceNodeLabel
Relationship
AttackPathIndicator
PrivilegeIndicator
CriticalAssetIndicator
Severity
```

Example:

```text
MSEM Attack Path Reaches User

User: john@contoso.com
Severity: High

Attack Path Source:
Vulnerable Endpoint-123

Relationship:
can authenticate to

User Privilege:
Privileged = Yes

Critical Asset Access:
Yes

SOC Action:
Investigate the endpoint, credential exposure and
user account activity.
```

---

# 16. User Notification

Keep the user notification intentionally simple.

```text
Security Alert: Your account requires attention

Your account has been identified as being associated with
a security exposure path.

Please follow the organization's security instructions and
contact the Security Team if requested.

Do not share your password or authentication information.
```

Avoid exposing detailed attack-path information to the end user unless the organization's security policy permits it.

---

# 17. Management Dashboard Metrics

This use case can contribute several useful MSEM dashboard metrics:

```text
Users Reached by Attack Paths
        ↓
High-Risk User Accounts
        ↓
Privileged Users in Attack Paths
        ↓
Users Connected to Critical Assets
        ↓
Attack Paths Requiring Remediation
        ↓
Attack Paths Remediated
```

Example:

| Metric                             | Value |
| ---------------------------------- | ----: |
| Users reached by attack paths      |    32 |
| High-risk users                    |    14 |
| Privileged users                   |     5 |
| Users connected to critical assets |     8 |
| Critical attack paths              |     3 |
| Remediation required               |    12 |

---

# 18. Validation Queries

### Query 1 — User relationships

```kql id="3h8j1m"
ExposureGraphEdges
| where TargetNodeLabel in~ (
    "identity",
    "identities",
    "user_account",
    "user"
)
| summarize Count=count()
    by EdgeLabel,
       SourceNodeLabel,
       TargetNodeLabel
| order by Count desc
```

### Query 2 — Actual paths into users

```kql id="7f2m0v"
ExposureGraphEdges
| where TargetNodeLabel in~ (
    "identity",
    "identities",
    "user_account",
    "user"
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

### Query 3 — Security-relevant paths

```kql id="m7k3q1"
ExposureGraphEdges
| where TargetNodeLabel in~ (
    "identity",
    "identities",
    "user_account",
    "user"
)
| where EdgeLabel in~ (
    "can authenticate to",
    "authenticate as",
    "credentials of",
    "affecting",
    "permissions"
)
| project *
| take 200
```

---

# 19. Critical Validation Point

Before implementing this as a production alert, we need to determine whether your MSEM tenant exposes **explicit attack-path information** in the graph.

Do not assume:

```text
ExposureGraphEdges = Attack Paths
```

Instead, validate whether the graph contains enough information to reconstruct:

```text
Source
  ↓
Intermediate Node
  ↓
Intermediate Node
  ↓
User Account
```

If so, we can use graph traversal / `graph-match` or controlled joins to reconstruct the path.

If MSEM provides explicit path/attack-path identifiers or properties in your tenant, those should be preferred.

---

# 20. Final Detection Architecture

```text
             MSEM Exposure Graph
                     |
                     ▼
              Attack Path
                     |
                     ▼
             ┌──────────────┐
             │ User Account │
             └──────┬───────┘
                    |
           ┌────────┴────────┐
           ▼                 ▼
       User Risk          SOC Alert
           |                 |
           ▼                 ▼
     User Notification   Investigation
                             |
                    ┌────────┴────────┐
                    ▼                 ▼
              Credential          Endpoint
              investigation       investigation
                    |
                    ▼
             Remediation
```

## Recommended Production Definition

The clean definition for the dashboard and automation should be:

> **Detect when an MSEM exposure/attack path can reach a user account and notify the affected user and SOC for investigation.**

The most valuable enrichment is:

```text
Attack Path
     +
User Account
     +
Privilege
     +
Critical Asset Access
     +
Credential/Device Exposure
```

That turns this from a simple graph relationship into a meaningful **identity attack-path detection**.
