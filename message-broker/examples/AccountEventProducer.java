package com.flanux.account.kafka;

import com.flanux.account.event.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

import java.util.concurrent.CompletableFuture;

/**
 * Kafka Producer for Account Service
 * Publishes account-related events to Kafka topics
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AccountEventProducer {

    private final KafkaTemplate<String, Object> kafkaTemplate;

    @Value("${account-service.kafka.topics.account-created}")
    private String accountCreatedTopic;

    @Value("${account-service.kafka.topics.account-updated}")
    private String accountUpdatedTopic;

    @Value("${account-service.kafka.topics.balance-changed}")
    private String balanceChangedTopic;

    @Value("${account-service.kafka.topics.account-closed}")
    private String accountClosedTopic;

    /**
     * Publish account created event
     */
    public void publishAccountCreated(AccountCreatedEvent event) {
        sendEvent(accountCreatedTopic, event.getAccountNumber(), event);
    }

    /**
     * Publish account updated event
     */
    public void publishAccountUpdated(AccountUpdatedEvent event) {
        sendEvent(accountUpdatedTopic, event.getAccountNumber(), event);
    }

    /**
     * Publish balance changed event
     */
    public void publishBalanceChanged(BalanceChangedEvent event) {
        sendEvent(balanceChangedTopic, event.getAccountNumber(), event);
    }

    /**
     * Publish account closed event
     */
    public void publishAccountClosed(AccountClosedEvent event) {
        sendEvent(accountClosedTopic, event.getAccountNumber(), event);
    }

    /**
     * Generic method to send events to Kafka
     */
    private void sendEvent(String topic, String key, Object event) {
        try {
            CompletableFuture<SendResult<String, Object>> future = 
                kafkaTemplate.send(topic, key, event);

            future.whenComplete((result, ex) -> {
                if (ex == null) {
                    log.info("Event sent successfully to topic: {} with key: {}, partition: {}, offset: {}",
                            topic, key, 
                            result.getRecordMetadata().partition(),
                            result.getRecordMetadata().offset());
                } else {
                    log.error("Failed to send event to topic: {} with key: {}, error: {}",
                            topic, key, ex.getMessage());
                }
            });
        } catch (Exception e) {
            log.error("Exception while sending event to topic: {}, error: {}", topic, e.getMessage(), e);
        }
    }
}
