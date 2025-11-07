import SwiftUI

struct GlassTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var icon: String?
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?

    @State private var isShowingPassword = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            HStack(spacing: AppTheme.smallSpacing) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(.secondary)
                }

                Group {
                    if isSecure && !isShowingPassword {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .textFieldStyle(.plain)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(keyboardType)
                .textContentType(textContentType)

                if isSecure {
                    Button {
                        isShowingPassword.toggle()
                    } label: {
                        Image(systemName: isShowingPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
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
}
