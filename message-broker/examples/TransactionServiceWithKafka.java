package com.flanux.transaction.service;

import com.flanux.transaction.entity.Transaction;
import com.flanux.transaction.event.TransactionEvent;
import com.flanux.transaction.kafka.TransactionEventProducer;
import com.flanux.transaction.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Transaction Service with Kafka Integration
 * Demonstrates the Transactional Outbox Pattern
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class TransactionService {

    private final TransactionRepository transactionRepository;
    private final TransactionEventProducer eventProducer;
    private final LedgerService ledgerService;
    private final AccountService accountService;

    /**
     * Process a transaction with event publishing
     * Uses database transaction to ensure consistency
     */
    @Transactional
    public Transaction processTransaction(
            Long fromAccountId,
            Long toAccountId,
            BigDecimal amount,
            String description) {
        
        try {
            log.info("Processing transaction: {} from account {} to account {}", 
                    amount, fromAccountId, toAccountId);
            
            // 1. Validate transaction
            validateTransaction(fromAccountId, toAccountId, amount);
            
            // 2. Create transaction record
            Transaction transaction = Transaction.builder()
                    .transactionId(generateTransactionId())
                    .fromAccountId(fromAccountId)
                    .toAccountId(toAccountId)
                    .amount(amount)
                    .currency("USD")
                    .description(description)
                    .transactionType("TRANSFER")
                    .transactionStatus("PENDING")
                    .transactionChannel("API")
                    .initiatedAt(LocalDateTime.now())
                    .build();
            
            // 3. Save transaction
            transaction = transactionRepository.save(transaction);
            
            // 4. Publish transaction initiated event
            eventProducer.publishTransactionInitiated(
                    TransactionEvent.fromTransaction(transaction));
            
            // 5. Update account balances
            BigDecimal fromBalanceAfter = accountService.debit(fromAccountId, amount);
            BigDecimal toBalanceAfter = accountService.credit(toAccountId, amount);
            
            // 6. Update transaction with balance info
            transaction.setFromAccountBalanceAfter(fromBalanceAfter);
            transaction.setToAccountBalanceAfter(toBalanceAfter);
            transaction.setTransactionStatus("COMPLETED");
            transaction.setCompletedAt(LocalDateTime.now());
            transaction = transactionRepository.save(transaction);
            
            // 7. Create ledger entries
            ledgerService.createLedgerEntries(transaction);
            
            // 8. Publish transaction completed event
            eventProducer.publishTransactionCompleted(
                    TransactionEvent.fromTransaction(transaction));
            
            log.info("Transaction {} completed successfully", transaction.getTransactionId());
            
            return transaction;
            
        } catch (Exception e) {
            log.error("Transaction failed: {}", e.getMessage(), e);
            
            // Publish transaction failed event
            TransactionEvent failedEvent = TransactionEvent.builder()
                    .fromAccountId(fromAccountId)
                    .toAccountId(toAccountId)
                    .amount(amount)
                    .failureReason(e.getMessage())
                    .build();
            
            eventProducer.publishTransactionFailed(failedEvent);
            
            throw new RuntimeException("Transaction processing failed", e);
        }
    }

    /**
     * Reverse a transaction
     */
    @Transactional
    public Transaction reverseTransaction(String transactionId, String reason) {
        
        log.info("Reversing transaction: {}, reason: {}", transactionId, reason);
        
        Transaction originalTransaction = transactionRepository
                .findByTransactionId(transactionId)
                .orElseThrow(() -> new RuntimeException("Transaction not found"));
        
        if (originalTransaction.getIsReversed()) {
            throw new RuntimeException("Transaction already reversed");
        }
        
        // Create reversal transaction
        Transaction reversalTransaction = Transaction.builder()
                .transactionId(generateTransactionId())
                .fromAccountId(originalTransaction.getToAccountId())
                .toAccountId(originalTransaction.getFromAccountId())
                .amount(originalTransaction.getAmount())
                .currency(originalTransaction.getCurrency())
                .description("Reversal: " + originalTransaction.getDescription())
                .transactionType("REVERSAL")
                .transactionStatus("COMPLETED")
                .transactionChannel("INTERNAL")
                .initiatedAt(LocalDateTime.now())
                .completedAt(LocalDateTime.now())
                .build();
        
        reversalTransaction = transactionRepository.save(reversalTransaction);
        
        // Update original transaction
        originalTransaction.setIsReversed(true);
        originalTransaction.setReversedAt(LocalDateTime.now());
        originalTransaction.setReversalTransactionId(reversalTransaction.getTransactionId());
        originalTransaction.setReversalReason(reason);
        transactionRepository.save(originalTransaction);
        
        // Update balances
        accountService.credit(originalTransaction.getFromAccountId(), originalTransaction.getAmount());
        accountService.debit(originalTransaction.getToAccountId(), originalTransaction.getAmount());
        
        // Create ledger entries
        ledgerService.createLedgerEntries(reversalTransaction);
        
        // Publish reversal event
        eventProducer.publishTransactionReversed(
                TransactionEvent.fromTransaction(reversalTransaction));
        
        return reversalTransaction;
    }

    private void validateTransaction(Long fromAccountId, Long toAccountId, BigDecimal amount) {
        if (fromAccountId == null || toAccountId == null) {
            throw new RuntimeException("Invalid account IDs");
        }
        
        if (fromAccountId.equals(toAccountId)) {
            throw new RuntimeException("Cannot transfer to same account");
        }
        
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new RuntimeException("Invalid amount");
        }
        
        // Check if from account has sufficient balance
        if (!accountService.hasSufficientBalance(fromAccountId, amount)) {
            throw new RuntimeException("Insufficient balance");
        }
    }

    private String generateTransactionId() {
        return "TXN" + System.currentTimeMillis();
    }
}
