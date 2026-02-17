package com.flanux.gateway.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/gateway")
public class GatewayController {

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "API Gateway");
        response.put("timestamp", LocalDateTime.now().toString());
        response.put("version", "1.0.0");
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/info")
    public ResponseEntity<Map<String, Object>> info() {
        Map<String, Object> response = new HashMap<>();
        response.put("name", "Flanux API Gateway");
        response.put("description", "Central gateway for all microservices");
        response.put("version", "1.0.0");
        response.put("services", Map.of(
            "account-service", "http://localhost:8081",
            "customer-service", "http://localhost:8082",
            "loan-service", "http://localhost:8083",
            "card-service", "http://localhost:8084",
            "transaction-service", "http://localhost:8085",
            "ledger-service", "http://localhost:8086",
            "notification-service", "http://localhost:8087",
            "reporting-service", "http://localhost:8088",
            "auth-service", "http://localhost:9000"
        ));
        
        return ResponseEntity.ok(response);
    }
}
