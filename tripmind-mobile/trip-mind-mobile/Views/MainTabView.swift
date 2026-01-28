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
                PlanHomeView()
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
                ExpertsListView()
            }
            .tabItem {
                Label("Experts", systemImage: "person.3.fill")
            }
            .tag(2)
            
            NavigationStack {
                ProfileView()
                    .environmentObject(authManager)
            }
            .tabItem {
                Label("Profile", systemImage: "person.circle")
            }
            .tag(3)
        }
        .accentColor(DesignSystem.primaryColor)
    }
}
