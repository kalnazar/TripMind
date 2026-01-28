//
//  ExpertsListViewModel.swift
//  trip-mind-mobile
//
//  View model for listing visible experts
//

import Foundation
import Combine

@MainActor
final class ExpertsListViewModel: ObservableObject {
    @Published var experts: [ExpertPublic] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    func loadExperts() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let result = try await apiClient.getPublicExperts()
            experts = result
        } catch {
            errorMessage = error.localizedDescription
            experts = []
        }
    }
}
