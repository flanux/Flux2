package com.ba.cardservice.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.ba.cardservice.model.Card;
import com.ba.cardservice.service.CardService;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/card")
public class CardController{

    @Autowired
    private CardService cardService;

    @PostMapping
    public Card issueCard(@RequestBody Card card){
        return cardService.issueCard(card);
    }

    @PutMapping("/{id}/activate")
    public Card activateCard(@PathVariable Long id){
        return cardService.activateCard(id);
    }

    @PutMapping("/{id}/block")
    public Card blockCard(@PathVariable Long id){
        return cardService.blockCard(id);
    }

    @GetMapping("/{id}")
    public Optional<Card> getById(@PathVariable Long id){
        return cardService.getById(id);
    }

    @GetMapping("/customer/{customerId}")
    public List<Card> getByCustomerId(@PathVariable Long customerId){
        return cardService.getCardByCustomer(customerId);
    }

    @GetMapping("/account/{accountId}")
    public List<Card> getByAccountId(@PathVariable Long accountId){
        return cardService.getCardByAccount(accountId);
    }
}
