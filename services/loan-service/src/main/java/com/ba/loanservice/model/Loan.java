package com.ba.loanservice.model;

import jakarta.persistence.*;

@Entity
public class Loan{

    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long loanId;

    private Long customerId;
    private Integer loanType;
    private Long principalAmount;
    private Float interestRate;
    private Integer tenureMonths;
    private Long outstandingAmount;
    private Integer status;
    private Long createdAt;

    public Loan() {}

    public Loan(Long loanId, Long customerId, Integer loanType,
        Long principalAmount, Float interestRate, Integer tenureMonths,
        Long outstandingAmount, Integer status, Long createdAt
    ) {
        this.loanId = loanId;
        this.customerId = customerId;
        this.loanType = loanType;
        this.principalAmount = principalAmount;
        this.interestRate = interestRate;
        this.tenureMonths = tenureMonths;
        this.outstandingAmount = outstandingAmount;
        this.status = status;
        this.createdAt = createdAt;
    }

    public Long getLoanId() { return loanId; }
    public void setLoanId(Long id) {this.loanId=id;}

    public Long getCustomerId() { return customerId;}
    public void setCustomerId(Long id) {this.customerId=id;}

    public Integer getLoanType() {return loanType;}
    public void setLoanType(Integer loanType){this.loanType=loanType;}

    public Long getPrincipleAmount() {return principalAmount;}
    public void setPrincipleAmount(Long principalAmount){
        this.principalAmount=principalAmount;
    }

    public Float getInterestRate() {return interestRate;}
    public void setInterestRate(Float interestRate){
        this.interestRate=interestRate;
    }

    public Integer getTenureMonths() {return tenureMonths;}
    public void setTneureMonths(Integer tenureMonths){
        this.tenureMonths=tenureMonths;
    }

    public Long getOutstandingAmount() {return outstandingAmount;}
    public void setOutstandingAmount(Long outstandingAmount){
        this.outstandingAmount=outstandingAmount;
    }

    public Integer getStatus() {return status;}
    public void setStatus(Integer status){this.status=status;}

    public Long getCreatedAt() {return createdAt;}
    public void setCreatedAt(Long createdAt){this.createdAt=createdAt;}
}
