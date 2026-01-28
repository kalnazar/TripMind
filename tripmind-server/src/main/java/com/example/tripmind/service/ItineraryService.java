package com.example.tripmind.service;

import com.example.tripmind.dto.itinerary.ItineraryDtos.*;
import com.example.tripmind.exception.ForbiddenException;
import com.example.tripmind.exception.ResourceNotFoundException;
import com.example.tripmind.model.Itinerary;
import com.example.tripmind.model.Trip;
import com.example.tripmind.repository.ItineraryRepository;
import com.example.tripmind.repository.TripRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class ItineraryService {

    private final ItineraryRepository itineraryRepository;
    private final TripRepository tripRepository;
    private final ObjectMapper objectMapper;
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ISO_OFFSET_DATE_TIME;

    public SaveItineraryResponse saveItinerary(SaveItineraryRequest request, Authentication authentication) {
        String userEmail = authentication.getName();

        // Validate trip ownership if tripId is provided
        if (request.getTripId() != null) {
            Trip trip = tripRepository.findById(request.getTripId())
                    .orElseThrow(() -> new ResourceNotFoundException("Trip not found"));
            if (!trip.getUserEmail().equals(userEmail)) {
                throw new ForbiddenException("You don't have access to this trip");
            }
        }

        try {
            String itineraryJson = objectMapper.writeValueAsString(request.getItineraryData());

            Itinerary itinerary = Itinerary.builder()
                    .userEmail(userEmail)
                    .tripId(request.getTripId())
                    .title(request.getTitle())
                    .itineraryJson(itineraryJson)
                    .build();

            Itinerary saved = itineraryRepository.save(itinerary);
            return new SaveItineraryResponse(saved.getId(), "Itinerary saved successfully");
        } catch (Exception e) {
            throw new RuntimeException("Failed to save itinerary: " + e.getMessage(), e);
        }
    }

    @Transactional(readOnly = true)
    public List<ItinerarySummary> getAllItineraries(Authentication authentication) {
        String userEmail = authentication.getName();
        List<Itinerary> itineraries = itineraryRepository.findAllByUserEmailOrderByCreatedAtDesc(userEmail);

        return itineraries.stream()
                .map(itinerary -> new ItinerarySummary(
                        itinerary.getId(),
                        itinerary.getTitle(),
                        itinerary.getTripId(),
                        itinerary.getCreatedAt().format(FORMATTER)
                ))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public ItineraryResponse getItineraryById(UUID id, Authentication authentication) {
        String userEmail = authentication.getName();
        Itinerary itinerary = itineraryRepository.findByIdAndUserEmail(id, userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Itinerary not found"));

        try {
            Map<String, Object> itineraryData = objectMapper.readValue(
                    itinerary.getItineraryJson(),
                    new TypeReference<Map<String, Object>>() {}
            );

            return new ItineraryResponse(
                    itinerary.getId(),
                    itinerary.getUserEmail(),
                    itinerary.getTripId(),
                    itinerary.getTitle(),
                    itineraryData,
                    itinerary.getCreatedAt().format(FORMATTER),
                    itinerary.getUpdatedAt() != null ? itinerary.getUpdatedAt().format(FORMATTER) : null
            );
        } catch (Exception e) {
            throw new RuntimeException("Failed to parse itinerary data: " + e.getMessage(), e);
        }
    }

    @Transactional(readOnly = true)
    public List<ItinerarySummary> getItinerariesByTripId(UUID tripId, Authentication authentication) {
        String userEmail = authentication.getName();

        // Verify trip ownership
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Trip not found"));
        if (!trip.getUserEmail().equals(userEmail)) {
            throw new ForbiddenException("You don't have access to this trip");
        }

        List<Itinerary> itineraries = itineraryRepository.findAllByTripIdOrderByCreatedAtDesc(tripId);
        return itineraries.stream()
                .map(itinerary -> new ItinerarySummary(
                        itinerary.getId(),
                        itinerary.getTitle(),
                        itinerary.getTripId(),
                        itinerary.getCreatedAt().format(FORMATTER)
                ))
                .collect(Collectors.toList());
    }

    public void deleteItinerary(UUID id, Authentication authentication) {
        String userEmail = authentication.getName();
        Itinerary itinerary = itineraryRepository.findByIdAndUserEmail(id, userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Itinerary not found"));
        itineraryRepository.delete(itinerary);
    }
}
