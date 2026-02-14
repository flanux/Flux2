package com.ba.ledgerservice.model;

import jakarta.persistence.*;

@Entity
public class Ledger {
        
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long ledgerEntryId;

    private Long transactionId;
    private Long accountId;
    private Long debit;
    private Long credit;
    private Long timeStamp;

    public Ledger() {}

    public Ledger(Long ledgerEntryId, Long transactionId, Long accountId,
            Long debit, Long credit, Long timeStamp) {
        this.ledgerEntryId = ledgerEntryId;
        this.transactionId = transactionId;
        this.accountId = accountId;
        this.debit = debit;
        this.credit = credit;
        this.timeStamp = timeStamp;
    }

    public Long getLedgerEntryId() {return ledgerEntryId;}
    public void setLedgerEntryId(Long id){this.ledgerEntryId=id;}

    public Long getTransactionId() {return transactionId;}
    public void setTransactionId(Long id){this.transactionId=id;}

    public Long getAccountId() {return accountId;}
    public void setAccountId(Long id) {this.accountId=id;}

    public Long getDebit() {return debit;}
    public void setDebit(Long debit) {this.debit=debit;}

    public Long getCredit() {return credit;}
    public void setCredit(Long credit) {this.credit=credit;}

    public Long getTimeStamp() {return timeStamp;}
    public void setTimestamp(Long timeStamp) {this.timeStamp=timeStamp;}
}