package com.example.tripmind.controller;

import com.example.tripmind.dto.booking.ExpertBookingDto;
import com.example.tripmind.dto.booking.UpdateExpertBookingStatusRequest;
import com.example.tripmind.model.ExpertBooking;
import com.example.tripmind.model.ExpertBookingStatus;
import com.example.tripmind.model.Role;
import com.example.tripmind.model.User;
import com.example.tripmind.repository.ExpertBookingRepository;
import com.example.tripmind.repository.UserRepository;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api/experts/bookings")
@RequiredArgsConstructor
public class ExpertBookingExpertController {

    private final UserRepository userRepository;
    private final ExpertBookingRepository expertBookingRepository;

    @GetMapping
    public List<ExpertBookingDto> listBookings(Authentication authentication) {
        User expert = userRepository.findByEmail(authentication.getName())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Expert not found"));
        if (expert.getRole() != Role.EXPERT) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Expert not found");
        }

        return expertBookingRepository.findAllByExpertIdOrderByCreatedAtDesc(expert.getId()).stream()
                .map(this::toDto)
                .toList();
    }

    @PatchMapping("/{id}")
    public ExpertBookingDto updateStatus(@PathVariable Long id,
                                         @RequestBody @Valid UpdateExpertBookingStatusRequest request,
                                         Authentication authentication) {
        User expert = userRepository.findByEmail(authentication.getName())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Expert not found"));
        if (expert.getRole() != Role.EXPERT) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Expert not found");
        }

        ExpertBooking booking = expertBookingRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Booking not found"));

        if (!booking.getExpert().getId().equals(expert.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Not your booking");
        }

        ExpertBookingStatus status = request.getStatus();
        if (status == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Status is required");
        }

        booking.setStatus(status);
        ExpertBooking saved = expertBookingRepository.save(booking);

        return toDto(saved);
    }

    private ExpertBookingDto toDto(ExpertBooking booking) {
        User user = booking.getUser();
        return ExpertBookingDto.builder()
                .id(booking.getId())
                .status(booking.getStatus())
                .createdAt(booking.getCreatedAt())
                .requestedStart(booking.getRequestedStart())
                .requestedTimeZone(booking.getRequestedTimeZone())
                .durationHours(booking.getDurationHours())
                .expertId(booking.getExpert().getId())
                .expertName(booking.getExpert().getName())
                .expertAvatarUrl(booking.getExpert().getAvatarUrl())
                .userId(user.getId())
                .userName(user.getName())
                .userEmail(user.getEmail())
                .userAvatarUrl(user.getAvatarUrl())
                .build();
    }
}
