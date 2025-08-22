package edu.ifba.saj.ads.api.blockchain.contracts.service;

import java.math.BigInteger;
import java.time.Instant;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import edu.ifba.saj.ads.api.blockchain.contracts.entity.AgreementStatus;
import edu.ifba.saj.ads.api.blockchain.contracts.entity.ServiceAgreement;
import edu.ifba.saj.ads.api.blockchain.contracts.entity.User;
import edu.ifba.saj.ads.api.blockchain.contracts.repository.ServiceAgreementRepository;
import edu.ifba.saj.ads.api.blockchain.contracts.repository.UserRepository;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ServiceAgreementService {

    private final ServiceAgreementRepository agreementRepository;
    private final UserRepository userRepository;

    @Transactional
    public ServiceAgreement createOffChain(
            String contractAddress,
            String factoryAddress,
            String providerWallet,
            String clientWallet,
            BigInteger agreedValueWei,
            Instant startDate,
            Instant deliveryDate,
            String description,
            String contractHash,
            Instant onChainCreatedAt,
            String txHashCreate
    ) {
        User provider = userRepository.findByWallet(providerWallet).orElse(null);
        User client = userRepository.findByWallet(clientWallet).orElse(null);

        ServiceAgreement entity = ServiceAgreement.builder()
                .contractAddress(contractAddress)
                .factoryAddress(factoryAddress)
                .provider(provider)
                .client(client)
                .agreedValueWei(agreedValueWei)
                .startDate(startDate)
                .deliveryDate(deliveryDate)
                .serviceDescription(description)
                .isCompleted(false)
                .contractHash(contractHash)
                .onChainCreatedAt(onChainCreatedAt)
                .status(AgreementStatus.CREATED)
                .txHashCreate(txHashCreate)
                .build();

        return agreementRepository.save(entity);
    }

    @Transactional
    public ServiceAgreement updateStatus(String contractAddress, AgreementStatus status, boolean isCompleted) {
        ServiceAgreement ag = agreementRepository.findByContractAddress(contractAddress)
                .orElseThrow(() -> new IllegalArgumentException("Agreement not found: " + contractAddress));
        ag.setStatus(status);
        ag.setCompleted(isCompleted);
        return agreementRepository.save(ag);
    }
}
