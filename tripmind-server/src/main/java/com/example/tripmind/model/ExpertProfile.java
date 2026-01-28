package com.example.tripmind.model;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

@Entity
@Table(name = "expert_profiles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExpertProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(columnDefinition = "text")
    private String bio;

    private String location;

    private String languages;

    @Column(name = "experience_years")
    private Integer experienceYears;

    @Column(name = "price_per_hour")
    private BigDecimal pricePerHour;

    @Column(name = "country_code")
    private String countryCode;

    @Column(name = "time_zone")
    private String timeZone;

    @Column(name = "is_shown")
    private Boolean isShown;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = OffsetDateTime.now();
        updatedAt = OffsetDateTime.now();
        if (isShown == null) {
            isShown = false;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = OffsetDateTime.now();
        if (isShown == null) {
            isShown = false;
        }
    }
}
