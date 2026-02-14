package com.ba.loanservice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.ba.loanservice.model.Loan;
import java.util.List;

public interface LoanRepository extends JpaRepository<Loan,   Long> {
    
    List<Loan> findByCustomerId(Long customerId);
};