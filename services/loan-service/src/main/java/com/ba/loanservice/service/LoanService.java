package com.ba.loanservice.service;
import com.ba.loanservice.model.Loan;
import com.ba.loanservice.repository.LoanRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Service @RequiredArgsConstructor
public class LoanService {
    private final LoanRepository loanRepository;

    public List<Loan> getByCustomerId(Long customerId) {
        return loanRepository.findByCustomerId(customerId);
    }

    public List<Loan> getAll() { return loanRepository.findAll(); }

    public Loan getById(Long id) {
        return loanRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Loan not found: " + id));
    }

    @Transactional
    public Loan apply(Map<String, Object> data, Long customerId) {
        BigDecimal principal = new BigDecimal(data.get("principalAmount").toString());
        BigDecimal rate = new BigDecimal(data.getOrDefault("interestRate", "12.0").toString());
        int terms = Integer.parseInt(data.getOrDefault("termMonths", "12").toString());
        Loan.LoanType type = Loan.LoanType.valueOf(data.getOrDefault("loanType", "PERSONAL").toString());

        // Calculate monthly payment: P * r * (1+r)^n / ((1+r)^n - 1)
        BigDecimal monthlyRate = rate.divide(BigDecimal.valueOf(1200), 10, RoundingMode.HALF_UP);
        BigDecimal factor = monthlyRate.add(BigDecimal.ONE).pow(terms);
        BigDecimal monthly = principal.multiply(monthlyRate).multiply(factor)
            .divide(factor.subtract(BigDecimal.ONE), 2, RoundingMode.HALF_UP);

        Loan loan = Loan.builder()
            .loanType(type)
            .principalAmount(principal)
            .outstandingBalance(principal)
            .interestRate(rate)
            .monthlyPayment(monthly)
            .nextPaymentDate(LocalDate.now().plusMonths(1))
            .loanStatus(Loan.LoanStatus.ACTIVE)
            .customerId(customerId)
            .termMonths(terms)
            .build();
        return loanRepository.save(loan);
    }

    @Transactional
    public Loan makePayment(Long id, BigDecimal amount) {
        Loan loan = getById(id);
        loan.setOutstandingBalance(loan.getOutstandingBalance().subtract(amount));
        if (loan.getOutstandingBalance().compareTo(BigDecimal.ZERO) <= 0) {
            loan.setOutstandingBalance(BigDecimal.ZERO);
            loan.setLoanStatus(Loan.LoanStatus.PAID_OFF);
        } else {
            loan.setNextPaymentDate(loan.getNextPaymentDate().plusMonths(1));
        }
        return loanRepository.save(loan);
    }
}
