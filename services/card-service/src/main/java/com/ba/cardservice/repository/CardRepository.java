package com.ba.cardservice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.ba.cardservice.model.Card;
import java.util.List;

public interface CardRepository extends JpaRepository<Card,    Long> {

   List<Card> findByCustomerId(Long customerId);
   List<Card> findByAccountId(Long accountId);
};