# Model Context Protocol (MCP) for SIEM and SOAR Discovery

## Executive Summary

This document outlines the implementation of Model Context Protocol (MCP) for SIEM (Security Information and Event Management) and SOAR (Security Orchestration, Automation, and Response) discovery and integration. The MCP framework enables AI assistants like GitHub Copilot, Claude, and ChatGPT to interact directly with security infrastructure, providing intelligent querying, analysis, and automation capabilities.

---

## 📋 Table of Contents

1. [Technical Description of MCP](#1-technical-description-of-mcp)
2. [How to Use MCP](#2-how-to-use-mcp)
3. [Prerequisites](#3-prerequisites-to-using-mcp)
4. [Use Cases](#4-example-use-cases)
5. [How It Works (Architecture)](#5-how-it-works-architecture)
6. [POC](#6-proposal-for-poc)

---

## 1. Technical Description of MCP

### 1.1 What is Model Context Protocol (MCP)?

**Model Context Protocol (MCP)** is an open-source protocol developed by Anthropic that enables AI models to securely connect to external data sources and tools. MCP provides a standardized way for AI assistants to:

- Access real-time data from enterprise systems
- Execute operations against security tools (SIEM, SOAR, EDR, etc.)
- Retrieve context-rich information for intelligent decision-making
- Automate security workflows through natural language commands

### 1.2 Core Components

```
┌─────────────────────────────────────────────────────────────┐
│                    MCP Architecture                         │
│                                                             │
│  ┌──────────────┐        ┌──────────────┐                   │
│  │  AI Client   │◄──────►│  MCP Server  │                   │
│  │  (Copilot,   │  JSON  │  (Security   │                   │
│  │   Claude)    │  -RPC  │   Connector) │                   │
│  └──────────────┘        └──────┬───────┘                   │
│                                  │                          │
│                                  ▼                          │
│                     ┌────────────────────────┐              │
│                     │   Security Systems     │              │
│                     │   • SIEM (Sentinel)    │              │
│                     │   • SOAR (Logic Apps)  │              │
│                     │   • Threat Intel       │              │
│                     └────────────────────────┘              │
└─────────────────────────────────────────────────────────────┘
```

**Key Components**:

1. **MCP Client**: AI assistant (GitHub Copilot, Claude Desktop, ChatGPT)
2. **MCP Server**: Middleware that exposes security tools as MCP-compatible endpoints
3. **Host**: The environment where MCP server runs (local machine, container, cloud VM)
4. **Resources**: Data sources (logs, alerts, incidents)
5. **Tools**: Executable functions (query KQL, create incidents, run playbooks)
6. **Prompts**: Pre-defined templates for common security tasks

**Host Considerations**:
- **Local Development**: VS Code with Python/Node.js runtime for testing and development
- **Production**: Azure Container Instances, Azure Functions, or dedicated VM for enterprise deployment
- **Security**: Host must have network access to Sentinel APIs and proper authentication credentials
- **Performance**: Host resources (CPU, memory) impact query response times and concurrent request handling

### 1.3 Technical Specifications

| **Aspect** | **Details** |
|------------|-------------|
| **Protocol** | JSON-RPC 2.0 over stdio, SSE (Server-Sent Events), or WebSocket |
| **Transport** | HTTP/HTTPS, stdio (standard input/output) |
| **Authentication** | OAuth 2.0, API Keys, Azure AD (Entra ID) |
| **Data Format** | JSON |
| **Language Support** | Python, TypeScript/JavaScript, Go, .NET |
| **Security** | TLS 1.2+, token-based auth, least privilege access |

### 1.4 MCP vs Traditional APIs

| **Feature** | **Traditional REST API** | **MCP** |
|-------------|--------------------------|---------|
| **Discovery** | Manual API documentation | Automatic capability discovery |
| **Natural Language** | Not supported | Native support via AI |
| **Context Awareness** | Stateless | Contextual conversations |
| **Error Handling** | Manual interpretation | AI-assisted troubleshooting |
| **Workflow Automation** | Requires scripting | Natural language commands |

---

## 2. How to Use MCP

### 2.1 Basic Workflow
The MCP workflow enables seamless interaction between users and security systems through natural language. Here's how the process works:

**Step-by-Step Process**:

1. **User Request**: Security analyst asks a question in natural language (e.g., "Show me critical alerts")
2. **AI Interpretation**: AI assistant (GitHub Copilot) understands the intent and determines which MCP tool to invoke
3. **MCP Translation**: MCP server translates the request into specific API calls or queries (e.g., KQL for Sentinel)
4. **Data Retrieval**: MCP server executes the query against Microsoft Sentinel or other security platforms
5. **Response Formatting**: MCP server formats the raw data into human-readable output
6. **AI Presentation**: AI assistant presents the results to the user with context and recommendations
   
```mermaid
sequenceDiagram
    participant User
    participant AI as AI Assistant (Copilot)
    participant MCP as MCP Server
    participant SIEM as Microsoft Sentinel
    
    User->>AI: "Show me critical alerts from the last 24 hours"
    AI->>MCP: Request: list_alerts(severity="Critical", timeRange="24h")
    MCP->>SIEM: KQL Query: SecurityAlert | where Severity == "Critical"
    SIEM-->>MCP: Results: 15 Critical Alerts
    MCP-->>AI: Formatted Alert Data
    AI-->>User: Display: "Found 15 critical alerts:<br/>1. Ransomware detected on SRV-001<br/>2. Brute force attempt on admin account..."
```

### 2.2 User Interaction Examples

#### **Example 1: Query SIEM for Alerts**

**User**: *"Show me all high severity alerts from the last hour"*

**AI (via MCP)**:
```
Querying Microsoft Sentinel...

Found 7 high severity alerts:
1. Suspicious PowerShell execution detected
   - Host: DESKTOP-ABC123
   - Time: 2026-01-29 10:15:23 UTC
   - Status: Active

2. Potential data exfiltration
   - Host: SRV-FILE-01
   - Time: 2026-01-29 10:42:11 UTC
   - Status: Under Investigation

[... 5 more alerts ...]
```

#### **Example 2: Create SOAR Incident**

**User**: *"Create an incident for the PowerShell alert and assign it to the SOC team"*

**AI (via MCP)**:
```
Creating incident in Microsoft Sentinel...

✓ Incident #1234 created successfully
  - Title: Suspicious PowerShell Execution on DESKTOP-ABC123
  - Severity: High
  - Status: New
  - Assigned To: SOC-Team@contoso.com
  - Related Alert: AlertId-98765
```

#### **Example 3: Run Threat Hunting Query**

**User**: *"Find all failed login attempts from external IPs in the last 7 days"*

**AI (via MCP)**:
```
Running KQL query against Sentinel...

SigninLogs
| where TimeGenerated > ago(7d)
| where ResultType != "0"
| where IPAddress !startswith "10."
| where IPAddress !startswith "172.16."
| where IPAddress !startswith "192.168."
| summarize FailedAttempts = count() by IPAddress, UserPrincipalName
| top 20 by FailedAttempts desc

Results:
╔════════════════╦══════════════════════════╦═════════════════╗
║ IP Address     ║ User                     ║ Failed Attempts ║
╠════════════════╬══════════════════════════╬═════════════════╣
║ 203.0.113.45   ║ admin@contoso.com        ║ 1,247           ║
║ 198.51.100.22  ║ john.doe@contoso.com     ║ 834             ║
║ 192.0.2.100    ║ service@contoso.com      ║ 523             ║
╚════════════════╩══════════════════════════╩═════════════════╝

⚠️ Recommendation: IP 203.0.113.45 shows suspicious activity (1,247 failed attempts)
   Suggested action: Block IP and investigate user account
```

### 2.3 Supported Commands (Natural Language)

**Alert & Incident Management**:
- "Show me all critical alerts"
- "Get details for incident #1234"
- "Close incident #5678 with resolution notes"
- "Escalate this alert to the security team"

**Threat Hunting**:
- "Find all suspicious logins from Russia"
- "Search for potential ransomware indicators"
- "Show me lateral movement patterns in the network"

**Automation & Playbooks**:
- "Run the phishing response playbook for this email"
- "Isolate the infected host SRV-001"
- "Block the malicious IP address 203.0.113.45"

**Reporting**:
- "Generate a summary of security events this week"
- "Export all malware detections from last month"
- "Create a compliance report for PCI-DSS assets"

---

## 3. Prerequisites to Using MCP

### 3.1 Technical Requirements

#### **Infrastructure**

| **Component** | **Requirement** | **Notes** |
|---------------|-----------------|-----------|
| **SIEM Platform** | Microsoft Sentinel with active workspace | Required for log analytics |
| **SOAR Platform** | Azure Logic Apps or Microsoft Sentinel Playbooks | For automation workflows |
| **Azure Subscription** | Active subscription with Contributor role | To deploy MCP server |
| **Log Analytics Workspace** | Workspace with 30+ days retention | Data source for queries |
| **Compute** | Azure Function App (Consumption or Premium) | To host MCP server |

#### **Software Dependencies**

```json
{
  "runtime": "Python 3.11+ or Node.js 18+",
  "frameworks": [
    "FastMCP (Python)",
    "MCP SDK (@modelcontextprotocol/sdk-typescript)"
  ],
  "azure_sdks": [
    "azure-identity",
    "azure-monitor-query",
    "azure-loganalytics",
    "azure-mgmt-securityinsight"
  ],
  "ai_clients": [
    "GitHub Copilot (VS Code Extension)",
    "Claude Desktop (with MCP support)",
    "OpenAI API (with custom integration)"
  ]
}
```

### 3.2 Access & Permissions

#### **Azure AD (Entra ID) Permissions**

**Service Principal Requirements**:
```yaml
App Registration: "MCP-Sentinel-Connector"
  Permissions:
    - Microsoft Graph:
        - SecurityEvents.Read.All
        - SecurityIncident.ReadWrite.All
        - User.Read.All
    - Azure Resource Manager:
        - Reader (Subscription level)
    - Log Analytics API:
        - Data.Read
```

**User Permissions** (for AI assistant operator):
- Microsoft Sentinel Reader (minimum)
- Microsoft Sentinel Responder (for incident management)
- Log Analytics Reader (for KQL queries)

#### **API Access**

1. **Microsoft Sentinel API**: Enabled via Azure AD app registration
2. **Log Analytics API**: Access via workspace ID + API key or Azure AD
3. **Azure Logic Apps**: Webhook URLs for playbook execution

### 3.3 Network & Security

**Firewall Rules**:
```
Outbound (from MCP server):
  - Azure Sentinel API: *.azure.com (HTTPS/443)
  - Azure AD: login.microsoftonline.com (HTTPS/443)
  - Log Analytics: api.loganalytics.io (HTTPS/443)

Inbound (to MCP server):
  - AI Client: Restricted to corporate network or VPN
  - Authentication: OAuth 2.0 token validation required
```

**Security Best Practices**:
- Use Managed Identity for Azure resource access
- Store credentials in Azure Key Vault
- Enable audit logging for all MCP operations
- Implement rate limiting (e.g., 100 requests/minute per user)
- Use least privilege principle for all permissions

### 3.4 Configuration Files

**MCP Server Configuration** (`mcp-config.json`):
```json
{
  "name": "sentinel-mcp-server",
  "version": "1.0.0",
  "tenant_id": "00000000-0000-0000-0000-000000000000",
  "workspace_id": "11111111-1111-1111-1111-111111111111",
  "subscription_id": "22222222-2222-2222-2222-222222222222",
  "resource_group": "rg-security-prod",
  "authentication": {
    "type": "azure_ad",
    "client_id": "33333333-3333-3333-3333-333333333333",
    "client_secret": "@Microsoft.KeyVault(SecretUri=https://kv-security.vault.azure.net/secrets/MCP-ClientSecret/)",
    "scope": "https://management.azure.com/.default"
  },
  "features": {
    "alert_querying": true,
    "incident_management": true,
    "kql_execution": true,
    "playbook_execution": true,
    "threat_intelligence": true
  },
  "rate_limiting": {
    "max_requests_per_minute": 100,
    "max_concurrent_queries": 10
  }
}
```

---

## 4. Example Use Cases

### 4.1 Security Operations Center (SOC) Use Cases

#### **Use Case 1: Automated Triage of Security Alerts**

**Scenario**: SOC analyst receives 500+ alerts daily, needs to prioritize critical threats

**Traditional Approach** (30 minutes):
1. Log into Sentinel portal
2. Manually filter alerts by severity
3. Click through each alert for details
4. Copy-paste data into Excel for analysis
5. Create incident tickets manually

**MCP-Enabled Approach** (2 minutes):

**Analyst**: *"Show me the top 10 most critical alerts from the last hour, sorted by risk score"*

**AI Response**:
```
Analyzing 500 alerts from Sentinel workspace...

Top 10 Critical Alerts (Sorted by Risk Score):

1. 🔴 CRITICAL (Risk: 95/100) - Ransomware Execution Detected
   • Host: SRV-FILE-01.contoso.com
   • User: admin@contoso.com
   • Process: C:\Temp\encrypt.exe
   • Time: 2026-01-29 10:45:12 UTC
   • Recommendation: IMMEDIATE ISOLATION REQUIRED

2. 🔴 CRITICAL (Risk: 92/100) - Lateral Movement via PsExec
   • Source: DESKTOP-SOC-01
   • Target: DC-PROD-01 (Domain Controller)
   • User: IT-Admin
   • Time: 2026-01-29 10:52:33 UTC
   • Recommendation: Investigate privileged account compromise

[... 8 more alerts ...]

Would you like me to:
  A) Create incidents for all critical alerts
  B) Run automated containment playbook for ransomware
  C) Generate executive summary report
```

**Analyst**: *"Option B - run containment playbook and create incidents"*

**AI Action**:
```
✓ Executing Ransomware Containment Playbook...
  1. Isolated host SRV-FILE-01 from network ✓
  2. Disabled user account admin@contoso.com ✓
  3. Created forensic memory dump ✓
  4. Notified security team via Teams ✓

✓ Created Incident #2024 (Critical Severity)
  - Title: Ransomware Execution on File Server
  - Status: Active Investigation
  - Assigned: SOC-Tier2@contoso.com
  - Evidence: 15 related alerts attached

Total time: 45 seconds
```

---

#### **Use Case 2: Threat Hunting with Natural Language**

**Scenario**: Security team suspects insider threat, needs to investigate unusual data access patterns

**Query**: *"Find users who accessed more than 100 files in the last 24 hours that they've never accessed before"*

**MCP Translation to KQL**:
```kql
let TimeRange = ago(24h);
let HistoricalBaseline = ago(30d);
// Get recent file access
let RecentAccess = OfficeActivity
| where TimeGenerated > TimeRange
| where Operation in~ ("FileAccessed", "FileDownloaded")
| extend FileName = tostring(OfficeObjectId)
| summarize FileCount = dcount(FileName), Files = make_set(FileName, 100) by UserId;
// Get historical baseline
let HistoricalAccess = OfficeActivity
| where TimeGenerated between (HistoricalBaseline .. TimeRange)
| where Operation in~ ("FileAccessed", "FileDownloaded")
| extend FileName = tostring(OfficeObjectId)
| summarize HistoricalFiles = make_set(FileName) by UserId;
// Find anomalies
RecentAccess
| join kind=leftouter (HistoricalAccess) on UserId
| extend NewFiles = set_difference(Files, HistoricalFiles)
| extend NewFileCount = array_length(NewFiles)
| where NewFileCount > 100
| project UserId, FileCount, NewFileCount, SampleNewFiles = array_slice(NewFiles, 0, 10)
| order by NewFileCount desc
```

**Results**:
```
⚠️ ANOMALY DETECTED: 3 users with unusual file access patterns

1. john.contractor@contoso.com
   - Total files accessed: 523
   - NEW files (never accessed before): 487
   - Sample files: 
     • /Finance/Q4-2025-Budget.xlsx
     • /HR/Employee-Salaries-2025.xlsx
     • /Legal/Contracts/Confidential/...
   - Risk Score: 88/100
   - Recommendation: URGENT - Potential data exfiltration

2. jane.intern@contoso.com
   - Total files accessed: 245
   - NEW files: 198
   - Sample files: /Marketing/Strategy-2026.pptx, ...
   - Risk Score: 62/100
   
3. bob.admin@contoso.com
   - Total files accessed: 156
   - NEW files: 134
   - Risk Score: 45/100

Would you like me to:
  • Investigate john.contractor's activity further
  • Create high-priority incident for john.contractor
  • Block john.contractor's access immediately
```

---

#### **Use Case 3: Incident Response Automation**

**Scenario**: Phishing email reported by user, need to contain and remediate

**User**: *"A user reported a phishing email. The sender is attacker@evil.com and 15 users clicked the link. Contain this incident."*

**AI Action Plan**:
```
📧 PHISHING INCIDENT RESPONSE INITIATED

Step 1: Intelligence Gathering
  ✓ Queried email logs for sender: attacker@evil.com
  ✓ Found 47 emails sent to organization
  ✓ Identified 15 users who clicked malicious link
  ✓ Checked threat intel: Domain evil.com (Malicious, Phishing, Category: Credential Theft)

Step 2: Containment Actions
  ✓ Blocked sender attacker@evil.com in Exchange Online
  ✓ Deleted all 47 emails from mailboxes
  ✓ Blocked domain evil.com in firewall (Palo Alto Networks)
  ✓ Forced password reset for 15 affected users

Step 3: Forensics & Investigation
  ✓ Checked for credential compromise: 3 users have suspicious sign-ins after click
  ✓ Scanning endpoints for malware: 0 detections
  ✓ Reviewing data exfiltration: 0 unusual file transfers

Step 4: Documentation
  ✓ Created Incident #2025: "Phishing Campaign - attacker@evil.com"
  ✓ Attached evidence: Email logs, click logs, threat intel report
  ✓ Notified users via email about password reset
  ✓ Generated executive summary report

⚠️ FOLLOW-UP REQUIRED:
  - 3 users (john.doe, jane.smith, bob.jones) have suspicious sign-ins
  - Recommend MFA enforcement for these accounts
  - Security awareness training for all affected users

Total Time: 3 minutes (vs. 45 minutes manual)
```

---

### 4.2 Compliance & Audit Use Cases

#### **Use Case 4: Automated Compliance Reporting**

**Query**: *"Generate a PCI-DSS compliance report for all in-scope systems for the last quarter"*

**AI Process**:
```
Generating PCI-DSS Compliance Report (Q4 2025)...

Scope: 127 assets tagged with "PCI-DSS"

✅ Compliant Areas (Score: 82/100):
  1. Network Segmentation (Req 1.2.1) - 95%
     • 120/127 systems in dedicated VLAN
     • 7 systems require network review
  
  2. Vulnerability Management (Req 6.2) - 78%
     • 98/127 systems patched within 30 days
     • 29 systems with overdue critical patches
  
  3. Access Control (Req 7.1) - 88%
     • 115/127 systems use MFA
     • 12 systems require MFA enablement

⚠️ Non-Compliant Areas:
  1. Logging & Monitoring (Req 10.1) - 65% ❌
     • 44/127 systems missing log forwarding to Sentinel
     • Action: Configure agents on 44 systems
  
  2. Encryption (Req 3.4) - 71% ⚠️
     • 37/127 systems using weak TLS 1.0/1.1
     • Action: Upgrade to TLS 1.2+

📊 Detailed Report: pci-dss-q4-2025.pdf (exported)
📧 Sent to: compliance@contoso.com, ciso@contoso.com
```

---

### 4.3 Proactive Threat Detection Use Cases

#### **Use Case 5: Continuous Threat Monitoring**

**Background Task** (MCP Server runs automatically every 15 minutes):

**MCP Agent**: *"Monitor for any anomalous activity and alert if critical threats detected"*

**Detection Example**:
```
🚨 CRITICAL ALERT - Automated Threat Detection

⏰ Time: 2026-01-29 14:37:22 UTC

🔍 Detection: Potential Credential Stuffing Attack

Details:
  • Source IPs: 203.0.113.0/24 (Russia, Known VPN Provider)
  • Target: 1,247 failed login attempts across 234 user accounts
  • Time Window: Last 10 minutes
  • Pattern: Sequential username enumeration detected
  • Success Rate: 3 successful logins (likely compromised)

🛡️ Automated Response Triggered:
  ✓ Blocked source IP range 203.0.113.0/24 in Azure Firewall
  ✓ Forced MFA challenge for 3 successful logins
  ✓ Disabled accounts: test@contoso.com, guest@contoso.com, demo@contoso.com
  ✓ Created Incident #2026 (Critical)
  ✓ Notified SOC team via Teams + Email

👤 Manual Review Required:
  - Investigate 3 compromised accounts for further activity
  - Review if IP block impacts legitimate users
  - Consider enabling Conditional Access policies
```

---

### 4.4 Custom MCP Integration Use Case

#### **Use Case 6: Using Custom Internal Security MCP**

**Scenario**: Security team has developed an internal MCP server that integrates with proprietary threat intelligence feeds and internal CMDB systems. The server provides custom tools for risk scoring and asset contextualization.

**Objective**: Configure and use the custom internal MCP server in VS Code with GitHub Copilot for daily security operations.

**Steps to Enable Custom MCP**:

1. **Add Custom MCP to VS Code Settings** (`.vscode/settings.json`):
```json
{
  "mcp.servers": {
    "internal-security": {
      "command": "python",
      "args": ["C:\\SecurityTools\\mcp-server\\server.py"],
      "env": {
        "API_KEY": "${env:INTERNAL_API_KEY}"
      }
    }
  }
}
```

2. **Restart VS Code** to load the custom MCP server

3. **Use with Copilot Chat**:
```
@internal-security Calculate risk score for server SRV-WEB-01
@internal-security Get asset context from CMDB for host 10.0.1.50
@internal-security Check threat intel for IP 203.0.113.45
```

**Example Interaction**:
```
Analyst: @internal-security Get risk assessment for SRV-DB-PROD-01

Copilot Response:
Risk Assessment for SRV-DB-PROD-01:
- Overall Risk Score: 87/100 (CRITICAL)
- Critical Vulnerabilities: 3
- Internet Facing: Yes
- Business Criticality: High
- Recommendations:
  1. Apply patches for CVE-2024-1234 (CVSS 9.8)
  2. Review firewall rules
  3. Schedule penetration test
```

**Benefits**:
- Access internal systems through natural language
- Combine multiple data sources (CMDB, vulnerability scanners, threat intel)
- Custom risk scoring algorithms specific to organization
- Faster investigation and incident response
- Consistent security assessments across team

---

### 4.5 Custom Agents Configuration for Azure Sentinel

#### **Use Case 7: Create Custom Agent for Azure Sentinel Operations**

**Note**: Custom Agents (`.agent.md` files) are a VS Code feature, separate from MCP. They define specialized AI agent behaviors and instructions.

**Scenario**: Security team needs a specialized AI agent for Azure Sentinel threat hunting, incident investigation, and KQL query assistance.

**Objective**: Create a custom `.agent.md` file that provides Sentinel-specific expertise within VS Code.

---

#### **Creating a Custom Sentinel Agent**

**Step 1: Create Agent File**

Location: `.vscode/agents/SentinelExpert.agent.md`

**File: `SentinelExpert.agent.md`**:

```markdown
---
name: SentinelExpert
description: Azure Sentinel security expert for threat hunting, KQL queries, and incident investigation
tags: [azure, sentinel, security, kql, siem]
---

# Azure Sentinel Expert Agent

You are an expert Azure Sentinel security analyst specializing in:
- Threat hunting and detection
- KQL query optimization
- Incident investigation and response
- Analytics rule development
- Workbook creation

## Core Capabilities

### 1. KQL Query Assistance
- Write optimized KQL queries for Azure Sentinel
- Explain query performance and best practices
- Convert natural language to KQL
- Debug and fix KQL syntax errors

### 2. Threat Hunting
- Guide threat hunting workflows
- Suggest hunting hypotheses based on MITRE ATT&CK
- Identify suspicious patterns in logs
- Recommend data sources for investigations

### 3. Incident Investigation
- Provide investigation playbooks
- Suggest next investigation steps
- Correlate entities across multiple incidents
- Recommend response actions

### 4. Analytics Rules
- Create detection rules from IOCs
- Optimize rule performance
- Reduce false positives
- Map detections to MITRE ATT&CK

## Sentinel-Specific Knowledge

### Available Data Sources
- AzureActivity
- SigninLogs, AADNonInteractiveUserSignInLogs
- SecurityAlert, SecurityIncident
- AuditLogs, AADServicePrincipalSignInLogs
- OfficeActivity (M365 Copilot, Security Copilot)
- Syslog, CommonSecurityLog
- ThreatIntelligenceIndicator

### Common KQL Patterns
Always use:
- `where` instead of filtering in `summarize`
- `project` early to reduce data volume
- `summarize` for aggregations
- `join` with `kind=inner` for correlations
- Time filters first in queries

### Best Practices
1. Always specify time range (e.g., `ago(24h)`)
2. Use `project` to limit columns early
3. Filter before aggregation
4. Use `has_any` for multiple string matches
5. Avoid `contains` when `has` works

## Response Format

When providing KQL queries:
```kql
// Query purpose and explanation
TableName
| where TimeGenerated >= ago(24h)
| where Field has "value"
| summarize Count=count() by Field
| order by Count desc
```

When investigating incidents:
1. **Initial Assessment**: Summary of the incident
2. **Key Entities**: Users, IPs, hosts involved
3. **Timeline**: Chronological event sequence
4. **Hunting Queries**: KQL to find related activity
5. **Recommendations**: Immediate actions and mitigation

## Example Interactions

### Query Request
User: "Find failed Copilot logins in last hour"

Response:
```kql
AADServicePrincipalSignInLogs
| where TimeGenerated >= ago(1h)
| where ResourceDisplayName has_any ("Copilot", "copilot")
| where ResultType != "0"  // Failed attempts
| project TimeGenerated, ServicePrincipalName, ResourceDisplayName, 
          IPAddress, ResultDescription
| order by TimeGenerated desc
```

### Threat Hunt
User: "Hunt for suspicious Copilot API usage"

Response:
1. Look for unusual access patterns (off-hours, unusual locations)
2. Check for excessive API calls from single user
3. Identify failed authentication attempts
4. Cross-reference with threat intelligence

[Provide 3-5 hunting queries]

### Incident Investigation
User: "Investigate incident INC-12345 with suspicious Copilot activity"

Response:
**Initial Assessment**: Anomalous Copilot API calls from compromised account

**Key Entities**:
- User: john.doe@contoso.com
- Source IP: 203.0.113.45
- Time: 2026-01-30 02:15-02:45 (off-hours)

**Timeline**:
1. 02:15 - Initial failed login attempts
2. 02:20 - Successful login from suspicious IP
3. 02:25 - Unusual Copilot queries (data exfiltration patterns)
4. 02:45 - Account disabled by SOC

[Provide investigation queries and next steps]
```

---

**Step 2: Enable Agent in VS Code**

1. Restart VS Code to load the agent
2. Access via Copilot Chat: `@SentinelExpert`
3. Agent automatically applies Sentinel-specific expertise

---

**Step 3: Use Custom Agent**

**Example Usage in Copilot Chat**:

```
# KQL Query Request
User: @SentinelExpert Write a query to find Microsoft 365 Copilot usage by department

SentinelExpert Response:
Here's an optimized KQL query for Copilot usage by department:

```kql
// Microsoft 365 Copilot Usage by Department
OfficeActivity
| where TimeGenerated >= ago(7d)
| where Operation has_any ("CopilotInteraction", "CopilotQuery")
| join kind=inner (
    SigninLogs
    | where TimeGenerated >= ago(7d)
    | project UserId, Department=tostring(DeviceDetail.department)
) on UserId
| summarize 
    TotalInteractions=count(),
    UniqueUsers=dcount(UserId),
    AvgPerUser=count() / dcount(UserId)
    by Department
| order by TotalInteractions desc
```

**Analysis**:
- Joins OfficeActivity with SigninLogs to get department info
- Last 7 days of Copilot interactions
- Shows usage patterns by department
- Identifies high-adoption teams

**Performance**: ~2-3 seconds for typical environment
```

```
# Threat Hunting
User: @SentinelExpert Help me hunt for credential stuffing attacks targeting Copilot

SentinelExpert Response:
**Credential Stuffing Hunt - Copilot Services**

**Hypothesis**: Attackers using stolen credentials to access Copilot services

**Hunting Queries**:

1. **Multiple Failed Logins from Same IP**:
```kql
SigninLogs
| where TimeGenerated >= ago(24h)
| where AppDisplayName has "Copilot"
| where ResultType != "0"
| summarize FailedAttempts=count(), UniqueAccounts=dcount(UserPrincipalName) 
    by IPAddress, Location
| where FailedAttempts > 10 and UniqueAccounts > 5
| order by FailedAttempts desc
```

2. **Failed then Successful Logins**:
```kql
SigninLogs
| where TimeGenerated >= ago(1h)
| where AppDisplayName has "Copilot"
| summarize FailedCount=countif(ResultType != "0"),
            SuccessCount=countif(ResultType == "0"),
            StartTime=min(TimeGenerated),
            EndTime=max(TimeGenerated)
    by UserPrincipalName, IPAddress
| where FailedCount > 3 and SuccessCount > 0
| project UserPrincipalName, IPAddress, FailedCount, SuccessCount, 
          TimeToSuccess=datetime_diff('minute', EndTime, StartTime)
```

3. **Cross-Reference with TI**:
```kql
let SuspiciousIPs = SigninLogs
    | where TimeGenerated >= ago(24h)
    | where AppDisplayName has "Copilot" and ResultType != "0"
    | summarize by IPAddress;
ThreatIntelligenceIndicator
| where TimeGenerated >= ago(7d)
| where NetworkIP in (SuspiciousIPs)
| project ThreatType, Confidence, Description, NetworkIP
```

**Indicators of Compromise**:
- Multiple accounts targeted from same IP
- Geographic anomalies (VPN/TOR usage)
- Failed attempts followed by success
- Known malicious IPs in TI feeds

**Recommended Actions**:
1. Block identified malicious IPs at firewall
2. Force password reset for targeted accounts
3. Enable MFA for all Copilot access
4. Create analytics rule for automated detection
```

```
# Create Analytics Rule
User: @SentinelExpert Create a detection rule for excessive Copilot API calls

SentinelExpert Response:
**Analytics Rule: Excessive Copilot API Usage**

```kql
// Rule Query
let threshold = 1000;  // API calls per hour
OfficeActivity
| where TimeGenerated >= ago(1h)
| where Operation has_any ("CopilotInteraction", "CopilotQuery")
| summarize APICallCount=count() by UserId, UserPrincipalName, 
            bin(TimeGenerated, 1h)
| where APICallCount > threshold
| extend Severity = case(
    APICallCount > 5000, "High",
    APICallCount > 2000, "Medium",
    "Low"
)
| project TimeGenerated, UserPrincipalName, APICallCount, Severity
```

**Rule Configuration**:
- **Name**: Excessive Copilot API Usage
- **Severity**: Medium
- **Tactics**: Exfiltration, Collection
- **Frequency**: Run every 1 hour
- **Query Period**: Look back 1 hour
- **Threshold**: Alert when >= 1 result

**Entity Mapping**:
- Account: UserPrincipalName
- Timestamp: TimeGenerated

**Alert Details**:
```
Alert: User {{UserPrincipalName}} generated {{APICallCount}} Copilot API calls in 1 hour
Severity: {{Severity}}
Recommendation: Investigate for data exfiltration or account compromise
```

**False Positive Reduction**:
- Exclude service accounts: `| where UserPrincipalName !contains "svc-"`
- Exclude power users: `| where UserId !in (PowerUsersList)`
- Adjust threshold based on baseline
```

---

#### **Additional Custom Agent Examples**

**1. Incident Response Agent** (`.vscode/agents/IncidentResponder.agent.md`):
- Focus: Incident triage, containment, and remediation
- Specialties: Playbook execution, timeline analysis, forensics

**2. Compliance Agent** (`.vscode/agents/ComplianceAuditor.agent.md`):
- Focus: Compliance monitoring, audit queries, reporting
- Specialties: SOC2, PCI-DSS, HIPAA, GDPR compliance checks

**3. KQL Tuning Agent** (`.vscode/agents/KQLOptimizer.agent.md`):
- Focus: Query performance, cost optimization
- Specialties: Query analysis, index recommendations, cost reduction

---

#### **Benefits of Custom Agents**

✅ **Specialized Expertise**: Domain-specific knowledge (Sentinel, KQL, security)  
✅ **Consistent Guidance**: Standardized best practices across team  
✅ **Faster Workflows**: Pre-configured responses for common tasks  
✅ **Training Tool**: Helps junior analysts learn Sentinel and KQL  
✅ **No External Dependencies**: Works entirely within VS Code (unlike MCP servers)  
✅ **Easy Customization**: Simple markdown files, version-controlled  

---

#### **Custom Agent vs MCP: Key Differences**

| Feature | Custom Agent (.agent.md) | MCP Server |
|---------|--------------------------|------------|
| **Purpose** | Define AI behavior/instructions | Connect to external tools/APIs |
| **Location** | `.vscode/agents/` in workspace | Separate server process |
| **Language** | Markdown with instructions | Python/TypeScript code |
| **Capabilities** | Specialized responses, guidance | Execute actions, query systems |
| **Dependencies** | None (VS Code only) | External APIs, credentials |
| **Use Case** | Expert consultant, teaching | Tool execution, data retrieval |

**When to Use Custom Agents**: Need specialized knowledge, guidance, or consistent responses  
**When to Use MCP**: Need to execute actions or query external systems (Azure Sentinel API, CMDB, etc.)

---

## 5. How It Works (Architecture)

### 5.1 VS Code Implementation for Azure Sentinel

#### **Step 1: Install Prerequisites**

**Required Extensions**:
1. **GitHub Copilot** (ms-vscode.copilot)
2. **Azure Account** (ms-vscode.azure-account)
3. **Azure Resources** (ms-azuretools.vscode-azureresourcegroups)

**Installation Commands**:
```bash
# Install VS Code extensions
code --install-extension ms-vscode.copilot
code --install-extension ms-vscode.azure-account
code --install-extension ms-azuretools.vscode-azureresourcegroups
```

#### **Step 2: Create MCP Server Project**

**Project Structure**:
```
mcp-sentinel-server/
├── .vscode/
│   ├── settings.json
│   └── launch.json
├── src/
│   ├── server.py
│   ├── tools/
│   │   ├── alerts.py
│   │   ├── incidents.py
│   │   └── queries.py
│   └── config/
│       └── azure_config.py
├── requirements.txt
├── .env.example
└── README.md
```

**Create Project**:
```bash
# Create project directory
mkdir mcp-sentinel-server
cd mcp-sentinel-server

# Create virtual environment
python -m venv venv
venv\Scripts\activate  # Windows

# Create requirements.txt
cat > requirements.txt << EOF
fastmcp==0.2.0
azure-identity==1.15.0
azure-monitor-query==1.3.0
azure-mgmt-securityinsight==1.0.0
python-dotenv==1.0.0
EOF

# Install dependencies
pip install -r requirements.txt
```

#### **Step 3: Configure VS Code Settings**

**File: `.vscode/settings.json`**:
```json
{
  "python.defaultInterpreterPath": "${workspaceFolder}/venv/Scripts/python.exe",
  "python.terminal.activateEnvironment": true,
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": true,
  "python.formatting.provider": "black",
  "mcp.servers": {
    "sentinel": {
      "command": "${workspaceFolder}/venv/Scripts/python.exe",
      "args": ["-m", "src.server"],
      "env": {
        "WORKSPACE_ID": "${env:WORKSPACE_ID}",
        "TENANT_ID": "${env:TENANT_ID}",
        "AZURE_CLIENT_ID": "${env:AZURE_CLIENT_ID}",
        "AZURE_CLIENT_SECRET": "${env:AZURE_CLIENT_SECRET}",
        "LOG_LEVEL": "INFO"
      },
      "disabled": false
    }
  },
  "github.copilot.enable": {
    "*": true,
    "yaml": true,
    "plaintext": true,
    "markdown": true,
    "python": true
  }
}
```

**File: `.vscode/launch.json`**:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Run MCP Server",
      "type": "python",
      "request": "launch",
      "module": "src.server",
      "console": "integratedTerminal",
      "envFile": "${workspaceFolder}/.env",
      "justMyCode": false
    },
    {
      "name": "Debug MCP Server",
      "type": "python",
      "request": "launch",
      "module": "src.server",
      "console": "integratedTerminal",
      "envFile": "${workspaceFolder}/.env",
      "justMyCode": true,
      "logToFile": true
    }
  ]
}
```

#### **Step 4: Create Environment Configuration**

**File: `.env.example`**:
```env
# Azure Configuration
WORKSPACE_ID=12345678-1234-1234-1234-123456789012
TENANT_ID=87654321-4321-4321-4321-210987654321
SUBSCRIPTION_ID=11111111-2222-3333-4444-555555555555
RESOURCE_GROUP=rg-sentinel-prod

# Authentication (use one method)
# Method 1: Service Principal
AZURE_CLIENT_ID=your-app-client-id
AZURE_CLIENT_SECRET=your-app-client-secret

# Method 2: Azure CLI (automatically uses cached credentials)
# No additional config needed

# Logging
LOG_LEVEL=INFO
```

**Copy to `.env`**:
```bash
cp .env.example .env
# Edit .env with your actual values
```

#### **Step 5: Implement MCP Server**

**File: `src/server.py`**:
```python
"""
Microsoft Sentinel MCP Server for VS Code
Enables AI-assisted security operations via GitHub Copilot
"""

import os
from fastmcp import FastMCP
from azure.identity import DefaultAzureCredential, ClientSecretCredential
from azure.monitor.query import LogsQueryClient
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"))
logger = logging.getLogger(__name__)

# Initialize MCP server
mcp = FastMCP("Microsoft Sentinel MCP Server", version="1.0.0")

# Azure configuration
WORKSPACE_ID = os.getenv("WORKSPACE_ID")
TENANT_ID = os.getenv("TENANT_ID")
CLIENT_ID = os.getenv("AZURE_CLIENT_ID")
CLIENT_SECRET = os.getenv("AZURE_CLIENT_SECRET")

# Initialize Azure credential
if CLIENT_ID and CLIENT_SECRET:
    credential = ClientSecretCredential(
        tenant_id=TENANT_ID,
        client_id=CLIENT_ID,
        client_secret=CLIENT_SECRET
    )
    logger.info("Using Service Principal authentication")
else:
    credential = DefaultAzureCredential()
    logger.info("Using Azure CLI/Managed Identity authentication")

# Initialize Azure clients
logs_client = LogsQueryClient(credential)

@mcp.tool()
async def query_sentinel_alerts(
    severity: str = "High",
    time_range: str = "24h",
    limit: int = 100
) -> dict:
    """
    Query Microsoft Sentinel for security alerts.
    
    Args:
        severity: Alert severity (Critical, High, Medium, Low)
        time_range: Time range (1h, 24h, 7d, 30d)
        limit: Maximum number of alerts to return (default: 100)
    
    Returns:
        Dictionary containing alert data
    """
    logger.info(f"Querying alerts: severity={severity}, time_range={time_range}")
    
    query = f"""
    SecurityAlert
    | where Severity == "{severity}"
    | where TimeGenerated > ago({time_range})
    | project 
        TimeGenerated,
        AlertName,
        AlertSeverity,
        Description,
        CompromisedEntity,
        Tactics,
        Status
    | order by TimeGenerated desc
    | take {limit}
    """
    
    try:
        response = logs_client.query_workspace(
            workspace_id=WORKSPACE_ID,
            query=query,
            timespan=None
        )
        
        alerts = []
        for table in response.tables:
            for row in table.rows:
                alerts.append({
                    "time": str(row[0]),
                    "name": row[1],
                    "severity": row[2],
                    "description": row[3],
                    "entity": row[4],
                    "tactics": row[5],
                    "status": row[6]
                })
        
        return {
            "success": True,
            "count": len(alerts),
            "alerts": alerts,
            "summary": f"Found {len(alerts)} {severity} severity alerts"
        }
    
    except Exception as e:
        logger.error(f"Error querying alerts: {str(e)}")
        return {
            "success": False,
            "error": str(e),
            "count": 0,
            "alerts": []
        }

@mcp.tool()
async def execute_kql_query(query: str, time_range: str = "24h") -> dict:
    """
    Execute a custom KQL query against Log Analytics workspace.
    
    Args:
        query: KQL query string
        time_range: Time context for the query
    
    Returns:
        Query results as structured data
    """
    logger.info(f"Executing KQL query: {query[:100]}...")
    
    # Security validation
    blocked_keywords = ["delete", "drop", "purge", ".create", ".alter"]
    query_lower = query.lower()
    
    for keyword in blocked_keywords:
        if keyword in query_lower:
            return {
                "success": False,
                "error": f"Query contains blocked keyword: {keyword}",
                "data": []
            }
    
    try:
        response = logs_client.query_workspace(
            workspace_id=WORKSPACE_ID,
            query=query,
            timespan=None
        )
        
        results = []
        for table in response.tables:
            columns = [col.name for col in table.columns]
            for row in table.rows:
                results.append(dict(zip(columns, row)))
        
        return {
            "success": True,
            "row_count": len(results),
            "columns": columns if results else [],
            "data": results[:1000]  # Limit to 1000 rows
        }
    
    except Exception as e:
        logger.error(f"Error executing query: {str(e)}")
        return {
            "success": False,
            "error": str(e),
            "data": []
        }

@mcp.tool()
async def get_security_metrics() -> dict:
    """
    Get current security metrics and dashboard data.
    
    Returns:
        Dictionary with key security metrics
    """
    logger.info("Retrieving security metrics")
    
    queries = {
        "critical_alerts": """
            SecurityAlert
            | where Severity == "Critical"
            | where TimeGenerated > ago(24h)
            | count
        """,
        "high_alerts": """
            SecurityAlert
            | where Severity == "High"
            | where TimeGenerated > ago(24h)
            | count
        """,
        "open_incidents": """
            SecurityIncident
            | where Status == "New"
            | count
        """,
        "failed_logins": """
            SigninLogs
            | where TimeGenerated > ago(24h)
            | where ResultType != "0"
            | count
        """
    }
    
    metrics = {}
    
    for metric_name, query in queries.items():
        try:
            response = logs_client.query_workspace(
                workspace_id=WORKSPACE_ID,
                query=query,
                timespan=None
            )
            
            count = response.tables[0].rows[0][0] if response.tables[0].rows else 0
            metrics[metric_name] = count
        
        except Exception as e:
            logger.error(f"Error getting {metric_name}: {str(e)}")
            metrics[metric_name] = -1
    
    return {
        "success": True,
        "timestamp": datetime.utcnow().isoformat(),
        "metrics": metrics
    }

@mcp.resource("sentinel://alerts/recent")
async def get_recent_alerts() -> str:
    """
    Resource providing feed of recent critical and high severity alerts.
    """
    result = await query_sentinel_alerts(severity="High", time_range="1h", limit=10)
    
    if result["success"]:
        return f"""Recent High Severity Alerts (Last Hour):
        
Total: {result['count']} alerts

{chr(10).join([f"- {alert['name']} ({alert['entity']})" for alert in result['alerts'][:10]])}
"""
    else:
        return f"Error retrieving alerts: {result.get('error', 'Unknown error')}"

# Run the server
if __name__ == "__main__":
    logger.info("Starting Microsoft Sentinel MCP Server...")
    logger.info(f"Workspace ID: {WORKSPACE_ID}")
    mcp.run()
```

**File: `src/tools/alerts.py`** (Extended functionality):
```python
"""Alert management tools"""

from azure.mgmt.securityinsight import SecurityInsights
from azure.identity import DefaultAzureCredential
import os

credential = DefaultAzureCredential()
subscription_id = os.getenv("SUBSCRIPTION_ID")
resource_group = os.getenv("RESOURCE_GROUP")

sentinel_client = SecurityInsights(credential, subscription_id)

def create_incident(title: str, severity: str, description: str) -> dict:
    """
    Create a new incident in Microsoft Sentinel.
    """
    workspace_name = "sentinel-workspace"
    incident_id = f"incident-{int(time.time())}"
    
    incident = sentinel_client.incidents.create_or_update(
        resource_group_name=resource_group,
        workspace_name=workspace_name,
        incident_id=incident_id,
        incident={
            "properties": {
                "title": title,
                "severity": severity,
                "status": "New",
                "description": description
            }
        }
    )
    
    return {
        "incident_id": incident.name,
        "title": incident.properties.title,
        "status": incident.properties.status
    }
```

#### **Step 6: Test in VS Code**

**Using GitHub Copilot Chat**:

1. Open VS Code Command Palette (`Ctrl+Shift+P` or `Cmd+Shift+P`)
2. Type: `GitHub Copilot: Open Chat`
3. Enable MCP server in Copilot settings

**Test Queries**:

```
# In Copilot Chat window, type:

@sentinel Show me all critical alerts from the last hour

@sentinel Execute KQL query: SecurityAlert | where Severity == "High" | take 10

@sentinel Get current security metrics

@sentinel Find failed login attempts from external IPs in the last 24 hours
```

#### **Step 7: Debug and Monitor**

**View Logs in VS Code Terminal**:
```bash
# Run server with verbose logging
$env:LOG_LEVEL="DEBUG"
python -m src.server
```

**Debug Breakpoints**:
1. Set breakpoints in `server.py`
2. Press `F5` to start debugging
3. Trigger queries from Copilot Chat
4. Step through code execution

**Monitor Performance**:
```python
# Add to server.py
import time

@mcp.tool()
async def query_sentinel_alerts(severity: str = "High", ...):
    start_time = time.time()
    # ... existing code ...
    elapsed = time.time() - start_time
    logger.info(f"Query completed in {elapsed:.2f}s")
```

#### **Step 8: VS Code Tasks for Automation**

**File: `.vscode/tasks.json`**:
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Start MCP Server",
      "type": "shell",
      "command": "${workspaceFolder}/venv/Scripts/python.exe",
      "args": ["-m", "src.server"],
      "problemMatcher": [],
      "group": {
        "kind": "build",
        "isDefault": true
      },
      "presentation": {
        "reveal": "always",
        "panel": "new"
      }
    },
    {
      "label": "Run Tests",
      "type": "shell",
      "command": "${workspaceFolder}/venv/Scripts/python.exe",
      "args": ["-m", "pytest", "tests/"],
      "problemMatcher": [],
      "group": "test"
    },
    {
      "label": "Install Dependencies",
      "type": "shell",
      "command": "${workspaceFolder}/venv/Scripts/pip.exe",
      "args": ["install", "-r", "requirements.txt"],
      "problemMatcher": []
    }
  ]
}
```

**Usage**:
- Press `Ctrl+Shift+B` to start MCP server
- Or: `Terminal > Run Task > Start MCP Server`

#### **Step 9: GitHub Copilot Integration**

**Enable MCP in Copilot Settings**:

**File: `settings.json` (User or Workspace)**:
```json
{
  "github.copilot.advanced": {
    "mcp.enabled": true,
    "mcp.servers": {
      "sentinel": {
        "enabled": true,
        "autoStart": false
      }
    }
  }
}
```

**Keyboard Shortcuts** (`.vscode/keybindings.json`):
```json
[
  {
    "key": "ctrl+shift+s",
    "command": "github.copilot.chat.open",
    "args": "@sentinel "
  }
]
```

#### **Step 10: Example Interactions in VS Code**

**Scenario 1: Alert Investigation**

**User in Copilot Chat**:
```
@sentinel Show me all critical alerts from the last 2 hours
```

**Copilot Response**:
```
Querying Microsoft Sentinel...

Found 5 critical alerts in the last 2 hours:

1. Ransomware Execution Detected
   - Entity: SRV-FILE-01.contoso.com
   - Time: 2026-01-29 14:23:11 UTC
   - Tactics: Execution, Impact

2. Suspicious PowerShell Encoded Command
   - Entity: DESKTOP-ABC123
   - Time: 2026-01-29 14:45:33 UTC
   - Tactics: Execution, Defense Evasion

[... 3 more alerts ...]

Would you like me to create incidents for these alerts?
```

**Scenario 2: Custom KQL Query**

**User**:
```
@sentinel Find all users with more than 10 failed login attempts in the last hour
```

**Copilot** (translates to KQL):
```
Executing query:

SigninLogs
| where TimeGenerated > ago(1h)
| where ResultType != "0"
| summarize FailedAttempts = count() by UserPrincipalName
| where FailedAttempts > 10
| order by FailedAttempts desc

Results:
╔═══════════════════════════════╦═════════════════╗
║ UserPrincipalName             ║ Failed Attempts ║
╠═══════════════════════════════╬═════════════════╣
║ admin@contoso.com             ║ 47              ║
║ john.doe@contoso.com          ║ 23              ║
║ service@contoso.com           ║ 15              ║
╚═══════════════════════════════╩═════════════════╝

⚠️ High number of failed attempts detected for admin@contoso.com
Recommendation: Investigate for potential brute force attack
```

**Scenario 3: Security Metrics Dashboard**

**User**:
```
@sentinel Get current security metrics
```

**Copilot**:
```
Security Metrics (Last 24 Hours):

🔴 Critical Alerts: 12
🟠 High Alerts: 47
📋 Open Incidents: 23
🔐 Failed Logins: 1,834

Last Updated: 2026-01-29 15:30:00 UTC
```

### 5.2 Detailed Component Architecture

```mermaid
graph TB
    subgraph "User Layer"
        A[Security Analyst]
        B[AI Assistant<br/>GitHub Copilot/Claude]
    end
    
    subgraph "MCP Layer"
        C[MCP Client SDK]
        D[MCP Server<br/>Azure Function]
        E[Authentication Service<br/>Azure AD]
    end
    
    subgraph "Security Platform Layer"
        F[Microsoft Sentinel<br/>SIEM]
        G[Azure Logic Apps<br/>SOAR]
        H[Threat Intelligence<br/>Microsoft Defender TI]
        I[Log Analytics<br/>Workspace]
    end
    
    subgraph "Data Layer"
        J[Security Logs<br/>Syslog, CEF, JSON]
        K[Alerts & Incidents]
        L[Threat Intel Feeds]
    end
    
    A -->|Natural Language| B
    B -->|MCP Protocol| C
    C -->|JSON-RPC| D
    D -->|OAuth 2.0| E
    D -->|Query/Execute| F
    D -->|Trigger Playbooks| G
    D -->|Enrich Context| H
    D -->|KQL Queries| I
    
    F --> K
    G --> K
    I --> J
    H --> L
    
    style D fill:#0078D4,color:#fff
    style F fill:#FFB900,color:#000
    style G fill:#50E6FF,color:#000
```

---

### 5.2 Detailed Component Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          MCP SIEM/SOAR ARCHITECTURE                         │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  LAYER 1: USER INTERACTION                                                  │
│                                                                             │
│  ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐       │
│  │  GitHub Copilot  │    │  Claude Desktop  │    │  Custom AI App   │       │
│  │  (VS Code)       │    │  (MCP Native)    │    │  (OpenAI GPT)    │       │
│  └────────┬─────────┘    └────────┬─────────┘    └────────┬─────────┘       │
│           │                        │                        │               │
└───────────┼────────────────────────┼────────────────────────┼───────────────┘
            │                        │                        │
            └────────────────────────┴────────────────────────┘
                                     │
┌────────────────────────────────────▼─────────────────────────────────────────┐
│  LAYER 2: MCP PROTOCOL LAYER                                                 │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │  MCP Client SDK                                                        │  │
│  │  • Protocol: JSON-RPC 2.0                                              │  │
│  │  • Transport: SSE (Server-Sent Events) or WebSocket                    │  │
│  │  • Message Types: Request, Response, Notification                      │  │
│  │  • Capability Discovery: Automatic tool/resource enumeration           │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────┬───────────────────────────────────────┘
                                       │ JSON-RPC Messages
┌──────────────────────────────────────▼───────────────────────────────────────┐
│  LAYER 3: MCP SERVER (Azure Function App)                                    │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │  Request Handler & Router                                              │  │
│  │  • Parse incoming JSON-RPC requests                                    │  │
│  │  • Route to appropriate handler (alerts, incidents, queries, etc.)     │  │
│  │  • Validate parameters and permissions                                 │  │
│  └────────────────────────┬───────────────────────────────────────────────┘  │
│                            │                                                 │
│  ┌────────────────────────▼───────────────────────────────────────────────┐  │
│  │  Authentication & Authorization Module                                 │  │
│  │  • Azure AD token validation                                           │  │
│  │  • RBAC enforcement (Reader, Responder, Contributor)                   │  │
│  │  • Audit logging (who, what, when)                                     │  │
│  └────────────────────────┬───────────────────────────────────────────────┘  │
│                            │                                                 │
│  ┌────────────────────────▼───────────────────────────────────────────────┐  │
│  │  Business Logic Layer                                                  │  │
│  │                                                                        │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                  │  │
│  │  │ Alert        │  │ Incident     │  │ KQL Query    │                  │  │  
│  │  │ Manager      │  │ Manager      │  │ Executor     │                  │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘                  │  │
│  │                                                                        │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                  │  │
│  │  │ Playbook     │  │ Threat       │  │ Response     │                  │  │
│  │  │ Executor     │  │ Intel        │  │ Formatter    │                  │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘                  │  │
│  └────────────────────────┬───────────────────────────────────────────────┘  │
└───────────────────────────┼──────────────────────────────────────────────────┘
                            │ Azure SDK Calls
┌───────────────────────────▼──────────────────────────────────────────────────┐
│  LAYER 4: AZURE SECURITY SERVICES                                            │
│                                                                              │
│  ┌──────────────────────────┐  ┌──────────────────────────┐                  │
│  │  Microsoft Sentinel API  │  │  Log Analytics API       │                  │
│  │  • Incidents             │  │  • KQL Query Execution   │                  │
│  │  • Alerts                │  │  • Log Ingestion         │                  │
│  │  • Entities               │  │  • Saved Searches        │                 │
│  └──────────────────────────┘  └──────────────────────────┘                  │
│                                                                              │
│  ┌──────────────────────────┐  ┌──────────────────────────┐                  │
│  │  Azure Logic Apps        │  │  Microsoft Defender TI   │                  │
│  │  • Playbook Execution    │  │  • IOC Enrichment        │                  │
│  │  • Webhook Triggers      │  │  • Reputation Scores     │                  │
│  │  • Action Automation     │  │  • OSINT Data            │                  │
│  └──────────────────────────┘  └──────────────────────────┘                  │
└───────────────────────────┬──────────────────────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────────────────────┐
│  LAYER 5: DATA STORAGE                                                       │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │  Log Analytics Workspace (Kusto)                                       │  │
│  │  • SecurityAlert, SecurityIncident                                     │  │
│  │  • SigninLogs, AuditLogs                                               │  │
│  │  • Syslog, CommonSecurityLog                                           │  │
│  │  • Custom Tables (ThreatIntelligence_CL, etc.)                         │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

### 5.3 Security Considerations

**Authentication Flow**:
```
┌─────────────┐
│ AI Client   │
└──────┬──────┘
       │ 1. User initiates request
       ▼
┌─────────────────────┐
│ MCP Client SDK      │
│ - Retrieve token    │
└──────┬──────────────┘
       │ 2. Token from cache or Azure AD
       ▼
┌─────────────────────┐
│ Azure AD            │
│ - Validate identity │
│ - Issue JWT token   │
└──────┬──────────────┘
       │ 3. Bearer token
       ▼
┌─────────────────────┐
│ MCP Server          │
│ - Validate token    │
│ - Check RBAC        │
│ - Audit log         │
└──────┬──────────────┘
       │ 4. Execute operation (if authorized)
       ▼
┌─────────────────────┐
│ Microsoft Sentinel  │
└─────────────────────┘
```

**Security Controls**:
1. **Authentication**: OAuth 2.0 with Azure AD
2. **Authorization**: RBAC at resource and operation level
3. **Encryption**: TLS 1.2+ for all communications
4. **Audit Logging**: All operations logged to Log Analytics
5. **Rate Limiting**: 100 requests/minute per user
6. **Input Validation**: Sanitize all queries and parameters
7. **Least Privilege**: Service principal with minimal required permissions

---

## 6. Proposal for POC

### 6.1 POC Objectives

**Primary Goals**:
1. Demonstrate AI-assisted security operations using MCP
2. Validate technical feasibility and integration complexity
3. Measure efficiency gains vs. traditional manual processes
4. Identify limitations and improvement opportunities

**Success Criteria**:
- [ ] Successfully query Sentinel alerts via natural language (90% accuracy)
- [ ] Create and manage incidents through AI assistant
- [ ] Execute at least 3 threat hunting scenarios with MCP
- [ ] Automate 1 SOAR playbook execution via MCP
- [ ] Achieve 50%+ time reduction in common SOC tasks
- [ ] Zero security incidents related to MCP implementation

### 6.2 POC Scope

#### **In Scope**
✅ Alert querying and filtering  
✅ Incident creation and management  
✅ KQL query execution (read-only)  
✅ Threat intelligence enrichment  
✅ Basic playbook execution (isolate host, block IP)  
✅ Dashboard data retrieval  

#### **Out of Scope**
❌ Direct log ingestion or modification  
❌ User/identity management operations  
❌ Firewall rule changes (except via approved playbooks)  
❌ Production deployment  
❌ Advanced ML/AI model training  

### 6.3 POC Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    POC ARCHITECTURE - MCP FOR SIEM/SOAR                     │
└─────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────┐
│  USER LAYER (SOC Analysts)                                                 │
│                                                                            │
│  ┌──────────────────┐                      ┌──────────────────┐            │
│  │  Analyst Laptop  │                      │  VS Code (Remote)│            │
│  │  • GitHub Copilot│                      │  • GitHub Copilot│            │
│  │  • MCP Config    │                      │  • MCP Extension │            │
│  └────────┬─────────┘                      └────────┬─────────┘            │
│           │                                          │                     │
└───────────┼──────────────────────────────────────────┼─────────────────────┘
            │                                          │
            │          ┌───────────────────────────┐  │
            └──────────┤  Corporate VPN / ExpressRoute├─┘
                       └───────────┬───────────────┘
                                   │
┌──────────────────────────────────▼──────────────────────────────────────────┐
│  AZURE POC ENVIRONMENT (Dev/Test Subscription)                              │
│                                                                             │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  RESOURCE GROUP: rg-mcp-poc                                            │ │
│  │                                                                        │ │
│  │  ┌──────────────────────────────────────────────────────────────┐      │ │
│  │  │  MCP Server (Azure Function App)                             │      │ │
│  │  │  • Runtime: Python 3.11                                      │      │ │
│  │  │  • Plan: Consumption (pay-per-execution)                     │      │ │
│  │  │  • Authentication: Managed Identity                          │      │ │
│  │  │  • Network: Integrated with VNET                             │      │ │
│  │  └────────────────────┬─────────────────────────────────────────┘      │ │
│  │                       │                                                │ │
│  │  ┌────────────────────▼─────────────────────────────────────────┐      │ │
│  │  │  Azure Key Vault (kv-mcp-poc)                                │      │ │
│  │  │  • Client secrets                                            │      │ │
│  │  │  • API keys                                                  │      │ │
│  │  │  • Playbook webhook URLs                                     │      │ │
│  │  └──────────────────────────────────────────────────────────────┘      │ │
│  │                                                                        │ │
│  │  ┌──────────────────────────────────────────────────────────────┐      │ │
│  │  │  Application Insights (ai-mcp-poc)                           │      │ │
│  │  │  • Performance monitoring                                    │      │ │
│  │  │  • Error tracking                                            │      │ │
│  │  │  • Usage analytics                                           │      │ │
│  │  └──────────────────────────────────────────────────────────────┘      │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                       │                                     │
│                                       │                                     │
│  ┌────────────────────────────────────▼──────────────────────────────────┐  │
│  │  RESOURCE GROUP: rg-sentinel-poc                                      │  │
│  │                                                                       │  │
│  │  ┌──────────────────────────────────────────────────────────────┐     │  │
│  │  │  Log Analytics Workspace (law-sentinel-poc)                  │      │ │
│  │  │  • Retention: 30 days                                        │      │  │
│  │  │  • Daily Cap: 1 GB (cost control)                            │      │  │
│  │  │  • Sample Data: 10,000 security events                       │      │  │
│  │  └──────────────────────────────────────────────────────────────┘      │  │
│  │                                                                        │  │
│  │  ┌──────────────────────────────────────────────────────────────┐      │  │
│  │  │  Microsoft Sentinel (enabled on workspace)                   │      │  │
│  │  │  • Data Connectors: Azure AD, Office 365, Syslog            │       │  │
│  │  │  • Analytics Rules: 5 sample detections                      │      │  │
│  │  │  • Sample Incidents: 20 test incidents                       │      │  │
│  │  └──────────────────────────────────────────────────────────────┘      │  │
│  │                                                                        │  │
│  │  ┌──────────────────────────────────────────────────────────────┐      │  │
│  │  │  Azure Logic Apps (Playbooks)                                │      │  │
│  │  │  • isolate-host-playbook                                     │      │  │
│  │  │  • block-ip-playbook                                         │      │  │
│  │  │  • enrich-alert-playbook                                     │      │  │
│  │  └──────────────────────────────────────────────────────────────┘      │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│  DATA SOURCES (Simulated for POC)                                            │
│                                                                              │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐                  │
│  │ Sample Alerts  │  │ Sample         │  │ Test Threat    │                  │
│  │ (JSON files)   │  │ Incidents      │  │ Intel Feed     │                  │
│  │ • 100 alerts   │  │ • 20 incidents │  │ • IOCs         │                  │
│  └────────────────┘  └────────────────┘  └────────────────┘                  │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

### 6.4 POC Implementation Plan

#### **Phase 1: Infrastructure Setup (Week 1)**

**Tasks**:
1. Provision Azure resources
   - Create resource groups (rg-mcp-poc, rg-sentinel-poc)
   - Deploy Log Analytics Workspace
   - Enable Microsoft Sentinel
   - Create Azure Function App for MCP server
   - Deploy Azure Key Vault

2. Configure authentication
   - Create Azure AD app registration for MCP
   - Assign Managed Identity to Function App
   - Grant permissions (Sentinel Reader, Log Analytics Reader)

3. Network configuration
   - Configure VNET integration for Function App
   - Set up Private Endpoints (if required)
   - Configure NSG rules

**Deliverables**:
- Infrastructure-as-Code templates (Bicep/Terraform)
- Network diagram
- Permission matrix

**Estimated Effort**: 16 hours

---

#### **Phase 2: MCP Server Development (Week 2-3)**

**Tasks**:
1. Set up development environment
   ```bash
   # Clone repository
   git clone https://github.com/your-org/mcp-sentinel-server.git
   cd mcp-sentinel-server
   
   # Create virtual environment
   python -m venv venv
   source venv/bin/activate  # Windows: venv\Scripts\activate
   
   # Install dependencies
   pip install fastmcp azure-identity azure-monitor-query azure-mgmt-securityinsight
   ```

2. Implement core MCP tools
   - ✅ `query_alerts()` - Query security alerts
   - ✅ `get_incident()` - Retrieve incident details
   - ✅ `create_incident()` - Create new incident
   - ✅ `execute_kql()` - Run KQL queries
   - ✅ `run_playbook()` - Trigger Logic App playbooks

3. Implement resources
   - ✅ `sentinel://alerts/recent` - Recent alerts feed
   - ✅ `sentinel://dashboard/metrics` - Dashboard data

4. Add error handling and logging
   - Implement retry logic
   - Add Application Insights telemetry
   - Create audit logs

5. Testing
   - Unit tests for each tool
   - Integration tests with Sentinel
   - Security testing (authentication, authorization)

**Deliverables**:
- Functional MCP server (Python)
- Unit test suite
- API documentation

**Estimated Effort**: 40 hours

---

#### **Phase 3: AI Client Integration (Week 3)**

**Tasks**:
1. Configure GitHub Copilot for MCP
   ```json
   // VS Code settings.json
   {
     "mcp.servers": {
       "sentinel": {
         "command": "python",
         "args": ["-m", "mcp_sentinel_server"],
         "env": {
           "WORKSPACE_ID": "your-workspace-id",
           "TENANT_ID": "your-tenant-id",
           "AZURE_CLIENT_ID": "your-client-id"
         }
       }
     }
   }
   ```

2. Test basic queries
   - "Show me critical alerts"
   - "Create an incident for alert XYZ"
   - "Query failed logins from Russia"

3. Configure Claude Desktop (optional)
   ```json
   // claude_desktop_config.json
   {
     "mcpServers": {
       "sentinel": {
         "command": "python",
         "args": ["-m", "mcp_sentinel_server"]
       }
     }
   }
   ```

**Deliverables**:
- Client configuration files
- User guide for AI assistants
- Sample prompts/queries

**Estimated Effort**: 8 hours

---

#### **Phase 4: Use Case Testing (Week 4)**

**Test Scenarios**:

| **Scenario** | **Description** | **Expected Outcome** | **Pass/Fail** |
|--------------|-----------------|---------------------|---------------|
| UC-1: Alert Triage | Query high-severity alerts, sort by risk | Accurate results in <5 seconds | ☐ |
| UC-2: Incident Creation | Create incident from alert via natural language | Incident created with correct metadata | ☐ |
| UC-3: Threat Hunting | Run complex KQL query via conversational prompt | Query translated correctly, results accurate | ☐ |
| UC-4: Playbook Execution | Trigger "isolate host" playbook | Logic App executed, host isolated | ☐ |
| UC-5: Dashboard Data | Retrieve security metrics for dashboard | Current metrics returned | ☐ |

**Testing Checklist**:
- [ ] Functional testing (all 5 scenarios)
- [ ] Performance testing (response time <5 seconds)
- [ ] Security testing (unauthorized access blocked)
- [ ] Error handling (invalid queries handled gracefully)
- [ ] Audit logging (all actions logged to Log Analytics)

**Deliverables**:
- Test results report
- Performance metrics
- Issue log

**Estimated Effort**: 24 hours

---

#### **Phase 5: Documentation & Training (Week 4)**

**Tasks**:
1. Create documentation
   - User guide (how to use MCP with Copilot)
   - Administrator guide (deployment, configuration)
   - Troubleshooting guide
   - API reference

2. Conduct training session
   - 2-hour workshop for SOC team
   - Demonstrate key use cases
   - Q&A session

3. Collect feedback
   - Survey SOC analysts
   - Document feature requests
   - Identify pain points

**Deliverables**:
- Complete documentation set
- Training presentation
- Feedback report

**Estimated Effort**: 16 hours

---

### 6.5 POC Timeline

```
Week 1: Infrastructure Setup
├─ Day 1-2: Azure resource provisioning
├─ Day 3: Authentication & permissions
└─ Day 4-5: Network configuration & testing

Week 2: MCP Server Development
├─ Day 6-7: Core tools implementation
├─ Day 8: Resources & error handling
└─ Day 9-10: Testing & debugging

Week 3: Integration & Advanced Features
├─ Day 11-12: AI client integration
├─ Day 13: Advanced queries & playbooks
└─ Day 14-15: End-to-end testing

Week 4: Validation & Handover
├─ Day 16-17: Use case testing
├─ Day 18: Documentation
├─ Day 19: Training session
└─ Day 20: POC review & go/no-go decision
```

**Total Duration**: 4 weeks (20 working days)

---

### 6.6 POC Cost Estimate

| **Resource** | **SKU** | **Quantity** | **Monthly Cost** | **4-Week Cost** |
|--------------|---------|--------------|------------------|-----------------|
| Azure Function App | Consumption | 1 | ~$10 | $10 |
| Log Analytics Workspace | 1 GB/day | 1 | ~$30 | $30 |
| Microsoft Sentinel | Included in LA | 1 | ~$0 | $0 |
| Azure Key Vault | Standard | 1 | ~$5 | $5 |
| Application Insights | 5 GB/month | 1 | ~$10 | $10 |
| Logic Apps | 100 runs | 3 | ~$15 | $15 |
| **Total Azure Costs** | | | | **~$70** |
| **Labor Costs** (2 engineers × 40 hours × $100/hr) | | | | **$8,000** |
| **Grand Total** | | | | **$8,070** |

*Note: Actual costs may vary based on usage patterns and regional pricing*

---

### 6.7 POC Success Metrics

#### **Quantitative Metrics**

| **Metric** | **Baseline (Manual)** | **Target (MCP)** | **Improvement** |
|------------|-----------------------|------------------|-----------------|
| Time to query alerts | 3 minutes | <30 seconds | 83% reduction |
| Time to create incident | 5 minutes | <1 minute | 80% reduction |
| Time to run threat hunt | 15 minutes | <3 minutes | 80% reduction |
| Time to execute playbook | 10 minutes | <2 minutes | 80% reduction |
| Queries per analyst/day | 20 | 50+ | 150% increase |

#### **Qualitative Metrics**

- [ ] **Ease of Use**: SOC analysts rate MCP interface 4/5 or higher
- [ ] **Accuracy**: 90%+ of natural language queries translated correctly
- [ ] **Reliability**: 99%+ uptime during POC period
- [ ] **Security**: Zero security incidents related to MCP
- [ ] **Satisfaction**: 80%+ of analysts want to continue using MCP

---

### 6.8 POC Risks & Mitigations

| **Risk** | **Likelihood** | **Impact** | **Mitigation** |
|----------|----------------|------------|----------------|
| Azure API rate limiting | Medium | High | Implement caching, request throttling |
| Incorrect query translation | High | Medium | Add query validation, human approval for destructive ops |
| Authentication issues | Low | High | Use Managed Identity, thorough testing |
| Performance degradation | Medium | Medium | Optimize queries, set timeouts, use async operations |
| User adoption resistance | Medium | Medium | Training, demonstrate value, gather feedback early |
| Cost overruns | Low | Low | Set daily spending limits, monitor usage |

---

### 6.9 POC Go/No-Go Decision Criteria

**Proceed to Production if:**
✅ All 5 use cases pass testing  
✅ Response time <5 seconds for 95% of queries  
✅ Zero critical security issues  
✅ 80%+ positive feedback from SOC team  
✅ Demonstrated ROI (time savings > cost)  

**Do Not Proceed if:**
❌ Critical security vulnerabilities identified  
❌ Performance unacceptable (>10 second response time)  
❌ Low accuracy (<70% correct query translations)  
❌ Negative feedback from majority of SOC team  
❌ Cost exceeds budget by >50%  

---

### 6.10 Post-POC Roadmap

**If POC Successful:**

**Phase 1: Pilot (Months 1-2)**
- Deploy to 5-10 SOC analysts
- Monitor usage and performance
- Collect detailed feedback
- Iterate on features

**Phase 2: Production (Months 3-4)**
- Deploy to entire SOC team (30+ analysts)
- Integrate with additional security tools (EDR, NDR, CASB)
- Develop custom playbooks
- Implement advanced features (ML-based recommendations)

**Phase 3: Scale (Months 5-6)**
- Expand to other teams (GRC, IT Ops, Threat Intel)
- Multi-tenant support
- Self-service playbook creation
- Integration with ServiceNow/ITSM

---

## 📚 References

1. **Model Context Protocol (MCP) Specification**  
   https://modelcontextprotocol.io/docs

2. **Microsoft Sentinel API Documentation**  
   https://learn.microsoft.com/en-us/rest/api/securityinsights/

3. **Azure Monitor Query API**  
   https://learn.microsoft.com/en-us/azure/azure-monitor/logs/api/overview

4. **FastMCP Framework (Python)**  
   https://github.com/jlowin/fastmcp

5. **GitHub Copilot MCP Integration**  
   https://docs.github.com/en/copilot/using-github-copilot/using-extensions-to-integrate-external-tools-with-copilot-chat

6. **Azure Logic Apps Webhook Triggers**  
   https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-http-endpoint

---

## 📝 Appendix

### Appendix A: Sample MCP Configuration

```json
{
  "mcpServers": {
    "microsoft-sentinel": {
      "command": "python",
      "args": ["-m", "mcp_sentinel_server"],
      "env": {
        "WORKSPACE_ID": "12345678-1234-1234-1234-123456789012",
        "TENANT_ID": "87654321-4321-4321-4321-210987654321",
        "SUBSCRIPTION_ID": "11111111-2222-3333-4444-555555555555",
        "RESOURCE_GROUP": "rg-sentinel-prod",
        "AZURE_CLIENT_ID": "app-registration-client-id",
        "KEY_VAULT_URL": "https://kv-security.vault.azure.net/",
        "LOG_LEVEL": "INFO"
      }
    }
  }
}
```

### Appendix B: Sample Natural Language Queries

```
# Alert Management
"Show me all critical alerts from the last 24 hours"
"Get details for alert with ID 12345"
"List alerts related to ransomware in the last week"

# Incident Management
"Create an incident for the PowerShell alert on SRV-001"
"Update incident #2024 status to 'Under Investigation'"
"Assign incident #2025 to john.doe@contoso.com"
"Close incident #2026 with resolution: False Positive"

# Threat Hunting
"Find all failed login attempts from external IPs"
"Search for lateral movement using PsExec"
"Show me data exfiltration attempts over 1GB"
"Identify users with suspicious privilege escalation"

# Automation
"Run the phishing response playbook for email ID xyz"
"Isolate host DESKTOP-ABC123 from the network"
"Block IP address 203.0.113.45 in the firewall"

# Reporting
"Generate a summary of security events this week"
"Export all malware detections from January 2026"
"Create a compliance report for PCI-DSS systems"
```

### Appendix C: KQL Query Examples

```kql
// Find brute force login attempts
SigninLogs
| where TimeGenerated > ago(1h)
| where ResultType != "0"
| summarize FailedAttempts = count() by IPAddress, UserPrincipalName
| where FailedAttempts > 10
| order by FailedAttempts desc

// Detect potential data exfiltration
OfficeActivity
| where TimeGenerated > ago(24h)
| where Operation in~ ("FileDownloaded", "FileCopied")
| summarize FileCount = count(), TotalSize = sum(Size) by UserId
| where TotalSize > 1000000000  // 1GB
| order by TotalSize desc

// Identify lateral movement
SecurityEvent
| where TimeGenerated > ago(24h)
| where EventID == 4648  // Explicit credential logon
| where TargetUserName != "-"
| project TimeGenerated, Computer, Account, TargetUserName, IpAddress
```

---

**Document Status**: Draft  
**Next Review Date**: February 15, 2026  
**Approval Required**: CISO, Security Architecture Team  
**Contact**: security-engineering@contoso.com

