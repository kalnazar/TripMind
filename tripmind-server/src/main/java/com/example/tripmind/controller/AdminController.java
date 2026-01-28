package com.example.tripmind.controller;

import com.example.tripmind.dto.admin.AdminDashboardDto;
import com.example.tripmind.dto.admin.AdminExpertDto;
import com.example.tripmind.dto.admin.AdminUserSummaryDto;
import com.example.tripmind.dto.admin.CreateExpertRequest;
import com.example.tripmind.dto.admin.UpdateExpertProfileRequest;
import com.example.tripmind.model.ExpertProfile;
import com.example.tripmind.model.Role;
import com.example.tripmind.model.User;
import com.example.tripmind.repository.ExpertProfileRepository;
import com.example.tripmind.repository.ExpertBookingRepository;
import com.example.tripmind.repository.ItineraryRepository;
import com.example.tripmind.repository.TripRepository;
import com.example.tripmind.repository.UserItineraryCount;
import com.example.tripmind.repository.UserRepository;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final UserRepository userRepository;
    private final TripRepository tripRepository;
    private final ItineraryRepository itineraryRepository;
    private final ExpertProfileRepository expertProfileRepository;
    private final ExpertBookingRepository expertBookingRepository;
    private final PasswordEncoder passwordEncoder;

    @GetMapping("/dashboard")
    public AdminDashboardDto dashboard() {
        return AdminDashboardDto.builder()
                .users(userRepository.countByRole(Role.USER))
                .experts(userRepository.countByRole(Role.EXPERT))
                .trips(tripRepository.count())
                .itineraries(itineraryRepository.count())
                .build();
    }

    @PostMapping("/experts")
    public AdminExpertDto createExpert(@RequestBody @Valid CreateExpertRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email already registered");
        }

        User expert = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .avatarUrl(request.getAvatarUrl())
                .role(Role.EXPERT)
                .build();
        userRepository.save(expert);

        String countryCode = request.getCountryCode();
        String normalizedCountry = countryCode == null ? null : countryCode.trim().toUpperCase();

        ExpertProfile profile = ExpertProfile.builder()
                .user(expert)
                .bio(request.getBio())
                .location(request.getLocation())
                .languages(request.getLanguages())
                .experienceYears(request.getExperienceYears())
                .pricePerHour(request.getPricePerHour())
                .countryCode(normalizedCountry)
                .timeZone(request.getTimeZone())
                .isShown(request.getIsShown() != null && request.getIsShown())
                .build();
        expertProfileRepository.save(profile);

        return AdminExpertDto.builder()
                .id(expert.getId())
                .email(expert.getEmail())
                .name(expert.getName())
                .avatarUrl(expert.getAvatarUrl())
                .role(expert.getRole())
                .bio(profile.getBio())
                .location(profile.getLocation())
                .languages(profile.getLanguages())
                .experienceYears(profile.getExperienceYears())
                .pricePerHour(profile.getPricePerHour())
                .countryCode(profile.getCountryCode())
                .timeZone(profile.getTimeZone())
                .isShown(profile.getIsShown())
                .build();
    }

    @GetMapping("/experts")
    public List<AdminExpertDto> listExperts() {
        List<User> experts = userRepository.findAllByRole(Role.EXPERT);
        if (experts.isEmpty()) {
            return List.of();
        }
        List<Long> expertIds = experts.stream().map(User::getId).toList();

        var profilesByUserId = expertProfileRepository.findAllByUserIdIn(expertIds).stream()
                .collect(Collectors.toMap(p -> p.getUser().getId(), p -> p));

        return experts.stream()
                .map(u -> {
                    ExpertProfile profile = profilesByUserId.get(u.getId());
                    return AdminExpertDto.builder()
                            .id(u.getId())
                            .email(u.getEmail())
                            .name(u.getName())
                            .avatarUrl(u.getAvatarUrl())
                            .role(u.getRole())
                            .bio(profile != null ? profile.getBio() : null)
                            .location(profile != null ? profile.getLocation() : null)
                            .languages(profile != null ? profile.getLanguages() : null)
                            .experienceYears(profile != null ? profile.getExperienceYears() : null)
                            .pricePerHour(profile != null ? profile.getPricePerHour() : null)
                            .countryCode(profile != null ? profile.getCountryCode() : null)
                            .timeZone(profile != null ? profile.getTimeZone() : null)
                            .isShown(profile != null ? profile.getIsShown() : Boolean.FALSE)
                            .build();
                })
                .toList();
    }

    @PatchMapping("/experts/{id}")
    public AdminExpertDto updateExpertProfile(@PathVariable Long id,
                                              @RequestBody @Valid UpdateExpertProfileRequest request) {
        User expert = userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Expert not found"));
        if (expert.getRole() != Role.EXPERT) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Expert not found");
        }

        ExpertProfile profile = expertProfileRepository.findByUserId(expert.getId())
                .orElseGet(() -> ExpertProfile.builder().user(expert).build());

        if (request.getBio() != null) {
            profile.setBio(request.getBio());
        }
        if (request.getLocation() != null) {
            profile.setLocation(request.getLocation());
        }
        if (request.getLanguages() != null) {
            profile.setLanguages(request.getLanguages());
        }
        if (request.getExperienceYears() != null) {
            profile.setExperienceYears(request.getExperienceYears());
        }
        if (request.getPricePerHour() != null) {
            profile.setPricePerHour(request.getPricePerHour());
        }
        if (request.getCountryCode() != null) {
            String normalized = request.getCountryCode().trim().toUpperCase();
            profile.setCountryCode(normalized.isEmpty() ? null : normalized);
        }
        if (request.getTimeZone() != null) {
            profile.setTimeZone(request.getTimeZone());
        }
        if (request.getIsShown() != null) {
            profile.setIsShown(request.getIsShown());
        }

        expertProfileRepository.save(profile);

        return AdminExpertDto.builder()
                .id(expert.getId())
                .email(expert.getEmail())
                .name(expert.getName())
                .avatarUrl(expert.getAvatarUrl())
                .role(expert.getRole())
                .bio(profile.getBio())
                .location(profile.getLocation())
                .languages(profile.getLanguages())
                .experienceYears(profile.getExperienceYears())
                .pricePerHour(profile.getPricePerHour())
                .countryCode(profile.getCountryCode())
                .timeZone(profile.getTimeZone())
                .isShown(profile.getIsShown())
                .build();
    }

    @DeleteMapping("/experts/{id}")
    @org.springframework.transaction.annotation.Transactional
    public ResponseEntity<Void> deleteExpert(@PathVariable Long id) {
        User expert = userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Expert not found"));
        if (expert.getRole() != Role.EXPERT) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Expert not found");
        }

        expertBookingRepository.deleteAllByExpertId(expert.getId());
        expertBookingRepository.deleteAllByUserId(expert.getId());
        expertProfileRepository.deleteByUserId(expert.getId());
        itineraryRepository.deleteAllByUserEmail(expert.getEmail());
        tripRepository.deleteAllByUserEmail(expert.getEmail());
        userRepository.delete(expert);

        return ResponseEntity.noContent().build();
    }

    @GetMapping("/users")
    public List<AdminUserSummaryDto> listUsers() {
        Map<String, Long> counts = itineraryRepository.countItinerariesByUserEmail().stream()
                .collect(Collectors.toMap(UserItineraryCount::getUserEmail, UserItineraryCount::getCount));

        return userRepository.findAll().stream()
                .map(u -> AdminUserSummaryDto.builder()
                        .id(u.getId())
                        .email(u.getEmail())
                        .name(u.getName())
                        .role(u.getRole())
                        .itineraryCount(counts.getOrDefault(u.getEmail(), 0L))
                        .build())
                .toList();
    }
}
