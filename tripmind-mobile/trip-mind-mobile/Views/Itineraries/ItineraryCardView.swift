//
//  ItineraryCardView.swift
//  trip-mind-mobile
//
//  Itinerary card component
//

import SwiftUI

struct ItineraryCardView: View {
    let itinerary: Itinerary
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing3) {
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.spacing1) {
                    Text(itinerary.title)
                        .font(.system(size: DesignSystem.FontSize.lg.value, weight: .semibold))
                        .foregroundColor(DesignSystem.foreground)
                    
                    if let description = itinerary.description {
                        Text(description)
                            .font(.system(size: DesignSystem.FontSize.sm.value))
                            .foregroundColor(DesignSystem.mutedForeground)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: DesignSystem.FontSize.sm.value))
                    .foregroundColor(DesignSystem.mutedForeground)
            }
            
            // Trip details
            HStack(spacing: DesignSystem.spacing4) {
                Label(itinerary.tripPlan.destination, systemImage: "mappin.circle.fill")
                    .font(.system(size: DesignSystem.FontSize.sm.value))
                    .foregroundColor(DesignSystem.mutedForeground)
                
                Label("\(itinerary.tripPlan.durationDays) days", systemImage: "calendar")
                    .font(.system(size: DesignSystem.FontSize.sm.value))
                    .foregroundColor(DesignSystem.mutedForeground)
                
                Label(itinerary.tripPlan.groupSize, systemImage: "person.2.fill")
                    .font(.system(size: DesignSystem.FontSize.sm.value))
                    .foregroundColor(DesignSystem.mutedForeground)
            }
            
            // Interests
            if !itinerary.tripPlan.interests.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignSystem.spacing2) {
                        ForEach(itinerary.tripPlan.interests, id: \.self) { interest in
                            Text(interest)
                                .font(.system(size: DesignSystem.FontSize.xs.value))
                                .padding(.horizontal, DesignSystem.spacing2)
                                .padding(.vertical, DesignSystem.spacing1)
                                .background(DesignSystem.muted)
                                .foregroundColor(DesignSystem.foreground)
                                .cornerRadius(DesignSystem.radiusFull)
                        }
                    }
                }
            }
        }
        .padding(DesignSystem.spacing4)
        .background(DesignSystem.card)
        .cornerRadius(DesignSystem.radiusXLarge)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge)
                .stroke(DesignSystem.border, lineWidth: 1)
        )
    }
}

#Preview {
    let itineraryDataDict: [String: AnyCodable] = [
        "origin": AnyCodable("New York"),
        "destination": AnyCodable("Paris"),
        "duration_days": AnyCodable(7),
        "group_size": AnyCodable("Couple"),
        "budget": AnyCodable("Medium"),
        "interests": AnyCodable(["Cultural", "Food"]),
        "hotels": AnyCodable([]),
        "itinerary": AnyCodable([])
    ]

    return ItineraryCardView(itinerary: Itinerary(
        id: "1",
        userEmail: "test@example.com",
        tripId: nil,
        title: "Paris - 7 days",
        description: "Cultural, Food trip for 2",
        itineraryData: itineraryDataDict,
        createdAt: "2025-12-07T12:00:00Z",
        updatedAt: nil
    ))
    .padding()
}
