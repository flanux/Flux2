package com.ba.accountservice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.ba.accountservice.model.Account;

import java.util.List;

@Repository
public interface AccountRepository extends JpaRepository<Account,   Long> {

    List<Account> findByCustomerId(long customerId);
};