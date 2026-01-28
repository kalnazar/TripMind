package com.example.tripmind.dto.itinerary;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.util.Map;
import java.util.UUID;

public class ItineraryDtos {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SaveItineraryRequest {
        @NotBlank(message = "Title is required")
        private String title;

        private UUID tripId; // Optional: link to a trip

        @NotNull(message = "Itinerary data is required")
        private Map<String, Object> itineraryData;
    }

    @Getter
    @Setter
    @AllArgsConstructor
    public static class SaveItineraryResponse {
        private UUID id;
        private String message;
    }

    @Getter
    @Setter
    @AllArgsConstructor
    public static class ItineraryResponse {
        private UUID id;
        private String userEmail;
        private UUID tripId;
        private String title;
        private Map<String, Object> itineraryData;
        private String createdAt;
        private String updatedAt;
    }

    @Getter
    @Setter
    @AllArgsConstructor
    public static class ItinerarySummary {
        private UUID id;
        private String title;
        private UUID tripId;
        private String createdAt;
    }
}
