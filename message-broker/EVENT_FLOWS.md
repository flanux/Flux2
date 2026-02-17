# Event Flow Diagrams - Flanux Banking System

## 1. Account Creation Flow

```
┌─────────────┐
│   Client    │
│  (React/    │
│  Angular)   │
└──────┬──────┘
       │ POST /api/accounts
       ▼
┌─────────────┐
│ API Gateway │
│  (JWT Auth) │
└──────┬──────┘
       │
       ▼
┌──────────────────┐
│ Account Service  │
│                  │
│ 1. Create Account│──┐
│ 2. Save to DB    │  │
│ 3. Publish Event │  │
└──────┬───────────┘  │
       │              │
       │              │ Publish to Kafka
       ▼              ▼
┌─────────────────────────────────┐
│  Kafka Topic: account.created   │
│  {                              │
│    accountId: 123,              │
│    accountNumber: "ACC1001",    │
│    customerId: 456,             │
│    balance: 5000.00,            │
│    currency: "USD"              │
│  }                              │
└────┬─────────┬──────────┬──────┘
     │         │          │
     │         │          │
     ▼         ▼          ▼
┌─────────┐ ┌────────┐ ┌─────────┐
│Notific. │ │Ledger  │ │Audit    │
│Service  │ │Service │ │Service  │
│         │ │        │ │         │
│Send     │ │Create  │ │Log      │
│Welcome  │ │GL      │ │Account  │
│Email    │ │Entry   │ │Creation │
└─────────┘ └────────┘ └─────────┘
```

## 2. Money Transfer Flow

```
┌──────────────┐
│   Client     │
└──────┬───────┘
       │ POST /api/transactions
       ▼
┌──────────────────────┐
│ Transaction Service  │
│                      │
│ 1. Validate          │
│ 2. Create Txn Record │
│ 3. Publish INITIATED │
└──────┬───────────────┘
       │
       ▼
┌────────────────────────────────┐
│ Kafka: transaction.initiated   │
└────┬──────────────────────────┘
     │
     ▼
┌──────────────────┐
│  Fraud Service   │
│                  │
│  Check if        │
│  suspicious      │
└────┬─────────────┘
     │ OK
     ▼
┌──────────────────────┐
│ Transaction Service  │
│                      │
│ 1. Debit From Acct   │──┐
│ 2. Credit To Acct    │  │
│ 3. Update Status     │  │
│ 4. Publish COMPLETED │  │
└──────┬───────────────┘  │
       │                  │
       ▼                  ▼
┌────────────────────────────────┐
│ Kafka: transaction.completed   │
└────┬───────┬───────┬───────────┘
     │       │       │
     ▼       ▼       ▼
┌────────┐ ┌────────┐ ┌─────────┐
│Account │ │Ledger  │ │Notific. │
│Service │ │Service │ │Service  │
│        │ │        │ │         │
│Update  │ │Post    │ │Send SMS │
│Balance │ │Entry   │ │Alert    │
└────────┘ └────────┘ └─────────┘
```

## 3. Loan Application Flow

```
┌──────────────┐
│   Client     │
└──────┬───────┘
       │ POST /api/loans/apply
       ▼
┌────────────────────┐
│   Loan Service     │
│                    │
│ 1. Create App      │
│ 2. Save to DB      │
│ 3. Publish EVENT   │
└────┬───────────────┘
     │
     ▼
┌──────────────────────────────────┐
│ Kafka: loan.application.submitted│
└────┬─────────────────────────────┘
     │
     ▼
┌──────────────────┐
│ Credit Check     │
│ Service          │
│                  │
│ 1. Get Credit    │
│    Score         │
│ 2. Calculate DTI │
│ 3. Make Decision │
└────┬─────────────┘
     │
     ├──── APPROVED ────┐
     │                  │
     │                  ▼
     │         ┌────────────────────────┐
     │         │   Loan Service         │
     │         │                        │
     │         │ 1. Update Status       │
     │         │ 2. Set Terms           │
     │         │ 3. Publish APPROVED    │
     │         └────┬───────────────────┘
     │              │
     │              ▼
     │    ┌──────────────────────────────┐
     │    │ Kafka: loan.application.     │
     │    │        approved               │
     │    └────┬───────┬──────────────────┘
     │         │       │
     │         ▼       ▼
     │    ┌────────┐ ┌─────────┐
     │    │Notific.│ │Account  │
     │    │Service │ │Service  │
     │    │        │ │         │
     │    │Send    │ │Create   │
     │    │Email   │ │Loan Acct│
     │    └────────┘ └─────────┘
     │
     └──── REJECTED ────┐
                        │
                        ▼
               ┌────────────────────────┐
               │   Loan Service         │
               │                        │
               │ 1. Update Status       │
               │ 2. Add Reason          │
               │ 3. Publish REJECTED    │
               └────┬───────────────────┘
                    │
                    ▼
          ┌──────────────────────────────┐
          │ Kafka: loan.application.     │
          │        rejected               │
          └────┬─────────────────────────┘
               │
               ▼
          ┌─────────┐
          │Notific. │
          │Service  │
          │         │
          │Send     │
          │Rejection│
          │Email    │
          └─────────┘
```

## 4. Card Transaction Authorization Flow

```
┌──────────────┐
│  POS/ATM     │
│  Terminal    │
└──────┬───────┘
       │ Card Swipe
       ▼
┌────────────────────┐
│   Card Service     │
│                    │
│ 1. Validate Card   │
│ 2. Check Limits    │
│ 3. Publish EVENT   │
└────┬───────────────┘
     │
     ▼
┌──────────────────────────────────────┐
│ Kafka: card.transaction.initiated    │
└────┬─────────────────────────────────┘
     │
     ▼
┌──────────────────┐
│  Fraud Service   │
│                  │
│ 1. Check Velocity│
│ 2. Check Location│
│ 3. Risk Score    │
└────┬─────────────┘
     │
     ├──── OK (Score < 50) ────┐
     │                          │
     │                          ▼
     │              ┌────────────────────┐
     │              │  Card Service      │
     │              │                    │
     │              │ 1. Authorize       │
     │              │ 2. Deduct Balance  │
     │              │ 3. Publish AUTH    │
     │              └────┬───────────────┘
     │                   │
     │                   ▼
     │         ┌────────────────────────────────┐
     │         │ Kafka: card.transaction.       │
     │         │        authorized              │
     │         └────┬───────┬───────────────────┘
     │              │       │
     │              ▼       ▼
     │         ┌────────┐ ┌─────────┐
     │         │Ledger  │ │Notific. │
     │         │Service │ │Service  │
     │         │        │ │         │
     │         │Post    │ │Send SMS │
     │         │Entry   │ │Alert    │
     │         └────────┘ └─────────┘
     │
     └──── FRAUD (Score >= 50) ────┐
                                    │
                                    ▼
                        ┌────────────────────┐
                        │  Card Service      │
                        │                    │
                        │ 1. Decline         │
                        │ 2. Block Card      │
                        │ 3. Publish DECLINE │
                        └────┬───────────────┘
                             │
                             ▼
                   ┌────────────────────────────┐
                   │ Kafka: card.blocked        │
                   │        fraud.alert         │
                   └────┬───────────────────────┘
                        │
                        ▼
                   ┌─────────┐
                   │Notific. │
                   │Service  │
                   │         │
                   │Send     │
                   │URGENT   │
                   │Alert    │
                   └─────────┘
```

## 5. Loan Payment Processing

```
┌──────────────┐
│   Client     │
└──────┬───────┘
       │ POST /api/loans/{id}/payment
       ▼
┌────────────────────┐
│   Loan Service     │
│                    │
│ 1. Validate        │
│ 2. Process Payment │
│ 3. Update Loan     │
│ 4. Publish EVENT   │
└────┬───────────────┘
     │
     ▼
┌────────────────────────────────┐
│ Kafka: loan.payment.received   │
└────┬───────┬───────────────────┘
     │       │
     ▼       ▼
┌────────┐ ┌─────────┐
│Account │ │Ledger   │
│Service │ │Service  │
│        │ │         │
│Credit  │ │Post     │
│Account │ │Payment  │
└────────┘ └─────────┘
```

## 6. End-of-Day Batch Processing

```
┌──────────────┐
│ Scheduler    │
│ (Cron Job)   │
└──────┬───────┘
       │ Daily at 11:59 PM
       ▼
┌───────────────────────┐
│ Reporting Service     │
│                       │
│ 1. Trigger EOD        │
│ 2. Publish EVENT      │
└────┬──────────────────┘
     │
     ▼
┌────────────────────────────────┐
│ Kafka: eod.processing.started  │
└────┬───────┬──────────┬────────┘
     │       │          │
     ▼       ▼          ▼
┌────────┐ ┌─────────┐ ┌────────┐
│Account │ │Loan     │ │Card    │
│Service │ │Service  │ │Service │
│        │ │         │ │        │
│Calc    │ │Check    │ │Process │
│Interest│ │Overdue  │ │Pending │
└────┬───┘ └────┬────┘ └────┬───┘
     │          │           │
     │          │           │
     ▼          ▼           ▼
┌────────────────────────────────┐
│ Kafka: Various EOD Events      │
│ - interest.calculated          │
│ - payment.overdue              │
│ - statement.generated          │
└────┬───────────────────────────┘
     │
     ▼
┌─────────────────┐
│ Ledger Service  │
│                 │
│ Create EOD      │
│ Journal Entries │
│ Balance Snapshot│
└─────────────────┘
```

## 7. Saga Pattern - Account Transfer with Compensation

```
Happy Path:
┌──────────────────────┐
│ Transaction Service  │
│ ORCHESTRATOR         │
└────┬─────────────────┘
     │
     ├─ Step 1: Debit Source Account
     │  ▼
     │  ┌────────────────┐
     │  │ Account Service│──► Success
     │  └────────────────┘
     │
     ├─ Step 2: Credit Target Account
     │  ▼
     │  ┌────────────────┐
     │  │ Account Service│──► Success
     │  └────────────────┘
     │
     ├─ Step 3: Update Ledger
     │  ▼
     │  ┌────────────────┐
     │  │ Ledger Service │──► Success
     │  └────────────────┘
     │
     └─ Complete ✓

Failure with Compensation:
┌──────────────────────┐
│ Transaction Service  │
│ ORCHESTRATOR         │
└────┬─────────────────┘
     │
     ├─ Step 1: Debit Source Account
     │  ▼
     │  ┌────────────────┐
     │  │ Account Service│──► Success
     │  └────────────────┘
     │
     ├─ Step 2: Credit Target Account
     │  ▼
     │  ┌────────────────┐
     │  │ Account Service│──► FAIL! (Account Frozen)
     │  └────────────────┘
     │
     └─ COMPENSATION STARTS
        │
        ├─ Compensate Step 1: Credit Back Source
        │  ▼
        │  ┌────────────────┐
        │  │ Account Service│──► Compensated
        │  └────────────────┘
        │
        └─ Publish transaction.failed
```

## Consumer Group Pattern

```
Topic: transaction.completed (10 partitions)

┌──────────────────────────────────────┐
│  Consumer Group: notification-group  │
├──────────────────────────────────────┤
│                                      │
│  Consumer 1 ───► Partition 0,1,2,3  │
│  Consumer 2 ───► Partition 4,5,6    │
│  Consumer 3 ───► Partition 7,8,9    │
│                                      │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  Consumer Group: ledger-group        │
├──────────────────────────────────────┤
│                                      │
│  Consumer 1 ───► Partition 0,1,2,3  │
│  Consumer 2 ───► Partition 4,5,6,7  │
│  Consumer 3 ───► Partition 8,9      │
│                                      │
└──────────────────────────────────────┘

Both groups consume ALL messages independently!
```

## Key Takeaways

1. **Loose Coupling** - Services don't call each other directly
2. **Scalability** - Add more consumers to handle load
3. **Resilience** - Failed consumers don't affect producers
4. **Audit Trail** - All events stored in Kafka
5. **Event Replay** - Can replay events from any point
6. **Real-time** - Instant propagation of changes
7. **Flexibility** - Easy to add new consumers
