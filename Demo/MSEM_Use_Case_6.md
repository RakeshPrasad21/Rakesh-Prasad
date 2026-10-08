# Use Case #6 — User Credential Is Exposed

## 1. Use Case

**User credential is exposed → User + Security Team**

### Objective

Identify when a credential associated with a user account is exposed or involved in an MSEM exposure/finding, and notify:

* **User** — credential/account owner
* **Security Team** — for investigation and remediation

The objective is to identify potentially compromised credentials before they are used for unauthorized access.

---

## 2. Example Scenario

A user's credential is discovered in an exposed location or is associated with an MSEM security finding.

Example:

```text
User Account
     |
     | credentials of
     v
Credential / Secret
     |
     | affecting / associated finding
     v
Security Finding
     |
     +----> Exposure / Attack Path
```

Example notification:

> **Credential Exposure Detected**
>
> User: [user@contoso.com](mailto:user@contoso.com)
> Credential: <credential identifier/name>
> Exposure Finding: Credential exposed
> Severity: High
>
> **Action:** Security Team should investigate and initiate credential rotation/reset.

---

# 3. MSEM Data Sources

Primary tables:

```text
ExposureGraphNodes
ExposureGraphEdges
```

Potentially relevant node categories from the current environment include:

```text
secret
cookies
credential-related findings
finding
security_finding
vulnerability_findings
user_account
identity
identities
```

Important relationships already observed in the environment include:

```text
credentials of
affecting
can authenticate to
authenticate as
has role on
```

---

# 4. Step 1 — Discover Credential/Secret Nodes

Start by determining how credentials are represented in the tenant.

```kql
ExposureGraphNodes
| where NodeLabel contains "credential"
    or NodeLabel contains "secret"
    or NodeLabel contains "cookie"
| summarize Count=count() by NodeLabel
| order by Count desc
```

Also inspect the actual records:

```kql
ExposureGraphNodes
| where NodeLabel contains "credential"
    or NodeLabel contains "secret"
    or NodeLabel contains "cookie"
| project NodeId, NodeLabel, NodeName, Categories, NodeProperties
| take 100
```

This is important because the exact credential representation can differ between tenants.

---

# 5. Step 2 — Identify Credential Relationships

The environment already contains a `credentials of` relationship, so investigate its direction.

```kql
ExposureGraphEdges
| where EdgeLabel =~ "credentials of"
| summarize Count=count()
    by SourceNodeLabel,
       TargetNodeLabel,
       EdgeLabel
| order by Count desc
```

For example, we may discover:

```text
secret → credentials of → user_account
```

or:

```text
user_account → credentials of → secret
```

Do **not** assume the direction until this query confirms it.

---

# 6. Step 3 — Inspect Actual Credential Relationships

```kql
ExposureGraphEdges
| where EdgeLabel =~ "credentials of"
| project
    SourceNodeId,
    SourceNodeName,
    SourceNodeLabel,
    TargetNodeId,
    TargetNodeName,
    TargetNodeLabel
| take 100
```

This gives us the actual relationship between the credential and the user.

---

# 7. Step 4 — Find Credential Exposure / Findings

Now investigate whether credentials/secrets are associated with security findings.

```kql
ExposureGraphEdges
| where EdgeLabel =~ "affecting"
| summarize Count=count()
    by SourceNodeLabel,
       TargetNodeLabel,
       EdgeLabel
| order by Count desc
```

Then inspect the relevant records:

```kql
ExposureGraphEdges
| where EdgeLabel =~ "affecting"
| where SourceNodeLabel contains "finding"
    or TargetNodeLabel contains "finding"
    or SourceNodeLabel contains "credential"
    or SourceNodeLabel contains "secret"
    or TargetNodeLabel contains "credential"
    or TargetNodeLabel contains "secret"
| project *
| take 200
```

---

# 8. Candidate Detection Logic

The preferred detection model is:

```text
User
  ↓
Credential / Secret
  ↓
Exposure / Finding
```

Conceptually:

```kql
let CredentialRelationships =
    ExposureGraphEdges
    | where EdgeLabel =~ "credentials of"
    | project
        CredentialNodeId = SourceNodeId,
        CredentialName = SourceNodeName,
        CredentialLabel = SourceNodeLabel,
        UserNodeId = TargetNodeId,
        UserName = TargetNodeName,
        UserLabel = TargetNodeLabel;

let ExposedCredentials =
    ExposureGraphEdges
    | where EdgeLabel =~ "affecting"
    | project
        FindingSourceNodeId = SourceNodeId,
        FindingSourceNodeName = SourceNodeName,
        FindingSourceNodeLabel = SourceNodeLabel,
        FindingTargetNodeId = TargetNodeId,
        FindingTargetNodeName = TargetNodeName,
        FindingTargetNodeLabel = TargetNodeLabel;

CredentialRelationships
| join kind=inner ExposedCredentials
    on $left.CredentialNodeId == $right.FindingTargetNodeId
| project
    UserName,
    UserNodeId,
    CredentialName,
    CredentialNodeId,
    Finding=FindingSourceNodeName,
    FindingSourceNodeLabel
```

### Important

The join above is a **template**, not yet the final production query.

The correct join direction depends on what your tenant returns from:

```kql
ExposureGraphEdges
| where EdgeLabel =~ "credentials of"
```

and:

```kql
ExposureGraphEdges
| where EdgeLabel =~ "affecting"
```

---

# 9. Alternative — Search Credential Findings Directly

If MSEM represents exposed credentials directly as findings, this may be simpler:

```kql
ExposureGraphNodes
| where NodeLabel contains "finding"
    or NodeLabel contains "security_finding"
    or NodeLabel contains "management_finding"
| where tostring(NodeProperties) contains "credential"
    or tostring(NodeProperties) contains "secret"
    or tostring(NodeProperties) contains "password"
| project
    NodeId,
    NodeLabel,
    NodeName,
    Categories,
    NodeProperties
| take 200
```

This helps determine whether the exposure information is stored in:

* `NodeLabel`
* `NodeName`
* `Categories`
* `NodeProperties`

---

# 10. Recommended Severity

Not every credential relationship should generate an alert.

| Condition                                   | Severity | Notification                  |
| ------------------------------------------- | -------- | ----------------------------- |
| Credential associated with exposure finding | Medium   | User + Security               |
| Credential exposed and user is privileged   | High     | User + Security + IAM         |
| Credential involved in attack path          | High     | User + Security               |
| Credential associated with critical asset   | Critical | User + Security + Asset Owner |
| Credential + active exploitation indicator  | Critical | Immediate Security response   |

---

# 11. Production Notification Output

The final query should ideally produce:

```text
UserName
UserNodeId
CredentialName
CredentialNodeId
FindingName
FindingNodeId
FindingType
Severity
NotificationRequired
```

Example:

```text
UserName:       user@contoso.com
Credential:     Credential-123
Finding:        Exposed Credential
FindingType:    security_finding
Severity:       High
Notification:   Yes
```

---

# 12. Logic App Flow

Recommended automation:

```text
MSEM Exposure Graph
        |
        v
Scheduled KQL / Detection
        |
        v
Credential Exposure Detected
        |
        +------------------+
        |                  |
        v                  v
   Resolve User       Security Team
        |                  |
        v                  v
 User notification    Investigation
        |
        v
Credential Reset /
Rotation
```

### User notification

Send a controlled notification such as:

```text
Security Alert: Your account credential may be exposed.

Account: user@contoso.com
Severity: High

Please follow the organization's credential-reset procedure.

Do not share your current password or credential with anyone.
```

### Security notification

```text
MSEM Credential Exposure Detected

User: user@contoso.com
Credential: Credential-123
Finding: Exposed Credential
Severity: High

Recommended Actions:
1. Validate the finding.
2. Determine whether the credential is active.
3. Reset/rotate the credential.
4. Review recent sign-in activity.
5. Check whether the credential was used against sensitive resources.
6. Investigate related attack paths.
```

---

# 13. Validation Queries

### Check credential relationships

```kql
ExposureGraphEdges
| where EdgeLabel =~ "credentials of"
| project *
| take 100
```

### Check finding relationships

```kql
ExposureGraphEdges
| where EdgeLabel =~ "affecting"
| project *
| take 100
```

### Check credential-related nodes

```kql
ExposureGraphNodes
| where NodeLabel contains "credential"
    or NodeLabel contains "secret"
    or NodeLabel contains "cookie"
| project *
| take 100
```

### Search credential-related properties

```kql
ExposureGraphNodes
| where tostring(NodeProperties) contains "credential"
    or tostring(NodeProperties) contains "password"
    or tostring(NodeProperties) contains "secret"
| project NodeId, NodeLabel, NodeName, NodeProperties
| take 100
```

---

# 14. Key Design Point

For this use case, **do not implement the alert as simply:**

```text
credentials of → user
```

That would create too many false positives.

The stronger detection is:

```text
Credential
     |
     +--> associated with User
     |
     +--> Exposure/Finding
     |
     +--> potentially Attack Path
```

Therefore the production rule should ideally require **both**:

```text
Credential ↔ User
        AND
Credential ↔ Exposure/Finding
```

Then enrich the event with:

```text
Is Privileged?
Is In Attack Path?
Can Authenticate To Critical Asset?
Is Asset Critical?
```

This makes the use case much more valuable for the Security Team than simply reporting credentials present in the MSEM graph.

---

# 15. Implementation Status

| Component                                 | Status                            |
| ----------------------------------------- | --------------------------------- |
| Identify credential nodes                 | Discovery required                |
| Identify `credentials of` direction       | **Validate in tenant**            |
| Identify credential exposure relationship | **Validate in tenant**            |
| Link credential → user                    | **Validate join direction**       |
| Severity calculation                      | Can be implemented                |
| User notification                         | Logic App                         |
| Security notification                     | Logic App / Sentinel              |
| Credential reset                          | Optional automation with approval |
| Attack-path enrichment                    | Phase 2                           |

## Final Detection Concept

```text
        ┌─────────────────┐
        │   User Account  │
        └────────┬────────┘
                 │
          credentials of
                 │
                 ▼
        ┌─────────────────┐
        │ Credential/Secret│
        └────────┬────────┘
                 │
          exposed / finding
                 │
                 ▼
        ┌─────────────────┐
        │ Security Finding│
        └────────┬────────┘
                 │
        ┌────────┴────────┐
        ▼                 ▼
      User          Security Team
   Notification      Investigation
```

**Recommendation:** For your MSEM dashboard, classify this as a **High-value identity exposure use case**, but only generate the notification when the credential is connected to an actual exposure/finding rather than merely existing in the graph.
