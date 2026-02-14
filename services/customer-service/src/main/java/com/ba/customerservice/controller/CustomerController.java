package com.ba.customerservice.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.ba.customerservice.model.Customer;
import com.ba.customerservice.service.CustomerService;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/customer")
public class CustomerController{

    @Autowired
    private CustomerService customerService;

    @PostMapping
    public Customer createCustomer(@RequestBody Customer customer){
        return customerService.createCustomer(customer);
    }

    @PutMapping("/{id}/status")
    public Customer updateCustomer(@PathVariable Long id, @PathVariable Integer status){
        return customerService.updateCustomer(id, status);
    }

    @PutMapping("/{id}/deactivate")
    public Customer deactivateCustomer(@PathVariable Long id){
        return customerService.deactivateCustomer(id);
    }

    @GetMapping("/{id}")
    public Optional<Customer> getById(@PathVariable Long id){
        return customerService.getById(id);
    }

    @GetMapping("id/{customerId}")
    public List<Customer> getByCusomterId(@PathVariable Long customerId){
        return customerService.getByCustomerId(customerId);
    }

    @GetMapping("email/{email}")
    public List<Customer> getByCustomerEmail(@PathVariable String email){
        return customerService.getByCustomerEmail(email);
    }
}