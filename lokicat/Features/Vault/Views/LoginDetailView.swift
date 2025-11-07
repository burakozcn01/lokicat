import SwiftUI

struct LoginDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vault: VaultRepository
    @State private var item: LoginItem
    @State private var isEditing = false
    @State private var showDeleteAlert = false
    @State private var copiedField: String?

    init(item: LoginItem) {
        _item = State(initialValue: item)
    }

    var body: some View {
        ZStack {
            backgroundGradient

            ScrollView {
                VStack(spacing: AppTheme.spacing) {
                    headerSection

                    if isEditing {
                        editingFields
                    } else {
                        displayFields
                    }

                    if !isEditing {
                        actionButtons
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    if isEditing {
                        saveChanges()
                    }
                    isEditing.toggle()
                }
            }
        }
        .alert("Delete Item", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteItem()
            }
        } message: {
            Text("Are you sure you want to delete this item?")
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var headerSection: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacing) {
                if let faviconURL = item.faviconURL,
                   let url = URL(string: faviconURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Image(systemName: "globe")
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Text(item.title)
                    .font(.title2)
                    .fontWeight(.bold)

                if let domain = item.domain {
                    Text(domain)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }

    private var displayFields: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacing) {
                DetailField(
                    title: "Username",
                    value: item.username,
                    icon: "person.fill",
                    canCopy: true,
                    onCopy: { copyToClipboard(item.username, field: "Username") }
                )

                Divider()

                DetailField(
                    title: "Password",
                    value: item.password,
                    icon: "key.fill",
                    isSecure: true,
                    canCopy: true,
                    onCopy: { copyToClipboard(item.password, field: "Password") }
                )

                if let url = item.url {
                    Divider()
                    DetailField(
                        title: "Website",
                        value: url,
                        icon: "link",
                        canCopy: true,
                        onCopy: { copyToClipboard(url, field: "Website") }
                    )
                }

                if let notes = item.notes, !notes.isEmpty {
                    Divider()
                    DetailField(
                        title: "Notes",
                        value: notes,
                        icon: "note.text"
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }

    private var editingFields: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacing) {
                GlassTextField(
                    title: "Title",
                    placeholder: "Enter title",
                    text: Binding(
                        get: { item.title },
                        set: { item.title = $0 }
                    ),
                    icon: "text.alignleft",
                    textContentType: .name
                )

                GlassTextField(
                    title: "Username",
                    placeholder: "Enter username",
                    text: Binding(
                        get: { item.username },
                        set: { item.username = $0 }
                    ),
                    icon: "person.fill",
                    keyboardType: .emailAddress,
                    textContentType: .username
                )

                GlassTextField(
                    title: "Password",
                    placeholder: "Enter password",
                    text: Binding(
                        get: { item.password },
                        set: { item.password = $0 }
                    ),
                    isSecure: true,
                    icon: "key.fill",
                    textContentType: .password
                )

                GlassTextField(
                    title: "Website",
                    placeholder: "https://example.com",
                    text: Binding(
                        get: { item.url ?? "" },
                        set: { item.url = $0.isEmpty ? nil : $0 }
                    ),
                    icon: "link",
                    keyboardType: .URL,
                    textContentType: .URL
                )
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }

    private var actionButtons: some View {
        VStack(spacing: AppTheme.spacing) {
            Button {
                item.isFavorite.toggle()
                saveChanges()
            } label: {
                HStack {
                    Image(systemName: item.isFavorite ? "star.fill" : "star")
                    Text(item.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            }

            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            }
        }
    }

    private func saveChanges() {
        try? vault.save(item)
    }

    private func deleteItem() {
        try? vault.delete(item)
        dismiss()
    }

    private func copyToClipboard(_ value: String, field: String) {
        UIPasteboard.general.string = value
        copiedField = field

        ClipboardManager.shared.scheduleClipboardClear()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            copiedField = nil
        }
    }
}

struct DetailField: View {
    let title: String
    let value: String
    let icon: String
    var isSecure: Bool = false
    var canCopy: Bool = false
    var onCopy: (() -> Void)?

    @State private var isRevealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                Spacer()

                if isSecure {
                    Button {
                        isRevealed.toggle()
                    } label: {
                        Image(systemName: isRevealed ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.secondary)
                    }
                }

                if canCopy {
                    Button {
                        onCopy?()
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.blue)
                    }
                }
            }

            Text(isSecure && !isRevealed ? String(repeating: "•", count: 12) : value)
                .font(.body)
                .textSelection(.enabled)
        }
    }
}
