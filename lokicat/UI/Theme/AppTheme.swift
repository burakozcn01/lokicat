import SwiftUI

struct AppTheme {
    static let cornerRadius: CGFloat = 20
    static let smallCornerRadius: CGFloat = 12
    static let spacing: CGFloat = 16
    static let smallSpacing: CGFloat = 8

    struct Glass {
        static let blur: CGFloat = 20
        static let opacity: CGFloat = 0.15
        static let borderOpacity: CGFloat = 0.3
        static let shadowRadius: CGFloat = 10
    }

    struct Colors {
        static let primary = Color.blue
        static let secondary = Color.purple
        static let accent = Color.cyan
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let text = Color.primary
        static let secondaryText = Color.secondary
    }
}
