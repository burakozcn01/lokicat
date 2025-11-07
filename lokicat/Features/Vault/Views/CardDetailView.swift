import SwiftUI

struct CardDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vault: VaultRepository
    @State private var item: CreditCard
    @State private var isEditing = false
    @State private var showDeleteAlert = false
    @State private var copiedField: String?

    init(item: CreditCard) {
        _item = State(initialValue: item)
    }

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
                    cardPreview

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
        .alert("Delete Card", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteItem()
            }
        } message: {
            Text("Are you sure you want to delete this card?")
        }
    }

    private var cardPreview: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacing) {
                HStack {
                    Image(systemName: item.cardType.iconName)
                        .font(.largeTitle)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Spacer()
                    Text(item.cardType.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(item.maskedCardNumber)
                    .font(.title2)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack {
                    Text(item.cardholderName)
                        .font(.subheadline)
                        .textCase(.uppercase)
                    Spacer()
                    Text(item.expirationDate)
                        .font(.subheadline)
                        .foregroundColor(item.isExpired ? .red : .secondary)
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
                    title: "Card Number",
                    value: item.cardNumber,
                    icon: "creditcard.fill",
                    isSecure: true,
                    canCopy: true,
                    onCopy: { copyToClipboard(item.cardNumber, field: "Card Number") }
                )

                Divider()

                DetailField(
                    title: "CVV",
                    value: item.cvv,
                    icon: "lock.fill",
                    isSecure: true,
                    canCopy: true,
                    onCopy: { copyToClipboard(item.cvv, field: "CVV") }
                )

                Divider()

                DetailField(
                    title: "Expiry",
                    value: item.expirationDate,
                    icon: "calendar"
                )
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
                    icon: "text.alignleft"
                )

                GlassTextField(
                    title: "Cardholder Name",
                    placeholder: "Name on card",
                    text: Binding(
                        get: { item.cardholderName },
                        set: { item.cardholderName = $0 }
                    ),
                    icon: "person.fill"
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
