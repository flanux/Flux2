package com.flanux.kyc.service;

import com.flanux.kyc.entity.KycRecord;
import com.flanux.kyc.repository.KycRecordRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * KYC Service - Know Your Customer verification
 * Handles identity verification, PEP checks, sanctions screening
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class KycService {

    private the KycRecordRepository kycRepository;
    private final DocumentService documentService;
    private final PepCheckService pepCheckService;
    private final SanctionsCheckService sanctionsCheckService;
    private final AdverseMediaService adverseMediaService;
    private final RiskScoringService riskScoringService;
    private final KafkaTemplate<String, Object> kafkaTemplate;

    /**
     * Initiate KYC verification for a customer
     */
    @Transactional
    public KycRecord initiateKyc(Long customerId, String fullName, 
                                 LocalDate dateOfBirth, String nationality,
                                 String idType, String idNumber) {
        
        log.info("Initiating KYC for customer: {}", customerId);
        
        KycRecord kyc = KycRecord.builder()
                .kycId(UUID.randomUUID())
                .customerId(customerId)
                .fullName(fullName)
                .dateOfBirth(dateOfBirth)
                .nationality(nationality)
                .idType(idType)
                .idNumber(idNumber)
                .kycLevel("BASIC")
                .kycStatus("PENDING")
                .createdAt(LocalDateTime.now())
                .build();
        
        kyc = kycRepository.save(kyc);
        
        // Publish event
        kafkaTemplate.send("customer.kyc.initiated", customerId.toString(), Map.of(
                "kycId", kyc.getKycId().toString(),
                "customerId", customerId,
                "kycLevel", "BASIC"
        ));
        
        return kyc;
    }

    /**
     * Upload and verify KYC documents
     */
    @Transactional
    public void uploadDocument(UUID kycId, String documentType, 
                              MultipartFile file) throws Exception {
        
        KycRecord kyc = kycRepository.findByKycId(kycId)
                .orElseThrow(() -> new Exception("KYC record not found"));
        
        // Upload to MinIO
        String filePath = documentService.uploadDocument(file, kycId, documentType);
        
        // OCR extraction (extract data from ID/passport)
        Map<String, Object> extractedData = documentService.performOcr(file);
        
        // Verify extracted data matches provided data
        boolean isVerified = verifyDocumentData(kyc, extractedData);
        
        // Save document record
        documentService.saveDocumentRecord(kycId, documentType, filePath, 
                                          extractedData, isVerified);
        
        // Update KYC status
        if (isVerified) {
            kyc.setKycStatus("IN_REVIEW");
            kycRepository.save(kyc);
        }
        
        log.info("Document uploaded for KYC: {}, type: {}", kycId, documentType);
    }

    /**
     * Perform comprehensive KYC checks
     */
    @Transactional
    public void performKycChecks(UUID kycId) throws Exception {
        
        KycRecord kyc = kycRepository.findByKycId(kycId)
                .orElseThrow(() -> new Exception("KYC record not found"));
        
        log.info("Performing KYC checks for: {}", kycId);
        
        // 1. PEP Check (Politically Exposed Person)
        boolean isPep = pepCheckService.checkPep(
                kyc.getFullName(), 
                kyc.getDateOfBirth(), 
                kyc.getNationality()
        );
        
        kyc.setIsPep(isPep);
        kyc.setPepCheckDate(LocalDateTime.now());
        
        if (isPep) {
            log.warn("PEP detected for customer: {}", kyc.getCustomerId());
            kyc.setPepDetails("Match found in PEP database");
        }
        
        // 2. Sanctions Screening
        List<String> sanctionsHits = sanctionsCheckService.checkSanctions(
                kyc.getFullName(),
                kyc.getDateOfBirth(),
                kyc.getNationality()
        );
        
        boolean sanctionsCleared = sanctionsHits.isEmpty();
        kyc.setSanctionsCleared(sanctionsCleared);
        kyc.setSanctionsCheckDate(LocalDateTime.now());
        
        if (!sanctionsCleared) {
            log.error("SANCTIONS HIT for customer: {}", kyc.getCustomerId());
            kyc.setKycStatus("REJECTED");
            kyc.setRejectionReason("Sanctions list match");
            kycRepository.save(kyc);
            
            // Publish rejection event
            publishKycRejected(kyc, "Sanctions list match");
            return;
        }
        
        // 3. Adverse Media Screening
        Map<String, Object> adverseMediaFindings = adverseMediaService.checkAdverseMedia(
                kyc.getFullName()
        );
        
        boolean adverseMediaCleared = adverseMediaFindings.isEmpty();
        kyc.setAdverseMediaCleared(adverseMediaCleared);
        kyc.setAdverseMediaCheckDate(LocalDateTime.now());
        
        // 4. Risk Scoring
        int riskScore = riskScoringService.calculateRiskScore(kyc, isPep, 
                sanctionsCleared, adverseMediaCleared);
        
        kyc.setRiskScore(riskScore);
        kyc.setRiskLevel(determineRiskLevel(riskScore));
        kyc.setRiskAssessmentDate(LocalDateTime.now());
        
        // 5. Make decision
        if (riskScore < 30 && sanctionsCleared) {
            // Auto-approve low risk
            approveKyc(kyc, "AUTOMATED");
        } else if (riskScore >= 70 || isPep) {
            // Require manual review for high risk
            kyc.setKycStatus("REQUIRES_MANUAL_REVIEW");
            kycRepository.save(kyc);
        } else {
            // Medium risk - standard review
            kyc.setKycStatus("IN_REVIEW");
            kycRepository.save(kyc);
        }
    }

    /**
     * Approve KYC
     */
    @Transactional
    public void approveKyc(KycRecord kyc, String verifiedBy) {
        
        kyc.setKycStatus("VERIFIED");
        kyc.setVerifiedBy(verifiedBy);
        kyc.setVerifiedAt(LocalDateTime.now());
        kyc.setAmlCleared(true);
        kyc.setCftCleared(true);
        
        // Set review schedule
        kyc.setLastReviewedAt(LocalDateTime.now());
        kyc.setNextReviewDate(LocalDate.now().plusYears(1));
        
        kycRepository.save(kyc);
        
        // Publish event
        publishKycVerified(kyc);
        
        log.info("KYC approved for customer: {}", kyc.getCustomerId());
    }

    /**
     * Reject KYC
     */
    @Transactional
    public void rejectKyc(UUID kycId, String reason, String rejectedBy) {
        
        KycRecord kyc = kycRepository.findByKycId(kycId)
                .orElseThrow(() -> new RuntimeException("KYC not found"));
        
        kyc.setKycStatus("REJECTED");
        kyc.setRejectionReason(reason);
        kyc.setVerifiedBy(rejectedBy);
        kyc.setVerifiedAt(LocalDateTime.now());
        
        kycRepository.save(kyc);
        
        // Publish event
        publishKycRejected(kyc, reason);
        
        log.info("KYC rejected for customer: {}, reason: {}", 
                kyc.getCustomerId(), reason);
    }

    /**
     * Schedule periodic KYC reviews
     */
    public List<KycRecord> getKycsRequiringReview() {
        LocalDate today = LocalDate.now();
        return kycRepository.findByNextReviewDateLessThanEqualAndKycStatus(
                today, "VERIFIED");
    }

    /**
     * Update customer risk profile
     */
    @Transactional
    public void updateRiskProfile(UUID kycId, Map<String, Object> riskFactors) {
        
        KycRecord kyc = kycRepository.findByKycId(kycId)
                .orElseThrow(() -> new RuntimeException("KYC not found"));
        
        // Recalculate risk score
        int newRiskScore = riskScoringService.calculateRiskScore(
                kyc, 
                kyc.getIsPep(), 
                kyc.getSanctionsCleared(), 
                kyc.getAdverseMediaCleared()
        );
        
        String oldRiskLevel = kyc.getRiskLevel();
        String newRiskLevel = determineRiskLevel(newRiskScore);
        
        kyc.setRiskScore(newRiskScore);
        kyc.setRiskLevel(newRiskLevel);
        kyc.setRiskAssessmentDate(LocalDateTime.now());
        
        kycRepository.save(kyc);
        
        // If risk increased significantly, trigger review
        if (!oldRiskLevel.equals(newRiskLevel)) {
            log.warn("Risk level changed for customer {}: {} -> {}", 
                    kyc.getCustomerId(), oldRiskLevel, newRiskLevel);
            
            kafkaTemplate.send("kyc.risk.level.changed", 
                    kyc.getCustomerId().toString(), 
                    Map.of(
                            "customerId", kyc.getCustomerId(),
                            "oldRiskLevel", oldRiskLevel,
                            "newRiskLevel", newRiskLevel,
                            "riskScore", newRiskScore
                    ));
        }
    }

    private String determineRiskLevel(int riskScore) {
        if (riskScore < 30) return "LOW";
        if (riskScore < 50) return "MEDIUM";
        if (riskScore < 70) return "HIGH";
        return "VERY_HIGH";
    }

    private boolean verifyDocumentData(KycRecord kyc, Map<String, Object> extractedData) {
        // Compare extracted data with provided data
        String extractedName = (String) extractedData.get("name");
        String extractedIdNumber = (String) extractedData.get("idNumber");
        
        boolean nameMatches = kyc.getFullName().equalsIgnoreCase(extractedName);
        boolean idMatches = kyc.getIdNumber().equals(extractedIdNumber);
        
        return nameMatches && idMatches;
    }

    private void publishKycVerified(KycRecord kyc) {
        kafkaTemplate.send("customer.kyc.verified", 
                kyc.getCustomerId().toString(),
                Map.of(
                        "kycId", kyc.getKycId().toString(),
                        "customerId", kyc.getCustomerId(),
                        "kycLevel", kyc.getKycLevel(),
                        "riskLevel", kyc.getRiskLevel(),
                        "verifiedAt", kyc.getVerifiedAt().toString()
                ));
    }

    private void publishKycRejected(KycRecord kyc, String reason) {
        kafkaTemplate.send("customer.kyc.rejected",
                kyc.getCustomerId().toString(),
                Map.of(
                        "kycId", kyc.getKycId().toString(),
                        "customerId", kyc.getCustomerId(),
                        "reason", reason,
                        "rejectedAt", LocalDateTime.now().toString()
                ));
    }
}
