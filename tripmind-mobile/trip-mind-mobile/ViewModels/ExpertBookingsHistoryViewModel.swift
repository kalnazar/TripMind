//
//  ExpertBookingsHistoryViewModel.swift
//  trip-mind-mobile
//
//  View model for user's expert bookings history
//

import Foundation
import Combine

@MainActor
final class ExpertBookingsHistoryViewModel: ObservableObject {
    @Published var bookings: [ExpertBooking] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    func loadBookings() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let result = try await apiClient.getMyExpertBookings()
            bookings = result
        } catch {
            errorMessage = error.localizedDescription
            bookings = []
        }
    }
}
