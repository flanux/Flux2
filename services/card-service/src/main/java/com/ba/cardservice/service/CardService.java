package com.ba.cardservice.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.ba.cardservice.model.Card;
import com.ba.cardservice.repository.CardRepository;

import java.util.List;
import java.util.Optional;

@Service
public class CardService{

    @Autowired
    private CardRepository cardRepo;

    public Card issueCard(Card card){
        card.setExpiryDate(0L);
        card.setStatus(0);
        card.setType(0);

        return cardRepo.save(card);
    }

    public Card blockCard(Long id){
        Card card = cardRepo.findById(id).orElseThrow(
            ()-> new RuntimeException("card not found")
        );
        card.setStatus(1);

        return cardRepo.save(card);
    }

    public Card activateCard(Long id){
        Card card = cardRepo.findById(id).orElseThrow(
            ()-> new RuntimeException("card not found")
        );
        card.setStatus(0);

        return cardRepo.save(card);
    }

    public Optional<Card> getById(Long id){
        return cardRepo.findById(id);
    }

    public List<Card> getCardByCustomer(Long customerId){
        return cardRepo.findByCustomerId(customerId);
    }

    public List<Card> getCardByAccount(Long accountId){
        return cardRepo.findByAccountId(accountId);
    }
}