package com.ba.customerservice.service;
import com.ba.customerservice.model.Customer;
import com.ba.customerservice.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service @RequiredArgsConstructor
public class CustomerService {
    private final CustomerRepository customerRepository;

    public List<Customer> getAll() { return customerRepository.findAll(); }

    public Customer getById(Long id) {
        return customerRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Customer not found: " + id));
    }

    @Transactional
    public Customer create(Customer customer) {
        return customerRepository.save(customer);
    }

    @Transactional
    public Customer update(Long id, Customer data) {
        Customer c = getById(id);
        if (data.getFirstName() != null) c.setFirstName(data.getFirstName());
        if (data.getLastName() != null) c.setLastName(data.getLastName());
        if (data.getEmail() != null) c.setEmail(data.getEmail());
        if (data.getPhone() != null) c.setPhone(data.getPhone());
        if (data.getAddress() != null) c.setAddress(data.getAddress());
        if (data.getDateOfBirth() != null) c.setDateOfBirth(data.getDateOfBirth());
        if (data.getIdNumber() != null) c.setIdNumber(data.getIdNumber());
        return customerRepository.save(c);
    }

    @Transactional
    public void delete(Long id) { customerRepository.deleteById(id); }

    public List<Customer> search(String q) { return customerRepository.search(q); }
}
