import SwiftUI
import Domain

@main
struct MetadataKillApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environment(\.locale, appState.currentLocale)
        }
    }
}

/// Global app state
@MainActor
final class AppState: ObservableObject {
    @Published var settings: CleaningSettings {
        didSet {
            updateLocale()
        }
    }
    @Published var currentLocale: Locale = .current
    
    init() {
        // Load settings from UserDefaults or use defaults
        if let data = UserDefaults.standard.data(forKey: "CleaningSettings"),
           let settings = try? JSONDecoder().decode(CleaningSettings.self, from: data) {
            self.settings = settings
        } else {
            self.settings = .default
        }
        updateLocale()
    }
    
    func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: "CleaningSettings")
        }
        updateLocale()
    }
    
    private func updateLocale() {
        if let languageCode = settings.appLanguage.languageCode {
            currentLocale = Locale(identifier: languageCode)
            UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        } else {
            currentLocale = .current
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        }
    }
}
