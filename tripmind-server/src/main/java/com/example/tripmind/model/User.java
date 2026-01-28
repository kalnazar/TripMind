package com.example.tripmind.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(name = "password_hash", nullable = false)
    private String password;

    @Column(nullable = false)
    private String name;

    @Column(name = "avatar_url")
    private String avatarUrl;

    @Enumerated(EnumType.STRING)
    // Keep nullable at DB level so existing rows can be backfilled safely.
    // Application logic + @PrePersist ensure a non-null role for new users.
    @Column
    private Role role;

    @PrePersist
    protected void prePersist() {
        if (role == null) role = Role.USER;
    }
}
