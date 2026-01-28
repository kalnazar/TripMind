import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    var name: String?
    var avatarUrl: String?
    var createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case avatarUrl
        case createdAt
    }
    
    private enum AltNameKeys: String, CodingKey {
        case username
        case fullName
        case displayName
    }
    
    init(id: String, email: String, name: String?, avatarUrl: String?, createdAt: String?) {
        self.id = id
        self.email = email
        self.name = name
        self.avatarUrl = avatarUrl
        self.createdAt = createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = idString
        } else if let idInt = try? container.decode(Int.self, forKey: .id) {
            self.id = String(idInt)
        } else if let idInt64 = try? container.decode(Int64.self, forKey: .id) {
            self.id = String(idInt64)
        } else {
            throw DecodingError.typeMismatch(
                String.self,
                .init(codingPath: container.codingPath + [CodingKeys.id],
                      debugDescription: "Expected id as String or Int")
            )
        }
        
        self.email = try container.decode(String.self, forKey: .email)
        self.avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        
        if let directName = try container.decodeIfPresent(String.self, forKey: .name) {
            self.name = directName
        } else if let alt = try? decoder.container(keyedBy: AltNameKeys.self) {
            if let full = try? alt.decode(String.self, forKey: .fullName) {
                self.name = full
            } else if let display = try? alt.decode(String.self, forKey: .displayName) {
                self.name = display
            } else if let username = try? alt.decode(String.self, forKey: .username) {
                self.name = username
            } else {
                self.name = nil
            }
        } else {
            self.name = nil
        }
    }
}

struct AuthResponse: Codable {
    let authenticated: Bool?
    let success: Bool?
    let user: User?
    let token: String?
    let accessToken: String?
    let refreshToken: String?
    
    var resolvedToken: String? {
        token ?? accessToken
    }
    
    var isAuthenticated: Bool {
        (authenticated == true) || (success == true) || (user != nil) || (resolvedToken?.isEmpty == false)
    }
    
    init(authenticated: Bool? = nil, success: Bool? = nil, user: User? = nil, token: String? = nil, accessToken: String? = nil, refreshToken: String? = nil) {
        self.authenticated = authenticated
        self.success = success
        self.user = user
        self.token = token
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    enum CodingKeys: String, CodingKey {
        case authenticated
        case success
        case user
        case token
        case accessToken
        case refreshToken
    }
    
    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self),
           container.allKeys.isEmpty == false {
            let authenticated = try container.decodeIfPresent(Bool.self, forKey: .authenticated)
            let success = try container.decodeIfPresent(Bool.self, forKey: .success)
            let user = try container.decodeIfPresent(User.self, forKey: .user)
            let token = try container.decodeIfPresent(String.self, forKey: .token)
            let accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken)
            let refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken)
            self.init(authenticated: authenticated, success: success, user: user, token: token, accessToken: accessToken, refreshToken: refreshToken)
            return
        }
        if let user = try? User(from: decoder) {
            self.init(user: user)
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "AuthResponse could not decode as wrapped response or bare user"))
    }
}
