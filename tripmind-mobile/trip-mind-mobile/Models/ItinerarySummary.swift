// ItinerarySummary.swift
// trip-mind-mobile
//
// Summary model returned by GET /api/itineraries

import Foundation

struct ItinerarySummary: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let createdAt: String?
    let updatedAt: String?
}
