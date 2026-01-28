package com.example.tripmind.dto.expert;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
public class ExpertPublicDto {
    private Long id;
    private String name;
    private String avatarUrl;
    private String bio;
    private String location;
    private String languages;
    private Integer experienceYears;
    private BigDecimal pricePerHour;
    private String countryCode;
    private String timeZone;
}
