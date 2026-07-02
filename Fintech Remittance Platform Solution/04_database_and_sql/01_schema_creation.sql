-- ==============================================================================
-- PROJECT: Remittance Platform
-- SCRIPT: 01_schema_creation.sql
-- PURPOSE: Define the core relational data model for users, KYC, and transactions.
-- ==============================================================================

-- 1. USERS TABLE (Senders and Recipients)
CREATE TABLE Users (
    UserID UUID PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    CountryCode CHAR(2) NOT NULL,
    PhoneNumber VARCHAR(20) UNIQUE NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. KYC & COMPLIANCE TABLE
CREATE TABLE KYC_Records (
    RecordID UUID PRIMARY KEY,
    UserID UUID REFERENCES Users(UserID),
    RiskScore INT CHECK (RiskScore BETWEEN 0 AND 100),
    VerificationStatus VARCHAR(20) DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED
    DocumentType VARCHAR(50),
    ReviewedBy VARCHAR(100), -- Null if auto-approved
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 3. CORE TRANSACTIONS TABLE
CREATE TABLE Transactions (
    TransactionID UUID PRIMARY KEY,
    SenderID UUID REFERENCES Users(UserID),
    RecipientID UUID REFERENCES Users(UserID),
    Amount DECIMAL(18, 2) NOT NULL,
    CurrencyCode VARCHAR(3) NOT NULL,
    ExchangeRate DECIMAL(10, 4) NOT NULL,
    FeeAmount DECIMAL(18, 2) NOT NULL,
    CurrentStatus VARCHAR(30) DEFAULT 'INITIATED', -- INITIATED, KYC_HOLD, PROCESSING, SETTLED, FAILED
    ComplianceFlag BOOLEAN DEFAULT FALSE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 4. TRANSACTION EVENT LOG (For Real-Time Tracking & Support)
CREATE TABLE Transaction_Events (
    EventID UUID PRIMARY KEY,
    TransactionID UUID REFERENCES Transactions(TransactionID),
    EventStatus VARCHAR(30) NOT NULL,
    EventDescription TEXT,
    TriggeredBy VARCHAR(50), -- API, SYSTEM, ADMIN
    EventTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. INDEXING FOR PERFORMANCE
-- Speeds up queries for support teams searching by status or active compliance holds
CREATE INDEX idx_transaction_status ON Transactions(CurrentStatus);
CREATE INDEX idx_kyc_status ON KYC_Records(VerificationStatus);
CREATE INDEX idx_event_tracking ON Transaction_Events(TransactionID);

-- Additional indexes for compliance and reporting queries
CREATE INDEX idx_user_country ON Users(CountryCode);
CREATE INDEX idx_transaction_sender ON Transactions(SenderID);
CREATE INDEX idx_transaction_recipient ON Transactions(RecipientID);
CREATE INDEX idx_transaction_created ON Transactions(CreatedAt);
CREATE INDEX idx_kyc_user ON KYC_Records(UserID);
