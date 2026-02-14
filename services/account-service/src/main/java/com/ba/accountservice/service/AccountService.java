package com.ba.accountservice.service;

import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import com.ba.accountservice.repository.AccountRepository;
import com.ba.accountservice.model.Account;

import java.util.List;
import java.util.Optional;

@Service
public class AccountService {

    @Autowired
    private AccountRepository accountRepository;

    public Account createAccount(Account account){
        account.setStatus(1);
        account.setCreatedAt(System.currentTimeMillis());
        account.setUpdateAt(System.currentTimeMillis());
        return accountRepository.save(account);
    }

    public Optional<Account> getAccountById(long accountId) {
        return  accountRepository.findById(accountId);
    }

    public List<Account> getAccountByCustomer(long customerId) {
        return accountRepository.findByCustomerId(customerId);
    }

    public Account updateBalance(long accountId, long newBalance) {
        Account acc = accountRepository.findById(accountId)
                .orElseThrow(()-> new RuntimeException("Account not found"));
        
        acc.setBalance(newBalance);
        acc.setUpdateAt(System.currentTimeMillis());

        return accountRepository.save(acc);
    }

    public Account UpdateStatus(long accountId, int status){
        Account acc = accountRepository.findById(accountId)
            .orElseThrow(() -> new RuntimeException("Account not found"));

        acc.setStatus(status);
        acc.setUpdateAt(System.currentTimeMillis());

        return accountRepository.save(acc);
    }
}