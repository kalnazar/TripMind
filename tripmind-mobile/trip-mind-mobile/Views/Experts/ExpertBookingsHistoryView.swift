//
//  ExpertBookingsHistoryView.swift
//  trip-mind-mobile
//
//  User booking history for experts
//

import SwiftUI

struct ExpertBookingsHistoryView: View {
    @StateObject private var viewModel = ExpertBookingsHistoryViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: DesignSystem.spacing3) {
                        Text("Failed to load bookings")
                            .font(.system(size: DesignSystem.FontSize.lg.value, weight: .semibold))
                        Text(error)
                            .font(.system(size: DesignSystem.FontSize.sm.value))
                            .foregroundColor(DesignSystem.mutedForeground)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.bookings.isEmpty {
                    VStack(spacing: DesignSystem.spacing4) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 56))
                            .foregroundColor(DesignSystem.mutedForeground)
                        
                        Text("No Bookings Yet")
                            .font(.system(size: DesignSystem.FontSize.xl.value, weight: .semibold))
                            .foregroundColor(DesignSystem.foreground)
                        
                        Text("Your expert booking requests will show up here.")
                            .font(.system(size: DesignSystem.FontSize.base.value))
                            .foregroundColor(DesignSystem.mutedForeground)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.spacing4) {
                            ForEach(viewModel.bookings) { booking in
                                BookingCardView(booking: booking)
                            }
                        }
                        .padding(DesignSystem.spacing4)
                    }
                }
            }
            .navigationTitle("Expert Bookings")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.loadBookings()
            }
            .task {
                await viewModel.loadBookings()
            }
        }
    }
}

private struct BookingCardView: View {
    let booking: ExpertBooking
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing3) {
            HStack(spacing: DesignSystem.spacing3) {
                avatarView
                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.expertName ?? "Expert")
                        .font(.system(size: DesignSystem.FontSize.lg.value, weight: .semibold))
                        .foregroundColor(DesignSystem.foreground)
                    if let timeText = formatRequestedTime() {
                        Text(timeText)
                            .font(.system(size: DesignSystem.FontSize.sm.value))
                            .foregroundColor(DesignSystem.mutedForeground)
                    }
                }
                Spacer()
                statusPill
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
    
    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.muted)
                .frame(width: 46, height: 46)
            
            if let urlString = booking.expertAvatarUrl,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(_):
                        initialsView
                    case .empty:
                        ProgressView()
                    @unknown default:
                        initialsView
                    }
                }
                .frame(width: 46, height: 46)
                .clipShape(Circle())
            } else {
                initialsView
            }
        }
    }
    
    private var initialsView: some View {
        Text(initials(from: booking.expertName ?? "EX"))
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(DesignSystem.mutedForeground)
    }
    
    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ").map { String($0.prefix(1)) }
        return parts.prefix(2).joined().uppercased()
    }
    
    private var statusPill: some View {
        let status = booking.status.uppercased()
        let (bg, fg): (Color, Color) = {
            switch status {
            case "ACCEPTED":
                return (Color.green.opacity(0.15), Color.green)
            case "REJECTED":
                return (Color.red.opacity(0.15), Color.red)
            default:
                return (Color.orange.opacity(0.15), Color.orange)
            }
        }()
        
        return Text(status)
            .font(.system(size: DesignSystem.FontSize.xs.value, weight: .semibold))
            .foregroundColor(fg)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(bg)
            .clipShape(Capsule())
    }
    
    private func formatRequestedTime() -> String? {
        guard let start = booking.requestedStart else { return nil }
        let iso = ISO8601DateFormatter()
        guard let date = iso.date(from: start) else { return start }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        if let tz = resolvedTimeZone(identifier: booking.requestedTimeZone) {
            formatter.timeZone = tz
        }
        
        var suffix = ""
        if let duration = booking.durationHours {
            suffix = " (\(duration)h)"
        }
        
        return formatter.string(from: date) + suffix
    }
    
    private func resolvedTimeZone(identifier: String?) -> TimeZone? {
        guard let raw = identifier?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else {
            return nil
        }
        
        if let tz = TimeZone(identifier: raw) {
            return tz
        }
        
        let regex = try? NSRegularExpression(pattern: #"^(UTC|GMT)([+-])(\d{1,2})(?::?(\d{2}))?$"#, options: .caseInsensitive)
        let range = NSRange(location: 0, length: raw.utf16.count)
        if let match = regex?.firstMatch(in: raw, options: [], range: range) {
            let signRange = match.range(at: 2)
            let hoursRange = match.range(at: 3)
            let minutesRange = match.range(at: 4)
            
            let sign = (raw as NSString).substring(with: signRange)
            let hoursString = (raw as NSString).substring(with: hoursRange)
            let minutesString = minutesRange.location != NSNotFound
                ? (raw as NSString).substring(with: minutesRange)
                : "00"
            
            if let hours = Int(hoursString), let minutes = Int(minutesString) {
                let totalSeconds = (hours * 3600) + (minutes * 60)
                let offset = sign == "-" ? -totalSeconds : totalSeconds
                return TimeZone(secondsFromGMT: offset)
            }
        }
        
        return nil
    }
}

#Preview {
    ExpertBookingsHistoryView()
}
