package com.ba.reportingservice.service;

import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import java.util.List;

import com.ba.reportingservice.model.Report;
import com.ba.reportingservice.repository.ReportRepository;

@Service
public class ReportService{

    @Autowired
    private ReportRepository reportRepo;

    public Report generateReport(Long reportId){
        Report report = reportRepo.findById(reportId).orElseThrow(
            ()-> new RuntimeException("report not found")
        );

        report.setStatus(0);
        report.setType(0);
        report.setData(null);

        return reportRepo.save(report);
    }

    public Report exportReport(Long reportId){
        Report report = getReportById(reportId);
    }

    public Report getReportById(Long reportId){
        return reportRepo.findById(reportId).orElseThrow(
            ()-> new RuntimeException("report not found")
        );
    }

    public List<Report> getReportsByType(Integer type){
       return reportRepo.findByType(type);
    }
}