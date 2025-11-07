import SwiftUI
import Combine

struct PasswordHealthView: View {
    @EnvironmentObject private var vault: VaultRepository
    @StateObject private var viewModel = PasswordHealthViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if vault.loginItems.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.spacing * 1.5) {
                        overallScoreCard

                        issuesSection
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Password Health")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.analyze(vault: vault)
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.spacing) {
            Image(systemName: "heart.text.square")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.secondary.opacity(0.5))

            Text("No Passwords Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Add some passwords to see your security health score")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private var overallScoreCard: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacing) {
                Text("Overall Score")
                    .font(.headline)
                    .foregroundColor(.secondary)

                ZStack {
                    Circle()
                        .stroke(.secondary.opacity(0.2), lineWidth: 15)
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0, to: CGFloat(viewModel.overallScore) / 100)
                        .stroke(
                            viewModel.scoreColor,
                            style: StrokeStyle(lineWidth: 15, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: viewModel.overallScore)

                    Text("\(viewModel.overallScore)%")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(viewModel.scoreColor)
                }

                Text(viewModel.scoreDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }

    private var issuesSection: some View {
        VStack(spacing: AppTheme.spacing) {
            if !viewModel.weakPasswords.isEmpty {
                NavigationLink(destination: WeakPasswordsListView(passwords: viewModel.weakPasswords)) {
                    IssueCard(
                        title: "Weak Passwords",
                        count: viewModel.weakPasswords.count,
                        icon: "exclamationmark.triangle.fill",
                        color: .red
                    )
                }
                .buttonStyle(.plain)
            }

            if !viewModel.reusedPasswords.isEmpty {
                NavigationLink(destination: ReusedPasswordsListView(passwords: viewModel.reusedPasswords)) {
                    IssueCard(
                        title: "Reused Passwords",
                        count: viewModel.reusedPasswords.count,
                        icon: "arrow.triangle.2.circlepath",
                        color: .orange
                    )
                }
                .buttonStyle(.plain)
            }

            if !viewModel.oldPasswords.isEmpty {
                NavigationLink(destination: OldPasswordsListView(passwords: viewModel.oldPasswords)) {
                    IssueCard(
                        title: "Old Passwords",
                        count: viewModel.oldPasswords.count,
                        icon: "clock.fill",
                        color: .yellow
                    )
                }
                .buttonStyle(.plain)
            }

            if viewModel.weakPasswords.isEmpty && viewModel.reusedPasswords.isEmpty && viewModel.oldPasswords.isEmpty {
                GlassCard {
                    VStack(spacing: AppTheme.spacing) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text("All Good!")
                            .font(.title3)
                            .fontWeight(.bold)

                        Text("Your passwords are secure and healthy")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
        }
    }
}

struct IssueCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color

    var body: some View {
        GlassCard {
            HStack(spacing: AppTheme.spacing) {
                Image(systemName: icon)
                    .font(.title2)
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

                    Text("\(count) affected")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

struct WeakPasswordsListView: View {
    let passwords: [LoginItem]

    var body: some View {
        PasswordIssueListView(
            items: passwords,
            title: "Weak Passwords",
            icon: "exclamationmark.triangle.fill",
            color: .red,
            description: "These passwords are too short or don't contain enough variety. Consider using the password generator to create stronger ones."
        )
    }
}

struct ReusedPasswordsListView: View {
    let passwords: [LoginItem]

    var body: some View {
        PasswordIssueListView(
            items: passwords,
            title: "Reused Passwords",
            icon: "arrow.triangle.2.circlepath",
            color: .orange,
            description: "These passwords are used in multiple accounts. If one account is compromised, all accounts with the same password are at risk."
        )
    }
}

struct OldPasswordsListView: View {
    let passwords: [LoginItem]

    var body: some View {
        PasswordIssueListView(
            items: passwords,
            title: "Old Passwords",
            icon: "clock.fill",
            color: .yellow,
            description: "These passwords haven't been changed in over 6 months. Regular password updates help maintain security."
        )
    }
}

struct PasswordIssueListView: View {
    let items: [LoginItem]
    let title: String
    let icon: String
    let color: Color
    let description: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.spacing) {
                    GlassCard {
                        VStack(spacing: AppTheme.spacing) {
                            Image(systemName: icon)
                                .font(.system(size: 50))
                                .foregroundColor(color)

                            Text(title)
                                .font(.title2)
                                .fontWeight(.bold)

                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }

                    ForEach(items) { item in
                        NavigationLink(destination: LoginDetailView(item: item)) {
                            LoginItemRow(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

final class PasswordHealthViewModel: ObservableObject {
    @Published var overallScore: Int = 100
    @Published var weakPasswords: [LoginItem] = []
    @Published var reusedPasswords: [LoginItem] = []
    @Published var oldPasswords: [LoginItem] = []

    var scoreColor: Color {
        if overallScore >= 80 { return .green }
        if overallScore >= 60 { return .yellow }
        if overallScore >= 40 { return .orange }
        return .red
    }

    var scoreDescription: String {
        if overallScore >= 80 { return "Excellent password security" }
        if overallScore >= 60 { return "Good, but room for improvement" }
        if overallScore >= 40 { return "Needs attention" }
        return "Critical issues detected"
    }

    func analyze(vault: VaultRepository) {
        analyzeWeakPasswords(vault.loginItems)
        analyzeReusedPasswords(vault.loginItems)
        analyzeOldPasswords(vault.loginItems)
        calculateOverallScore()
    }

    private func analyzeWeakPasswords(_ items: [LoginItem]) {
        weakPasswords = items.filter { item in
            let password = item.password
            return password.count < 12 ||
                   !password.contains(where: { $0.isUppercase }) ||
                   !password.contains(where: { $0.isLowercase }) ||
                   !password.contains(where: { $0.isNumber })
        }
    }

    private func analyzeReusedPasswords(_ items: [LoginItem]) {
        var passwordCounts: [String: Int] = [:]
        for item in items {
            passwordCounts[item.password, default: 0] += 1
        }

        reusedPasswords = items.filter { item in
            (passwordCounts[item.password] ?? 0) > 1
        }
    }

    private func analyzeOldPasswords(_ items: [LoginItem]) {
        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
        oldPasswords = items.filter { $0.modifiedAt < sixMonthsAgo }
    }

    private func calculateOverallScore() {
        var score = 100

        score -= weakPasswords.count * 10
        score -= reusedPasswords.count * 15
        score -= oldPasswords.count * 5

        overallScore = max(0, score)
    }
}
