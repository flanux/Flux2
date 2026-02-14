package com.ba.cardservice.model;

import jakarta.persistence.*;

@Entity
public class Card{

    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long cardId;

    private Long customerId;
    private Long accountId;
    private Long cardNumber;
    private Integer type;
    private Long expiryDate;
    private Integer status;
    
    public Card() {}

    public Card(Long cardId, Long customerId, Long accountId, Long cardNumber, 
        Integer type, Long expiryDate, Integer status
    ){
        this.cardId=cardId;
        this.customerId=customerId;
        this.accountId=accountId;
        this.cardNumber=cardNumber;
        this.type=type;
        this.expiryDate=expiryDate;
        this.status=status;
    }

    public Long getCardId() {return cardId;}
    public void setCardId(Long cardId){this.cardId=cardId;}

    public Long getCustomerId() {return customerId;}
    public void setCustomerId(Long customerId){this.customerId=customerId;}

    public Long getAccountId() {return accountId;}
    public void setAccountId(Long accountId){this.accountId=accountId;}

    public Long getCardNumber() {return cardNumber;}
    public void setCardNumber(Long cardNumber){this.cardNumber=cardNumber;}

    public Integer getType() {return type;}
    public void setType(Integer type){this.type=type;}

    public Long getExpiryDate() {return expiryDate;}
    public void setExpiryDate(Long expiryDate){this.expiryDate=expiryDate;}

    public Integer getStatus() {return status;}
    public void setStatus(Integer status){this.status=status;}
}