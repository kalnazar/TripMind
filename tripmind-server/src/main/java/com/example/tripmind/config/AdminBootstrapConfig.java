package com.example.tripmind.config;

import com.example.tripmind.model.Role;
import com.example.tripmind.model.User;
import com.example.tripmind.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
@RequiredArgsConstructor
public class AdminBootstrapConfig {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Bean
    CommandLineRunner ensureAdminUser(
            @Value("${app.admin.email:}") String adminEmail,
            @Value("${app.admin.password:}") String adminPassword,
            @Value("${app.admin.name:Admin}") String adminName
    ) {
        return args -> {
            if (adminEmail == null || adminEmail.isBlank()) return;
            if (adminPassword == null || adminPassword.isBlank()) return;

            userRepository.findByEmail(adminEmail).ifPresentOrElse(existing -> {
                if (existing.getRole() != Role.ADMIN) {
                    existing.setRole(Role.ADMIN);
                    userRepository.save(existing);
                }
            }, () -> {
                User admin = User.builder()
                        .email(adminEmail)
                        .name(adminName == null || adminName.isBlank() ? "Admin" : adminName)
                        .password(passwordEncoder.encode(adminPassword))
                        .role(Role.ADMIN)
                        .build();
                userRepository.save(admin);
            });
        };
    }
}

