import SwiftUI
import Domain

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                homeContent
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gear")
                                    .accessibilityLabel("settings.title".localized)
                            }
                        }
                    }
            }
        } else {
            NavigationView {
                homeContent
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gear")
                                    .accessibilityLabel("settings.title".localized)
                            }
                        }
                    }
            }
            .navigationViewStyle(.stack)
        }
    }
    
    private var homeContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Section with Enhanced Gradient
                ZStack {
                    // Multi-layer gradient for depth
                    LinearGradient(
                        colors: [
                            Color(red: 0.0, green: 0.48, blue: 0.99),
                            Color(red: 0.36, green: 0.20, blue: 0.85),
                            Color(red: 0.58, green: 0.12, blue: 0.75)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea(edges: .top)
                    
                    // Subtle overlay pattern
                    LinearGradient(
                        colors: [Color.white.opacity(0.1), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                    .ignoresSafeArea(edges: .top)
                    
                    VStack(spacing: 20) {
                        // Icon with glow effect
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 110, height: 110)
                                .blur(radius: 20)
                            
                            Image(systemName: "shield.lefthalf.filled")
                                .font(.system(size: 75, weight: .medium))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .white.opacity(0.9)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
                        }
                        .padding(.top, 8)
                        
                        VStack(spacing: 12) {
                            Text("app.title".localized)
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            
                            Text("home.hero.tagline".localized)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.98))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Text("home.hero.description".localized)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.90))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.vertical, 50)
                }
                .frame(maxWidth: .infinity)
                
                // Trust Badges with Enhanced Design
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        TrustBadge(icon: "lock.shield.fill", text: "home.badge.privacy".localized, color: .green)
                        TrustBadge(icon: "bolt.fill", text: "home.badge.fast".localized, color: .orange)
                        TrustBadge(icon: "checkmark.seal.fill", text: "home.badge.quality".localized, color: .blue)
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Trust indicators")
                }
                .padding(.horizontal)
                .padding(.vertical, 28)
                .background(
                    LinearGradient(
                        colors: [Color(.systemBackground), Color(.secondarySystemBackground).opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Features Section with Modern Design
                VStack(alignment: .leading, spacing: 20) {
                    Text("home.features.title".localized)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 14) {
                        FeatureRow(icon: "location.slash.fill", title: "home.feature.gps".localized, color: .red)
                        FeatureRow(icon: "camera.fill", title: "home.feature.exif".localized, color: .orange)
                        FeatureRow(icon: "mappin.slash", title: "home.feature.location".localized, color: .green)
                        FeatureRow(icon: "iphone.and.arrow.forward", title: "home.feature.ondevice".localized, color: .blue)
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Key features")
                    .padding(.horizontal)
                }
                .padding(.vertical, 28)
                .background(Color(.secondarySystemBackground))
                
                // Main Actions with Premium Design
                VStack(spacing: 18) {
                    Text("home.actions.title".localized)
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 28)
                    
                    NavigationLink(destination: ImageCleanerView()) {
                        ActionButton(
                            title: "home.clean_photos".localized,
                            subtitle: "home.clean_photos.subtitle".localized,
                            icon: "photo.stack",
                            color: .blue,
                            accentColor: Color(red: 0.0, green: 0.48, blue: 0.99)
                        )
                    }
                    
                    NavigationLink(destination: VideoCleanerView()) {
                        ActionButton(
                            title: "home.clean_videos".localized,
                            subtitle: "home.clean_videos.subtitle".localized,
                            icon: "video.fill",
                            color: .purple,
                            accentColor: Color(red: 0.58, green: 0.12, blue: 0.75)
                        )
                    }
                    
                    NavigationLink(destination: BatchProcessorView()) {
                        ActionButton(
                            title: "home.batch_processing".localized,
                            subtitle: "home.batch_processing.subtitle".localized,
                            icon: "square.stack.3d.up.fill",
                            color: .green,
                            accentColor: Color(red: 0.20, green: 0.78, blue: 0.35)
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 28)
                
                // Recent Activity
                if !viewModel.recentResults.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("home.recent".localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(viewModel.recentResults.prefix(5)) { result in
                                    RecentItemCard(result: result)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 28)
                }
            }
        }
    }
}

// MARK: - Trust Badge

struct TrustBadge: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(color)
                .font(.system(size: 22))
                .accessibilityHidden(true)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Action Button

struct ActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                // Gradient background with depth
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [accentColor, accentColor.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: accentColor.opacity(0.4), radius: 8, x: 0, y: 4)
                
                Image(systemName: icon)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.95)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .frame(width: 68, height: 68)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(accentColor)
                        .shadow(color: accentColor.opacity(0.3), radius: 4, x: 0, y: 2)
                )
                .accessibilityHidden(true)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [accentColor.opacity(0.3), accentColor.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
}

// MARK: - Recent Item Card

struct RecentItemCard: View {
    let result: CleaningResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: result.mediaItem.type == .image ? "photo" : "video")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                if result.success {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                }
            }
            
            Text(result.mediaItem.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            Text("results.metadata_removed".localized(result.removedMetadata.count))
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let spaceSaved = result.spaceSaved, spaceSaved > 0 {
                Text("results.space_saved".localized(ByteCountFormatter.string(fromByteCount: spaceSaved, countStyle: .file)))
                    .font(.caption)
                    .foregroundColor(.green)
                    .fontWeight(.medium)
            }
        }
        .padding(14)
        .frame(width: 160)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
    }
}

// MARK: - Home View Model

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var recentResults: [CleaningResult] = []
    
    init() {
        loadRecentResults()
    }
    
    private func loadRecentResults() {
        // Load from UserDefaults or database
        if let data = UserDefaults.standard.data(forKey: "RecentResults"),
           let results = try? JSONDecoder().decode([CleaningResult].self, from: data) {
            recentResults = results
        }
    }
    
    func addResult(_ result: CleaningResult) {
        recentResults.insert(result, at: 0)
        if recentResults.count > 10 {
            recentResults.removeLast()
        }
        saveRecentResults()
    }
    
    private func saveRecentResults() {
        if let data = try? JSONEncoder().encode(recentResults) {
            UserDefaults.standard.set(data, forKey: "RecentResults")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
