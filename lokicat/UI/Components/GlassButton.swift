import SwiftUI

struct GlassButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var style: ButtonStyle = .primary

    init(_ title: String, icon: String? = nil, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.smallSpacing) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(style.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(style.borderColor, lineWidth: 1)
            )
            .shadow(color: style.shadowColor, radius: 8, y: 4)
        }
        .foregroundColor(style.foreground)
    }

    enum ButtonStyle {
        case primary
        case secondary
        case destructive

        var background: Material {
            switch self {
            case .primary: return .regularMaterial
            case .secondary: return .thinMaterial
            case .destructive: return .regularMaterial
            }
        }

        var foreground: Color {
            switch self {
            case .primary: return .blue
            case .secondary: return .primary
            case .destructive: return .red
            }
        }

        var borderColor: Color {
            switch self {
            case .primary: return .blue.opacity(0.3)
            case .secondary: return .white.opacity(0.2)
            case .destructive: return .red.opacity(0.3)
            }
        }

        var shadowColor: Color {
            switch self {
            case .primary: return .blue.opacity(0.2)
            case .secondary: return .black.opacity(0.1)
            case .destructive: return .red.opacity(0.2)
            }
        }
    }
}
