//
//  ExpertPublic.swift
//  trip-mind-mobile
//
//  Public expert profile shown to users
//

import Foundation

struct ExpertPublic: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let avatarUrl: String?
    let bio: String?
    let location: String?
    let languages: String?
    let experienceYears: Int?
    let pricePerHour: Double?
    let countryCode: String?
    let timeZone: String?
}
