package com.ba.notificationservice.model;

import jakarta.persistence.*;

@Entity
public class Notification{

    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long notificationId;

    private Long customerId;
    private String message;
    private Integer type;
    private Integer status;
    private Long timeStamp;

    public Notification() {}

    public Notification(Long notificationId, Long customerId, String message,
        Integer type, Integer status, Long timeStamp
    ){
        this.notificationId = notificationId;
        this.customerId  = customerId;
        this.message = message;
        this.type = type;
        this.status = status;
        this.timeStamp = timeStamp;
    }

    public Long getNotificationId() {return notificationId;}
    public void setNotificationId(Long notificationId){
        this.notificationId = notificationId;
    }

    public Long getCustomerId() {return customerId;}
    public void setCustomerId(Long customerId){
        this.customerId = customerId;
    }

    public String getMessage() {return message;}
    public void setMessage(String message){
        this.message = message;
    }

    public Integer getType() {return type;}
    public void setType(Integer type){
        this.type = type;
    }

    public Integer getStatus() {return status;}
    public void setStatus(Integer status){
        this.status = status;
    }

    public Long getTimeStamp() {return timeStamp;}
    public void setTimeStamp(Long timeStamp){
        this.timeStamp = timeStamp;
    }
}