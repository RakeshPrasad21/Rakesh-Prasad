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

**Description:** Specialized policy for Finance department with Restricted Strategic Financial labels aligned with the ICPES four-tier classification framework.

**Labels Published:**
- Public
- Internal
- Confidential
  - All Employees
  - Internal Only
  - External Approved
- Restricted
  - Strategic Financial

**Administrative Units:**
- **Admin Unit Assignment:** Finance OU

**Users and Groups:**
- **Location:** Exchange Email
- **Users:** `Finance-All-Users@icpes.com`
- **Groups:** Finance, Accounting, Treasury, Audit
- **Scope:** Finance Department Users and Groups

**Policy Settings:**

**→ General Settings:**
- **Users must provide a justification to remove a label or lower its classification:** ☑ Yes
- **Require users to apply a label to their emails and documents:** ☑ Yes
- **Require users to apply a label to their Fabric and Power BI content:** ☑ Yes
- **Custom Help Page URL:** Not Configured

**→ Default Settings for Documents:**
- **Apply a default label to documents:** `Confidential \ All Employees`
- **User Override Allowed:** ☑ Yes (downgrade requires justification)

**→ Default Settings for Emails:**
- **Apply a default label to emails:** `Confidential \ All Employees`
- **Require users to apply a label to their emails:** ☑ Yes
- **Email inherits highest priority label from attachments:** ☑ Yes

**→ Default Settings for Meetings and Calendar Events:**
- **Apply a default label to meetings and calendar events:** `Confidential \ All Employees`
- **Require users to apply a label to meetings and calendar events:** ☑ Yes
- **Inherit label from files shared to meetings:** ☑ Yes
- **Inheritance Mode:** Automatically apply highest priority label
- **Apply meeting label to artifacts (recordings, transcripts, and Loop notes):** ☑ Yes

**→ Default Settings for Fabric and Power BI Content:**
- **Apply a default label to Fabric and Power BI content:** `Confidential \ All Employees`
- **Require users to apply a label to their Fabric and Power BI content:** ☑ Yes

**Priority:** 2

**Status:** Published

---

#### **Policy 3: R&D / OT Policy**

**Policy Name:** `RD-OT-LabelingPolicy-TradeSecrets`

**Description:** Policy for Research & Development and Operational Technology teams with Restricted Trade Secret labels for proprietary formulas, manufacturing processes, engineering designs, and intellectual property.

**Labels Published:**
- Public
- Internal
- Confidential
  - All Employees
  - Internal Only
  - External Approved
- Restricted
  - Trade Secret

**Administrative Units:**
- **Admin Unit Assignment:** R&D OU, OT OU

**Users and Groups:**
- **Location:** Exchange Email
- **Users:** `RD-Security-Group@icpes.com`, `OT-Operations-Team@icpes.com`
- **Groups:** R&D, Operations Technology, CISO
- **Scope:** R&D and OT Users and Groups

**Policy Settings:**

**→ General Settings:**
- **Users must provide a justification to remove a label or lower its classification:** ☑ Yes
- **Require users to apply a label to their emails and documents:** ☑ Yes
- **Require users to apply a label to their Fabric and Power BI content:** ☑ Yes
- **Custom Help Page URL:** Not Configured

**→ Default Settings for Documents:**
- **Apply a default label to documents:** `Confidential \ Internal Only`
- **User Override Allowed:** ☑ Yes (downgrade requires justification)

**→ Default Settings for Emails:**
- **Apply a default label to emails:** `Confidential \ Internal Only`
- **Require users to apply a label to their emails:** ☑ Yes
- **Email inherits highest priority label from attachments:** ☑ Yes

**→ Default Settings for Meetings and Calendar Events:**
- **Apply a default label to meetings and calendar events:** `Confidential \ Internal Only`
- **Require users to apply a label to meetings and calendar events:** ☑ Yes
- **Inherit label from files shared to meetings:** ☑ Yes
- **Inheritance Mode:** Automatically apply highest priority label
- **Apply meeting label to artifacts (recordings, transcripts, and Loop notes):** ☑ Yes

**→ Default Settings for Fabric and Power BI Content:**
- **Apply a default label to Fabric and Power BI content:** `Confidential \ Internal Only`
- **Require users to apply a label to their Fabric and Power BI content:** ☑ Yes

**Priority:** 2

**Status:** Published

---

#### **Policy 4: Executive Management Policy**

**Policy Name:** `ExecutiveLabelingPolicy-Management`

**Description:** Policy for Executive Management, Board Members, and C-Level leadership with access to all classification labels, including Restricted classifications.

**Labels Published:**
- Public
- Internal
- Confidential
  - All Employees
  - Internal Only
  - External Approved
- Restricted
  - Strategic Financial
  - Trade Secret
  - Board Confidential
  - Executive Only

**Administrative Units:**
- **Admin Unit Assignment:** Executive OU

**Users and Groups:**
- **Location:** Exchange Email
- **Users:** `Management-Executive-Team@icpes.com`, `Board-Members@icpes.com`
- **Groups:** C-Suite, Board of Directors
- **Scope:** Executive Management Users and Groups

**Policy Settings:**

**→ General Settings:**
- **Users must provide a justification to remove a label or lower its classification:** ☑ Yes
- **Require users to apply a label to their emails and documents:** ☑ Yes
- **Require users to apply a label to their Fabric and Power BI content:** ☑ Yes
- **Custom Help Page URL:** Not Configured

**→ Default Settings for Documents:**
- **Apply a default label to documents:** `Confidential \ Internal Only`
- **User Override Allowed:** ☑ Yes (all downgrades require justification)

**→ Default Settings for Emails:**
- **Apply a default label to emails:** `Confidential \ Internal Only`
- **Require users to apply a label to their emails:** ☑ Yes
- **Email inherits highest priority label from attachments:** ☑ Yes

**→ Default Settings for Meetings and Calendar Events:**
- **Apply a default label to meetings and calendar events:** `Confidential \ Internal Only`
- **Require users to apply a label to meetings and calendar events:** ☑ Yes
- **Inherit label from files shared to meetings:** ☑ Yes
- **Inheritance Mode:** Automatically apply highest priority label
- **Apply meeting label to artifacts (recordings, transcripts, and Loop notes):** ☑ Yes

**→ Default Settings for Fabric and Power BI Content:**
- **Apply a default label to Fabric and Power BI content:** `Confidential \ Internal Only`
- **Require users to apply a label to their Fabric and Power BI content:** ☑ Yes

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

**Description:** Automatically applies `Confidential \ Internal Only` to content containing Kuwait Civil IDs, GCC National IDs, Work Permit Numbers, and Passport Numbers in accordance with Tier 3 (Confidential) classification requirements.

### Policy Type

- Automatically Apply Labels Only

#### Info to Label

- **Category:** Custom
- **Detection Method:** Custom Sensitive Information Types (SITs) and Built-in Sensitive Information Types
- **Purpose:** Identify and classify Personally Identifiable Information (PII) related to Kuwait and GCC employee identity records.

#### Label

- **Label to Auto-Apply:** `Confidential \ Internal Only`

#### Administrative Units

- **Admin Unit Assignment:** Full Directory

#### Locations

- ☑ SharePoint Sites: All Sites
- ☑ OneDrive Accounts: All Accounts
- ☑ Exchange Email: HR Department and Legal Team Mailboxes

#### Policy Rules

**Rule Type:** Common Rules

#### **Rule 1: Kuwait Civil ID Detected**

**Conditions:**

- Content contains **Kuwait Civil ID Number** (Custom Sensitive Information Type)
- Confidence Level: High
- Instance Count: At least 1 occurrence

**Action:**

- Apply Sensitivity Label: `Confidential \ Internal Only`

---

#### **Rule 2: GCC National ID Detected**

**Conditions:**

Content contains at least one of the following:

- UAE Identity Card Number (Built-in SIT)
- Saudi Arabia National ID (Built-in SIT)
- Qatar ID Number (Custom SIT)
- Bahrain Personal Number (Custom SIT)
- Oman Identity Card Number (Custom SIT)

**Additional Condition:**

- Instance Count: At least 1 occurrence

**Action:**

- Apply Sensitivity Label: `Confidential \ Internal Only`

---

#### **Rule 3: Work Permit or Passport Detected**

**Conditions:**

Content contains:

- Kuwait Work Permit Number (Custom SIT)

**OR**

- Passport Number (*requires verification of supported SIT and detection method*)

**Additional Condition:**

- Instance Count: At least 1 occurrence

**Action:**

- Apply Sensitivity Label: `Confidential \ Internal Only`

#### Additional Label Settings

- **Replace Existing Labels if Their Priority Is Lower:** ☑ Yes

**Behavior:**

- Existing labels with lower priority than `Confidential \ Internal Only` are automatically replaced.
- Applies across configured locations (Exchange, SharePoint, and OneDrive).

#### Policy Mode

- **Initial Mode:** Run Policy in Simulation Mode
- **Simulation Duration:** 14 Days
- **Validation Activity:** Review matched content, false positives, and rule accuracy
- **Post-Validation Mode:** Turn Policy On (Enforced Mode)

#### Notifications

- **User Notification:** ☐ No
- **Admin Monitoring and Review:** ☑ Yes

#### Status

**Active**
---
#### **Auto-Labeling Policy 2: Strategic Financial Data Detection**

**Policy Name:** `AutoLabel-Strategic-Financial`

**Description:** Automatically classifies strategic financial information and M&A-related content with the `Restricted \ Strategic Financial` sensitivity label.

#### Policy Type

- Automatically Apply Labels Only

#### Info to Label

- **Category:** Financial
- **Detection Method:** Built-in Sensitive Information Types, Trainable Classifiers, Keywords

#### Label

- **Label to Auto-Apply:** `Restricted \ Strategic Financial`

#### Administrative Units

- Finance OU

#### Locations

- ☑ SharePoint Sites
  - `/sites/Finance/Strategic`
  - `/sites/Finance/MergersAcquisitions`
  - `/sites/Finance/ExecutiveReports`
- ☑ OneDrive Accounts
  - `Finance-Leadership-Group@icpes.com`
  - `CFO-Office@icpes.com`
- ☑ Exchange Email
  - Finance Leadership
  - CFO Office
  - Treasury Team

#### Policy Rules

**Rule Type:** Common Rules

#### **Rule 1: Strategic Banking Data Detected**

**Conditions:**

- At least 2 instances of:
  - IBAN
  - SWIFT Code
  - Credit Card Number
- AND
  - File stored in Strategic Finance repositories
  - OR contains:
    - M&A
    - Strategic Pricing
    - Margin Analysis
    - Executive Compensation

**Action:**

- Apply Label: `Restricted \ Strategic Financial`

#### **Rule 2: M&A and Strategic Content Detected**

**Conditions:**

- Trainable Classifier Match:
  - Strategic Financial Reports
  - M&A Documents

**Action:**

- Apply Label: `Restricted \ Strategic Financial`

#### Additional Label Settings

- Replace Existing Labels if Their Priority Is Lower: ☑ Yes

### Policy Mode

- Run Policy in Simulation Mode
- Simulation Period: 14 Days
- Post Validation: Turn Policy On

#### Status

**Active**

---

#### **Auto-Labeling Policy 3: Trade Secret Detection**

**Policy Name:** `AutoLabel-Trade-Secrets`

**Description:** Automatically classifies proprietary formulas, manufacturing processes, and research content using the `Restricted \ Trade Secret` label.

#### Policy Type

- Automatically Apply Labels Only

#### Info to Label

- **Category:** Custom
- **Detection Method:** Keywords, Document Fingerprints, Custom SITs

#### Label

- **Label to Auto-Apply:** `Restricted \ Trade Secret`

#### Administrative Units

- R&D OU
- OT OU

#### Locations

- ☑ SharePoint Sites
  - `/sites/RD`
  - `/sites/OT`
  - `/sites/Research`
- ☑ OneDrive Accounts
  - `RD-Security-Group@icpes.com`
  - `OT-Operations-Team@icpes.com`
- ☑ Exchange Email
  - R&D Team
  - OT Team

#### Policy Rules

**Rule Type:** Common Rules

#### **Rule 1: Proprietary Content Detected**

**Conditions:**

- Stored in:
  - `/RD/Formulations`
  - `/OT/Processes`
  - `/Research/Proprietary`

- AND contains:
  - Proprietary
  - Trade Secret
  - Confidential Formula
  - Recipe
  - Manufacturing Process
  - ملكية
  - سري تجاري

**Action:**

- Apply Label: `Restricted \ Trade Secret`

#### **Rule 2: Document Fingerprint Match**

**Conditions:**

- Document Fingerprint Match:
  - Approved Trade Secret Templates

**Action:**

- Apply Label: `Restricted \ Trade Secret`

#### Additional Label Settings

- Replace Existing Labels if Their Priority Is Lower: ☑ Yes

#### Policy Mode

- Run Policy in Simulation Mode
- Simulation Period: 14 Days
- Post Validation: Turn Policy On

#### Status

**Pending (Phase 2)**

---

#### **Auto-Labeling Policy 4: IT Security Credentials Detection**

**Policy Name:** `AutoLabel-IT-Credentials`

#### Policy Type

- Automatically Apply Labels Only

#### Info to Label

- **Category:** Custom
- **Detection Method:** Custom SITs, Built-in SITs

#### Label

- **Label to Auto-Apply:** `Confidential \ Internal Only`

#### Administrative Units

- IT OU

#### Locations

- ☑ SharePoint Sites
  - `/sites/IT`
  - `/sites/DevOps`
  - `/sites/Infrastructure`

- ☑ OneDrive Accounts
  - `IT-Security-Team@icpes.com`
  - `DevOps-Team@icpes.com`

- ☑ Exchange Email
  - IT Team
  - Security Team

#### Policy Rules

**Rule Type:** Common Rules

#### **Rule 1: Azure/Cloud Credentials**

**Conditions:**

- Azure Storage Account Key (Custom SIT)
- Azure Subscription Key (Custom SIT)
- Azure SQL Connection String (Custom SIT)
- AWS Access Key (requires validation of built-in SIT availability)

#### **Rule 2: API Keys / SSH Keys**

**Conditions:**

- API Key Pattern (Custom SIT)
- SSH Private Key Pattern (Custom SIT)

#### Additional Label Settings

- Replace Existing Labels if Their Priority Is Lower: ☑ Yes

#### Policy Mode

- Run Policy in Simulation Mode
- Simulation Period: 14 Days
- Post Validation: Turn Policy On

#### Status

**Pending (Phase 2)**

---

#### **Auto-Labeling Policy 5: HR Employment Records Detection**

**Policy Name:** `AutoLabel-HR-Employment`

#### Policy Type

- Automatically Apply Labels Only

#### Info to Label

- **Category:** Privacy
- **Detection Method:** Custom SITs, Keywords

#### Label

- **Label to Auto-Apply:** `Confidential \ Internal Only`

#### Administrative Units

- HR OU

#### Locations

- ☑ SharePoint Sites
  - `/sites/HR`
  - `/sites/HRRecords`

- ☑ OneDrive Accounts
  - `HR-All-Users@icpes.com`

- ☑ Exchange Email
  - HR Team

#### Policy Rules

**Rule Type:** Common Rules

#### **Rule 1: Employment Contract**

**Conditions**

- Contract Keywords
- Kuwait Civil ID Number
- Date of Birth

#### **Rule 2: Labor File Number**

**Conditions**

- Kuwait Labor File Number (Custom SIT)

#### **Rule 3: Performance and Disciplinary Records**

**Conditions**

- Performance Review
- Disciplinary Action
- Warning Letter

#### Additional Label Settings

- Replace Existing Labels if Their Priority Is Lower: ☑ Yes

#### Policy Mode

- Run Policy in Simulation Mode
- Simulation Period: 14 Days
- Post Validation: Turn Policy On

#### Status

**Pending (Phase 2)**

---

#### **Auto-Labeling Policy 6: Legal Contract Detection**

**Policy Name:** `AutoLabel-Legal-Contracts`

#### Policy Type

- Automatically Apply Labels Only

#### Info to Label

- **Category:** Custom
- **Detection Method:** Keywords, Custom SITs

#### Label

- **Label to Auto-Apply:** `Confidential \ All Employees`

#### Administrative Units

- Legal OU

#### Locations

- ☑ SharePoint Sites
  - `/sites/Legal`
  - `/sites/Contracts`

- ☑ OneDrive Accounts
  - `Legal-Team@icpes.com`

- ☑ Exchange Email
  - Legal Team

#### Policy Rules

**Rule Type:** Common Rules

#### **Rule 1: Contract Document**

**Conditions**

- Contract-related keywords
- PDF or Word document

#### **Rule 2: Legal Case Reference**

**Conditions**

- Kuwait Legal Case Reference (Custom SIT)
- Kuwait Trade License Number (Custom SIT)

#### Additional Label Settings

- Replace Existing Labels if Their Priority Is Lower: ☑ Yes

#### Policy Mode

- Run Policy in Simulation Mode
- Simulation Period: 14 Days
- Post Validation: Turn Policy On

#### Status

**Pending (Phase 2)**

---

#### **Auto-Labeling Policy 7: Marketing Customer Data Detection**

**Policy Name:** `AutoLabel-Marketing-CustomerData`

#### Policy Type

- Automatically Apply Labels Only

#### Info to Label

- **Category:** Privacy
- **Detection Method:** Custom SITs, Keywords

#### Label

- **Label to Auto-Apply:** `Confidential \ Internal Only`

#### Administrative Units

- Marketing OU

#### Locations

- ☑ SharePoint Sites
  - `/sites/Marketing`
  - `/sites/CustomerData`

- ☑ OneDrive Accounts
  - `Marketing-Team@icpes.com`

- ☑ Exchange Email
  - Marketing Team

#### Policy Rules

**Rule Type:** Common Rules

#### **Rule 1: Customer Contact List**

**Conditions**

- Minimum 5 Email Address occurrences
- Minimum 5 Phone Number occurrences
- Customer List file names

#### **Rule 2: Marketing Campaign Data**

**Conditions**

- Marketing campaign repositories
- Customer segmentation keywords
- Campaign performance keywords

#### Additional Label Settings

- Replace Existing Labels if Their Priority Is Lower: ☑ Yes

#### Policy Mode

- Run Policy in Simulation Mode
- Simulation Period: 14 Days
- Post Validation: Turn Policy On

#### Status

**Pending (Phase 3)**

---

#### **Auto-Labeling Policy 8: Management Strategic Documents Detection**

**Policy Name:** `AutoLabel-Management-Strategic`

#### Policy Type

- Automatically Apply Labels Only

#### Info to Label

- **Category:** Custom
- **Detection Method:** Keywords, Trainable Classifiers

#### Label

- **Label to Auto-Apply:** `Confidential \ Internal Only`

#### Administrative Units

- Executive OU

#### Locations

- ☑ SharePoint Sites
  - `/sites/Executive`
  - `/sites/BoardOfDirectors`
  - `/sites/CLevel`

- ☑ OneDrive Accounts
  - `Management-Executive-Team@icpes.com`
  - `Board-Members@icpes.com`

- ☑ Exchange Email
  - Executive Management
  - Board Members

#### Policy Rules

**Rule Type:** Common Rules

#### **Rule 1: Board and Executive Documents**

**Conditions**

- Board Minutes
- Board Meeting
- Executive Summary
- Strategic Plan

#### **Rule 2: Strategic Planning Documents**

**Conditions**

- Strategic Initiative
- Roadmap
- 5-Year Plan
- Business Strategy
- Strategic Planning Documents (Trainable Classifier)
- Executive Reports (Trainable Classifier)

#### Additional Label Settings

- Replace Existing Labels if Their Priority Is Lower: ☑ Yes

#### Policy Mode

- Run Policy in Simulation Mode
- Simulation Period: 14 Days
- Post Validation: Turn Policy On

#### Status

**Pending (Phase 3)**

---
