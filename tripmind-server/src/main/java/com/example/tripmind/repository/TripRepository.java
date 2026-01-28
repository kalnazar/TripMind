package com.example.tripmind.repository;

import com.example.tripmind.model.Trip;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface TripRepository extends JpaRepository<Trip, UUID> {
    List<Trip> findAllByUserEmailOrderByCreatedAtDesc(String userEmail);
    void deleteAllByUserEmail(String userEmail);
}
