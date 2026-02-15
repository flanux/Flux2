package com.ba.authservice.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String username;
    
    @Column(unique = true, nullable = false)
    private String email;
    
    @Column(name = "password_hash", nullable = false)
    private String passwordHash;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;
    
    @Column(name = "customer_id")
    private Long customerId;
    
    @Column(name = "branch_id")
    private Long branchId;
    
    @Column(name = "account_locked")
    @Builder.Default
    private Boolean accountLocked = false;
    
    @Column(name = "failed_login_attempts")
    @Builder.Default
    private Integer failedLoginAttempts = 0;
    
    @Column(name = "last_login_at")
    private LocalDateTime lastLoginAt;
    
    @Column(name = "locked_until")
    private LocalDateTime lockedUntil;
    
    @Column(nullable = false)
    @Builder.Default
    private Boolean active = true;
    
    @CreationTimestamp
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    public boolean isLocked() {
        if (!accountLocked) return false;
        if (lockedUntil != null && LocalDateTime.now().isAfter(lockedUntil)) {
            accountLocked = false;
            lockedUntil = null;
            return false;
        }
        return true;
    }
    
    public void recordFailedLogin() {
        this.failedLoginAttempts++;
    }
    
    public void recordSuccessfulLogin() {
        this.failedLoginAttempts = 0;
        this.lastLoginAt = LocalDateTime.now();
    }
    
    public void lockAccount(int durationSeconds) {
        this.accountLocked = true;
        this.lockedUntil = LocalDateTime.now().plusSeconds(durationSeconds);
    }
}
