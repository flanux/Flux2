package com.ba.transactionservice.repository;
import com.ba.transactionservice.model.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDateTime;
import java.util.List;

public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    List<Transaction> findByFromAccountIdOrToAccountIdOrderByCreatedAtDesc(Long fromId, Long toId);
    @Query("SELECT t FROM Transaction t WHERE t.toAccountNumber = :accountNumber ORDER BY t.createdAt DESC")
    List<Transaction> findByAccountNumber(@Param("accountNumber") String accountNumber);
    @Query("SELECT t FROM Transaction t WHERE t.createdAt >= :start ORDER BY t.createdAt DESC")
    List<Transaction> findToday(@Param("start") LocalDateTime start);
}
