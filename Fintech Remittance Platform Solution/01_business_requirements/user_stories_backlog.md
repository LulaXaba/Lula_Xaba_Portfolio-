# 📖 User Stories & Acceptance Criteria Backlog

**Document Version:** 1.0  
**Last Updated:** July 2026  
**Format:** Agile User Stories with BDD (Behaviour-Driven Development) Acceptance Criteria  
**Product Owner:** Finance & Compliance  
**Status:** Ready for Sprint Planning

---

## 📌 Backlog Overview

This backlog contains **prioritized user stories** organized by **Epic**. Each story includes:
- **User Story Statement** (As a [User Type], I want [Action], so that [Benefit])
- **Business Context** (Why this matters)
- **Acceptance Criteria** (BDD Gherkin format for clarity)
- **Story Points** (Fibonacci scale: 1, 2, 3, 5, 8, 13)
- **Priority** (P0=Critical, P1=High, P2=Medium, P3=Low)

---

## 🎯 Epic 1: User Onboarding & KYC Verification

---

### **US-1.1: Register New User with Phone & Email**
**Priority:** P0 (Critical)  
**Story Points:** 5  
**Sprint:** Sprint 1  

**User Story:**
```
As a new customer,
I want to register with my phone number and email,
so that I can access the remittance platform quickly.
```

**Business Context:**  
Fast onboarding is a competitive advantage. Customers expect frictionless registration similar to fintech apps (Wise, Remitly). The mobile app must capture phone & email for account recovery and notifications.

**Acceptance Criteria:**

```gherkin
Feature: User Registration
  
  Scenario: Successful registration with valid phone number
    Given I am on the registration screen
    When I enter:
      | Field               | Value                    |
      | First Name          | Thabo                    |
      | Last Name           | Mokoena                  |
      | Phone Number        | 0821234567              |
      | Email               | thabo.mokoena@gmail.com |
      | Country             | South Africa             |
    And I click "Create Account"
    Then I should see "Account created successfully"
    And a UserID should be generated
    And an SMS should be sent with a verification code
    And the user status should be "PENDING_EMAIL_VERIFICATION"

  Scenario: Validation error - Invalid phone number format
    Given I am on the registration screen
    When I enter phone number "123" (invalid format)
    And I click "Create Account"
    Then I should see error "Phone number must be in valid format (e.g., 0821234567 or +27821234567)"
    And no account should be created

  Scenario: Duplicate phone number detection
    Given an existing user with phone "0821234567"
    When a new user tries to register with the same phone
    Then I should see message "This phone number is already registered. Sign in or reset password."
    And the user should be offered account recovery options

  Scenario: Verify email address
    Given I have registered with email "thabo@gmail.com"
    When I click the verification link in the email
    Then my email should be marked as "VERIFIED"
    And I should be prompted to upload ID document for KYC
```

**Technical Notes:**
- Phone validation: Regex pattern for E.164 format
- Duplicate check: Query Users table on INSERT attempt
- Email verification: 24-hour token expiry
- SMS delivery: Via Twilio integration

**Definition of Done:**
- ✅ API endpoint created: POST /api/v1/users/register
- ✅ Phone & email validation implemented
- ✅ Duplicate detection working
- ✅ SMS verification code sent
- ✅ Unit tests: 100% coverage
- ✅ Integration tests with Twilio mock
- ✅ QA sign-off on mobile app

---

### **US-1.2: Upload & Verify KYC Document (ID)**
**Priority:** P0 (Critical)  
**Story Points:** 8  
**Sprint:** Sprint 1

**User Story:**
```
As a registered user,
I want to upload my national ID or passport,
so that I can be verified and unlock higher transaction limits.
```

**Business Context:**  
KYC verification is mandatory for regulatory compliance (FIC AML). This is the gateway to enabling transactions. Fast, automated verification for low-risk users accelerates revenue.

**Acceptance Criteria:**

```gherkin
Feature: KYC Document Upload & Verification
  Background:
    Given I am a registered user with verified email
    And I am on the KYC upload screen

  Scenario: Successfully upload national ID
    When I select "National ID Card" as document type
    And I take a photo of my national ID (front side)
    And I confirm the image is clear and readable
    And I click "Upload"
    Then the system should display "Document received. Verifying..."
    And the document should be stored in secure storage
    And OCR processing should begin asynchronously

  Scenario: Automated KYC approval (Low-Risk)
    Given I have uploaded a clear national ID
    And the OCR extracted all required fields successfully
    And my risk score is calculated as 35 (Low Risk)
    When the background KYC job processes my document
    Then my KYC status should update to "APPROVED" within 60 seconds
    And I should receive SMS: "Welcome! You can now send money."
    And my transaction limit should be set to ZAR 100,000 daily

  Scenario: Manual KYC review required (Medium-Risk)
    Given I have uploaded a passport
    And my risk score is calculated as 65 (Medium Risk)
    When the background KYC job processes my document
    Then my KYC status should remain "PENDING"
    And an alert should be created for the compliance team
    And I should receive SMS: "Verification in progress. We'll notify you shortly."
    And daily transaction limit should be set to ZAR 50,000 (temporary)

  Scenario: Document upload fails - Poor quality
    Given I am uploading a blurry or partially obscured ID photo
    When the system analyzes the image
    Then it should calculate OCR confidence < 85%
    And I should see error: "Document quality too low. Please retake photo with better lighting."
    And I should be prompted to re-upload

  Scenario: Document upload fails - Expired ID
    Given I upload an ID with expiry date in the past
    When the system extracts the expiry date
    Then I should see error: "Your ID has expired. Please renew it and try again."
    And no verification should proceed

  Scenario: Document upload fails - Unsupported document type
    Given I try to upload a student ID or work permit
    When the system analyzes the document type
    Then I should see error: "This document type is not accepted. Please use a National ID or Passport."
    And the upload should be rejected
```

**Technical Notes:**
- OCR Engine: Google Cloud Vision API or AWS Rekognition
- Document Storage: Encrypted blob storage (Azure Blob or S3)
- Risk Scoring: ML model evaluates document quality + country + profile
- Compliance Queue: Manual review tasks assigned in compliance dashboard

**Definition of Done:**
- ✅ Document upload API: POST /api/v1/kyc/documents
- ✅ OCR integration working (confidence threshold: 85%)
- ✅ Risk scoring model deployed and tested
- ✅ Auto-approval workflow for low-risk users
- ✅ Compliance team dashboard for manual reviews
- ✅ Audit logs capture all document accesses
- ✅ Mobile app shows upload UX (camera integration)
- ✅ Encryption key management implemented
- ✅ QA sign-off; security scan complete

---

## 💰 Epic 2: Transaction Initiation & Processing

---

### **US-2.1: Initiate Remittance Transfer**
**Priority:** P0 (Critical)  
**Story Points:** 8  
**Sprint:** Sprint 2

**User Story:**
```
As an approved sender,
I want to enter recipient details and transfer amount,
so that I can send money to my family abroad.
```

**Business Context:**  
Core transaction creation. This is the revenue-generating feature. Must handle edge cases (daily limits, compliance holds) gracefully.

**Acceptance Criteria:**

```gherkin
Feature: Initiate Remittance Transfer
  Background:
    Given I am a KYC-approved sender
    And my daily limit is ZAR 100,000
    And my available balance is ZAR 50,000

  Scenario: Successful transaction initiation (Low-Risk)
    Given I navigate to "Send Money" screen
    When I enter:
      | Field                | Value              |
      | Recipient Phone      | +2348012345678    |
      | Amount (Send)        | ZAR 5,000         |
      | Recipient Currency   | USD               |
      | Payment Method       | EFT_LINK          |
    And I review the breakdown:
      | Fee (2%)             | ZAR 100           |
      | Exchange Rate        | 1 USD = 17.50 ZAR |
      | Recipient Gets       | ~USD 280          |
    And I click "Confirm Transfer"
    Then a TransactionID should be generated (e.g., tx_5592-abcd-1234)
    And the system should return HTTP 202 (Accepted)
    And I should see "Transfer initiated. Processing..."
    And the transaction status should be "INITIATED"
    And the transaction should move to "PROCESSING" within 5 seconds
    And I should be taken to the transaction tracking screen

  Scenario: Daily limit enforcement
    Given my daily limit is ZAR 100,000
    And I have already sent ZAR 90,000 today
    When I try to initiate a transfer of ZAR 20,000
    Then I should see error: "Daily limit exceeded. You can send up to ZAR 10,000 more today."
    And the transaction should not be created
    And no charge should be applied

  Scenario: Insufficient balance check
    Given my available balance is ZAR 5,000
    When I try to initiate a transfer of ZAR 8,000 (including fees)
    Then I should see error: "Insufficient balance. You need ZAR 8,100 (including fees). Please top up."
    And no transaction should be created

  Scenario: Recipient not registered (valid phone)
    Given I enter a valid, unregistered recipient phone number
    When I click "Confirm Transfer"
    Then the system should auto-create a placeholder recipient profile
    And the transaction should proceed
    And I should see message: "Recipient will be auto-registered upon funds arrival"
    And the recipient should receive SMS: "You have a pending transfer from [Sender Name]"

  Scenario: High-risk transaction triggers manual review
    Given my risk score is 78 (High-Risk)
    When I initiate a transfer of ZAR 15,000
    Then the transaction status should move to "KYC_HOLD" (not PROCESSING)
    And an alert should be sent to compliance team
    And I should see: "Transfer under review. We'll notify you shortly."
    And the transaction should not settle until manual approval

  Scenario: Transaction timeout (bank API unresponsive)
    Given the settlement API is taking > 30 seconds to respond
    When the system detects the timeout
    Then the transaction should move to "RETRY_QUEUE"
    And an alert should be sent to ops team
    And I should see: "Transfer in progress. Please check back in 30 minutes."
    And the system should retry automatically (exponential backoff)
```

**Technical Notes:**
- API Endpoint: POST /api/v1/transactions/initiate
- FX Rate: Real-time lookup from FX provider; cache for 5 minutes
- Balance Check: Query against Account ledger (soft-reserved during processing)
- Recipient Lookup: Check Users table; create temp profile if not found
- Compliance Check: Run risk-scoring async; hold if score > 75

**Definition of Done:**
- ✅ API endpoint working with all validation
- ✅ FX provider integration tested
- ✅ Daily limit enforcement working
- ✅ Compliance hold workflow tested
- ✅ Retry queue implemented
- ✅ Load test: 1,000 concurrent transactions
- ✅ Mobile UX approved by product
- ✅ QA sign-off; no critical bugs

---

### **US-2.2: View Real-Time Transaction Status**
**Priority:** P1 (High)  
**Story Points:** 5  
**Sprint:** Sprint 2

**User Story:**
```
As a sender,
I want to see real-time updates on my transfer status,
so that I know when my family will receive the money.
```

**Business Context:**  
Reduces support burden ("Where is my money?"). Transparency builds trust. Proactive push notifications > reactive support tickets.

**Acceptance Criteria:**

```gherkin
Feature: Real-Time Transaction Status Tracking
  Background:
    Given I have initiated a transfer with TransactionID "tx_5592-abcd-1234"

  Scenario: View transaction status (PROCESSING)
    Given the transaction is in PROCESSING status
    When I navigate to transaction details page
    Then I should see:
      | Field                      | Value                        |
      | Transaction ID             | tx_5592-abcd-1234           |
      | Status                     | 🟡 Processing               |
      | Amount Sent                | ZAR 5,100 (incl. fee)       |
      | Amount Recipient Gets      | ~USD 280                    |
      | Initiated At               | Jul 2, 2026 08:00 AM        |
      | Estimated Delivery         | Jul 2, 2026 2:00 PM         |
      | Recipient Phone            | +234 801 ****678            |

  Scenario: Real-time push notification - Status update
    Given a transaction is in PROCESSING status
    When the system updates status to SETTLED
    Then I should receive:
      - SMS: "Money sent! USD 280 will arrive in [Recipient Country] by 2:00 PM"
      - Push notification (in-app) with the same message
    And the status badge should change to 🟢 SETTLED
    And an estimated settlement time should be displayed

  Scenario: View detailed event timeline
    Given I click "View Timeline" on a settled transaction
    Then I should see:
      | Event # | Time              | Status                      | Details                                  |
      | 1       | 08:00 AM          | INITIATED                  | Transfer created via mobile app         |
      | 2       | 08:00:15 AM       | KYC_ASSESSED               | Risk score: 42 (Low Risk)               |
      | 3       | 08:00:30 AM       | PROCESSING                 | Routed to settlement                    |
      | 4       | 08:01:15 AM       | BANK_NOTIFIED              | Settlement message sent to partner bank |
      | 5       | 08:45 AM          | SETTLED                    | Funds cleared; reference: BK123456     |

  Scenario: Webhook callback delivered (for API clients)
    Given I registered a webhook URL: "https://myapp.com/webhooks/tx"
    When a transaction status changes
    Then the system should POST:
      ```json
      {
        "transaction_id": "tx_5592-abcd-1234",
        "status": "SETTLED",
        "timestamp": "2026-07-02T08:45:00Z",
        "idempotency_key": "webhook_evt_12345"
      }
      ```
    And the webhook should be retried 3 times if it fails
    And I should see delivery status in dashboard (Success / Failure)

  Scenario: Transaction failure notification
    Given a transaction fails due to compliance rejection
    When the system detects the failure
    Then I should receive SMS: "Your transfer was declined. Reason: Compliance review. Please contact support."
    And the transaction status should show "🔴 FAILED"
    And a refund should be initiated automatically
```

**Technical Notes:**
- API Endpoint: GET /api/v1/transactions/{transaction_id}/status
- Push Notifications: Firebase Cloud Messaging (FCM) for Android; APNs for iOS
- Webhook Retries: Exponential backoff (2s → 5s → 10s)
- Idempotency: All webhooks include idempotency key to prevent duplicate processing

**Definition of Done:**
- ✅ Status API endpoint implemented
- ✅ Push notification integration working (FCM + APNs)
- ✅ Webhook delivery with retry logic
- ✅ Event timeline visible in mobile app
- ✅ Load test: 10,000 concurrent status queries
- ✅ End-to-end integration test with mock bank
- ✅ QA sign-off

---

## 🔐 Epic 3: Compliance & Risk Management

---

### **US-3.1: Compliance Officer Manual Review Workflow**
**Priority:** P1 (High)  
**Story Points:** 8  
**Sprint:** Sprint 3

**User Story:**
```
As a compliance officer,
I want to review flagged transactions and make approval decisions,
so that I can ensure regulatory compliance and prevent fraud.
```

**Business Context:**  
Regulatory requirement. Must have audit trail. Compliance officers need clear, actionable dashboard. SLA: 4 business hours for review.

**Acceptance Criteria:**

```gherkin
Feature: Compliance Officer Manual Review
  Background:
    Given I am logged in as a compliance officer
    And I navigate to the "Pending Reviews" dashboard

  Scenario: View high-risk transaction in review queue
    Given there are 3 transactions pending manual review
    When I sort by "Created Time" descending
    Then I should see:
      | Transaction ID    | Sender          | Amount | Risk Factor  | Days Pending |
      | tx_5592-abcd-1234 | Thabo Mokoena   | ZAR 15k| High Risk    | < 1 hour     |
      | tx_4401-xyza-5678 | Maria Santos    | ZAR 25k| PEP Match    | 2 hours      |
      | tx_3310-pqrs-9101 | Hassan Ibrahim  | ZAR 12k| Grey Country | 5 hours      |

  Scenario: Approve low-risk transaction
    Given I click on transaction "tx_5592-abcd-1234"
    When I review:
      - Sender's KYC documents ✓ Valid
      - Risk score: 42 (Low Risk)
      - Transaction amount: ZAR 15,000 (within limits)
    And I click "APPROVE"
    Then the transaction should move to PROCESSING
    And I should see confirmation: "Transaction approved. Routing to settlement."
    And an audit log entry should be created:
      ```
      Action: APPROVED
      Admin: john.compliance@remittance.com
      Reason: Low-risk profile; within limits
      Timestamp: 2026-07-02 10:30:15 UTC
      ```

  Scenario: Reject transaction with reason code
    Given I click on transaction "tx_4401-xyza-5678"
    When I review the sender's profile:
      - PEP match: Maria Santos = Politically Exposed Person (High Government Official)
      - Source of funds: Unclear
    And I click "REJECT"
    And I select reason: "PEP_MATCH - Enhanced Due Diligence Required"
    And I add note: "PEP requires additional documentation before approval"
    And I click "Submit"
    Then the transaction should move to FAILED
    And an audit log should record my decision
    And an SMS should be sent to sender: "Your transfer was declined. Please contact support for more information."
    And an STR (Suspicious Transaction Report) should be auto-created

  Scenario: Place compliance hold for further investigation
    Given I'm reviewing transaction "tx_3310-pqrs-9101"
    When I need more time to investigate the grey-list destination
    And I click "PLACE HOLD"
    And I enter hold reason: "Additional beneficiary verification needed"
    And I set follow-up date: "2026-07-03 09:00 AM"
    Then the transaction should move to HOLD status
    And a calendar reminder should be set for the follow-up date
    And the transaction should auto-release or auto-reject after 30 days

  Scenario: View STR submissions history
    Given I navigate to "STR Submissions" tab
    When I filter by "Date: Last 30 Days"
    Then I should see:
      | STR ID     | Transaction  | Reason              | Submitted Date | FIC Ref |
      | STR_001    | tx_1234      | Cumulative Threshold| 2026-06-30    | FIC-2026-1234 |
      | STR_002    | tx_4401      | PEP Match           | 2026-07-02    | (Pending)     |
    And I should see submission confirmation from FIC

  Scenario: Dashboard KPI summary
    Given I'm on the compliance dashboard
    Then I should see:
      | Metric                  | Value    | Status |
      | Pending Reviews         | 3        | 🟡     |
      | Approved (24h)          | 42       | 🟢     |
      | Rejected (24h)          | 2        | 🟡     |
      | Avg Review Time         | 1.5 hrs  | 🟢     |
      | STRs Submitted (Month)  | 5        | 🟡     |
      | SLA Compliance          | 98%      | 🟢     |
```

**Technical Notes:**
- Dashboard: React-based admin UI with real-time WebSocket updates
- Audit Log: All actions immutable; no deletion allowed
- STR Auto-generation: System auto-creates STR when certain thresholds hit
- FIC Submission: Auto-submit STRs via secure API; track FIC reference numbers

**Definition of Done:**
- ✅ Compliance dashboard fully functional
- ✅ Audit logging 100% coverage
- ✅ STR auto-generation working
- ✅ FIC submission API integration tested
- ✅ User acceptance testing by compliance team
- ✅ 4-hour SLA monitoring alerts
- ✅ QA sign-off

---

## 📊 Epic 4: Analytics & Reporting

---

### **US-4.1: Real-Time Compliance Dashboard (Power BI)**
**Priority:** P2 (Medium)  
**Story Points:** 5  
**Sprint:** Sprint 4

**User Story:**
```
As a compliance manager,
I want to see real-time dashboards with transaction metrics,
so that I can monitor compliance KPIs and detect anomalies.
```

**Acceptance Criteria:**

```gherkin
Feature: Power BI Compliance Dashboard
  Background:
    Given I am a compliance manager
    And I have access to the Power BI dashboard

  Scenario: View daily transaction summary
    When I open the "Daily Summary" report
    Then I should see:
      - Total transactions: 247
      - Total volume (ZAR): 2,450,000
      - Approved: 245 (99.2%)
      - Rejected: 2 (0.8%)
      - STRs generated: 3
      - FX margin (avg): 2.5%
    And the data should refresh every 5 minutes

  Scenario: Identify transaction anomaly
    Given the system detects transaction volume spike
    When volume exceeds 500% of 30-day average
    Then a red alert should appear: "⚠️ Unusual activity detected"
    And I should be able to drill down to see:
      - Top senders (by volume)
      - Top destinations
      - Unusual payment methods
      - Time patterns

  Scenario: Export compliance report
    Given I navigate to "Monthly Reports"
    When I select "June 2026" and click "Export to PDF"
    Then a report should be generated containing:
      - Transaction volume trends
      - KYC approval rates
      - STR submissions
      - Rejected transaction reasons
      - Regulatory compliance checklist
    And the report should include FIC sign-off section
```

**Technical Notes:**
- BI Tool: Power BI Premium (auto-refresh via dataflow)
- Data Source: ETL from transaction database (nightly + hourly incremental)
- Refresh Schedule: Hourly for real-time dashboards; daily for compliance reports
- Row-Level Security (RLS): Each compliance officer sees only their region's data

**Definition of Done:**
- ✅ Power BI dataset model created (star schema)
- ✅ DAX measures for all KPIs
- ✅ ETL pipeline deployed and tested
- ✅ Dashboards validated by compliance team
- ✅ Performance: < 3-second query latency
- ✅ QA sign-off

---

## 📋 Backlog Prioritization & Release Planning

### **MVP (Minimum Viable Product) - Sprint 1-2:**
✅ US-1.1: User Registration  
✅ US-1.2: KYC Document Upload  
✅ US-2.1: Initiate Transaction  
✅ US-2.2: Transaction Tracking  

### **Phase 2 - Sprint 3-4:**
✅ US-3.1: Compliance Manual Review  
✅ US-4.1: Analytics Dashboard  

### **Phase 3 (Backlog):**
- 🎯 US-3.2: Automated Sanction List Screening
- 🎯 US-3.3: Enhanced Due Diligence (EDD) Workflow
- 🎯 US-4.2: Predictive Fraud Detection (ML Model)
- 🎯 US-5.1: Mobile Money Integration (MTN M-Pesa)
- 🎯 US-5.2: Blockchain Settlement (USDC Stablecoin)

---

## 📞 Story Refinement & Questions

**Open Questions for Product Owner:**
1. What is the acceptable latency for KYC verification (currently 60 seconds auto-approval)?
2. Should we support beneficiary pre-registration via SMS?
3. What is the compliance hold SLA (currently 30 days)?
4. Should we implement multi-currency wallets or on-demand conversion only?

**Team Capacity & Velocity:**
- Sprint velocity: ~21 story points per 2-week sprint
- Team size: 1 Backend Lead, 2 Backend Engineers, 1 Frontend, 1 QA
- Estimated MVP delivery: 4 sprints (8 weeks)

---

**Document approved by:**  
- Product Owner: [Signature]
- Scrum Master: [Signature]
- Tech Lead: [Signature]
