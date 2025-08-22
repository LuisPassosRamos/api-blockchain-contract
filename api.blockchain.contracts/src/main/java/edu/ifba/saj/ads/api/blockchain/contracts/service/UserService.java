package edu.ifba.saj.ads.api.blockchain.contracts.service;

import java.time.Instant;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import edu.ifba.saj.ads.api.blockchain.contracts.entity.User;
import edu.ifba.saj.ads.api.blockchain.contracts.repository.UserRepository;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;

    @Transactional
    public User getOrCreate(String wallet, String name, String sensitiveInfo, Instant onChainCreatedAt) {
        return userRepository.findByWallet(wallet)
                .orElseGet(() -> userRepository.save(
                        User.builder()
                            .wallet(wallet)
                            .name(name)
                            .sensitiveInfo(sensitiveInfo)
                            .onChainCreatedAt(onChainCreatedAt)
                            .build()
                ));
    }
}
