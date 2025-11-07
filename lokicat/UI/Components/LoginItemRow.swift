import SwiftUI

struct LoginItemRow: View {
    let item: LoginItem

    var body: some View {
        SmallGlassCard {
            HStack(spacing: AppTheme.spacing) {
                if let faviconURL = item.faviconURL,
                   let url = URL(string: faviconURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Image(systemName: "globe")
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: "globe")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 40)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(item.username)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if item.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(AppTheme.spacing)
        }
    }
}

struct CardItemRow: View {
    let item: CreditCard

    var body: some View {
        SmallGlassCard {
            HStack(spacing: AppTheme.spacing) {
                Image(systemName: item.cardType.iconName)
                    .font(.title2)
                    .foregroundColor(.green)
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(item.maskedCardNumber)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if item.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(AppTheme.spacing)
        }
    }
}

struct NoteItemRow: View {
    let item: SecureNote

    var body: some View {
        SmallGlassCard {
            HStack(spacing: AppTheme.spacing) {
                Image(systemName: "note.text")
                    .font(.title2)
                    .foregroundColor(.purple)
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(item.content)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if item.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(AppTheme.spacing)
        }
    }
}

struct FavoriteItemRow: View {
    let item: AnyVaultItem

    var body: some View {
        Group {
            if let login = item.base as? LoginItem {
                LoginItemRow(item: login)
            } else if let card = item.base as? CreditCard {
                CardItemRow(item: card)
            } else if let note = item.base as? SecureNote {
                NoteItemRow(item: note)
            }
        }
    }
}
