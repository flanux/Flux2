package com.flanux.audit.service;

import com.flanux.audit.entity.AuditLog;
import com.flanux.audit.repository.AuditLogRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.Acknowledgment;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * Audit Service - Listens to ALL events and logs them
 * Provides complete audit trail for compliance
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AuditService {

    private final AuditLogRepository auditLogRepository;
    private final ElasticsearchService elasticsearchService;

    /**
     * Log account creation events
     */
    @KafkaListener(
        topics = "account.created",
        groupId = "audit-consumer-group"
    )
    @Transactional
    public void auditAccountCreated(Map<String, Object> event, Acknowledgment ack) {
        try {
            AuditLog log = AuditLog.builder()
                    .action("CREATE")
                    .entityType("ACCOUNT")
                    .entityId(event.get("accountId").toString())
                    .description("Account created: " + event.get("accountNumber"))
                    .newValue(event)
                    .severity("INFO")
                    .username(event.getOrDefault("createdBy", "system").toString())
                    .createdAt(LocalDateTime.now())
                    .build();
            
            // Save to PostgreSQL
            auditLogRepository.save(log);
            
            // Index in Elasticsearch for search
            elasticsearchService.indexAuditLog(log);
            
            ack.acknowledge();
            log.info("Audited account creation: {}", event.get("accountNumber"));
            
        } catch (Exception e) {
            log.error("Failed to audit account creation", e);
        }
    }

    /**
     * Log all transaction events
     */
    @KafkaListener(
        topics = {
            "transaction.initiated",
            "transaction.completed",
            "transaction.failed",
            "transaction.reversed"
        },
        groupId = "audit-consumer-group"
    )
    @Transactional
    public void auditTransaction(Map<String, Object> event, Acknowledgment ack) {
        try {
            String action = determineAction(event);
            
            AuditLog log = AuditLog.builder()
                    .action(action)
                    .entityType("TRANSACTION")
                    .entityId(event.get("transactionId").toString())
                    .description(buildTransactionDescription(event))
                    .newValue(event)
                    .severity(determineSeverity(event))
                    .username(event.getOrDefault("processedBy", "system").toString())
                    .metadata(event)
                    .createdAt(LocalDateTime.now())
                    .build();
            
            auditLogRepository.save(log);
            elasticsearchService.indexAuditLog(log);
            
            ack.acknowledge();
            
        } catch (Exception e) {
            log.error("Failed to audit transaction", e);
        }
    }

    /**
     * Log user login/logout events
     */
    @KafkaListener(
        topics = {"audit.user.login", "audit.user.logout"},
        groupId = "audit-consumer-group"
    )
    @Transactional
    public void auditUserActivity(Map<String, Object> event, Acknowledgment ack) {
        try {
            AuditLog log = AuditLog.builder()
                    .action(event.get("action").toString())
                    .entityType("USER")
                    .entityId(event.get("userId").toString())
                    .username(event.get("username").toString())
                    .description(event.get("action") + " activity")
                    .ipAddress(event.getOrDefault("ipAddress", "").toString())
                    .userAgent(event.getOrDefault("userAgent", "").toString())
                    .severity("INFO")
                    .createdAt(LocalDateTime.now())
                    .build();
            
            auditLogRepository.save(log);
            elasticsearchService.indexAuditLog(log);
            
            ack.acknowledge();
            
        } catch (Exception e) {
            log.error("Failed to audit user activity", e);
        }
    }

    /**
     * Log security events with high priority
     */
    @KafkaListener(
        topics = {"fraud.alert", "card.blocked"},
        groupId = "audit-consumer-group"
    )
    @Transactional
    public void auditSecurityEvent(Map<String, Object> event, Acknowledgment ack) {
        try {
            AuditLog log = AuditLog.builder()
                    .action("SECURITY_ALERT")
                    .entityType("SECURITY")
                    .entityId(event.getOrDefault("alertId", "").toString())
                    .description("Security event: " + event.get("description"))
                    .newValue(event)
                    .severity("CRITICAL")
                    .metadata(event)
                    .createdAt(LocalDateTime.now())
                    .build();
            
            auditLogRepository.save(log);
            elasticsearchService.indexAuditLog(log);
            
            // Send alert to compliance team
            sendSecurityAlert(log);
            
            ack.acknowledge();
            
        } catch (Exception e) {
            log.error("Failed to audit security event", e);
        }
    }

    /**
     * Log data access for sensitive information
     */
    public void logDataAccess(Long userId, String username, String dataType, 
                              String dataId, String accessType, String ipAddress) {
        
        AuditLog log = AuditLog.builder()
                .action("VIEW")
                .entityType(dataType)
                .entityId(dataId)
                .userId(userId)
                .username(username)
                .description(String.format("User %s accessed %s", username, dataType))
                .ipAddress(ipAddress)
                .severity("INFO")
                .createdAt(LocalDateTime.now())
                .build();
        
        auditLogRepository.save(log);
        elasticsearchService.indexAuditLog(log);
    }

    /**
     * Generate compliance report
     */
    public Map<String, Object> generateComplianceReport(LocalDateTime fromDate, LocalDateTime toDate) {
        
        long totalEvents = auditLogRepository.countByCreatedAtBetween(fromDate, toDate);
        long criticalEvents = auditLogRepository.countBySeverityAndCreatedAtBetween("CRITICAL", fromDate, toDate);
        
        Map<String, Long> eventsByAction = auditLogRepository.countEventsByAction(fromDate, toDate);
        Map<String, Long> eventsByEntity = auditLogRepository.countEventsByEntityType(fromDate, toDate);
        
        return Map.of(
            "totalEvents", totalEvents,
            "criticalEvents", criticalEvents,
            "eventsByAction", eventsByAction,
            "eventsByEntity", eventsByEntity,
            "period", Map.of("from", fromDate, "to", toDate)
        );
    }

    private String determineAction(Map<String, Object> event) {
        String status = event.getOrDefault("transactionStatus", "").toString();
        return switch (status) {
            case "COMPLETED" -> "TRANSFER";
            case "FAILED" -> "FAILURE";
            case "REVERSED" -> "REVERSAL";
            default -> "TRANSACTION";
        };
    }

    private String buildTransactionDescription(Map<String, Object> event) {
        return String.format("Transaction %s: %s %s",
                event.get("transactionId"),
                event.get("amount"),
                event.get("transactionType"));
    }

    private String determineSeverity(Map<String, Object> event) {
        String status = event.getOrDefault("transactionStatus", "").toString();
        Double amount = ((Number) event.getOrDefault("amount", 0)).doubleValue();
        
        if ("FAILED".equals(status)) {
            return "WARNING";
        }
        if (amount > 100000) {
            return "CRITICAL";
        }
        return "INFO";
    }

    private void sendSecurityAlert(AuditLog log) {
        // Send email/SMS to compliance team
        log.warn("SECURITY ALERT: {}", log.getDescription());
    }
}
