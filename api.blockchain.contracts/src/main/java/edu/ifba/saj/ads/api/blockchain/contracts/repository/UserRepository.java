package edu.ifba.saj.ads.api.blockchain.contracts.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import edu.ifba.saj.ads.api.blockchain.contracts.entity.User;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByWallet(String wallet);
    boolean existsByWallet(String wallet);
}
