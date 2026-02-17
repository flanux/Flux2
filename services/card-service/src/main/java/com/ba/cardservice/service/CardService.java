package com.ba.cardservice.service;
import com.ba.cardservice.model.Card;
import com.ba.cardservice.repository.CardRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDate;
import java.util.List;

@Service @RequiredArgsConstructor
public class CardService {
    private final CardRepository cardRepository;

    public List<Card> getByCustomerId(Long customerId) {
        return cardRepository.findByCustomerId(customerId);
    }

    public List<Card> getAll() { return cardRepository.findAll(); }

    public Card getById(Long id) {
        return cardRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Card not found: " + id));
    }

    @Transactional
    public Card block(Long id, String reason) {
        Card card = getById(id);
        card.setStatus(Card.CardStatus.BLOCKED);
        card.setBlockReason(reason);
        return cardRepository.save(card);
    }

    @Transactional
    public Card issue(Long customerId, Long accountId, Card.CardType cardType) {
        String last4 = String.format("%04d", (int)(Math.random() * 10000));
        LocalDate expiry = LocalDate.now().plusYears(3);
        Card card = Card.builder()
            .lastFourDigits(last4)
            .cardType(cardType)
            .expiryDate(expiry.getMonthValue() + "/" + (expiry.getYear() % 100))
            .status(Card.CardStatus.ACTIVE)
            .customerId(customerId)
            .accountId(accountId)
            .build();
        return cardRepository.save(card);
    }
}
