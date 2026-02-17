package com.ba.accountservice.service;
import com.ba.accountservice.dto.CreateAccountRequest;
import com.ba.accountservice.model.Account;
import com.ba.accountservice.repository.AccountRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.util.List;

@Service @RequiredArgsConstructor
public class AccountService {
    private final AccountRepository accountRepository;

    public List<Account> getByCustomerId(Long customerId) {
        return accountRepository.findByCustomerId(customerId);
    }

    public Account getById(Long id) {
        return accountRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Account not found: " + id));
    }

    public Account getByAccountNumber(String accountNumber) {
        return accountRepository.findByAccountNumber(accountNumber)
            .orElseThrow(() -> new RuntimeException("Account not found: " + accountNumber));
    }

    public List<Account> getAll() {
        return accountRepository.findAll();
    }

    @Transactional
    public Account create(CreateAccountRequest req) {
        Account account = Account.builder()
            .accountNumber(generateAccountNumber())
            .accountType(req.getAccountType() != null ? req.getAccountType() : Account.AccountType.SAVINGS)
            .balance(BigDecimal.ZERO)
            .currency(req.getCurrency() != null ? req.getCurrency() : "NPR")
            .status(Account.AccountStatus.ACTIVE)
            .customerId(req.getCustomerId())
            .branchId(req.getBranchId())
            .build();
        return accountRepository.save(account);
    }

    @Transactional
    public Account close(Long id) {
        Account account = getById(id);
        account.setStatus(Account.AccountStatus.INACTIVE);
        return accountRepository.save(account);
    }

    @Transactional
    public Account updateBalance(Long id, BigDecimal amount) {
        Account account = getById(id);
        account.setBalance(account.getBalance().add(amount));
        return accountRepository.save(account);
    }

    private String generateAccountNumber() {
        return "ACC" + System.currentTimeMillis() + (int)(Math.random() * 1000);
    }
}
