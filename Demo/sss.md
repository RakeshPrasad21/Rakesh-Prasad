# Daily Checks Automation – Discovery Report

> **Version:** 1.0 | **Date:** April 7, 2026 | **Status:** Draft for Review | **Classification:** Internal – Confidential

---

## Summary Metrics

| Metric | Value |
|---|---|
| Daily KQL Check Functions in Sentinel | **25+** |
| Daily Manual Effort (to be eliminated) | **~2 hours** |
| Manual Steps Blocking Full Automation | **3 critical** |
| Estimated Implementation Timeline | **6 weeks** |

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Scope & Assumptions](#2-scope--assumptions)
3. [Current State – As-Is Architecture](#3-current-state--as-is-architecture)
4. [Gap Analysis](#4-gap-analysis)
5. [Component Inventory](#5-component-inventory)
6. [Implementation Options](#6-implementation-options)
7. [Prerequisites & Dependencies](#7-prerequisites--dependencies)
8. [Implementation Roadmap](#8-implementation-roadmap)
9. [Risk Register](#9-risk-register)
10. [Estimated Azure Cost](#10-estimated-azure-cost)
11. [Security & Compliance Considerations](#11-security--compliance-considerations)
12. [Success Metrics & Acceptance Criteria](#12-success-metrics--acceptance-criteria)
13. [Recommended Next Steps](#13-recommended-next-steps)
14. [Conclusion](#14-conclusion)

---

## 1. Executive Summary

The Security Operations team currently runs **20–25 daily checks** plus several weekly checks using Microsoft Sentinel KQL functions. While the Sentinel execution layer has already been partially automated via a Logic App and watchlist, the downstream processing and reporting pipeline still requires significant manual intervention — primarily the CyberArk report download, PowerShell comparison execution, and distribution of the final Excel report.

This discovery report documents the **current state**, identifies automation gaps, evaluates implementation options, and proposes a phased roadmap to achieve **zero manual intervention** across the entire daily checks workflow.

The recommended architecture leverages:
- **Azure Logic Apps** for orchestration
- **Azure Functions (PowerShell)** for processing and Excel generation
- **CyberArk REST API** for automated data retrieval
- **Power BI** for real-time dashboards

Results would be delivered automatically by **6:30 AM each day** with no human intervention required.

---

## 2. Scope & Assumptions

### In Scope

| # | Item |
|---|---|
| 1 | Automation of the existing 20–25 daily Sentinel KQL check functions |
| 2 | Automation of weekly Sentinel KQL check functions |
| 3 | Automated CyberArk data retrieval via REST API |
| 4 | Automated PowerShell-based comparison of Sentinel results vs CyberArk data |
| 5 | Automated generation and email distribution of formatted Excel report |
| 6 | Structured CSV and Excel storage in Azure Blob with lifecycle management |
| 7 | Error alerting via Microsoft Teams and email on any step failure |
| 8 | Power BI dashboard for historical trending and compliance visibility |
| 9 | Sentinel Workbook for check history and pass/fail analysis |

### Out of Scope

| # | Item | Reason |
|---|---|---|
| 1 | Modifying the existing KQL check logic / function content | Separate SOC review process |
| 2 | Auto-remediation of failed checks | Future phase – requires CAB approval |
| 3 | Integration with ITSM ticketing systems (ServiceNow, etc.) | Future phase |
| 4 | CyberArk PAM configuration changes | Managed by CyberArk admin team |
| 5 | Power BI report design / branding | Handled by BI team post go-live |
| 6 | Migration of historical check data | Data migration is a separate workstream |

### Assumptions

- The existing Sentinel KQL functions are stable, tested, and return consistent output schemas.
- The CyberArk platform exposes a REST API that can be accessed from Azure using a service account or managed identity.
- The existing Logic App has a valid Sentinel connection using a service principal or managed identity (not a personal user token).
- SecOps team will be available for a 5-day parallel run validation in Phase 5 before manual steps are disabled.
- The existing PowerShell comparison script is functional, documented, and owned by the SecOps engineering team.
- Azure subscription exists and appropriate RBAC roles can be granted within the project timeline.
- Microsoft 365 / Office 365 mailbox is available for automated email sending.
- The organisation uses Microsoft Teams as the primary collaboration and alerting channel.

---

## 3. Current State – As-Is Architecture

### Process Flow

```
[Sentinel KQL Functions] ──► [Watchlist Lookup] ──► [Logic App Execution] ──► [CSV + Email Output]
      ✅ Automated               ✅ Automated            ✅ Automated               ✅ Automated

[CSV + Email Output] ──► [CyberArk Download] ──► [PowerShell Compare] ──► [Excel Report Review]
                            ⚠️ MANUAL                 ⚠️ MANUAL                 ⚠️ MANUAL
```

### Step-by-Step Breakdown

| # | Process Step | Tool / Method | Status | Pain Points |
|---|---|---|---|---|
| 1 | KQL Check Functions stored in Sentinel | Microsoft Sentinel – Log Analytics | ✅ Automated | Functions need periodic review & versioning |
| 2 | Watchlist drives check execution list | Sentinel Watchlist | ✅ Automated | Manual updates when new checks are added |
| 3 | Logic App triggers daily and loops checks | Azure Logic App | ✅ Automated | Error handling limited; no retry alerting |
| 4 | CSV generated per check, emailed to team | Logic App → Office 365 connector | ⚠️ Partial | No consolidated report; CSVs sent individually |
| 5 | CSV stored in folder structure | Logic App → SharePoint / File Share | ✅ Automated | No archiving policy; folder grows unbounded |
| 6 | CyberArk Cyber Arc report download | **Manual – SecOps browser download** | ❌ Manual | Time-sensitive; fails when staff are absent |
| 7 | PowerShell compare Sentinel vs CyberArk | **Manual – local PS execution** | ❌ Manual | No logging; single point of failure on workstation |
| 8 | Excel report with discrepancies sent | **Manual – SecOps email** | ❌ Manual | Inconsistent formatting; no historical comparison |

---

## 4. Gap Analysis

> **3 Critical gaps** must be resolved to achieve full automation.

| Gap ID | Area | Current State | Target State | Priority |
|---|---|---|---|---|
| **GAP-01** | CyberArk Data Retrieval | SecOps manually downloads Cyber Arc report daily from portal | CyberArk REST API called automatically at 6:00 AM by Azure Function | 🔴 HIGH |
| **GAP-02** | PowerShell Comparison Engine | PS script run manually on SecOps local workstation; no logging | Azure Function hosts PS runbook; triggered automatically after data collection | 🔴 HIGH |
| **GAP-03** | Excel Report Distribution | SecOps manually attaches and emails Excel output to distribution list | Logic App auto-generates formatted Excel and emails on completion | 🔴 HIGH |
| **GAP-04** | Error Handling & Alerting | No notification if a check fails; failures discovered retroactively | Teams / email alert on any check failure with run details | 🟡 MEDIUM |
| **GAP-05** | Historical Trending | No historical dashboard; comparison done ad-hoc in Excel only | Power BI dashboard showing pass/fail trends, compliance score over time | 🟡 MEDIUM |
| **GAP-06** | Watchlist Maintenance | Watchlist updated manually when checks are added or modified | Automated watchlist sync from a master configuration file | 🟡 MEDIUM |
| **GAP-07** | Weekly Checks Orchestration | Weekly checks run on the same daily schedule (inconsistent) | Separate schedule for weekly checks (Sunday 7:00 AM) | 🟢 LOW |
| **GAP-08** | Storage Archiving | CSV folder grows without lifecycle policy; no retention management | Azure Storage lifecycle policy archives data older than 90 days | 🟢 LOW |

---

## 5. Component Inventory

| Component | Exists Today? | Current Role | Target Role | Action Required |
|---|---|---|---|---|
| Microsoft Sentinel | ✅ Yes | Hosts 20–25 daily KQL functions + weekly checks | Same + scheduled analytics rules for alerting | Add scheduled query rules; review function versioning |
| Sentinel Watchlist | ✅ Yes | Stores list of check names and parameters | Same + add schedule type (daily/weekly), enabled flag | Update watchlist schema; add new columns |
| Logic App (Checks Runner) | ✅ Yes | Runs daily, reads watchlist, executes KQL, emails CSV | Enhanced – includes retry, error alerting, trigger AF | Enhance existing Logic App; add error handling steps |
| Azure Function (PowerShell) | ❌ No | – | Runs PS comparison, generates Excel, calls CyberArk API | **Create new** Azure Function App (PowerShell runtime) |
| CyberArk REST API | ⚠️ Exists, not integrated | Portal accessed manually by SecOps | API called automatically by Azure Function | Obtain API credentials; configure managed identity auth |
| Azure Storage Account | ⚠️ Partial | CSVs stored in file share / local folder | Central blob storage with /YYYY/MM/DD/ folder structure | Create storage account; configure lifecycle policy |
| Logic App (Email Distributor) | ⚠️ Partial (single email) | Sends individual CSV per check | Sends consolidated Excel + all CSVs to distribution list | Update or create second Logic App for distribution |
| Power BI Dashboard | ❌ No | – | Real-time metrics, trends, compliance scores | **Create new** Power BI dataset + report from Storage |
| Teams Integration | ❌ No | – | Adaptive Card alerts on failures + daily summary | Add Teams connector to Logic App; create channel |
| Key Vault | ⚠️ Unknown | Not used for this workflow | Stores CyberArk API secrets, storage keys securely | Create Key Vault secrets; wire to Function/Logic App |

---

## 6. Implementation Options

The key decision is which technology handles the **comparison and report generation** step (GAP-01, 02, 03).

### Option 1 – KQL Scheduled Analytics

| | |
|---|---|
| **What it does** | Native Sentinel scheduled query rules run KQL checks on a cron schedule and raise incidents/alerts |
| **Pros** | ✅ Simplest setup – no new services; ✅ Native Sentinel integration; ✅ Built-in alert management |
| **Cons** | ❌ Cannot generate Excel output; ❌ No CyberArk API capability; ❌ Limited data transformation |
| **Fit** | ⚠️ Partial Fit – suitable for detection only |
| **Complexity** | Low |

---

### Option 2 – Logic App Extended Workflow

| | |
|---|---|
| **What it does** | Expands existing Logic App to handle CyberArk API calls, CSV comparison, and Excel generation via connectors |
| **Pros** | ✅ No new services required; ✅ Visual designer – low code; ✅ 400+ built-in connectors |
| **Cons** | ❌ Limited PowerShell scripting; ❌ Complex data transforms are verbose; ❌ Higher per-action cost at scale |
| **Fit** | ⚠️ Moderate Fit – struggles with complex Excel formatting logic |
| **Complexity** | Low–Medium |

---

### Option 3 – Azure Function (PowerShell) ⭐ RECOMMENDED

| | |
|---|---|
| **What it does** | Serverless Azure Function running PowerShell runtime. Reuses existing PS scripts, calls CyberArk API, generates Excel with ImportExcel module |
| **Pros** | ✅ Reuse existing PowerShell scripts; ✅ Full scripting power for complex logic; ✅ ImportExcel for rich Excel output; ✅ Serverless – pay per execution; ✅ Easy CyberArk REST API integration |
| **Cons** | ⚠️ Requires PowerShell development skills; ⚠️ Cold start latency (~2–5s) |
| **Fit** | ✅ Best overall fit – matches current tooling; minimal rewrite needed |
| **Complexity** | Medium |

---

### Option 4 – Azure Automation Runbook

| | |
|---|---|
| **What it does** | Managed service for PS runbooks with built-in scheduling, hybrid worker for on-prem connectivity, and job history |
| **Pros** | ✅ Direct reuse of existing PS scripts; ✅ Hybrid Runbook Worker for on-prem; ✅ Job history and audit logs |
| **Cons** | ❌ Service being consolidated into Azure Arc; ❌ Slower cold start vs functions; ❌ Less flexible trigger options |
| **Fit** | ⚠️ Viable if on-prem connectivity needed; otherwise prefer Azure Functions |
| **Complexity** | Low–Medium |

---

### Option 5 – Sentinel SOAR Playbooks

| | |
|---|---|
| **What it does** | Logic App playbooks triggered by Sentinel incidents/alerts. Deep native integration with Sentinel entities and incidents |
| **Pros** | ✅ Deep Sentinel incident integration; ✅ Teams / email alert built-in; ✅ Auto incident response actions |
| **Cons** | ❌ Alert/incident-driven only; ❌ Not suitable for scheduled reports; ❌ Cannot replace comparison logic |
| **Fit** | ⚠️ Best as a complement, not a primary processing engine |
| **Complexity** | Low |

---

### Option 6 – Hybrid: Logic App + Azure Function ✅ Best Architecture

| | |
|---|---|
| **What it does** | Logic App handles orchestration and connectors; Azure Function handles heavy PS processing |
| **Pros** | ✅ Logic App = easy connectors + routing; ✅ Function = full PS scripting power; ✅ Separation of concerns; ✅ Independently scalable |
| **Cons** | ⚠️ Two services to manage; ⚠️ Slightly more complex debugging |
| **Fit** | ✅ Ideal architecture combining simplicity of Logic App with power of Functions |
| **Complexity** | Medium |

---

## 7. Prerequisites & Dependencies

| Category | Requirement | Owner | Status |
|---|---|---|---|
| CyberArk | CyberArk REST API endpoint URL and authentication method (OAuth / API key) | CyberArk Admin | ❌ To Confirm |
| CyberArk | Service account / managed identity with read-only access to Cyber Arc reports | CyberArk Admin | ❌ To Confirm |
| Azure | Azure subscription with Contributor rights to deploy Function App, Logic App, Storage | Azure Admin | ⚠️ Check Access |
| Azure | Key Vault instance to store CyberArk credentials and storage connection strings | Azure Admin | ❌ To Create |
| Sentinel | Managed Identity or Service Principal for Logic App to query Sentinel KQL functions | Sentinel Admin | ⚠️ Verify Existing |
| Sentinel | Watchlist schema update – add columns: ScheduleType, Enabled, LastRunStatus | SecOps | ❌ To Update |
| Email | Office 365 service account / shared mailbox for automated email distribution | IT Admin | ⚠️ Check Existing |
| Email | Final distribution list (DL) for daily reports – confirm recipients | SecOps Manager | ❌ To Confirm |
| Storage | Azure Storage Account with blob containers for CSVs, CyberArk data, Excel outputs | Azure Admin | ❌ To Create |
| PowerShell | Existing PS comparison script reviewed and ready for migration to Azure Function | SecOps Engineer | ⚠️ Review Needed |
| Power BI | Power BI Pro license for dashboard authors + workspace access | IT Admin | ⚠️ Check Licenses |
| Teams | Dedicated Teams channel for SecOps automation alerts; webhook URL | SecOps Manager | ❌ To Create |

---

## 8. Implementation Roadmap

### Phase 1 – Foundations & CyberArk API Integration `Week 1–2`

> Establish Azure infrastructure, obtain CyberArk API access, and validate automated data retrieval. Closes **GAP-01**.

- [ ] Deploy Azure Function App (PowerShell runtime)
- [ ] Create Azure Key Vault + secrets
- [ ] Create Azure Storage Account + containers
- [ ] Obtain CyberArk API credentials
- [ ] Build PS function: CyberArk API pull
- [ ] Test automated CyberArk data collection
- [ ] Store CyberArk output in Azure Blob

---

### Phase 2 – PowerShell Migration to Azure Function `Week 2–3`

> Migrate existing local PowerShell comparison script to Azure Function with enhanced error handling and Excel output. Closes **GAP-02**, **GAP-03**.

- [ ] Review existing PS comparison script
- [ ] Install ImportExcel PS module in Function App
- [ ] Migrate comparison logic to Azure Function
- [ ] Add Excel formatting & conditional formatting
- [ ] Add error handling + structured logging
- [ ] Test outputs match manual process
- [ ] Upload Excel to Azure Blob on completion

---

### Phase 3 – Logic App Enhancement & Email Distribution `Week 3–4`

> Enhance existing Logic App to trigger Azure Function and add automated email distribution. Closes **GAP-04**.

- [ ] Update Sentinel Watchlist schema
- [ ] Add retry logic to existing Logic App
- [ ] Add step: trigger Azure Function post-checks
- [ ] Create Logic App 2: Email distributor
- [ ] Configure distribution list + attachments
- [ ] Add Teams failure alert connector
- [ ] Add weekly check schedule (Sunday 7:00 AM)

---

### Phase 4 – Dashboards & Monitoring `Week 4–5`

> Deliver real-time visibility through Power BI and Sentinel Workbook. Closes **GAP-05**.

- [ ] Create Power BI dataset from Azure Blob
- [ ] Build Power BI dashboard (trends, compliance scores)
- [ ] Create Sentinel Workbook for check history
- [ ] Set up Azure Monitor alerts for function failures
- [ ] Configure Storage lifecycle policy (90-day archive)
- [ ] Set up Application Insights for Function App

---

### Phase 5 – Parallel Run, Testing & Go-Live `Week 5–6`

> Run automated and manual processes in parallel to validate accuracy before full cutover.

- [ ] Run parallel: automated vs manual (5 days)
- [ ] Validate Excel output accuracy
- [ ] Validate CyberArk data matches manual download
- [ ] Sign-off from SecOps team lead
- [ ] Disable manual process steps
- [ ] Document runbooks & support procedures
- [ ] Handover & team training

---

## 9. Risk Register

| Risk ID | Risk Description | Likelihood | Impact | Severity | Mitigation |
|---|---|---|---|---|---|
| **R-01** | CyberArk API access not available or restricted | Medium | High | 🔴 HIGH | Engage CyberArk admin early in Phase 1; fallback to SFTP if API unavailable |
| **R-02** | Existing PS scripts too complex to migrate without rewrite | Low | Medium | 🟡 MEDIUM | Script review workshop in Week 1; budget 3 days for refactoring |
| **R-03** | Azure permissions not available for deployment | Medium | High | 🔴 HIGH | Submit access request in Week 0; work with Azure admin for IAM setup |
| **R-04** | Logic App user access token expires or authentication breaks | Low | High | 🟡 MEDIUM | Switch to Managed Identity for Logic App – eliminates token expiry |
| **R-05** | KQL function results differ from expected in automated run | Low | Medium | 🟡 MEDIUM | 5-day parallel run in Phase 5 to validate all outputs before cutover |
| **R-06** | Costs exceed estimate due to high Logic App action volume | Low | Low | 🟢 LOW | Set Azure budget alerts at 80% threshold; monitor first 2 weeks |
| **R-07** | Team resistance to removing manual review step | Medium | Low | 🟢 LOW | Parallel run demonstrates accuracy; Power BI dashboard gives full visibility |

---

## 10. Estimated Azure Cost

> Based on Consumption (pay-per-use) tier. Actual costs depend on check count and data volume.

| Service | Usage Basis | Est. Monthly Cost (USD) | Notes |
|---|---|---|---|
| Azure Function App | ~30 executions/month (daily), ~2 min/run | ~$0–$5 | First 1M executions free; minimal cost |
| Logic App (Consumption) | ~25 actions/check × 25 checks × 30 days | ~$10–$30 | $0.000025/action; scale with check count |
| Azure Storage Account | ~5 GB CSVs + Excel per month | ~$1–$3 | Blob storage + lifecycle archiving after 90 days |
| Azure Key Vault | ~100 secret operations/month | <$1 | Negligible cost |
| Application Insights | ~500 MB logs/month | ~$1–$3 | First 5 GB/month free |
| Power BI Pro | Per user license | ~$10/user/month | May already be licensed; check existing licenses |
| **Total** | | **~$25–$55 / month** | Excluding existing Sentinel / Power BI licenses |

---

## 11. Security & Compliance Considerations

Security is a first-class concern in this automation. The following controls must be implemented:

### Identity & Access Management

| Control | Implementation | Standard |
|---|---|---|
| No hardcoded credentials | All secrets stored in Azure Key Vault; never in code or config files | OWASP / CIS |
| Managed Identity | Logic Apps and Azure Functions use system-assigned managed identities | Zero Trust |
| Least privilege | Each component granted minimum RBAC roles required (e.g., Sentinel Reader for Logic App) | CIS Azure |
| Service Principal rotation | CyberArk API service account password rotated every 90 days | ISO 27001 |
| MFA on admin accounts | All Azure admin accounts require MFA | NIST 800-53 |

### Data Security

| Control | Implementation |
|---|---|
| Encryption at rest | Azure Storage uses AES-256 encryption by default |
| Encryption in transit | All API calls use HTTPS / TLS 1.2+ |
| Data classification | CSVs and Excel reports classified as **Internal – Confidential** |
| Access control on storage | Storage containers use private access; SAS tokens with expiry for Logic App |
| Email attachment security | Reports sent only to approved distribution list; no external recipients |

### Audit & Logging

| Control | Implementation |
|---|---|
| Function App logging | Application Insights captures all execution logs, exceptions, and durations |
| Logic App run history | 90-day run history retained in Azure portal |
| Storage access logs | Azure Storage analytics logs all read/write operations |
| Key Vault audit logs | All secret access events logged to Azure Monitor / Log Analytics |
| Sentinel audit trail | All KQL query executions logged in Sentinel audit logs |

### Compliance Considerations

- All Azure resources deployed in the organisation's approved region to comply with **data residency** requirements.
- CyberArk integration must be reviewed and approved by the **CyberArk owner** and **Information Security** team before go-live.
- Automated email distribution must comply with the organisation's **data handling policy** — verify recipients are authorised to receive security reports.
- Azure Function code must be stored in a **source-controlled repository** (Git) with peer review before deployment.
- Change management process (**CAB / change ticket**) required before disabling manual steps in Phase 5.

---

## 12. Success Metrics & Acceptance Criteria

| Metric | Current Baseline | Target | Measurement Method |
|---|---|---|---|
| Daily Manual Effort | ~2 hours/day (SecOps) | **0 minutes** | Time tracking before/after |
| Report Delivery Time | 9:00–10:00 AM (when remembered) | **By 6:30 AM daily** | Email timestamp analysis |
| Check Execution Reliability | ~80% (skipped when SecOps busy) | **99.9%** (Azure SLA backed) | Logic App run history |
| CyberArk Data Accuracy | N/A – manual pull | **100% match** with manual download (parallel run validation) | 5-day parallel comparison |
| Excel Report Accuracy | Dependent on script version | **100% match** with manually produced report | Field-by-field comparison in parallel run |
| Failure Alert Latency | Discovered next day (no alerting) | **Teams alert within 5 minutes** of failure | Monitor alert timestamps |
| Historical Data Retention | No structured storage | **90 days hot + 1 year archive** | Azure Storage lifecycle policy |

---

## 13. Recommended Next Steps

| # | Action | Owner | Due | Priority |
|---|---|---|---|---|
| 1 | Schedule discovery workshop with CyberArk admin to confirm API access method | SecOps Lead | Week 0 | 🔴 HIGH |
| 2 | Submit Azure RBAC request for Function App, Logic App, Storage, Key Vault deployment | Azure Admin | Week 0 | 🔴 HIGH |
| 3 | Conduct PowerShell script review session — document inputs, outputs, dependencies | SecOps Engineer | Week 1 | 🔴 HIGH |
| 4 | Confirm email distribution list for automated reports | SecOps Manager | Week 1 | 🟡 MEDIUM |
| 5 | Confirm Power BI Pro license availability | IT Admin | Week 1 | 🟡 MEDIUM |
| 6 | Create Teams channel for SecOps automation alerts | SecOps Manager | Week 1 | 🟢 LOW |
| 7 | Review and approve this discovery report — confirm scope and approach | Project Sponsor | Week 0 | 🔴 HIGH |

---

---

## 14. Conclusion

This discovery report confirms that the Daily Checks automation workflow is **well-positioned for full end-to-end automation** with a focused 6-week implementation effort. The foundational work — Sentinel KQL functions, watchlist configuration, and the initial Logic App — is already in place and functioning. The remaining gaps are well-defined, technically solvable, and low in risk.

### Key Findings

| Finding | Detail |
|---|---|
| **60% already automated** | Steps 1–5 of the 8-step workflow are automated; only the CyberArk, comparison, and distribution steps remain manual |
| **Low implementation risk** | Existing PowerShell scripts can be directly migrated to Azure Functions with minimal rewrite |
| **Minimal cost** | Full automation costs approximately $25–$55/month in Azure consumption — a strong ROI against ~2 hours/day of manual SecOps effort |
| **Quick win available** | CyberArk API integration (GAP-01) is the highest-impact single change and can be delivered in Week 1–2 independently |
| **Security-first design** | Managed identities, Key Vault, and least-privilege RBAC ensure the automated pipeline meets enterprise security standards |

### Recommended Approach

The **Hybrid Logic App + Azure Function** architecture (Option 6) is the recommended path forward. This approach:

- Preserves the existing Logic App investment and extends it
- Moves the PowerShell comparison logic to a managed, serverless Azure Function
- Introduces CyberArk REST API automation to eliminate the most critical manual dependency
- Delivers real-time visibility via Power BI and Sentinel Workbook
- Achieves full zero-touch automation by end of Week 6

### Business Impact

Upon completion, the Security Operations team will benefit from:

- ⏱️ **~2 hours/day** of manual effort eliminated — equivalent to ~40 hours/month returned to the team
- 📊 **Daily reports delivered by 6:30 AM** regardless of staff availability, leave, or incidents
- 🎯 **99.9% execution reliability** backed by Azure SLA vs. ~80% manual consistency today
- 🔍 **Full audit trail** across all check executions, data pulls, and report distributions
- 📈 **Historical trending** enabling compliance reporting and pattern analysis over time
- 🚨 **Proactive alerting** when checks fail — issues caught within minutes, not the next morning

### Final Recommendation

Approve this discovery report and proceed to **Phase 1 – Foundations** immediately. The two critical pre-work items (CyberArk API access confirmation and Azure RBAC request) should be initiated in **Week 0** to avoid blocking the technical delivery phases.

---

*Daily Checks Automation – Discovery Report | Version 1.0 | April 9, 2026 | Internal – Confidential*
