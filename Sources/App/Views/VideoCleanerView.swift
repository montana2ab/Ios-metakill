import SwiftUI
import Domain
import Data
import Platform

struct VideoCleanerView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = VideoCleanerViewModel()
    @State private var showingPhotoPicker = false
    @State private var showingFilePicker = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.selectedVideos.isEmpty {
                // Empty State
                VStack(spacing: 24) {
                    Image(systemName: "video.badge.waveform")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                    
                    Text("video_cleaner.empty.title".localized)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("video_cleaner.empty.description".localized)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    VStack(spacing: 12) {
                        Button(action: { showingPhotoPicker = true }) {
                            Label("video_cleaner.select_from_photos".localized, systemImage: "photo.stack")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: { showingFilePicker = true }) {
                            Label("video_cleaner.select_from_files".localized, systemImage: "folder")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .frame(maxHeight: .infinity)
            } else {
                // Selected Videos List
                List {
                    Section(header: Text("\("video_cleaner.selected_videos".localized) (\(viewModel.selectedVideos.count))")) {
                        ForEach(viewModel.selectedVideos) { item in
                            VideoItemRow(item: item)
                        }
                        .onDelete { indexSet in
                            viewModel.removeVideos(at: indexSet)
                        }
                    }
                    
                    if !viewModel.results.isEmpty {
                        Section(header: Text("video_cleaner.results".localized)) {
                            ForEach(viewModel.results) { result in
                                ResultRow(result: result)
                            }
                        }
                        
                        // Delete original files button
                        if viewModel.results.contains(where: { $0.success }) {
                            Section {
                                Button(action: {
                                    viewModel.deleteOriginalFiles()
                                }) {
                                    Label("results.delete_original_files".localized, systemImage: "trash")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.orange)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        Section {
                            Button(action: {
                                dismiss()
                            }) {
                                Label("common.return_home".localized, systemImage: "house.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.purple)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                
                // Action Button
                if !viewModel.isProcessing {
                    Button(action: {
                        viewModel.processVideos(settings: appState.settings)
                    }) {
                        Text(viewModel.selectedVideos.count > 1 ? "video_cleaner.clean_button_plural".localized(viewModel.selectedVideos.count) : "video_cleaner.clean_button".localized(viewModel.selectedVideos.count))
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
                        
                        Text("video_cleaner.processing".localized(viewModel.currentIndex, viewModel.selectedVideos.count))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("video_cleaner.cancel".localized) {
                            viewModel.cancel()
                        }
                        .foregroundColor(.red)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("video_cleaner.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPhotoPicker) {
            VideoLibraryPicker(selectedItems: $viewModel.selectedVideos)
        }
        .sheet(isPresented: $showingFilePicker) {
            VideoDocumentPicker(selectedItems: $viewModel.selectedVideos)
        }
        .alert("common.error".localized, isPresented: $viewModel.showingError) {
            Button("common.ok".localized, role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("results.delete_original_confirm_title".localized, isPresented: $viewModel.showingDeleteConfirm) {
            Button("common.cancel".localized, role: .cancel) { }
            Button("results.delete_original_files".localized, role: .destructive) {
                viewModel.confirmDeleteOriginalFiles()
            }
        } message: {
            let successCount = viewModel.results.filter { $0.success }.count
            Text("results.delete_original_confirm_message".localized(successCount))
        }
        .alert("results.delete_success_title".localized, isPresented: $viewModel.showingDeleteSuccess) {
            Button("common.ok".localized, role: .cancel) { }
        } message: {
            Text("results.delete_success_message".localized(viewModel.deletedCount))
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
    @Published var videoProgress: Double = 0  // Progress within current video
    @Published var showingDeleteConfirm = false
    @Published var showingDeleteSuccess = false
    @Published var deletedCount = 0
    @Published var showingError = false
    @Published var errorMessage = ""
    
    private var task: Task<Void, Never>?
    
    func processVideos(settings: CleaningSettings) {
        cancel()

        task = Task(priority: .userInitiated) { [weak self, settings] in
            guard let self else { return }
            await self.runProcessing(settings: settings)
        }
    }

    func removeVideos(at offsets: IndexSet) {
        selectedVideos.remove(atOffsets: offsets)
    }

    func cancel() {
        task?.cancel()
        task = nil
        isProcessing = false
        progress = 0
        currentIndex = 0
        videoProgress = 0
    }
    
    func deleteOriginalFiles() {
        showingDeleteConfirm = true
    }
    
    func confirmDeleteOriginalFiles() {
        let successfulResults = results.filter { $0.success }
        deletedCount = 0
        
        Task { [weak self] in
            guard let self else { return }
            
            let storage = LocalStorageRepository()
            var failedCount = 0
            
            for result in successfulResults {
                do {
                    try await storage.deleteOriginal(mediaItem: result.mediaItem)
                    await MainActor.run {
                        self.deletedCount += 1
                    }
                } catch {
                    failedCount += 1
                    await MainActor.run {
                        self.showingError = true
                        self.errorMessage = "results.deletion_failed".localized(error.localizedDescription)
                    }
                }
            }
            
            // Show success message if at least one file was deleted
            await MainActor.run {
                if self.deletedCount > 0 && failedCount == 0 {
                    self.showingDeleteSuccess = true
                }
            }
        }
    }

    private func runProcessing(settings: CleaningSettings) async {
        await MainActor.run {
            isProcessing = true
            progress = 0
            currentIndex = 0
            videoProgress = 0
            results = []
        }

        let cleaner = VideoMetadataCleaner()
        let storage = LocalStorageRepository()
        let useCase = CleanVideoUseCaseImpl(cleaner: cleaner, storage: storage)

        let videos = await MainActor.run { selectedVideos }

        for (index, item) in videos.enumerated() {
            if Task.isCancelled { break }

            await MainActor.run {
                currentIndex = index + 1
                videoProgress = 0
            }

            do {
                let result = try await useCase.execute(
                    videoURL: item.sourceURL,
                    settings: settings,
                    progressHandler: { [weak self] videoProgress in
                        guard let self else { return }
                        Task { @MainActor in
                            self.videoProgress = videoProgress
                            // Update overall progress: (completed videos + current video progress) / total videos
                            self.progress = (Double(index) + videoProgress) / Double(videos.count)
                        }
                    }
                )

                if Task.isCancelled { break }

                await MainActor.run {
                    results.append(result)
                    videoProgress = 1.0
                    progress = Double(currentIndex) / Double(videos.count)
                }
            } catch {
                if Task.isCancelled || error is CancellationError { break }

                await MainActor.run {
                    results.append(CleaningResult(
                        mediaItem: item,
                        state: .failed,
                        error: error.localizedDescription
                    ))
                    videoProgress = 0
                    progress = Double(currentIndex) / Double(videos.count)
                }
            }
        }

        await MainActor.run {
            if Task.isCancelled {
                progress = 0
                videoProgress = 0
            }
            isProcessing = false
            task = nil
        }
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            VideoCleanerView()
                .environmentObject(AppState())
        }
    } else {
        // Fallback on earlier versions
    }
}
