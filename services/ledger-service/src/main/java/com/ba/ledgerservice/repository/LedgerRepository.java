package com.ba.ledgerservice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.ba.ledgerservice.model.Ledger;
import java.util.List;

public interface LedgerRepository extends JpaRepository<Ledger,   Long> {
    
    List<Ledger> findByAccountId(Long accountId);
    List<Ledger> findByTransactionId(Long transactionId);
};