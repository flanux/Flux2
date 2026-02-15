-- ================================================
-- FLUX v2.0 - Authentication Database
-- ================================================

CREATE DATABASE auth_db;
CREATE USER auth_user WITH ENCRYPTED PASSWORD 'auth_pass_2024';
GRANT ALL PRIVILEGES ON DATABASE auth_db TO auth_user;

\c auth_db

GRANT ALL ON SCHEMA public TO auth_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO auth_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO auth_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO auth_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO auth_user;

CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('CUSTOMER', 'BRANCH_EMPLOYEE', 'BRANCH_MANAGER', 'CENTRAL_BANK_ADMIN')),
    customer_id BIGINT,
    branch_id BIGINT,
    account_locked BOOLEAN DEFAULT FALSE NOT NULL,
    failed_login_attempts INTEGER DEFAULT 0 NOT NULL,
    last_login_at TIMESTAMP,
    locked_until TIMESTAMP,
    active BOOLEAN DEFAULT TRUE NOT NULL,
    mfa_enabled BOOLEAN DEFAULT FALSE NOT NULL,
    mfa_secret VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);

CREATE TABLE refresh_tokens (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(500) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    revoked BOOLEAN DEFAULT FALSE NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX idx_refresh_tokens_token ON refresh_tokens(token);
CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);

-- Password: Flux@2026 (BCrypt hash with cost 12)
INSERT INTO users (username, email, password_hash, role, active) VALUES
('admin', 'admin@centralbank.np', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYKKT4lK5Eq', 'CENTRAL_BANK_ADMIN', true),
('manager.ktm', 'manager@branch1.np', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYKKT4lK5Eq', 'BRANCH_MANAGER', true),
('employee.ktm', 'employee@branch1.np', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYKKT4lK5Eq', 'BRANCH_EMPLOYEE', true),
('ram.bahadur', 'ram@gmail.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYKKT4lK5Eq', 'CUSTOMER', true);

UPDATE users SET branch_id = 1 WHERE username IN ('manager.ktm', 'employee.ktm');
UPDATE users SET customer_id = 1 WHERE username = 'ram.bahadur';

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO auth_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO auth_user;

\echo '✅ Auth database initialized!'
\echo ''
\echo 'Test users created:'
\echo '  - admin / Flux@2026 (CENTRAL_BANK_ADMIN)'
\echo '  - manager.ktm / Flux@2026 (BRANCH_MANAGER)'
\echo '  - employee.ktm / Flux@2026 (BRANCH_EMPLOYEE)'
\echo '  - ram.bahadur / Flux@2026 (CUSTOMER)'
\echo ''
\echo '⚠️  CHANGE DEFAULT PASSWORDS IN PRODUCTION!'
