-- ============================================
-- KYC Service Database Schema
-- ============================================

CREATE DATABASE kyc_db;

\c kyc_db;

CREATE USER kyc_user WITH PASSWORD 'kyc_pass_2024';
GRANT ALL PRIVILEGES ON DATABASE kyc_db TO kyc_user;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- KYC Status Enum
CREATE TYPE kyc_status AS ENUM (
    'PENDING', 'IN_REVIEW', 'VERIFIED', 'REJECTED', 
    'EXPIRED', 'REQUIRES_UPDATE', 'SUSPENDED'
);

-- KYC Level Enum
CREATE TYPE kyc_level AS ENUM ('BASIC', 'INTERMEDIATE', 'ENHANCED', 'INSTITUTIONAL');

-- Verification Method
CREATE TYPE verification_method AS ENUM (
    'MANUAL', 'AUTOMATED', 'THIRD_PARTY', 
    'BIOMETRIC', 'VIDEO_CALL', 'IN_PERSON'
);

-- Risk Level
CREATE TYPE risk_level AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'VERY_HIGH');

-- KYC Records
CREATE TABLE kyc_records (
    id BIGSERIAL PRIMARY KEY,
    kyc_id UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    customer_id BIGINT NOT NULL,
    
    -- KYC Level
    kyc_level kyc_level NOT NULL,
    kyc_status kyc_status DEFAULT 'PENDING',
    
    -- Identity Verification
    full_name VARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    nationality VARCHAR(50),
    id_type VARCHAR(50) NOT NULL,
    id_number VARCHAR(100) NOT NULL,
    id_issuing_country VARCHAR(50),
    id_expiry_date DATE,
    
    -- Address Verification
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    address_verified BOOLEAN DEFAULT FALSE,
    address_verification_date TIMESTAMP,
    
    -- PEP (Politically Exposed Person) Check
    is_pep BOOLEAN DEFAULT FALSE,
    pep_details TEXT,
    pep_check_date TIMESTAMP,
    
    -- Sanctions Screening
    sanctions_cleared BOOLEAN DEFAULT FALSE,
    sanctions_check_date TIMESTAMP,
    sanctions_hits JSONB,
    
    -- Adverse Media Screening
    adverse_media_cleared BOOLEAN DEFAULT FALSE,
    adverse_media_check_date TIMESTAMP,
    adverse_media_findings JSONB,
    
    -- Risk Assessment
    risk_level risk_level,
    risk_score INT,
    risk_factors JSONB,
    risk_assessment_date TIMESTAMP,
    
    -- Verification
    verification_method verification_method,
    verified_by VARCHAR(100),
    verified_at TIMESTAMP,
    rejection_reason TEXT,
    
    -- Review
    last_reviewed_at TIMESTAMP,
    next_review_date DATE,
    review_frequency_days INT DEFAULT 365,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    
    -- Compliance
    aml_cleared BOOLEAN DEFAULT FALSE,
    cft_cleared BOOLEAN DEFAULT FALSE,
    
    CONSTRAINT valid_risk_score CHECK (risk_score >= 0 AND risk_score <= 100)
);

-- KYC Documents
CREATE TABLE kyc_documents (
    id BIGSERIAL PRIMARY KEY,
    kyc_id UUID NOT NULL REFERENCES kyc_records(kyc_id) ON DELETE CASCADE,
    
    -- Document Info
    document_type VARCHAR(50) NOT NULL,
    document_number VARCHAR(100),
    document_name VARCHAR(255) NOT NULL,
    
    -- File Storage
    file_path VARCHAR(500) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_size BIGINT,
    mime_type VARCHAR(100),
    
    -- OCR & Extraction
    extracted_data JSONB,
    ocr_confidence DECIMAL(5, 2),
    
    -- Verification
    is_verified BOOLEAN DEFAULT FALSE,
    verified_by VARCHAR(100),
    verified_at TIMESTAMP,
    verification_notes TEXT,
    
    -- Expiry
    expires_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- KYC Verification Steps
CREATE TABLE kyc_verification_steps (
    id BIGSERIAL PRIMARY KEY,
    kyc_id UUID NOT NULL REFERENCES kyc_records(kyc_id) ON DELETE CASCADE,
    
    step_name VARCHAR(100) NOT NULL,
    step_number INT NOT NULL,
    step_status VARCHAR(50) NOT NULL,
    step_result VARCHAR(50),
    step_data JSONB,
    
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    processed_by VARCHAR(100),
    
    error_message TEXT,
    
    UNIQUE(kyc_id, step_number)
);

-- PEP (Politically Exposed Persons) Database
CREATE TABLE pep_database (
    id BIGSERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    aliases TEXT[],
    date_of_birth DATE,
    nationality VARCHAR(50),
    position VARCHAR(255),
    organization VARCHAR(255),
    pep_category VARCHAR(50), -- SENIOR_OFFICIAL, FAMILY_MEMBER, CLOSE_ASSOCIATE
    country VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    start_date DATE,
    end_date DATE,
    source VARCHAR(255),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sanctions List
CREATE TABLE sanctions_list (
    id BIGSERIAL PRIMARY KEY,
    list_name VARCHAR(100) NOT NULL,
    entity_name VARCHAR(255) NOT NULL,
    aliases TEXT[],
    entity_type VARCHAR(50), -- INDIVIDUAL, ORGANIZATION
    date_of_birth DATE,
    nationality VARCHAR(50),
    sanction_type VARCHAR(100),
    sanctioned_by VARCHAR(100),
    effective_date DATE,
    expiry_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    source VARCHAR(255),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- KYC Alerts
CREATE TABLE kyc_alerts (
    id BIGSERIAL PRIMARY KEY,
    kyc_id UUID REFERENCES kyc_records(kyc_id) ON DELETE CASCADE,
    customer_id BIGINT NOT NULL,
    
    alert_type VARCHAR(100) NOT NULL,
    alert_severity VARCHAR(20) NOT NULL,
    alert_description TEXT NOT NULL,
    alert_data JSONB,
    
    is_resolved BOOLEAN DEFAULT FALSE,
    resolved_at TIMESTAMP,
    resolved_by VARCHAR(100),
    resolution_notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- KYC Audit Trail
CREATE TABLE kyc_audit_trail (
    id BIGSERIAL PRIMARY KEY,
    kyc_id UUID NOT NULL REFERENCES kyc_records(kyc_id) ON DELETE CASCADE,
    
    action VARCHAR(100) NOT NULL,
    performed_by VARCHAR(100) NOT NULL,
    old_status kyc_status,
    new_status kyc_status,
    changes JSONB,
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Watchlist Monitoring
CREATE TABLE watchlist_monitoring (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    monitoring_status VARCHAR(50) DEFAULT 'ACTIVE',
    last_check_date TIMESTAMP,
    next_check_date TIMESTAMP,
    check_frequency_days INT DEFAULT 30,
    hits_count INT DEFAULT 0,
    last_hit_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_kyc_records_customer_id ON kyc_records(customer_id);
CREATE INDEX idx_kyc_records_status ON kyc_records(kyc_status);
CREATE INDEX idx_kyc_records_level ON kyc_records(kyc_level);
CREATE INDEX idx_kyc_records_risk ON kyc_records(risk_level);
CREATE INDEX idx_kyc_records_next_review ON kyc_records(next_review_date);
CREATE INDEX idx_kyc_documents_kyc_id ON kyc_documents(kyc_id);
CREATE INDEX idx_kyc_alerts_customer_id ON kyc_alerts(customer_id);
CREATE INDEX idx_kyc_alerts_resolved ON kyc_alerts(is_resolved);
CREATE INDEX idx_pep_name ON pep_database(full_name);
CREATE INDEX idx_sanctions_name ON sanctions_list(entity_name);
CREATE INDEX idx_watchlist_customer ON watchlist_monitoring(customer_id);

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO kyc_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO kyc_user;

\echo 'KYC database schema created successfully!';
