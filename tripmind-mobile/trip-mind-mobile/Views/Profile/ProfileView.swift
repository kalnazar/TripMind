//
//  ProfileView.swift
//  trip-mind-mobile
//
//  User profile screen
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State private var isLoggingOut = false
    @State private var isDeletingAccount = false
    @State private var showDeleteAccountAlert = false
    @State private var deleteAccountError: String?
    @State private var isLoadingSummary = false
    @State private var itineraryCount = 0
    @State private var lastTripTitle: String?
    @State private var lastTripDateString: String?
    
    private let apiClient = APIClient.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.spacing6) {
                // Header / Avatar / Basic info
                headerCard
                
                // Stats card
                statsCard
                
                // Account info card
                accountInfoCard
                
                // Actions card
                actionsCard
            }
            .padding(.vertical, DesignSystem.spacing4)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        // Pull to refresh: refresh user + summary
        .refreshable {
            await refreshProfile()
        }
        .task {
            await loadSummary()
        }
        .onAppear {
            print("[ProfileView] using AuthManager:", ObjectIdentifier(authManager),
                  "isAuthenticated:", authManager.isAuthenticated,
                  "user:", String(describing: authManager.currentUser))
        }
    }
    
    // MARK: - Subviews
    
    private var headerCard: some View {
        VStack(spacing: DesignSystem.spacing4) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [DesignSystem.primaryColor.opacity(0.15), DesignSystem.muted],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 110, height: 110)
                
                if let avatarUrl = authManager.currentUser?.avatarUrl,
                   let url = URL(string: avatarUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(DesignSystem.muted)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(DesignSystem.mutedForeground)
                            }
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(DesignSystem.muted)
                        .frame(width: 100, height: 100)
                        .overlay {
                            Text(initials(from: authManager.currentUser))
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundColor(DesignSystem.mutedForeground)
                        }
                }
            }
            
            Text(displayName(from: authManager.currentUser))
                .font(.system(size: DesignSystem.FontSize.xl.value, weight: .semibold))
                .foregroundColor(DesignSystem.foreground)
            
            if let email = authManager.currentUser?.email {
                Text(email)
                    .font(.system(size: DesignSystem.FontSize.base.value))
                    .foregroundColor(DesignSystem.mutedForeground)
            }
        }
        .padding(.top, DesignSystem.spacing8)
        .padding(.bottom, DesignSystem.spacing2)
    }
    
    private var statsCard: some View {
        VStack(spacing: 0) {
            HStack {
                statBlock(title: "Trips Planned", value: itineraryCount > 0 ? "\(itineraryCount)" : "—")
                Divider()
                    .frame(height: 44)
                    .background(DesignSystem.border)
                statBlock(title: "Last Trip", value: lastTripTitle ?? "—")
            }
            .padding(DesignSystem.spacing4)
            
            if let memberSince = authManager.currentUser?.createdAt {
                Divider()
                    .background(DesignSystem.border)
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(DesignSystem.mutedForeground)
                    Text("Member since \(formatDate(memberSince))")
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                    Spacer()
                }
                .padding([.horizontal, .bottom], DesignSystem.spacing4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.card)
        .cornerRadius(DesignSystem.radiusXLarge)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge)
                .stroke(DesignSystem.border, lineWidth: 1)
        )
        .padding(.horizontal, DesignSystem.spacing4)
        .overlay(alignment: .topTrailing) {
            if isLoadingSummary {
                ProgressView()
                    .padding()
            }
        }
    }
    
    private func statBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: DesignSystem.FontSize.xl.value, weight: .semibold))
                .foregroundColor(DesignSystem.foreground)
                .lineLimit(1)
            Text(title)
                .font(.system(size: DesignSystem.FontSize.sm.value))
                .foregroundColor(DesignSystem.mutedForeground)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var accountInfoCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing4) {
            if let user = authManager.currentUser {
                
                InfoRow(label: "Email", value: user.email)
                buttonsRow(copyValue: user.email, label: "Copy Email")
                
                if let createdAt = user.createdAt {
                    InfoRow(label: "Created", value: formatDate(createdAt))
                }
            } else {
                Text("No user data available")
                    .font(.system(size: DesignSystem.FontSize.sm.value))
                    .foregroundColor(DesignSystem.mutedForeground)
            }
        }
        .padding(DesignSystem.spacing4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.card)
        .cornerRadius(DesignSystem.radiusXLarge)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge)
                .stroke(DesignSystem.border, lineWidth: 1)
        )
        .padding(.horizontal, DesignSystem.spacing4)
    }
    
    private func buttonsRow(copyValue: String, label: String) -> some View {
        HStack(spacing: DesignSystem.spacing2) {
            Button {
                copyToClipboard(copyValue)
            } label: {
                Label(label, systemImage: "doc.on.doc")
                    .font(.system(size: DesignSystem.FontSize.sm.value, weight: .medium))
            }
            .buttonStyle(.bordered)
            
            Spacer()
        }
    }
    
    private var actionsCard: some View {
        VStack(spacing: DesignSystem.spacing3) {
            NavigationLink(destination: ExpertBookingsHistoryView()) {
                Text("Expert Bookings")
                    .font(.system(size: DesignSystem.FontSize.base.value, weight: .semibold))
                    .frame(maxWidth: .infinity)
            }
            .frame(height: DesignSystem.buttonHeightTouch)
            .background(DesignSystem.primaryColor)
            .foregroundColor(.white)
            .cornerRadius(DesignSystem.radiusMedium)

            Button(action: { showDeleteAccountAlert = true }) {
                if isDeletingAccount {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Delete Account")
                        .font(.system(size: DesignSystem.FontSize.base.value, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.buttonHeightTouch)
            .background(Color.red.opacity(0.9))
            .foregroundColor(.white)
            .cornerRadius(DesignSystem.radiusMedium)

            Button(action: handleLogout) {
                if isLoggingOut {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Logout")
                        .font(.system(size: DesignSystem.FontSize.base.value, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.buttonHeightTouch)
            .background(DesignSystem.destructive)
            .foregroundColor(.white)
            .cornerRadius(DesignSystem.radiusMedium)
            
            if let deleteAccountError = deleteAccountError {
                Text(deleteAccountError)
                    .font(.system(size: DesignSystem.FontSize.sm.value))
                    .foregroundColor(DesignSystem.destructive)
            }
        }
        .padding(.horizontal, DesignSystem.spacing4)
        .alert("Delete Account?", isPresented: $showDeleteAccountAlert) {
            Button("Delete", role: .destructive) {
                handleDeleteAccount()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete your account and itineraries.")
        }
    }
    
    // MARK: - Helpers
    
    private func initials(from user: User?) -> String {
        let source = user?.name?.trimmingCharacters(in: .whitespacesAndNewlines)
            ?? user?.email
            ?? "U"
        let parts = source.split(whereSeparator: { !$0.isLetter })
        let first = parts.first?.first.map(String.init) ?? "U"
        let second = parts.dropFirst().first?.first.map(String.init) ?? ""
        return (first + second).uppercased()
    }
    
    private func displayName(from user: User?) -> String {
        if let name = user?.name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name
        }
        return user?.email ?? "User"
    }
    
    private func formatDate(_ dateString: String) -> String {
        // Try ISO8601 first
        let iso = ISO8601DateFormatter()
        if let date = iso.date(from: dateString) {
            let display = DateFormatter()
            display.dateStyle = .medium
            return display.string(from: date)
        }
        // Fallback: return as-is
        return dateString
    }
    
    private func copyToClipboard(_ text: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = text
        #endif
    }
    
    private func handleLogout() {
        isLoggingOut = true
        Task {
            await authManager.logout()
            isLoggingOut = false
        }
    }

    private func handleDeleteAccount() {
        guard !isDeletingAccount else { return }
        isDeletingAccount = true
        deleteAccountError = nil
        Task {
            do {
                try await apiClient.deleteAccount()
                await authManager.logout()
            } catch {
                await MainActor.run {
                    deleteAccountError = error.localizedDescription
                    isDeletingAccount = false
                }
            }
        }
    }
    
    private func refreshProfile() async {
        async let auth: () = authManager.checkAuthStatus()
        async let summary: () = loadSummary()
        await auth
        await summary
    }
    
    private func loadSummary() async {
        guard !isLoadingSummary else { return }
        isLoadingSummary = true
        defer { isLoadingSummary = false }
        
        do {
            let summaries = try await apiClient.getItinerariesSummary()
            itineraryCount = summaries.count
            
            // Last trip by createdAt (desc)
            let iso = ISO8601DateFormatter()
            let latest = summaries
                .sorted { (lhs, rhs) -> Bool in
                    let l = lhs.createdAt.flatMap { iso.date(from: $0) } ?? .distantPast
                    let r = rhs.createdAt.flatMap { iso.date(from: $0) } ?? .distantPast
                    return l > r
                }
                .first
            
            lastTripTitle = latest?.title
            if let createdAt = latest?.createdAt {
                lastTripDateString = formatDate(createdAt)
            } else {
                lastTripDateString = nil
            }
        } catch {
            print("[ProfileView] Failed to load summary: \(error)")
        }
    }
    
    private func parseISO(_ string: String?) -> Date? {
        guard let string = string else { return nil }
        let iso = ISO8601DateFormatter()
        return iso.date(from: string)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}
