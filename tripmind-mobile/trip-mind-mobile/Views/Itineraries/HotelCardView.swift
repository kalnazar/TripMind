//
//  HotelCardView.swift
//  trip-mind-mobile
//
//  Hotel card component
//

import SwiftUI

struct HotelCardView: View {
    let hotel: Hotel
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing3) {
            // Hotel image - prioritize hotelImageUrl
            let imageUrl = hotel.hotelImageUrl ?? (hotel.images?.first ?? nil)
            
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
                .frame(height: 200)
                .clipped()
                .cornerRadius(DesignSystem.radiusLarge)
            } else {
                Rectangle()
                    .fill(DesignSystem.muted)
                    .frame(height: 200)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(DesignSystem.mutedForeground)
                    }
                    .cornerRadius(DesignSystem.radiusLarge)
            }
            
            // Hotel info
            VStack(alignment: .leading, spacing: DesignSystem.spacing2) {
                Text(hotel.hotelName)
                    .font(.system(size: DesignSystem.FontSize.lg.value, weight: .semibold))
                    .foregroundColor(DesignSystem.foreground)
                
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                    
                    Text(hotel.hotelAddress)
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                }
                
                HStack(spacing: DesignSystem.spacing4) {
                    if let rating = hotel.rating {
                        HStack(spacing: DesignSystem.spacing1) {
                            Image(systemName: "star.fill")
                                .font(.system(size: DesignSystem.FontSize.sm.value))
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.system(size: DesignSystem.FontSize.sm.value))
                                .foregroundColor(DesignSystem.foreground)
                        }
                    }
                    
                    Text(hotel.pricePerNight)
                        .font(.system(size: DesignSystem.FontSize.sm.value, weight: .medium))
                        .foregroundColor(DesignSystem.primaryColor)
                }
                
                if let hotelType = hotel.hotelType {
                    Text(hotelType)
                        .font(.system(size: DesignSystem.FontSize.xs.value))
                        .padding(.horizontal, DesignSystem.spacing2)
                        .padding(.vertical, DesignSystem.spacing1)
                        .background(DesignSystem.muted)
                        .foregroundColor(DesignSystem.foreground)
                        .cornerRadius(DesignSystem.radiusFull)
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
