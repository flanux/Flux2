package com.ba.accountservice.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;

@Entity
public class Account {
    @Id
    @GeneratedValue (strategy = GenerationType.IDENTITY)
    private Long accountId;

    private Long customerId;
    Integer accountType;
    private Long balance;
    private Integer status;
    private Long createdAt;
    private Long updatedAt;

    public Account() {}

    public Account(Long accountId, Long customerId, Integer accountType, Long balance,
         Integer status, Long createdAt, Long updatedAt){
        this.accountId = accountId;
        this.customerId = customerId;
        this.accountType = accountType;
        this.balance = balance;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public Long getAccountId() {
        return accountId;
    }

    public Long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Long customerId) {
        this.customerId = customerId;
    }

    public Integer getAccountType() {
        return accountType;
    }

    public void setAccountType(Integer accountType) {
        this.accountType= accountType;
    }

    public Long getBalance() {
        return balance;
    }

    public void setBalance(Long balance) {
        this.balance = balance;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public Long getCreateAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }

    public Long getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdateAt(Long updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public String toString() {
        return "Account{" +
                "accountId=" + accountId +
                ", customer=" + customerId +
                ", accountType=" + accountType +
                " balance=" + balance +
                ", status=" + status +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt + 
                '}';
   }
}