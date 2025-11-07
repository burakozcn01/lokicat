import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "lock.shield.fill",
            title: "Secure & Private",
            description: "All your passwords are encrypted with AES-256 and stored locally on your device. We never see your data.",
            color: .blue
        ),
        OnboardingPage(
            icon: "faceid",
            title: "Biometric Lock",
            description: "Use Face ID or Touch ID to quickly and securely access your vault without typing passwords.",
            color: .green
        ),
        OnboardingPage(
            icon: "key.fill",
            title: "Strong Passwords",
            description: "Generate secure passwords and get health scores to keep your accounts safe from breaches.",
            color: .purple
        ),
        OnboardingPage(
            icon: "square.and.arrow.up.fill",
            title: "Encrypted Backups",
            description: "Create encrypted backups of your vault. Your data stays secure even in backups.",
            color: .orange
        )
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                VStack(spacing: AppTheme.spacing) {
                    if currentPage == pages.count - 1 {
                        GlassButton("Get Started", icon: "arrow.right") {
                            showOnboarding = false
                        }
                        .padding(.horizontal, 40)
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        Button {
                            showOnboarding = false
                        } label: {
                            Text("Skip")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 20)
                    }
                }
                .animation(.spring(), value: currentPage)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: AppTheme.spacing * 2) {
            Spacer()

            Image(systemName: page.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(
                    LinearGradient(
                        colors: [page.color, page.color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(40)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .shadow(color: page.color.opacity(0.3), radius: 20)
                )

            VStack(spacing: AppTheme.spacing) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()
        }
        .padding()
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}
