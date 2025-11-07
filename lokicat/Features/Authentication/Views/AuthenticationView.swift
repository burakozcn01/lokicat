import SwiftUI

struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @EnvironmentObject private var authService: AuthenticationService
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showOnboarding = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.spacing * 2) {
                    Spacer()
                        .frame(height: 60)

                    appLogo

                    if viewModel.isSetup {
                        loginSection
                    } else {
                        setupSection
                    }

                    Spacer()
                }
                .padding(AppTheme.spacing * 1.5)
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(showOnboarding: $showOnboarding)
        }
        .onAppear {
            if !hasSeenOnboarding && !viewModel.isSetup {
                showOnboarding = true
                hasSeenOnboarding = true
            }
        }
    }

    private var appLogo: some View {
        VStack(spacing: AppTheme.spacing) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)

            Text("LokiCat")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Secure Password Manager")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var setupSection: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacing * 1.5) {
                VStack(spacing: AppTheme.smallSpacing) {
                    Text("Create Master Password")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("This password will protect all your data. Choose a strong password you'll remember.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                VStack(spacing: AppTheme.spacing) {
                    GlassTextField(
                        title: "Master Password",
                        placeholder: "Enter a strong password",
                        text: $viewModel.masterPassword,
                        isSecure: true,
                        icon: "lock.fill",
                        textContentType: .newPassword
                    )

                    GlassTextField(
                        title: "Confirm Password",
                        placeholder: "Re-enter your password",
                        text: $viewModel.confirmPassword,
                        isSecure: true,
                        icon: "lock.fill",
                        textContentType: .newPassword
                    )
                }

                GlassButton("Create Vault", icon: "checkmark.shield.fill") {
                    viewModel.setup()
                }
                .disabled(viewModel.isLoading)
                .padding(.top)
            }
            .padding(AppTheme.spacing * 1.5)
        }
    }

    private var loginSection: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacing * 1.5) {
                VStack(spacing: AppTheme.smallSpacing) {
                    Text("Welcome Back")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Enter your master password to unlock")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                if viewModel.isLockedOut {
                    lockoutView
                } else {
                    VStack(spacing: AppTheme.spacing) {
                        GlassTextField(
                            title: "Master Password",
                            placeholder: "Enter your password",
                            text: $viewModel.masterPassword,
                            isSecure: true,
                            icon: "lock.fill",
                            textContentType: .password
                        )

                        GlassButton("Unlock", icon: "lock.open.fill") {
                            viewModel.login()
                        }
                        .disabled(viewModel.isLoading)

                        if authService.isBiometricEnabled && viewModel.isBiometricAvailable {
                            Divider()
                                .padding(.vertical, AppTheme.smallSpacing)

                            GlassButton(
                                "Unlock with \(viewModel.biometricType.displayName)",
                                icon: viewModel.biometricType.iconName,
                                style: .secondary
                            ) {
                                viewModel.loginWithBiometric()
                            }
                            .disabled(viewModel.isLoading)
                        }
                    }
                }
            }
            .padding(AppTheme.spacing * 1.5)
        }
    }

    private var lockoutView: some View {
        VStack(spacing: AppTheme.spacing) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.red)

            Text("Account Locked")
                .font(.title3)
                .fontWeight(.bold)

            Text("Too many failed attempts")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Try again in \(viewModel.lockoutTime / 60) minutes")
                .font(.headline)
                .foregroundColor(.red)
        }
        .padding()
    }
}
