import SwiftUI

struct AddItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vault: VaultRepository
    @State private var selectedType: VaultItemType = .login
    @State private var title = ""
    @State private var username = ""
    @State private var password = ""
    @State private var url = ""
    @State private var content = ""
    @State private var cardholderName = ""
    @State private var cardNumber = ""
    @State private var expirationMonth = 1
    @State private var expirationYear = 2025
    @State private var cvv = ""

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
                    VStack(spacing: AppTheme.spacing) {
                        typeSelector

                        GlassCard {
                            VStack(spacing: AppTheme.spacing) {
                                GlassTextField(
                                    title: "Title",
                                    placeholder: "Enter title",
                                    text: $title,
                                    icon: "text.alignleft",
                                    textContentType: .name
                                )

                                if selectedType == .login {
                                    loginFields
                                } else if selectedType == .creditCard {
                                    cardFields
                                } else if selectedType == .secureNote {
                                    noteFields
                                }
                            }
                            .padding()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private var typeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.smallSpacing) {
                ForEach([VaultItemType.login, .secureNote, .creditCard], id: \.self) { type in
                    Button {
                        selectedType = type
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: type.icon)
                                .font(.title2)
                            Text(type.displayName)
                                .font(.caption)
                        }
                        .frame(width: 80, height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                .fill(selectedType == type ? .blue.opacity(0.2) : .clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                .stroke(selectedType == type ? .blue : .white.opacity(0.3), lineWidth: 1.5)
                        )
                        .foregroundColor(selectedType == type ? .blue : .primary)
                    }
                }
            }
        }
    }

    private var loginFields: some View {
        Group {
            GlassTextField(
                title: "Username",
                placeholder: "Enter username or email",
                text: $username,
                icon: "person.fill",
                keyboardType: .emailAddress,
                textContentType: .username
            )

            GlassTextField(
                title: "Password",
                placeholder: "Enter password",
                text: $password,
                isSecure: true,
                icon: "key.fill",
                textContentType: .newPassword
            )

            GlassTextField(
                title: "Website (Optional)",
                placeholder: "https://example.com",
                text: $url,
                icon: "link",
                keyboardType: .URL,
                textContentType: .URL
            )
        }
    }

    private var noteFields: some View {
        GlassTextField(
            title: "Content",
            placeholder: "Enter your secure note",
            text: $content,
            icon: "note.text"
        )
    }

    private var cardFields: some View {
        Group {
            GlassTextField(
                title: "Cardholder Name",
                placeholder: "Enter name on card",
                text: $cardholderName,
                icon: "person.fill",
                textContentType: .name
            )

            GlassTextField(
                title: "Card Number",
                placeholder: "0000 0000 0000 0000",
                text: $cardNumber,
                icon: "creditcard.fill",
                keyboardType: .numberPad
            )

            HStack(spacing: AppTheme.spacing) {
                VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
                    Text("Expiry Month")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Picker("", selection: $expirationMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text(String(format: "%02d", month)).tag(month)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                            .fill(.thinMaterial)
                    )
                }

                VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
                    Text("Year")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Picker("", selection: $expirationYear) {
                        ForEach(2025...2040, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                            .fill(.thinMaterial)
                    )
                }
            }

            GlassTextField(
                title: "CVV",
                placeholder: "123",
                text: $cvv,
                isSecure: true,
                icon: "lock.fill",
                keyboardType: .numberPad
            )
        }
    }

    private func saveItem() {
        switch selectedType {
        case .login:
            let item = LoginItem(
                title: title,
                username: username,
                password: password,
                url: url.isEmpty ? nil : url
            )
            try? vault.save(item)
        case .creditCard:
            let item = CreditCard(
                title: title,
                cardholderName: cardholderName,
                cardNumber: cardNumber,
                expirationMonth: expirationMonth,
                expirationYear: expirationYear,
                cvv: cvv
            )
            try? vault.save(item)
        case .secureNote:
            let item = SecureNote(
                title: title,
                content: content
            )
            try? vault.save(item)
        default:
            break
        }
        dismiss()
    }
}

extension VaultItemType {
    var displayName: String {
        switch self {
        case .login: return "Login"
        case .secureNote: return "Note"
        case .creditCard: return "Card"
        case .identity: return "Identity"
        case .wifiPassword: return "Wi-Fi"
        case .apiKey: return "API Key"
        }
    }

    var icon: String {
        switch self {
        case .login: return "person.fill"
        case .secureNote: return "note.text"
        case .creditCard: return "creditcard.fill"
        case .identity: return "person.text.rectangle"
        case .wifiPassword: return "wifi"
        case .apiKey: return "key.fill"
        }
    }
}
