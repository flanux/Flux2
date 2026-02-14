package com.ba.customerservice.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.ba.customerservice.model.Customer;
import com.ba.customerservice.repository.CustomerRepository;

import java.util.List;
import java.util.Optional;

@Service
public class CustomerService{

    @Autowired
    private CustomerRepository customerRepo;

    public Customer createCustomer(Customer customer){
        customer.setStatus(0);
        customer.setCreatedAt(System.currentTimeMillis());

        return customerRepo.save(customer);
    }

    public Customer updateCustomer(Long id, Integer status){
        Customer customer = customerRepo.findById(id)
            .orElseThrow(()-> new RuntimeException("customer not found"));

        customer.setStatus(status);
        return customerRepo.save(customer);
    }

    public Customer deactivateCustomer(Long id){
        Customer customer = customerRepo.findById(id)
            .orElseThrow(()->new RuntimeException("customer not found"));

        customer.setStatus(1);// or updateCustomer(id, status) ??
        return customerRepo.save(customer);
    }

    public Optional<Customer> getById(Long id){
        return customerRepo.findById(id);
    }

    public List<Customer> getByCustomerId(Long id){
        return customerRepo.findByCustomerId(id);
    }

    public List<Customer> getByCustomerEmail(String email){
        return customerRepo.findByEmail(email);
    }
}