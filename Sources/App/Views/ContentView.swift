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
                // Hero Section with Gradient
                ZStack {
                    LinearGradient(
                        colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea(edges: .top)
                    
                    VStack(spacing: 16) {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        Text("app.title".localized)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("home.hero.tagline".localized)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.95))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Text("home.hero.description".localized)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 40)
                }
                .frame(maxWidth: .infinity)
                
                // Trust Badges
                VStack(spacing: 0) {
                    HStack(spacing: 20) {
                        TrustBadge(icon: "lock.shield.fill", text: "home.badge.privacy".localized)
                        TrustBadge(icon: "bolt.fill", text: "home.badge.fast".localized)
                        TrustBadge(icon: "checkmark.seal.fill", text: "home.badge.quality".localized)
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Trust indicators")
                }
                .padding(.horizontal)
                .padding(.vertical, 24)
                .background(Color(.systemBackground))
                
                // Features Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("home.features.title".localized)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        FeatureRow(icon: "location.slash.fill", title: "home.feature.gps".localized, color: .red)
                        FeatureRow(icon: "camera.fill", title: "home.feature.exif".localized, color: .orange)
                        FeatureRow(icon: "mappin.slash", title: "home.feature.location".localized, color: .green)
                        FeatureRow(icon: "iphone.and.arrow.forward", title: "home.feature.ondevice".localized, color: .blue)
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Key features")
                    .padding(.horizontal)
                }
                .padding(.vertical, 24)
                .background(Color(.secondarySystemBackground))
                
                // Main Actions
                VStack(spacing: 16) {
                    Text("home.actions.title".localized)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 24)
                    
                    NavigationLink(destination: ImageCleanerView()) {
                        ActionButton(
                            title: "home.clean_photos".localized,
                            subtitle: "home.clean_photos.subtitle".localized,
                            icon: "photo.stack",
                            color: .blue
                        )
                    }
                    
                    NavigationLink(destination: VideoCleanerView()) {
                        ActionButton(
                            title: "home.clean_videos".localized,
                            subtitle: "home.clean_videos.subtitle".localized,
                            icon: "video.fill",
                            color: .purple
                        )
                    }
                    
                    NavigationLink(destination: BatchProcessorView()) {
                        ActionButton(
                            title: "home.batch_processing".localized,
                            subtitle: "home.batch_processing.subtitle".localized,
                            icon: "square.stack.3d.up.fill",
                            color: .green
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
                
                // Recent Activity
                if !viewModel.recentResults.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("home.recent".localized)
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.recentResults.prefix(5)) { result in
                                    RecentItemCard(result: result)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 24)
                }
            }
        }
    }
}

// MARK: - Trust Badge

struct TrustBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
            
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(color)
                .cornerRadius(10)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 18))
                .accessibilityHidden(true)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Action Button

struct ActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                LinearGradient(
                    colors: [color, color.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .cornerRadius(12)
                
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
            .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 28, height: 28)
                .background(color)
                .clipShape(Circle())
                .accessibilityHidden(true)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Recent Item Card

struct RecentItemCard: View {
    let result: CleaningResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: result.mediaItem.type == .image ? "photo" : "video")
                    .foregroundColor(.blue)
                
                Spacer()
                
                if result.success {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            
            Text(result.mediaItem.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Text("results.metadata_removed".localized(result.removedMetadata.count))
                .font(.caption2)
                .foregroundColor(.secondary)
            
            if let spaceSaved = result.spaceSaved, spaceSaved > 0 {
                Text("results.space_saved".localized(ByteCountFormatter.string(fromByteCount: spaceSaved, countStyle: .file)))
                    .font(.caption2)
                    .foregroundColor(.green)
            }
        }
        .padding(12)
        .frame(width: 150)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
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
