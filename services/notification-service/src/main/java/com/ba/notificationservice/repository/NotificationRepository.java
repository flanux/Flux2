package com.ba.notificationservice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.ba.notificationservice.model.Notification;
import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification,   Long> {
    List<Notification> findByCustomerId(Long customerId);
};