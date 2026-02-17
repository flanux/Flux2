package com.ba.notificationservice.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.ba.notificationservice.model.Notification;
import com.ba.notificationservice.service.NotificationService;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/notification")
public class NotificationController{

    @Autowired
    private NotificationService notifService;

    @PostMapping("/notification/send")
    public Notification sendNotification(@PathVariable Long id){
        return notifService.sendNotification(id);
    }

    @PostMapping("/notification/email")
    public Notification sendEmail(@PathVariable Long id){
        return notifService.sendEmail(id);
    }

    @PostMapping("/notification/sms")
    public Notification sendSMS(@PathVariable long id){
        return notifService.sendSMS(id);
    }

    @PostMapping("/notification/push")
    public Notification sendPush(@PathVariable long id){
        return notifService.sendPush(id);
    }

    @GetMapping("/{id}")
    public Optional<Notification> getById(@PathVariable Long id){
        return notifService.getNotificationById(id);
    }

    @GetMapping("/customer/{customerId}")
    public List<Notification> getByCustomer(@PathVariable Long customerId){
        return notifService.getNotificationByCustomerId(customerId);
    }
}