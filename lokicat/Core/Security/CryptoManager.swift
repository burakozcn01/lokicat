import Foundation
import CryptoKit
import CommonCrypto

final class CryptoManager {
    static let shared = CryptoManager()
    private init() {}

    func deriveKey(from password: String, salt: Data, iterations: Int = 100_000, keyLength: Int = 32) throws -> SymmetricKey {
        guard let passwordData = password.data(using: .utf8) else {
            throw CryptoError.invalidPassword
        }

        var derivedKeyData = Data(count: keyLength)
        let derivationStatus = derivedKeyData.withUnsafeMutableBytes { derivedKeyBytes in
            salt.withUnsafeBytes { saltBytes in
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    password,
                    passwordData.count,
                    saltBytes.bindMemory(to: UInt8.self).baseAddress,
                    salt.count,
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                    UInt32(iterations),
                    derivedKeyBytes.bindMemory(to: UInt8.self).baseAddress,
                    keyLength
                )
            }
        }

        guard derivationStatus == kCCSuccess else {
            throw CryptoError.keyDerivationFailed
        }

        return SymmetricKey(data: derivedKeyData)
    }

    func encrypt(data: Data, using key: SymmetricKey) throws -> EncryptedData {
        let nonce = AES.GCM.Nonce()
        let sealedBox = try AES.GCM.seal(data, using: key, nonce: nonce)

        guard let combinedData = sealedBox.combined else {
            throw CryptoError.encryptionFailed
        }

        return EncryptedData(data: combinedData, nonce: nonce)
    }

    func decrypt(encryptedData: EncryptedData, using key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData.data)
        return try AES.GCM.open(sealedBox, using: key)
    }

    func generateSalt() -> Data {
        var salt = Data(count: 32)
        _ = salt.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, 32, bytes.baseAddress!)
        }
        return salt
    }

    func hash(data: Data) -> Data {
        Data(SHA256.hash(data: data))
    }
}

struct EncryptedData: Codable {
    let data: Data
    let nonce: Data

    init(data: Data, nonce: AES.GCM.Nonce) {
        self.data = data
        self.nonce = Data(nonce)
    }
}

enum CryptoError: LocalizedError {
    case invalidPassword
    case keyDerivationFailed
    case encryptionFailed
    case decryptionFailed

    var errorDescription: String? {
        switch self {
        case .invalidPassword: return "Invalid password format"
        case .keyDerivationFailed: return "Key derivation failed"
        case .encryptionFailed: return "Encryption failed"
        case .decryptionFailed: return "Decryption failed"
        }
    }
}
