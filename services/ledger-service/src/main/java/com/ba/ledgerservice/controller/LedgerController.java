package com.ba.ledgerservice.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.ba.ledgerservice.model.Ledger;
import com.ba.ledgerservice.service.LedgerService;

import java.util.List;
import java.util.Optional;


@RestController
@RequestMapping("/ledger")
public class LedgerController {

    @Autowired
    private LedgerService ledgerService;

    @PostMapping
    public Ledger create(@RequestBody Ledger entry){
        return ledgerService.createEntry(entry);
    }

    @GetMapping("/{id}")
    public Optional<Ledger> getById(@PathVariable Long id){
        return ledgerService.getById(id);
    }

    @GetMapping("/account/{accountId}")
    public List<Ledger> getByAccount(@PathVariable Long id){
        return ledgerService.getByAccount(id);
    }

    @GetMapping("/tx/{transactionId}")
    public List<Ledger> getByTransaction(@PathVariable Long id){
        return ledgerService.getByTransaction(id);
    }
}