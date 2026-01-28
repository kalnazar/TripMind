//
//  ItineraryDetailView.swift
//  trip-mind-mobile
//
//  Detailed itinerary view with day-by-day breakdown
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ItineraryDetailView: View {
    let itinerary: Itinerary
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: ItineraryTab = .information
    @State private var selectedDay: Int = 1
    @State private var isSaved: Bool = false
    @State private var showDeleteAlert = false
    @State private var isDeleting = false
    @State private var deleteError: String?
    
    private let apiClient = APIClient.shared
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                heroHeader

                VStack(spacing: 0) {
                    tabBar

                    Group {
                        switch selectedTab {
                        case .information:
                            informationTab
                        case .timeline:
                            timelineTab
                        case .hotels:
                            hotelsTab
                        }
                    }
                    .padding(.top, DesignSystem.spacing4)
                    .padding(.bottom, DesignSystem.spacing6)
                }
                .background(DesignSystem.background)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .offset(y: -28)
                .padding(.bottom, -28)
            }
        }
        .background(DesignSystem.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            // Default selected day: first day available
            if let first = itinerary.tripPlan.itinerary.first?.day {
                selectedDay = first
            }
        }
    }

    // MARK: - Header

    private var heroHeader: some View {
        let heroWidth = (UIScreen.current?.bounds.width ?? 0)
        return ZStack(alignment: .top) {
            HeroImage(urlString: heroImageURL)
                .frame(width: heroWidth, height: 320)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [Color.black.opacity(0.25), Color.black.opacity(0.15), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .overlay(
                    LinearGradient(
                        colors: [Color.black.opacity(0.55), Color.black.opacity(0.15), Color.clear],
                        startPoint: .bottom,
                        endPoint: .center
                    )
                )

            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.black.opacity(0.18))
                        .clipShape(Circle())
                }

                Spacer()
                
                Button(action: { showDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.black.opacity(0.18))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, DesignSystem.spacing4)
            .padding(.top, DesignSystem.spacing6)

            VStack(alignment: .leading, spacing: 8) {
                Spacer()

                Text(itinerary.title)
                    .font(.system(size: DesignSystem.FontSize.xl2.value, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)

                HStack(spacing: DesignSystem.spacing2) {
                    Label(itinerary.tripPlan.origin.isEmpty ? "Origin" : itinerary.tripPlan.origin, systemImage: "airplane.departure")
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    Label(itinerary.tripPlan.destination.isEmpty ? "Destination" : itinerary.tripPlan.destination, systemImage: "mappin.circle.fill")
                }
                .font(.system(size: DesignSystem.FontSize.sm.value, weight: .semibold))
                .foregroundColor(.white.opacity(0.92))

                HStack(spacing: DesignSystem.spacing3) {
                    MetaPill(text: "\(itinerary.tripPlan.durationDays) days", systemImage: "calendar")
                    MetaPill(text: itinerary.tripPlan.groupSize, systemImage: "person.2.fill")
                    MetaPill(text: itinerary.tripPlan.budget, systemImage: "creditcard")
                }
            }
            .padding(.horizontal, DesignSystem.spacing4)
            .padding(.bottom, 34)
            .frame(height: 320, alignment: .bottom)
        }
        .frame(width: heroWidth, height: 320)
        .clipped()
        .alert("Delete Itinerary?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteItinerary()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    // MARK: - Tabs

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(ItineraryTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 10) {
                        Text(tab.title)
                            .font(.system(size: DesignSystem.FontSize.base.value, weight: .semibold))
                            .foregroundColor(selectedTab == tab ? DesignSystem.primaryColor : DesignSystem.mutedForeground)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)

                        Capsule()
                            .fill(selectedTab == tab ? DesignSystem.primaryColor : Color.clear)
                            .frame(height: 2)
                            .padding(.horizontal, 18)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)                 // important: don’t let it size weirdly
        .padding(.horizontal, DesignSystem.spacing4) // inner padding
        .padding(.vertical, DesignSystem.spacing3)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(DesignSystem.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(DesignSystem.border, lineWidth: 1)
                )
        )
        .padding(.horizontal, DesignSystem.spacing4) // outer margin from screen edges
    }


    // MARK: - Information

    private var informationTab: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing4) {
            VStack(alignment: .leading, spacing: DesignSystem.spacing2) {
                Text("Information")
                    .font(.system(size: DesignSystem.FontSize.xl.value, weight: .bold))
                    .foregroundColor(DesignSystem.foreground)

                if let description = itinerary.description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: DesignSystem.FontSize.base.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                }
            }
            .padding(.horizontal, DesignSystem.spacing4)

            VStack(alignment: .leading, spacing: DesignSystem.spacing2) {
                InfoRow(label: "Origin", value: itinerary.tripPlan.origin)
                InfoRow(label: "Destination", value: itinerary.tripPlan.destination)
                InfoRow(label: "Duration", value: "\(itinerary.tripPlan.durationDays) days")
                InfoRow(label: "Group Size", value: itinerary.tripPlan.groupSize)
                InfoRow(label: "Budget", value: itinerary.tripPlan.budget)

                if let special = itinerary.tripPlan.specialRequirements, !special.isEmpty {
                    InfoRow(label: "Notes", value: special)
                }
            }
            .padding(DesignSystem.spacing4)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge, style: .continuous)
                    .fill(DesignSystem.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge, style: .continuous)
                    .stroke(DesignSystem.border, lineWidth: 1)
            )
            .padding(.horizontal, DesignSystem.spacing4)

            if !itinerary.tripPlan.interests.isEmpty {
                VStack(alignment: .leading, spacing: DesignSystem.spacing3) {
                    Text("Interests")
                        .font(.system(size: DesignSystem.FontSize.lg.value, weight: .semibold))
                        .foregroundColor(DesignSystem.foreground)

                    FlowPills(items: itinerary.tripPlan.interests)
                }
                .padding(.horizontal, DesignSystem.spacing4)
            }
        }
    }

    // MARK: - Timeline

    // MARK: - Timeline

    private var timelineTab: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing4) {
            Text("Timeline")
                .font(.system(size: DesignSystem.FontSize.xl.value, weight: .bold))
                .foregroundColor(DesignSystem.foreground)
                .padding(.horizontal, DesignSystem.spacing4)

            if itinerary.tripPlan.itinerary.isEmpty {
                Text("No timeline available yet.")
                    .font(.system(size: DesignSystem.FontSize.base.value))
                    .foregroundColor(DesignSystem.mutedForeground)
                    .padding(.horizontal, DesignSystem.spacing4)
            } else {
                ForEach(itinerary.tripPlan.itinerary) { day in
                    TimelineDaySection(day: day)
                        .padding(.horizontal, DesignSystem.spacing4)   // ✅ same as Hotels
                }
            }
        }
    }

    // MARK: - Hotels

    private var hotelsTab: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing4) {
            Text("Hotels")
                .font(.system(size: DesignSystem.FontSize.xl.value, weight: .bold))
                .foregroundColor(DesignSystem.foreground)
                .padding(.horizontal, DesignSystem.spacing4)

            if itinerary.tripPlan.hotels.isEmpty {
                Text("No hotels available yet.")
                    .font(.system(size: DesignSystem.FontSize.base.value))
                    .foregroundColor(DesignSystem.mutedForeground)
                    .padding(.horizontal, DesignSystem.spacing4)
            } else {
                ForEach(itinerary.tripPlan.hotels) { hotel in
                    HotelCardView(hotel: hotel)
                        .padding(.horizontal, DesignSystem.spacing4)
                }
            }
        }
    }

    // MARK: - Helpers

    private var heroImageURL: String? {
        // Prefer the first day activity image for a more "trip cover" feel
        if let firstDay = itinerary.tripPlan.itinerary.sorted(by: { $0.day < $1.day }).first {
            if let firstActivityImage = firstDay.activities.compactMap({ $0.placeImageUrl }).first(where: { !$0.isEmpty }) {
                return firstActivityImage
            }
        }

        // Fallback: any activity image
        for day in itinerary.tripPlan.itinerary.sorted(by: { $0.day < $1.day }) {
            if let img = day.activities.compactMap({ $0.placeImageUrl }).first(where: { !$0.isEmpty }) {
                return img
            }
        }

        // Last resort: hotel image
        if let hotel = itinerary.tripPlan.hotels.first,
           let url = hotel.hotelImageUrl, !url.isEmpty {
            return url
        }

        return nil
    }

    private func deleteItinerary() {
        guard !isDeleting else { return }
        isDeleting = true
        deleteError = nil
        
        Task {
            do {
                try await apiClient.deleteItinerary(id: itinerary.id)
                await MainActor.run {
                    isDeleting = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    deleteError = error.localizedDescription
                    isDeleting = false
                }
            }
        }
    }
}

private enum ItineraryTab: CaseIterable {
    case information
    case timeline
    case hotels

    var title: String {
        switch self {
        case .information: return "Information"
        case .timeline: return "Timeline"
        case .hotels: return "Hotels"
        }
    }
}

private struct MetaPill: View {
    let text: String
    let systemImage: String

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white.opacity(0.92))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.22))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
    }
}

private struct HeroImage: View {
    let urlString: String?

    var body: some View {
        if let urlString, let url = URL.fromPossiblyUnescaped(urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(DesignSystem.muted)
                        .overlay { ProgressView().tint(.white) }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .clipped()
                case .failure:
                    fallback
                @unknown default:
                    fallback
                }
            }
        } else {
            fallback
        }
    }

    private var fallback: some View {
        ZStack {
            LinearGradient(
                colors: [DesignSystem.primaryColor.opacity(0.55), DesignSystem.muted],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "photo")
                .font(.system(size: 36, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
        }
    }
}

private struct FlowPills: View {
    let items: [String]

    var body: some View {
        // Simple wrap using multiple lines via adaptive grid
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 10)], alignment: .leading, spacing: 10) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.system(size: DesignSystem.FontSize.sm.value, weight: .semibold))
                    .foregroundColor(DesignSystem.foreground)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(DesignSystem.card)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(DesignSystem.border, lineWidth: 1))
            }
        }
    }
}

private struct DayRail: View {
    let days: [Int]
    @Binding var selectedDay: Int

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(days.enumerated()), id: \.offset) { idx, day in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        selectedDay = day
                    }
                } label: {
                    HStack(spacing: 10) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(selectedDay == day ? DesignSystem.primaryColor : DesignSystem.border)
                                .frame(width: 10, height: 10)

                            if idx != days.count - 1 {
                                Rectangle()
                                    .fill(DesignSystem.border)
                                    .frame(width: 2, height: 46)
                                    .padding(.vertical, 6)
                            }
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Day \(day)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(selectedDay == day ? DesignSystem.foreground : DesignSystem.mutedForeground)
                        }
                        .frame(width: 64, alignment: .leading)
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct TimelineDaySection: View {
    let day: DayPlan

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing3) {
            HStack(alignment: .top, spacing: 10) {
                Text("Day \(day.day)")
                    .font(.system(size: DesignSystem.FontSize.lg.value, weight: .bold))
                    .foregroundColor(DesignSystem.foreground)

                Spacer()

                if let best = day.bestTimeToVisitDay, !best.isEmpty {
                    Label(best, systemImage: "clock")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(DesignSystem.mutedForeground)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(DesignSystem.muted)
                        .clipShape(Capsule())
                }
            }

            Text(day.dayPlan)
                .font(.system(size: DesignSystem.FontSize.base.value, weight: .medium))
                .foregroundColor(DesignSystem.mutedForeground)

            VStack(spacing: DesignSystem.spacing4) {
                ForEach(day.activities) { activity in
                    TimelineActivityCard(activity: activity)
                }
            }
        }
        .padding(DesignSystem.spacing4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge, style: .continuous)
                .fill(DesignSystem.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge, style: .continuous)
                .stroke(DesignSystem.border, lineWidth: 1)
        )
        .shadow(color: DesignSystem.border.opacity(0.25), radius: 10, x: 0, y: 6)
        .clipped()
    }
}


private struct TimelineActivityCard: View {
    let activity: Activity

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HeroImage(urlString: activity.placeImageUrl ?? activity.images?.first)
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(activity.placeName)
                    .font(.system(size: DesignSystem.FontSize.lg.value, weight: .bold))
                    .foregroundColor(DesignSystem.foreground)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(DesignSystem.mutedForeground)

                    Text(activity.placeAddress)
                        .font(.system(size: DesignSystem.FontSize.sm.value, weight: .medium))
                        .foregroundColor(DesignSystem.mutedForeground)
                        .lineLimit(2)
                }
            }
        }
        .padding(DesignSystem.spacing4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge, style: .continuous)
                .fill(DesignSystem.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge, style: .continuous)
                .stroke(DesignSystem.border, lineWidth: 1)
        )
        .shadow(color: DesignSystem.border.opacity(0.20), radius: 10, x: 0, y: 6)
        .clipped()
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
