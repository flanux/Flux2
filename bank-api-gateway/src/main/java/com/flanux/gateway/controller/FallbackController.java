package com.flanux.gateway.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/fallback")
public class FallbackController {

    @GetMapping("/account-service")
    public ResponseEntity<Map<String, Object>> accountServiceFallback() {
        return createFallbackResponse("Account Service");
    }

    @GetMapping("/customer-service")
    public ResponseEntity<Map<String, Object>> customerServiceFallback() {
        return createFallbackResponse("Customer Service");
    }

    @GetMapping("/loan-service")
    public ResponseEntity<Map<String, Object>> loanServiceFallback() {
        return createFallbackResponse("Loan Service");
    }

    @GetMapping("/card-service")
    public ResponseEntity<Map<String, Object>> cardServiceFallback() {
        return createFallbackResponse("Card Service");
    }

    @GetMapping("/transaction-service")
    public ResponseEntity<Map<String, Object>> transactionServiceFallback() {
        return createFallbackResponse("Transaction Service");
    }

    @GetMapping("/ledger-service")
    public ResponseEntity<Map<String, Object>> ledgerServiceFallback() {
        return createFallbackResponse("Ledger Service");
    }

    @GetMapping("/notification-service")
    public ResponseEntity<Map<String, Object>> notificationServiceFallback() {
        return createFallbackResponse("Notification Service");
    }

    @GetMapping("/reporting-service")
    public ResponseEntity<Map<String, Object>> reportingServiceFallback() {
        return createFallbackResponse("Reporting Service");
    }

    private ResponseEntity<Map<String, Object>> createFallbackResponse(String serviceName) {
        Map<String, Object> response = new HashMap<>();
        response.put("error", serviceName + " is currently unavailable");
        response.put("message", "Please try again later. Our team has been notified.");
        response.put("timestamp", LocalDateTime.now().toString());
        response.put("status", HttpStatus.SERVICE_UNAVAILABLE.value());
        
        return ResponseEntity
                .status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(response);
    }
}
