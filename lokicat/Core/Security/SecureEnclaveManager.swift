import Foundation
import CryptoKit
import Security

final class SecureEnclaveManager {
    static let shared = SecureEnclaveManager()
    private init() {}

    private let keyTag = "com.lokicat.secureenclave.key"

    func generateKey() throws -> SecureEnclave.P256.Signing.PrivateKey {
        if let existingKey = try? loadKey() {
            return existingKey
        }

        let key = try SecureEnclave.P256.Signing.PrivateKey()
        try saveKey(key)
        return key
    }

    func loadKey() throws -> SecureEnclave.P256.Signing.PrivateKey {
        var error: Unmanaged<CFError>?
        guard let keyData = SecItemCopyMatching([
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keyTag,
            kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef: true
        ] as CFDictionary, nil) as! SecKey? else {
            throw SecureEnclaveError.keyNotFound
        }

        var unmanagedError: Unmanaged<CFError>?
        guard let representation = SecKeyCopyExternalRepresentation(keyData, &unmanagedError) as Data? else {
            throw SecureEnclaveError.keyLoadFailed
        }

        return try SecureEnclave.P256.Signing.PrivateKey(dataRepresentation: representation)
    }

    private func saveKey(_ key: SecureEnclave.P256.Signing.PrivateKey) throws {
        let attributes: [String: Any] = [
            kSecAttrApplicationTag as String: keyTag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecClass as String: kSecClassKey,
            kSecValueData as String: key.dataRepresentation
        ]

        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SecureEnclaveError.keySaveFailed
        }
    }

    func deleteKey() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureEnclaveError.keyDeletionFailed
        }
    }

    func sign(data: Data) throws -> Data {
        let key = try loadKey()
        let signature = try key.signature(for: data)
        return signature.rawRepresentation
    }

    func verify(data: Data, signature: Data) throws -> Bool {
        let key = try loadKey()
        let publicKey = key.publicKey
        let sig = try P256.Signing.ECDSASignature(rawRepresentation: signature)
        return publicKey.isValidSignature(sig, for: data)
    }
}

enum SecureEnclaveError: LocalizedError {
    case keyNotFound
    case keyLoadFailed
    case keySaveFailed
    case keyDeletionFailed
    case signatureFailed
    case verificationFailed

    var errorDescription: String? {
        switch self {
        case .keyNotFound: return "Secure Enclave key not found"
        case .keyLoadFailed: return "Failed to load key from Secure Enclave"
        case .keySaveFailed: return "Failed to save key to Secure Enclave"
        case .keyDeletionFailed: return "Failed to delete key from Secure Enclave"
        case .signatureFailed: return "Signature generation failed"
        case .verificationFailed: return "Signature verification failed"
        }
    }
}
