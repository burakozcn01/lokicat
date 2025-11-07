import SwiftUI
import UniformTypeIdentifiers

struct ImportVaultSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vault: VaultRepository

    @State private var password = ""
    @State private var isImporting = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showFilePicker = false
    @State private var selectedFileURL: URL?

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
                                Image(systemName: "square.and.arrow.down.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.green, .blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )

                                Text("Import Encrypted Vault")
                                    .font(.title3)
                                    .fontWeight(.bold)

                                Text("Restore your vault from an encrypted backup file. This will merge with your existing data.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        }

                        GlassButton("Select Backup File", icon: "doc.fill") {
                            showFilePicker = true
                        }

                        if let fileURL = selectedFileURL {
                            GlassCard {
                                HStack {
                                    Image(systemName: "doc.fill")
                                        .foregroundColor(.blue)
                                    Text(fileURL.lastPathComponent)
                                        .font(.subheadline)
                                    Spacer()
                                    Button {
                                        selectedFileURL = nil
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                            }

                            GlassCard {
                                VStack(spacing: AppTheme.spacing) {
                                    GlassTextField(
                                        title: "Decryption Password",
                                        placeholder: "Enter backup password",
                                        text: $password,
                                        isSecure: true,
                                        icon: "lock.fill",
                                        textContentType: .password
                                    )
                                }
                                .padding()
                            }

                            GlassButton("Import Vault", icon: "square.and.arrow.down.fill") {
                                importVault()
                            }
                            .disabled(password.isEmpty || isImporting)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Import Vault")
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
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [UTType(filenameExtension: "lokicat")!],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        selectedFileURL = url
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func importVault() {
        guard let fileURL = selectedFileURL else { return }

        isImporting = true

        do {
            guard fileURL.startAccessingSecurityScopedResource() else {
                throw ImportError.accessDenied
            }
            defer { fileURL.stopAccessingSecurityScopedResource() }

            let data = try Data(contentsOf: fileURL)
            try vault.importVault(from: data, password: password)

            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isImporting = false
    }
}

enum ImportError: LocalizedError {
    case accessDenied

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Cannot access the selected file"
        }
    }
}
