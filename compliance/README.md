# Compliance Layer - Complete Setup

## 🎯 What is the Compliance Layer?

For a **banking system**, compliance is NOT optional. This layer ensures:

✅ **Complete Audit Trail** - Every action logged  
✅ **KYC/AML Compliance** - Know Your Customer + Anti-Money Laundering  
✅ **Regulatory Reporting** - CTR, SAR, OFAC, etc.  
✅ **Risk Management** - Real-time risk scoring  
✅ **Document Storage** - Secure KYC document vault  

## 📊 Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   ALL MICROSERVICES                     │
│  Account | Customer | Loan | Transaction | Card         │
└────┬──────────┬──────────┬──────────┬────────────┬──────┘
     │          │          │          │            │
     │ Events   │ Events   │ Events   │ Events     │ Events
     ▼          ▼          ▼          ▼            ▼
┌─────────────────────────────────────────────────────────┐
│                      KAFKA                              │
└────┬──────────┬──────────┬──────────────────────────────┘
     │          │          │
     ▼          ▼          ▼
┌──────────┐ ┌──────────┐ ┌────────────────────┐
│  AUDIT   │ │   KYC    │ │    REGULATORY      │
│ SERVICE  │ │ SERVICE  │ │    REPORTING       │
│          │ │          │ │                    │
│ Logs ALL │ │ Identity │ │ CTR, SAR, AML      │
│  Events  │ │ Verify   │ │ Reports            │
└────┬─────┘ └────┬─────┘ └─────┬──────────────┘
     │            │             │
     ▼            ▼             ▼
┌─────────┐  ┌────────┐    ┌──────────┐
│Postgres │  │ MinIO  │    │Postgres  │
│audit_db │  │  Docs  │    │regulatory│
│         │  │Storage │    │  _db     │
└────┬────┘  └────────┘    └──────────┘
     │
     ▼
┌──────────────┐
│Elasticsearch │ ← Search audit logs
│   + Kibana   │ ← Visualize dashboards
└──────────────┘
```

## 🚀 Quick Start

### 1. Start Compliance Services

```bash
cd docker
docker-compose up -d
```

This starts:
- **Audit Service** (port 8091)
- **KYC Service** (port 8092)
- **Regulatory Reporting** (port 8093)
- **Elasticsearch** (port 9200)
- **Kibana** (port 5601)
- **MinIO** (port 9001)

### 2. Create Databases

```bash
# Run schema scripts
psql -U flanux_admin -h localhost -f audit-service/schema.sql
psql -U flanux_admin -h localhost -f kyc-service/schema.sql
psql -U flanux_admin -h localhost -f regulatory-reporting/schema.sql
```

### 3. Verify

```bash
# Check services
docker ps

# Access Kibana
Open: http://localhost:5601

# Access MinIO
Open: http://localhost:9002
Login: flanux_admin / flanux_minio_2024
```

## 📦 What's Included

### 1. Audit Service

**Purpose**: Log EVERY event for compliance audit trail

**Features**:
- ✅ Listens to ALL Kafka topics
- ✅ Logs to PostgreSQL + Elasticsearch
- ✅ Searchable via Kibana
- ✅ Retention policies
- ✅ Compliance reports

**Tables**:
- `audit_logs` - Main audit log
- `user_activity_logs` - Login/logout tracking
- `transaction_audit_trail` - Transaction steps
- `data_access_logs` - Sensitive data access
- `security_events` - Security incidents
- `configuration_changes` - System changes

**Example Events Logged**:
```
- account.created → Audit log created
- transaction.completed → Audit log created
- user.login → Activity log created
- fraud.alert → Security event created
- config.changed → Configuration change logged
```

### 2. KYC Service

**Purpose**: Verify customer identity & comply with AML regulations

**Features**:
- ✅ Document upload & OCR
- ✅ PEP (Politically Exposed Person) checks
- ✅ Sanctions screening (OFAC, UN, EU)
- ✅ Adverse media screening
- ✅ Risk scoring
- ✅ Automated & manual review workflows

**Tables**:
- `kyc_records` - Customer KYC status
- `kyc_documents` - Uploaded documents
- `kyc_verification_steps` - Verification workflow
- `pep_database` - PEP watchlist
- `sanctions_list` - Sanctions lists
- `kyc_alerts` - KYC alerts
- `watchlist_monitoring` - Ongoing monitoring

**KYC Flow**:
```
1. Customer uploads ID documents
   ↓
2. OCR extraction & verification
   ↓
3. PEP check
   ↓
4. Sanctions screening
   ↓
5. Adverse media check
   ↓
6. Risk scoring
   ↓
7. Auto-approve (low risk) OR Manual review (high risk)
```

### 3. Regulatory Reporting Service

**Purpose**: Generate mandatory regulatory reports

**Features**:
- ✅ CTR (Currency Transaction Reports) - Transactions > $10,000
- ✅ SAR (Suspicious Activity Reports)
- ✅ AML monitoring & alerts
- ✅ Capital adequacy tracking
- ✅ Compliance violation tracking

**Tables**:
- `regulatory_reports` - All regulatory reports
- `ctr_reports` - Currency transaction reports
- `sar_reports` - Suspicious activity reports
- `aml_rules` - AML monitoring rules
- `aml_alerts` - AML alerts
- `transaction_monitoring` - Real-time monitoring
- `capital_adequacy` - Capital adequacy tracking
- `compliance_violations` - Violation tracking

**Report Types**:
- **CTR** - Any cash transaction over $10,000
- **SAR** - Suspicious patterns detected
- **OFAC** - OFAC compliance report
- **AML** - Anti-money laundering summary
- **Capital Adequacy** - Basel III compliance

## 🔧 Integration

### Step 1: Add Dependencies

```xml
<!-- Spring Kafka (already added) -->
<dependency>
    <groupId>org.springframework.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
</dependency>

<!-- Elasticsearch (for audit service) -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-elasticsearch</artifactId>
</dependency>

<!-- MinIO (for KYC documents) -->
<dependency>
    <groupId>io.minio</groupId>
    <artifactId>minio</artifactId>
    <version>8.5.7</version>
</dependency>
```

### Step 2: Audit Service Integration

Every service publishes events → Audit Service logs them automatically!

**Already done via Kafka!** No code changes needed in existing services.

### Step 3: KYC Integration

Add KYC check when customer registers:

```java
// In Customer Service
@PostMapping("/customers")
public Customer createCustomer(@RequestBody CustomerRequest request) {
    
    // 1. Create customer
    Customer customer = customerService.createCustomer(request);
    
    // 2. Initiate KYC
    kycClient.initiateKyc(customer.getId(), customer.getFullName(), 
                          customer.getDateOfBirth(), customer.getNationality());
    
    return customer;
}

// Listen to KYC events
@KafkaListener(topics = "customer.kyc.verified")
public void handleKycVerified(Map<String, Object> event) {
    Long customerId = (Long) event.get("customerId");
    customerService.updateKycStatus(customerId, "VERIFIED");
}
```

### Step 4: Regulatory Reporting Integration

Transaction Service auto-generates CTRs:

```java
// In Transaction Service
public void processTransaction(Transaction txn) {
    
    // Process transaction
    // ...
    
    // Check if CTR required
    if (txn.getAmount().compareTo(new BigDecimal("10000")) >= 0) {
        // Publish event for regulatory reporting
        kafkaTemplate.send("transaction.large.amount", txn);
    }
}
```

Regulatory Service listens and creates CTR automatically!

## 📊 Compliance Dashboards

### Kibana Dashboards (Audit Logs)

Access: `http://localhost:5601`

**Pre-built Dashboards**:
1. **User Activity** - Logins, logouts, actions
2. **Transaction Monitoring** - All transactions
3. **Security Events** - Fraud alerts, blocks
4. **System Changes** - Configuration changes

**Create Custom Searches**:
```
# Search transactions by user
user_id:123 AND entity_type:TRANSACTION

# Search failed logins
action:LOGIN AND success:false

# Search high-value transactions
entity_type:TRANSACTION AND amount:>100000

# Search security events
severity:CRITICAL
```

### MinIO Console (KYC Documents)

Access: `http://localhost:9002`

**Buckets**:
- `kyc-documents` - ID cards, passports, proof of address
- `regulatory-reports` - Generated PDF reports
- `audit-exports` - Exported audit logs

## 🔐 Compliance Features

### 1. Complete Audit Trail

**Every action is logged**:
```sql
SELECT * FROM audit_logs 
WHERE entity_type = 'TRANSACTION' 
AND created_at > NOW() - INTERVAL '24 hours';
```

### 2. KYC Verification Levels

- **BASIC** - Name, DOB, ID verification
- **INTERMEDIATE** - Address verification, sanctions check
- **ENHANCED** - PEP check, adverse media, source of funds
- **INSTITUTIONAL** - Corporate verification, beneficial owners

### 3. AML Monitoring Rules

**Pre-configured rules**:
```
Rule 1: Transactions > $10,000 in single day
Rule 2: Multiple transactions just under $10,000 (structuring)
Rule 3: Unusual geographic patterns
Rule 4: Rapid movement of funds
Rule 5: Transactions with high-risk countries
```

### 4. Automatic CTR Generation

```sql
-- All transactions > $10,000 auto-generate CTR
INSERT INTO ctr_reports 
SELECT * FROM transactions 
WHERE amount >= 10000 
AND transaction_date = CURRENT_DATE;
```

### 5. SAR Workflow

```
1. AML alert triggered
   ↓
2. Analyst reviews
   ↓
3. If suspicious → Create SAR
   ↓
4. SAR approved by compliance officer
   ↓
5. Filed with FinCEN
   ↓
6. Confirmation received
```

## 📈 Reporting

### Daily Compliance Report

```java
// Generate daily compliance summary
Map<String, Object> report = auditService.generateComplianceReport(
    LocalDateTime.now().minusDays(1),
    LocalDateTime.now()
);

// Returns:
{
    "totalEvents": 15234,
    "criticalEvents": 12,
    "eventsByAction": {
        "CREATE": 450,
        "UPDATE": 890,
        "DELETE": 23,
        "TRANSFER": 12456
    },
    "eventsByEntity": {
        "TRANSACTION": 12456,
        "ACCOUNT": 450,
        "CUSTOMER": 320
    }
}
```

### Monthly Regulatory Pack

```sql
-- CTRs filed this month
SELECT COUNT(*) FROM ctr_reports 
WHERE DATE_TRUNC('month', transaction_date) = DATE_TRUNC('month', CURRENT_DATE);

-- SARs filed this month
SELECT COUNT(*) FROM sar_reports 
WHERE DATE_TRUNC('month', filing_date) = DATE_TRUNC('month', CURRENT_DATE);

-- KYC verifications completed
SELECT COUNT(*) FROM kyc_records 
WHERE kyc_status = 'VERIFIED' 
AND DATE_TRUNC('month', verified_at) = DATE_TRUNC('month', CURRENT_DATE);
```

## 🧪 Testing

### Test Audit Logging

```bash
# Create account → Check audit log
curl -X POST http://localhost:8081/api/accounts \
  -H "Authorization: Bearer TOKEN" \
  -d '{"customerId":1,"accountType":"SAVINGS"}'

# Check Elasticsearch
curl http://localhost:9200/audit-logs/_search?q=entity_type:ACCOUNT
```

### Test KYC Flow

```bash
# Upload KYC document
curl -X POST http://localhost:8092/api/kyc/documents \
  -H "Authorization: Bearer TOKEN" \
  -F "file=@passport.jpg" \
  -F "documentType=PASSPORT"

# Check KYC status
curl http://localhost:8092/api/kyc/customers/123/status
```

### Test CTR Generation

```bash
# Make large transaction
curl -X POST http://localhost:8085/api/transactions \
  -d '{"amount":15000,"type":"DEPOSIT"}'

# Check if CTR created
curl http://localhost:8093/api/regulatory/ctr?date=2024-02-04
```

## ⚠️ Regulatory Requirements

### US Banking Regulations

- ✅ **Bank Secrecy Act (BSA)** - CTR filing
- ✅ **USA PATRIOT Act** - KYC/AML
- ✅ **OFAC** - Sanctions screening
- ✅ **FinCEN** - SAR filing
- ✅ **FDIC** - Audit trail
- ✅ **SOX** - Internal controls

### Data Retention

```
Audit Logs: 7 years
KYC Documents: 5 years after account closure
CTRs: 5 years
SARs: 5 years
Transaction Records: 7 years
```

## 🎯 Best Practices

### 1. Audit Everything

```java
// Before any sensitive operation
auditService.logDataAccess(userId, username, "CUSTOMER", 
                          customerId, "VIEW", ipAddress);

// Perform operation
Customer customer = customerService.getCustomer(customerId);

// Audit complete
```

### 2. KYC Before Account Opening

```java
// Check KYC status
KycStatus status = kycService.getKycStatus(customerId);

if (!"VERIFIED".equals(status)) {
    throw new Exception("KYC verification required");
}

// Proceed with account opening
```

### 3. Real-time AML Monitoring

```java
// Every transaction triggers AML check
@KafkaListener(topics = "transaction.initiated")
public void checkAml(Transaction txn) {
    
    List<AmlRule> triggeredRules = amlService.checkRules(txn);
    
    if (!triggeredRules.isEmpty()) {
        amlService.createAlert(txn, triggeredRules);
    }
}
```

## 📂 File Structure

```
compliance-layer/
├── docker/
│   └── docker-compose.yml          # All services
├── audit-service/
│   ├── schema.sql                  # Database schema
│   └── AuditService.java           # Implementation
├── kyc-service/
│   ├── schema.sql                  # Database schema
│   └── KycService.java             # Implementation
├── regulatory-reporting/
│   ├── schema.sql                  # Database schema
│   └── RegulatoryReporting.java    # Implementation
├── examples/
│   ├── AuditService.java
│   └── KycService.java
└── README.md                       # This file
```
