package edu.ifba.saj.ads.api.blockchain.contracts.entity;

import java.math.BigInteger;
import java.time.Instant;

import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "service_agreements",
       uniqueConstraints = {
           @UniqueConstraint(name = "ux_agreement_contract_address", columnNames = "contract_address")
       },
       indexes = {
           @Index(name = "idx_contract_address", columnList = "contract_address"),
           @Index(name = "idx_client_wallet", columnList = "client_wallet"),
           @Index(name = "idx_provider_wallet", columnList = "provider_wallet"),
           @Index(name = "idx_status", columnList = "status")
       })
@EntityListeners(AuditingEntityListener.class)
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class ServiceAgreement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Endereço do contrato ServiceAgreement on-chain
    @Column(name = "contract_address", length = 42, nullable = false)
    private String contractAddress;

    // Endereço do contrato Factory que criou o acordo (opcional, mas útil)
    @Column(name = "factory_address", length = 42)
    private String factoryAddress;

    // Relacionamentos por wallet (chave natural em User)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "provider_wallet", referencedColumnName = "wallet")
    private User provider;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_wallet", referencedColumnName = "wallet")
    private User client;

    // Valor em wei (BigInteger alinha com Web3j)
    @Column(name = "agreed_value_wei", precision = 38, nullable = false)
    private BigInteger agreedValueWei;

    @Column(nullable = false)
    private Instant startDate;

    @Column(nullable = false)
    private Instant deliveryDate;

    @Column(length = 1024)
    private String serviceDescription;

    @Column(nullable = false)
    private boolean isCompleted;

    // Hash do contrato “civil”/documento (off-chain)
    @Column(length = 128, nullable = false)
    private String contractHash;

    // Timestamp on-chain (creationTimestamp do contrato Solidity)
    private Instant onChainCreatedAt;

    // Status off-chain para fluxo de negócio
    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private AgreementStatus status;

    // Metadados úteis
    @Column(length = 66)
    private String txHashCreate;

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    @LastModifiedDate
    @Column(nullable = false)
    private Instant updatedAt;
}
