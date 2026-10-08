# MSEM Use Case 5 – User Is Associated with Critical Asset

## 1. Use Case

**Requirement:**

> Identify users associated with critical assets and notify the appropriate asset owner.

### Notification Target

| Finding                                | Notification    |
| -------------------------------------- | --------------- |
| User is associated with critical asset | **Asset Owner** |

---

# 2. Objective

Use Microsoft Security Exposure Management (MSEM) Exposure Graph data to identify relationships between:

```text
User / Identity
       |
       v
Associated With
       |
       v
Critical Asset
       |
       v
Asset Owner
```

The objective is to provide the asset owner with visibility when a user has a meaningful relationship with a critical asset.

---

# 3. Example Scenario

```text
User
john@company.com
       |
       | can authenticate to
       |
       v
Production Server
SERVER01
       |
       | Criticality = High
       |
       v
Asset Owner
Infrastructure Team
```

The notification goes to:

```text
Infrastructure / Asset Owner
```

rather than automatically going to John.

---

# 4. Important Definition

A user being associated with an asset does **not necessarily mean the user owns the asset**.

For example:

```text
User
  |
  +---- can authenticate to ----> Server
```

means the user has an access relationship.

It does not mean:

```text
User = Asset Owner
```

Therefore, this use case has two separate relationships:

```text
User
  |
  +---- associated with ----> Critical Asset
                                  |
                                  +---- owned by ----> Asset Owner
```

---

# 5. MSEM Tables

Use:

```text
ExposureGraphNodes
ExposureGraphEdges
```

### ExposureGraphNodes

Used to identify:

* Users
* Identities
* Servers
* Devices
* Applications
* Cloud resources
* Critical assets

### ExposureGraphEdges

Used to identify relationships such as:

```text
can authenticate to
has role on
permissions
member of
runs on
contains
affecting
```

---

# 6. Step 1 – Discover Critical Asset Node Types

Start with:

```kql
ExposureGraphNodes
| summarize
    Count = count()
    by
    NodeLabel
| order by Count desc
```

This gives the actual node labels populated in your tenant.

You can then investigate categories such as:

```text
compute
device
virtual_machine
server
application
database
environmentAzure
environmentAws
```

---

# 7. Step 2 – Inspect Criticality Information

Search the node properties for criticality-related information:

```kql
ExposureGraphNodes
| where
    tostring(NodeProperties) contains "critical"
| project
    NodeId,
    NodeLabel,
    NodeName,
    Categories,
    NodeProperties
| take 100
```

### Purpose

We need to determine how MSEM represents asset criticality in your tenant.

Possible information may include:

```text
criticality
business criticality
asset criticality
criticality level
```

Do not assume a specific property name until it is confirmed in your tenant.

---

# 8. Step 3 – Identify User-to-Asset Relationships

Your tenant already contains relationships such as:

```text
can authenticate to
has role on
permissions
member of
```

Start with:

```kql
ExposureGraphEdges
| where EdgeLabel in~ (
    "can authenticate to",
    "has role on",
    "permissions",
    "member of"
)
| summarize
    Count = count()
    by
    EdgeLabel,
    SourceNodeLabel,
    TargetNodeLabel
| order by Count desc
```

This tells us which relationships actually connect identities and assets.

---

# 9. Step 4 – Inspect User → Asset Relationships

For example:

```kql
ExposureGraphEdges
| where EdgeLabel in~ (
    "can authenticate to",
    "has role on",
    "permissions"
)
| where
    SourceNodeLabel in~ (
        "identity",
        "user",
        "user_account"
    )
| project *
| take 100
```

The purpose is to validate the actual fields available in your tenant.

We should continue using fields such as:

```text
SourceNodeId
SourceNodeName
SourceNodeLabel
TargetNodeId
TargetNodeName
TargetNodeLabel
EdgeLabel
```

and avoid unsupported fie
