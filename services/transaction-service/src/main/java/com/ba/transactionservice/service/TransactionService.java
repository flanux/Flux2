package com.ba.transactionservice.service;
import com.ba.transactionservice.dto.TransferRequest;
import com.ba.transactionservice.model.Transaction;
import com.ba.transactionservice.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Service @RequiredArgsConstructor
public class TransactionService {
    private final TransactionRepository transactionRepository;

    public List<Transaction> getByAccountId(Long accountId) {
        return transactionRepository.findByFromAccountIdOrToAccountIdOrderByCreatedAtDesc(accountId, accountId);
    }

    public List<Transaction> getAll() {
        return transactionRepository.findAll();
    }

    public Transaction getById(Long id) {
        return transactionRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Transaction not found: " + id));
    }

    public List<Transaction> getByAccountNumber(String accountNumber) {
        return transactionRepository.findByAccountNumber(accountNumber);
    }

    public List<Transaction> getToday() {
        LocalDateTime startOfDay = LocalDateTime.now().withHour(0).withMinute(0).withSecond(0);
        return transactionRepository.findToday(startOfDay);
    }

    @Transactional
    public Transaction transfer(TransferRequest req) {
        Transaction txn = Transaction.builder()
            .amount(req.getAmount())
            .currency("NPR")
            .transactionType(Transaction.TransactionType.TRANSFER)
            .transactionStatus(Transaction.TransactionStatus.COMPLETED)
            .description(req.getDescription() != null ? req.getDescription() : "Transfer")
            .fromAccountId(req.getFromAccountId())
            .toAccountNumber(req.getToAccountNumber())
            .build();
        return transactionRepository.save(txn);
    }

    @Transactional
    public Transaction deposit(Long accountId, BigDecimal amount, String description) {
        Transaction txn = Transaction.builder()
            .amount(amount)
            .currency("NPR")
            .transactionType(Transaction.TransactionType.DEPOSIT)
            .transactionStatus(Transaction.TransactionStatus.COMPLETED)
            .description(description != null ? description : "Deposit")
            .toAccountId(accountId)
            .build();
        return transactionRepository.save(txn);
    }

    @Transactional
    public Transaction withdrawal(Long accountId, BigDecimal amount, String description) {
        Transaction txn = Transaction.builder()
            .amount(amount)
            .currency("NPR")
            .transactionType(Transaction.TransactionType.WITHDRAWAL)
            .transactionStatus(Transaction.TransactionStatus.COMPLETED)
            .description(description != null ? description : "Withdrawal")
            .fromAccountId(accountId)
            .build();
        return transactionRepository.save(txn);
    }
}
