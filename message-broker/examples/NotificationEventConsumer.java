package com.flanux.notification.kafka;

import com.flanux.notification.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.Acknowledgment;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * Kafka Consumer for Notification Service
 * Listens to various topics and sends notifications
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class NotificationEventConsumer {

    private final NotificationService notificationService;

    /**
     * Listen to account created events
     */
    @KafkaListener(
        topics = "account.created",
        groupId = "notification-consumer-group",
        containerFactory = "kafkaListenerContainerFactory"
    )
    public void handleAccountCreated(
            @Payload Map<String, Object> event,
            @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
            @Header(KafkaHeaders.RECEIVED_PARTITION) int partition,
            @Header(KafkaHeaders.OFFSET) long offset,
            Acknowledgment acknowledgment) {
        
        try {
            log.info("Received account.created event from topic: {}, partition: {}, offset: {}",
                    topic, partition, offset);
            
            String accountNumber = (String) event.get("accountNumber");
            Long customerId = ((Number) event.get("customerId")).longValue();
            
            // Send welcome email/SMS
            notificationService.sendAccountCreatedNotification(customerId, accountNumber);
            
            // Manually commit the offset
            acknowledgment.acknowledge();
            
            log.info("Successfully processed account.created event for account: {}", accountNumber);
            
        } catch (Exception e) {
            log.error("Error processing account.created event: {}", e.getMessage(), e);
            // Don't acknowledge - message will be retried
        }
    }

    /**
     * Listen to loan approved events
     */
    @KafkaListener(
        topics = "loan.application.approved",
        groupId = "notification-consumer-group"
    )
    public void handleLoanApproved(
            @Payload Map<String, Object> event,
            Acknowledgment acknowledgment) {
        
        try {
            log.info("Received loan.application.approved event");
            
            Long customerId = ((Number) event.get("customerId")).longValue();
            String loanNumber = (String) event.get("loanNumber");
            Double amount = ((Number) event.get("approvedAmount")).doubleValue();
            
            // Send approval notification
            notificationService.sendLoanApprovedNotification(customerId, loanNumber, amount);
            
            acknowledgment.acknowledge();
            
        } catch (Exception e) {
            log.error("Error processing loan.application.approved event: {}", e.getMessage(), e);
        }
    }

    /**
     * Listen to transaction completed events
     */
    @KafkaListener(
        topics = "transaction.completed",
        groupId = "notification-consumer-group"
    )
    public void handleTransactionCompleted(
            @Payload Map<String, Object> event,
            Acknowledgment acknowledgment) {
        
        try {
            log.info("Received transaction.completed event");
            
            String accountNumber = (String) event.get("accountNumber");
            Double amount = ((Number) event.get("amount")).doubleValue();
            String transactionType = (String) event.get("transactionType");
            
            // Send transaction alert
            notificationService.sendTransactionAlert(accountNumber, amount, transactionType);
            
            acknowledgment.acknowledge();
            
        } catch (Exception e) {
            log.error("Error processing transaction.completed event: {}", e.getMessage(), e);
        }
    }

    /**
     * Listen to card blocked events
     */
    @KafkaListener(
        topics = "card.blocked",
        groupId = "notification-consumer-group"
    )
    public void handleCardBlocked(
            @Payload Map<String, Object> event,
            Acknowledgment acknowledgment) {
        
        try {
            log.info("Received card.blocked event");
            
            Long customerId = ((Number) event.get("customerId")).longValue();
            String cardNumber = (String) event.get("lastFourDigits");
            String reason = (String) event.get("blockReason");
            
            // Send urgent notification
            notificationService.sendCardBlockedNotification(customerId, cardNumber, reason);
            
            acknowledgment.acknowledge();
            
        } catch (Exception e) {
            log.error("Error processing card.blocked event: {}", e.getMessage(), e);
        }
    }

    /**
     * Listen to fraud alerts
     */
    @KafkaListener(
        topics = "fraud.alert",
        groupId = "notification-consumer-group"
    )
    public void handleFraudAlert(
            @Payload Map<String, Object> event,
            Acknowledgment acknowledgment) {
        
        try {
            log.info("Received fraud.alert event - HIGH PRIORITY");
            
            Long customerId = ((Number) event.get("customerId")).longValue();
            String alertType = (String) event.get("alertType");
            String description = (String) event.get("description");
            
            // Send urgent security alert
            notificationService.sendFraudAlert(customerId, alertType, description);
            
            acknowledgment.acknowledge();
            
        } catch (Exception e) {
            log.error("Error processing fraud.alert event: {}", e.getMessage(), e);
        }
    }

    /**
     * Listen to payment overdue events
     */
    @KafkaListener(
        topics = "loan.payment.overdue",
        groupId = "notification-consumer-group"
    )
    public void handlePaymentOverdue(
            @Payload Map<String, Object> event,
            Acknowledgment acknowledgment) {
        
        try {
            log.info("Received loan.payment.overdue event");
            
            Long customerId = ((Number) event.get("customerId")).longValue();
            String loanNumber = (String) event.get("loanNumber");
            Double amount = ((Number) event.get("overdueAmount")).doubleValue();
            Integer daysOverdue = ((Number) event.get("daysOverdue")).intValue();
            
            // Send overdue payment reminder
            notificationService.sendPaymentOverdueReminder(
                customerId, loanNumber, amount, daysOverdue);
            
            acknowledgment.acknowledge();
            
        } catch (Exception e) {
            log.error("Error processing loan.payment.overdue event: {}", e.getMessage(), e);
        }
    }
}
