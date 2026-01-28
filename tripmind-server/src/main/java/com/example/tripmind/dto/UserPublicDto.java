package com.example.tripmind.dto;

import com.example.tripmind.model.Role;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UserPublicDto {
    private Long id;
    private String email;
    private String name;
    private String avatarUrl;
    private Role role;
}

