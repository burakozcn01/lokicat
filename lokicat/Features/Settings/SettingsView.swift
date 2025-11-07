import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @State private var showChangePasswordSheet = false
    @State private var showAutoLockSheet = false
    @State private var showExportSheet = false
    @State private var showImportSheet = false
    @State private var showJailbreakWarning = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.spacing * 3.5) {
                    securitySection
                    biometricSection
                    backupSection
                    aboutSection
                }
                .padding()
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            checkJailbreak()
        }
        .alert("Security Warning", isPresented: $showJailbreakWarning) {
            Button("I Understand", role: .cancel) {}
        } message: {
            Text("This device appears to be jailbroken. Your data security may be compromised.")
        }
        .sheet(isPresented: $showChangePasswordSheet) {
            ChangePasswordSheet()
        }
        .sheet(isPresented: $showAutoLockSheet) {
            AutoLockSettingsSheet()
        }
        .sheet(isPresented: $showExportSheet) {
            ExportVaultSheet()
        }
        .sheet(isPresented: $showImportSheet) {
            ImportVaultSheet()
        }
    }

    private var securitySection: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacing) {
                SettingsRow(
                    icon: "lock.rotation",
                    title: "Change Master Password",
                    color: .blue
                ) {
                    showChangePasswordSheet = true
                }

                Divider().padding(.leading, 60)

                SettingsRow(
                    icon: "timer",
                    title: "Auto-Lock",
                    subtitle: authService.autoLockDuration == 0 ? "Never" : "\(authService.autoLockDuration / 60) minutes",
                    color: .orange
                ) {
                    showAutoLockSheet = true
                }

                Divider().padding(.leading, 60)

                SettingsRow(
                    icon: "trash.fill",
                    title: "Clear Clipboard",
                    subtitle: "After 30 seconds",
                    color: .red
                ) {}
            }
            .padding()
        }
    }

    @ViewBuilder
    private var biometricSection: some View {
        if BiometricManager.shared.isAvailable {
            GlassCard {
                HStack {
                    Image(systemName: BiometricManager.shared.biometricType.iconName)
                        .font(.title2)
                        .foregroundColor(.green)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.green.opacity(0.2))
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(BiometricManager.shared.biometricType.displayName)")
                            .font(.headline)

                        Text(authService.isBiometricEnabled ? "Enabled" : "Disabled")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { authService.isBiometricEnabled },
                        set: { enabled in
                            if enabled {
                            } else {
                                authService.disableBiometric()
                            }
                        }
                    ))
                    .labelsHidden()
                }
                .padding()
            }
        }
    }

    private var backupSection: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacing) {
                SettingsRow(
                    icon: "square.and.arrow.up",
                    title: "Export Vault",
                    subtitle: "Create encrypted backup",
                    color: .blue
                ) {
                    showExportSheet = true
                }

                Divider().padding(.leading, 60)

                SettingsRow(
                    icon: "square.and.arrow.down",
                    title: "Import Vault",
                    subtitle: "Restore from backup",
                    color: .green
                ) {
                    showImportSheet = true
                }
            }
            .padding()
        }
    }

    private var aboutSection: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacing) {
                SettingsRow(
                    icon: "info.circle",
                    title: "Version",
                    subtitle: "1.0.0",
                    color: .gray
                ) {}

                Divider().padding(.leading, 60)

                NavigationLink(destination: PrivacySecurityView()) {
                    HStack(spacing: AppTheme.spacing) {
                        Image(systemName: "lock.shield.fill")
                            .font(.title3)
                            .foregroundColor(.purple)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(Color.purple.opacity(0.2))
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Privacy & Security")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                .buttonStyle(.plain)

                Divider().padding(.leading, 60)

                SettingsRow(
                    icon: "arrow.right.square.fill",
                    title: "Sign Out",
                    color: .red
                ) {
                    authService.logout()
                }
            }
            .padding()
        }
    }

    private func checkJailbreak() {
        if JailbreakDetector.shared.isJailbroken {
            showJailbreakWarning = true
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var subtitle: String?
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.spacing) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(color.opacity(0.2))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .buttonStyle(.plain)
    }
}
