package com.example.tripmind.controller;

import com.example.tripmind.dto.booking.CreateExpertBookingRequest;
import com.example.tripmind.dto.booking.ExpertBookingDto;
import com.example.tripmind.model.ExpertBooking;
import com.example.tripmind.model.Role;
import com.example.tripmind.model.User;
import com.example.tripmind.repository.ExpertBookingRepository;
import com.example.tripmind.repository.ExpertProfileRepository;
import com.example.tripmind.repository.UserRepository;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeParseException;

@RestController
@RequestMapping("/api/expert-bookings")
@RequiredArgsConstructor
public class ExpertBookingController {

    private final UserRepository userRepository;
    private final ExpertProfileRepository expertProfileRepository;
    private final ExpertBookingRepository expertBookingRepository;

    @PostMapping
    public ExpertBookingDto createBooking(@RequestBody @Valid CreateExpertBookingRequest request,
                                          Authentication authentication) {
        User user = userRepository.findByEmail(authentication.getName())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User not found"));

        User expert = userRepository.findById(request.getExpertId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Expert not found"));
        if (expert.getRole() != Role.EXPERT) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Expert not found");
        }

        var profile = expertProfileRepository.findByUserId(expert.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Expert not found"));
        if (profile.getIsShown() == null || !profile.getIsShown()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Expert is not available for booking");
        }
        if (profile.getTimeZone() == null || profile.getTimeZone().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Expert timezone is not set");
        }

        ZoneId zoneId;
        try {
            zoneId = ZoneId.of(profile.getTimeZone());
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Expert timezone is invalid");
        }

        LocalDate date;
        LocalTime time;
        try {
            date = LocalDate.parse(request.getDate());
            time = LocalTime.parse(request.getTime());
        } catch (DateTimeParseException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid date or time format");
        }

        if (time.getMinute() != 0 || time.getSecond() != 0 || (time.getHour() % 4 != 0)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Time must be in 4-hour increments");
        }

        OffsetDateTime requestedStart = ZonedDateTime.of(date, time, zoneId).toOffsetDateTime();

        ExpertBooking booking = ExpertBooking.builder()
                .user(user)
                .expert(expert)
                .requestedStart(requestedStart)
                .requestedTimeZone(zoneId.getId())
                .durationHours(4)
                .build();
        ExpertBooking saved = expertBookingRepository.save(booking);

        return ExpertBookingDto.builder()
                .id(saved.getId())
                .status(saved.getStatus())
                .createdAt(saved.getCreatedAt())
                .requestedStart(saved.getRequestedStart())
                .requestedTimeZone(saved.getRequestedTimeZone())
                .durationHours(saved.getDurationHours())
                .expertId(expert.getId())
                .expertName(expert.getName())
                .expertAvatarUrl(expert.getAvatarUrl())
                .userId(user.getId())
                .userName(user.getName())
                .userEmail(user.getEmail())
                .userAvatarUrl(user.getAvatarUrl())
                .build();
    }

    @GetMapping
    public java.util.List<ExpertBookingDto> listUserBookings(Authentication authentication) {
        User user = userRepository.findByEmail(authentication.getName())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User not found"));

        return expertBookingRepository.findAllByUserIdOrderByCreatedAtDesc(user.getId()).stream()
                .map(booking -> ExpertBookingDto.builder()
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
                        .build())
                .toList();
    }
}
