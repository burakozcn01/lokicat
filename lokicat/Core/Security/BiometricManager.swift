import Foundation
import LocalAuthentication

final class BiometricManager {
    static let shared = BiometricManager()
    private init() {}

    var biometricType: BiometricType {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .opticID:
            return .opticID
        default:
            return .none
        }
    }

    var isAvailable: Bool {
        biometricType != .none
    }

    func authenticate(reason: String = "Authenticate to access LokiCat") async throws -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw BiometricError.notAvailable
        }

        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
        } catch let error as LAError {
            throw BiometricError.from(error)
        }
    }
}

enum BiometricType {
    case none
    case touchID
    case faceID
    case opticID

    var displayName: String {
        switch self {
        case .none: return "None"
        case .touchID: return "Touch ID"
        case .faceID: return "Face ID"
        case .opticID: return "Optic ID"
        }
    }

    var iconName: String {
        switch self {
        case .none: return "lock.fill"
        case .touchID: return "touchid"
        case .faceID: return "faceid"
        case .opticID: return "opticid"
        }
    }
}

enum BiometricError: LocalizedError {
    case notAvailable
    case failed
    case cancelled
    case lockout
    case notEnrolled

    static func from(_ error: LAError) -> BiometricError {
        switch error.code {
        case .biometryNotAvailable, .biometryNotEnrolled:
            return .notEnrolled
        case .biometryLockout:
            return .lockout
        case .userCancel, .appCancel, .systemCancel:
            return .cancelled
        default:
            return .failed
        }
    }

    var errorDescription: String? {
        switch self {
        case .notAvailable: return "Biometric authentication not available"
        case .failed: return "Authentication failed"
        case .cancelled: return "Authentication cancelled"
        case .lockout: return "Too many failed attempts"
        case .notEnrolled: return "Biometric not enrolled on device"
        }
    }
}
