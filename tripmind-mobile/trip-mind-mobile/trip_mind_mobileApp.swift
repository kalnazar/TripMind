//
//  trip_mind_mobileApp.swift
//  trip-mind-mobile
//

import SwiftUI

@main
struct trip_mind_mobileApp: App {
    @StateObject private var authManager = AuthManager()
    @AppStorage("shouldShowWelcome") private var shouldShowWelcome: Bool = true

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if shouldShowWelcome {
                    NavigationStack {
                        WelcomeView(shouldShowWelcome: $shouldShowWelcome)
                    }
                } else if authManager.isAuthenticated {
                    MainTabView()
                        .environmentObject(authManager)
                } else {
                    NavigationStack {
                        LoginView()
                    }
                }
            }
            .environmentObject(authManager)
        }
    }
}
