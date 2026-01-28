import Foundation

struct TripPlan: Codable, Hashable {
    let origin: String
    let destination: String
    let durationDays: Int
    let groupSize: String
    let budget: String
    let interests: [String]
    var specialRequirements: String?
    let hotels: [Hotel]
    let itinerary: [DayPlan]
    
    init(
        origin: String,
        destination: String,
        durationDays: Int,
        groupSize: String,
        budget: String,
        interests: [String],
        specialRequirements: String? = nil,
        hotels: [Hotel],
        itinerary: [DayPlan]
    ) {
        self.origin = origin
        self.destination = destination
        self.durationDays = durationDays
        self.groupSize = groupSize
        self.budget = budget
        self.interests = interests
        self.specialRequirements = specialRequirements
        self.hotels = hotels
        self.itinerary = itinerary
    }
}

struct Hotel: Codable, Identifiable, Hashable {
    var id: String { hotelName }

    let hotelName: String        // hotel_name
    let hotelAddress: String     // hotel_address
    let pricePerNight: String    // price_per_night
    let rating: Double?
    let hotelType: String?
    let images: [String]?
    let hotelImageUrl: String?   // hotel_image_url
    let description: String?
    let geoCoordinates: GeoCoordinates?
}

struct GeoCoordinates: Codable, Hashable {
    let latitude: Double
    let longitude: Double
}

struct DayPlan: Codable, Identifiable, Hashable {
    var id: Int { day }

    let day: Int
    let dayPlan: String              // day_plan
    let bestTimeToVisitDay: String?  // best_time_to_visit_day
    let activities: [Activity]
}

struct Activity: Codable, Identifiable, Hashable {
    var id: String { placeName }

    let placeName: String            // place_name
    let placeAddress: String         // place_address
    let placeDetails: String?        // place_details
    let images: [String]?
    let ticketPricing: String?       // ticket_pricing
    let timeTravelEachLocation: String? // time_travel_each_location
    let bestTimeToVisit: String?     // best_time_to_visit
    let placeImageUrl: String?       // place_image_url
    let geoCoordinates: GeoCoordinates?
}

struct TripPlanResponse: Codable {
    let tripPlan: TripPlan
}
