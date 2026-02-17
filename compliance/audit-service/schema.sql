-- ============================================
-- Audit Service Database Schema
-- ============================================

CREATE DATABASE audit_db;

\c audit_db;

CREATE USER audit_user WITH PASSWORD 'audit_pass_2024';
GRANT ALL PRIVILEGES ON DATABASE audit_db TO audit_user;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Audit Log Types
CREATE TYPE audit_action AS ENUM (
    'CREATE', 'UPDATE', 'DELETE', 'VIEW', 
    'LOGIN', 'LOGOUT', 'APPROVE', 'REJECT',
    'TRANSFER', 'DEPOSIT', 'WITHDRAWAL',
    'EXPORT', 'IMPORT', 'CONFIGURATION_CHANGE'
);

CREATE TYPE audit_severity AS ENUM ('INFO', 'WARNING', 'ERROR', 'CRITICAL');

-- Main Audit Logs Table
CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    audit_id UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    
    -- Who
    user_id BIGINT,
    username VARCHAR(255),
    user_role VARCHAR(50),
    
    -- What
    action audit_action NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id VARCHAR(100),
    
    -- Details
    description TEXT NOT NULL,
    old_value JSONB,
    new_value JSONB,
    changes JSONB,
    
    -- Severity
    severity audit_severity DEFAULT 'INFO',
    
    -- Context
    ip_address VARCHAR(45),
    user_agent TEXT,
    session_id VARCHAR(255),
    request_id VARCHAR(100),
    
    -- Metadata
    metadata JSONB,
    tags TEXT[],
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Compliance
    retention_date DATE,
    is_archived BOOLEAN DEFAULT FALSE
);

-- User Activity Logs
CREATE TABLE user_activity_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    username VARCHAR(255) NOT NULL,
    activity_type VARCHAR(100) NOT NULL,
    activity_description TEXT,
    ip_address VARCHAR(45),
    device_info TEXT,
    location VARCHAR(255),
    success BOOLEAN DEFAULT TRUE,
    failure_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Transaction Audit Trail
CREATE TABLE transaction_audit_trail (
    id BIGSERIAL PRIMARY KEY,
    transaction_id VARCHAR(100) NOT NULL,
    step_number INT NOT NULL,
    step_name VARCHAR(100) NOT NULL,
    step_status VARCHAR(50) NOT NULL,
    step_data JSONB,
    processed_by VARCHAR(100),
    processing_time_ms BIGINT,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(transaction_id, step_number)
);

-- Data Access Logs (who accessed what sensitive data)
CREATE TABLE data_access_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    username VARCHAR(255) NOT NULL,
    data_type VARCHAR(100) NOT NULL,
    data_id VARCHAR(100) NOT NULL,
    access_type VARCHAR(50) NOT NULL, -- READ, EXPORT, PRINT
    justification TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Security Events
CREATE TABLE security_events (
    id BIGSERIAL PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL,
    severity audit_severity NOT NULL,
    description TEXT NOT NULL,
    user_id BIGINT,
    username VARCHAR(255),
    ip_address VARCHAR(45),
    event_data JSONB,
    is_resolved BOOLEAN DEFAULT FALSE,
    resolved_at TIMESTAMP,
    resolved_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Configuration Changes
CREATE TABLE configuration_changes (
    id BIGSERIAL PRIMARY KEY,
    config_key VARCHAR(255) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    changed_by VARCHAR(100) NOT NULL,
    change_reason TEXT,
    approved_by VARCHAR(100),
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Compliance Reports
CREATE TABLE compliance_reports (
    id BIGSERIAL PRIMARY KEY,
    report_type VARCHAR(100) NOT NULL,
    report_period VARCHAR(50) NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    total_events BIGINT DEFAULT 0,
    critical_events BIGINT DEFAULT 0,
    violations BIGINT DEFAULT 0,
    report_data JSONB,
    generated_by VARCHAR(100),
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    file_path VARCHAR(500)
);

-- Indexes for performance
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX idx_audit_logs_severity ON audit_logs(severity);
CREATE INDEX idx_user_activity_user_id ON user_activity_logs(user_id);
CREATE INDEX idx_user_activity_created_at ON user_activity_logs(created_at);
CREATE INDEX idx_transaction_audit_txn_id ON transaction_audit_trail(transaction_id);
CREATE INDEX idx_data_access_user_id ON data_access_logs(user_id);
CREATE INDEX idx_data_access_data_type ON data_access_logs(data_type, data_id);
CREATE INDEX idx_security_events_severity ON security_events(severity);
CREATE INDEX idx_security_events_resolved ON security_events(is_resolved);

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO audit_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO audit_user;

\echo 'Audit database schema created successfully!';
