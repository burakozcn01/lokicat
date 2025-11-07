import Foundation

struct LoginItem: VaultItem {
    let id: UUID
    var title: String
    let createdAt: Date
    var modifiedAt: Date
    var isFavorite: Bool
    var categoryId: UUID?
    var tags: [UUID]

    var username: String
    var password: String
    var url: String?
    var notes: String?
    var totpSecret: String?

    var type: VaultItemType { .login }

    init(
        id: UUID = UUID(),
        title: String,
        username: String,
        password: String,
        url: String? = nil,
        notes: String? = nil,
        totpSecret: String? = nil,
        categoryId: UUID? = nil,
        tags: [UUID] = [],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.username = username
        self.password = password
        self.url = url
        self.notes = notes
        self.totpSecret = totpSecret
        self.categoryId = categoryId
        self.tags = tags
        self.isFavorite = isFavorite
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
}

extension LoginItem {
    var domain: String? {
        guard let url = url, let urlObj = URL(string: url) else { return nil }
        return urlObj.host
    }

    var faviconURL: String? {
        guard let domain = domain else { return nil }
        return "https://www.google.com/s2/favicons?domain=\(domain)&sz=64"
    }

    var searchableContent: String {
        [title, username, url, domain, notes]
            .compactMap { $0 }
            .joined(separator: " ")
            .lowercased()
    }
}
