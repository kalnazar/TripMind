package com.example.tripmind.dto.admin;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class CreateExpertRequest {
    @NotBlank
    private String name;

    @NotBlank
    @Email
    private String email;

    @NotBlank
    private String password;

    private String avatarUrl;

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
