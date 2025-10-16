# 🧠 Microsoft Sentinel Analytic Rule Testing Guide
### Test Analytic Rules Safely Using Mock CSV Data (No Test Environment Needed)

---

## 📍 Overview
This guide describes **how to test Microsoft Sentinel Analytic Rules** without using a production environment or ingesting any mock data.  
It is designed for SOC analysts and engineers who only have **mock logs in CSV format** and **no permission to create or modify Azure resources**.

You will learn to:
- Use in-memory KQL tables (`datatable()`)
- Reference public CSVs (`externaldata()`)
- Convert your CSV into KQL automatically (PowerShell)
- Validate analytic rule logic safely

---

## ⚙️ Prerequisites
- Access to **Microsoft Sentinel Logs** (read-only permission is enough)
- Mock CSV data (e.g., from Atomic Red Team or custom dataset)
- Optionally: PowerShell (for CSV → datatable conversion)

---

## 🚀 Option A — Use `datatable()` (No Uploads or Permissions Required)
This is the simplest and safest way to simulate your data directly in the Sentinel Logs query window.

### ✅ Steps
1. Open **Microsoft Sentinel → Logs → New Query**  
2. Paste the below query and modify with your own mock data

```kql
// Sample EmailEvents (replace with your own data)
let EmailEvents = datatable(TimeGenerated:datetime, NetworkMessageId:string, SenderFromAddress:string, RecipientEmailAddress:string, Subject:string, DeliveryAction:string, ClientIP:string)
[
  datetime(2025-10-15T09:00:00Z), "<msg-0001@example.com>", "alice.external@example.com", "bob@contoso.com", "Q3 Financials - Please review", "Delivered", "203.0.113.45",
  datetime(2025-10-15T09:10:00Z), "<msg-0002@example.com>", "unknown@phishingsite.info", "hr@contoso.com", "Employee Benefits Update - see attached", "Quarantined", "45.33.32.101",
  datetime(2025-10-15T09:20:00Z), "<msg-0003@example.com>", "ceo-compromised@trustedpartner.com", "it-admin@contoso.com", "FW: Urgent - Server reboot instructions", "Delivered", "198.51.100.22"
];

// Sample EmailAttachmentInfo
let EmailAttachmentInfo = datatable(TimeGenerated:datetime, NetworkMessageId:string, AttachmentName:string, AttachmentType:string, AttachmentHash:string, AttachmentSize:int, IsMalicious:bool, ScanVerdict:string)
[
  datetime(2025-10-15T09:00:00Z), "<msg-0001@example.com>", "Q3-Financials.docx", "docx", "FAKEHASH0001", 256000, false, "NoThreatFound",
  datetime(2025-10-15T09:10:00Z), "<msg-0002@example.com>", "Benefits.xlsm", "xlsm", "FAKEHASH0002", 512000, true, "MacroBehaviorDetected",
  datetime(2025-10-15T09:20:00Z), "<msg-0003@example.com>", "RebootSteps.pdf", "pdf", "FAKEHASH0003", 120000, false, "NoThreatFound"
];

// Analytic Rule KQL Logic Example
EmailAttachmentInfo
| join kind=inner (EmailEvents) on NetworkMessageId
| where IsMalicious == true or AttachmentType in ("docm","xlsm","pptm")
| project TimeGenerated, SenderFromAddress, RecipientEmailAddress, Subject, AttachmentName, AttachmentType, ScanVerdict, DeliveryAction, ClientIP
| order by TimeGenerated desc
```
This creates temporary in-memory tables that only exist during query execution — no ingestion or permissions required.

## 🚀 Option B — Use externaldata() with a Public CSV
If you host your CSV file in GitHub or an accessible location, you can query it directly:

```
let EmailEvents = externaldata(TimeGenerated:datetime, NetworkMessageId:string, SenderFromAddress:string, RecipientEmailAddress:string, Subject:string, DeliveryAction:string, ClientIP:string)
[h@"https://raw.githubusercontent.com/youruser/yourrepo/main/EmailEvents_T1566_001_mock.csv"]
with(format="csv", ignoreFirstRecord=true);

let EmailAttachmentInfo = externaldata(TimeGenerated:datetime, NetworkMessageId:string, AttachmentName:string, AttachmentType:string, AttachmentHash:string, AttachmentSize:int, IsMalicious:bool, ScanVerdict:string)
[h@"https://raw.githubusercontent.com/youruser/yourrepo/main/EmailAttachmentInfo_T1566_001_mock.csv"]
with(format="csv", ignoreFirstRecord=true);

EmailAttachmentInfo
| join kind=inner (EmailEvents) on NetworkMessageId
| where IsMalicious == true or AttachmentType in ("docm","xlsm","pptm")
| project TimeGenerated, SenderFromAddress, RecipientEmailAddress, Subject, AttachmentName, AttachmentType, ScanVerdict, DeliveryAction, ClientIP

```
##### Note: The CSV link must be publicly accessible (raw.githubusercontent.com or public blob).

## 🧪 Validation Steps
- Paste the datatable() or externaldata() query into Sentinel → Logs
- Run your full analytic rule KQL and confirm:
  - The join works as expected
  - Filtering, summarization, and conditions match the rule logic
  - Results return expected detection rows
- Adjust timestamps to simulate different time windows (e.g., use ago()).
