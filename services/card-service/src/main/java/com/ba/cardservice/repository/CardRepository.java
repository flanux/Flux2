package com.ba.cardservice.repository;
import com.ba.cardservice.model.Card;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface CardRepository extends JpaRepository<Card, Long> {
    List<Card> findByCustomerId(Long customerId);
}
