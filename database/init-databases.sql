-- Account service
CREATE DATABASE account_db;
CREATE USER account_user WITH ENCRYPTED PASSWORD 'account_pass_2024';
GRANT ALL PRIVILEGES ON DATABASE account_db TO account_user;

-- Customer service
CREATE DATABASE customer_db;
CREATE USER customer_user WITH ENCRYPTED PASSWORD 'customer_pass_2024';
GRANT ALL PRIVILEGES ON DATABASE customer_db TO customer_user;

-- Card service
CREATE DATABASE card_db;
CREATE USER card_user WITH ENCRYPTED PASSWORD 'card_pass_2024';
GRANT ALL PRIVILEGES ON DATABASE card_db TO card_user;

-- Ledger service
CREATE DATABASE ledger_db;
CREATE USER ledger_user WITH ENCRYPTED PASSWORD 'ledger_pass_2024';
GRANT ALL PRIVILEGES ON DATABASE ledger_db TO ledger_user;

-- Loan service
CREATE DATABASE loan_db;
CREATE USER loan_user WITH ENCRYPTED PASSWORD 'loan_2026';
GRANT ALL PRIVILEGES ON DATABASE loan_db TO loan_user;

-- Notification service
CREATE DATABASE notification_db;
CREATE USER notification_user WITH ENCRYPTED PASSWORD 'notification_2026';
GRANT ALL PRIVILEGES ON DATABASE notification_db TO notification_user;

-- Reporting service
CREATE DATABASE reporting_db;
CREATE USER reporting_user WITH ENCRYPTED PASSWORD 'reporting_2026';
GRANT ALL PRIVILEGES ON DATABASE reporting_db TO reporting_user;

-- Transaction service
CREATE DATABASE transaction_db;
CREATE USER transaction_user WITH ENCRYPTED PASSWORD 'transaction_2026';
GRANT ALL PRIVILEGES ON DATABASE transaction_db TO transaction_user;