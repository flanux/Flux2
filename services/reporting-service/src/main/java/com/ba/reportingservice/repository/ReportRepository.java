package com.ba.reportingservice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.ba.reportingservice.model.Report;
import java.util.List;

public interface ReportRepository extends JpaRepository<Report, Long> {

   List<Report> findByType(Integer type);
};