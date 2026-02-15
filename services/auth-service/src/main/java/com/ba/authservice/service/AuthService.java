package com.ba.authservice.service;

import com.ba.authservice.dto.*;
import com.ba.authservice.model.*;
import com.ba.authservice.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AuthService {
    
    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final JwtService jwtService;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder(12);
    
    @Value("${jwt.refresh-token-expiry}")
    private Long refreshTokenExpiry;
    
    @Value("${security.max-failed-attempts}")
    private Integer maxFailedAttempts;
    
    @Value("${security.lockout-duration}")
    private Integer lockoutDuration;
    
    @Transactional
    public LoginResponse login(LoginRequest request) {
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new RuntimeException("Invalid credentials"));
        
        if (user.isLocked()) {
            throw new RuntimeException("Account is locked. Please try again later.");
        }
        
        if (!user.getActive()) {
            throw new RuntimeException("Account is inactive");
        }
        
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            user.recordFailedLogin();
            
            if (user.getFailedLoginAttempts() >= maxFailedAttempts) {
                user.lockAccount(lockoutDuration);
            }
            
            userRepository.save(user);
            throw new RuntimeException("Invalid credentials");
        }
        
        user.recordSuccessfulLogin();
        userRepository.save(user);
        
        String accessToken = jwtService.generateAccessToken(user);
        String refreshTokenString = jwtService.generateRefreshToken();
        
        RefreshToken refreshToken = RefreshToken.builder()
                .user(user)
                .token(refreshTokenString)
                .expiresAt(LocalDateTime.now().plusSeconds(refreshTokenExpiry))
                .createdAt(LocalDateTime.now())
                .build();
        
        refreshTokenRepository.save(refreshToken);
        
        return LoginResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshTokenString)
                .tokenType("Bearer")
                .expiresIn(28800L)
                .user(UserDto.builder()
                        .id(user.getId())
                        .username(user.getUsername())
                        .email(user.getEmail())
                        .role(user.getRole())
                        .customerId(user.getCustomerId())
                        .branchId(user.getBranchId())
                        .build())
                .build();
    }
    
    @Transactional
    public void logout(Long userId) {
        refreshTokenRepository.revokeAllUserTokens(userId);
    }
    
    public UserDto getCurrentUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        return UserDto.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .role(user.getRole())
                .customerId(user.getCustomerId())
                .branchId(user.getBranchId())
                .build();
    }
}
