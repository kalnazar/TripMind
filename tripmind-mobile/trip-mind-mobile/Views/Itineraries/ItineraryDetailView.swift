//
//  ItineraryDetailView.swift
//  trip-mind-mobile
//
//  Detailed itinerary view with day-by-day breakdown
//

import SwiftUI

struct ItineraryDetailView: View {
    let itinerary: Itinerary
    @State private var expandedDays: Set<Int> = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.spacing6) {
                // Header
                VStack(alignment: .leading, spacing: DesignSystem.spacing2) {
                    Text(itinerary.title)
                        .font(.system(size: DesignSystem.FontSize.xl2.value, weight: .bold))
                        .foregroundColor(DesignSystem.foreground)
                    
                    if let description = itinerary.description {
                        Text(description)
                            .font(.system(size: DesignSystem.FontSize.base.value))
                            .foregroundColor(DesignSystem.mutedForeground)
                    }
                    
                    // Trip metadata
                    VStack(alignment: .leading, spacing: DesignSystem.spacing2) {
                        InfoRow(label: "Origin", value: itinerary.tripPlan.origin)
                        InfoRow(label: "Destination", value: itinerary.tripPlan.destination)
                        InfoRow(label: "Duration", value: "\(itinerary.tripPlan.durationDays) days")
                        InfoRow(label: "Group Size", value: itinerary.tripPlan.groupSize)
                        InfoRow(label: "Budget", value: itinerary.tripPlan.budget)
                        
                        if !itinerary.tripPlan.interests.isEmpty {
                            HStack(alignment: .top) {
                                Text("Interests:")
                                    .font(.system(size: DesignSystem.FontSize.sm.value, weight: .medium))
                                    .foregroundColor(DesignSystem.mutedForeground)
                                    .frame(width: 100, alignment: .leading)
                                
                                Text(itinerary.tripPlan.interests.joined(separator: ", "))
                                    .font(.system(size: DesignSystem.FontSize.sm.value))
                                    .foregroundColor(DesignSystem.foreground)
                            }
                        }
                    }
                    .padding(.top, DesignSystem.spacing2)
                }
                .padding(DesignSystem.spacing4)
                .background(DesignSystem.card)
                .cornerRadius(DesignSystem.radiusXLarge)
                
                // Hotels
                if !itinerary.tripPlan.hotels.isEmpty {
                    VStack(alignment: .leading, spacing: DesignSystem.spacing4) {
                        Text("Hotels")
                            .font(.system(size: DesignSystem.FontSize.xl.value, weight: .semibold))
                            .foregroundColor(DesignSystem.foreground)
                        
                        ForEach(itinerary.tripPlan.hotels) { hotel in
                            HotelCardView(hotel: hotel)
                        }
                    }
                    .padding(.horizontal, DesignSystem.spacing4)
                }
                
                // Day-by-day itinerary
                VStack(alignment: .leading, spacing: DesignSystem.spacing4) {
                    Text("Itinerary")
                        .font(.system(size: DesignSystem.FontSize.xl.value, weight: .semibold))
                        .foregroundColor(DesignSystem.foreground)
                        .padding(.horizontal, DesignSystem.spacing4)
                    
                    ForEach(itinerary.tripPlan.itinerary) { dayPlan in
                        DayPlanCardView(
                            dayPlan: dayPlan,
                            isExpanded: expandedDays.contains(dayPlan.day)
                        ) {
                            if expandedDays.contains(dayPlan.day) {
                                expandedDays.remove(dayPlan.day)
                            } else {
                                expandedDays.insert(dayPlan.day)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, DesignSystem.spacing4)
        }
        .navigationTitle("Itinerary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text("\(label):")
                .font(.system(size: DesignSystem.FontSize.sm.value, weight: .medium))
                .foregroundColor(DesignSystem.mutedForeground)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.system(size: DesignSystem.FontSize.sm.value))
                .foregroundColor(DesignSystem.foreground)
        }
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
        
        return NavigationStack {
            ItineraryDetailView(itinerary: Itinerary(
                id: "1",
                userEmail: "test@example.com",
                tripId: nil,
                title: "Paris - 7 days",
                description: "Cultural, Food trip for 2",
                itineraryData: itineraryDataDict,
                createdAt: "2025-12-07T12:00:00Z",
                updatedAt: nil
            ))
        }
}
