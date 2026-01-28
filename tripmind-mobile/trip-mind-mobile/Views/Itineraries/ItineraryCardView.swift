//
//  ItineraryCardView.swift
//  trip-mind-mobile
//
//  Itinerary card component
//

import SwiftUI

import SwiftUI

struct ItineraryCardView: View {
    let itinerary: Itinerary

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing3) {
            coverImage

            HStack(alignment: .top, spacing: DesignSystem.spacing3) {
                VStack(alignment: .leading, spacing: DesignSystem.spacing1) {
                    Text(itinerary.title)
                        .font(.system(size: DesignSystem.FontSize.lg.value, weight: .semibold))
                        .foregroundColor(DesignSystem.foreground)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let description = itinerary.description, !description.isEmpty {
                        Text(description)
                            .font(.system(size: DesignSystem.FontSize.sm.value))
                            .foregroundColor(DesignSystem.mutedForeground)
                            .lineLimit(2)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: DesignSystem.FontSize.sm.value, weight: .semibold))
                    .foregroundColor(DesignSystem.mutedForeground)
                    .padding(.top, 2)
            }

            // Trip details
            HStack(spacing: DesignSystem.spacing2) {
                TripMetaChip(text: itinerary.tripPlan.destination, systemImage: "mappin.circle.fill")
                TripMetaChip(text: "\(itinerary.tripPlan.durationDays) days", systemImage: "calendar")
                TripMetaChip(text: itinerary.tripPlan.groupSize, systemImage: "person.2.fill")
            }

            // Interests
            if !itinerary.tripPlan.interests.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignSystem.spacing2) {
                        ForEach(itinerary.tripPlan.interests, id: \.self) { interest in
                            Text(interest)
                                .font(.system(size: DesignSystem.FontSize.xs.value, weight: .medium))
                                .padding(.horizontal, DesignSystem.spacing2)
                                .padding(.vertical, DesignSystem.spacing1)
                                .background(DesignSystem.muted)
                                .foregroundColor(DesignSystem.mutedForeground)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(DesignSystem.spacing4)
        .frame(maxWidth: .infinity, alignment: .leading) // ✅ fill available width inside list padding
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge, style: .continuous)
                .fill(DesignSystem.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge, style: .continuous)
                .stroke(DesignSystem.border, lineWidth: 1)
        )
        .shadow(color: DesignSystem.border.opacity(0.55), radius: 10, x: 0, y: 6)
        .clipped()                 // ✅ contain any child overflow
        .frame(maxWidth: 420)      // ✅ optional: same cap you used elsewhere
    }

    private var coverImage: some View {
        ZStack(alignment: .bottomLeading) {
            if let urlString = coverImageURL,
               let url = URL.fromPossiblyUnescaped(urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(DesignSystem.muted)
                            .overlay { ProgressView() }
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        fallbackImage
                    @unknown default:
                        fallbackImage
                    }
                }
            } else {
                fallbackImage
            }

            LinearGradient(
                colors: [Color.black.opacity(0.55), Color.clear],
                startPoint: .bottom,
                endPoint: .center
            )

            Text(itinerary.tripPlan.destination.isEmpty ? "Trip" : itinerary.tripPlan.destination)
                .font(.system(size: DesignSystem.FontSize.base.value, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, DesignSystem.spacing3)
                .padding(.bottom, DesignSystem.spacing3)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .clipped() // ✅ important: clips overlay too
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge, style: .continuous))
    }


    private var fallbackImage: some View {
        LinearGradient(
            colors: [DesignSystem.primaryColor.opacity(0.6), DesignSystem.muted],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Image(systemName: "photo")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
        )
    }

    private var coverImageURL: String? {
        if let firstDay = itinerary.tripPlan.itinerary.sorted(by: { $0.day < $1.day }).first {
            if let first = firstDay.activities.compactMap({ $0.placeImageUrl }).first(where: { !$0.isEmpty }) {
                return first
            }
            if let firstImage = firstDay.activities.compactMap({ $0.images?.first }).first(where: { !$0.isEmpty }) {
                return firstImage
            }
        }

        for day in itinerary.tripPlan.itinerary.sorted(by: { $0.day < $1.day }) {
            if let img = day.activities.compactMap({ $0.placeImageUrl }).first(where: { !$0.isEmpty }) {
                return img
            }
            if let img = day.activities.compactMap({ $0.images?.first }).first(where: { !$0.isEmpty }) {
                return img
            }
        }

        if let hotel = itinerary.tripPlan.hotels.first,
           let url = hotel.hotelImageUrl, !url.isEmpty {
            return url
        }

        return nil
    }
}


private struct TripMetaChip: View {
    let text: String
    let systemImage: String
    
    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.system(size: DesignSystem.FontSize.xs.value, weight: .medium))
            .foregroundColor(DesignSystem.mutedForeground)
            .padding(.horizontal, DesignSystem.spacing2)
            .padding(.vertical, DesignSystem.spacing1)
            .background(DesignSystem.muted)
            .clipShape(Capsule())
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
