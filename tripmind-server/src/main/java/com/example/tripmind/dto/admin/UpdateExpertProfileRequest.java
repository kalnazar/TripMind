package com.example.tripmind.dto.admin;

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

    private String countryCode;

    private String timeZone;

    private Boolean isShown;
}
