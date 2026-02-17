package com.ba.accountservice.controller;
import com.ba.accountservice.dto.*;
import com.ba.accountservice.model.Account;
import com.ba.accountservice.service.AccountService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/accounts")
public class AccountController {
    private final AccountService accountService;

    @GetMapping("/my")
    public ResponseEntity<ApiResponse<List<Account>>> getMyAccounts(
            @RequestHeader(value = "X-User-Id", required = false) String userId) {
        if (userId == null || userId.isEmpty()) {
            return ResponseEntity.status(401).body(ApiResponse.error("Unauthorized"));
        }
        Long customerId = Long.parseLong(userId);
        return ResponseEntity.ok(ApiResponse.ok(accountService.getByCustomerId(customerId)));
    }

    @GetMapping("/my/{id}")
    public ResponseEntity<ApiResponse<Account>> getMyAccount(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(accountService.getById(id)));
    }

    @GetMapping
    public ResponseEntity<List<Account>> getAll() {
        return ResponseEntity.ok(accountService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Account> getById(@PathVariable Long id) {
        return ResponseEntity.ok(accountService.getById(id));
    }

    @GetMapping("/customer/{customerId}")
    public ResponseEntity<List<Account>> getByCustomer(@PathVariable Long customerId) {
        return ResponseEntity.ok(accountService.getByCustomerId(customerId));
    }

    @GetMapping("/number/{accountNumber}")
    public ResponseEntity<Account> getByNumber(@PathVariable String accountNumber) {
        return ResponseEntity.ok(accountService.getByAccountNumber(accountNumber));
    }

    @PostMapping
    public ResponseEntity<Account> create(@RequestBody CreateAccountRequest req) {
        return ResponseEntity.ok(accountService.create(req));
    }

    @PutMapping("/{id}/close")
    public ResponseEntity<Account> close(@PathVariable Long id) {
        return ResponseEntity.ok(accountService.close(id));
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Account service is running!");
    }
}
