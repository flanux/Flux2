package com.ba.accountservice.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.ba.accountservice.model.Account;
import com.ba.accountservice.service.AccountService;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/accounts")
public class AccountController {

    @Autowired
    private AccountService accountService;

    @PostMapping
    public Account createAccount(@RequestBody Account account){
        return accountService.createAccount(account);
    }

    @GetMapping("/{id}")
    public Optional<Account> getAccountById(@PathVariable long id){
        return accountService.getAccountById(id);
    }

    @GetMapping("/customer/{customerId}")
    public List<Account> getAccountByCustomer(@PathVariable long customerId) {
        return accountService.getAccountByCustomer(customerId);
    }

    @PutMapping("/{id}/balance")
    public Account updateBalance(
        @PathVariable long id,
        @RequestParam long value
    ){
        return accountService.updateBalance(id, value);
    }

    @PutMapping("/{id}/status")
    public Account updateStatus(
        @PathVariable long id,
        @RequestParam int value
    ){
        return accountService.UpdateStatus(id, value);
    }
}