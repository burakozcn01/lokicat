import SwiftUI

struct ChangePasswordSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authService: AuthenticationService

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.spacing * 1.5) {
                        GlassCard {
                            VStack(spacing: AppTheme.spacing) {
                                GlassTextField(
                                    title: "Current Password",
                                    placeholder: "Enter current password",
                                    text: $currentPassword,
                                    isSecure: true,
                                    icon: "lock.fill",
                                    textContentType: .password
                                )

                                Divider()
                                    .padding(.vertical, AppTheme.smallSpacing)

                                GlassTextField(
                                    title: "New Password",
                                    placeholder: "Enter new password",
                                    text: $newPassword,
                                    isSecure: true,
                                    icon: "lock.fill",
                                    textContentType: .newPassword
                                )

                                GlassTextField(
                                    title: "Confirm New Password",
                                    placeholder: "Re-enter new password",
                                    text: $confirmPassword,
                                    isSecure: true,
                                    icon: "lock.fill",
                                    textContentType: .newPassword
                                )
                            }
                            .padding()
                        }

                        GlassButton("Change Password", icon: "checkmark.circle.fill") {
                            changePassword()
                        }
                        .disabled(currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
                    }
                    .padding()
                }
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
    }

    private func changePassword() {
        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match"
            showError = true
            return
        }

        guard newPassword.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            showError = true
            return
        }

        do {
            try authService.changeMasterPassword(current: currentPassword, new: newPassword)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
