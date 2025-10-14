// MetadataKill App Wrapper
// This is a minimal wrapper that uses the App module from the Swift Package

import SwiftUI
import Domain

@main
struct MetadataKillWrapperApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

/// Global app state
@MainActor
final class AppState: ObservableObject {
    @Published var settings: CleaningSettings
    
    init() {
        // Load settings from UserDefaults or use defaults
        if let data = UserDefaults.standard.data(forKey: "CleaningSettings"),
           let settings = try? JSONDecoder().decode(CleaningSettings.self, from: data) {
            self.settings = settings
        } else {
            self.settings = .default
        }
    }
    
    func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: "CleaningSettings")
        }
    }
}
