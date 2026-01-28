package com.example.tripmind.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.OffsetDateTime;

@Entity
@Table(name = "expert_bookings")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExpertBooking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "expert_id", nullable = false)
    private User expert;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ExpertBookingStatus status;

    @Column(name = "requested_start")
    private OffsetDateTime requestedStart;

    @Column(name = "requested_time_zone")
    private String requestedTimeZone;

    @Column(name = "duration_hours")
    private Integer durationHours;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = OffsetDateTime.now();
        updatedAt = OffsetDateTime.now();
        if (status == null) {
            status = ExpertBookingStatus.PENDING;
        }
        if (durationHours == null) {
            durationHours = 4;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = OffsetDateTime.now();
        if (status == null) {
            status = ExpertBookingStatus.PENDING;
        }
        if (durationHours == null) {
            durationHours = 4;
        }
    }
}
