//
//  DayPlanCardView.swift
//  trip-mind-mobile
//
//  Day plan card component
//

import SwiftUI

struct DayPlanCardView: View {
    let dayPlan: DayPlan
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: onToggle) {
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.spacing1) {
                        Text("Day \(dayPlan.day)")
                            .font(.system(size: DesignSystem.FontSize.lg.value, weight: .semibold))
                            .foregroundColor(DesignSystem.foreground)
                        
                        Text(dayPlan.dayPlan)
                            .font(.system(size: DesignSystem.FontSize.base.value))
                            .foregroundColor(DesignSystem.mutedForeground)
                            .lineLimit(isExpanded ? nil : 2)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                }
                .padding(DesignSystem.spacing4)
            }
            .buttonStyle(.plain)
            
            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: DesignSystem.spacing4) {
                    if let bestTime = dayPlan.bestTimeToVisitDay {
                        HStack {
                            Image(systemName: "clock.fill")
                                .font(.system(size: DesignSystem.FontSize.sm.value))
                                .foregroundColor(DesignSystem.primaryColor)
                            Text("Best time: \(bestTime)")
                                .font(.system(size: DesignSystem.FontSize.sm.value))
                                .foregroundColor(DesignSystem.foreground)
                        }
                        .padding(.horizontal, DesignSystem.spacing4)
                    }
                    
                    ForEach(dayPlan.activities) { activity in
                        ActivityCardView(activity: activity)
                    }
                }
                .padding(.horizontal, DesignSystem.spacing4)
                .padding(.bottom, DesignSystem.spacing4)
            }
        }
        .background(DesignSystem.card)
        .cornerRadius(DesignSystem.radiusXLarge)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge)
                .stroke(DesignSystem.border, lineWidth: 1)
        )
    }
}

struct ActivityCardView: View {
    let activity: Activity
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing3) {
            ActivityImageView(imageUrl: activity.placeImageUrl ?? (activity.images?.first ?? nil))
            
            // Activity info
            VStack(alignment: .leading, spacing: DesignSystem.spacing2) {
                Text(activity.placeName)
                    .font(.system(size: DesignSystem.FontSize.base.value, weight: .semibold))
                    .foregroundColor(DesignSystem.foreground)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: DesignSystem.spacing2) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                    
                    Text(activity.placeAddress)
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                        .lineLimit(2)
                }
                
                if let details = activity.placeDetails {
                    Text(details)
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                        .lineLimit(3)
                }
                
                HStack(spacing: DesignSystem.spacing4) {
                    if let pricing = activity.ticketPricing {
                        Label(pricing, systemImage: "ticket.fill")
                            .font(.system(size: DesignSystem.FontSize.sm.value))
                            .foregroundColor(DesignSystem.foreground)
                    }
                    
                    if let time = activity.timeTravelEachLocation {
                        Label(time, systemImage: "clock.fill")
                            .font(.system(size: DesignSystem.FontSize.sm.value))
                            .foregroundColor(DesignSystem.foreground)
                    }
                    
                    if let bestTime = activity.bestTimeToVisit {
                        Label(bestTime, systemImage: "sun.max.fill")
                            .font(.system(size: DesignSystem.FontSize.sm.value))
                            .foregroundColor(DesignSystem.foreground)
                    }
                }
            }
        }
        .padding(DesignSystem.spacing4)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.radiusLarge, style: .continuous)
                .fill(DesignSystem.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.radiusLarge, style: .continuous)
                .stroke(DesignSystem.border, lineWidth: 1)
        )
        .shadow(color: DesignSystem.border.opacity(0.45), radius: 8, x: 0, y: 4)
        .frame(maxWidth: .infinity)
    }
}

private struct ActivityImageView: View {
    let imageUrl: String?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.radiusLarge, style: .continuous)
                    .fill(DesignSystem.muted)

                if let imageUrl, let url = URL.fromPossiblyUnescaped(imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: geo.size.width, height: geo.size.height)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                        case .failure:
                            Image(systemName: "wifi.exclamationmark")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(DesignSystem.mutedForeground)
                                .frame(width: geo.size.width, height: geo.size.height)
                        @unknown default:
                            Image(systemName: "photo")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(DesignSystem.mutedForeground)
                                .frame(width: geo.size.width, height: geo.size.height)
                        }
                    }
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(DesignSystem.mutedForeground)
                        .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.radiusLarge, style: .continuous))
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
    }
}
