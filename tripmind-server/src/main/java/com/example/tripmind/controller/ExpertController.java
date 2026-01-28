package com.example.tripmind.controller;

import com.example.tripmind.dto.expert.ExpertProfileDto;
import com.example.tripmind.dto.expert.UpdateExpertProfileRequest;
import com.example.tripmind.exception.ResourceNotFoundException;
import com.example.tripmind.model.ExpertProfile;
import com.example.tripmind.model.Role;
import com.example.tripmind.model.User;
import com.example.tripmind.repository.ExpertProfileRepository;
import com.example.tripmind.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/experts")
@RequiredArgsConstructor
public class ExpertController {

    private final UserRepository userRepository;
    private final ExpertProfileRepository expertProfileRepository;

    @GetMapping("/me")
    public ExpertProfileDto me(Authentication authentication) {
        String email = authentication.getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        // SecurityConfig already restricts /api/experts/** to experts,
        // but keep a defensive check to avoid confusing responses if misconfigured.
        if (user.getRole() != Role.EXPERT) {
            throw new ResourceNotFoundException("Expert not found");
        }

        ExpertProfile profile = expertProfileRepository.findByUserId(user.getId()).orElse(null);

        return ExpertProfileDto.builder()
                .id(user.getId())
                .email(user.getEmail())
                .name(user.getName())
                .avatarUrl(user.getAvatarUrl())
                .bio(profile != null ? profile.getBio() : null)
                .location(profile != null ? profile.getLocation() : null)
                .languages(profile != null ? profile.getLanguages() : null)
                .experienceYears(profile != null ? profile.getExperienceYears() : null)
                .pricePerHour(profile != null ? profile.getPricePerHour() : null)
                .countryCode(profile != null ? profile.getCountryCode() : null)
                .timeZone(profile != null ? profile.getTimeZone() : null)
                .isShown(profile != null ? profile.getIsShown() : Boolean.FALSE)
                .build();
    }

    @RequestMapping(value = "/me", method = {RequestMethod.PATCH, RequestMethod.PUT})
    public ExpertProfileDto updateMe(Authentication authentication,
                                     @RequestBody @Valid UpdateExpertProfileRequest request) {
        String email = authentication.getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (user.getRole() != Role.EXPERT) {
            throw new ResourceNotFoundException("Expert not found");
        }

        ExpertProfile profile = expertProfileRepository.findByUserId(user.getId())
                .orElseGet(() -> ExpertProfile.builder().user(user).build());

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
        if (request.getTimeZone() != null) {
            profile.setTimeZone(request.getTimeZone());
        }
        if (request.getCountryCode() != null) {
            String normalized = request.getCountryCode().trim().toUpperCase();
            profile.setCountryCode(normalized.isEmpty() ? null : normalized);
        }

        expertProfileRepository.save(profile);

        return ExpertProfileDto.builder()
                .id(user.getId())
                .email(user.getEmail())
                .name(user.getName())
                .avatarUrl(user.getAvatarUrl())
                .bio(profile.getBio())
                .location(profile.getLocation())
                .languages(profile.getLanguages())
                .experienceYears(profile.getExperienceYears())
                .pricePerHour(profile.getPricePerHour())
                .countryCode(profile.getCountryCode())
                .timeZone(profile.getTimeZone())
                .isShown(profile.getIsShown() != null ? profile.getIsShown() : Boolean.FALSE)
                .build();
    }
}
