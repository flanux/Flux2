package com.ba.transactionservice.model;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "transactions")
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String transactionId;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal amount;

    @Column(nullable = false, length = 3)
    private String currency;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TransactionType transactionType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TransactionStatus transactionStatus;

    private String description;

    private Long fromAccountId;
    private Long toAccountId;
    private String toAccountNumber;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (transactionStatus == null) transactionStatus = TransactionStatus.COMPLETED;
        if (currency == null) currency = "NPR";
        if (transactionId == null) transactionId = "TXN" + System.currentTimeMillis() + (int)(Math.random() * 10000);
    }

    public enum TransactionType { DEPOSIT, WITHDRAWAL, TRANSFER }
    public enum TransactionStatus { COMPLETED, PENDING, FAILED }
}
