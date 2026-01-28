//
//  APIClient.swift
//  trip-mind-mobile
//
//  API client for backend communication
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noToken
    case unauthorized
    case serverError(Int)
    case decodingError
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noToken: return "No authentication token"
        case .unauthorized: return "Unauthorized"
        case .serverError(let code): return "Server error: \(code)"
        case .decodingError: return "Failed to decode response"
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        }
    }
}

final class APIClient {
    static let shared = APIClient()
    
    private let isLoggingEnabled = true
    
    private let baseURLString: String
    private let session: URLSession
    
    private init(session: URLSession = .shared) {
        if let apiURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           !apiURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.baseURLString = apiURL.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            self.baseURLString = "http://127.0.0.1:8080"
        }
        self.session = session
        if isLoggingEnabled {
            print("API_BASE_URL at runtime =", baseURLString)
        }
    }
    
    // MARK: - Request Helpers
    
    private func makeRequest<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: baseURLString + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            guard let token = KeychainService.getToken() else {
                throw APIError.noToken
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw APIError.networkError(error)
            }
        }
        
        if isLoggingEnabled {
            print("Request:", method, url.absoluteString)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError(NSError(domain: "APIClient", code: -1))
            }
            
            if isLoggingEnabled {
                print("Response:", httpResponse.statusCode, url.absoluteString)
            }
            
            if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            }
            
            // 🔥 НОВЫЙ БЛОК ЛОГОВ ДЛЯ 4xx/5xx
            if httpResponse.statusCode >= 400 {
                if isLoggingEnabled {
                    if let bodyString = String(data: data, encoding: .utf8) {
                        print("[APIClient] Error \(httpResponse.statusCode) body for \(url.absoluteString):")
                        print(bodyString)
                    } else {
                        print("[APIClient] Error \(httpResponse.statusCode), cannot decode error body as UTF-8")
                    }
                }
                
                if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let msg = (dict["message"] as? String)
                        ?? (dict["detail"] as? String)
                        ?? (dict["error"] as? String)
                    if let msg = msg {
                        throw NSError(
                            domain: "APIClient",
                            code: httpResponse.statusCode,
                            userInfo: [NSLocalizedDescriptionKey: msg]
                        )
                    }
                }
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                if isLoggingEnabled {
                    print("Decoding error for", url.absoluteString, "data length:", data.count)
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("[Decoding Error] Raw JSON response:")
                        print(jsonString)
                    }
                    print("[Decoding Error] DecodingError details: \(error)")
                    if let decodingError = error as? DecodingError {
                        print("[Decoding Error] Details:")
                        switch decodingError {
                        case .dataCorrupted(let context):
                            print("- Data corrupted: \(context.debugDescription)")
                        case .keyNotFound(let key, let context):
                            print("- Key not found: \(key), path: \(context.codingPath)")
                        case .typeMismatch(let type, let context):
                            print("- Type mismatch: expected \(type), path: \(context.codingPath)")
                        case .valueNotFound(let type, let context):
                            print("- Value not found: expected \(type), path: \(context.codingPath)")
                        @unknown default:
                            print("- Unknown decoding error")
                        }
                    }
                }
                throw APIError.decodingError
            }
        } catch {
            if let apiError = error as? APIError { throw apiError }
            throw APIError.networkError(error)
        }
    }

    private func makeEmptyRequest(
        endpoint: String,
        method: String = "DELETE",
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws {
        guard let url = URL(string: baseURLString + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth {
            guard let token = KeychainService.getToken() else {
                throw APIError.noToken
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw APIError.networkError(error)
            }
        }

        if isLoggingEnabled {
            print("Request:", method, url.absoluteString)
        }

        do {
            let (_, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError(NSError(domain: "APIClient", code: -1))
            }

            if isLoggingEnabled {
                print("Response:", httpResponse.statusCode, url.absoluteString)
            }

            if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            }

            if httpResponse.statusCode >= 400 {
                throw APIError.serverError(httpResponse.statusCode)
            }
        } catch {
            if let apiError = error as? APIError { throw apiError }
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Authentication
    
    func register(email: String, password: String, name: String) async throws -> AuthResponse {
        struct RegisterRequest: Codable { let email, password, name: String }
        let request = RegisterRequest(email: email, password: password, name: name)
        let response: AuthResponse = try await makeRequest(
            endpoint: "/api/auth/register",
            method: "POST",
            body: request,
            requiresAuth: false
        )
        return response
    }
    
    func login(email: String, password: String) async throws -> AuthResponse {
        struct LoginRequest: Codable { let email, password: String }
        let request = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await makeRequest(
            endpoint: "/api/auth/login",
            method: "POST",
            body: request,
            requiresAuth: false
        )
        // Token will be saved by AuthManager after verifying success
        return response
    }
    
    func getCurrentUser() async throws -> AuthResponse {
        try await makeRequest(endpoint: "/api/users/me", requiresAuth: true)
    }
    
    // If your backend does not expose logout, you can remove this entirely
    func logoutCallIfAvailable() async throws {
        struct EmptyResponse: Codable {}
        let _: EmptyResponse = try await makeRequest(
            endpoint: "/api/auth/logout",
            method: "POST",
            requiresAuth: true
        )
    }
    
    // MARK: - AI Chat
    
    func sendChatMessage(messages: [ChatMessage]) async throws -> ChatResponse {
        print("[APIClient.sendChatMessage] Called with \(messages.count) messages")
        let request = ChatRequest(messages: messages)
        
        do {
            // Print the request details
            if let jsonData = try? JSONEncoder().encode(request),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("[APIClient.sendChatMessage] Request body: \(jsonString)")
            }
            
            print("[APIClient.sendChatMessage] About to make request to /api/ai")
            let response: ChatResponse = try await makeRequest(
                endpoint: "/api/ai",
                method: "POST",
                body: request,
                requiresAuth: true
            )
            print("[APIClient.sendChatMessage] Successfully received response: \(response.content)")
            return response
        } catch {
            print("[APIClient.sendChatMessage] Error: \(error)")
            print("[APIClient.sendChatMessage] Error description: \(String(describing: error))")
            throw error
        }
    }
    
    func generateItinerary(
        source: String,
        destination: String,
        groupSize: String,
        budget: String,
        tripDurationDays: Int,
        interests: [String],
        specialReq: String?
    ) async throws -> TripPlanResponse {
        struct ItineraryRequest: Codable {
            let source, destination, groupSize, budget: String
            let tripDurationDays: Int
            let interests: [String]
            var specialReq: String?
        }
        let request = ItineraryRequest(
            source: source,
            destination: destination,
            groupSize: groupSize,
            budget: budget,
            tripDurationDays: tripDurationDays,
            interests: interests,
            specialReq: specialReq
        )
        return try await makeRequest(
            endpoint: "/api/ai/itinerary",
            method: "POST",
            body: request,
            requiresAuth: true
        )
    }
    
    // MARK: - Itineraries
    
    func saveItinerary(_ itinerary: SaveItineraryRequest) async throws -> SaveItineraryResponse {
        if isLoggingEnabled {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(itinerary),
               let json = String(data: data, encoding: .utf8) {
                print("[APIClient.saveItinerary] Request body JSON:")
                print(json)
            }
        }

        return try await makeRequest(
            endpoint: "/api/itineraries",
            method: "POST",
            body: itinerary,
            requiresAuth: true
        )
    }
    
    // New: summaries from GET /api/itineraries
    func getItinerariesSummary() async throws -> [ItinerarySummary] {
        print("[APIClient.getItinerariesSummary] Called")
        do {
            let result: [ItinerarySummary] = try await makeRequest(endpoint: "/api/itineraries", requiresAuth: true)
            print("[APIClient.getItinerariesSummary] Success, returned \(result.count) summaries")
            return result
        } catch {
            print("[APIClient.getItinerariesSummary] Error: \(error)")
            throw error
        }
    }
    
    // Kept for detail by id
    func getItinerary(id: String) async throws -> Itinerary {
        print("[APIClient.getItinerary] Called with id: \(id)")
        do {
            let result: Itinerary = try await makeRequest(endpoint: "/api/itineraries/\(id)", requiresAuth: true)
            print("[APIClient.getItinerary] Success, returned itinerary: \(result.title)")
            return result
        } catch {
            print("[APIClient.getItinerary] Error: \(error)")
            throw error
        }
    }

    func deleteItinerary(id: String) async throws {
        try await makeEmptyRequest(
            endpoint: "/api/itineraries/\(id)",
            method: "DELETE",
            requiresAuth: true
        )
    }

    // MARK: - Experts

    func getPublicExperts() async throws -> [ExpertPublic] {
        let result: [ExpertPublic] = try await makeRequest(
            endpoint: "/api/public/experts",
            requiresAuth: false
        )
        return result
    }

    func createExpertBooking(expertId: Int, date: String, time: String) async throws -> ExpertBooking {
        struct BookingRequest: Codable {
            let expertId: Int
            let date: String
            let time: String
        }
        let request = BookingRequest(expertId: expertId, date: date, time: time)
        let result: ExpertBooking = try await makeRequest(
            endpoint: "/api/expert-bookings",
            method: "POST",
            body: request,
            requiresAuth: true
        )
        return result
    }
    
    func getMyExpertBookings() async throws -> [ExpertBooking] {
        let result: [ExpertBooking] = try await makeRequest(
            endpoint: "/api/expert-bookings",
            requiresAuth: true
        )
        return result
    }

    // MARK: - Account

    func deleteAccount() async throws {
        try await makeEmptyRequest(
            endpoint: "/api/users/me",
            method: "DELETE",
            requiresAuth: true
        )
    }
}
