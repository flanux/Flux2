package com.ba.customerservice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.ba.customerservice.model.Customer;
import java.util.List;

public interface CustomerRepository extends JpaRepository<Customer,    Long> {
    public List<Customer> findByCustomerId(Long customerId);
    public List<Customer> findByEmail(String email);
};