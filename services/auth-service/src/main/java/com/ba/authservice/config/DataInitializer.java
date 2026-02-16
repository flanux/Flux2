package com.ba.authservice.config;

import com.ba.authservice.model.Role;
import com.ba.authservice.model.User;
import com.ba.authservice.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

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
        
        createUserIfNotExists("admin", "admin@centralbank.np", encodedPassword, Role.CENTRAL_BANK_ADMIN, null, null);
        createUserIfNotExists("manager.ktm", "manager@branch1.np", encodedPassword, Role.BRANCH_MANAGER, 1L, null);
        createUserIfNotExists("employee.ktm", "employee@branch1.np", encodedPassword, Role.BRANCH_EMPLOYEE, 1L, null);
        createUserIfNotExists("ram.bahadur", "ram@gmail.com", encodedPassword, Role.CUSTOMER, null, 1L);
        
        log.info("Default users initialized. Password for all users: {}", defaultPassword);
    }

    private void createUserIfNotExists(String username, String email, String passwordHash, Role role, Long branchId, Long customerId) {
        if (userRepository.findByUsername(username).isEmpty()) {
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
            log.info("User already exists: {}", username);
        }
    }
}
