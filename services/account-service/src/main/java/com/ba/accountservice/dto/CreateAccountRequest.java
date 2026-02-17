package com.ba.accountservice.dto;
import com.ba.accountservice.model.Account;
import lombok.*;
@Data @NoArgsConstructor @AllArgsConstructor
public class CreateAccountRequest {
    private Long customerId;
    private Account.AccountType accountType;
    private String currency;
    private Long branchId;
}
