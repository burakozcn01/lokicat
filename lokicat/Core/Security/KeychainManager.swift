import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()
    private init() {}

    private let service = "com.lokicat.app"

    @discardableResult
    func save(_ data: Data, for key: String, requireBiometric: Bool = false) -> Bool {
        delete(key)

        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        if requireBiometric {
            var error: Unmanaged<CFError>?
            guard let access = SecAccessControlCreateWithFlags(
                nil,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                .biometryCurrentSet,
                &error
            ) else {
                return false
            }
            query[kSecAttrAccessControl as String] = access
            query.removeValue(forKey: kSecAttrAccessible as String)
        }

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    func retrieve(_ key: String, context: LAContext? = nil) -> Data? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        if let context = context {
            query[kSecUseAuthenticationContext as String] = context
        }

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess {
            return result as? Data
        }
        return nil
    }

    @discardableResult
    func delete(_ key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    func exists(_ key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
}

import LocalAuthentication

extension KeychainManager {
    func retrieveWithBiometric(_ key: String) async throws -> Data? {
        let context = LAContext()
        context.localizedReason = "Unlock your vault"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw KeychainError.biometricNotAvailable
        }

        do {
            try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authenticate to access your passwords"
            )
            return retrieve(key, context: context)
        } catch {
            throw KeychainError.biometricFailed
        }
    }
}

enum KeychainError: LocalizedError {
    case biometricNotAvailable
    case biometricFailed
    case itemNotFound

    var errorDescription: String? {
        switch self {
        case .biometricNotAvailable: return "Biometric authentication is not available"
        case .biometricFailed: return "Biometric authentication failed"
        case .itemNotFound: return "Item not found in keychain"
        }
    }
}
