package com.example.tripmind.repository;

import com.example.tripmind.model.ExpertProfile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ExpertProfileRepository extends JpaRepository<ExpertProfile, Long> {
    Optional<ExpertProfile> findByUserId(Long userId);
    void deleteByUserId(Long userId);

    List<ExpertProfile> findAllByUserIdIn(List<Long> userIds);

    List<ExpertProfile> findAllByIsShownTrue();
}
