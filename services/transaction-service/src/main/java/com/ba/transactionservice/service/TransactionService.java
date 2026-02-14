package com.ba.transactionservice.service;

import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;

import com.ba.transactionservice.model.Transaction;
import com.ba.transactionservice.repository.TransactionRepository;

import java.util.List;
import java.util.Optional;

@Service
public class TransactionService {

    @Autowired
    private TransactionRepository txRepo;

    public Transaction createTransaction(Transaction tx) {

        if(tx.getTimeStamp() == null) {
            tx.setTimeStamp(System.currentTimeMillis());
        }

        if(tx.getStatus() == null) {
            tx.setStatus(0);
        }

        return txRepo.save(tx);
    }

    public Optional<Transaction> getTransactionById(Long id) {
        return txRepo.findById(id);
    }

    public List<Transaction> getTransactionsByAccountId(Long accountId){
        return txRepo.findByAccountId(accountId);
    }

    public Transaction updateStatus(Long id, Integer status) {
        Transaction t = txRepo.findById(id)
            .orElseThrow(()-> new RuntimeException("Transaction not found"));
        t.setStatus(status);
        return  txRepo.save(t);
    }
}