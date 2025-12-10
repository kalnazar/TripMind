import Foundation
import SwiftUI
import Combine

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared

    init() {
        Task { await checkAuthStatus() }
    }

    func checkAuthStatus() async {
        isLoading = true
        defer { isLoading = false }

        guard let token = KeychainService.getToken(), !token.isEmpty else {
            isAuthenticated = false
            currentUser = nil
            return
        }

        do {
            let response = try await apiClient.getCurrentUser()

            if let user = response.user {
                currentUser = user
                isAuthenticated = true
            } else if response.isAuthenticated {
                isAuthenticated = true
            } else {
                _ = KeychainService.deleteToken()
                currentUser = nil
                isAuthenticated = false
            }
        } catch {
            _ = KeychainService.deleteToken()
            currentUser = nil
            isAuthenticated = false
        }
    }

    func login(email: String, password: String) async throws {
        errorMessage = nil

        do {
            let response = try await apiClient.login(email: email, password: password)

            guard let token = response.resolvedToken, !token.isEmpty else {
                throw AuthError.message("Login failed: no token in response")
            }

            guard KeychainService.saveToken(token) else {
                throw AuthError.message("Failed to save token")
            }

            do {
                let me = try await apiClient.getCurrentUser()
                currentUser = me.user ?? response.user
                isAuthenticated = true
            } catch {
                currentUser = response.user
                isAuthenticated = true
            }

        } catch let apiError as APIError {
            switch apiError {
            case .serverError(let msg):
                throw AuthError.message(String(describing: msg))
            case .unauthorized:
                throw AuthError.message("Incorrect email or password")
            default:
                throw AuthError.message(apiError.localizedDescription)
            }
        } catch {
            throw AuthError.message(error.localizedDescription)
        }
    }

    func register(name: String, email: String, password: String) async throws {
        errorMessage = nil

        do {
            let response = try await apiClient.register(email: email, password: password, name: name)

            guard let token = response.resolvedToken, !token.isEmpty else {
                throw AuthError.message("Registration failed: no token in response")
            }

            guard KeychainService.saveToken(token) else {
                throw AuthError.message("Failed to save token")
            }

            do {
                let me = try await apiClient.getCurrentUser()
                currentUser = me.user ?? response.user
                isAuthenticated = true
            } catch {
                currentUser = response.user
                isAuthenticated = true
            }

        } catch let apiError as APIError {
            switch apiError {
            case .serverError(let msg):
                throw AuthError.message(String(describing: msg))
            case .unauthorized:
                throw AuthError.message("Rejected")
            default:
                throw AuthError.message(apiError.localizedDescription)
            }
        } catch {
            throw AuthError.message(error.localizedDescription)
        }
    }

    func logout() async {
        _ = KeychainService.deleteToken()
        currentUser = nil
        isAuthenticated = false
    }
}

enum AuthError: LocalizedError {
    case message(String)

    var errorDescription: String? {
        switch self {
        case .message(let msg):
            return msg
        }
    }
}
