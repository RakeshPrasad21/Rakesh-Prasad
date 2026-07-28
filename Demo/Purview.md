# Microsoft Purview Classification & Labeling Framework
## Kuwait/GCC Implementation Guide

**Document Version:** 2.1  
**Last Updated:** July 27, 2026  
**Status:** Aligned with Client Four-Tier Classification Policy (CITRA Resolution 26/2024, NCSC Decisions 1&2/2025-2026)  
**Implementation Phase:** Week 3 - Classification, SITs, and Label Design  

---

## Table of Contents

1. [Data Classification Matrix (Kuwait/GCC)](#1-data-classification-matrix-kuwaitgcc)
   - [1.0 Classification Taxonomy & Policy Alignment](#10-classification-taxonomy--policy-alignment)
   - [1.1 Sensitivity Level Definitions](#11-sensitivity-level-definitions)
   - [1.2 Kuwait/GCC-Specific Handling Rules Matrix](#12-kuwaitgcc-specific-handling-rules-matrix)
   - [1.3 Kuwait/GCC Recommended Compliance Mapping](#13-kuwaitgcc-recommended-compliance-mapping)
   - [1.4 GCC-Specific Data Protection Considerations](#14-gcc-specific-data-protection-considerations)
2. [Sensitive Information Type (SIT) Inventory](#2-sensitive-information-type-sit-inventory)
   - [2.1 Microsoft Built-in SITs (Verified July 2026)](#21-microsoft-built-in-sits-verified-july-2026)
   - [2.1.1 Non-Existent Built-in Sensitive Information Types](#211-non-existent-built-in-sensitive-information-types-client-verification-required)
   - [2.2 Custom SITs Required for Kuwait](#22-custom-sits-required-for-kuwait)
   - [2.3 Department-Specific SIT Mapping](#23-department-specific-sit-mapping)
3. [Sensitivity Label Framework Design](#3-sensitivity-label-framework-design)
   - [3.1 Label Design Overview](#31-label-design-overview-fact-checked-microsoft-purview-july-2026)
   - [3.2 Kuwait/GCC Sensitivity Label Hierarchy](#32-kuwaitgcc-sensitivity-label-hierarchy)
   - [3.2.1 Client Recommended Label Architecture](#321-client-recommended-label-architecture-per-policy)
   - [3.3 Detailed Label Configuration](#33-detailed-label-configuration)
4. [Implementation Roadmap](#4-implementation-roadmap)
5. [References](#5-references)

---

## 1. Data Classification Matrix (Kuwait/GCC)

> **🔔 CRITICAL POLICY ALIGNMENT NOTICE**
> 
> This implementation follows the client's **mandated four-tier classification framework**, not the typical five-tier approach. Key differences:
> 
> - **Four Tiers**: Public, Internal, Confidential, Restricted (no "Highly Confidential" tier)
> - **Tier 2 Default**: "Internal" is mandatory default for all new content
> - **PII at Tier 3**: Personal Identifiable Information is classified as Confidential, not Restricted
> - **Tier 4 Focus**: Reserved for trade secrets, strategic pricing, M&A, formulations
> - **Regulatory Anchors**: CITRA Resolution 26/2024; NCSC Decisions (1)/2025 & (2)/2026
> 
> All label designs, auto-labeling policies, and DLP configurations in this document align with this four-tier structure.

---

### 1.0 Classification Taxonomy & Policy Alignment

#### **Client Policy Overview (Mandated Classification Framework)**

| Dimension | Policy Details |
|-----------|----------------|
| **Tier count** | Four — Tier 1 Public, Tier 2 Internal, Tier 3 Confidential, Tier 4 Restricted |
| **Meaning of top tier** | Recipes, formulations, ingredient ratios, trade secrets, M&A, strategic pricing and margin data |
| **Placement of PII** | Tier 3 Confidential |
| **"Highly Confidential"** | Does not exist in the policy |
| **Default classification** | Tier 2 Internal, mandatory default for all new documents and emails |
| **Regulatory anchor** | CITRA Resolution 26/2024; NCSC Decision (1)/2025; NCSC Decision (2)/2026 |
| **Trade-secret coverage** | Tier 4 is defined principally by it |

> **⚠️ IMPORTANT NOTE:** The client's mandated policy defines **four tiers**, not five. The "Highly Confidential" tier referenced in earlier drafts **does not exist** in the official policy. This document has been updated to align with the client's **four-tier framework** (Public, Internal, Confidential, Restricted) while maintaining backwards compatibility with Microsoft Purview best practices.

---

### 1.1 Sensitivity Level Definitions

| Sensitivity Level | Description | Business Impact if Disclosed | GCC Regulatory Impact | Label Color (Microsoft Standard) |
|-------------------|-------------|------------------------------|----------------------|----------------------------------|
| **Tier 1: Public** | Information intended for public consumption | None - already public | None | Green |
| **Tier 2: Internal** | General business information for internal use (mandatory default) | Low - minor business disruption | None | Yellow |
| **Tier 3: Confidential** | Business-sensitive information requiring protection, including PII | Moderate - competitive disadvantage, reputation damage | Kuwait Cyberlaw 63/2015 violation, CITRA Resolution 26/2024 | Orange |
| **Tier 4: Restricted** | Trade secrets, strategic financial data, M&A, formulations requiring strictest controls | Severe - criminal liability, regulatory sanctions, competitive harm | Criminal penalties under Kuwait law, GCC regulatory action, NCSC Decisions (1)/2025 & (2)/2026 | Dark Red |

---

### 1.2 Kuwait/GCC-Specific Handling Rules Matrix

#### **Tier 4: RESTRICTED (Trade Secrets, Strategic Data)**

| Control Category | Handling Rule | Microsoft Purview / Microsoft 365 Implementation |
|------------------|---------------|--------------------------------------------------|
| **Access Controls** | Access limited to explicitly authorized personnel (R&D, OT, Finance leadership). | Microsoft Entra ID, MFA, Conditional Access, RBAC, and Privileged Identity Management (where available). |
| **Encryption** | Mandatory encryption for all files and communications. Double Key Encryption candidate for Trade Secrets. | Microsoft Purview Information Protection, Microsoft Purview Message Encryption, Azure Rights Management, DKE for Trade Secrets. |
| **Storage** | Store only in approved Microsoft 365 or Azure storage locations. | SharePoint Online, OneDrive, Exchange Online, or approved Azure Storage. |
| **Retention** | Retain according to legal, regulatory, and business requirements. | Microsoft Purview Retention Labels, Retention Policies, and Records Management. |
| **DLP Actions** | Block unauthorized sharing, printing, and EXTRACT functions. Generate high-priority incidents. | Microsoft Purview DLP with blocking, incident reporting, and Security/Compliance notifications. |
| **Labeling** | Mandatory labeling for trade secrets, strategic pricing, M&A data, formulations. | Mandatory Sensitivity Labels with auto-labeling via fingerprints, custom SITs, site defaults. |
| **Collaboration** | Collaboration limited to explicitly authorized users (named groups only). External sharing prohibited. | Teams, SharePoint, OneDrive with Sensitivity Labels, Conditional Access, and restricted sharing policies. |
| **Email Protection** | Encrypt all email communications. External sharing blocked. | Microsoft Purview Message Encryption (OME) and Sensitivity Labels with Do Not Forward. |
| **Cross-Border Sharing** | Prohibited unless explicitly approved by executive leadership and legal. | DLP, Sensitivity Labels, Conditional Access, Information Protection. |
| **Audit Logging** | Comprehensive audit logging and monitoring. | Microsoft Purview Audit Premium and Microsoft Defender XDR (where licensed). |
| **Disposal** | Secure disposition after retention period with C-level approval required. | Microsoft Purview Records Management and Disposition Review. |

---

#### **Tier 3: CONFIDENTIAL (Business-Sensitive, PII)**

| Control Category | Handling Rule | Microsoft Purview / Microsoft 365 Implementation |
|------------------|---------------|--------------------------------------------------|
| **Access Controls** | Access restricted to authorized users based on business role. | Microsoft Entra ID RBAC, MFA, and Conditional Access. |
| **Encryption** | Encrypt sensitive documents and emails. Encryption mandatory for PII. All employees have access (or guest-scoped for External Approved). | Microsoft Purview Sensitivity Labels with encryption and Microsoft Purview Message Encryption (OME). |
| **Storage** | Store only in approved Microsoft 365 locations. | SharePoint Online, OneDrive for Business, Exchange Online. |
| **Retention** | Retain information according to legal, regulatory, and business requirements (10 years for PII per Kuwait Labor Law). | Microsoft Purview Retention Labels and Retention Policies. |
| **DLP Actions** | Notify users of policy violations and generate alerts for review. Block external sharing for Internal Only sublabel. | Microsoft Purview DLP with Policy Tips, user notifications, audit logging, and incident reporting. |
| **Labeling** | Mandatory for confidential business information and PII where defined by policy. | Manual or auto-labeling using Microsoft Purview Sensitivity Labels. SITs (PII, financial), trainable classifiers, container defaults. |
| **Collaboration** | Internal collaboration permitted (All Employees sublabel). External sharing restricted to External Approved sublabel with guest-scoped rights. Internal Only blocks external sharing. | Teams, SharePoint Online, OneDrive protected with Sensitivity Labels and Conditional Access. |
| **Email Protection** | Encrypt confidential emails where appropriate. Do Not Forward for Internal Only sublabel. | Microsoft Purview Message Encryption (OME). |
| **Cross-Border Sharing** | Governed by organizational policy and applicable regulations (CITRA Resolution 26/2024). | DLP, Sensitivity Labels, Conditional Access. |
| **Audit Logging** | Record user activity and policy events. | Microsoft Purview Audit. |
| **Disposal** | Secure deletion after retention period. | Microsoft Purview Records Management. |

---

#### **Tier 2: INTERNAL** (Mandatory Default)

| Control Category | Handling Rule | Microsoft Purview / Microsoft 365 Implementation |
|------------------|---------------|--------------------------------------------------|
| **Access Controls** | Access permitted for all employees. | Microsoft Entra ID, standard authentication. |
| **Encryption** | Not required (optional for sensitive internal content). | Optional: Microsoft Purview Sensitivity Labels with encryption. |
| **Storage** | Store in approved Microsoft 365 locations. | SharePoint Online, OneDrive for Business, Exchange Online. |
| **Retention** | Retain according to business requirements. | Microsoft Purview Retention Labels and Retention Policies. |
| **DLP Actions** | Monitor for external sharing. Generate alerts for compliance review. | Microsoft Purview DLP with Policy Tips and user notifications. |
| **Labeling** | **Mandatory default for all new documents and emails** per organizational policy. | Automatically applied as default label in all label policies. |
| **Collaboration** | Internal collaboration permitted. External sharing discouraged (requires justification). | Teams, SharePoint Online, OneDrive with standard sharing policies. |
| **Email Protection** | Standard email protection. | Microsoft Purview Message Encryption (OME) available but not enforced. |
| **Cross-Border Sharing** | Governed by organizational policy. | DLP, Sensitivity Labels, Conditional Access. |
| **Audit Logging** | Record user activity and policy events. | Microsoft Purview Audit. |
| **Disposal** | Standard deletion after retention period. | Microsoft Purview Records Management. |

---

#### **Tier 1: PUBLIC**

| Control Category | Handling Rule | Microsoft Purview / Microsoft 365 Implementation |
|------------------|---------------|--------------------------------------------------|
| **Access Controls** | No restrictions. Available for public consumption. | Standard Microsoft 365 sharing. |
| **Encryption** | Not required. | Not applicable. |
| **Storage** | No restrictions. | SharePoint Online, OneDrive, Exchange Online, public-facing websites. |
| **Retention** | Retain according to business requirements. | Microsoft Purview Retention Labels and Retention Policies. |
| **DLP Actions** | None. | Not applicable. |
| **Labeling** | Manual application only. Used for marketing materials, press releases, public announcements. | Manual labeling in Office apps. |
| **Collaboration** | Unrestricted. Can be shared externally without approval. | Standard Microsoft 365 sharing and collaboration features. |
| **Email Protection** | Not required. | Not applicable. |
| **Cross-Border Sharing** | No restrictions. | No restrictions. |
| **Audit Logging** | Record user activity (standard level). | Microsoft Purview Audit. |
| **Disposal** | Standard deletion after retention period. | Microsoft Purview Records Management. |

---

### 1.3 Kuwait/GCC Recommended Compliance Mapping

| Sensitivity Level | GCC/Kuwait Regulations | Compliance Controls | Audit Frequency |
|-------------------|------------------------|---------------------|-----------------|
| **Tier 4: Restricted** | CITRA Resolution 26/2024, NCSC Decision (1)/2025, NCSC Decision (2)/2026, Kuwait Cybercrime Law No. 63/2015, sector-specific regulations (e.g., CBK, Ministry of Health), internal security policies | AES-256 encryption (DKE for Trade Secrets), MFA, Conditional Access, Microsoft Purview Sensitivity Labels, DLP (block forward/print/extract), audit logging, named-group access controls, fingerprints, site defaults | Continuous monitoring + Quarterly review |
| **Tier 3: Confidential** | CITRA Resolution 26/2024, Kuwait Cyberlaw 63/2015 (for PII), Kuwait Labor Law 6/2010 (10-year PII retention), commercial agreements, contractual confidentiality obligations, internal information security policy | Encryption (mandatory for PII), MFA, role-based access, Purview labels, DLP (block for Internal Only), SITs (PII, financial), trainable classifiers, retention policies (10 years for PII), access reviews | Quarterly (Semi-annual for non-PII) |
| **Tier 2: Internal** | Corporate governance policies, CITRA general cybersecurity controls | Standard Microsoft 365 security controls, access permissions, baseline monitoring, DLP alerting (not blocking) | Annual |
| **Tier 1: Public** | No specific regulatory restrictions | Standard publication approval process | As required |

**Regulatory Anchor Notes:**

- **CITRA Resolution 26/2024**: Communications and Information Technology Regulatory Authority cybersecurity framework for Kuwait
- **NCSC Decision (1)/2025 and (2)/2026**: National Cybersecurity Council decisions governing data classification and protection
- **Kuwait Cyberlaw 63/2015**: Criminal penalties for unauthorized access, data breaches, and cybersecurity violations
- **Kuwait Labor Law 6/2010**: 10-year mandatory retention for employee records, contracts, and termination documents

---

### 1.4 GCC-Specific Data Protection Considerations

#### **1.4.1 Data Sovereignty Requirements**

✅ **Kuwait Cybersecurity Law 63/2015**: Requires government data and critical infrastructure data to remain in Kuwait  
✅ **Recommended Azure Regions**:
- Primary: UAE North (Dubai)
- Secondary: UAE Central (Abu Dhabi) or Qatar Central
- Consider: Kuwait cloud providers for government sector

#### **1.4.2 Labor Law Compliance (Law 6/2010)**

✅ **Mandatory 10-year retention**: Employee records, contracts, termination documents  
✅ **Work permit tracking**: Integration with PAM (Public Authority for Manpower)  
✅ **Kafala system data**: Sponsor information, transfer tracking

#### **1.4.3 Islamic Finance Considerations**

✅ **Sharia-compliant data handling**: Separate handling for Islamic banking data  
✅ **Zakat calculations**: Sensitive financial data requiring special protection  
✅ **Islamic calendar**: Date handling for Hijri calendar dates

#### **1.4.4 GCC Mobility**

✅ **GCC National ID recognition**: All 6 GCC country IDs (KSA, UAE, Qatar, Bahrain, Oman, Kuwait)  
✅ **Cross-border data sharing**: Within GCC with proper controls  
✅ **Regional compliance**: Harmonized approach across GCC operations

---

## 2. Sensitive Information Type (SIT) Inventory

### 2.1 Microsoft Built-in SITs (Verified July 2026)

| SIT Name | Microsoft Built-in | Kuwait/GCC Rationale |
|----------|--------------------|----------------------|
| U.A.E. Identity Card Number | ✅ Yes | UAE operations and GCC workforce |
| Saudi Arabia National ID | ✅ Yes | KSA operations and GCC workforce |
| Passport Number (All Countries) | ✅ Yes | Expat workforce identification and immigration documents |
| International Bank Account Number (IBAN) | ✅ Yes | GCC banking standard (KWD, SAR, AED, etc.) |
| SWIFT Code | ✅ Yes | International banking and cross-border payments |
| Credit Card Number | ✅ Yes | PCI-DSS compliance |
| Bank Account Number | ✅ Yes | Payroll, supplier payments, and banking operations |
| Email Address | ✅ Yes | Personal information under privacy requirements |
| Phone Number | ✅ Yes | Employee and customer contact information |
| Physical Address | ✅ Yes | Employee and customer residency information |
| Date of Birth | ✅ Yes | HR records and identity verification |
| IP Address (IPv4/IPv6) | ✅ Yes | Security monitoring, audit logs, and cybersecurity investigations |
| Azure Storage Account Key | ✅ Yes | Azure cloud infrastructure security |
| SQL Server Connection String | ✅ Yes | Database connection protection |
| Azure Subscription | ✅ Yes | Azure subscription and cloud resource management |
| General Symmetric Key | ✅ Yes | Encryption keys and application secrets |

## Notes

- This inventory contains **Microsoft Purview built-in Sensitive Information Types (SITs)** applicable to a Kuwait/GCC deployment.
- **Kuwait Civil ID** is **not currently available as a Microsoft built-in SIT** and should be implemented as a **Custom Sensitive Information Type** if detection is required.
- **Kuwait VAT Registration Number** is **not currently available as a Microsoft built-in SIT** and should be implemented as a **Custom Sensitive Information Type** if required.
- This list is based on the Microsoft Purview built-in SIT catalog available as of **July 2026**.

---

### 2.1.1 Non-Existent Built-in Sensitive Information Types (Client Verification Required)

The following SITs are listed in Phase 1 department tables as Microsoft built-in SITs but **are not present in the Purview catalogue** under these exact names. **Verification and catalogue position review required** before implementation:

| SIT Referenced | Catalogue Position | Tables Affected | Verification Action Required |
|----------------|-------------------|-----------------|------------------------------|
| **Passport Number (All Countries)** | No generic SIT exists. Passport SITs are country-scoped — U.S. Passport Number, U.K. Passport Number, Australia Passport Number, etc. each require separate verification. | HR, Legal, Management | ✅ Verify if country-scoped passports (U.S., U.K., Kuwait, etc.) meet requirements or create Custom SIT |
| **Email Address** | Not a built-in SIT | HR, Finance, IT, Legal, Marketing, Management | ⚠️ Create Custom SIT or use regex pattern in auto-labeling policies |
| **Phone Number** | Not a built-in SIT | HR, Finance, Legal, Marketing, Management | ⚠️ Create Custom SIT or use regex pattern |
| **Date of Birth** | Not a built-in SIT | HR, Marketing | ⚠️ Create Custom SIT or use regex pattern |
| **Bank Account Number** | No generic type. Country-specific SITs exist (e.g., U.S. Bank Account Number). Requires catalogue verification. | HR, Finance | ✅ Verify country-specific bank account SITs (U.S., Kuwait, UAE, KSA) or create Custom SIT |
| **Physical Address** | Not a built-in SIT | HR, Marketing | ⚠️ Create Custom SIT or use regex/keyword pattern |
| **Azure Subscription Key** | Named inconsistently across two tables: "Azure Subscription" and "Azure Subscription Key". Requires verification against current catalogue name. | IT, Management | ✅ Verify exact catalogue name (may be "Azure Subscription Key" or "Azure subscription secret") |
| **Azure Cosmos DB Key** | Catalogue name is "Azure Cosmos DB Account Key". | IT | ✅ Update references to use correct catalogue name: **Azure Cosmos DB Account Key** |
| **Azure Service Bus String** | Catalogue name is "Azure Service Bus Connection String". | IT | ✅ Update references to use correct catalogue name: **Azure Service Bus Connection String** |
| **Microsoft Entra Client Secret** | Historically "Azure AD Client Secret". Requires verification of current official name. | IT | ✅ Verify exact catalogue name post-rebrand (Azure AD → Microsoft Entra ID) |

**Action Items:**

1. **IT Admin / Purview Team**: Log into **Microsoft Purview Portal** → **Data Classification** → **Sensitive Info Types** → **All sensitive info types** and verify the exact names and availability of each SIT listed above.
2. **For missing SITs (Email, Phone, Date of Birth, Physical Address)**: Create **Custom Sensitive Information Types** with appropriate regex patterns and keywords.
3. **For naming mismatches (Azure Cosmos DB, Service Bus, Entra)**: Update all references in department SIT tables (Section 2.3) to use the exact catalogue name.
4. **For country-scoped SITs (Passport, Bank Account)**: Determine which countries are in scope for Kuwait/GCC operations and verify availability of those specific SITs.

**Microsoft Documentation References:**
- [Sensitive information type entity definitions - Microsoft Purview](https://learn.microsoft.com/en-us/purview/sit-sensitive-information-type-entity-definitions)
- [Named entities](https://learn.microsoft.com/en-us/purview/sit-get-started-exact-data-match-create-schema#named-entities)

---

### 2.2 Custom SITs Required for Kuwait

**⚠️ PRIORITY CUSTOM SITs (Not in Microsoft Built-in Library) - Must Create:**

| # | SIT Name | Format/Pattern | Confidence Level | Departments Using | Priority |
|---|----------|----------------|------------------|-------------------|----------|
| 1 | **Kuwait Civil ID Number** | 12 digits: YYMMDDSSSSSR (Birthdate + Sequence + Checksum) | High (85%) | HR, Finance, Legal, Management, Marketing | **CRITICAL** |
| 2 | **Kuwait Work Permit Number** | Variable (MOI issued) - Pattern TBD | High (80%) | HR, Legal | **HIGH** |
| 3 | **Kuwait Labor File Number** | PAM system format - Pattern TBD | High (80%) | HR | **HIGH** |
| 4 | **Kuwait Trade License Number** | MOC format - Pattern TBD | Medium (75%) | Finance, Legal | **MEDIUM** |
| 5 | **Kuwait Sponsor/Employer ID** | Variable format | Medium (75%) | HR | **MEDIUM** |

**Custom SIT Creation Example (Kuwait Civil ID):**

```xml
<Entity id="kuwait-civil-id" patternsProximity="300" recommendedConfidence="85">
  <Pattern confidenceLevel="85">
    <IdMatch idRef="Regex_kuwait_civil_id" />
    <Match idRef="Keyword_kuwait_civil_id" />
  </Pattern>
  <Pattern confidenceLevel="75">
    <IdMatch idRef="Regex_kuwait_civil_id" />
  </Pattern>
</Entity>

<!-- Regex Pattern -->
Regex_kuwait_civil_id: \b[0-9]{2}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])[0-9]{4}[0-9]\b

<!-- Keywords -->
Keyword_kuwait_civil_id: Civil ID, رقم مدني, بطاقة مدنية, Kuwait ID, PACI number
```

---

### 2.3 Department-Specific SIT Mapping

#### **HR DEPARTMENT (10 SITs)**

| # | SIT Name | Sensitivity Level | GCC/Kuwait Justification | Priority |
|---|----------|-------------------|--------------------------|----------|
| 1 | Kuwait Civil ID Number *(Custom SIT)* | **Confidential** | Primary national identification for employees and residents in Kuwait (PII - Tier 3 per policy) | High |
| 2 | Work Permit / Residency Number *(Custom SIT)* | **Confidential** | Residency and employment authorization for expatriate workforce (PII - Tier 3 per policy) | High |
| 3 | Passport Number *(Built-in)* | **Confidential** | Employee identity verification, immigration, and international travel (PII - Tier 3 per policy) | High |
| 4 | Date of Birth *(Built-in)* | **Confidential** | Employee records and identity verification (PII - Tier 3 per policy) | Medium |
| 5 | U.A.E. Identity Card Number / Saudi Arabia National ID *(Built-in)* | **Confidential** | Identification of GCC nationals employed in Kuwait (PII - Tier 3 per policy) | High |
| 6 | International Bank Account Number (IBAN) *(Built-in)* | **Restricted** | Payroll processing and salary transfers (Financial data - Tier 4) | High |
| 7 | Phone Number *(Built-in)* | **Confidential** | Employee contact information and emergency contacts (PII - Tier 3 per policy) | Low |
| 8 | Email Address *(Built-in)* | **Confidential** | Employee communications and business correspondence (PII - Tier 3 per policy) | Low |
| 9 | Physical Address *(Built-in)* | **Confidential** | Residency verification and employee records (PII - Tier 3 per policy) | Medium |
| 10 | Labor File Number *(Custom SIT)* | **Confidential** | Kuwait Public Authority for Manpower (PAM) employment records (PII/HR records - Tier 3) | High |

> **Note:** Kuwait Civil ID Number, Work Permit/Residency Number, and Labor File Number are **not currently available as Microsoft Purview built-in Sensitive Information Types (SITs)** and should be implemented as **Custom SITs** if detection is required. U.A.E. Identity Card Number and Saudi Arabia National ID are available as Microsoft Purview built-in SITs.
#### **FINANCE DEPARTMENT (10 SITs)**

| # | SIT Name | Sensitivity Level | GCC/Kuwait Justification | Priority |
|---|----------|-------------------|--------------------------|----------|
| 1 | Credit Card Number *(Built-in)* | **Restricted** | PCI-DSS compliance for payment card data (Financial - Tier 4) | High |
| 2 | International Bank Account Number (IBAN) *(Built-in)* | **Restricted** | GCC banking standard for salary, vendor, and international payments (Financial - Tier 4) | High |
| 3 | SWIFT Code *(Built-in)* | **Restricted** | International payment processing and cross-border banking (Strategic Financial - Tier 4) | Medium |
| 4 | Kuwait Civil ID *(Custom SIT)* | **Confidential** | Customer and vendor identification for Kuwait operations (PII - Tier 3 per policy) | High |
| 5 | Trade License Number *(Custom SIT)* | **Confidential** | Vendor registration and commercial licensing compliance (Business info - Tier 3) | Medium |
| 6 | Tax Registration Number *(Custom SIT)* | **Confidential** | VAT and corporate tax compliance requirements (Business info - Tier 3) | Medium |
| 7 | Email Address *(Built-in)* | **Confidential** | Invoice communication and customer/vendor correspondence (PII - Tier 3 per policy) | Low |
| 8 | Phone Number *(Built-in)* | **Confidential** | Customer contact and payment confirmation (PII - Tier 3 per policy) | Low |
| 9 | IP Address (IPv4/IPv6) *(Built-in)* | **Confidential** | Security monitoring, audit logging, and CBK/CITRA compliance (Technical data - Tier 3) | Low |
| 10 | U.A.E. Identity Card Number / Saudi Arabia National ID *(Built-in)* | **Confidential** | GCC regional customer and employee identification (PII - Tier 3 per policy) | Medium |

> **Note:** Kuwait Civil ID, Trade License Number, and Kuwait Tax Registration Number are **not currently available as Microsoft Purview built-in Sensitive Information Types (SITs)** and should be implemented as **Custom SITs** if detection is required.

#### **IT DEPARTMENT (10 SITs)**

| # | SIT Name | Sensitivity Level | GCC/Kuwait Justification | Priority |
|---|----------|-------------------|-------------------------|----------|
| 1 | Azure Storage Account Key *(Built-in)* | **Restricted** | Cloud infrastructure protection required under CITRA cybersecurity regulations (Critical Infrastructure - Tier 4) | **High** |
| 2 | SQL Server Connection String *(Built-in)* | **Restricted** | Database security and data protection for business-critical systems (Critical Infrastructure - Tier 4) | **High** |
| 3 | Azure Subscription Key *(Built-in)* | **Restricted** | Cloud resource management and Azure tenant security (Critical Infrastructure - Tier 4) | **High** |
| 4 | General Symmetric Key *(Built-in)* | **Restricted** | Encryption keys for data protection under Kuwait Cyberlaw 63/2015 (Critical Infrastructure - Tier 4) | **High** |
| 5 | IP Address (IPv4/IPv6) *(Built-in)* | **Confidential** | Network monitoring, security incident investigation, and CITRA audit compliance (Technical data - Tier 3) | **Medium** |
| 6 | Email Address *(Built-in)* | **Confidential** | IT user accounts and system access management (PII - Tier 3 per policy) | **Low** |
| 7 | Azure Cosmos DB Key *(Built-in)* | **Restricted** | NoSQL database credentials and API access control (Critical Infrastructure - Tier 4) | **Medium** |
| 8 | Azure IoT Connection String *(Built-in)* | **Restricted** | IoT device management and industrial control systems (Critical Infrastructure - Tier 4) | **Low** |
| 9 | Azure Service Bus Connection String *(Built-in)* | **Restricted** | Enterprise integration and message queue security (Critical Infrastructure - Tier 4) | **Low** |
| 10 | Microsoft Entra Client Secret *(Built-in)* | **Restricted** | Identity and access management, single sign-on, and authentication (Critical Infrastructure - Tier 4) | **High** |

> **Note:** All Azure-related SITs are critical for CITRA (Communications and Information Technology Regulatory Authority) compliance and Kuwait cybersecurity regulatory requirements.

---

#### **LEGAL DEPARTMENT (10 SITs)**

| # | SIT Name | Sensitivity Level | GCC/Kuwait Justification | Priority |
|---|----------|-------------------|--------------------------|----------|
| 1 | Kuwait Civil ID Number *(Custom SIT)* | **Confidential** | Client identification for legal proceedings, contract management, and regulatory compliance (PII - Tier 3 per policy) | High |
| 2 | Passport Number *(Built-in)* | **Confidential** | Immigration cases, visa documentation, and expatriate legal matters (PII - Tier 3 per policy) | High |
| 3 | Work Permit / Residency Number *(Custom SIT)* | **Confidential** | Employment law compliance, labor disputes, and residency verification (PII - Tier 3 per policy) | High |
| 4 | International Bank Account Number (IBAN) *(Built-in)* | **Restricted** | Financial dispute resolution, settlements, and contract payment verification (Financial - Tier 4) | High |
| 5 | Trade License Number *(Custom SIT)* | **Confidential** | Commercial registration, corporate legal compliance, licensing, and due diligence (Business info - Tier 3) | High |
| 6 | Kuwait Tax Registration Number *(Custom SIT)* | **Confidential** | Tax compliance, regulatory matters, and financial dispute documentation (Business info - Tier 3) | Medium |
| 7 | Credit Card Number *(Built-in)* | **Restricted** | Payment disputes, fraud investigations, and litigation evidence (Financial - Tier 4) | Medium |
| 8 | U.A.E. Identity Card Number / Saudi Arabia National ID *(Built-in)* | **Confidential** | GCC cross-border legal matters and regional contract management (PII - Tier 3 per policy) | High |
| 9 | Email Address *(Built-in)* | **Confidential** | Legal correspondence, client communications, eDiscovery, and litigation records (PII - Tier 3 per policy) | Medium |
| 10 | Phone Number *(Built-in)* | **Confidential** | Client, witness, and external legal communications (PII - Tier 3 per policy) | Low |

> **Note:** Kuwait Civil ID Number, Work Permit/Residency Number, Trade License Number, and Kuwait Tax Registration Number are **not currently available as Microsoft Purview built-in Sensitive Information Types (SITs)** and should be implemented as **Custom SITs** if detection is required. U.A.E. Identity Card Number and Saudi Arabia National ID are supported as Microsoft Purview built-in SITs.


---

#### **MARKETING DEPARTMENT (10 SITs)**

| # | SIT Name | Sensitivity Level | GCC/Kuwait Justification | Priority |
|---|----------|-------------------|--------------------------|----------|
| 1 | Email Address *(Built-in)* | **Confidential** | Customer databases, marketing campaigns, CRM systems, and customer communications (PII - Tier 3 per policy) | High |
| 2 | Phone Number *(Built-in)* | **Confidential** | Customer contact lists, SMS campaigns, and telemarketing activities (PII - Tier 3 per policy) | High |
| 3 | Physical Address *(Built-in)* | **Confidential** | Customer mailing lists, direct marketing campaigns, and delivery information (PII - Tier 3 per policy) | Medium |
| 4 | Kuwait Civil ID Number *(Custom SIT)* | **Confidential** | Customer identity verification for loyalty programs or regulated promotional activities (PII - Tier 3 per policy) | Low |
| 5 | Credit Card Number *(Built-in)* | **Restricted** | E-commerce transactions, promotional purchases, and customer payment processing (Financial - Tier 4) | High |
| 6 | International Bank Account Number (IBAN) *(Built-in)* | **Restricted** | Customer refunds, promotional payments, and financial transactions (Financial - Tier 4) | Medium |
| 7 | IP Address (IPv4/IPv6) *(Built-in)* | **Confidential** | Website analytics, digital marketing, fraud detection, and security monitoring (Technical data - Tier 3) | Low |
| 8 | Date of Birth *(Built-in)* | **Confidential** | Customer profiles, age verification, and personalized marketing campaigns (PII - Tier 3 per policy) | Medium |
| 9 | U.A.E. Identity Card Number / Saudi Arabia National ID *(Built-in)* | **Confidential** | GCC regional customer identification for cross-border marketing initiatives (PII - Tier 3 per policy) | Medium |
| 10 | Trade License Number *(Custom SIT)* | **Confidential** | B2B marketing, corporate customer onboarding, and business relationship management (Business info - Tier 3) | Medium |

> **Note:** Kuwait Civil ID Number and Trade License Number are **not currently available as Microsoft Purview built-in Sensitive Information Types (SITs)** and should be implemented as **Custom SITs** if detection is required. U.A.E. Identity Card Number and Saudi Arabia National ID are supported as Microsoft Purview built-in SITs.
---

#### **MANAGEMENT DEPARTMENT (10 SITs)**

| # | SIT Name | Sensitivity Level | GCC/Kuwait Justification | Priority |
|---|----------|-------------------|--------------------------|----------|
| 1 | Kuwait Civil ID Number *(Custom SIT)* | **Confidential** | Executive identity verification, board member records, and senior management documentation (PII - Tier 3 per policy) | High |
| 2 | Passport Number *(Built-in)* | **Confidential** | Executive travel, visa processing, and international business documentation (PII - Tier 3 per policy) | High |
| 3 | International Bank Account Number (IBAN) *(Built-in)* | **Restricted** | Executive compensation, payroll, bonus payments, and financial transactions (Strategic Financial - Tier 4) | High |
| 4 | Credit Card Number *(Built-in)* | **Restricted** | Corporate card management, executive travel expenses, and payment processing (Financial - Tier 4) | Medium |
| 5 | SWIFT Code *(Built-in)* | **Restricted** | International banking transactions, treasury operations, and strategic financial activities (Strategic Financial - Tier 4) | Medium |
| 6 | Email Address *(Built-in)* | **Confidential** | Executive communications, board correspondence, and corporate governance records (PII - Tier 3 per policy) | High |
| 7 | Phone Number *(Built-in)* | **Confidential** | Executive contact information, emergency communications, and management directories (PII - Tier 3 per policy) | Medium |
| 8 | U.A.E. Identity Card Number / Saudi Arabia National ID *(Built-in)* | **Confidential** | GCC executive recruitment, regional partnerships, and board member identification (PII - Tier 3 per policy) | Medium |
| 9 | Azure Subscription Key *(Built-in)* | **Restricted** | Cloud administration, strategic IT governance, and executive oversight of cloud resources (Critical Infrastructure - Tier 4) | Medium |
| 10 | Trade License Number *(Custom SIT)* | **Confidential** | Corporate governance, subsidiary management, regulatory filings, and business entity oversight (Business info - Tier 3) | Medium |

> **Note:** Kuwait Civil ID Number and Trade License Number are **not currently available as Microsoft Purview built-in Sensitive Information Types (SITs)** and should be implemented as **Custom SITs** if detection is required. U.A.E. Identity Card Number and Saudi Arabia National ID are supported as Microsoft Purview built-in SITs.
---

## 3. Sensitivity Label Framework Design

### 3.1 Label Design Overview (Fact-Checked: Microsoft Purview July 2026)

Microsoft Purview sensitivity labels consist of:

1. **Label Details** (Name, Display name, Priority, Descriptions, Color)
2. **Scope** (Items, Emails, Groups & Sites, Meetings)
3. **Protection Settings** (Encryption, Content Marking, Auto-labeling)
4. **Policy Settings** (Who sees labels, Default labels, Mandatory labeling)

**Reference:** [Microsoft Learn - Create and configure sensitivity labels](https://learn.microsoft.com/en-us/purview/create-sensitivity-labels) (Updated June 2026)

---

### 3.2 Kuwait/GCC Sensitivity Label Hierarchy

#### **Label Hierarchy Design (Client Four-Tier Policy Aligned)**

```
📁 Tier 1: Public
📁 Tier 2: Internal (Mandatory Default)
📁 Tier 3: Confidential (includes PII per policy)
   └─ Confidential \ All Employees
   └─ Confidential \ Internal Only
   └─ Confidential \ External Approved
📁 Tier 4: Restricted (Trade Secrets, Strategic Data)
   └─ Restricted \ Trade Secret
   └─ Restricted \ Strategic Financial
```

**Policy Alignment Notes:**

- **Four Tiers Only**: This hierarchy aligns with the client's mandated four-tier classification framework (CITRA Resolution 26/2024; NCSC Decisions 1/2025 & 2/2026)
- **Tier 2 Default**: "Internal" is the **mandatory default label** for all new documents and emails
- **Tier 3 PII Placement**: Per client policy, **PII is classified as Tier 3 Confidential**, not Tier 4 Restricted
- **Tier 4 Trade Secrets**: Tier 4 is **principally defined by trade secret coverage** (recipes, formulations, ingredient ratios, M&A, strategic pricing)
- **Sublabels**: Client-recommended sublabels provide granular protection for internal-only vs. external-approved sharing (Tier 3), and trade secrets vs. strategic financial data (Tier 4)

**Note on Modern Label Scheme:** Microsoft introduced the "Modern label scheme" (October 2025+) which replaces parent labels with **Label Groups**. If your tenant was created after October 1, 2025, or manually migrated, you'll see Label Groups instead of parent/sublabels. Both approaches are functionally equivalent for protection.

**Reference:** [Microsoft Learn - Modern label scheme vs Classic](https://learn.microsoft.com/en-us/purview/migrate-sensitivity-label-scheme)

---

### 3.2.1 Client Recommended Label Architecture (Per Policy)

The following table reflects the client's mandated four-tier classification framework with recommended Microsoft Purview implementation approach:

| Tier | Label | Protection | Primary Detection Method |
|------|-------|------------|-------------------------|
| **Tier 1** | Public | None; content marking only | Manual application only |
| **Tier 2** | Internal | None | Default label per policy |
| **Tier 3** | Confidential | Encrypt; all employees; EX\|REACT withheld from guests | SITs (PII, financial), trainable classifiers, container defaults |
| **Tier 3** | Confidential \ Internal Only | Encrypt; Do Not Forward | Manual; mail flow rules |
| **Tier 3** | Confidential \ External Approved | Encrypt; guest-scoped rights | Manual |
| **Tier 4** | Restricted | Encrypt; named groups only; no forward, print or EXTRACT | Fingerprints, custom SITs, site defaults, manual |
| **Tier 4** | Restricted \ Trade Secret | Double Key Encryption candidate | R&D and OT owned; fingerprints and site defaults |
| **Tier 4** | Restricted \ Strategic Financial | Encrypt; Finance leadership group | Finance owned; classifiers and manual |

**Key Implementation Notes:**

- **Tier 2 (Internal)** is the **mandatory default** for all new documents and emails per organizational policy
- **Tier 3 (Confidential)** is where **PII is placed** according to the policy (not Restricted as suggested in some frameworks)
- **Tier 4 (Restricted)** is reserved for **trade secrets, strategic pricing, M&A, formulations** — the most sensitive business data
- **Tier 4 sublabels** provide granular control for Trade Secrets (R&D/OT ownership) and Strategic Financial data (Finance leadership)
- **"Highly Confidential" tier does not exist** in the mandated policy and should not be used

---

### 3.3 Detailed Label Configuration

#### **LABEL 1: PUBLIC**

**Label Details:**
- **Name:** `Public`
- **Display Name:** `Public`
- **Description for Users:** "Information approved for public consumption. Can be shared externally without restriction."
- **Description for Admins:** "No protection. For marketing materials, press releases, public announcements."
- **Label Priority:** 1 (Lowest)
- **Label Color:** Green

**Scope:**
- ☑ Files & other data assets
- ☑ Emails
- ☐ Groups & sites
- ☐ Meetings

**Protection Settings for Items:**

**→ Choose protection settings:**
- ☐ Control access (Encryption) - **NOT ENABLED**
- ☐ Apply content marking - **NOT ENABLED**

**→ Auto-labeling for files and emails:**
- ☐ Automatically or recommend to label files and emails - **NOT ENABLED**

**→ Groups & Sites:**

This label's scope does not include **Groups & sites**, so no group/site protection settings are configured.

**Publishing Policy:**
- **Scope:** All users
- **Default Label:** None
- **Mandatory:** No
- **Justification Required:** No

---

#### **LABEL 2: INTERNAL**

**Label Details:**
- **Name:** `Internal`
- **Display Name:** `Internal`
- **Description for Users:** "Internal business information. For employees only. Do not share outside the organization."
- **Description for Admins:** "Internal-only documents. Basic DLP monitoring. No encryption."
- **Label Priority:** 2
- **Label Color:** Yellow

**Scope:**
- ☑ Files & other data assets
- ☑ Emails
- ☐ Groups & sites
- ☐ Meetings

**Protection Settings for Items:**

**→ Choose protection settings:**
- ☐ Control access (Encryption) - **NOT ENABLED**
- ☑ **Apply content marking** - **ENABLED**
  - **Header:** `INTERNAL - For Employees Only`
    - Font: Calibri, 11pt
    - Color: Gray
    - Align: Center
  - **Footer:** `${User.Name} | ${Event.DateTime}`
    - Font: Calibri, 9pt
    - Color: Gray
    - Align: Left
  - **Watermark:** ☐ NOT ENABLED

**→ Auto-labeling for files and emails:**
- ☐ Automatically or recommend to label - **NOT ENABLED** (manual only initially)

**→ Groups & Sites:**

This label's scope does not include **Groups & sites**, so no group/site protection settings are configured.

**Publishing Policy:**
- **Scope:** All users
- **Default Label for documents:** `Internal`
- **Mandatory:** No
- **Justification Required:** Yes (for lowering to Public)

---

#### **LABEL 3: CONFIDENTIAL**

**Label Details:**
- **Name:** `Confidential`
- **Display Name:** `Confidential`
- **Description for Users:** "Sensitive business information. Limited internal distribution. Encryption optional based on sublabel."
- **Description for Admins:** "Parent label for Confidential sublabels. Use sublabels for specific protections."
- **Label Priority:** 3
- **Label Color:** Orange

**Scope:**
- ☑ Files & other data assets
- ☑ Emails
- ☑ Groups & sites (for Teams/SharePoint sites)
- ☐ Meetings

**⚠️ Note:** This is a **parent label** (or **label group** in modern scheme). Users must select a sublabel.

**→ Groups & Sites:**

This is a **parent label** (or **label group** in modern scheme). Protection settings for groups and sites are typically configured at the sublabel level or directly on container resources. No specific group/site protection settings are defined at this parent label level.

**Sublabels:**

---

##### **SUBLABEL 3.1: Confidential \ All Employees**

**Label Details:**
- **Name:** `Confidential-All-Employees`
- **Display Name:** `Confidential \ All Employees`
- **Description for Users:** "Confidential content accessible to all employees. Encryption applied. Do not share externally."
- **Description for Admins:** "Encryption: All employees (tenant members). Content marking. Auto-labeling for emails/docs containing 'Confidential'."
- **Label Priority:** 3.1
- **Label Color:** Orange (inherited from parent)

**Scope:**
- ☑ Files & other data assets
- ☑ Emails
- ☐ Groups & sites
- ☐ Meetings

**Protection Settings for Items:**

**→ Choose protection settings:**
- ☑ **Control access (Encryption)** - **ENABLED**
  - **Assign permissions now** (Admin-defined)
  - **Users and Groups:**
    - ☑ Everyone in your organization (All tenant members)
    - ☐ Any authenticated users
    - ☐ Specific users/groups
  - **Permissions:** **Editor** (View, Edit, Copy, Print)
  - **User access expires:** **Never**
  - **Allow offline access:** **Only for a number of days = 7**
  - **Double Key Encryption:** ☐ NOT ENABLED
  - **Dynamic Watermarks:** ☐ NOT ENABLED

- ☑ **Apply content marking** - **ENABLED**
  - **Header:** `CONFIDENTIAL - Internal Only`
    - Font: Calibri, 12pt, Bold
    - Color: Orange
    - Align: Center
  - **Footer:** `Document Owner: ${User.Name} | Created: ${Event.DateTime}`
    - Font: Calibri, 9pt
    - Color: Gray
    - Align: Center
  - **Watermark:** `CONFIDENTIAL`
    - Font: Calibri, 48pt
    - Color: Light Orange (Semi-transparent)
    - Layout: Diagonal

**→ Auto-labeling for files and emails:**
- ☑ **Automatically or recommend to label files and emails** - **ENABLED**
  - **Mode:** Recommend (with customizable policy tip)
  - **Conditions:**
    - Content contains **at least 1 instance** of:
      - ✅ Email Address (Built-in SIT) - Confidence: Medium
      - ✅ Phone Number (Built-in SIT) - Confidence: Medium
      - ✅ Kuwait Trade License Number (Custom SIT) - Confidence: Medium
    - OR
    - Content contains **keywords:**
      - "Confidential", "سري", "For Internal Use", "Proprietary"

**→ Groups & Sites:**

This sublabel's scope does not include **Groups & sites** (configured at parent label level only), so no group/site protection settings are configured for this sublabel.

**Publishing Policy:**
- **Scope:** All users
- **Default Label:** None (user selects as needed)
- **Mandatory:** No
- **Justification Required:** Yes (for any label change)

---

##### **SUBLABEL 3.2: Confidential \ Internal Only**

**Label Details:**
- **Name:** `Confidential-Internal-Only`
- **Display Name:** `Confidential \ Internal Only`
- **Description for Users:** "Confidential content for internal use only. Do Not Forward protection enforced. Cannot be shared externally."
- **Description for Admins:** "Encryption with Do Not Forward. Manual application. Blocks external sharing via DLP."
- **Label Priority:** 3.2
- **Label Color:** Orange (inherited from parent)

**Scope:**
- ☑ Files & other data assets
- ☑ Emails
- ☐ Groups & sites
- ☐ Meetings

**Protection Settings for Items:**

**→ Choose protection settings:**
- ☑ **Control access (Encryption)** - **ENABLED**
  - **Assign permissions now** (Admin-defined)
  - **Users and Groups:**
    - ☑ Everyone in your organization (All tenant members)
  - **Permissions:** **Editor** (View, Edit, Copy, Print) + **Do Not Forward**
  - **User access expires:** **Never**
  - **Allow offline access:** **Only for a number of days = 7**
  - **Double Key Encryption:** ☐ NOT ENABLED
  - **Dynamic Watermarks:** ☐ NOT ENABLED

- ☑ **Apply content marking** - **ENABLED**
  - **Header:** `CONFIDENTIAL - INTERNAL ONLY | DO NOT FORWARD`
    - Font: Calibri, 12pt, Bold
    - Color: Orange
    - Align: Center
  - **Footer:** `Document Owner: ${User.Name} | Created: ${Event.DateTime} | Internal Use Only`
    - Font: Calibri, 9pt
    - Color: Gray
    - Align: Center
  - **Watermark:** `INTERNAL ONLY`
    - Font: Calibri, 48pt
    - Color: Orange (Semi-transparent)
    - Layout: Diagonal

**→ Auto-labeling for files and emails:**
- ☐ NOT ENABLED (manual application only, enforced via mail flow rules or user selection)

**DLP Policy (Linked to this Label):**
- **Name:** DLP-Confidential-Internal-Only-Protection
- **Locations:** Exchange, SharePoint, OneDrive, Teams, Devices
- **Conditions:** Content has label `Confidential \ Internal Only`
- **Actions:**
  - **Block external sharing** (hard block)
  - **Alert:** Compliance team (immediate)
  - **User notification:** "This document is marked Internal Only. External sharing is prohibited."

**→ Groups & Sites:**

This sublabel's scope does not include **Groups & sites**, so no group/site protection settings are configured.

**Publishing Policy:**
- **Scope:** All users
- **Default Label:** None (user selects as needed)
- **Mandatory:** No
- **Justification Required:** Yes (for any label change)

---

##### **SUBLABEL 3.3: Confidential \ External Approved**

**Label Details:**
- **Name:** `Confidential-External-Approved`
- **Display Name:** `Confidential \ External Approved`
- **Description for Users:** "Confidential content approved for sharing with specific external partners or guests. User must specify recipients."
- **Description for Admins:** "Guest-scoped encryption. User-defined permissions for external collaboration. Requires justification."
- **Label Priority:** 3.3
- **Label Color:** Orange (inherited from parent)

**Scope:**
- ☑ Files & other data assets
- ☑ Emails
- ☐ Groups & sites
- ☐ Meetings

**Protection Settings for Items:**

**→ Choose protection settings:**
- ☑ **Control access (Encryption)** - **ENABLED**
  - **Let users assign permissions when they apply the label** - **USER-DEFINED**
  - **In Outlook:**
    - ☑ Prompt users to specify permissions (Encrypt-Only or custom)
  - **In Word, PowerPoint, and Excel:**
    - ☑ Prompt users to specify permissions
    - Users can choose specific external people/groups and assign custom permissions (View, Edit, etc.)
  - **Guest-scoped rights:** ☑ ENABLED (guests receive limited permissions)

- ☑ **Apply content marking** - **ENABLED**
  - **Header:** `CONFIDENTIAL - EXTERNAL APPROVED | AUTHORIZED RECIPIENTS ONLY`
    - Font: Calibri, 12pt, Bold
    - Color: Orange
    - Align: Center
  - **Footer:** `Shared by: ${User.Name} | ${Event.DateTime} | External Distribution Approved`
    - Font: Calibri, 9pt
    - Color: Gray
    - Align: Center
  - **Watermark:** `CONFIDENTIAL`
    - Font: Calibri, 48pt
    - Color: Light Orange (Semi-transparent)
    - Layout: Diagonal

**→ Auto-labeling:**
- ☐ NOT ENABLED (user-defined labels cannot be auto-applied per Microsoft design)

**→ Groups & Sites:**

This sublabel's scope does not include **Groups & sites**, so no group/site protection settings are configured.

**Publishing Policy:**
- **Scope:** All users (with management approval workflow recommended)
- **Default Label:** None (manual selection with justification)
- **Mandatory:** No
- **Justification Required:** Yes (requires business justification for external sharing)

---

#### **LABEL 4: RESTRICTED**

#### **LABEL 4: RESTRICTED**

**Label Details:**
- **Name:** `Restricted`
- **Display Name:** `Restricted`
- **Description for Users:** "Trade secrets, strategic financial data, M&A plans, formulations. Highest security. Named-group access only. Requires strict controls."
- **Description for Admins:** "Client Four-Tier Policy Tier 4. Trade secrets (R&D/OT owned), strategic financial data (Finance leadership). Named groups, DKE candidate, fingerprints, site defaults."
- **Label Priority:** 4 (Highest)
- **Label Color:** Dark Red

**Scope:**
- ☑ Files & other data assets
- ☑ Emails
- ☑ Groups & sites
- ☐ Meetings

**⚠️ Note:** This is a **parent label** (or **label group** in modern scheme). Users must select a sublabel.

**→ Groups & Sites:**

This is a **parent label**. Protection settings for groups and sites are typically configured at the sublabel level or directly on SharePoint/Teams resources. No specific group/site protection settings are defined at this parent label level.

**Sublabels:**

---

##### **SUBLABEL 4.1: Restricted \ Trade Secret**

**Label Details:**
- **Name:** `Restricted-Trade-Secret`
- **Display Name:** `Restricted \ Trade Secret`
- **Description for Users:** "Trade secrets: recipes, formulations, ingredient ratios, proprietary processes. R&D and OT access only. Highest security controls."
- **Description for Admins:** "R&D/OT owned. Auto-labels: fingerprints, site defaults. Named-group access. Double Key Encryption candidate. No forward, print, or EXTRACT."
- **Label Priority:** 4.1
- **Label Color:** Dark Red (inherited from parent)

**Scope:**
- ☑ Files & other data assets
- ☑ Emails
- ☐ Groups & sites
- ☐ Meetings

**Protection Settings for Items:**

**→ Choose protection settings:**
- ☑ **Control access (Encryption)** - **ENABLED**
  - **Assign permissions now** (Admin-defined)
  - **Users and Groups:**
    - ☑ **Specific groups:** `RD-Security-Group@icpes.com`, `OT-Operations-Team@icpes.com`, `CISO-Team@icpes.com`
  - **Permissions:** **Co-Owner** (R&D/OT) + **View-Only** (CISO/Audit)
  - **User access expires:** **Never**
  - **Allow offline access:** **Never** (requires online authentication + MFA)
  - **Double Key Encryption:** ☑ **ENABLED (Candidate for Phase 2)** - Trade secrets require highest protection
  - **Dynamic Watermarks:** ☑ **ENABLED**
    - `RESTRICTED - TRADE SECRET | ${User.PrincipalName} | Proprietary & Confidential`

- ☑ **Apply content marking** - **ENABLED**
  - **Header:** `⛔ RESTRICTED - TRADE SECRET ⛔ | Proprietary Information Protected`
    - Font: Calibri, 16pt, Bold
    - Color: Dark Red
    - Align: Center
  - **Footer:** `Authorized R&D/OT Personnel Only | ${User.Name} | ${Event.DateTime} | Do NOT Distribute`
    - Font: Calibri, 9pt
    - Color: Dark Red
    - Align: Center
  - **Watermark:** Dynamic (user email) + "TRADE SECRET - DO NOT COPY"
    - Font: Calibri, 60pt
    - Color: Dark Red (Semi-transparent)
    - Layout: Diagonal

**→ Auto-labeling for files and emails:**
- ☑ **Automatically or recommend to label** - **ENABLED**
  - **Mode:** **Automatic** (apply silently with fingerprint match)
  - **Conditions:**
    - **Document fingerprints** (exact data match) for known trade secret documents:
      - Recipe formulations
      - Ingredient ratios and specifications
      - Proprietary manufacturing processes
      - R&D experimental data and results
    - OR file stored in `/sites/RD-TradeSecrets` OR `/sites/OT-Formulations`
    - OR contains keywords: "Recipe", "Formulation", "Proprietary Process", "Trade Secret", "وصفة سرية"

**DLP Policy (Linked to this Label):**
- **Name:** DLP-Trade-Secret-Protection
- **Locations:** Exchange, SharePoint, OneDrive, Teams, Devices
- **Conditions:** Content has label `Restricted \ Trade Secret`
- **Actions:**
  - **Block external sharing** (hard block - no exceptions)
  - **Block printing** (hard block)
  - **Block copy to USB/removable media** (Endpoint DLP)
  - **Block EXTRACT/copy-paste** (when technically feasible)
  - **Alert:** CISO + Legal + C-Level (immediate high-priority incident)
  - **Incident report:** Generate within 5 minutes
  - **User notification:** "This document contains trade secrets. ALL external distribution, printing, and copying are strictly prohibited."

**Retention Policy (Linked to this Label):**
- **Retention Period:** Indefinite (permanent retention until business decision to retire)
- **Disposition:** C-Level + Legal + CISO approval required
- **Immutable Storage:** WORM (Write-Once-Read-Many) compliance

**→ Groups & Sites:**

This sublabel's scope does not include **Groups & sites**, so no group/site protection settings are configured. Apply site-level defaults on R&D and OT SharePoint sites to auto-apply this label to all uploaded content.

**Publishing Policy:**
- **Scope:** R&D department + OT team + CISO team only
- **Default Label:** None (auto-applied by fingerprints and site defaults)
- **Mandatory:** Yes
- **Justification Required:** Yes (C-level + CISO approval required to change or remove)

---

##### **SUBLABEL 4.2: Restricted \ Strategic Financial**

**Label Details:**
- **Name:** `Restricted-Strategic-Financial`
- **Display Name:** `Restricted \ Strategic Financial`
- **Description for Users:** "Strategic financial data: M&A plans, strategic pricing, margin data, executive compensation, treasury operations. Finance leadership access only."
- **Description for Admins:** "Finance owned. Auto-labels: IBAN, SWIFT, strategic financial documents. CFO/Finance leadership group. Trainable classifiers + manual."
- **Label Priority:** 4.2
- **Label Color:** Dark Red (inherited from parent)

**Scope:**
- ☑ Files & other data assets
- ☑ Emails
- ☐ Groups & sites
- ☐ Meetings

**Protection Settings for Items:**

**→ Choose protection settings:**
- ☑ **Control access (Encryption)** - **ENABLED**
  - **Assign permissions now** (Admin-defined)
  - **Users and Groups:**
    - ☑ **Specific groups:** `Finance-Leadership-Group@icpes.com`, `CFO-Office@icpes.com`, `Treasury-Team@icpes.com`, `CISO-Team@icpes.com`
  - **Permissions:** **Co-Owner** (Finance Leadership) + **View-Only** (CISO/Audit)
  - **User access expires:** **Never**
  - **Allow offline access:** **Never** (online + MFA required)
  - **Double Key Encryption:** ☐ NOT ENABLED (consider for Phase 2 if required)
  - **Dynamic Watermarks:** ☑ **ENABLED**
    - `RESTRICTED - STRATEGIC FINANCIAL | ${User.PrincipalName} | Confidential Financial Data`

- ☑ **Apply content marking** - **ENABLED**
  - **Header:** `⛔ RESTRICTED - STRATEGIC FINANCIAL DATA ⛔ | Executive-Level Financial Information`
    - Font: Calibri, 16pt, Bold
    - Color: Dark Red
    - Align: Center
  - **Footer:** `Authorized Finance Leadership Only | ${User.Name} | ${Event.DateTime} | Strategic & Proprietary`
    - Font: Calibri, 9pt
    - Color: Dark Red
    - Align: Center
  - **Watermark:** Dynamic (user email) + "STRATEGIC FINANCIAL - DO NOT DISTRIBUTE"
    - Font: Calibri, 54pt
    - Color: Dark Red (Semi-transparent)
    - Layout: Diagonal

**→ Auto-labeling for files and emails:**
- ☑ **Automatically or recommend to label** - **ENABLED**
  - **Mode:** **Recommend** (user confirms due to business context requirements)
  - **Conditions:**
    - Content contains **at least 2 instances** of:
      - ✅ **IBAN** (Built-in SIT) - Confidence: High
      - ✅ **SWIFT Code** (Built-in SIT) - Confidence: High
      - ✅ **Credit Card Number** (Built-in SIT) - Confidence: High
    - AND file stored in `/Finance/Strategic` OR `/Finance/ExecutiveReports` OR `/Finance/MergersAcquisitions`
    - OR contains keywords: "M&A", "Strategic Pricing", "Margin Analysis", "Executive Compensation", "Treasury Operations", "Board Financial Report", "استحواذ", "تسعير استراتيجي"
    - OR **trainable classifier** matches: "Strategic Financial Reports", "M&A Documents"

**DLP Policy (Linked to this Label):**
- **Name:** DLP-Strategic-Financial-Protection
- **Locations:** Exchange, SharePoint, OneDrive, Teams, Devices
- **Conditions:** Content has label `Restricted \ Strategic Financial`
- **Actions:**
  - **Block external sharing** (hard block)
  - **Block printing** (optional - configure per CFO requirements)
  - **Block copy to USB** (Endpoint DLP)
  - **Require MFA for access** (Conditional Access)
  - **Alert:** CFO + CISO + Compliance (immediate high-priority incident)
  - **Incident report:** Within 5 minutes
  - **User notification:** "This document contains strategic financial data. External sharing violates corporate policy and regulatory requirements."

**Retention Policy:**
- **Retention Period:** 7 years (financial regulations) + strategic hold where required
- **Disposition:** CFO + Legal + Audit approval required
- **Immutable Storage:** WORM compliance for regulatory financial records

**→ Groups & Sites:**

This sublabel's scope does not include **Groups & sites**, so no group/site protection settings are configured. Apply site-level defaults on Finance strategic SharePoint sites to auto-apply this label to uploaded financial strategy documents.

**Publishing Policy:**
- **Scope:** Finance leadership + CFO office + Treasury team only
- **Default Label:** None (recommend-mode auto-labeling with user confirmation)
- **Mandatory:** Yes (for Finance leadership users)
- **Justification Required:** Yes (CFO + CISO approval)

---

### 3.4 Label Policy Configuration

---

#### **Policy 1: General Labeling Policy (All Users)**

**Policy Name:** `GeneralLabelingPolicy-AllUsers`

**Description:**  
Baseline sensitivity labeling policy for all ICPES users. Publishes Public, Internal, and Confidential sensitivity labels and establishes Internal as the default classification for standard business content.

### Labels Published

1. Public
2. Internal
3. Confidential
   - All Employees
   - Internal Only
   - External Approved

### Administrative Units

1. **Admin Unit Assignment:** Full Directory

### Users and Groups

1. **Location:** Exchange Email
2. **Users:** All Employees (`AllUsers@icpes.com`)
3. **Groups:** All Departments
4. **Scope:** All Users and Groups

### Policy Settings

#### → General Settings

1. **Users must provide a justification to remove a label or lower its classification:** ☑ Yes
2. **Require users to apply a label to their emails and documents:** ☐ No
3. **Require users to apply a label to their Fabric and Power BI content:** ☐ No
4. **Custom Help Page URL:** Not Configured

#### → Default Settings for Documents

1. **Apply a default label to documents:** `Internal`
2. **User Override Allowed:** ☑ Yes

#### → Default Settings for Emails

1. **Apply a default label to emails:** `Internal`
2. **Require users to apply a label to their emails:** ☐ No
3. **Email inherits highest priority label from attachments:** ☑ Yes

#### → Default Settings for Meetings and Calendar Events

1. **Apply a default label to meetings and calendar events:** `None`
2. **Require users to apply a label to meetings and calendar events:** ☐ No
3. **Inherit label from files shared to meetings:** ☐ No
4. **Apply meeting label to artifacts (recordings, transcripts, and Loop notes):** ☐ No

#### → Default Settings for Fabric and Power BI Content

1. **Apply a default label to Fabric and Power BI content:** `Internal`
2. **Require users to apply a label to Fabric and Power BI content:** ☐ No

### Policy Scope

1. **Administrative Units:** Full Directory
2. **Users:** All Employees (`AllUsers@icpes.com`)
3. **Groups:** All Departments

### Priority

**1** (Highest – evaluated first)

### Status

**Published**


---

#### **Policy 2: Finance Department Policy**

**Policy Name:** `FinanceLabelingPolicy-FinanceDept`

**Description:** Specialized policy for Finance department with Restricted strategic financial labels aligned with client four-tier policy.

**Labels Published:**
- Public
- Internal
- Confidential (All Employees, Internal Only, External Approved)
- Restricted \ Strategic Financial

**Policy Settings:**

**→ Default settings for documents:**
- **Apply this label by default to documents:** `Confidential \ All Employees`
- **Users must apply a label to their emails and documents:** ☑ Yes (mandatory for Finance)
- **Require justification:** ☑ Yes

**→ Default settings for emails:**
- **Apply this label by default to emails:** `Confidential \ All Employees`
- **Require users to apply a label:** ☑ Yes (mandatory)
- **Inherit label from attachments:** ☑ Yes

**→ Policy Scope:**
- **Administrative Units:** Finance OU
- **Users:** `Finance-All-Users@icpes.com` security group
- **Groups:** Finance, Accounting, Treasury, Audit

**Priority:** 2

**Status:** Published

---

#### **Policy 3: R&D / OT Policy**

**Policy Name:** `RD-OT-LabelingPolicy-TradeSecrets`

**Description:** Policy for R&D and Operations Technology teams with Restricted trade secret labels for proprietary formulations and processes.

**Labels Published:**
- Public
- Internal
- Confidential (All Employees, Internal Only, External Approved)
- Restricted \ Trade Secret

**Policy Settings:**

**→ Default settings for documents:**
- **Apply this label by default:** `Confidential \ Internal Only`
- **Mandatory labeling:** ☑ Yes
- **Require justification:** ☑ Yes

**→ Default settings for emails:**
- **Default label:** `Confidential \ Internal Only`
- **Mandatory:** ☑ Yes
- **Inherit from attachments:** ☑ Yes

**→ Policy Scope:**
- **Administrative Units:** R&D OU, OT OU
- **Users:** `RD-Security-Group@icpes.com`, `OT-Operations-Team@icpes.com`
- **Groups:** R&D, Operations Technology, CISO

**Priority:** 2

**Status:** Published

---

#### **Policy 4: Executive Management Policy**

**Policy Name:** `ExecutiveLabelingPolicy-Management`

**Description:** Policy for C-level executives and management with access to all labels in the client four-tier framework.

**Labels Published:**
- All labels (Public, Internal, Confidential with all sublabels, Restricted with all sublabels)

**Policy Settings:**

**→ Default settings for documents:**
- **Default label:** `Confidential \ Internal Only`
- **Mandatory:** ☑ Yes
- **Justification:** ☑ Yes (C-level approval for any change)

**→ Default settings for emails:**
- **Default label:** `Confidential \ Internal Only`
- **Mandatory:** ☑ Yes
- **Inherit from attachments:** ☑ Yes

**→ Default label for groups and sites:**
- **Apply this label by default:** `Confidential \ Internal Only`

**→ Default label for Power BI:**
- **Default label:** `Confidential \ Internal Only`

**→ Policy Scope:**
- **Administrative Units:** Executive OU
- **Users:** `Management-Executive-Team@icpes.com`, `Board-Members@icpes.com`
- **Groups:** C-Suite, Board of Directors

**Priority:** 1 (Highest - overrides other policies for these users)

**Status:** Published

---

### 3.5 Auto-Labeling Policies (Service-Side)

In addition to **auto-labeling for Office apps** (configured in label settings), you can configure **auto-labeling policies** that work service-side for SharePoint, OneDrive, and Exchange.

> **⚠️ SCOPE CONSTRAINT:** Up to eight auto-labelling policies in total for this project scope. Plan policy design carefully to maximize coverage within this limit.

**Reference:** [Microsoft Learn - How to configure auto-labeling policies](https://learn.microsoft.com/en-us/purview/apply-sensitivity-label-automatically#how-to-configure-auto-labeling-policies-for-sharepoint-onedrive-and-exchange)

---

#### **Auto-Labeling Policy 1: Kuwait PII Detection**

**Policy Name:** `AutoLabel-Kuwait-PII`

**Description:** Automatically applies `Confidential \ Internal Only` label to content containing Kuwait Civil IDs, GCC National IDs, Work Permits (Tier 3 per client policy).

**Locations:**
- ☑ SharePoint sites: All sites
- ☑ OneDrive accounts: All accounts
- ☑ Exchange mailboxes: HR department + Legal team only

**Rules:**

**→ Rule 1: Kuwait Civil ID Detected**
- **Conditions:**
  - Content contains **Kuwait Civil ID Number** (Custom SIT) - Confidence: High
  - **Instance count:** At least 1
- **Label to apply:** `Confidential \ Internal Only`

**→ Rule 2: GCC National IDs Detected**
- **Conditions:**
  - Content contains any of:
    - UAE Identity Card Number (Built-in)
    - Saudi Arabia National ID (Built-in)
    - Qatar ID (Custom)
    - Bahrain Personal Number (Custom)
    - Oman Identity Card (Custom)
  - **Instance count:** At least 1
- **Label to apply:** `Confidential \ Internal Only`

**→ Rule 3: Work Permit/Passport Detected**
- **Conditions:**
  - Content contains:
    - Kuwait Work Permit Number (Custom) OR
    - Passport Number (Built-in)
  - **Instance count:** At least 1
- **Label to apply:** `Confidential \ Internal Only`

**Policy Mode:**
- **Simulation Mode:** 14 days (test before enforcement)
- **Then:** Automatic (apply label without user interaction)

**Notifications:**
- **User notification:** ☐ No (service-side auto-labeling is silent)
- **Admin notification:** ☑ Yes (alert when label applied)

**Status:** Active

---

#### **Auto-Labeling Policy 2: Strategic Financial Data Detection**

**Policy Name:** `AutoLabel-Strategic-Financial`

**Description:** Automatically recommends `Restricted \ Strategic Financial` label to content with IBAN, Credit Cards, M&A keywords, strategic financial data (Tier 4 per client policy).

**Locations:**
- ☑ SharePoint sites: Finance strategic sites only (`/sites/Finance/Strategic`, `/sites/Finance/MergersAcquisitions`, `/sites/Finance/ExecutiveReports`)
- ☑ OneDrive accounts: Finance leadership only (`Finance-Leadership-Group@icpes.com`, `CFO-Office@icpes.com`)
- ☑ Exchange mailboxes: Finance leadership + CFO office + Treasury team

**Rules:**

**→ Rule 1: Strategic Banking Data Detected**
- **Conditions:**
  - Content contains **at least 2 instances** of:
    - IBAN (Built-in) - Confidence: High
    - SWIFT Code (Built-in) - Confidence: High
    - Credit Card Number (Built-in) - Confidence: High
  - **AND** file stored in `/Finance/Strategic` OR `/Finance/MergersAcquisitions` OR contains keywords: "M&A", "Strategic Pricing", "Margin Analysis", "Executive Compensation"
- **Label:** `Restricted \ Strategic Financial`
- **Mode:** **Recommend** (user confirms due to business context requirements)

**→ Rule 2: M&A and Strategic Content Detected**
- **Conditions:**
  - Content contains trainable classifiers:
    - Strategic Financial Reports
    - M&A Documents
  - **Instance count:** At least 1
- **Label:** `Restricted \ Strategic Financial`
- **Mode:** **Recommend**

**Policy Mode:**
- **Simulation:** 14 days
- **Then:** Recommend (requires user confirmation)

**Status:** Active

---

#### **Auto-Labeling Policy 3: Trade Secret Detection**

**Policy Name:** `AutoLabel-Trade-Secrets`

**Description:** Automatically recommends `Restricted \ Trade Secret` label to content containing proprietary formulations, recipes, R&D processes, and OT operational data (Tier 4 per client policy).

**Locations:**
- ☑ SharePoint sites: R&D sites only (`/sites/RD`, `/sites/OT`, `/sites/Research`)
- ☑ OneDrive accounts: R&D team + OT team only (`RD-Security-Group@icpes.com`, `OT-Operations-Team@icpes.com`)
- ☑ Exchange mailboxes: R&D + OT teams

**Rules:**

**→ Rule 1: Proprietary Content Detected**
- **Conditions:**
  - Content stored in `/RD/Formulations` OR `/OT/Processes` OR `/Research/Proprietary`
  - **AND** contains keywords: "Proprietary", "Trade Secret", "Confidential Formula", "Recipe", "Manufacturing Process", "ملكية", "سري تجاري"
- **Label:** `Restricted \ Trade Secret`
- **Mode:** **Recommend** (user confirms due to business context requirements)

**→ Rule 2: Document Fingerprint Match**
- **Conditions:**
  - Content matches **document fingerprint** for known trade secret templates (configured in fingerprint library)
- **Label:** `Restricted \ Trade Secret`
- **Mode:** **Recommend**

**Policy Mode:**
- **Simulation:** 14 days
- **Then:** Recommend (requires user confirmation)

**Notifications:**
- **User notification:** ☑ Yes (policy tip: "This appears to contain trade secrets. Apply Restricted label?")
- **Admin notification:** ☑ Yes (alert when label applied)

**Status:** Pending (to be activated in Phase 2)

---

#### **Auto-Labeling Policy 4: IT Security Credentials Detection**

**Policy Name:** `AutoLabel-IT-Credentials`

**Description:** Automatically applies `Confidential \ Internal Only` label to content containing Azure Keys, API Keys, SSH Keys, database credentials (Tier 3 per client policy).

**Locations:**
- ☑ SharePoint sites: IT sites only (`/sites/IT`, `/sites/DevOps`, `/sites/Infrastructure`)
- ☑ OneDrive accounts: IT department only (`IT-Security-Team@icpes.com`, `DevOps-Team@icpes.com`)
- ☑ Exchange mailboxes: IT + Security teams

**Rules:**

**→ Rule 1: Azure/Cloud Credentials Detected**
- **Conditions:**
  - Content contains **at least 1 instance** of:
    - Azure Storage Account Key (Custom SIT) - Confidence: High
    - Azure Subscription Key (Custom SIT) - Confidence: High
    - Azure SQL Connection String (Custom SIT) - Confidence: High
    - AWS Access Key (Built-in) - Confidence: High
- **Label:** `Confidential \ Internal Only`

**→ Rule 2: API Keys/SSH Keys Detected**
- **Conditions:**
  - Content contains **at least 1 instance** of:
    - API Key (Custom SIT - pattern: alphanumeric 32-64 chars) - Confidence: High
    - SSH Private Key (Custom SIT - pattern: "-----BEGIN.*PRIVATE KEY-----") - Confidence: High
- **Label:** `Confidential \ Internal Only`

**Policy Mode:**
- **Simulation:** 14 days
- **Then:** Automatic (apply label without user interaction)

**Notifications:**
- **User notification:** ☐ No (service-side auto-labeling is silent)
- **Admin notification:** ☑ Yes (alert when label applied)

**Status:** Pending (to be activated in Phase 2)

---

#### **Auto-Labeling Policy 5: HR Employment Records Detection**

**Policy Name:** `AutoLabel-HR-Employment`

**Description:** Automatically applies `Confidential \ Internal Only` label to HR employment documents including contracts, performance reviews, disciplinary records (Tier 3 per client policy).

**Locations:**
- ☑ SharePoint sites: HR sites only (`/sites/HR`, `/sites/HRRecords`)
- ☑ OneDrive accounts: HR department only (`HR-All-Users@icpes.com`)
- ☑ Exchange mailboxes: HR department only

**Rules:**

**→ Rule 1: Employment Contract Detected**
- **Conditions:**
  - Content contains keywords: "Employment Contract", "Offer Letter", "عقد عمل", "خطاب عرض العمل"
  - **AND** contains **at least 1 instance** of:
    - Kuwait Civil ID Number (Custom SIT)
    - Date of Birth (Custom SIT)
- **Label:** `Confidential \ Internal Only`

**→ Rule 2: HR File Number Detected**
- **Conditions:**
  - Content contains **Kuwait Labor File Number** (Custom SIT) - Confidence: High
  - **Instance count:** At least 1
- **Label:** `Confidential \ Internal Only`

**→ Rule 3: Performance/Disciplinary Records**
- **Conditions:**
  - File stored in `/HR/PerformanceReviews` OR `/HR/Disciplinary`
  - **OR** contains keywords: "Performance Review", "Disciplinary Action", "Warning Letter", "تقييم الأداء", "إجراء تأديبي"
- **Label:** `Confidential \ Internal Only`

**Policy Mode:**
- **Simulation:** 14 days
- **Then:** Automatic

**Notifications:**
- **User notification:** ☐ No
- **Admin notification:** ☑ Yes

**Status:** Pending (to be activated in Phase 2)

---

#### **Auto-Labeling Policy 6: Legal Contract Detection**

**Policy Name:** `AutoLabel-Legal-Contracts`

**Description:** Automatically applies `Confidential \ All Employees` label to legal contracts, agreements, NDAs, and case files (Tier 3 per client policy).

**Locations:**
- ☑ SharePoint sites: Legal sites only (`/sites/Legal`, `/sites/Contracts`)
- ☑ OneDrive accounts: Legal team only (`Legal-Team@icpes.com`)
- ☑ Exchange mailboxes: Legal team

**Rules:**

**→ Rule 1: Contract Document Detected**
- **Conditions:**
  - Content contains **at least 2 instances** of keywords:
    - "Contract", "Agreement", "NDA", "Non-Disclosure", "Vendor Agreement", "Service Agreement", "عقد", "اتفاقية", "اتفاقية عدم الإفصاح"
  - **AND** document type is PDF or Word (.docx, .doc)
- **Label:** `Confidential \ All Employees`

**→ Rule 2: Legal Case Reference Detected**
- **Conditions:**
  - Content contains **Kuwait Legal Case Reference** (Custom SIT) - Confidence: High
  - **OR** contains **Kuwait Trade License Number** (Custom SIT)
  - **Instance count:** At least 1
- **Label:** `Confidential \ All Employees`

**Policy Mode:**
- **Simulation:** 14 days
- **Then:** Automatic

**Notifications:**
- **User notification:** ☐ No
- **Admin notification:** ☑ Yes

**Status:** Pending (to be activated in Phase 2)

---

#### **Auto-Labeling Policy 7: Marketing Customer Data Detection**

**Policy Name:** `AutoLabel-Marketing-CustomerData`

**Description:** Automatically applies `Confidential \ Internal Only` label to marketing customer lists, campaign data, and customer contact information (Tier 3 per client policy).

**Locations:**
- ☑ SharePoint sites: Marketing sites only (`/sites/Marketing`, `/sites/CustomerData`)
- ☑ OneDrive accounts: Marketing department only (`Marketing-Team@icpes.com`)
- ☑ Exchange mailboxes: Marketing team

**Rules:**

**→ Rule 1: Customer Contact List Detected**
- **Conditions:**
  - Content contains **at least 5 instances** of:
    - Email Address (Custom SIT or regex pattern)
    - Phone Number (Custom SIT or Built-in)
  - **AND** file name contains: "Customer", "Contact", "Lead", "Prospect", "قائمة العملاء", "جهات الاتصال"
- **Label:** `Confidential \ Internal Only`

**→ Rule 2: Marketing Campaign Data**
- **Conditions:**
  - File stored in `/Marketing/Campaigns` OR `/Marketing/CustomerAnalysis`
  - **OR** contains keywords: "Customer Segmentation", "Campaign Performance", "Marketing ROI", "تقسيم العملاء", "أداء الحملة"
- **Label:** `Confidential \ Internal Only`

**Policy Mode:**
- **Simulation:** 14 days
- **Then:** Automatic

**Notifications:**
- **User notification:** ☐ No
- **Admin notification:** ☑ Yes

**Status:** Pending (to be activated in Phase 3)

---

#### **Auto-Labeling Policy 8: Management Strategic Documents Detection**

**Policy Name:** `AutoLabel-Management-Strategic`

**Description:** Automatically applies `Confidential \ Internal Only` label to board minutes, strategic plans, and executive documents (Tier 3 per client policy).

**Locations:**
- ☑ SharePoint sites: Executive sites only (`/sites/Executive`, `/sites/BoardOfDirectors`, `/sites/CLevel`)
- ☑ OneDrive accounts: Management team only (`Management-Executive-Team@icpes.com`, `Board-Members@icpes.com`)
- ☑ Exchange mailboxes: Executive management + Board members

**Rules:**

**→ Rule 1: Board/Executive Documents Detected**
- **Conditions:**
  - Content contains keywords: "Board Minutes", "Board Meeting", "Executive Summary", "Strategic Plan", "محضر اجتماع مجلس الإدارة", "خطة استراتيجية"
  - **AND** file stored in `/Executive/` OR `/BoardOfDirectors/` paths
- **Label:** `Confidential \ Internal Only`

**→ Rule 2: Strategic Planning Documents**
- **Conditions:**
  - Content contains **at least 2 instances** of:
    - "Strategic Initiative", "Roadmap", "5-Year Plan", "Business Strategy", "مبادرة استراتيجية", "خارطة الطريق"
  - **OR** trainable classifier matches: "Strategic Planning Documents", "Executive Reports"
- **Label:** `Confidential \ Internal Only`

**Policy Mode:**
- **Simulation:** 14 days
- **Then:** Automatic

**Notifications:**
- **User notification:** ☐ No
- **Admin notification:** ☑ Yes

**Status:** Pending (to be activated in Phase 3)

---

### 3.6 Integration with Other Microsoft Purview Features

#### **3.6.1 Data Loss Prevention (DLP) Policies**

Sensitivity labels are **conditions** in DLP policies:

**Example DLP Policy: Block External Sharing of Restricted Content**

- **Name:** DLP-Block-Restricted-External
- **Locations:** Exchange, SharePoint, OneDrive, Teams, Endpoints
- **Conditions:**
  - Content is labeled with `Restricted \ Trade Secret` OR `Restricted \ Strategic Financial` OR `Confidential \ Internal Only`
- **Actions:**
  - **Block** sharing content with people outside the organization
  - **Block** copying to USB/removable media (Endpoint DLP)
  - **Alert** CISO + Compliance Officer (high-severity incident)
  - **User notification:** "This content is Restricted or Confidential (Internal Only). External sharing is prohibited by Kuwait Cyberlaw 63/2015."
- **Exceptions:** `Confidential \ External Approved` (when explicitly approved)
- **Status:** Enforced

**Reference:** [Microsoft Learn - Use sensitivity labels as conditions in DLP policies](https://learn.microsoft.com/en-us/purview/dlp-sensitivity-label-as-condition)

---

#### **3.6.2 Retention Policies**

Sensitivity labels can **trigger retention policies**:

**Example Retention Policy: 10-Year HR Records Retention**

- **Name:** Retention-HR-PII-10Years
- **Locations:** SharePoint, OneDrive, Exchange
- **Settings:**
  - **Retain for:** 10 years (Kuwait Labor Law requirement)
  - **After retention period:** Do nothing (legal hold check required)
  - **Conditions:** Content is labeled with `Confidential \ Internal Only` (for PII content - Tier 3 per client policy)
- **Status:** Active

**Reference:** [Microsoft Learn - Automatically apply retention labels](https://learn.microsoft.com/en-us/purview/apply-retention-labels-automatically)

---

#### **3.6.3 Microsoft Defender for Cloud Apps Integration**

Sensitivity labels extend to **Cloud Apps** (non-Microsoft apps):

- **Discover** labeled content in third-party cloud apps (Dropbox, Box, Google Drive)
- **Enforce** DLP policies on labeled content in SaaS apps
- **Monitor** labeled content activity across cloud services

**Reference:** [Microsoft Learn - Discover, classify, label, and protect data in cloud apps](https://learn.microsoft.com/en-us/defender-cloud-apps/best-practices#discover-classify-label-and-protect-regulated-and-sensitive-data-stored-in-the-cloud)

---

#### **3.6.4 Microsoft Purview Data Map (Azure, AWS, GCP)**

Extend sensitivity labels to **non-Microsoft 365 data sources**:

- **Azure Blob Storage** (invoices, scanned documents)
- **Azure SQL Database** (customer databases)
- **Azure Data Lake Gen2** (analytics data)
- **On-premises file shares** (via Information Protection scanner)

**Pay-as-you-go billing** required for Data Map labeling.

**Reference:** [Microsoft Learn - Labeling in Microsoft Purview Data Map](https://learn.microsoft.com/en-us/purview/data-map-sensitivity-labels)

---

### 3.7 Label Management & Governance

#### **3.7.1 Label Priority (Order Matters)**

Labels are ordered by **priority** (1 = lowest, 4 = highest in our client-aligned design):

1. Public (Priority 1)
2. Internal (Priority 2)
3. Confidential (Priority 3)
4. **Restricted (Priority 4 - HIGHEST)**

**Why Priority Matters:**

- **Auto-labeling**: When multiple labels match, the **highest priority** label is applied
- **Inheritance**: Email attachments inherit the **highest priority** label from attached files
- **Justification**: Users must justify lowering classification (e.g., changing from Confidential to Internal)
- **Audit alerts**: When a document with higher priority label is uploaded to a site with lower priority label, an **audit event + email** is generated

**Example:** Document labeled `Restricted \ Trade Secret` (Priority 4) uploaded to SharePoint site labeled `Confidential \ All Employees` (Priority 3) → **Alert triggered** + Email sent to site owners.

**Reference:** [Microsoft Learn - Label priority (order matters)](https://learn.microsoft.com/en-us/purview/sensitivity-labels#label-priority-order-matters)

---

#### **3.7.2 Label Changes & Replication Time

- **New labels:** Allow **1 hour minimum**, up to **24 hours** for replication to all apps/services
- **Editing existing labels:** Allow **24 hours** for changes to propagate
- **Policy changes:** Allow **24 hours** for policy updates to reach all users

**Important:** Don't troubleshoot label issues until 24 hours after creation/modification.

**Reference:** [Microsoft Learn - When to expect new labels and changes to take effect](https://learn.microsoft.com/en-us/purview/create-sensitivity-labels#when-to-expect-new-labels-and-changes-to-take-effect)

---

#### **3.7.3 Label Auditing & Monitoring

All labeling activities are audited:

- **User applied sensitivity label** (manual labeling)
- **Auto-labeling rule matched** (automatic labeling)
- **Sensitivity label removed**
- **Sensitivity label changed** (with justification captured)
- **Detected document sensitivity mismatch** (upload alert)

**View audit logs:**
- **Microsoft Purview portal** → **Audit** → Search for "Sensitivity label activities"
- **Activity Explorer**: Visual analytics of labeling activity
- **Content Explorer**: See where labeled content is located

**Reference:** [Microsoft Learn - Audit log activities - Sensitivity label activities](https://learn.microsoft.com/en-us/purview/audit-log-activities#sensitivity-label-activities)

---

#### **3.7.4 Label Removal & Deletion Best Practices

**⚠️ IMPORTANT:** Deleting labels is risky. Follow these guidelines:

**Removing a label from a policy (safe):**
- Users no longer see the label in apps
- Already-labeled content **keeps the label and protection**
- Can be re-added to policy later

**Deleting a label (permanent):**
- Label is permanently removed from tenant
- Encryption protection template is **archived** (content can still be opened)
- Label metadata remains but label name won't display in apps
- **Can't create new label with same name** (due to archived template)

**Best Practice:** Instead of deleting, **remove from policy** and keep label for audit/historical purposes.

**Reference:** [Microsoft Learn - Removing and deleting labels](https://learn.microsoft.com/en-us/purview/create-sensitivity-labels#removing-and-deleting-labels)

---

### 3.8 User Training & Rollout Considerations

#### **3.8.1 User Education (Essential for Success)**

**Training Topics:**

1. **What are sensitivity labels?**
   - Visual indicator of data sensitivity (like a stamp)
   - Travels with the data (persistent protection)
   - Enforces protection (encryption, access control, watermarks)

2. **When to use each label:**
   - **Tier 1 - Public:** Press releases, marketing materials, public website content
   - **Tier 2 - Internal (Default):** Internal memos, departmental updates, general business docs
   - **Tier 3 - Confidential:** Contracts, vendor agreements, project plans, budgets, PII (Civil IDs, Passports, employee records)
     - **All Employees:** Standard confidential content accessible by all internal employees
     - **Internal Only:** Cannot be shared externally, Do Not Forward enforced
     - **External Approved:** Can be shared with specific external partners with approval
   - **Tier 4 - Restricted:** Trade secrets (recipes, formulations), strategic financial data (M&A, strategic pricing, executive compensation)
     - **Trade Secret:** R&D/OT owned proprietary processes and formulations
     - **Strategic Financial:** Finance leadership strategic pricing, M&A plans, treasury operations

3. **How to apply labels:**
   - **Manual:** Click "Sensitivity" button in Office apps (Word, Excel, PowerPoint, Outlook)
   - **Automatic:** Labels apply automatically when SITs detected (user sees notification)
   - **Recommended:** Label suggested with policy tip (user can accept/reject)

4. **What happens when you apply a label:**
   - **Public/Internal:** Content marking (header/footer) added
   - **Confidential:** Encryption + content marking applied (varies by sublabel)
   - **Restricted:** Strong encryption + dynamic watermarks + named-group access + DKE candidate (for Trade Secrets)

5. **DLP Alerts & Blocking:**
   - Users will see **policy tips** when sharing Restricted or Confidential\Internal Only content externally
   - **Block messages** will appear if action is prohibited (e.g., "Cannot share Trade Secrets externally")
   - **Justification prompts** when lowering classification

**Training Delivery:**

- **Week 1 (Pilot):** In-person training for HR, Finance, Legal (30 mins)
- **Week 2 (IT/Management):** Virtual training for IT admins and management (45 mins)
- **Week 3 (All Users):** Company-wide webinar (30 mins) + recorded video on intranet
- **Ongoing:** Quick reference guide (PDF), tooltips in labels, help link to internal wiki

**User Documentation Link (in Label Policy):**
- **Provide users with link to custom help page:** `https://intranet.icpes.com/purview-labeling-guide`

**Reference:** [Microsoft Learn - End-user documentation for sensitivity labels](https://learn.microsoft.com/en-us/purview/get-started-with-sensitivity-labels#end-user-documentation-for-sensitivity-labels)

---

#### **3.8.2 Phased Rollout Strategy

**Phase 1: Pilot (Week 3)**
- **Scope:** 20 users (5 from HR, 5 from Finance, 5 from Legal, 5 from IT)
- **Labels:** Public, Internal, Confidential only
- **Duration:** 1 week
- **Goal:** Test label visibility, manual application, collect feedback
- **Monitoring:** Daily check of audit logs, user feedback survey

**Phase 2: Department Rollout (Week 4)**
- **Scope:** R&D/OT departments (full), Finance department (full), HR/Legal teams
- **Labels:** Add Restricted labels (Trade Secret, Strategic Financial) + full Confidential sublabels (Internal Only, External Approved)
- **Duration:** 1 week
- **Goal:** Test auto-labeling for trade secrets, strategic financial data, and confidential PII, DLP policies
- **Monitoring:** Activity Explorer review, incident reports

**Phase 3: Full Organization (Week 5+)**
- **Scope:** All users (500+ employees)
- **Labels:** All labels published
- **Duration:** Ongoing
- **Goal:** Full adoption, continuous monitoring
- **Monitoring:** Monthly reports, quarterly review of label usage

---

### 3.9 Technical Prerequisites (Checklist)

Before deploying sensitivity labels, verify:

#### **Microsoft 365 Licensing**

- ✅ **Microsoft 365 E3** or higher (for basic labeling)
- ✅ **Microsoft 365 E5** or **Microsoft Purview Information Protection P1/P2** (for auto-labeling, DLP, encryption, Data Map)
- ✅ **Azure Information Protection P1** (for scanner, if using on-prem file shares)

**Reference:** [Microsoft Learn - Licensing requirements for sensitivity labels](https://learn.microsoft.com/en-us/purview/get-started-with-sensitivity-labels#licensing-and-billing-requirements-for-sensitivity-labels)

---

#### **Azure Rights Management Activation**

- ✅ **Azure Rights Management service activated** (required for encryption)
  - Check: `Connect-AipService` → `Get-AipService` (should show "Enabled")
  - If not enabled: `Enable-AipService`

**Reference:** [Microsoft Learn - Activate Azure Rights Management](https://learn.microsoft.com/en-us/purview/activate-rights-management-service)

---

#### **Exchange Online Configuration**

- ✅ **Exchange Online IRM configured** (for encrypted emails in Outlook)
  - Check: `Get-IRMConfiguration | fl *RMSOnline*`
  - Configure: [Exchange Online: IRM Configuration](https://learn.microsoft.com/en-us/azure/information-protection/configure-office365#exchangeonline-irm-configuration)

---

#### **SharePoint/OneDrive Configuration**

- ✅ **Sensitivity labels enabled for Office files in SharePoint/OneDrive**
  - Enables: Co-authoring on encrypted files, auto-labeling in SharePoint, DLP on labeled PDFs
  - Configure: `Set-SPOTenant -EnableAIPIntegration $true`

**Reference:** [Microsoft Learn - Enable sensitivity labels for Office files in SharePoint and OneDrive](https://learn.microsoft.com/en-us/purview/sensitivity-labels-sharepoint-onedrive-files)

---

#### **Microsoft Entra ID (Azure AD) Configuration**

- ✅ **Sensitivity labels for containers enabled** (for Teams, Microsoft 365 Groups, SharePoint sites)
  - PowerShell: `Execute-AzureAdLabelSync`

**Reference:** [Microsoft Learn - Enable sensitivity labels for containers](https://learn.microsoft.com/en-us/purview/sensitivity-labels-teams-groups-sites#how-to-enable-sensitivity-labels-for-containers-and-synchronize-labels)

---

#### **Conditional Access (for Restricted Labels)**

- ✅ **Conditional Access policies configured** (for unmanaged devices, MFA)
  - Example policies:
    - **Require-MFA-Restricted** (for all Restricted labels: Trade Secret, Strategic Financial)
    - **Block-Unmanaged-Devices-Restricted** (for Restricted labels)

**Reference:** [Microsoft Learn - Microsoft Entra Conditional Access overview](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/overview)

---

#### **Data Loss Prevention (DLP) Policies**

- ✅ **DLP policies created and tested in simulation mode**
  - Test DLP-Kuwait-PII-Protection (14 days simulation)
  - Test DLP-GCC-Financial-Protection (14 days simulation)
  - Then switch to Enforce mode

---

#### **Custom SITs Created**

- ✅ **Kuwait Civil ID Number SIT** created and tested
- ✅ **Kuwait Work Permit SIT** created and tested
- ✅ **Kuwait Labor File Number SIT** created and tested
- ✅ **Kuwait Trade License SIT** created (optional)

---

### 3.10 Monitoring & Continuous Improvement

#### **Weekly Monitoring (Weeks 3-5)**

- **Activity Explorer**: Review label application trends
- **Audit Logs**: Check for "Document sensitivity mismatch" alerts
- **DLP Incidents**: Review false positives, adjust rules
- **User Feedback**: Collect via helpdesk tickets, surveys

---

#### **Monthly Reports (After Go-Live)**

- **Label Coverage Report**:
  - % of documents labeled vs. unlabeled
  - Most-used labels
  - Departments with highest/lowest labeling rates

- **DLP Incident Report**:
  - Number of blocked actions (external sharing, USB copy)
  - Top users triggering DLP alerts
  - False positive rate

- **Auto-Labeling Effectiveness**:
  - Number of auto-applied labels
  - Accuracy of SIT detection (false positives/negatives)
  - User overrides of recommended labels

---

#### **Quarterly Review (Governance)**

- **Label Effectiveness Review**:
  - Are labels meeting business needs?
  - Do we need new labels? (e.g., "Restricted \ Government-Only" for public sector clients)
  - Should any labels be deprecated?

- **Policy Tuning**:
  - Adjust DLP rules based on false positives
  - Fine-tune auto-labeling conditions
  - Update SIT patterns (e.g., new Kuwait Civil ID format)

- **Compliance Audit**:
  - Verify 10-year retention for HR records
  - Check GCC data localization (all Restricted data in UAE/Qatar regions)
  - Review audit logs for unauthorized label removal

---

## 4. Implementation Roadmap

### **Week 3: Classification, SITs, Label Design (Current Phase)**

| Day | Task | Owner | Status |
|-----|------|-------|--------|
| **Mon** | Finalize Data Classification Matrix (Kuwait/GCC) | Compliance Team | ✅ Complete |
| **Tue** | Create Custom SIT: Kuwait Civil ID Number | IT/Purview Admin | 🔄 In Progress |
| **Wed** | Create Custom SIT: Kuwait Work Permit, Labor File Number | IT/Purview Admin | ⏳ Pending |
| **Thu** | Design Sensitivity Label Hierarchy (5 labels + sublabels) | Compliance + IT | ✅ Complete |
| **Fri** | Review label design with stakeholders (HR, Finance, Legal, Management) | Project Manager | ⏳ Pending |

---

### **Week 4: Label Configuration & Testing**

| Day | Task | Owner | Status |
|-----|------|-------|--------|
| **Mon** | Create labels in Microsoft Purview portal (Public, Internal, Confidential) | IT Admin | ⏳ Pending |
| **Tue** | Configure encryption settings for Confidential sublabels | IT Admin | ⏳ Pending |
| **Wed** | Create Restricted labels with encryption (Trade Secret, Strategic Financial) and complete Confidential sublabels (Internal Only, External Approved) | IT Admin | ⏳ Pending |
| **Thu** | Configure auto-labeling policies (Kuwait PII, GCC Financial) in Simulation mode | IT Admin | ⏳ Pending |
| **Fri** | Create label policies (General, Finance, HR/Legal, Executive) and publish to pilot users | IT Admin | ⏳ Pending |

---

### **Week 5: DLP & Pilot Testing**

| Day | Task | Owner | Status |
|-----|------|-------|--------|
| **Mon** | Create DLP policies (Block Restricted External, USB Copy restrictions) in Simulation mode | IT Admin | ⏳ Pending |
| **Tue** | Pilot training: HR, Finance, Legal (20 users) | Training Team | ⏳ Pending |
| **Wed** | Pilot users test manual labeling (Public, Internal, Confidential) | Pilot Users | ⏳ Pending |
| **Thu** | Monitor pilot: Activity Explorer, audit logs, user feedback | IT + Compliance | ⏳ Pending |
| **Fri** | Pilot review meeting: Adjust labels/policies based on feedback | Project Team | ⏳ Pending |

---

### **Week 6: Full Rollout Preparation**

| Day | Task | Owner | Status |
|-----|------|-------|--------|
| **Mon** | Fix pilot issues: Label description updates, DLP rule adjustments | IT Admin | ⏳ Pending |
| **Tue** | Company-wide training (webinar + recorded video) | Training Team | ⏳ Pending |
| **Wed** | Publish labels to all users (phased by department: HR, Finance, Legal first) | IT Admin | ⏳ Pending |
| **Thu** | Switch auto-labeling policies from Simulation to Automatic mode | IT Admin | ⏳ Pending |
| **Fri** | Switch DLP policies from Simulation to Enforce mode | IT Admin | ⏳ Pending |

---

### **Week 7+: Monitoring & Continuous Improvement**

| Frequency | Task | Owner |
|-----------|------|-------|
| **Daily (Week 7-8)** | Monitor DLP incidents, Activity Explorer, audit logs | IT + Compliance |
| **Weekly** | User feedback review, helpdesk ticket analysis | IT Support |
| **Monthly** | Label coverage report, DLP incident report, auto-labeling effectiveness | Compliance Team |
| **Quarterly** | Label effectiveness review, policy tuning, compliance audit | Governance Team |

---

## 5. References

### **Microsoft Learn Documentation (Fact-Checked July 2026)**

1. **Sensitivity Labels Overview**
   - [Learn about sensitivity labels](https://learn.microsoft.com/en-us/purview/sensitivity-labels)
   - [Get started with sensitivity labels](https://learn.microsoft.com/en-us/purview/get-started-with-sensitivity-labels)

2. **Create & Configure Labels**
   - [Create and publish sensitivity labels](https://learn.microsoft.com/en-us/purview/create-sensitivity-labels)
   - [Manage sensitivity labels in Office apps](https://learn.microsoft.com/en-us/purview/sensitivity-labels-office-apps)

3. **Encryption & Protection**
   - [Apply encryption using sensitivity labels](https://learn.microsoft.com/en-us/purview/encryption-sensitivity-labels)
   - [Azure Rights Management service](https://learn.microsoft.com/en-us/purview/azure-rights-management-learn-about)

4. **Auto-Labeling**
   - [Automatically apply sensitivity labels](https://learn.microsoft.com/en-us/purview/apply-sensitivity-label-automatically)

5. **DLP Integration**
   - [Use sensitivity labels as conditions in DLP policies](https://learn.microsoft.com/en-us/purview/dlp-sensitivity-label-as-condition)
   - [Learn about data loss prevention](https://learn.microsoft.com/en-us/purview/dlp-learn-about-dlp)

6. **Containers (Teams, SharePoint)**
   - [Use sensitivity labels for containers (groups and sites)](https://learn.microsoft.com/en-us/purview/sensitivity-labels-teams-groups-sites)

7. **Auditing & Monitoring**
   - [Audit log activities - Sensitivity label activities](https://learn.microsoft.com/en-us/purview/audit-log-activities#sensitivity-label-activities)
   - [Data classification activity explorer](https://learn.microsoft.com/en-us/purview/data-classification-activity-explorer)

8. **Sensitive Information Types**
   - [Sensitive information type entity definitions](https://learn.microsoft.com/en-us/purview/sit-sensitive-information-type-entity-definitions)
   - [UAE Identity Card Number](https://learn.microsoft.com/en-us/purview/sit-defn-uae-identity-card-number)

---

### **Kuwait/GCC Regulatory References**

1. **Kuwait Cybersecurity Law 63/2015**
   - Focus: Critical infrastructure protection, data sovereignty, incident reporting to CITRA

2. **Kuwait Labor Law 6/2010**
   - Focus: 10-year retention for employee records, work permits, termination documents

3. **Central Bank of Kuwait (CBK) Regulations**
   - Focus: Banking data protection, financial record retention (7 years), PCI-DSS compliance

4. **GCC Data Localization Guidelines**
   - Focus: Keep sensitive data in GCC regions (UAE, Qatar, Bahrain, Oman, KSA)

---

### **Azure Resources**

1. **Azure Regions for Kuwait/GCC:**
   - Primary: Azure UAE North (Dubai)
   - Secondary: Azure UAE Central (Abu Dhabi), Azure Qatar Central

2. **Azure Rights Management:**
   - [Activate Azure Rights Management service](https://learn.microsoft.com/en-us/purview/activate-rights-management-service)

3. **Conditional Access:**
   - [Microsoft Entra Conditional Access overview](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/overview)

---

## Document Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-07-22 | Project Team | Initial Data Classification Matrix (Kuwait/GCC) |
| 2.0 | 2026-07-24 | Compliance + IT | Added SIT Inventory + Sensitivity Label Framework Design (Fact-checked against Microsoft July 2026 docs) |
| 2.1 | 2026-07-27 | Compliance + IT | **Client Policy Alignment Update**: <br>• Added Section 1.0: Classification Taxonomy & Policy Alignment (mandated four-tier framework)<br>• Updated Section 1.1: Sensitivity Level Definitions (Tier 1-4 instead of 5 levels)<br>• Updated Section 1.2: Handling Rules Matrix (removed "Highly Confidential", aligned with Tier 4/3/2/1)<br>• Updated Section 1.3: Compliance Mapping (CITRA Resolution 26/2024, NCSC Decisions 1&2/2025-2026)<br>• Added Section 2.1.1: Non-Existent Built-in SITs (verification required for Email Address, Phone Number, Azure SITs)<br>• **Updated Section 2.3: All Department SIT Tables** (HR, Finance, IT, Legal, Marketing, Management) — **Realigned all sensitivity levels per client 4-tier policy**: Moved all PII items (Civil IDs, Passports, Work Permits, DOB, Email, Phone, Physical Address) from "Restricted"/"Highly Confidential" to **Confidential (Tier 3)**; kept financial data (Credit Cards, IBANs, SWIFT) and critical infrastructure (Azure keys) at **Restricted (Tier 4)**; eliminated all "Highly Confidential" references<br>• Updated Section 3.2: Label Hierarchy (Client Four-Tier Policy Aligned)<br>• Added Section 3.2.1: Client Recommended Label Architecture (Confidential\Internal Only, Confidential\External Approved, Restricted\Trade Secret, Restricted\Strategic Financial sublabels)<br>• **Updated Section 3.3: Detailed Label Configuration** — Replaced old 5-tier label structure with client 4-tier design: Updated Confidential sublabels (All Employees, Internal Only, External Approved); Converted "Highly Confidential" Label 4 to "Restricted" Label 4 with Trade Secret and Strategic Financial sublabels; Removed old Label 5 entirely<br>• **Updated Section 3.4: Label Policy Configuration** — Updated all four labeling policies to reference new label structure (removed "Highly Confidential", "Trusted People", "PII-Kuwait", "Financial-GCC" references)<br>• **Updated Section 3.5: Auto-Labeling Policies** — Aligned PII detection with Tier 3 Confidential (not Tier 4 Restricted); updated financial detection to reference Strategic Financial label<br>• **Updated Section 3.6: DLP & Retention Policies** — Updated policy references to new label structure<br>• **Updated Section 3.7: Label Priority** — Changed from 5-tier to 4-tier priority system<br>• **Updated Section 3.8: Training & Roadmap** — Updated training materials, phased rollout strategy, conditional access policies, and Week 4 roadmap tasks to reflect client 4-tier structure<br>• Added critical policy notice callout: PII at Tier 3 (not Tier 4), Tier 2 mandatory default, Tier 4 for trade secrets |

---

## Approval & Sign-Off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| **Project Sponsor** | [Name] | ________________ | ______ |
| **Compliance Officer** | [Name] | ________________ | ______ |
| **IT Manager** | [Name] | ________________ | ______ |
| **CISO** | [Name] | ________________ | ______ |
| **Legal Counsel** | [Name] | ________________ | ______ |

---

**END OF DOCUMENT**
