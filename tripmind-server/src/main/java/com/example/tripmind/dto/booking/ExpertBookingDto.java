package com.example.tripmind.dto.booking;

import com.example.tripmind.model.ExpertBookingStatus;
import lombok.Builder;
import lombok.Data;

import java.time.OffsetDateTime;

@Data
@Builder
public class ExpertBookingDto {
    private Long id;
    private ExpertBookingStatus status;
    private OffsetDateTime createdAt;

    private OffsetDateTime requestedStart;
    private String requestedTimeZone;
    private Integer durationHours;

    private Long expertId;
    private String expertName;
    private String expertAvatarUrl;

    private Long userId;
    private String userName;
    private String userEmail;
    private String userAvatarUrl;
}
