package com.ba.transactionservice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.ba.transactionservice.model.Transaction;
import java.util.List;

public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    List<Transaction> findByAccountId(Long accountId);
};