import Foundation
import Combine

final class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()

    @Published var isAuthenticated = false
    @Published var isBiometricEnabled = false
    @Published var autoLockDuration: Int = 300
    @Published var failedAttempts: Int = 0

    private let keychain = KeychainManager.shared
    private let crypto = CryptoManager.shared
    private let biometric = BiometricManager.shared
    private var lockTimer: Timer?

    private let maxFailedAttempts = 5
    private let lockoutDurations = [60, 300, 900, 3600]

    private init() {
        loadSettings()
    }

    var isSetup: Bool {
        keychain.exists("master.password.hash")
    }

    var isLockedOut: Bool {
        guard let lockoutUntil = keychain.retrieve("lockout.until"),
              let timestamp = try? JSONDecoder().decode(Date.self, from: lockoutUntil) else {
            return false
        }
        return timestamp > Date()
    }

    var lockoutRemainingTime: TimeInterval {
        guard let lockoutUntil = keychain.retrieve("lockout.until"),
              let timestamp = try? JSONDecoder().decode(Date.self, from: lockoutUntil) else {
            return 0
        }
        return max(0, timestamp.timeIntervalSince(Date()))
    }

    func setupMasterPassword(_ password: String) throws {
        guard password.count >= 8 else {
            throw AuthError.weakPassword
        }

        let salt = crypto.generateSalt()
        let hash = crypto.hash(data: password.data(using: .utf8)! + salt)

        keychain.save(hash, for: "master.password.hash")
        keychain.save(salt, for: "master.password.salt")

        try VaultRepository.shared.initialize(with: password)

        isAuthenticated = true
    }

    func authenticate(with password: String) throws {
        guard !isLockedOut else {
            throw AuthError.lockedOut(duration: Int(lockoutRemainingTime))
        }

        guard let savedHash = keychain.retrieve("master.password.hash"),
              let salt = keychain.retrieve("master.password.salt") else {
            throw AuthError.notSetup
        }

        let inputHash = crypto.hash(data: password.data(using: .utf8)! + salt)

        guard inputHash == savedHash else {
            failedAttempts += 1
            if failedAttempts >= maxFailedAttempts {
                try lockOut()
            }
            throw AuthError.incorrectPassword(remaining: maxFailedAttempts - failedAttempts)
        }

        failedAttempts = 0
        try VaultRepository.shared.initialize(with: password)
        isAuthenticated = true
        startAutoLockTimer()
    }

    func authenticateWithBiometric() async throws {
        guard isBiometricEnabled else {
            throw AuthError.biometricNotEnabled
        }

        guard !isLockedOut else {
            throw AuthError.lockedOut(duration: Int(lockoutRemainingTime))
        }

        _ = try await biometric.authenticate()

        guard let passwordData = try await keychain.retrieveWithBiometric("master.password.biometric"),
              let password = String(data: passwordData, encoding: .utf8) else {
            throw AuthError.biometricFailed
        }

        try VaultRepository.shared.initialize(with: password)
        isAuthenticated = true
        startAutoLockTimer()
    }

    func enableBiometric(password: String) throws {
        guard biometric.isAvailable else {
            throw AuthError.biometricNotAvailable
        }

        guard let passwordData = password.data(using: .utf8) else {
            throw AuthError.invalidPassword
        }

        guard keychain.save(passwordData, for: "master.password.biometric", requireBiometric: true) else {
            throw AuthError.biometricFailed
        }

        isBiometricEnabled = true
        saveBiometricSetting()
    }

    func disableBiometric() {
        keychain.delete("master.password.biometric")
        isBiometricEnabled = false
        saveBiometricSetting()
    }

    func logout() {
        isAuthenticated = false
        lockTimer?.invalidate()
        lockTimer = nil
    }

    func changeMasterPassword(current: String, new: String) throws {
        try authenticate(with: current)

        guard new.count >= 8 else {
            throw AuthError.weakPassword
        }

        let salt = crypto.generateSalt()
        let hash = crypto.hash(data: new.data(using: .utf8)! + salt)

        keychain.save(hash, for: "master.password.hash")
        keychain.save(salt, for: "master.password.salt")

        if isBiometricEnabled {
            try enableBiometric(password: new)
        }
    }

    private func lockOut() throws {
        let duration = lockoutDurations[min(failedAttempts - maxFailedAttempts, lockoutDurations.count - 1)]
        let lockoutUntil = Date().addingTimeInterval(TimeInterval(duration))
        let data = try JSONEncoder().encode(lockoutUntil)
        keychain.save(data, for: "lockout.until")
    }

    private func startAutoLockTimer() {
        lockTimer?.invalidate()
        guard autoLockDuration > 0 else { return }

        lockTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(autoLockDuration), repeats: false) { [weak self] _ in
            self?.logout()
        }
    }

    private func loadSettings() {
        if let data = keychain.retrieve("settings.biometric.enabled"),
           let enabled = try? JSONDecoder().decode(Bool.self, from: data) {
            isBiometricEnabled = enabled
        }

        if let data = keychain.retrieve("settings.autolock.duration"),
           let duration = try? JSONDecoder().decode(Int.self, from: data) {
            autoLockDuration = duration
        }
    }

    private func saveBiometricSetting() {
        if let data = try? JSONEncoder().encode(isBiometricEnabled) {
            keychain.save(data, for: "settings.biometric.enabled")
        }
    }

    func setAutoLockDuration(_ duration: Int) {
        autoLockDuration = duration
        if let data = try? JSONEncoder().encode(duration) {
            keychain.save(data, for: "settings.autolock.duration")
        }
        if isAuthenticated {
            startAutoLockTimer()
        }
    }
}

enum AuthError: LocalizedError {
    case notSetup
    case incorrectPassword(remaining: Int)
    case weakPassword
    case lockedOut(duration: Int)
    case biometricNotAvailable
    case biometricNotEnabled
    case biometricFailed
    case invalidPassword

    var errorDescription: String? {
        switch self {
        case .notSetup:
            return "Master password not set up"
        case .incorrectPassword(let remaining):
            return remaining > 0 ? "Incorrect password. \(remaining) attempts remaining" : "Incorrect password"
        case .weakPassword:
            return "Password must be at least 8 characters"
        case .lockedOut(let duration):
            let minutes = duration / 60
            return "Too many failed attempts. Try again in \(minutes) minutes"
        case .biometricNotAvailable:
            return "Biometric authentication not available on this device"
        case .biometricNotEnabled:
            return "Biometric authentication not enabled"
        case .biometricFailed:
            return "Biometric authentication failed"
        case .invalidPassword:
            return "Invalid password format"
        }
    }
}
