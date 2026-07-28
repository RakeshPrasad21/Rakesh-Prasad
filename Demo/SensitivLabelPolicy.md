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
