//
//  MainTabView.swift
//  trip-mind-mobile
//
//  Main tab navigation
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                PlanView()
            }
            .tabItem {
                Label("Plan", systemImage: "sparkles")
            }
            .tag(0)
            
            NavigationStack {
                ItinerariesListView()
            }
            .tabItem {
                Label("Itineraries", systemImage: "list.bullet")
            }
            .tag(1)
            
            NavigationStack {
                ProfileView()
                    .environmentObject(authManager)
            }
            .tabItem {
                Label("Profile", systemImage: "person.circle")
            }
            .tag(2)
        }
        .accentColor(DesignSystem.primaryColor)
    }
}
