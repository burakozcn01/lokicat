import Foundation

struct APIKey: VaultItem {
    let id: UUID
    var title: String
    let createdAt: Date
    var modifiedAt: Date
    var isFavorite: Bool
    var categoryId: UUID?
    var tags: [UUID]

    var serviceName: String
    var apiKey: String
    var apiSecret: String?
    var apiType: APIType
    var expiryDate: Date?
    var notes: String?

    var type: VaultItemType { .apiKey }

    init(
        id: UUID = UUID(),
        title: String,
        serviceName: String,
        apiKey: String,
        apiSecret: String? = nil,
        apiType: APIType = .restApi,
        expiryDate: Date? = nil,
        notes: String? = nil,
        categoryId: UUID? = nil,
        tags: [UUID] = [],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.serviceName = serviceName
        self.apiKey = apiKey
        self.apiSecret = apiSecret
        self.apiType = apiType
        self.expiryDate = expiryDate
        self.notes = notes
        self.categoryId = categoryId
        self.tags = tags
        self.isFavorite = isFavorite
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
}

enum APIType: String, Codable, CaseIterable {
    case restApi = "REST API"
    case graphql = "GraphQL"
    case sshKey = "SSH Key"
    case accessToken = "Access Token"
    case other = "Other"
}

extension APIKey {
    var maskedKey: String {
        guard apiKey.count > 8 else { return "••••••••" }
        let prefix = apiKey.prefix(4)
        let suffix = apiKey.suffix(4)
        return "\(prefix)••••\(suffix)"
    }

    var isExpired: Bool {
        guard let expiryDate = expiryDate else { return false }
        return expiryDate < Date()
    }

    var searchableContent: String {
        [title, serviceName, notes]
            .compactMap { $0 }
            .joined(separator: " ")
            .lowercased()
    }
}
