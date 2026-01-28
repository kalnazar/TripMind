package com.example.tripmind.repository;

import com.example.tripmind.model.ExpertBooking;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ExpertBookingRepository extends JpaRepository<ExpertBooking, Long> {
    List<ExpertBooking> findAllByExpertIdOrderByCreatedAtDesc(Long expertId);

    List<ExpertBooking> findAllByUserIdOrderByCreatedAtDesc(Long userId);

    void deleteAllByUserId(Long userId);

    void deleteAllByExpertId(Long expertId);
}
