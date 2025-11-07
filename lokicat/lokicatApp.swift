import SwiftUI

@main
struct lokicatApp: App {
    @StateObject private var authService = AuthenticationService.shared
    @StateObject private var vault = VaultRepository.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(vault)
                .preferredColorScheme(.dark)
        }
    }
}
