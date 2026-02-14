package com.ba.transactionservice.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;


@Entity
public class Transaction{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long transactionId;

    private Long accountId;
    private Long amount;
    private Integer type;
    private Long timeStamp;
    private Integer status;

    public Transaction() {}

    public Transaction(Long transactionId, Long accountId, Long amount,
             Integer type, Long timeStamp, Integer status){
                this.transactionId = transactionId;
                this.accountId = accountId;
                this.amount = amount;
                this.type = type;
                this.timeStamp = timeStamp;
                this.status = status;
    }

    public Long getTransactionId() { return transactionId;}
    public void setTransactionId(Long transactionId) {this.transactionId = transactionId;}

    public Long getAccountId() {return accountId;}
    public void setAccountId(Long accountId) {this.accountId= accountId;}

    public Long getAmount() {return amount;}
    public void setAmount(Long amount) {this.amount=amount;}

    public Integer getType() { return type;}
    public void setType(Integer type) {this.type=type;}

    public Long getTimeStamp() { return timeStamp;}
    public void setTimeStamp(Long timeStamp) {this.timeStamp=timeStamp;}

    public Integer getStatus() {return status;}
    public void setStatus(Integer status) {this.status=status;}

      @Override
    public String toString() {
        return "Transaction{" +
                "transactionId=" + transactionId +
                ", accountId=" + accountId +
                ", amount=" + amount +
                ", type=" + type +
                ", timeStamp=" + timeStamp +
                ", status=" + status +
                '}';
    }
}