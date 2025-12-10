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
                .padding(.bottom, DesignSystem.spacing4)
            }
        }
        .background(DesignSystem.card)
        .cornerRadius(DesignSystem.radiusXLarge)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge)
                .stroke(DesignSystem.border, lineWidth: 1)
        )
        .padding(.horizontal, DesignSystem.spacing4)
    }
}

struct ActivityCardView: View {
    let activity: Activity
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing3) {
            // Activity image - prioritize placeImageUrl
            let imageUrl = activity.placeImageUrl ?? (activity.images?.first ?? nil)
            
            if let imageUrl = imageUrl, !imageUrl.isEmpty {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(DesignSystem.muted)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundColor(DesignSystem.mutedForeground)
                        }
                }
                .frame(height: 150)
                .clipped()
                .cornerRadius(DesignSystem.radiusLarge)
            }
            
            // Activity info
            VStack(alignment: .leading, spacing: DesignSystem.spacing2) {
                Text(activity.placeName)
                    .font(.system(size: DesignSystem.FontSize.base.value, weight: .semibold))
                    .foregroundColor(DesignSystem.foreground)
                
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                    
                    Text(activity.placeAddress)
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                }
                
                if let details = activity.placeDetails {
                    Text(details)
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.mutedForeground)
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
        .background(DesignSystem.muted.opacity(0.5))
        .cornerRadius(DesignSystem.radiusLarge)
        .padding(.horizontal, DesignSystem.spacing4)
    }
}
