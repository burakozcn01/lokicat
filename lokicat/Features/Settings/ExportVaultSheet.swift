import SwiftUI
import UniformTypeIdentifiers

struct ExportVaultSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vault: VaultRepository

    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isExporting = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var exportedData: Data?
    @State private var showShareSheet = false

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
                            VStack(spacing: AppTheme.smallSpacing) {
                                Image(systemName: "lock.square.stack.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )

                                Text("Export Encrypted Vault")
                                    .font(.title3)
                                    .fontWeight(.bold)

                                Text("Create an encrypted backup file. Use a strong password to protect your data.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        }

                        GlassCard {
                            VStack(spacing: AppTheme.spacing) {
                                GlassTextField(
                                    title: "Encryption Password",
                                    placeholder: "Enter a strong password",
                                    text: $password,
                                    isSecure: true,
                                    icon: "lock.fill",
                                    textContentType: .newPassword
                                )

                                GlassTextField(
                                    title: "Confirm Password",
                                    placeholder: "Re-enter password",
                                    text: $confirmPassword,
                                    isSecure: true,
                                    icon: "lock.fill",
                                    textContentType: .newPassword
                                )
                            }
                            .padding()
                        }

                        GlassButton("Export Vault", icon: "square.and.arrow.up.fill") {
                            exportVault()
                        }
                        .disabled(password.isEmpty || confirmPassword.isEmpty || isExporting)
                    }
                    .padding()
                }
            }
            .navigationTitle("Export Vault")
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
                Text(errorMessage)
            }
            .sheet(isPresented: $showShareSheet, onDismiss: {
                dismiss()
            }) {
                if let data = exportedData {
                    ShareSheet(items: [data])
                }
            }
        }
    }

    private func exportVault() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showError = true
            return
        }

        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            showError = true
            return
        }

        isExporting = true

        do {
            let data = try vault.exportVault(password: password)
            exportedData = data
            showShareSheet = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isExporting = false
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let filename = "lokicat_backup_\(Int(Date().timeIntervalSince1970)).lokicat"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        if let data = items.first as? Data {
            try? data.write(to: tempURL)
            let controller = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            return controller
        }

        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
