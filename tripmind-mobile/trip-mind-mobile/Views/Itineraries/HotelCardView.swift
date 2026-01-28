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
            HotelImageView(imageUrl: hotel.hotelImageUrl ?? hotel.images?.first)

            VStack(alignment: .leading, spacing: DesignSystem.spacing2) {
                Text(hotel.hotelName)
                    .font(.system(size: DesignSystem.FontSize.lg.value, weight: .semibold))
                    .foregroundColor(DesignSystem.foreground)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: DesignSystem.spacing2) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.mutedForeground)

                    Text(hotel.hotelAddress)
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                        .lineLimit(2)
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

                if let hotelType = hotel.hotelType, !hotelType.isEmpty {
                    Text(hotelType)
                        .font(.system(size: DesignSystem.FontSize.xs.value, weight: .medium))
                        .padding(.horizontal, DesignSystem.spacing2)
                        .padding(.vertical, DesignSystem.spacing1)
                        .background(DesignSystem.muted)
                        .foregroundColor(DesignSystem.foreground)
                        .clipShape(Capsule())
                }
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
        .shadow(color: DesignSystem.border.opacity(0.5), radius: 10, x: 0, y: 6)
        .frame(maxWidth: 420)
    }
}


private struct HotelImageView: View {
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
        .frame(height: 200)
    }
}

