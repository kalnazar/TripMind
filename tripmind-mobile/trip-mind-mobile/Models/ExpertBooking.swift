//
//  ExpertBooking.swift
//  trip-mind-mobile
//
//  Booking record for an expert request
//

import Foundation

struct ExpertBooking: Identifiable, Codable, Equatable {
    let id: Int
    let status: String
    let createdAt: String?
    let requestedStart: String?
    let requestedTimeZone: String?
    let durationHours: Int?
    let expertId: Int?
    let expertName: String?
    let expertAvatarUrl: String?
}
