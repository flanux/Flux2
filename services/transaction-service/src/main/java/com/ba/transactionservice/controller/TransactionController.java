package com.ba.transactionservice.controller;
import com.ba.transactionservice.dto.*;
import com.ba.transactionservice.model.Transaction;
import com.ba.transactionservice.service.TransactionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class TransactionController {
    private final TransactionService transactionService;

    // Customer portal - get my transactions for an account
    @GetMapping("/transactions/my/{accountId}")
    public ResponseEntity<ApiResponse<List<Transaction>>> getMyTransactions(@PathVariable Long accountId) {
        return ResponseEntity.ok(ApiResponse.ok(transactionService.getByAccountId(accountId)));
    }

    // Transfer - customer portal
    @PostMapping("/transfers/external")
    public ResponseEntity<ApiResponse<Transaction>> transfer(@RequestBody TransferRequest req) {
        return ResponseEntity.ok(ApiResponse.ok(transactionService.transfer(req)));
    }

    // Branch dashboard endpoints
    @GetMapping("/transactions")
    public ResponseEntity<List<Transaction>> getAll() {
        return ResponseEntity.ok(transactionService.getAll());
    }

    @GetMapping("/transactions/{id}")
    public ResponseEntity<Transaction> getById(@PathVariable Long id) {
        return ResponseEntity.ok(transactionService.getById(id));
    }

    @GetMapping("/transactions/account/{accountNumber}")
    public ResponseEntity<List<Transaction>> getByAccount(@PathVariable String accountNumber) {
        return ResponseEntity.ok(transactionService.getByAccountNumber(accountNumber));
    }

    @PostMapping("/transactions/deposit")
    public ResponseEntity<Transaction> deposit(@RequestBody Map<String, Object> body) {
        Long accountId = Long.parseLong(body.get("accountId").toString());
        BigDecimal amount = new BigDecimal(body.get("amount").toString());
        String desc = body.containsKey("description") ? body.get("description").toString() : "Deposit";
        return ResponseEntity.ok(transactionService.deposit(accountId, amount, desc));
    }

    @PostMapping("/transactions/withdrawal")
    public ResponseEntity<Transaction> withdrawal(@RequestBody Map<String, Object> body) {
        Long accountId = Long.parseLong(body.get("accountId").toString());
        BigDecimal amount = new BigDecimal(body.get("amount").toString());
        String desc = body.containsKey("description") ? body.get("description").toString() : "Withdrawal";
        return ResponseEntity.ok(transactionService.withdrawal(accountId, amount, desc));
    }

    @PostMapping("/transactions/transfer")
    public ResponseEntity<Transaction> branchTransfer(@RequestBody TransferRequest req) {
        return ResponseEntity.ok(transactionService.transfer(req));
    }

    @GetMapping("/transactions/today")
    public ResponseEntity<List<Transaction>> getToday() {
        return ResponseEntity.ok(transactionService.getToday());
    }

    @GetMapping("/transactions/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Transaction service is running!");
    }
}
