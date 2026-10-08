# MSEM Use Case 4 – User's Device Is Exposed

## 1. Use Case

**Requirement:**

> Identify exposed user devices and notify the associated device owner.

### Notification Target

| Finding                  | Notification     |
| ------------------------ | ---------------- |
| User's device is exposed | **Device Owner** |

---

# 2. Objective

Use Microsoft Security Exposure Management (MSEM) exposure graph data to identify devices that have security exposures and determine the user associated with the device.

The intended flow is:

```text
Exposed Device
      |
      v
Identify Device Owner
      |
      v
User / Owner
      |
      v
Send Notification
```

---

# 3. Example Scenario

```text
Laptop-001
    |
    +-- Vulnerability
    |
    +-- Security Finding
    |
    +-- Attack Path
    |
    +-- Exposed Configuration
    |
    v
Device Owner:
john@company.com
```

Notification:

> Your device has been identified as part of a security exposure. Please review the recommended remediation.

---

# 4. MSEM Tables

The primary tables are:

```text
ExposureGraphNodes
ExposureGraphEdges
```

We use:

* `ExposureGraphNodes` → identify devices and findings
* `ExposureGraphEdges` → determine the relationship between the device and owner/exposure

---

# 5. Step 1 – Discover Device Node Types

Start with:

```kql id="lpmcgr"
ExposureGraphNodes
| where
    NodeLabel contains "device"
    or NodeLabel contains "computer"
    or NodeLabel contains "endpoint"
    or NodeLabel contains "machine"
| summarize
    Count = count()
    by
    NodeLabel
| order by Count desc
```

### Purpose

This identifies the device node labels actually populated in your tenant.

Your existing MSEM data already showed categories such as:

```text
device
physical_device
computer_account
compute
virtual_machine
```

The actual `NodeLabel` should be confirmed from your tenant.

---

# 6. Step 2 – Discover Device Relationships

Run:

```kql id="a0ox3j"
ExposureGraphEdges
| where
    SourceNodeLabel contains "device"
    or TargetNodeLabel contains "device"
    or SourceNodeLabel contains "computer"
    or TargetNodeLabel contains "computer"
| summarize
    Count = count()
    by
    EdgeLabel,
    SourceNodeLabel,
    TargetNodeLabel
| order by Count desc
```

This is important because we need to determine how MSEM represents:

```text
User → Device
Device → User
Device → Finding
Finding → Device
```

---

# 7. Step 3 – Find Device → User Relationships

If the graph contains a direct relationship between the device and the owner, inspect it:

```kql id="3k8k6v"
ExposureGraphEdges
| where
    SourceNodeLabel contains "device"
    or TargetNodeLabel contains "device"
| where
    EdgeLabel in~ (
        "owned by",
        "belongs to",
        "used by",
        "assigned to",
        "frequently logged in by"
    )
| project *
| take 100
```

Your existing MSEM data contains the relationship:

```text
frequently logged in by
```

which is particularly interesting for determining the likely user associated with a device.

However, we should validate the actual direction:

```text
Device → User
```

or:

```text
User → Device
```

before using it in production.

---

# 8. Step 4 – Basic Exposed Device Query

First identify devices that have exposure-related relationships:

```kql id="fr6shv"
ExposureGraphEdges
| where
    SourceNodeLabel contains "device"
    or TargetNodeLabel contains "device"
| where EdgeLabel in~ (
    "affecting",
    "runs on",
    "contains"
)
| project
    SourceNodeId,
    SourceNodeLabel,
    SourceNodeName,
    TargetNodeId,
    TargetNodeLabel,
    TargetNodeName,
    EdgeLabel
```

This gives us the candidate exposed devices.

---

# 9. Step 5 – Identify Exposure Findings

Your tenant has a large number of nodes categorized as:

```text
finding
security_finding
vulnerability_findings
management_finding
```

So inspect those first:

```kql id="p2xjij"
ExposureGraphNodes
| where
    NodeLabel contains "finding"
    or NodeLabel contains "vulnerability"
    or NodeLabel contains "security"
| summarize
    Count = count()
    by NodeLabel
| order by Count desc
```

This determines which finding labels are available.

---

# 10. Step 6 – Find Device → Finding Relationships

```kql id="j5xk1d"
ExposureGraphEdges
| where
    (
        SourceNodeLabel contains "device"
        and TargetNodeLabel contains "finding"
    )
    or
    (
        TargetNodeLabel contains "device"
        and SourceNodeLabel contains "finding"
    )
| project
    SourceNodeId,
    SourceNodeLabel,
    SourceNodeName,
    TargetNodeId,
    TargetNodeLabel,
    TargetNodeName,
    EdgeLabel
| take 100
```

The goal is to establish a relationship like:

```text
Device
   |
   +---- affecting ----> Finding
```

or:

```text
Finding
   |
   +---- affecting ----> Device
```

---

# 11. Step 7 – Identify Device Owner

Once the relationship direction is confirmed, the final query can correlate:

```text
Device
   |
   +----> Finding
   |
   +----> User
```

For example, if the relationship is:

```text
Device → frequently logged in by → User
```

the query could be:

```kql id="3dy4yw"
ExposureGraphEdges
| where EdgeLabel =~ "frequently logged in by"
| where SourceNodeLabel contains "device"
| project
    DeviceId = SourceNodeId,
    DeviceName = SourceNodeName,
    UserId = TargetNodeId,
    UserName = TargetNodeName,
    Relationship = EdgeLabel
```

This should be validated against your actual data before production.

---

# 12. Combined Conceptual Detection

The desired result is:

```text
Device
  |
  +----> Exposure/Finding
  |
  +----> Owner/User
```

The output should be:

| Device   | Owner                                         | Exposure         | Severity |
| -------- | --------------------------------------------- | ---------------- | -------- |
| LAPTOP01 | [john@company.com](mailto:john@company.com)   | Vulnerability    | High     |
| LAPTOP02 | [rahul@company.com](mailto:rahul@company.com) | Security Finding | Medium   |
| LAPTOP03 | [amit@company.com](mailto:amit@company.com)   | Attack Path      | Critical |

---

# 13. Recommended Production Output

The final KQL should return:

| Column               | Purpose                           |
| -------------------- | --------------------------------- |
| DeviceName           | Device requiring attention        |
| DeviceNodeId         | MSEM device node                  |
| DeviceOwner          | User associated with device       |
| OwnerNodeId          | MSEM identity node                |
| ExposureType         | Vulnerability/Finding/Attack Path |
| ExposureName         | Specific exposure                 |
| Severity             | Risk severity                     |
| Relationship         | Why the device is exposed         |
| NotificationRequired | Yes/No                            |

Example:

```text id="8j5j1n"
DeviceName:
LAPTOP-001

DeviceOwner:
john@company.com

ExposureType:
Vulnerability

Exposure:
Critical vulnerability

Severity:
High

NotificationRequired:
Yes
```

---

# 14. Notification Workflow

```text id="yq3f3k"
                  MSEM
                   |
           Exposure Graph
                   |
                   v
            Exposed Device
                   |
          +--------+--------+
          |                 |
          v                 v
       Finding          Device Owner
          |                 |
          +--------+--------+
                   |
                   v
             Notification
                   |
                   v
              Device Owner
```

---

# 15. User Notification

Example Teams/Email notification:

```text id="xq2h9d"
Subject:
MSEM – Security Exposure Detected on Your Device

Hello <User>,

Microsoft Security Exposure Management has identified
a security exposure associated with your device.

Device:
<DeviceName>

Exposure:
<ExposureType>

Finding:
<ExposureName>

Severity:
<Severity>

Recommended Action:
Please review and remediate the identified issue
according to the security team's guidance.

Security Operations
```

---

# 16. Important Design Consideration – Device Owner

Do not assume:

```text
DeviceName = User
```

The device owner should be resolved through the MSEM graph or another authoritative identity/device source.

Possible relationships include:

```text
Device
   |
   +-- frequently logged in by --> User
```

or:

```text
Device
   |
   +-- owned by --> User
```

or:

```text
User
   |
   +-- uses --> Device
```

If MSEM doesn't provide a reliable owner relationship, use an authoritative device inventory such as:

```text
Microsoft Intune
Microsoft Defender for Endpoint
Entra ID
```

to resolve the device owner.

---

# 17. Avoid False Positives

Not every device finding should trigger a user notification.

Recommended filtering:

```text
Low
 ↓
Dashboard only

Medium
 ↓
Notification depending on policy

High
 ↓
Notify device owner

Critical
 ↓
Notify device owner
+
Security Team
```

For example:

| Exposure                       | User Notification |
| ------------------------------ | ----------------- |
| Informational finding          | No                |
| Low vulnerability              | No                |
| Medium vulnerability           | Optional          |
| High vulnerability             | Yes               |
| Critical vulnerability         | Yes               |
| Device in critical attack path | Yes               |
| Compromised device             | Yes               |

---

# 18. Recommended Detection Architecture

```text
                   MSEM
                    |
                    v
          ExposureGraphNodes
                    +
          ExposureGraphEdges
                    |
                    v
              Device Filter
                    |
          +---------+---------+
          |                   |
          v                   v
       Exposure           Device Owner
          |                   |
          +---------+---------+
                    |
                    v
             Risk Evaluation
                    |
            +-------+-------+
            |               |
            v               v
        High/Critical      Low
            |               |
            v               v
       Notification       Dashboard
            |
            v
       Device Owner
```

---

# 19. Validation Queries

Before creating the production detection, run these three queries.

### Query 1 – Device labels

```kql id="txc4yq"
ExposureGraphNodes
| where
    NodeLabel contains "device"
    or NodeLabel contains "computer"
| summarize Count = count() by NodeLabel
| order by Count desc
```

### Query 2 – Device relationships

```kql id="x7d8wa"
ExposureGraphEdges
| where
    SourceNodeLabel contains "device"
    or TargetNodeLabel contains "device"
| summarize
    Count = count()
    by
    EdgeLabel,
    SourceNodeLabel,
    TargetNodeLabel
| order by Count desc
```

### Query 3 – Device owner candidates

```kql id="qz3v4h"
ExposureGraphEdges
| where EdgeLabel in~ (
    "owned by",
    "belongs to",
    "used by",
    "assigned to",
    "frequently logged in by"
)
| project *
| take 100
```

---

# 20. Final Recommendation

For this use case, **do not immediately build the final KQL around a guessed relationship such as `owned by`**.

Your tenant already has:

```text
frequently logged in by
```

which may provide a useful way to identify the user associated with a device.

First validate:

```text
Device → frequently logged in by → User
```

and identify the actual MSEM relationships between:

```text
Device
   |
   +---- Finding
   |
   +---- Vulnerability
   |
   +---- Attack Path
   |
   +---- User
```

Once those relationships are confirmed, the production detection becomes:

```text
Exposed Device
      |
      +---- Exposure Severity >= High
      |
      +---- Device Owner identified
                    |
                    v
             Notification
                    |
                    v
             Device Owner
```

This makes **“User's device is exposed → Device Owner”** a clean and actionable MSEM-to-user notification use case rather than simply notifying users for every device-related graph relationship.
