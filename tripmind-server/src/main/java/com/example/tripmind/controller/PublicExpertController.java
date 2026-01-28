package com.example.tripmind.controller;

import com.example.tripmind.dto.expert.ExpertPublicDto;
import com.example.tripmind.model.ExpertProfile;
import com.example.tripmind.model.Role;
import com.example.tripmind.repository.ExpertProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/public")
@RequiredArgsConstructor
public class PublicExpertController {

    private final ExpertProfileRepository expertProfileRepository;

    @GetMapping("/experts")
    public List<ExpertPublicDto> listVisibleExperts() {
        return expertProfileRepository.findAllByIsShownTrue().stream()
                .filter(profile -> profile.getUser() != null && profile.getUser().getRole() == Role.EXPERT)
                .map(profile -> ExpertPublicDto.builder()
                        .id(profile.getUser().getId())
                        .name(profile.getUser().getName())
                        .avatarUrl(profile.getUser().getAvatarUrl())
                        .bio(profile.getBio())
                        .location(profile.getLocation())
                        .languages(profile.getLanguages())
                        .experienceYears(profile.getExperienceYears())
                        .pricePerHour(profile.getPricePerHour())
                        .countryCode(profile.getCountryCode())
                        .timeZone(profile.getTimeZone())
                        .build())
                .toList();
    }
}
