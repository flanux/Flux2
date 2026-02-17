package com.ba.loanservice.controller;
import com.ba.loanservice.dto.ApiResponse;
import com.ba.loanservice.model.Loan;
import com.ba.loanservice.service.LoanService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/loans")
public class LoanController {
    private final LoanService loanService;

    @GetMapping("/my")
    public ResponseEntity<ApiResponse<List<Loan>>> getMyLoans(
            @RequestHeader(value = "X-User-Id", required = false) String userId) {
        if (userId == null || userId.isEmpty()) {
            return ResponseEntity.status(401).body(ApiResponse.error("Unauthorized"));
        }
        return ResponseEntity.ok(ApiResponse.ok(loanService.getByCustomerId(Long.parseLong(userId))));
    }

    @PostMapping("/apply")
    public ResponseEntity<ApiResponse<Loan>> apply(
            @RequestBody Map<String, Object> data,
            @RequestHeader(value = "X-User-Id", required = false) String userId) {
        Long customerId = userId != null ? Long.parseLong(userId) : Long.parseLong(data.getOrDefault("customerId", "1").toString());
        return ResponseEntity.ok(ApiResponse.ok(loanService.apply(data, customerId)));
    }

    @PostMapping("/{id}/payment")
    public ResponseEntity<ApiResponse<Loan>> makePayment(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body) {
        BigDecimal amount = new BigDecimal(body.get("amount").toString());
        return ResponseEntity.ok(ApiResponse.ok(loanService.makePayment(id, amount)));
    }

    @GetMapping
    public ResponseEntity<List<Loan>> getAll() {
        return ResponseEntity.ok(loanService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Loan> getById(@PathVariable Long id) {
        return ResponseEntity.ok(loanService.getById(id));
    }

    @GetMapping("/customer/{customerId}")
    public ResponseEntity<List<Loan>> getByCustomer(@PathVariable Long customerId) {
        return ResponseEntity.ok(loanService.getByCustomerId(customerId));
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Loan service is running!");
    }
}
