package com.example.tripmind.controller;

import com.example.tripmind.dto.UserPublicDto;
import com.example.tripmind.exception.ResourceNotFoundException;
import com.example.tripmind.model.Role;
import com.example.tripmind.model.User;
import com.example.tripmind.repository.ExpertBookingRepository;
import com.example.tripmind.repository.ExpertProfileRepository;
import com.example.tripmind.repository.ItineraryRepository;
import com.example.tripmind.repository.TripRepository;
import com.example.tripmind.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.transaction.annotation.Transactional;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserRepository userRepository;
    private final ItineraryRepository itineraryRepository;
    private final TripRepository tripRepository;
    private final ExpertProfileRepository expertProfileRepository;
    private final ExpertBookingRepository expertBookingRepository;

    @GetMapping("/me")
    public UserPublicDto getCurrentUser(Authentication authentication) {
        String email = authentication.getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        return UserPublicDto.builder()
                .id(user.getId())
                .email(user.getEmail())
                .name(user.getName())
                .avatarUrl(user.getAvatarUrl())
                .role(user.getRole())
                .build();
    }

    @DeleteMapping("/me")
    @Transactional
    public ResponseEntity<Void> deleteMe(Authentication authentication) {
        String email = authentication.getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (user.getRole() != Role.USER) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only users can delete their account");
        }

        expertBookingRepository.deleteAllByUserId(user.getId());
        expertBookingRepository.deleteAllByExpertId(user.getId());
        expertProfileRepository.deleteByUserId(user.getId());
        itineraryRepository.deleteAllByUserEmail(user.getEmail());
        tripRepository.deleteAllByUserEmail(user.getEmail());
        userRepository.delete(user);

        return ResponseEntity.noContent().build();
    }
}
