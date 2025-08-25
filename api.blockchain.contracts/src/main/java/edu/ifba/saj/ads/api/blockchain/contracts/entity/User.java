package edu.ifba.saj.ads.api.blockchain.contracts.entity;

import java.time.Instant;

import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "users",
       uniqueConstraints = @UniqueConstraint(name = "ux_users_wallet", columnNames = "wallet"),
       indexes = { @Index(name = "idx_users_wallet", columnList = "wallet") })
@EntityListeners(AuditingEntityListener.class)
@Data 
@NoArgsConstructor 
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Endereço da wallet (0x... 42 chars)
    @Column(nullable = false, length = 42)
    private String wallet;

    @Column(nullable = false, length = 120)
    private String name;

    // Dado sensível deve ser criptografado off-chain
    @Column(length = 512)
    private String sensitiveInfo;

    // espelha creationTimestamp on-chain (UserRegistry); opcional
    private Instant onChainCreatedAt;

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    @LastModifiedDate
    @Column(nullable = false)
    private Instant updatedAt;
}
