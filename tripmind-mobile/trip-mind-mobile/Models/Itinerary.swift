import Foundation

struct Itinerary: Codable, Identifiable, Hashable {
    let id: String
    var userEmail: String?
    var tripId: String?
    let title: String
    var description: String?
    
    let itineraryData: [String: AnyCodable]
    
    let createdAt: String
    var updatedAt: String?
    
    // MARK: - Computed TripPlan
    
    var tripPlan: TripPlan {
        do {
            let regularDict = itineraryData.mapValues { $0.value }
            print("[Itinerary.tripPlan] Available keys: \(regularDict.keys.sorted())")
            
            let jsonData = try JSONSerialization.data(withJSONObject: regularDict)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let tripPlan = try decoder.decode(TripPlan.self, from: jsonData)
            print("[Itinerary.tripPlan] Successfully converted to TripPlan")
            return tripPlan
        } catch {
            print("[Itinerary.tripPlan] Error converting itineraryData to TripPlan: \(error)")
            print("[Itinerary.tripPlan] Available keys: \(itineraryData.keys.sorted())")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("[Itinerary.tripPlan] Missing key: \(key), path: \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("[Itinerary.tripPlan] Type mismatch for \(type), path: \(context.codingPath)")
                default:
                    break
                }
            }
        }
        
        // Фоллбек если вдруг что-то пойдёт не так
        return TripPlan(
            origin: "",
            destination: "",
            durationDays: 0,
            groupSize: "", budget: "",
            interests: [],
            specialRequirements: nil,
            hotels: [],
            itinerary: []
        )
    }
    
    // MARK: - Coding
    
    enum CodingKeys: String, CodingKey {
        case id
        case userEmail
        case tripId
        case title
        case description
        case itineraryData       // старое имя, если где-то ещё осталось
        case plan                // новое имя, как на бэкенде
        case createdAt
        case updatedAt
    }
    
    // Явный init(from:) чтобы поддерживать и plan, и itineraryData
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        userEmail = try container.decodeIfPresent(String.self, forKey: .userEmail)
        tripId = try container.decodeIfPresent(String.self, forKey: .tripId)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        
        if let data = try container.decodeIfPresent([String: AnyCodable].self, forKey: .itineraryData) {
            itineraryData = data
        } else if let data = try container.decodeIfPresent([String: AnyCodable].self, forKey: .plan) {
            itineraryData = data
        } else {
            print("[Itinerary] Warning: no plan/itineraryData in response")
            itineraryData = [:]
        }
        
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
    
    // Не особо нужен сейчас, но пусть будет консистентный
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(userEmail, forKey: .userEmail)
        try container.encodeIfPresent(tripId, forKey: .tripId)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(itineraryData, forKey: .plan) // пишем как plan
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
    }
    
    // Удобный memberwise init для превью/тестов
    init(
        id: String,
        userEmail: String? = nil,
        tripId: String? = nil,
        title: String,
        description: String? = nil,
        itineraryData: [String: AnyCodable],
        createdAt: String,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.userEmail = userEmail
        self.tripId = tripId
        self.title = title
        self.description = description
        self.itineraryData = itineraryData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct SaveItineraryRequest: Codable {
    let title: String
    var tripId: String?
    
    let origin: String
    let destination: String
    let durationDays: Int
    let budget: String
    let groupSize: String
    let interests: [String]
    let specialReq: String?
    
    let itineraryData: [String: AnyCodable]
    
    init(title: String, tripId: String? = nil, tripPlan: TripPlan) {
        self.title = title
        self.tripId = tripId
        
        self.origin = tripPlan.origin
        self.destination = tripPlan.destination
        self.durationDays = tripPlan.durationDays
        self.budget = tripPlan.budget
        self.groupSize = tripPlan.groupSize
        self.interests = tripPlan.interests
        self.specialReq = tripPlan.specialRequirements
        
        self.itineraryData = Self.tripPlanToDictionary(tripPlan)
    }
    
    private static func tripPlanToDictionary(_ tripPlan: TripPlan) -> [String: AnyCodable] {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        do {
            let jsonData = try encoder.encode(tripPlan)
            if let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                return jsonDictionary.mapValues { AnyCodable($0) }
            }
        } catch {
            print("[SaveItineraryRequest] Error encoding tripPlan: \(error)")
        }
        
        return [:]
    }
}

struct AnyCodable: Codable, Equatable, Hashable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    // MARK: - Decodable
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode AnyCodable"
            )
        }
    }
    
    // MARK: - Encodable
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case is NSNull:
            try container.encodeNil()
            
        // 🔥 Главное изменение — отдельно обрабатываем NSNumber,
        // чтобы числа не превращались в странные типы
        case let number as NSNumber:
            // В наших планах day / duration и т.п. — числа,
            // поэтому спокойно кодим как Int/Double
            if number.doubleValue.rounded() == number.doubleValue {
                try container.encode(number.intValue)
            } else {
                try container.encode(number.doubleValue)
            }
            
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription: "Cannot encode \(type(of: value))"
                )
            )
        }
    }
    
    // MARK: - Equatable / Hashable через JSON
    
    static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        do {
            let lhsData = try encoder.encode(lhs)
            let rhsData = try encoder.encode(rhs)
            return lhsData == rhsData
        } catch {
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        do {
            let data = try encoder.encode(self)
            if let json = String(data: data, encoding: .utf8) {
                hasher.combine(json)
            }
        } catch {
            hasher.combine(0)
        }
    }
}

struct SaveItineraryResponse: Codable {
    let id: String
    let message: String
}
