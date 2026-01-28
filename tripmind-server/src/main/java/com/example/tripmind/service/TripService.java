package com.example.tripmind.service;

import com.example.tripmind.dto.trip.TripDtos.*;
import com.example.tripmind.exception.ForbiddenException;
import com.example.tripmind.exception.ResourceNotFoundException;
import com.example.tripmind.model.Trip;
import com.example.tripmind.repository.TripRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class TripService {

    private final TripRepository tripRepository;
    private final ObjectMapper objectMapper;

    @Transactional
    public SaveTripResponse save(SaveTripRequest request, Authentication authentication) {
        String userEmail = authentication.getName();
        
        try {
            String planJson = objectMapper.writeValueAsString(request.getPlan());
            String title = request.getTitle() != null && !request.getTitle().isBlank()
                    ? request.getTitle()
                    : String.format("%s in %d days", request.getDestination(), 
                            request.getDurationDays() != null ? request.getDurationDays() : 0);
            
            String interests = request.getInterests() != null && !request.getInterests().isEmpty()
                    ? String.join(", ", request.getInterests())
                    : null;

            Trip trip = Trip.builder()
                    .userEmail(userEmail)
                    .title(title)
                    .origin(request.getOrigin())
                    .destination(request.getDestination())
                    .durationDays(request.getDurationDays() != null ? request.getDurationDays() : 0)
                    .budget(request.getBudget())
                    .groupSize(request.getGroupSize())
                    .interests(interests)
                    .specialReq(request.getSpecialReq())
                    .planJson(planJson)
                    .createdAt(OffsetDateTime.now())
                    .build();

            Trip saved = tripRepository.save(trip);
            return new SaveTripResponse(saved.getId());
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to serialize trip plan: " + e.getMessage(), e);
        }
    }

    @Transactional(readOnly = true)
    public List<Trip> listMine(Authentication authentication) {
        String userEmail = authentication.getName();
        return tripRepository.findAllByUserEmailOrderByCreatedAtDesc(userEmail);
    }

    @Transactional(readOnly = true)
    public Trip getOne(UUID id, Authentication authentication) {
        String userEmail = authentication.getName();
        Trip trip = tripRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Trip not found"));
        
        if (!trip.getUserEmail().equals(userEmail)) {
            throw new ForbiddenException("You don't have access to this trip");
        }
        
        return trip;
    }
}
