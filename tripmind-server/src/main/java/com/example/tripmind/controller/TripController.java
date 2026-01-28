package com.example.tripmind.controller;

import com.example.tripmind.dto.trip.TripDtos.*;
import com.example.tripmind.model.Trip;
import com.example.tripmind.service.TripService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/trips")
@RequiredArgsConstructor
public class TripController {

    private final TripService tripService;

    @PostMapping
    public ResponseEntity<SaveTripResponse> createTrip(
            @RequestBody @Valid SaveTripRequest request,
            Authentication authentication) {
        SaveTripResponse response = tripService.save(request, authentication);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    public ResponseEntity<List<Trip>> getMyTrips(Authentication authentication) {
        return ResponseEntity.ok(tripService.listMine(authentication));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Trip> getTripById(
            @PathVariable UUID id,
            Authentication authentication) {
        return ResponseEntity.ok(tripService.getOne(id, authentication));
    }
}
