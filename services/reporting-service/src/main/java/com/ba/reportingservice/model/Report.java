package com.ba.reportingservice.model;

import jakarta.persistence.*;

@Entity
public class Report{

    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long reportId;

    private Integer type;
    private Long generatedAt;
    private Integer status;
    private String data;

    public Report() {}

    public Report(Long reportId, Integer type, Long generatedAt, Integer status, String data){
        this.reportId=reportId;
        this.type=type;
        this.generatedAt=generatedAt;
        this.status=status;
        this.data=data;
    }

    public Long getReportId() {return reportId;}
    public void setReportId(Long reportId){this.reportId=reportId;}

    public Integer getType() {return type;}
    public void setType(Integer type){this.type=type;}

    public Long getGeneratedAt() {return generatedAt;}
    public void setGeneratedAt(Long generatedAt){this.generatedAt=generatedAt;}

    public Integer getStatus() {return status;}
    public void setStatus(Integer status){this.status=status;}

    public String getData() {return data;}
    public void setData(String data){this.data=data;}
}