import SwiftUI

struct VaultListView: View {
    @EnvironmentObject private var vault: VaultRepository
    @State private var searchText = ""
    @State private var selectedFilter: VaultFilter = .all
    @State private var showingAddSheet = false

    var body: some View {
        ZStack {
            backgroundGradient

            ScrollView {
                VStack(spacing: AppTheme.spacing) {
                    filterSection

                    if filteredItems.isEmpty {
                        emptyState
                    } else {
                        itemsList
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Vault")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search vault...")
        .sheet(isPresented: $showingAddSheet) {
            AddItemSheet()
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

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.smallSpacing) {
                ForEach(VaultFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.title,
                        icon: filter.icon,
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation(.spring()) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private var itemsList: some View {
        LazyVStack(spacing: AppTheme.spacing) {
            if selectedFilter == .all || selectedFilter == .logins {
                ForEach(filteredLogins) { item in
                    NavigationLink(destination: LoginDetailView(item: item)) {
                        LoginItemRow(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }

            if selectedFilter == .all || selectedFilter == .cards {
                ForEach(filteredCards) { item in
                    NavigationLink(destination: CardDetailView(item: item)) {
                        CardItemRow(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }

            if selectedFilter == .all || selectedFilter == .notes {
                ForEach(filteredNotes) { item in
                    NavigationLink(destination: NoteDetailView(item: item)) {
                        NoteItemRow(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }

            if selectedFilter == .favorites {
                ForEach(favoriteItems, id: \.id) { item in
                    FavoriteItemRow(item: item)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.spacing) {
            Image(systemName: "tray.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.secondary.opacity(0.5))

            Text("No items yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Tap + to add your first item")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 100)
    }

    private var filteredLogins: [LoginItem] {
        vault.loginItems.filter { item in
            searchText.isEmpty || item.searchableContent.contains(searchText.lowercased())
        }
    }

    private var filteredCards: [CreditCard] {
        vault.creditCards.filter { item in
            searchText.isEmpty || item.searchableContent.contains(searchText.lowercased())
        }
    }

    private var filteredNotes: [SecureNote] {
        vault.secureNotes.filter { item in
            searchText.isEmpty || item.searchableContent.contains(searchText.lowercased())
        }
    }

    private var favoriteItems: [AnyVaultItem] {
        var items: [AnyVaultItem] = []
        items += vault.loginItems.filter { $0.isFavorite }.map { AnyVaultItem($0) }
        items += vault.creditCards.filter { $0.isFavorite }.map { AnyVaultItem($0) }
        items += vault.secureNotes.filter { $0.isFavorite }.map { AnyVaultItem($0) }
        return items
    }

    private var filteredItems: [Any] {
        switch selectedFilter {
        case .all:
            return filteredLogins + filteredCards + filteredNotes
        case .logins:
            return filteredLogins
        case .cards:
            return filteredCards
        case .notes:
            return filteredNotes
        case .favorites:
            return favoriteItems
        }
    }
}

enum VaultFilter: CaseIterable {
    case all
    case favorites
    case logins
    case cards
    case notes

    var title: String {
        switch self {
        case .all: return "All"
        case .favorites: return "Favorites"
        case .logins: return "Logins"
        case .cards: return "Cards"
        case .notes: return "Notes"
        }
    }

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .favorites: return "star.fill"
        case .logins: return "person.fill"
        case .cards: return "creditcard.fill"
        case .notes: return "note.text"
        }
    }
}

struct AnyVaultItem: Identifiable {
    let id: UUID
    let base: Any

    init<T: VaultItem>(_ item: T) {
        self.id = item.id
        self.base = item
    }
}
