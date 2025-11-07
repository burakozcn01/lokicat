import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: AppTheme.Glass.shadowRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(.white.opacity(AppTheme.Glass.borderOpacity), lineWidth: 1)
            )
    }
}

struct SmallGlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .fill(.thinMaterial)
                    .shadow(color: .black.opacity(0.05), radius: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .stroke(.white.opacity(AppTheme.Glass.borderOpacity), lineWidth: 0.5)
            )
    }
}
