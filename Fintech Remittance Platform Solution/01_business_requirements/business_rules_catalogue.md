# 📋 Business Rules Catalogue: FIC-Aligned Compliance Framework

**Document Version:** 1.0  
**Last Updated:** July 2026  
**Classification:** Internal Use Only  
**Compliance Reference:** FIC (Financial Intelligence Centre), POPIA, ISO 20022

---

## 📌 Executive Summary

This catalogue documents all business rules governing the Remittance Platform, with emphasis on **FIC Anti-Money Laundering (AML)** compliance, **Know Your Customer (KYC)** requirements, and **transaction routing logic**. Each rule includes the regulatory basis, implementation details, and exception handling procedures.

---

## 🔐 Section 1: KYC & Identity Verification Rules

### **RULE 1.1: Risk-Based KYC Classification**

**Regulatory Basis:** FIC AML Regulations Section 21 (Know Your Customer)  
**Business Objective:** Classify users into risk tiers to determine onboarding speed and transaction limits  

**Rule Definition:**

```
IF Risk_Score < 50:
    Classification = "LOW_RISK"
    KYC_Status = AUTO_APPROVED (no manual review)
    Onboarding_Timeline = "Immediate"
    Daily_Limit_ZAR = 100,000
    Monthly_Limit_ZAR = 500,000

ELSE IF Risk_Score BETWEEN 50 AND 75:
    Classification = "MEDIUM_RISK"
    KYC_Status = MANUAL_REVIEW (compliance officer review)
    Onboarding_Timeline = "24-48 hours"
    Daily_Limit_ZAR = 50,000
    Monthly_Limit_ZAR = 200,000

ELSE IF Risk_Score > 75:
    Classification = "HIGH_RISK"
    KYC_Status = ESCALATED (senior analyst + manager approval)
    Onboarding_Timeline = "3-5 business days"
    Daily_Limit_ZAR = 10,000
    Monthly_Limit_ZAR = 50,000
    Additional_Action = "Ongoing Enhanced Due Diligence (EDD)"
```

**Risk Score Calculation Factors:**

| Factor | Weight | Low Risk | Medium Risk | High Risk |
| :--- | :--- | :--- | :--- | :--- |
| Document Quality | 20% | High-res, valid | Acceptable | Blurry, expired |
| Country of Residence | 25% | Developed economy | Emerging market | FATF Grey List |
| Transaction Pattern | 20% | Small, regular | Moderate variance | Large, irregular |
| PEP Status | 25% | Clear | Under review | Confirmed PEP |
| Sanctions Check | 10% | Clear | No hits | Potential match |

**Implementation:** ML model scores document OCR, cross-references OFAC/UN sanctions lists, analyzes transaction patterns.

---

### **RULE 1.2: Document Type Acceptance**

**Regulatory Basis:** FIC AML Regulations Section 21(1)(c) (Identity verification documentation)  
**Business Objective:** Ensure only government-issued ID is accepted for KYC verification

**Acceptable Documents (in order of preference):**

| Priority | Document Type | Issuing Authority | Validity | Notes |
| :--- | :--- | :--- | :--- | :--- |
| 1 | National ID Card | National Government | 10 years | Preferred; supports biometric matching |
| 2 | Passport | National Government | 10 years | Widely accepted; international standard |
| 3 | Driver's License | Provincial Authority | 5 years | Secondary option; may require additional verification |

**Rejected Documents:**
❌ Student IDs  
❌ Work permits (unless government-issued national ID also provided)  
❌ Library cards, gym membership  
❌ Digital-only IDs without biometric backing  

**Document Validation Rules:**

```
VALIDATE_DOCUMENT(document):
  IF document_type NOT IN ["NATIONAL_ID", "PASSPORT", "DRIVER_LICENSE"]:
    RETURN REJECT("Document type not supported")
  
  IF document_expiry_date < TODAY():
    RETURN REJECT("Document has expired")
  
  IF document_issue_date > TODAY():
    RETURN REJECT("Document issue date is in the future")
  
  IF OCR_confidence < 85%:
    RETURN REQUEST_RESUBMISSION("Document quality too low for automated OCR")
  
  IF document_country NOT IN approved_countries_list:
    RETURN REJECT("Transactions from this country not supported")
  
  RETURN APPROVE()
```

---

### **RULE 1.3: Duplicate User Detection & Account Linking**

**Regulatory Basis:** FIC requirement to maintain single customer view  
**Business Objective:** Prevent account fraud; support legitimate multi-account users

**Detection Method:**

```
DETECT_DUPLICATE_USER(phone, national_id, email):
  existing_user = QUERY Users WHERE 
    PhoneNumber = phone OR 
    NationalID = national_id OR 
    Email = email
  
  IF existing_user EXISTS:
    IF existing_user.KYC_Status = "APPROVED":
      // Legitimate user, reuse account
      LINK_ACCOUNT(new_registration, existing_user)
      NOTIFY("Account linked; existing limits apply")
      RETURN existing_user.UserID
    
    ELSE IF existing_user.KYC_Status = "PENDING":
      // Duplicate registration attempt
      REJECT("Account pending verification; use existing account")
      LOG_SUSPICIOUS_ACTIVITY(new_registration)
      RETURN ERROR_409_CONFLICT
    
    ELSE IF existing_user.KYC_Status = "REJECTED":
      // Previous rejection; escalate
      FLAG_FOR_MANUAL_REVIEW("Account reactivation request")
      RETURN ERROR_403_FORBIDDEN
  
  ELSE:
    CREATE_NEW_USER(phone, national_id, email)
    RETURN new_user.UserID
```

---

## 💰 Section 2: Transaction Routing & Compliance Rules

### **RULE 2.1: Daily & Monthly Transaction Limits**

**Regulatory Basis:** FIC Reporting Rules (threshold-based suspicious transaction reporting)  
**Business Objective:** Enforce risk-based limits; trigger monitoring for high-value transfers

**Limit Rules:**

```
IF user.RiskClassification = "LOW_RISK":
  daily_limit = 100,000 ZAR
  monthly_limit = 500,000 ZAR
  cumulative_transactions_trigger = 1,000,000 ZAR (30 days)

ELSE IF user.RiskClassification = "MEDIUM_RISK":
  daily_limit = 50,000 ZAR
  monthly_limit = 200,000 ZAR
  cumulative_transactions_trigger = 500,000 ZAR (30 days)

ELSE IF user.RiskClassification = "HIGH_RISK":
  daily_limit = 10,000 ZAR
  monthly_limit = 50,000 ZAR
  cumulative_transactions_trigger = 100,000 ZAR (30 days)

// Enforcement
IF new_transaction.amount > daily_limit:
  REJECT("Daily limit exceeded")
  LOG_LIMIT_BREACH()

ELSE IF (user.transactions_month_to_date + new_transaction.amount) > monthly_limit:
  REJECT("Monthly limit exceeded")
  LOG_LIMIT_BREACH()

ELSE IF (user.cumulative_30day + new_transaction.amount) > cumulative_trigger:
  FLAG_TRANSACTION("Cumulative threshold breached; flag for AML review")
  ALLOW_BUT_MONITOR(transaction)
```

---

### **RULE 2.2: Beneficiary Country Screening**

**Regulatory Basis:** FIC Sanctions List (aligned with UN, OFAC, EU)  
**Business Objective:** Prevent remittances to high-risk, sanctioned, or terrorism-financing countries

**Blacklist Countries (Do Not Serve):**

| Country | Reason | Last Updated | Review |
| :--- | :--- | :--- | :--- |
| 🚫 Iran | UN Sanctions | July 2026 | Quarterly |
| 🚫 North Korea | OFAC Sanctions | July 2026 | Quarterly |
| 🚫 Syria | OFAC Sanctions | July 2026 | Quarterly |
| 🚫 Crimea | Regional conflict | July 2026 | Monthly |

**Grey List Countries (Enhanced Monitoring Required):**

| Country | Status | Mitigation |
| :--- | :--- | :--- |
| 🟡 Pakistan | FATF Grey List | Require additional beneficiary verification |
| 🟡 Turkey | High-risk transit | Flag for AML review |
| 🟡 UAE | High-value remittance hub | Monitor for structuring patterns |

**Rule Implementation:**

```
VALIDATE_BENEFICIARY_COUNTRY(recipient_country):
  IF recipient_country IN blacklist_countries:
    REJECT("Transactions to this country are not supported")
    LOG_BLOCKED_TRANSACTION()
    NOTIFY_COMPLIANCE_TEAM()
  
  ELSE IF recipient_country IN grey_list_countries:
    RETRIEVE_ENHANCED_BENEFICIARY_INFO(recipient)
    IF beneficiary_verification_level < ENHANCED:
      REQUIRE_ADDITIONAL_VERIFICATION(recipient)
    ALLOW_WITH_MONITORING(transaction)
  
  ELSE:
    ALLOW(transaction)
```

---

### **RULE 2.3: Suspicious Transaction Reporting (STR) Threshold**

**Regulatory Basis:** FIC Reporting Rules; mandatory STR submission within 30 days  
**Business Objective:** Identify and report transactions with AML red flags

**STR Triggers (Any of the Following):**

1. **Transaction Amount:** Single transaction > ZAR 500,000 (or equivalent foreign currency)
2. **Cumulative Pattern:** 10+ transactions totaling > ZAR 1,000,000 in 30 days (consistent with structuring)
3. **Beneficiary Country:** Destination is grey-list country + sender has no documented business relationship
4. **Timing Anomaly:** Transaction at 23:59 (attempting to avoid day-change detection)
5. **Velocity:** > 5 transactions per day from same sender (potential layering)
6. **Mismatch:** Stated purpose (e.g., "family support") inconsistent with amount or frequency
7. **PEP Connection:** Sender or beneficiary matches Politically Exposed Person database
8. **Sanctions Hit:** OFAC/UN database match (automated daily scan)

**Rule Implementation:**

```
EVALUATE_STR_TRIGGER(transaction):
  risk_flags = 0
  
  IF transaction.amount > 500000:
    risk_flags += 1
    FLAG_REASON = "High transaction amount"
  
  IF user.transactions_30day_count > 10 AND user.cumulative_30day > 1000000:
    risk_flags += 1
    FLAG_REASON = "Potential structuring pattern"
  
  IF recipient_country IN grey_list:
    risk_flags += 1
    FLAG_REASON = "Grey-list destination"
  
  IF check_pep_database(sender.name) = TRUE:
    risk_flags += 2  // Higher weight for PEP
    FLAG_REASON = "Sender identified as PEP"
  
  IF risk_flags >= 2:
    CREATE_STR_RECORD(transaction)
    LOG_FOR_SUBMISSION("Submit to FIC within 30 days")
    ROUTE_TO_COMPLIANCE_QUEUE("Manual review required")
    RETURN SUSPEND_PENDING_APPROVAL
  
  ELSE:
    RETURN ALLOW(transaction)
```

---

## 🔄 Section 3: Transaction Lifecycle Rules

### **RULE 3.1: Transaction State Transitions**

**Regulatory Basis:** FIC audit trail requirements; transaction tracking for dispute resolution  
**Business Objective:** Enforce valid state transitions; prevent unauthorized status changes

**Valid State Diagram:**

```
INITIATED → KYC_HOLD → PROCESSING → SETTLED ✓
INITIATED → KYC_HOLD → FAILED ✗
INITIATED → PROCESSING → SETTLED ✓
INITIATED → PROCESSING → FAILED ✗
PROCESSING → RETRY_QUEUE → PROCESSING → SETTLED ✓
PROCESSING → RETRY_QUEUE → PROCESSING → FAILED ✗
INITIATED → CANCELLED (Admin only, within 15 minutes) ✓
```

**Rule:**

```
VALIDATE_STATE_TRANSITION(transaction, new_state):
  current_state = transaction.current_status
  valid_transitions = state_machine[current_state]
  
  IF new_state NOT IN valid_transitions:
    REJECT("Invalid state transition")
    LOG_AUDIT("Attempted invalid transition from %s to %s", 
             current_state, new_state)
    ALERT_SECURITY_TEAM()
  
  ELSE:
    UPDATE transaction.current_status = new_state
    INSERT_EVENT(transaction_id, new_state, CURRENT_TIMESTAMP)
    LOG_AUDIT("State transition: %s → %s", current_state, new_state)
```

---

### **RULE 3.2: Compliance Hold & Exception Handling**

**Regulatory Basis:** FIC AML Regulations (temporary hold for investigation)  
**Business Objective:** Allow compliance team to place holds on suspicious transactions

**Hold Rules:**

```
CREATE_COMPLIANCE_HOLD(transaction, reason, admin_id):
  IF transaction.current_status IN ["KYC_HOLD", "PROCESSING"]:
    transaction.compliance_hold_flag = TRUE
    transaction.hold_reason = reason  // e.g., "STR_PENDING", "PEP_REVIEW"
    transaction.held_by = admin_id
    transaction.hold_timestamp = CURRENT_TIMESTAMP
    
    INSERT_AUDIT_LOG("Compliance hold placed")
    NOTIFY_COMPLIANCE_TEAM("Hold placed on transaction %s", transaction.id)
    
    RETURN SUCCESS
  
  ELSE:
    REJECT("Cannot place hold on settled/failed transactions")

RELEASE_COMPLIANCE_HOLD(transaction, reason, admin_id):
  IF transaction.compliance_hold_flag = TRUE:
    transaction.compliance_hold_flag = FALSE
    transaction.hold_released_by = admin_id
    transaction.hold_release_timestamp = CURRENT_TIMESTAMP
    
    // Resume processing from where it left off
    IF transaction.current_status = "KYC_HOLD":
      TRIGGER_KYC_REASSESSMENT(transaction)
    
    ELSE IF transaction.current_status = "PROCESSING":
      TRIGGER_SETTLEMENT_RETRY(transaction)
    
    INSERT_AUDIT_LOG("Compliance hold released: %s", reason)
    
    RETURN SUCCESS
```

**Maximum Hold Duration:** 30 calendar days (per FIC regulations)  
**Escalation:** If hold not released after 30 days, auto-reject transaction + refund sender

---

## 📊 Section 4: Reporting & Compliance Metrics

### **RULE 4.1: Daily Compliance Dashboard Metrics**

**Regulatory Basis:** FIC monitoring requirements  
**Business Objective:** Track KPIs for compliance team; detect anomalies in real-time

**Key Metrics (Generated Daily at 02:00 UTC):**

| Metric | Formula | Threshold Alert | Owner |
| :--- | :--- | :--- | :--- |
| **Transaction Volume** | COUNT(transactions where status = 'SETTLED') | > 500% of avg | Ops |
| **KYC Approval Rate** | APPROVED / (APPROVED + REJECTED) | < 80% | Compliance |
| **STR Queue Size** | COUNT(transactions with STR_flag = TRUE) | > 50 pending | Compliance |
| **Average Hold Duration** | AVG(hold_release_timestamp - hold_timestamp) | > 5 days | Ops |
| **Failed Settlements** | COUNT(where status = 'FAILED') | > 10% of volume | Ops |
| **Average Daily Volume (ZAR)** | SUM(transaction amounts) | > 10M ZAR | Finance |

**Alert Escalation:** If any metric exceeds threshold, email sent to Compliance Manager + CFO

---

## ✅ Section 5: Audit & Exception Handling

### **RULE 5.1: Transaction Audit Trail**

**Regulatory Basis:** POPIA Section 14 (Information Officer requirements); FIC Section 28  
**Business Objective:** Maintain immutable audit log for 7-year regulatory retention

**Audit Logging Requirements:**

```
FOR EACH transaction event:
  INSERT INTO Transaction_Events:
    - EventID (UUID)
    - TransactionID (FK to transaction)
    - EventStatus (e.g., INITIATED, KYC_HOLD, SETTLED)
    - EventDescription (free text)
    - TriggeredBy (API, SYSTEM, ADMIN)
    - EventTimestamp (UTC)
    - IP_Address (if user-triggered)
    - User_ID (if admin action)
    - [IMMUTABLE] No UPDATE or DELETE allowed
```

**Retention Policy:**
- **7 years:** Full transaction records + audit trail (regulatory minimum)
- **2 years:** Detailed event logs (compliance investigation)
- **30 days:** Real-time monitoring data (performance tracking)

---

### **RULE 5.2: Exception Escalation Matrix**

**Business Objective:** Ensure high-risk scenarios are escalated to appropriate authority

| Scenario | Initial Decision | Escalation Path | SLA |
| :--- | :--- | :--- | :--- |
| STR Threshold Exceeded | Auto-flag | → Compliance Officer | 2 hours |
| PEP Match Detected | Hold transaction | → Compliance Manager | 4 hours |
| Sanctions Hit | Reject + Alert | → Legal + Compliance Manager | Immediate |
| 30-Day Hold Expiry | Auto-reject | → Operations + Compliance | Immediate |
| >5 Failed Settlements | Auto-retry queue | → Engineering + Ops | 24 hours |
| Daily Volume Spike 500% | Alert | → Compliance Manager + CFO | 1 hour |

---

## 📝 Rule Maintenance & Version Control

| Version | Date | Changes | Approved By |
| :--- | :--- | :--- | :--- |
| 1.0 | July 2026 | Initial rules catalogue (18 rules) | Compliance Manager |
| 1.1 (Planned) | Q3 2026 | Add biometric verification rule | — |
| 2.0 (Planned) | Q4 2026 | Blockchain settlement rules | — |

**Review Cycle:** Quarterly (or when regulations change)  
**Last Reviewed:** July 2026  
**Next Review:** October 2026
