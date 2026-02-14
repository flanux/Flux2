package com.ba.loanservice.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.ba.loanservice.model.Loan;
import com.ba.loanservice.repository.LoanRepository;

import java.util.List;
import java.util.Optional;

@Service
public class LoanService{

    @Autowired
    private LoanRepository loanRepo;

    public Loan applyForLoan(Loan loan){
        loan.setStatus(0);
        loan.setOutstandingAmount(loan.getPrincipleAmount());
        loan.setCreatedAt(System.currentTimeMillis());

        return loanRepo.save(loan);
    }

    public Loan approveLoan(Long id){
        Loan loan = loanRepo.findById(id).orElseThrow(
            ()-> new RuntimeException("loan not found")
        );
        loan.setStatus(1);
        return loanRepo.save(loan);
    }

    public Loan rejectLoan(Long id){
        Loan loan = loanRepo.findById(id).orElseThrow(
            ()-> new RuntimeException("Loan not found")
        );
        loan.setStatus(2);
        return loanRepo.save(loan);
    }

    public Optional<Loan> getLoanById(Long id){
        return loanRepo.findById(id);
    }

    public List<Loan> getByCustomerId(Long id){
        return loanRepo.findByCustomerId(id);
    }

    public Loan updateLoanStatus(Long id, Integer status){
        Loan loan = loanRepo.findById(id).orElseThrow(
            ()-> new RuntimeException("Loan not found")
        );

        loan.setStatus(status);
        return loanRepo.save(loan);
    }

    public Double calculateEMI(Long principal, Float rate, Integer months) {
        double r = rate / (12 * 100.0);
        return (principal * r * Math.pow(1+r, months)) /
               (Math.pow(1+r, months) - 1);
    }
}