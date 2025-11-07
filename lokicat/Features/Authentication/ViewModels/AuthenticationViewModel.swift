import Foundation
import Combine

final class AuthenticationViewModel: ObservableObject {
    @Published var masterPassword = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    private let authService = AuthenticationService.shared
    private var cancellables = Set<AnyCancellable>()

    var isSetup: Bool {
        authService.isSetup
    }

    var isLockedOut: Bool {
        authService.isLockedOut
    }

    var lockoutTime: Int {
        Int(authService.lockoutRemainingTime)
    }

    var biometricType: BiometricType {
        BiometricManager.shared.biometricType
    }

    var isBiometricAvailable: Bool {
        BiometricManager.shared.isAvailable
    }

    func setup() {
        guard !masterPassword.isEmpty else {
            showErrorMessage("Please enter a password")
            return
        }

        guard masterPassword == confirmPassword else {
            showErrorMessage("Passwords do not match")
            return
        }

        isLoading = true

        do {
            try authService.setupMasterPassword(masterPassword)
            clearFields()
        } catch {
            showErrorMessage(error.localizedDescription)
        }

        isLoading = false
    }

    func login() {
        guard !masterPassword.isEmpty else {
            showErrorMessage("Please enter your password")
            return
        }

        isLoading = true

        do {
            try authService.authenticate(with: masterPassword)
            clearFields()
        } catch {
            showErrorMessage(error.localizedDescription)
        }

        isLoading = false
    }

    func loginWithBiometric() {
        isLoading = true

        Task { @MainActor in
            do {
                try await authService.authenticateWithBiometric()
                clearFields()
            } catch {
                showErrorMessage(error.localizedDescription)
            }
            isLoading = false
        }
    }

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }

    private func clearFields() {
        masterPassword = ""
        confirmPassword = ""
    }
}
