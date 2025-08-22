package edu.ifba.saj.ads.api.blockchain.contracts.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import edu.ifba.saj.ads.api.blockchain.contracts.entity.AgreementStatus;
import edu.ifba.saj.ads.api.blockchain.contracts.entity.ServiceAgreement;

public interface ServiceAgreementRepository extends JpaRepository<ServiceAgreement, Long> {
    Optional<ServiceAgreement> findByContractAddress(String contractAddress);
    List<ServiceAgreement> findAllByClient_Wallet(String wallet);
    List<ServiceAgreement> findAllByProvider_Wallet(String wallet);
    List<ServiceAgreement> findAllByStatus(AgreementStatus status);
}
