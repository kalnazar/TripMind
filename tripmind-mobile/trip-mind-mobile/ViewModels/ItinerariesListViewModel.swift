//
//  ItinerariesListViewModel.swift
//  trip-mind-mobile
//
//  View model for listing user itineraries
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ItinerariesListViewModel: ObservableObject {
    @Published var itineraries: [Itinerary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Add these summary properties:
    @Published var itineraryCount: Int = 0
    @Published var lastTripTitle: String?
    @Published var lastTripDateString: String?

    private let apiClient = APIClient.shared

    func loadItineraries() async {
        print("[ItinerariesListViewModel.loadItineraries] Called")
        guard !isLoading else {
            print("[ItinerariesListViewModel.loadItineraries] Already loading, returning")
            return
        }
        isLoading = true
        print("[ItinerariesListViewModel.loadItineraries] Set isLoading to true")
        errorMessage = nil
        defer {
            print("[ItinerariesListViewModel.loadItineraries] Defer called, setting isLoading to false")
            isLoading = false
        }

        do {
            // 1) Fetch summaries
            print("[ItinerariesListViewModel.loadItineraries] About to call apiClient.getItinerariesSummary()")
            let summaries = try await apiClient.getItinerariesSummary()
            print("[ItinerariesListViewModel] Fetched \(summaries.count) summaries")
            print("[ItinerariesListViewModel] Summaries: \(summaries)")
            
            guard !summaries.isEmpty else {
                print("[ItinerariesListViewModel] No summaries returned - empty array")
                itineraries = []
                print("[ItinerariesListViewModel] Set itineraries to empty array")
                return
            }
            print("[ItinerariesListViewModel] Summaries not empty, proceeding to fetch details")

            // 2) Fetch details in parallel
            let details = try await withThrowingTaskGroup(of: Itinerary.self) { group -> [Itinerary] in
                for s in summaries {
                    group.addTask { [apiClient] in
                        do {
                            let itinerary = try await apiClient.getItinerary(id: s.id)
                            print("[ItinerariesListViewModel] Fetched itinerary: \(itinerary.title)")
                            return itinerary
                        } catch {
                            print("[ItinerariesListViewModel] Failed to fetch itinerary \(s.id): \(error)")
                            throw error
                        }
                    }
                }
                var collected: [Itinerary] = []
                for try await item in group {
                    collected.append(item)
                }
                return collected
            }

            print("[ItinerariesListViewModel] Successfully fetched \(details.count) itinerary details")
            print("[ItinerariesListViewModel] Details: \(details)")
            
            // 3) Sort by createdAt desc if available
            let iso = ISO8601DateFormatter()
            itineraries = details.sorted { lhs, rhs in
                let l = iso.date(from: lhs.createdAt) ?? .distantPast
                let r = iso.date(from: rhs.createdAt) ?? .distantPast
                return l > r
            }
            
            print("[ItinerariesListViewModel] Final itineraries count: \(itineraries.count)")
            print("[ItinerariesListViewModel] itineraries array updated: \(itineraries)")
            print("[ItinerariesListViewModel] isLoading will be set to false by defer")
        } catch {
            errorMessage = error.localizedDescription
            print("[ItinerariesListViewModel] CATCH BLOCK - Failed to load itineraries")
            print("[ItinerariesListViewModel] Error: \(error)")
            print("[ItinerariesListViewModel] Error localizedDescription: \(error.localizedDescription)")
            print("[ItinerariesListViewModel] Error full description: \(String(describing: error))")
            print("[ItinerariesListViewModel] Setting itineraries to empty array")
            itineraries = []
        }
    }
}

