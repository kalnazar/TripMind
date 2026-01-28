package com.example.tripmind.repository;

import com.example.tripmind.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.List;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);

    long countByRole(com.example.tripmind.model.Role role);

    List<User> findAllByRole(com.example.tripmind.model.Role role);
}


