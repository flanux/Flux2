-- ============================================
-- Regulatory Reporting Service Database Schema
-- ============================================

CREATE DATABASE regulatory_db;

\c regulatory_db;

CREATE USER regulatory_user WITH PASSWORD 'regulatory_pass_2024';
GRANT ALL PRIVILEGES ON DATABASE regulatory_db TO regulatory_user;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Report Types
CREATE TYPE report_type AS ENUM (
    'CTR',          -- Currency Transaction Report
    'SAR',          -- Suspicious Activity Report
    'OFAC',         -- OFAC Compliance Report
    'AML',          -- Anti-Money Laundering Report
    'KYC_STATS',    -- KYC Statistics Report
    'TRANSACTION',  -- Transaction Summary Report
    'BALANCE',      -- Balance Sheet Report
    'INCOME',       -- Income Statement
    'CASHFLOW',     -- Cash Flow Statement
    'CAPITAL',      -- Capital Adequacy Report
    'LIQUIDITY',    -- Liquidity Report
    'RISK',         -- Risk Assessment Report
    'CUSTOM'        -- Custom Regulatory Report
);

-- Report Status
CREATE TYPE report_status AS ENUM (
    'DRAFT', 'PENDING_REVIEW', 'APPROVED', 
    'SUBMITTED', 'ACCEPTED', 'REJECTED', 'AMENDED'
);

-- Regulatory Reports
CREATE TABLE regulatory_reports (
    id BIGSERIAL PRIMARY KEY,
    report_id UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    
    -- Report Details
    report_type report_type NOT NULL,
    report_name VARCHAR(255) NOT NULL,
    report_status report_status DEFAULT 'DRAFT',
    
    -- Period
    reporting_period VARCHAR(50) NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    
    -- Regulation
    regulation_name VARCHAR(255),
    regulation_code VARCHAR(50),
    regulatory_authority VARCHAR(255),
    
    -- Submission
    submission_deadline DATE,
    submitted_at TIMESTAMP,
    submitted_by VARCHAR(100),
    acknowledgment_number VARCHAR(100),
    
    -- Content
    report_data JSONB NOT NULL,
    summary TEXT,
    
    -- File
    file_path VARCHAR(500),
    file_format VARCHAR(20),
    file_size BIGINT,
    
    -- Approval Workflow
    created_by VARCHAR(100) NOT NULL,
    reviewed_by VARCHAR(100),
    approved_by VARCHAR(100),
    
    reviewed_at TIMESTAMP,
    approved_at TIMESTAMP,
    
    -- Rejection
    rejection_reason TEXT,
    rejected_by VARCHAR(100),
    rejected_at TIMESTAMP,
    
    -- Amendments
    is_amended BOOLEAN DEFAULT FALSE,
    original_report_id UUID REFERENCES regulatory_reports(report_id),
    amendment_reason TEXT,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Currency Transaction Reports (CTR) - Transactions > $10,000
CREATE TABLE ctr_reports (
    id BIGSERIAL PRIMARY KEY,
    report_id UUID REFERENCES regulatory_reports(report_id) ON DELETE CASCADE,
    
    -- Transaction Details
    transaction_id VARCHAR(100) NOT NULL,
    transaction_date DATE NOT NULL,
    transaction_amount DECIMAL(19, 2) NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    
    -- Customer Details
    customer_id BIGINT NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    customer_ssn VARCHAR(20),
    customer_address TEXT,
    
    -- Account Details
    account_number VARCHAR(50),
    account_type VARCHAR(50),
    
    -- Additional Info
    purpose_of_transaction TEXT,
    is_suspicious BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT valid_ctr_amount CHECK (transaction_amount >= 10000)
);

-- Suspicious Activity Reports (SAR)
CREATE TABLE sar_reports (
    id BIGSERIAL PRIMARY KEY,
    report_id UUID REFERENCES regulatory_reports(report_id) ON DELETE CASCADE,
    
    -- Subject Information
    subject_type VARCHAR(50) NOT NULL, -- CUSTOMER, EMPLOYEE, THIRD_PARTY
    subject_name VARCHAR(255) NOT NULL,
    subject_id BIGINT,
    
    -- Activity Details
    activity_type VARCHAR(100) NOT NULL,
    activity_description TEXT NOT NULL,
    suspicious_indicators TEXT[],
    
    -- Financial Details
    total_amount DECIMAL(19, 2),
    transaction_count INT,
    date_range_start DATE,
    date_range_end DATE,
    
    -- Evidence
    supporting_documents JSONB,
    involved_accounts TEXT[],
    involved_transactions TEXT[],
    
    -- Investigation
    investigator_name VARCHAR(100),
    investigation_notes TEXT,
    investigation_completed BOOLEAN DEFAULT FALSE,
    
    -- Submission
    filed_with VARCHAR(100), -- FinCEN, OFAC, etc.
    filing_date DATE,
    confirmation_number VARCHAR(100),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- AML Monitoring Rules
CREATE TABLE aml_rules (
    id BIGSERIAL PRIMARY KEY,
    rule_name VARCHAR(255) NOT NULL,
    rule_code VARCHAR(50) UNIQUE NOT NULL,
    rule_description TEXT,
    
    -- Rule Logic
    rule_type VARCHAR(50) NOT NULL, -- THRESHOLD, PATTERN, VELOCITY, GEOGRAPHIC
    rule_criteria JSONB NOT NULL,
    threshold_amount DECIMAL(19, 2),
    time_window_hours INT,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    severity VARCHAR(20), -- LOW, MEDIUM, HIGH, CRITICAL
    
    -- Action
    auto_flag BOOLEAN DEFAULT TRUE,
    auto_block BOOLEAN DEFAULT FALSE,
    requires_investigation BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- AML Alerts
CREATE TABLE aml_alerts (
    id BIGSERIAL PRIMARY KEY,
    alert_id UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    
    -- Rule
    rule_id BIGINT REFERENCES aml_rules(id),
    rule_name VARCHAR(255) NOT NULL,
    
    -- Subject
    customer_id BIGINT NOT NULL,
    customer_name VARCHAR(255),
    
    -- Alert Details
    alert_type VARCHAR(100) NOT NULL,
    alert_severity VARCHAR(20) NOT NULL,
    alert_description TEXT NOT NULL,
    triggered_data JSONB,
    
    -- Related Entities
    related_transactions TEXT[],
    related_accounts TEXT[],
    
    -- Status
    alert_status VARCHAR(50) DEFAULT 'OPEN',
    
    -- Investigation
    assigned_to VARCHAR(100),
    investigated_by VARCHAR(100),
    investigation_notes TEXT,
    investigation_completed BOOLEAN DEFAULT FALSE,
    
    -- Resolution
    resolution VARCHAR(50), -- FALSE_POSITIVE, ESCALATED, SAR_FILED, CLOSED
    resolution_notes TEXT,
    resolved_at TIMESTAMP,
    resolved_by VARCHAR(100),
    
    -- SAR Filing
    sar_filed BOOLEAN DEFAULT FALSE,
    sar_report_id UUID REFERENCES regulatory_reports(report_id),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Transaction Monitoring
CREATE TABLE transaction_monitoring (
    id BIGSERIAL PRIMARY KEY,
    transaction_id VARCHAR(100) NOT NULL,
    customer_id BIGINT NOT NULL,
    
    -- Transaction Details
    transaction_type VARCHAR(50) NOT NULL,
    transaction_amount DECIMAL(19, 2) NOT NULL,
    transaction_date TIMESTAMP NOT NULL,
    
    -- Risk Scoring
    risk_score INT,
    risk_factors JSONB,
    
    -- Flags
    is_flagged BOOLEAN DEFAULT FALSE,
    flag_reasons TEXT[],
    
    -- Rules Triggered
    rules_triggered TEXT[],
    alerts_generated INT DEFAULT 0,
    
    -- Review
    requires_review BOOLEAN DEFAULT FALSE,
    reviewed_by VARCHAR(100),
    reviewed_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Regulatory Deadlines
CREATE TABLE regulatory_deadlines (
    id BIGSERIAL PRIMARY KEY,
    report_type report_type NOT NULL,
    regulation_name VARCHAR(255) NOT NULL,
    reporting_period VARCHAR(50) NOT NULL,
    
    due_date DATE NOT NULL,
    reminder_date DATE,
    
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP,
    completed_by VARCHAR(100),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Capital Adequacy Tracking
CREATE TABLE capital_adequacy (
    id BIGSERIAL PRIMARY KEY,
    reporting_date DATE NOT NULL,
    
    -- Capital Components
    tier_1_capital DECIMAL(19, 2) NOT NULL,
    tier_2_capital DECIMAL(19, 2) NOT NULL,
    total_capital DECIMAL(19, 2) NOT NULL,
    
    -- Risk-Weighted Assets
    credit_risk_weighted_assets DECIMAL(19, 2) NOT NULL,
    market_risk_weighted_assets DECIMAL(19, 2) NOT NULL,
    operational_risk_weighted_assets DECIMAL(19, 2) NOT NULL,
    total_risk_weighted_assets DECIMAL(19, 2) NOT NULL,
    
    -- Ratios
    tier_1_ratio DECIMAL(5, 2) NOT NULL,
    total_capital_ratio DECIMAL(5, 2) NOT NULL,
    leverage_ratio DECIMAL(5, 2) NOT NULL,
    
    -- Requirements
    minimum_tier_1_required DECIMAL(5, 2) DEFAULT 6.0,
    minimum_total_capital_required DECIMAL(5, 2) DEFAULT 8.0,
    
    is_compliant BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(reporting_date)
);

-- Compliance Violations
CREATE TABLE compliance_violations (
    id BIGSERIAL PRIMARY KEY,
    violation_type VARCHAR(100) NOT NULL,
    regulation_violated VARCHAR(255) NOT NULL,
    severity VARCHAR(20) NOT NULL,
    
    description TEXT NOT NULL,
    affected_entities JSONB,
    
    discovered_date DATE NOT NULL,
    discovered_by VARCHAR(100),
    
    -- Remediation
    remediation_plan TEXT,
    remediation_deadline DATE,
    is_remediated BOOLEAN DEFAULT FALSE,
    remediated_at TIMESTAMP,
    remediated_by VARCHAR(100),
    
    -- Reporting
    reported_to_regulator BOOLEAN DEFAULT FALSE,
    reported_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_regulatory_reports_type ON regulatory_reports(report_type);
CREATE INDEX idx_regulatory_reports_status ON regulatory_reports(report_status);
CREATE INDEX idx_regulatory_reports_period ON regulatory_reports(from_date, to_date);
CREATE INDEX idx_ctr_transaction ON ctr_reports(transaction_id);
CREATE INDEX idx_ctr_customer ON ctr_reports(customer_id);
CREATE INDEX idx_sar_subject ON sar_reports(subject_id);
CREATE INDEX idx_aml_alerts_customer ON aml_alerts(customer_id);
CREATE INDEX idx_aml_alerts_status ON aml_alerts(alert_status);
CREATE INDEX idx_transaction_monitoring_txn ON transaction_monitoring(transaction_id);
CREATE INDEX idx_transaction_monitoring_flagged ON transaction_monitoring(is_flagged);

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO regulatory_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO regulatory_user;

\echo 'Regulatory reporting database schema created successfully!';
