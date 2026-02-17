#!/bin/bash

echo "=========================================="
echo "FLUX2 FIX - Updates existing users with correct password"
echo "=========================================="

# Create DataInitializer that UPDATES existing users
mkdir -p services/auth-service/src/main/java/com/ba/authservice/config

cat > services/auth-service/src/main/java/com/ba/authservice/config/DataInitializer.java << 'JAVAEOF'
package com.ba.authservice.config;

import com.ba.authservice.model.Role;
import com.ba.authservice.model.User;
import com.ba.authservice.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Slf4j
@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder(12);

    @Override
    public void run(String... args) {
        String defaultPassword = "Flux@2026";
        String encodedPassword = passwordEncoder.encode(defaultPassword);
        
        log.info("========================================");
        log.info("BCrypt hash for '{}': {}", defaultPassword, encodedPassword);
        log.info("========================================");
        
        createOrUpdateUser("admin", "admin@centralbank.np", encodedPassword, Role.CENTRAL_BANK_ADMIN, null, null);
        createOrUpdateUser("manager.ktm", "manager@branch1.np", encodedPassword, Role.BRANCH_MANAGER, 1L, null);
        createOrUpdateUser("employee.ktm", "employee@branch1.np", encodedPassword, Role.BRANCH_EMPLOYEE, 1L, null);
        createOrUpdateUser("ram.bahadur", "ram@gmail.com", encodedPassword, Role.CUSTOMER, null, 1L);
        
        log.info("Default users initialized. Password for all users: {}", defaultPassword);
    }

    private void createOrUpdateUser(String username, String email, String passwordHash, Role role, Long branchId, Long customerId) {
        Optional<User> existingUser = userRepository.findByUsername(username);
        
        if (existingUser.isEmpty()) {
            User user = User.builder()
                    .username(username)
                    .email(email)
                    .passwordHash(passwordHash)
                    .role(role)
                    .branchId(branchId)
                    .customerId(customerId)
                    .active(true)
                    .accountLocked(false)
                    .failedLoginAttempts(0)
                    .build();
            userRepository.save(user);
            log.info("Created user: {} with role: {}", username, role);
        } else {
            User user = existingUser.get();
            user.setPasswordHash(passwordHash);
            user.setEmail(email);
            user.setRole(role);
            user.setBranchId(branchId);
            user.setCustomerId(customerId);
            user.setActive(true);
            user.setAccountLocked(false);
            user.setFailedLoginAttempts(0);
            userRepository.save(user);
            log.info("Updated user: {} with correct password", username);
        }
    }
}
JAVAEOF

# Fix application.yml
cat > services/auth-service/src/main/resources/application.yml << 'YMLEOF'
server:
  port: 8080

spring:
  application:
    name: auth-service
    
  datasource:
    url: ${SPRING_DATASOURCE_URL:jdbc:postgresql://database:5432/auth_db}
    username: ${SPRING_DATASOURCE_USERNAME:auth_user}
    password: ${SPRING_DATASOURCE_PASSWORD:auth_pass_2024}
    driver-class-name: org.postgresql.Driver
    
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        
  kafka:
    bootstrap-servers: ${SPRING_KAFKA_BOOTSTRAP_SERVERS:kafka:29092}
      
  data:
    redis:
      host: ${SPRING_REDIS_HOST:redis}
      port: ${SPRING_REDIS_PORT:6379}

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics

jwt:
  secret-key: ${JWT_SECRET:FLUX_BANKING_SECRET_KEY_CHANGE_IN_PRODUCTION}
  access-token-expiry: 28800
  refresh-token-expiry: 604800
  issuer: flux-banking-system

security:
  max-failed-attempts: 5
  lockout-duration: 1800
YMLEOF

echo ""
echo "=========================================="
echo "FIX APPLIED! Now run:"
echo "=========================================="
echo ""
echo "  docker-compose build auth-service"
echo "  docker-compose up -d auth-service"
echo "  docker-compose logs -f auth-service"
echo ""
echo "You should see: 'Updated user: admin with correct password'"
echo ""
echo "Then test login: admin / Flux@2026"
echo ""