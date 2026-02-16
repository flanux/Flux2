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
