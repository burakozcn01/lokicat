import Foundation

struct SecureNote: VaultItem {
    let id: UUID
    var title: String
    let createdAt: Date
    var modifiedAt: Date
    var isFavorite: Bool
    var categoryId: UUID?
    var tags: [UUID]

    var content: String

    var type: VaultItemType { .secureNote }

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        categoryId: UUID? = nil,
        tags: [UUID] = [],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.categoryId = categoryId
        self.tags = tags
        self.isFavorite = isFavorite
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
}

extension SecureNote {
    var searchableContent: String {
        "\(title) \(content)".lowercased()
    }
}
