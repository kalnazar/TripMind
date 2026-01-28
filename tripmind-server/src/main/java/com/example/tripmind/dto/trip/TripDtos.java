package com.example.tripmind.dto.trip;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

public class TripDtos {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SaveTripRequest {
        private String title;
        
        @NotBlank(message = "Origin is required")
        private String origin;
        
        @NotBlank(message = "Destination is required")
        private String destination;
        
        private Integer durationDays;
        
        @NotBlank(message = "Budget is required")
        private String budget;
        
        @NotBlank(message = "Group size is required")
        private String groupSize;
        
        private List<String> interests;
        private String specialReq;
        
        @NotNull(message = "Plan is required")
        private Map<String, Object> plan;
    }

    @Getter @Setter @AllArgsConstructor
    public static class TripSummary {
        public UUID id;
        public String title;
        public String origin;
        public String destination;
        public Integer durationDays;
        public String budget;
        public String groupSize;
        public String createdAt;
    }

    @Getter @Setter @AllArgsConstructor
    public static class SaveTripResponse {
        public UUID id;
    }
}
