package com.example.tripmind.repository;

import com.example.tripmind.model.Itinerary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ItineraryRepository extends JpaRepository<Itinerary, UUID> {
    List<Itinerary> findAllByUserEmailOrderByCreatedAtDesc(String userEmail);
    Optional<Itinerary> findByIdAndUserEmail(UUID id, String userEmail);
    List<Itinerary> findAllByTripIdOrderByCreatedAtDesc(UUID tripId);
    void deleteAllByUserEmail(String userEmail);

    @Query("select i.userEmail as userEmail, count(i) as count from Itinerary i group by i.userEmail")
    List<UserItineraryCount> countItinerariesByUserEmail();
}
