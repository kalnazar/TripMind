package com.example.tripmind.dto.admin;

import com.example.tripmind.model.Role;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AdminUserSummaryDto {
    private Long id;
    private String email;
    private String name;
    private Role role;
    private Long itineraryCount;
}
