package com.example.tripmind.repository;

import com.example.tripmind.model.Itinerary;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ItineraryRepository extends JpaRepository<Itinerary, UUID> {
    List<Itinerary> findAllByUserEmailOrderByCreatedAtDesc(String userEmail);
    Optional<Itinerary> findByIdAndUserEmail(UUID id, String userEmail);
    List<Itinerary> findAllByTripIdOrderByCreatedAtDesc(UUID tripId);
}
