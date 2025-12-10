//
//  ChatViewModel.swift
//  trip-mind-mobile
//
//  Chat view model for AI planning
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var generatedTripPlan: TripPlan?
    @Published var showItineraryPreview = false
    @Published var saveStatusMessage: String?
    @Published var showSaveAlert = false
    
    private let apiClient = APIClient.shared
    private var collectedAnswers: [String: String] = [:]

    private func lastAssistantMeta() -> ChatMeta? {
        for msg in messages.reversed() {
            if msg.role == .assistant, let meta = msg.meta {
                return meta
            }
        }
        return nil
    }

    func leaveChat() {
        print("[ChatViewModel.leaveChat] Clearing conversation state")
        messages.removeAll()
        isLoading = false
        generatedTripPlan = nil
        collectedAnswers.removeAll()
        showItineraryPreview = false
        saveStatusMessage = nil
        showSaveAlert = false
    }

    func saveGeneratedTrip() async {
        guard let tripPlan = generatedTripPlan else {
            print("[ChatViewModel.saveGeneratedTrip] No generated trip to save")
            saveStatusMessage = "No trip to save"
            showSaveAlert = true
            return
        }

        // Create a title from origin/destination if available
        let title = "Planned: \(tripPlan.origin.isEmpty ? "Trip" : tripPlan.origin) → \(tripPlan.destination.isEmpty ? "Trip" : tripPlan.destination)"

        let request = SaveItineraryRequest(title: title, tripPlan: tripPlan)
        do {
            print("[ChatViewModel.saveGeneratedTrip] Sending save request for title: \(title)")
            let response = try await apiClient.saveItinerary(request)
            print("[ChatViewModel.saveGeneratedTrip] Save success: \(response.message), id=\(response.id)")
            saveStatusMessage = "Saved itinerary (id: \(response.id))"
            showSaveAlert = true
        } catch {
            print("[ChatViewModel.saveGeneratedTrip] Error saving itinerary: \(error)")
            saveStatusMessage = "Failed to save itinerary: \(error.localizedDescription)"
            showSaveAlert = true
        }
    }

    // Save offered trip summary as a simple itinerary (fallback when no structured TripPlan)
    func saveOfferedTrip(summary: String) async {
        // Try to build a minimal TripPlan from collected answers
        let origin = collectedAnswers["source"] ?? collectedAnswers["origin"] ?? ""
        let destination = collectedAnswers["destination"] ?? ""
        let durationStr = collectedAnswers["tripDuration"] ?? collectedAnswers["duration"] ?? "0"
        let duration = Int(durationStr) ?? 0
        let groupSize = collectedAnswers["groupSize"] ?? collectedAnswers["group_size"] ?? ""
        let budget = collectedAnswers["budget"] ?? ""
        let interestsStr = collectedAnswers["interests"] ?? ""
        let interests = interestsStr.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        let specialReq = collectedAnswers["specialReq"] ?? collectedAnswers["special_req"]

        let tripPlan = TripPlan(
            origin: origin,
            destination: destination,
            durationDays: duration,
            groupSize: groupSize, budget: budget,
            interests: interests,
            specialRequirements: specialReq,
            hotels: [],
            itinerary: []
        )

        let title = "Offered: \(origin.isEmpty ? "Trip" : origin) → \(destination.isEmpty ? "Trip" : destination)"
        let request = SaveItineraryRequest(title: title, tripPlan: tripPlan)

        do {
            print("[ChatViewModel.saveOfferedTrip] Saving offered trip with title: \(title)")
            let response = try await apiClient.saveItinerary(request)
            print("[ChatViewModel.saveOfferedTrip] Saved offered itinerary id=\(response.id)")
            saveStatusMessage = "Saved itinerary (id: \(response.id))"
            showSaveAlert = true
        } catch {
            print("[ChatViewModel.saveOfferedTrip] Error saving offered itinerary: \(error)")
            saveStatusMessage = "Failed to save itinerary: \(error.localizedDescription)"
            showSaveAlert = true
        }
    }
    
    func startConversation() async {
        print("[ChatViewModel.startConversation] Starting conversation")
        let initialMessage = ChatMessage(
            role: .user,
            content: "I want to plan a trip"
        )
        messages.append(initialMessage)
        await sendMessage("I want to plan a trip")
    }
    
    func sendMessage(_ text: String) async {
        print("[ChatViewModel.sendMessage] Sending message: \(text)")
        isLoading = true
        print("[ChatViewModel.sendMessage] Set isLoading to true")
        defer {
            print("[ChatViewModel.sendMessage] Defer block: setting isLoading to false")
            isLoading = false
        }
        // If the assistant asked a question just before the user's message, store the typed answer
        if let meta = lastAssistantMeta() {
            print("[ChatViewModel.sendMessage] Storing typed answer for key: \(meta.ui) = \(text)")
            collectedAnswers[meta.ui] = text
        }
        do {
            print("[ChatViewModel.sendMessage] Current messages count: \(messages.count)")
            print("[ChatViewModel.sendMessage] About to call apiClient.sendChatMessage")
            
            let response = try await apiClient.sendChatMessage(messages: messages)
            print("[ChatViewModel.sendMessage] Received response: \(response.content)")
            
            let assistantMessage = ChatMessage(
                role: .assistant,
                content: response.content,
                meta: response.meta
            )
            messages.append(assistantMessage)
            print("[ChatViewModel.sendMessage] Message appended to array")
            
            let meta = response.meta
            print("[ChatViewModel.sendMessage] Meta UI: \(meta.ui)")
            if meta.ui == "final" {
                print("[ChatViewModel.sendMessage] Final step reached")
                if let tripPlan = meta.tripPlan {
                    print("[ChatViewModel.sendMessage] Trip plan received from AI")
                    generatedTripPlan = tripPlan
                    showItineraryPreview = true
                } else {
                    print("[ChatViewModel.sendMessage] No trip plan in response, generating from answers")
                    await generateItineraryFromAnswers()
                }
            }
            print("[ChatViewModel.sendMessage] Function ending normally")
        } catch {
            print("[ChatViewModel.sendMessage] Error: \(error)")
            print("[ChatViewModel.sendMessage] Error type: \(type(of: error))")
            let errorMessage = ChatMessage(
                role: .assistant,
                content: "Sorry, I encountered an error: \(error.localizedDescription). Please check if the backend is running."
            )
            messages.append(errorMessage)
            print("[ChatViewModel.sendMessage] Error message appended")
        }
    }
    
    func selectOption(_ option: ChatOption) async {
        print("[ChatViewModel.selectOption] Selected option: \(option.label) = \(option.value)")
        // Find the last assistant meta to determine which question this option answers
        if let meta = lastAssistantMeta() {
            print("[ChatViewModel.selectOption] Storing answer for key: \(meta.ui) = \(option.value)")
            collectedAnswers[meta.ui] = option.value
        } else {
            print("[ChatViewModel.selectOption] Warning: couldn't find assistant meta to store option")
        }
        
        let userMessage = ChatMessage(
            role: .user,
            content: option.label
        )
        messages.append(userMessage)
        
        await sendMessage(option.value)
    }
    
    private func parseInt(from text: String) -> Int? {
        let scanner = Scanner(string: text)
        var value: Int = 0
        if scanner.scanInt(&value) {
            return value
        }
        return nil
    }
    
    func generateItineraryFromAnswers() async {
        print("[ChatViewModel.generateItineraryFromAnswers] Collected answers: \(collectedAnswers)")
        
        // Нормализуем ключи (ui из meta) к ожидаемым полям
        func value(_ keys: [String]) -> String? {
            for k in keys {
                if let v = collectedAnswers[k], !v.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return v.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            return nil
        }

        guard let source = value(["origin", "source", "from"]),
              let destination = value(["destination", "to"]),
              let groupSize = value(["groupSize", "group_size", "group"]),
              let budget = value(["budget"]),
              let durationRaw = value(["duration", "tripDuration", "duration_days", "tripDurationDays"]),
              let duration = parseInt(from: durationRaw) else {
            print("[ChatViewModel.generateItineraryFromAnswers] Missing required core answers: \(collectedAnswers)")
            return
        }
        
        // interests делаем НЕ обязательными
        let interestsStr = value(["interests"])
        let interests: [String]
        if let interestsStr, !interestsStr.isEmpty {
            interests = interestsStr
                .split(separator: ",")
                .map { String($0.trimmingCharacters(in: .whitespaces)) }
        } else {
            interests = []
        }
        
        // special requirements — опционально, с разными ключами
        let specialReq = value(["specialReq", "special_req", "specialRequirements"])
        
        print("[ChatViewModel.generateItineraryFromAnswers] Generating itinerary with: source=\(source), destination=\(destination), duration=\(duration), groupSize=\(groupSize), budget=\(budget), interests=\(interests)")
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await apiClient.generateItinerary(
                source: source,
                destination: destination,
                groupSize: groupSize,
                budget: budget,
                tripDurationDays: duration,
                interests: interests,
                specialReq: specialReq
            )
            print("[ChatViewModel.generateItineraryFromAnswers] Successfully generated itinerary")
            generatedTripPlan = response.tripPlan
            showItineraryPreview = true
        } catch {
            print("[ChatViewModel.generateItineraryFromAnswers] Error generating itinerary: \(error)")
            let errorMessage = ChatMessage(
                role: .assistant,
                content: "Sorry, I couldn't generate your itinerary: \(error.localizedDescription)"
            )
            messages.append(errorMessage)
        }
    }
}

