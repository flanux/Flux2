package com.ba.authservice.dto;

import com.ba.authservice.model.Role;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UserDto {
    private Long id;
    private String username;
    private String email;
    private Role role;
    private Long customerId;
    private Long branchId;
}
