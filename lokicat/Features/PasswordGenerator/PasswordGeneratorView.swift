import SwiftUI
import Combine

struct PasswordGeneratorView: View {
    @StateObject private var viewModel = PasswordGeneratorViewModel()

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
                    generatedPasswordSection

                    optionsSection

                    strengthIndicator
                }
                .padding()
            }
        }
        .navigationTitle("Password Generator")
        .navigationBarTitleDisplayMode(.large)
    }

    private var generatedPasswordSection: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacing) {
                Text(viewModel.generatedPassword)
                    .font(.title2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .textSelection(.enabled)
                    .padding()

                HStack(spacing: AppTheme.spacing) {
                    GlassButton("Copy", icon: "doc.on.doc") {
                        viewModel.copyPassword()
                    }

                    GlassButton("Regenerate", icon: "arrow.clockwise") {
                        viewModel.generatePassword()
                    }
                }
            }
            .padding()
        }
    }

    private var optionsSection: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacing * 1.5) {
                VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
                    Text("Length: \(viewModel.length)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Slider(value: Binding(
                        get: { Double(viewModel.length) },
                        set: { viewModel.length = Int($0) }
                    ), in: 8...64, step: 1)
                    .onChange(of: viewModel.length) { _ in
                        viewModel.generatePassword()
                    }
                }

                Divider()

                VStack(spacing: AppTheme.spacing) {
                    ToggleOption(
                        title: "Uppercase (A-Z)",
                        isOn: $viewModel.includeUppercase
                    )
                    .onChange(of: viewModel.includeUppercase) { _ in
                        viewModel.generatePassword()
                    }

                    ToggleOption(
                        title: "Lowercase (a-z)",
                        isOn: $viewModel.includeLowercase
                    )
                    .onChange(of: viewModel.includeLowercase) { _ in
                        viewModel.generatePassword()
                    }

                    ToggleOption(
                        title: "Numbers (0-9)",
                        isOn: $viewModel.includeNumbers
                    )
                    .onChange(of: viewModel.includeNumbers) { _ in
                        viewModel.generatePassword()
                    }

                    ToggleOption(
                        title: "Symbols (!@#$%)",
                        isOn: $viewModel.includeSymbols
                    )
                    .onChange(of: viewModel.includeSymbols) { _ in
                        viewModel.generatePassword()
                    }
                }
            }
            .padding()
        }
    }

    private var strengthIndicator: some View {
        GlassCard {
            VStack(spacing: AppTheme.smallSpacing) {
                HStack {
                    Text("Strength")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(viewModel.strength.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.strength.color)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(.secondary.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)

                        Rectangle()
                            .fill(viewModel.strength.color)
                            .frame(width: geometry.size.width * viewModel.strength.percentage, height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
            .padding()
        }
    }
}

struct ToggleOption: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(title, isOn: $isOn)
            .toggleStyle(SwitchToggleStyle(tint: .blue))
    }
}

final class PasswordGeneratorViewModel: ObservableObject {
    @Published var generatedPassword = ""
    @Published var length = 16
    @Published var includeUppercase = true
    @Published var includeLowercase = true
    @Published var includeNumbers = true
    @Published var includeSymbols = true

    init() {
        generatePassword()
    }

    func generatePassword() {
        var characterSet = ""

        if includeUppercase { characterSet += "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
        if includeLowercase { characterSet += "abcdefghijklmnopqrstuvwxyz" }
        if includeNumbers { characterSet += "0123456789" }
        if includeSymbols { characterSet += "!@#$%^&*()_+-=[]{}|;:,.<>?" }

        guard !characterSet.isEmpty else {
            generatedPassword = ""
            return
        }

        generatedPassword = String((0..<length).compactMap { _ in
            characterSet.randomElement()
        })
    }

    func copyPassword() {
        UIPasteboard.general.string = generatedPassword
        ClipboardManager.shared.scheduleClipboardClear()
    }

    var strength: PasswordStrength {
        let score = calculateStrength()
        if score >= 80 { return .veryStrong }
        if score >= 60 { return .strong }
        if score >= 40 { return .medium }
        if score >= 20 { return .weak }
        return .veryWeak
    }

    private func calculateStrength() -> Int {
        var score = 0

        score += min(length * 4, 40)

        if includeUppercase { score += 10 }
        if includeLowercase { score += 10 }
        if includeNumbers { score += 15 }
        if includeSymbols { score += 25 }

        return min(score, 100)
    }
}

enum PasswordStrength {
    case veryWeak, weak, medium, strong, veryStrong

    var displayName: String {
        switch self {
        case .veryWeak: return "Very Weak"
        case .weak: return "Weak"
        case .medium: return "Medium"
        case .strong: return "Strong"
        case .veryStrong: return "Very Strong"
        }
    }

    var color: Color {
        switch self {
        case .veryWeak: return .red
        case .weak: return .orange
        case .medium: return .yellow
        case .strong: return .green
        case .veryStrong: return .blue
        }
    }

    var percentage: CGFloat {
        switch self {
        case .veryWeak: return 0.2
        case .weak: return 0.4
        case .medium: return 0.6
        case .strong: return 0.8
        case .veryStrong: return 1.0
        }
    }
}
