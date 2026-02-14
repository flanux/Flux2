package com.ba.loanservice.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.ba.loanservice.model.Loan;
import com.ba.loanservice.service.LoanService;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/loan")
public class LoanController{

    @Autowired
    private LoanService loanService;

    @PostMapping
    public Loan applyForLoan(@RequestBody Loan loan){
        return loanService.applyForLoan(loan);
    }

    @PutMapping("/{id}/approve")
    public Loan approve(@PathVariable Long id){
        return loanService.approveLoan(id);
    }

    @PutMapping("/{id}/reject")
    public Loan reject(@PathVariable Long id){
        return loanService.rejectLoan(id);
    }

    @GetMapping("/{id}")
    public Optional<Loan> getById(@PathVariable Long id){
        return loanService.getLoanById(id);
    }

    @GetMapping("/customer/{customerId}")
    public List<Loan> getByCustomerId(@PathVariable Long customerId){
        return loanService.getByCustomerId(customerId);
    }
}