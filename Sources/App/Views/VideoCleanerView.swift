import SwiftUI
import Domain
import Data

struct VideoCleanerView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = VideoCleanerViewModel()
    @State private var showingFilePicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.selectedVideos.isEmpty {
                // Empty State
                VStack(spacing: 24) {
                    Image(systemName: "video.badge.waveform")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                    
                    Text("Select Videos to Clean")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Choose videos to remove QuickTime metadata, GPS location, and chapters")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button(action: { showingFilePicker = true }) {
                        Label("Select Videos", systemImage: "folder")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                }
                .frame(maxHeight: .infinity)
            } else {
                // Selected Videos List
                List {
                    Section(header: Text("Selected Videos (\(viewModel.selectedVideos.count))")) {
                        ForEach(viewModel.selectedVideos) { item in
                            VideoItemRow(item: item)
                        }
                        .onDelete { indexSet in
                            viewModel.removeVideos(at: indexSet)
                        }
                    }
                    
                    if !viewModel.results.isEmpty {
                        Section(header: Text("Results")) {
                            ForEach(viewModel.results) { result in
                                ResultRow(result: result)
                            }
                        }
                    }
                }
                
                // Action Button
                if !viewModel.isProcessing {
                    Button(action: {
                        Task {
                            await viewModel.processVideos(settings: appState.settings)
                        }
                    }) {
                        Text("Clean \(viewModel.selectedVideos.count) Video\(viewModel.selectedVideos.count > 1 ? "s" : "")")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                } else {
                    VStack(spacing: 12) {
                        ProgressView(value: viewModel.progress)
                            .progressViewStyle(.linear)
                        
                        Text("Processing \(viewModel.currentIndex)/\(viewModel.selectedVideos.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("Cancel") {
                            viewModel.cancel()
                        }
                        .foregroundColor(.red)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Clean Videos")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingFilePicker) {
            DocumentPickerView(selectedFiles: $viewModel.selectedVideos)
        }
    }
}

// MARK: - Video Item Row

struct VideoItemRow: View {
    let item: MediaItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "video.fill")
                .font(.title2)
                .foregroundColor(.purple)
                .frame(width: 44, height: 44)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(item.formattedSize)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - View Model

@MainActor
final class VideoCleanerViewModel: ObservableObject {
    @Published var selectedVideos: [MediaItem] = []
    @Published var results: [CleaningResult] = []
    @Published var isProcessing = false
    @Published var progress: Double = 0
    @Published var currentIndex = 0
    
    private var task: Task<Void, Never>?
    
    func processVideos(settings: CleaningSettings) async {
        isProcessing = true
        progress = 0
        currentIndex = 0
        results = []
        
        let cleaner = VideoMetadataCleaner()
        let storage = LocalStorageRepository()
        let useCase = CleanVideoUseCaseImpl(cleaner: cleaner, storage: storage)
        
        for (index, item) in selectedVideos.enumerated() {
            currentIndex = index + 1
            
            do {
                let result = try await useCase.execute(
                    videoURL: item.sourceURL,
                    settings: settings
                )
                results.append(result)
            } catch {
                results.append(CleaningResult(
                    mediaItem: item,
                    state: .failed,
                    error: error.localizedDescription
                ))
            }
            
            progress = Double(currentIndex) / Double(selectedVideos.count)
        }
        
        isProcessing = false
    }
    
    func removeVideos(at offsets: IndexSet) {
        selectedVideos.remove(atOffsets: offsets)
    }
    
    func cancel() {
        task?.cancel()
        isProcessing = false
    }
}

#Preview {
    NavigationStack {
        VideoCleanerView()
            .environmentObject(AppState())
    }
}
