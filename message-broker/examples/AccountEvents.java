package com.flanux.account.event;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Event published when a new account is created
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AccountCreatedEvent {
    private Long accountId;
    private String accountNumber;
    private Long customerId;
    private String accountType;
    private String currency;
    private BigDecimal initialBalance;
    private String branchCode;
    private LocalDateTime createdAt;
    private String createdBy;
}

/**
 * Event published when account details are updated
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AccountUpdatedEvent {
    private Long accountId;
    private String accountNumber;
    private String fieldUpdated;
    private String oldValue;
    private String newValue;
    private LocalDateTime updatedAt;
    private String updatedBy;
}

/**
 * Event published when account balance changes
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BalanceChangedEvent {
    private Long accountId;
    private String accountNumber;
    private BigDecimal previousBalance;
    private BigDecimal newBalance;
    private BigDecimal changeAmount;
    private String transactionId;
    private String transactionType;
    private LocalDateTime changedAt;
}

/**
 * Event published when account is closed
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AccountClosedEvent {
    private Long accountId;
    private String accountNumber;
    private Long customerId;
    private String closureReason;
    private BigDecimal finalBalance;
    private LocalDateTime closedAt;
    private String closedBy;
}

/**
 * Event published when account statement is generated
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StatementGeneratedEvent {
    private Long statementId;
    private String accountNumber;
    private String statementPeriod;
    private String filePath;
    private LocalDateTime generatedAt;
}
