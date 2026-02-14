#!/bin/bash

# ============================================
# Kafka Topics Creation Script
# Run this after Kafka is up and running
# ============================================

KAFKA_BROKER="localhost:9092"

echo "🚀 Creating Kafka Topics for Flanux Microservices..."
echo ""

# Function to create topic
create_topic() {
    local topic_name=$1
    local partitions=$2
    local replication=$3
    
    echo "Creating topic: $topic_name (partitions: $partitions, replication: $replication)"
    
    docker exec flanux-kafka kafka-topics --create \
        --bootstrap-server kafka:29092 \
        --topic "$topic_name" \
        --partitions "$partitions" \
        --replication-factor "$replication" \
        --if-not-exists \
        --config retention.ms=604800000 \
        --config segment.ms=86400000
}

# Account Events
create_topic "account.created" 3 1
create_topic "account.updated" 3 1
create_topic "account.closed" 3 1
create_topic "account.balance.changed" 5 1
create_topic "account.statement.generated" 2 1

# Customer Events
create_topic "customer.registered" 3 1
create_topic "customer.updated" 3 1
create_topic "customer.kyc.verified" 2 1
create_topic "customer.kyc.rejected" 2 1
create_topic "customer.status.changed" 2 1

# Loan Events
create_topic "loan.application.submitted" 3 1
create_topic "loan.application.approved" 3 1
create_topic "loan.application.rejected" 2 1
create_topic "loan.disbursed" 3 1
create_topic "loan.payment.received" 5 1
create_topic "loan.payment.overdue" 3 1
create_topic "loan.payment.missed" 3 1
create_topic "loan.paid.off" 2 1

# Card Events
create_topic "card.issued" 3 1
create_topic "card.activated" 3 1
create_topic "card.blocked" 3 1
create_topic "card.transaction.authorized" 10 1
create_topic "card.transaction.declined" 5 1
create_topic "card.limit.exceeded" 3 1
create_topic "card.expired" 2 1

# Transaction Events
create_topic "transaction.initiated" 10 1
create_topic "transaction.completed" 10 1
create_topic "transaction.failed" 5 1
create_topic "transaction.reversed" 5 1
create_topic "transaction.disputed" 3 1
create_topic "transaction.approved" 5 1
create_topic "transaction.rejected" 5 1

# Ledger Events
create_topic "ledger.entry.posted" 10 1
create_topic "ledger.journal.created" 5 1
create_topic "ledger.balance.snapshot" 3 1

# Notification Events
create_topic "notification.email.send" 5 1
create_topic "notification.sms.send" 5 1
create_topic "notification.push.send" 5 1
create_topic "notification.delivered" 5 1
create_topic "notification.failed" 3 1

# Audit Events
create_topic "audit.user.login" 5 1
create_topic "audit.user.logout" 3 1
create_topic "audit.data.modified" 5 1
create_topic "audit.permission.changed" 2 1
create_topic "audit.security.alert" 3 1

# Fraud Detection Events
create_topic "fraud.alert" 5 1
create_topic "fraud.transaction.flagged" 5 1
create_topic "fraud.investigation.opened" 3 1

# Reporting Events
create_topic "report.generated" 2 1
create_topic "report.scheduled" 2 1

# Dead Letter Queue (for failed messages)
create_topic "dlq.account.events" 3 1
create_topic "dlq.transaction.events" 5 1
create_topic "dlq.notification.events" 3 1
create_topic "dlq.general" 3 1

echo ""
echo "✅ All topics created successfully!"
echo ""
echo "📊 Listing all topics:"
docker exec flanux-kafka kafka-topics --list --bootstrap-server kafka:29092

echo ""
echo "🎉 Kafka is ready for use!"
echo ""
echo "Access Kafka UI at: http://localhost:8090"
echo "Access Kafdrop at: http://localhost:9000"
