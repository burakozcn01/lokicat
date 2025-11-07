import SwiftUI

struct AutoLockSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authService: AuthenticationService

    let durations = [
        (60, "1 minute"),
        (300, "5 minutes"),
        (600, "10 minutes"),
        (900, "15 minutes"),
        (1800, "30 minutes"),
        (3600, "1 hour"),
        (0, "Never")
    ]

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                List {
                    ForEach(durations, id: \.0) { duration in
                        Button {
                            authService.setAutoLockDuration(duration.0)
                            dismiss()
                        } label: {
                            HStack {
                                Text(duration.1)
                                    .foregroundColor(.primary)
                                Spacer()
                                if authService.autoLockDuration == duration.0 {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Auto-Lock")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
