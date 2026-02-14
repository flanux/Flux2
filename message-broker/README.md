# Microservices - Kafka Message Broker Setup

Complete Apache Kafka setup for event-driven microservices architecture.

## 🎯 Why Kafka?

For a **banking/financial system**, Kafka is the perfect choice:

✅ **High Throughput** - Handle millions of transactions/day  
✅ **Durability** - Messages persisted to disk (no data loss)  
✅ **Scalability** - Add brokers as you grow  
✅ **Event Sourcing** - Complete audit trail  
✅ **Real-time Processing** - Instant notifications & fraud detection  
✅ **Exactly-Once Semantics** - Critical for financial transactions  

## 📊 Architecture Overview

```
┌───────────────────────────────────────────────────────────┐
│                    MICROSERVICES                          │
├─────────────┬─────────────┬─────────────┬─────────────────┤
│  Account    │  Customer   │    Loan     │  Transaction    │
│  Service    │  Service    │   Service   │   Service       │
│  (Producer) │ (Producer)  │ (Producer)  │  (Producer)     │
└──────┬──────┴──────┬──────┴──────┬──────┴──────┬──────────┘
       │             │             │             │
       │ Events      │ Events      │ Events      │ Events
       ▼             ▼             ▼             ▼
┌──────────────────────────────────────────────────────────┐
│                    KAFKA CLUSTER                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │  Topic:  │  │  Topic:  │  │  Topic:  │  │  Topic:  │  │
│  │ account. │  │customer. │  │  loan.   │  │transact. │  │
│  │ created  │  │ updated  │  │ approved │  │completed │  │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │
└──────┬──────────────┬──────────────┬──────────────┬──────┘
       │              │              │              │
       │ Subscribe    │ Subscribe    │ Subscribe    │ Subscribe
       ▼              ▼              ▼              ▼
┌─────────────┬──────────────┬──────────────┬─────────────┐
│Notification │   Ledger     │  Reporting   │   Fraud     │
│  Service    │   Service    │   Service    │ Detection   │
│ (Consumer)  │ (Consumer)   │ (Consumer)   │ (Consumer)  │
└─────────────┴──────────────┴──────────────┴─────────────┘
```

## 🚀 Quick Start (3 Steps)

### 1. Start Kafka Cluster

```bash
cd docker
docker-compose up -d
```

This starts:
- **Zookeeper** (port 2181)
- **Kafka Broker** (port 9092)
- **Kafka UI** (port 8090)
- **Kafdrop** (port 9000)
- **Schema Registry** (port 8081)
- **Kafka Connect** (port 8083)

### 2. Create Topics

```bash
cd scripts
./create-topics.sh
```

This creates 50+ topics for all microservices.

### 3. Verify Setup

```bash
# Check if Kafka is running
docker ps

# List topics
docker exec flanux-kafka kafka-topics --list --bootstrap-server localhost:9092

# Access Kafka UI
# Open browser: http://localhost:8090
```

## 📋 Topics Overview

### Account Service Topics
- `account.created` - New account created
- `account.updated` - Account details updated
- `account.closed` - Account closed
- `account.balance.changed` - Balance modified
- `account.statement.generated` - Statement generated

### Customer Service Topics
- `customer.registered` - New customer registered
- `customer.updated` - Customer info updated
- `customer.kyc.verified` - KYC verification completed
- `customer.kyc.rejected` - KYC verification failed
- `customer.status.changed` - Customer status changed

### Loan Service Topics
- `loan.application.submitted` - New loan application
- `loan.application.approved` - Loan approved
- `loan.application.rejected` - Loan rejected
- `loan.disbursed` - Loan amount disbursed
- `loan.payment.received` - Payment received
- `loan.payment.overdue` - Payment overdue
- `loan.payment.missed` - Payment missed
- `loan.paid.off` - Loan fully paid

### Card Service Topics
- `card.issued` - New card issued
- `card.activated` - Card activated
- `card.blocked` - Card blocked
- `card.transaction.authorized` - Transaction authorized
- `card.transaction.declined` - Transaction declined
- `card.limit.exceeded` - Credit limit exceeded
- `card.expired` - Card expired

### Transaction Service Topics
- `transaction.initiated` - Transaction started
- `transaction.completed` - Transaction successful
- `transaction.failed` - Transaction failed
- `transaction.reversed` - Transaction reversed
- `transaction.disputed` - Dispute raised
- `transaction.approved` - Approval granted
- `transaction.rejected` - Approval denied

### Ledger Service Topics
- `ledger.entry.posted` - Ledger entry posted
- `ledger.journal.created` - Journal entry created
- `ledger.balance.snapshot` - Balance snapshot taken

### Notification Topics
- `notification.email.send` - Email to be sent
- `notification.sms.send` - SMS to be sent
- `notification.push.send` - Push notification
- `notification.delivered` - Notification delivered
- `notification.failed` - Notification failed

### Audit & Fraud Topics
- `audit.user.login` - User login event
- `audit.data.modified` - Data modification
- `fraud.alert` - Fraud detected
- `fraud.transaction.flagged` - Suspicious transaction

### Dead Letter Queues (DLQ)
- `dlq.account.events` - Failed account events
- `dlq.transaction.events` - Failed transaction events
- `dlq.notification.events` - Failed notifications
- `dlq.general` - Other failed events

## 🔧 Integration with Spring Boot

### Step 1: Add Dependencies

Add to **each microservice's pom.xml**:

```xml
<dependency>
    <groupId>org.springframework.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
</dependency>
```

See `configs/pom-dependencies.xml` for complete list.

### Step 2: Configure application.yml

```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.springframework.kafka.support.serializer.JsonSerializer
    consumer:
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.springframework.kafka.support.serializer.JsonDeserializer
      group-id: ${spring.application.name}
```

See `configs/spring-kafka-config.yml` for complete configuration.

### Step 3: Create Producer (Example: Account Service)

```java
@Service
@RequiredArgsConstructor
public class AccountEventProducer {
    
    private final KafkaTemplate<String, Object> kafkaTemplate;
    
    public void publishAccountCreated(AccountCreatedEvent event) {
        kafkaTemplate.send("account.created", 
                          event.getAccountNumber(), 
                          event);
    }
}
```

See `examples/AccountEventProducer.java` for full code.

### Step 4: Create Consumer (Example: Notification Service)

```java
@Component
@RequiredArgsConstructor
public class NotificationEventConsumer {
    
    @KafkaListener(topics = "account.created", 
                   groupId = "notification-consumer-group")
    public void handleAccountCreated(AccountCreatedEvent event, 
                                    Acknowledgment ack) {
        // Send welcome email
        notificationService.sendWelcomeEmail(event);
        ack.acknowledge();
    }
}
```

See `examples/NotificationEventConsumer.java` for full code.

## 📚 Event Flow Examples

### Example 1: Account Creation Flow

```
1. User creates account via API Gateway
   ↓
2. Account Service creates account in DB
   ↓
3. Account Service publishes to "account.created"
   ↓
4. Consumers react:
   - Notification Service → Send welcome email
   - Ledger Service → Create GL entry
   - Reporting Service → Update analytics
   - Audit Service → Log creation event
```

### Example 2: Transaction Processing Flow

```
1. Transaction Service receives transfer request
   ↓
2. Publishes to "transaction.initiated"
   ↓
3. Fraud Service checks transaction (consumer)
   ↓
4. If OK: Transaction completes → "transaction.completed"
   ↓
5. Consumers react:
   - Ledger Service → Update GL
   - Account Service → Update balances
   - Notification Service → Send SMS alert
   - Reporting Service → Update metrics
```

### Example 3: Loan Approval Flow

```
1. Customer applies for loan
   ↓
2. Loan Service publishes "loan.application.submitted"
   ↓
3. Credit Check Service evaluates (consumer)
   ↓
4. If approved: "loan.application.approved"
   ↓
5. Consumers react:
   - Notification Service → Email approval
   - Account Service → Create loan account
   - Ledger Service → Record disbursement
```

## 🎯 Event Patterns

### 1. **Event Notification**
Simple notification that something happened.
```java
// Event
{
  "accountId": 123,
  "accountNumber": "ACC1001234567",
  "eventType": "CREATED",
  "timestamp": "2024-02-04T10:00:00Z"
}
```

### 2. **Event-Carried State Transfer**
Event contains all necessary data.
```java
// Event with full state
{
  "accountId": 123,
  "accountNumber": "ACC1001234567",
  "customerId": 456,
  "balance": 5000.00,
  "currency": "USD",
  "accountType": "SAVINGS",
  "status": "ACTIVE"
}
```

### 3. **Event Sourcing**
Store all state changes as events.
```java
// Sequence of events
1. AccountCreatedEvent
2. DepositMadeEvent
3. WithdrawalMadeEvent
4. BalanceUpdatedEvent
```

## 🔐 Best Practices

### 1. **Idempotent Consumers**
Handle duplicate messages gracefully.

```java
@KafkaListener(topics = "account.created")
public void handleAccountCreated(AccountCreatedEvent event) {
    // Check if already processed
    if (processedEvents.contains(event.getEventId())) {
        return; // Skip duplicate
    }
    
    // Process event
    processEvent(event);
    
    // Mark as processed
    processedEvents.add(event.getEventId());
}
```

### 2. **Dead Letter Queue**
Handle failed messages.

```java
@KafkaListener(topics = "account.created")
public void handleAccountCreated(AccountCreatedEvent event) {
    try {
        processEvent(event);
    } catch (Exception e) {
        // Send to DLQ
        kafkaTemplate.send("dlq.account.events", event);
    }
}
```

### 3. **Event Versioning**
Handle schema changes.

```java
// Version 1
public class AccountCreatedEventV1 {
    private Long accountId;
    private String accountNumber;
}

// Version 2 (added field)
public class AccountCreatedEventV2 {
    private Long accountId;
    private String accountNumber;
    private String accountType; // New field
}
```

### 4. **Transactional Outbox Pattern**
Ensure exactly-once delivery.

```java
@Transactional
public void createAccount(Account account) {
    // 1. Save to database
    accountRepository.save(account);
    
    // 2. Save event to outbox table
    outboxRepository.save(new OutboxEvent(
        "account.created",
        accountCreatedEvent
    ));
    
    // 3. Separate process reads outbox and sends to Kafka
}
```

## 📊 Monitoring & Management

### Kafka UI
- **URL**: http://localhost:8090
- View topics, messages, consumer groups
- Monitor lag, throughput, errors

### Kafdrop
- **URL**: http://localhost:9000
- Alternative UI with different features
- View message contents, topic configs

### Important Commands

```bash
# List topics
docker exec flanux-kafka kafka-topics --list --bootstrap-server localhost:9092

# Describe topic
docker exec flanux-kafka kafka-topics --describe --topic account.created --bootstrap-server localhost:9092

# View consumer groups
docker exec flanux-kafka kafka-consumer-groups --list --bootstrap-server localhost:9092

# Check consumer lag
docker exec flanux-kafka kafka-consumer-groups --describe --group notification-consumer-group --bootstrap-server localhost:9092

# Consume messages from beginning
docker exec -it flanux-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic account.created --from-beginning

# Produce test message
docker exec -it flanux-kafka kafka-console-producer --bootstrap-server localhost:9092 --topic account.created
```

## 🧪 Testing

### 1. Send Test Event

```bash
docker exec -it flanux-kafka kafka-console-producer \
  --bootstrap-server localhost:9092 \
  --topic account.created

# Then type JSON and press Enter:
{"accountId":123,"accountNumber":"ACC1001234567","balance":5000.00}
```

### 2. Consume Test Event

```bash
docker exec -it flanux-kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic account.created \
  --from-beginning
```

### 3. Unit Test with Embedded Kafka

```java
@SpringBootTest
@EmbeddedKafka(partitions = 1, topics = {"account.created"})
class AccountServiceTest {
    
    @Autowired
    private KafkaTemplate<String, Object> kafkaTemplate;
    
    @Test
    void testAccountCreatedEvent() {
        // Send event
        AccountCreatedEvent event = new AccountCreatedEvent(...);
        kafkaTemplate.send("account.created", event);
        
        // Verify consumption
        // ...
    }
}
```

## ⚠️ Production Checklist

- [ ] **Multiple Brokers** - Add 2+ brokers for HA
- [ ] **Replication Factor** - Set to 3 for critical topics
- [ ] **Monitoring** - Set up Prometheus + Grafana
- [ ] **Alerts** - Configure alerts for lag, errors
- [ ] **Backup** - Enable topic backups
- [ ] **Security** - Enable SSL/SASL authentication
- [ ] **Resource Limits** - Set proper memory/CPU limits
- [ ] **Retention Policy** - Configure based on compliance
- [ ] **Partitioning Strategy** - Plan for scale
- [ ] **Schema Registry** - Use for schema evolution

## 📈 Performance Tips

1. **Batch Processing** - Process messages in batches
2. **Async Processing** - Use async consumers
3. **Partitioning** - More partitions = more parallelism
4. **Compression** - Use snappy/lz4 compression
5. **Consumer Tuning** - Adjust fetch.min.bytes, max.poll.records
6. **Producer Tuning** - Adjust batch.size, linger.ms

## 🎓 Learning Resources

- Apache Kafka Docs: https://kafka.apache.org/documentation/
- Spring Kafka: https://spring.io/projects/spring-kafka
- Confluent Platform: https://docs.confluent.io/

## 🎉 Next Steps

1. ✅ **Kafka Setup** - DONE!
2. ⏭️ **Add Kafka to each microservice** - Producers & Consumers
3. ⏭️ **Test event flows** - End-to-end testing
4. ⏭️ **Add monitoring** - Grafana dashboards
5. ⏭️ **Move to Compliance Layer** - Audit logs, KYC
