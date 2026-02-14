package com.ba.transactionservice.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.ba.transactionservice.model.Transaction;
import com.ba.transactionservice.service.TransactionService;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/Transactions")
public class TransactionController{

    @Autowired
    private TransactionService txService;

    @PostMapping
    public Transaction create(@RequestBody Transaction tx){
        return txService.createTransaction(tx);
    }

    @GetMapping("/{id}")
    public Optional<Transaction> getById(@PathVariable Long id){
        return txService.getTransactionById(id);
    }

    @GetMapping("/account/{accountId}")
    public List<Transaction> getByAccount(@PathVariable Long accountId){
        return txService.getTransactionsByAccountId(accountId);
    }

    @PutMapping("/{id}/status")
    public Transaction updateStatus(@PathVariable Long id, @RequestParam Integer status){
        return txService.updateStatus(id, status);
    }
}