# 🗺️ Data Mapping Matrix: User Onboarding to Database

**Source System:** Mobile App Front-End (Registration Screen)  
**Target System:** Core SQL Database (`Users` and `KYC_Records` tables)  
**Mapping Version:** 1.0 | **Last Updated:** July 2026

---

## 📋 Field-Level Mapping

| Source Field (Front-End) | Target Table | Target Column | Data Type | Transformation / Validation Rule | Mandatory | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `First Name` | `Users` | `FirstName` | `VARCHAR(100)` | Strip special characters, capitalize first letter. Max 100 chars. | Yes | Reject if contains numbers or symbols |
| `Last Name` | `Users` | `LastName` | `VARCHAR(100)` | Strip special characters, capitalize first letter. Max 100 chars. | Yes | Reject if contains numbers or symbols |
| `Mobile Number` | `Users` | `PhoneNumber` | `VARCHAR(20)` | Convert to international format (e.g., replace '0' with '+27' for SA). Validate E.164 standard. | Yes | Must be unique; reject duplicates |
| `Country of Residence` | `Users` | `CountryCode` | `CHAR(2)` | Map dropdown selection to ISO 3166-1 alpha-2 code (e.g., South Africa → 'ZA'). | Yes | Validate against FIC approved countries list |
| `Email Address` | `Users` | `EmailAddress` | `VARCHAR(255)` | Validate RFC 5322 format. Convert to lowercase. | Yes | Must be unique; used for account recovery |
| `ID Document Type` | `KYC_Records` | `DocumentType` | `VARCHAR(50)` | Enforce file format (PDF, JPG, PNG). Max size 5MB. Map to enum: 'PASSPORT', 'NATIONAL_ID', 'DRIVER_LICENSE'. | Yes | Reject unsupported formats |
| `ID Document Upload` | `KYC_Records` | `DocumentBlob` | `BLOB` | Store base64-encoded document. Encrypt at rest. | Yes | PII data - subject to POPIA encryption requirements |
| *(System Generated)* | `Users` | `UserID` | `UUID` | Auto-generate unique identifier. | System | Primary key; created by application layer |
| *(System Generated)* | `KYC_Records` | `RecordID` | `UUID` | Auto-generate unique identifier. | System | Primary key; created by application layer |
| *(System Generated)* | `KYC_Records` | `VerificationStatus` | `VARCHAR(20)` | Default value: 'PENDING'. Updated asynchronously via KYC microservice. | System | Enum: PENDING, APPROVED, REJECTED |
| *(System Generated)* | `KYC_Records` | `RiskScore` | `INT` | Null upon entry. Updated asynchronously via Risk Engine webhook after document OCR. Range: 0-100. | System | Driven by ML model; triggers compliance routing |
| *(System Generated)* | `Users` | `CreatedAt` | `TIMESTAMP` | Set to current UTC timestamp. | System | Audit trail; immutable |

---

## 🔍 Exception Handling & Business Rules

### **Rule 1: High-Risk Country Screening**
If `Country of Residence` is flagged against the **FATF High-Risk Jurisdictions list**, the API must:
- Return HTTP 400 with message: `"Transactions from this country are not supported at this time."`
- Log the attempt for audit purposes
- Do NOT create a User record

**Affected Countries (Example):** Iran, North Korea, Syria, Crimea  
**Maintenance:** FATF list reviewed quarterly

---

### **Rule 2: Duplicate Phone Number Detection**
Before inserting into `Users` table, check if `PhoneNumber` already exists:
- If **Duplicate Found & KYC Approved:** Link transaction to existing user (re-use UserID)
- If **Duplicate Found & KYC Pending:** Return 409 Conflict; ask user to verify account
- **Rationale:** Prevents multiple registrations by same person; supports account linking

---

### **Rule 3: Risk Score-Based KYC Routing**
After Risk Engine calculates `RiskScore`, trigger automated routing:

| Risk Score | Action | Owner |
| :--- | :--- | :--- |
| 0–50 | Auto-approve; set `VerificationStatus = 'APPROVED'` | SYSTEM |
| 51–75 | Queue for manual review; set `VerificationStatus = 'PENDING'` | COMPLIANCE_OFFICER |
| 76–100 | Escalate; flag for senior analyst; consider rejection | COMPLIANCE_MANAGER |

---

### **Rule 4: Document Validation**
`DocumentType` mapping must match file upload validation:

| Document Type | Accepted Formats | Max File Size | OCR Required | Notes |
| :--- | :--- | :--- | :--- | :--- |
| PASSPORT | PDF, JPG, PNG | 5 MB | Yes | Must show full name, DOB, expiry |
| NATIONAL_ID | PDF, JPG, PNG | 5 MB | Yes | Must show ID number, country of issue |
| DRIVER_LICENSE | PDF, JPG, PNG | 3 MB | Yes | Backup option; not primary |

---

## 🔐 Data Security & Compliance Mapping

| Requirement | Implementation | Mapping Reference |
| :--- | :--- | :--- |
| **POPIA Encryption** | All PII columns encrypted at rest (AES-256) | `KYC_Records.DocumentBlob` |
| **GDPR Compliance** | User can request data export/deletion; logged in audit table | `Users` table has deletion flags |
| **FIC Screening** | Country codes validated against FATF list on insert | `Users.CountryCode` validation rule |
| **AML Sanction List** | Phone/email cross-referenced with FinCEN SDN list | Pre-insert validation hook |

---

## 📊 Data Quality Metrics

After each batch import (e.g., from mobile app to database), validate:

- **Duplicate Rates:** < 2% acceptable; flag anything above
- **Rejected Records:** Log all validation failures with reason code
- **Null Percentages:** Optional fields can be null; mandatory fields must be 100% populated
- **Processing Latency:** End-to-end mapping (front-end to database) must complete within 500ms (p99)

---

## 🔄 Backward Compatibility & Versioning

| Version | Changes | Date | Status |
| :--- | :--- | :--- | :--- |
| 1.0 | Initial mapping; 10 core fields | July 2026 | ACTIVE |
| 2.0 (Planned) | Add biometric field; expand country list | Q3 2026 | PLANNED |

---

## 📞 Support & Questions

For data mapping clarifications or exceptions, contact:
- **Data Engineering Team:** data-eng@remittance-platform.com
- **Compliance Officer:** compliance@remittance-platform.com
