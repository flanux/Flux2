package com.ba.cardservice.controller;
import com.ba.cardservice.dto.ApiResponse;
import com.ba.cardservice.model.Card;
import com.ba.cardservice.service.CardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/cards")
public class CardController {
    private final CardService cardService;

    @GetMapping("/my")
    public ResponseEntity<ApiResponse<List<Card>>> getMyCards(
            @RequestHeader(value = "X-User-Id", required = false) String userId) {
        if (userId == null || userId.isEmpty()) {
            return ResponseEntity.status(401).body(ApiResponse.error("Unauthorized"));
        }
        return ResponseEntity.ok(ApiResponse.ok(cardService.getByCustomerId(Long.parseLong(userId))));
    }

    @PostMapping("/{id}/block")
    public ResponseEntity<ApiResponse<Card>> block(
            @PathVariable Long id,
            @RequestBody Map<String, String> body) {
        String reason = body.getOrDefault("reason", "Customer requested");
        return ResponseEntity.ok(ApiResponse.ok(cardService.block(id, reason)));
    }

    @GetMapping
    public ResponseEntity<List<Card>> getAll() {
        return ResponseEntity.ok(cardService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Card> getById(@PathVariable Long id) {
        return ResponseEntity.ok(cardService.getById(id));
    }

    @GetMapping("/customer/{customerId}")
    public ResponseEntity<List<Card>> getByCustomer(@PathVariable Long customerId) {
        return ResponseEntity.ok(cardService.getByCustomerId(customerId));
    }

    @PostMapping("/issue")
    public ResponseEntity<Card> issue(@RequestBody Map<String, Object> body) {
        Long customerId = Long.parseLong(body.get("customerId").toString());
        Long accountId = Long.parseLong(body.get("accountId").toString());
        Card.CardType cardType = Card.CardType.valueOf(body.getOrDefault("cardType", "DEBIT").toString());
        return ResponseEntity.ok(cardService.issue(customerId, accountId, cardType));
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Card service is running!");
    }
}
