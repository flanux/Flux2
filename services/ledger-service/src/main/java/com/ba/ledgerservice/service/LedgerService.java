package com.ba.ledgerservice.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.ba.ledgerservice.model.Ledger;
import com.ba.ledgerservice.repository.LedgerRepository;

import java.util.List;
import java.util.Optional;

@Service
public class LedgerService {

    @Autowired
    private LedgerRepository ledgerRepo;

    public Ledger createEntry(Ledger entry){
        if (entry.getTimeStamp() == null) {
            entry.setTimestamp(System.currentTimeMillis());
        }
        return ledgerRepo.save(entry);
    }

    public Optional<Ledger> getById(Long id){
        return ledgerRepo.findById(id);
    }

    public List<Ledger> getByAccount(Long id){
        return ledgerRepo.findByAccountId(id);
    }

    public List<Ledger> getByTransaction(Long id){
        return ledgerRepo.findByTransactionId(id);
    }
}