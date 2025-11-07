import Foundation

struct WiFiPassword: VaultItem {
    let id: UUID
    var title: String
    let createdAt: Date
    var modifiedAt: Date
    var isFavorite: Bool
    var categoryId: UUID?
    var tags: [UUID]

    var ssid: String
    var password: String
    var securityType: WiFiSecurityType
    var notes: String?

    var type: VaultItemType { .wifiPassword }

    init(
        id: UUID = UUID(),
        title: String,
        ssid: String,
        password: String,
        securityType: WiFiSecurityType = .wpa2,
        notes: String? = nil,
        categoryId: UUID? = nil,
        tags: [UUID] = [],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.ssid = ssid
        self.password = password
        self.securityType = securityType
        self.notes = notes
        self.categoryId = categoryId
        self.tags = tags
        self.isFavorite = isFavorite
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
}

enum WiFiSecurityType: String, Codable, CaseIterable {
    case wpa3 = "WPA3"
    case wpa2 = "WPA2"
    case wpa = "WPA"
    case wep = "WEP"
    case open = "Open"
}

extension WiFiPassword {
    var searchableContent: String {
        [title, ssid, notes]
            .compactMap { $0 }
            .joined(separator: " ")
            .lowercased()
    }
}
