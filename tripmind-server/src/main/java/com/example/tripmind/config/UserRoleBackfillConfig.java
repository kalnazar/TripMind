package com.example.tripmind.config;

import com.example.tripmind.model.Role;
import com.example.tripmind.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@RequiredArgsConstructor
public class UserRoleBackfillConfig {

    private final UserRepository userRepository;

    @Bean
    CommandLineRunner backfillNullUserRoles() {
        return args -> userRepository.findAll().stream()
                .filter(u -> u.getRole() == null)
                .forEach(u -> {
                    u.setRole(Role.USER);
                    userRepository.save(u);
                });
    }
}

