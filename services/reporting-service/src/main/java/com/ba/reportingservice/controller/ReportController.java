package com.ba.reportingservice.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

import com.ba.reportingservice.model.Report;
import com.ba.reportingservice.service.ReportService;

@RestController
@RequestMapping("/report")
public class ReportController{

    @Autowired
    private ReportService reportService;

    @GetMapping("/{id}")
    public Report getReportById(@PathVariable Long id){
        return reportService.getReportById(id);
    }

    @GetMapping("/type/{type}")
    public List<Report> getReportByType(@PathVariable Integer type){
        return reportService.getReportsByType(type);
    }

    @PostMapping("/generate/{id}")
    public Report generaReport(@PathVariable Long id){
        return reportService.generateReport(id);
    }

    @PostMapping("/export/{id}")
    public Report exportReport(@PathVariable Long id){
        return reportService.exportReport(id);
    }
}