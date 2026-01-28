package com.example.tripmind.controller;

import com.example.tripmind.dto.itinerary.ItineraryDtos.*;
import com.example.tripmind.service.ItineraryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/itineraries")
@RequiredArgsConstructor
public class ItineraryController {

    private final ItineraryService itineraryService;

    @PostMapping
    public ResponseEntity<SaveItineraryResponse> saveItinerary(
            @RequestBody @Valid SaveItineraryRequest request,
            Authentication authentication) {
        SaveItineraryResponse response = itineraryService.saveItinerary(request, authentication);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    public ResponseEntity<List<ItinerarySummary>> getAllItineraries(Authentication authentication) {
        List<ItinerarySummary> itineraries = itineraryService.getAllItineraries(authentication);
        return ResponseEntity.ok(itineraries);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ItineraryResponse> getItineraryById(
            @PathVariable UUID id,
            Authentication authentication) {
        ItineraryResponse itinerary = itineraryService.getItineraryById(id, authentication);
        return ResponseEntity.ok(itinerary);
    }

    @GetMapping("/trip/{tripId}")
    public ResponseEntity<List<ItinerarySummary>> getItinerariesByTripId(
            @PathVariable UUID tripId,
            Authentication authentication) {
        List<ItinerarySummary> itineraries = itineraryService.getItinerariesByTripId(tripId, authentication);
        return ResponseEntity.ok(itineraries);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteItinerary(
            @PathVariable UUID id,
            Authentication authentication) {
        itineraryService.deleteItinerary(id, authentication);
        return ResponseEntity.noContent().build();
    }
}
