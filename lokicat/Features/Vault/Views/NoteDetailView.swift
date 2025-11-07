import SwiftUI

struct NoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vault: VaultRepository
    @State private var item: SecureNote
    @State private var isEditing = false
    @State private var showDeleteAlert = false

    init(item: SecureNote) {
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
                    if isEditing {
                        editingFields
                    } else {
                        displayContent
                    }

                    if !isEditing {
                        actionButtons
                    }
                }
                .padding()
            }
        }
        .navigationTitle(item.title)
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
        .alert("Delete Note", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteItem()
            }
        } message: {
            Text("Are you sure you want to delete this note?")
        }
    }

    private var displayContent: some View {
        GlassCard {
            Text(item.content)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
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

                VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
                    Text("Content")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    TextEditor(text: Binding(
                        get: { item.content },
                        set: { item.content = $0 }
                    ))
                    .frame(minHeight: 150)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                            .fill(.thinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                }
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
}
