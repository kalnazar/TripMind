//
//  WelcomeView.swift
//  trip-mind-mobile
//
//  Onboarding / welcome screen shown on first launch
//

import SwiftUI

struct WelcomeView: View {
    @Binding var shouldShowWelcome: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                AuthBackground()
                
                VStack(spacing: DesignSystem.spacing6) {
                    // App icon / hero
                    VStack(spacing: DesignSystem.spacing3) {
                        Image(systemName: "airplane.departure")
                            .font(.system(size: 72))
                            .foregroundColor(DesignSystem.primaryColor)

                        Text("Welcome to TripMind")
                            .font(.system(size: DesignSystem.FontSize.xl2.value, weight: .bold))
                            .foregroundColor(DesignSystem.foreground)

                        Text("Plan smarter trips with AI. Create personalized itineraries, save them, and explore with ease.")
                            .font(.system(size: DesignSystem.FontSize.base.value))
                            .foregroundColor(DesignSystem.mutedForeground)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DesignSystem.spacing4)
                    }
                    .padding(.top, DesignSystem.spacing8)

                    // Features list (optional)
                    AuthCard {
                        VStack(alignment: .leading, spacing: DesignSystem.spacing3) {
                            FeatureRow(icon: "sparkles", title: "AI Trip Planning", subtitle: "Chat to build your perfect itinerary")
                            FeatureRow(icon: "list.bullet", title: "Save Itineraries", subtitle: "Keep and revisit your plans anytime")
                            FeatureRow(icon: "person.circle", title: "Profile", subtitle: "Manage your account and preferences")
                        }
                    }
                    .padding(.horizontal, DesignSystem.spacing4)

                    Spacer()

                    // Continue button
                    Button(action: { shouldShowWelcome = false }) {
                        Text("Continue")
                            .font(.system(size: DesignSystem.FontSize.base.value, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: DesignSystem.buttonHeightTouch)
                            .background(DesignSystem.primaryColor)
                            .foregroundColor(DesignSystem.primaryForeground)
                            .cornerRadius(DesignSystem.radiusMedium)
                    }
                    .padding(.horizontal, DesignSystem.spacing4)
                    .padding(.bottom, DesignSystem.spacing6)
                }
            }
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.spacing3) {
            Image(systemName: icon)
                .font(.system(size: DesignSystem.FontSize.base.value, weight: .semibold))
                .foregroundColor(DesignSystem.primaryColor)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: DesignSystem.spacing1) {
                Text(title)
                    .font(.system(size: DesignSystem.FontSize.base.value, weight: .semibold))
                    .foregroundColor(DesignSystem.foreground)

                Text(subtitle)
                    .font(.system(size: DesignSystem.FontSize.sm.value))
                    .foregroundColor(DesignSystem.mutedForeground)
            }
        }
    }
}

#Preview {
    WelcomeView(shouldShowWelcome: .constant(true))
}
