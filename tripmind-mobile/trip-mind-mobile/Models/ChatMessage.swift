import Foundation

struct ChatMessage: Codable, Identifiable {
    let id: UUID
    let role: MessageRole
    let content: String
    var meta: ChatMeta?
    
    init(role: MessageRole, content: String, meta: ChatMeta? = nil) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.meta = meta
    }
    
    enum MessageRole: String, Codable {
        case user
        case assistant
    }
}

struct ChatMeta: Codable {
    let ui: String
    var options: [ChatOption]?
    var multi: Bool?
    var tripPlan: TripPlan?
    
    enum CodingKeys: String, CodingKey {
        case ui
        case options
        case multi
        case tripPlan
    }
}

struct ChatOption: Codable, Identifiable {
    var id: String { value }
    let label: String
    let value: String
    var emoji: String?
    var subtitle: String?
}

struct ChatRequest: Codable {
    let messages: [ChatMessage]
}

struct ChatResponse: Codable {
    let resp: String
    let ui: String
    var options: [ChatOption]?
    var multi: Bool?
    var tripPlan: TripPlan?
    
    var content: String { resp }
    
    var meta: ChatMeta {
        return ChatMeta(
            ui: ui,
            options: options,
            multi: multi,
            tripPlan: tripPlan
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case resp
        case ui
        case options
        case multi
        case tripPlan
    }
}
