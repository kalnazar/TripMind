package com.example.tripmind.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.UuidGenerator;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "trips")
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Trip {

    @Id
    @UuidGenerator
    private UUID id;

    @Column(name = "user_email", nullable = false)
    private String userEmail;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private String origin;

    @Column(nullable = false)
    private String destination;

    @Column(name = "duration_days", nullable = false)
    private int durationDays;

    @Column(nullable = false)
    private String budget;

    @Column(name = "group_size", nullable = false)
    private String groupSize;

    private String interests;     // “Food, Cultural”
    @Column(name = "special_req")
    private String specialReq;

    @Column(name = "plan_json", columnDefinition = "jsonb") // use "TEXT" if not on Postgres
    private String planJson;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;
}
