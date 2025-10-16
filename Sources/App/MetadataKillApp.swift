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
    @Published var localizationVersion: Int = 0 // Used to force UI updates
    
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
        // Force UI refresh by incrementing version
        localizationVersion += 1
    }
    
    private func updateLocale() {
        if let languageCode = settings.appLanguage.languageCode {
            currentLocale = Locale(identifier: languageCode)
            UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        } else {
            currentLocale = .current
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }
        // Notify that localization has changed
        NotificationCenter.default.post(name: .localizationDidChange, object: nil)
    }
}

// Notification for localization changes
extension Notification.Name {
    static let localizationDidChange = Notification.Name("localizationDidChange")
}
