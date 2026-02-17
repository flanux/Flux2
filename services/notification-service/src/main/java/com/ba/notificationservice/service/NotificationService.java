package com.ba.notificationservice.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.ba.notificationservice.model.Notification;
import com.ba.notificationservice.repository.NotificationRepository;

import java.util.List;
import java.util.Optional;

@Service
public class NotificationService {

    @Autowired
    private NotificationRepository notifRepo;

    public Notification sendNotification(Long id){
        Notification notif = notifRepo.findById(id).orElseThrow(
            ()-> new RuntimeException("notification not found")
        );
        notif.setType(0);
        notif.setStatus(0);
        notif.setMessage("message");
        notif.setTimeStamp(System.currentTimeMillis());
        return notifRepo.save(notif);
    }

    public Notification sendEmail(Long id){
        Notification notif = notifRepo.findById(id).orElseThrow(
            ()-> new RuntimeException("notification not found")
        );
        notif.setType(0);
        notif.setStatus(0);
        notif.setMessage("message");
        notif.setTimeStamp(System.currentTimeMillis());
        return notifRepo.save(notif);
    }

    public Notification sendSMS(Long id){
        Notification notif = notifRepo.findById(id).orElseThrow(
            ()-> new RuntimeException("notification not found")
        );
        notif.setType(1);
        notif.setStatus(0);
        notif.setMessage("message");
        notif.setTimeStamp(System.currentTimeMillis());
        return notifRepo.save(notif);
    }

    public Notification sendPush(Long id){
        Notification notif = notifRepo.findById(id).orElseThrow(
            ()-> new RuntimeException("notification not found")
        );
        notif.setType(2);
        notif.setStatus(0);
        notif.setMessage("message");
        notif.setTimeStamp(System.currentTimeMillis());
        return notifRepo.save(notif);
    }

    public Optional<Notification> getNotificationById(Long id){
        return notifRepo.findById(id);
    }

    public List<Notification> getNotificationByCustomerId(Long customerId){
        return notifRepo.findByCustomerId(customerId);
    }
}