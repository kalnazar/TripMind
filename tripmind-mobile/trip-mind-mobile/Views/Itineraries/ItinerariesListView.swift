//
//  ItinerariesListView.swift
//  trip-mind-mobile
//
//  List of saved itineraries
//

import SwiftUI

struct ItinerariesListView: View {
    @StateObject private var viewModel = ItinerariesListViewModel()
    @State private var selectedItinerary: Itinerary?
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.itineraries.isEmpty {
                    VStack(spacing: DesignSystem.spacing4) {
                        Image(systemName: "map")
                            .font(.system(size: 60))
                            .foregroundColor(DesignSystem.mutedForeground)
                        
                        Text("No Itineraries Yet")
                            .font(.system(size: DesignSystem.FontSize.xl.value, weight: .semibold))
                            .foregroundColor(DesignSystem.foreground)
                        
                        Text("Start planning your first trip!")
                            .font(.system(size: DesignSystem.FontSize.base.value))
                            .foregroundColor(DesignSystem.mutedForeground)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.spacing4) {
                            ForEach(viewModel.itineraries) { itinerary in
                                ItineraryCardView(itinerary: itinerary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .contentShape(Rectangle())
                                    .onTapGesture { selectedItinerary = itinerary }
                            }
                        }
                        .padding(.horizontal, DesignSystem.spacing4)
                        .padding(.vertical, DesignSystem.spacing4)
                    }
                }
            }
            .navigationTitle("My Itineraries")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.loadItineraries()
            }
            .navigationDestination(item: $selectedItinerary) { itinerary in
                ItineraryDetailView(itinerary: itinerary)
            }
            .onAppear {
                // Load itineraries when view appears
                print("[ItinerariesListView] onAppear called")
                print("[ItinerariesListView] viewModel.itineraries.count: \(viewModel.itineraries.count)")
                print("[ItinerariesListView] isLoading: \(viewModel.isLoading)")
                
                Task {
                    print("[ItinerariesListView] Calling viewModel.loadItineraries()")
                    await viewModel.loadItineraries()
                    print("[ItinerariesListView] viewModel.loadItineraries() completed")
                    print("[ItinerariesListView] Final itineraries count: \(viewModel.itineraries.count)")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ItinerariesListView()
    }
}
