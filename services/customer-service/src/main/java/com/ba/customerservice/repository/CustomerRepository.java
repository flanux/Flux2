package com.ba.customerservice.repository;
import com.ba.customerservice.model.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;
public interface CustomerRepository extends JpaRepository<Customer, Long> {
    Optional<Customer> findByEmail(String email);
    @Query("SELECT c FROM Customer c WHERE LOWER(c.firstName) LIKE LOWER(CONCAT('%',:q,'%')) OR LOWER(c.lastName) LIKE LOWER(CONCAT('%',:q,'%')) OR LOWER(c.email) LIKE LOWER(CONCAT('%',:q,'%'))")
    List<Customer> search(@Param("q") String q);
}
