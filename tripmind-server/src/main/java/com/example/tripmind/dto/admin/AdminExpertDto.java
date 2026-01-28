package com.example.tripmind.dto.admin;

import com.example.tripmind.model.Role;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
public class AdminExpertDto {
    private Long id;
    private String email;
    private String name;
    private String avatarUrl;
    private Role role;
    private String bio;
    private String location;
    private String languages;
    private Integer experienceYears;
    private BigDecimal pricePerHour;
    private String countryCode;
    private String timeZone;
    private Boolean isShown;
}
