package com.example.tripmind.dto.admin;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AdminDashboardDto {
    private long users;
    private long experts;
    private long trips;
    private long itineraries;
}

