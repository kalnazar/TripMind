package com.example.tripmind.dto.booking;

import com.example.tripmind.model.ExpertBookingStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class UpdateExpertBookingStatusRequest {
    @NotNull
    private ExpertBookingStatus status;
}
