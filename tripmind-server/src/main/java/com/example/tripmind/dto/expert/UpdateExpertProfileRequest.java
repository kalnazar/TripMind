package com.example.tripmind.dto.expert;

import jakarta.validation.constraints.PositiveOrZero;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class UpdateExpertProfileRequest {
    private String bio;
    private String location;
    private String languages;

    @PositiveOrZero
    private Integer experienceYears;

    @PositiveOrZero
    private BigDecimal pricePerHour;

    private String timeZone;
    private String countryCode;
}
