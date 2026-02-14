package com.ba.customerservice.model;

import jakarta.persistence.*;

@Entity
public class Customer{

    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long customerId;

    private String name;
    private Long DOB;
    private String email;
    private String address;
    private Integer status;
    private Long createdAt;

    public Customer() {}

    public Customer(Long customerId, String name, Long DOB, String email, String address,
        Integer status, Long createdAt
    ) {
        this.customerId = customerId;
        this.name = name;
        this.DOB = DOB;
        this.email = email;
        this.address = address;
        this.status = status;
        this.createdAt = createdAt;
    }

    public Long getCustomerId() {return customerId;}
    public void setCustomerId(Long id){this.customerId=id;}

    public Long getDOB() {return DOB;}
    public void setDOB(Long DOB){this.DOB=DOB;}

    public String getEmail() {return email;}
    public void setEmail(String email){this.email=email;}

    public String getAddress() {return address;}
    public void setAddress(String address){this.address=address;}

    public Integer getStatus() {return status;}
    public void setStatus(Integer status){this.status=status;}

    public Long getCreatedAt() {return createdAt;}
    public void setCreatedAt(Long createdAt){this.createdAt=createdAt;}
}