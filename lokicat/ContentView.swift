import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authService: AuthenticationService

    var body: some View {
        Group {
            if authService.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .animation(.easeInOut, value: authService.isAuthenticated)
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                VaultListView()
            }
            .tabItem {
                Label("Vault", systemImage: "lock.shield.fill")
            }
            .tag(0)

            NavigationView {
                PasswordGeneratorView()
            }
            .tabItem {
                Label("Generator", systemImage: "key.fill")
            }
            .tag(1)

            NavigationView {
                PasswordHealthView()
            }
            .tabItem {
                Label("Health", systemImage: "heart.fill")
            }
            .tag(2)

            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(3)
        }
        .accentColor(.blue)
    }
}
