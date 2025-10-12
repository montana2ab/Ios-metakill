import SwiftUI
import Domain

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // App Title
                VStack(spacing: 8) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("MetadataKill")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Clean metadata from photos and videos")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Main Actions
                VStack(spacing: 16) {
                    NavigationLink(destination: ImageCleanerView()) {
                        ActionButton(
                            title: "Clean Photos",
                            subtitle: "Remove EXIF, GPS, and other metadata",
                            icon: "photo.stack",
                            color: .blue
                        )
                    }
                    
                    NavigationLink(destination: VideoCleanerView()) {
                        ActionButton(
                            title: "Clean Videos",
                            subtitle: "Remove QuickTime metadata and location",
                            icon: "video.fill",
                            color: .purple
                        )
                    }
                    
                    NavigationLink(destination: BatchProcessorView()) {
                        ActionButton(
                            title: "Batch Processing",
                            subtitle: "Process multiple files at once",
                            icon: "square.stack.3d.up.fill",
                            color: .green
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Recent Activity
                if !viewModel.recentResults.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent")
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
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
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
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(color)
                .cornerRadius(12)
            
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
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
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
            
            Text("\(result.removedMetadata.count) metadata removed")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            if let spaceSaved = result.spaceSaved, spaceSaved > 0 {
                Text("Saved \(ByteCountFormatter.string(fromByteCount: spaceSaved, countStyle: .file))")
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
