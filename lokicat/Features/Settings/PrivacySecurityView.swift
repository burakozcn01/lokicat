import SwiftUI

struct PrivacySecurityView: View {
    @EnvironmentObject private var authService: AuthenticationService

    var body: some View {
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
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )

                            Text("Your Privacy Matters")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("LokiCat is designed with privacy at its core. Your data never leaves your device.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }

                    FeatureCard(
                        icon: "lock.fill",
                        title: "AES-256 Encryption",
                        description: "All your passwords are encrypted with military-grade AES-256-GCM encryption.",
                        color: .blue
                    )

                    FeatureCard(
                        icon: "iphone.and.arrow.forward",
                        title: "Local-Only Storage",
                        description: "Your data is stored only on your device. We never sync or upload to any server.",
                        color: .green
                    )

                    FeatureCard(
                        icon: "key.fill",
                        title: "Secure Enclave",
                        description: "Cryptographic keys are protected by Apple's Secure Enclave hardware.",
                        color: .purple
                    )

                    FeatureCard(
                        icon: "eye.slash.fill",
                        title: "Zero Knowledge",
                        description: "Your master password is never stored. Only a secure hash is kept locally.",
                        color: .orange
                    )

                    FeatureCard(
                        icon: "trash.fill",
                        title: "Auto-Clear Clipboard",
                        description: "Copied passwords are automatically cleared after 30 seconds.",
                        color: .red
                    )

                    GlassCard {
                        VStack(spacing: AppTheme.smallSpacing) {
                            Text("Open Source Soon")
                                .font(.headline)

                            Text("LokiCat will be open-sourced so you can verify our security claims.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Privacy & Security")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        GlassCard {
            HStack(spacing: AppTheme.spacing) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(color.opacity(0.2))
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding()
        }
    }
}
