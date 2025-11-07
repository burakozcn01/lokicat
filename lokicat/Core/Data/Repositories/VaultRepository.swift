import Foundation
import Combine
import CryptoKit

final class VaultRepository: ObservableObject {
    static let shared = VaultRepository()

    @Published private(set) var loginItems: [LoginItem] = []
    @Published private(set) var secureNotes: [SecureNote] = []
    @Published private(set) var creditCards: [CreditCard] = []
    @Published private(set) var identities: [Identity] = []
    @Published private(set) var wifiPasswords: [WiFiPassword] = []
    @Published private(set) var apiKeys: [APIKey] = []
    @Published private(set) var categories: [Category] = []
    @Published private(set) var tags: [Tag] = []

    private let crypto = CryptoManager.shared
    private let keychain = KeychainManager.shared
    private var masterKey: SymmetricKey?

    private init() {}

    func initialize(with masterPassword: String) throws {
        let salt: Data
        if let existingSalt = keychain.retrieve("vault.salt") {
            salt = existingSalt
        } else {
            salt = crypto.generateSalt()
            keychain.save(salt, for: "vault.salt")
        }

        masterKey = try crypto.deriveKey(from: masterPassword, salt: salt)
        try loadVault()
    }

    private func loadVault() throws {
        guard let key = masterKey else { throw VaultError.notInitialized }

        if let data = keychain.retrieve("vault.logins"), !data.isEmpty {
            let decrypted = try crypto.decrypt(encryptedData: try JSONDecoder().decode(EncryptedData.self, from: data), using: key)
            loginItems = try JSONDecoder().decode([LoginItem].self, from: decrypted)
        }

        if let data = keychain.retrieve("vault.notes"), !data.isEmpty {
            let decrypted = try crypto.decrypt(encryptedData: try JSONDecoder().decode(EncryptedData.self, from: data), using: key)
            secureNotes = try JSONDecoder().decode([SecureNote].self, from: decrypted)
        }

        if let data = keychain.retrieve("vault.cards"), !data.isEmpty {
            let decrypted = try crypto.decrypt(encryptedData: try JSONDecoder().decode(EncryptedData.self, from: data), using: key)
            creditCards = try JSONDecoder().decode([CreditCard].self, from: decrypted)
        }

        if let data = keychain.retrieve("vault.identities"), !data.isEmpty {
            let decrypted = try crypto.decrypt(encryptedData: try JSONDecoder().decode(EncryptedData.self, from: data), using: key)
            identities = try JSONDecoder().decode([Identity].self, from: decrypted)
        }

        if let data = keychain.retrieve("vault.wifi"), !data.isEmpty {
            let decrypted = try crypto.decrypt(encryptedData: try JSONDecoder().decode(EncryptedData.self, from: data), using: key)
            wifiPasswords = try JSONDecoder().decode([WiFiPassword].self, from: decrypted)
        }

        if let data = keychain.retrieve("vault.apikeys"), !data.isEmpty {
            let decrypted = try crypto.decrypt(encryptedData: try JSONDecoder().decode(EncryptedData.self, from: data), using: key)
            apiKeys = try JSONDecoder().decode([APIKey].self, from: decrypted)
        }

        if let data = keychain.retrieve("vault.categories") {
            categories = try JSONDecoder().decode([Category].self, from: data)
        } else {
            categories = Category.defaultCategories
            try saveCategories()
        }

        if let data = keychain.retrieve("vault.tags") {
            tags = try JSONDecoder().decode([Tag].self, from: data)
        }
    }

    func save(_ item: LoginItem) throws {
        if let index = loginItems.firstIndex(where: { $0.id == item.id }) {
            var updated = item
            updated.modifiedAt = Date()
            loginItems[index] = updated
        } else {
            loginItems.append(item)
        }
        try saveLoginItems()
    }

    func delete(_ item: LoginItem) throws {
        loginItems.removeAll { $0.id == item.id }
        try saveLoginItems()
    }

    func save(_ item: SecureNote) throws {
        if let index = secureNotes.firstIndex(where: { $0.id == item.id }) {
            var updated = item
            updated.modifiedAt = Date()
            secureNotes[index] = updated
        } else {
            secureNotes.append(item)
        }
        try saveSecureNotes()
    }

    func delete(_ item: SecureNote) throws {
        secureNotes.removeAll { $0.id == item.id }
        try saveSecureNotes()
    }

    func save(_ item: CreditCard) throws {
        if let index = creditCards.firstIndex(where: { $0.id == item.id }) {
            var updated = item
            updated.modifiedAt = Date()
            creditCards[index] = updated
        } else {
            creditCards.append(item)
        }
        try saveCreditCards()
    }

    func delete(_ item: CreditCard) throws {
        creditCards.removeAll { $0.id == item.id }
        try saveCreditCards()
    }

    func save(_ item: Identity) throws {
        if let index = identities.firstIndex(where: { $0.id == item.id }) {
            var updated = item
            updated.modifiedAt = Date()
            identities[index] = updated
        } else {
            identities.append(item)
        }
        try saveIdentities()
    }

    func delete(_ item: Identity) throws {
        identities.removeAll { $0.id == item.id }
        try saveIdentities()
    }

    func save(_ item: WiFiPassword) throws {
        if let index = wifiPasswords.firstIndex(where: { $0.id == item.id }) {
            var updated = item
            updated.modifiedAt = Date()
            wifiPasswords[index] = updated
        } else {
            wifiPasswords.append(item)
        }
        try saveWiFiPasswords()
    }

    func delete(_ item: WiFiPassword) throws {
        wifiPasswords.removeAll { $0.id == item.id }
        try saveWiFiPasswords()
    }

    func save(_ item: APIKey) throws {
        if let index = apiKeys.firstIndex(where: { $0.id == item.id }) {
            var updated = item
            updated.modifiedAt = Date()
            apiKeys[index] = updated
        } else {
            apiKeys.append(item)
        }
        try saveAPIKeys()
    }

    func delete(_ item: APIKey) throws {
        apiKeys.removeAll { $0.id == item.id }
        try saveAPIKeys()
    }

    func save(_ category: Category) throws {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
        } else {
            categories.append(category)
        }
        try saveCategories()
    }

    func delete(_ category: Category) throws {
        categories.removeAll { $0.id == category.id }
        try saveCategories()
    }

    func save(_ tag: Tag) throws {
        if let index = tags.firstIndex(where: { $0.id == tag.id }) {
            tags[index] = tag
        } else {
            tags.append(tag)
        }
        try saveTags()
    }

    func delete(_ tag: Tag) throws {
        tags.removeAll { $0.id == tag.id }
        try saveTags()
    }

    private func saveLoginItems() throws {
        guard let key = masterKey else { throw VaultError.notInitialized }
        let data = try JSONEncoder().encode(loginItems)
        let encrypted = try crypto.encrypt(data: data, using: key)
        let encryptedData = try JSONEncoder().encode(encrypted)
        keychain.save(encryptedData, for: "vault.logins")
    }

    private func saveSecureNotes() throws {
        guard let key = masterKey else { throw VaultError.notInitialized }
        let data = try JSONEncoder().encode(secureNotes)
        let encrypted = try crypto.encrypt(data: data, using: key)
        let encryptedData = try JSONEncoder().encode(encrypted)
        keychain.save(encryptedData, for: "vault.notes")
    }

    private func saveCreditCards() throws {
        guard let key = masterKey else { throw VaultError.notInitialized }
        let data = try JSONEncoder().encode(creditCards)
        let encrypted = try crypto.encrypt(data: data, using: key)
        let encryptedData = try JSONEncoder().encode(encrypted)
        keychain.save(encryptedData, for: "vault.cards")
    }

    private func saveIdentities() throws {
        guard let key = masterKey else { throw VaultError.notInitialized }
        let data = try JSONEncoder().encode(identities)
        let encrypted = try crypto.encrypt(data: data, using: key)
        let encryptedData = try JSONEncoder().encode(encrypted)
        keychain.save(encryptedData, for: "vault.identities")
    }

    private func saveWiFiPasswords() throws {
        guard let key = masterKey else { throw VaultError.notInitialized }
        let data = try JSONEncoder().encode(wifiPasswords)
        let encrypted = try crypto.encrypt(data: data, using: key)
        let encryptedData = try JSONEncoder().encode(encrypted)
        keychain.save(encryptedData, for: "vault.wifi")
    }

    private func saveAPIKeys() throws {
        guard let key = masterKey else { throw VaultError.notInitialized }
        let data = try JSONEncoder().encode(apiKeys)
        let encrypted = try crypto.encrypt(data: data, using: key)
        let encryptedData = try JSONEncoder().encode(encrypted)
        keychain.save(encryptedData, for: "vault.apikeys")
    }

    private func saveCategories() throws {
        let data = try JSONEncoder().encode(categories)
        keychain.save(data, for: "vault.categories")
    }

    private func saveTags() throws {
        let data = try JSONEncoder().encode(tags)
        keychain.save(data, for: "vault.tags")
    }

    func exportVault(password: String) throws -> Data {
        let salt = crypto.generateSalt()
        let key = try crypto.deriveKey(from: password, salt: salt)

        let vaultData = VaultExport(
            loginItems: loginItems,
            secureNotes: secureNotes,
            creditCards: creditCards,
            identities: identities,
            wifiPasswords: wifiPasswords,
            apiKeys: apiKeys,
            categories: categories,
            tags: tags,
            exportDate: Date()
        )

        let data = try JSONEncoder().encode(vaultData)
        let encrypted = try crypto.encrypt(data: data, using: key)
        let exportPackage = ExportPackage(salt: salt, encryptedData: encrypted)
        return try JSONEncoder().encode(exportPackage)
    }

    func importVault(from data: Data, password: String) throws {
        let package = try JSONDecoder().decode(ExportPackage.self, from: data)
        let key = try crypto.deriveKey(from: password, salt: package.salt)
        let decrypted = try crypto.decrypt(encryptedData: package.encryptedData, using: key)
        let vaultData = try JSONDecoder().decode(VaultExport.self, from: decrypted)

        loginItems = vaultData.loginItems
        secureNotes = vaultData.secureNotes
        creditCards = vaultData.creditCards
        identities = vaultData.identities
        wifiPasswords = vaultData.wifiPasswords
        apiKeys = vaultData.apiKeys
        categories = vaultData.categories
        tags = vaultData.tags

        try saveLoginItems()
        try saveSecureNotes()
        try saveCreditCards()
        try saveIdentities()
        try saveWiFiPasswords()
        try saveAPIKeys()
        try saveCategories()
        try saveTags()
    }
}

struct VaultExport: Codable {
    let loginItems: [LoginItem]
    let secureNotes: [SecureNote]
    let creditCards: [CreditCard]
    let identities: [Identity]
    let wifiPasswords: [WiFiPassword]
    let apiKeys: [APIKey]
    let categories: [Category]
    let tags: [Tag]
    let exportDate: Date
}

struct ExportPackage: Codable {
    let salt: Data
    let encryptedData: EncryptedData
}

enum VaultError: LocalizedError {
    case notInitialized
    case saveFailed
    case loadFailed

    var errorDescription: String? {
        switch self {
        case .notInitialized: return "Vault not initialized"
        case .saveFailed: return "Failed to save vault"
        case .loadFailed: return "Failed to load vault"
        }
    }
}
