import Foundation

protocol VaultItem: Identifiable, Codable {
    var id: UUID { get }
    var title: String { get set }
    var createdAt: Date { get }
    var modifiedAt: Date { get set }
    var isFavorite: Bool { get set }
    var categoryId: UUID? { get set }
    var tags: [UUID] { get set }
    var type: VaultItemType { get }
}

enum VaultItemType: String, Codable {
    case login
    case secureNote
    case creditCard
    case identity
    case wifiPassword
    case apiKey
}

extension VaultItem {
    var searchableContent: String {
        title.lowercased()
    }
}
