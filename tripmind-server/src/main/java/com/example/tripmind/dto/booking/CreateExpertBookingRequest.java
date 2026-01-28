package com.example.tripmind.dto.booking;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CreateExpertBookingRequest {
    @NotNull
    private Long expertId;

    @NotBlank
    private String date;

    @NotBlank
    private String time;
}
