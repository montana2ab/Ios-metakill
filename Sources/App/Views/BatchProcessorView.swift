import SwiftUI
import Domain
import Platform
import Data

struct BatchProcessorView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = BatchProcessorViewModel()
    @State private var showingPhotoPicker = false
    @State private var showingFilePicker = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.items.isEmpty {
                // Empty State
                VStack(spacing: 24) {
                    Image(systemName: "square.stack.3d.up")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                    
                    Text("batch_processor.title".localized)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("batch_processor.description".localized)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    VStack(spacing: 12) {
                        Button(action: { showingPhotoPicker = true }) {
                            Label("batch_processor.select_from_photos".localized, systemImage: "photo.stack")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: { showingFilePicker = true }) {
                            Label("batch_processor.select_from_files".localized, systemImage: "folder")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .frame(maxHeight: .infinity)
            } else {
                // Selected Items List
                List {
                    Section(header: Text("batch_processor.selected_items".localized + " (\(viewModel.items.count))")) {
                        ForEach(viewModel.items) { item in
                            BatchItemRow(item: item)
                        }
                        .onDelete { indexSet in
                            viewModel.removeItems(at: indexSet)
                        }
                    }
                    
                    if !viewModel.results.isEmpty {
                        Section(header: Text("batch_processor.results".localized)) {
                            ForEach(viewModel.results) { result in
                                BatchResultRow(result: result)
                            }
                        }
                        
                        Section {
                            Button(action: {
                                dismiss()
                            }) {
                                Label("common.return_home".localized, systemImage: "house.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                
                // Action Button
                if !viewModel.isProcessing {
                    Button(action: {
                        viewModel.processItems(settings: appState.settings)
                    }) {
                        Text("batch_processor.process_button".localized + " (\(viewModel.items.count))")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                } else {
                    VStack(spacing: 12) {
                        ProgressView(value: viewModel.progress)
                            .progressViewStyle(.linear)
                        
                        Text("batch_processor.processing".localized + " \(viewModel.currentIndex)/\(viewModel.items.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("batch_processor.cancel".localized) {
                            viewModel.cancel()
                        }
                        .foregroundColor(.red)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("batch_processor.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPhotoPicker) {
            MediaLibraryPicker(selectedItems: $viewModel.items)
        }
        .sheet(isPresented: $showingFilePicker) {
            MediaDocumentPicker(selectedItems: $viewModel.items)
        }
        .alert("common.error".localized, isPresented: $viewModel.showingError) {
            Button("common.ok".localized, role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

// MARK: - Batch Item Row

struct BatchItemRow: View {
    let item: MediaItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.type == .image ? "photo" : "video")
                .font(.title2)
                .foregroundColor(item.type == .image ? .blue : .purple)
                .frame(width: 44, height: 44)
                .background((item.type == .image ? Color.blue : Color.purple).opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(item.formattedSize)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(item.type == .image ? "common.image".localized : "common.video".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Batch Result Row

struct BatchResultRow: View {
    let result: CleaningResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(result.mediaItem.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Spacer()
                
                if result.success {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            
            if result.success {
                VStack(alignment: .leading, spacing: 4) {
                    Text("results.metadata_types_removed".localized(result.removedMetadata.count))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if result.detectedMetadata.contains(where: { $0.type == .gps && $0.detected }) {
                        HStack {
                            Image(systemName: "location.fill")
                                .font(.caption2)
                            Text("results.gps_removed".localized)
                                .font(.caption2)
                        }
                        .foregroundColor(.orange)
                    }
                    
                    if let spaceSaved = result.spaceSaved, spaceSaved > 0 {
                        Text("results.space_saved_inline".localized(ByteCountFormatter.string(fromByteCount: spaceSaved, countStyle: .file)))
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    
                    Text("results.processing_time".localized(result.processingTime))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else if let error = result.error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - View Model

@MainActor
final class BatchProcessorViewModel: ObservableObject {
    @Published var items: [MediaItem] = []
    @Published var results: [CleaningResult] = []
    @Published var isProcessing = false
    @Published var progress: Double = 0
    @Published var currentIndex = 0
    @Published var showingError = false
    @Published var errorMessage = ""
    
    private var task: Task<Void, Never>?
    
    func processItems(settings: CleaningSettings) {
        cancel()

        task = Task(priority: .userInitiated) { [weak self, settings] in
            guard let self else { return }
            await self.runProcessing(settings: settings)
        }
    }

    func removeItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    func cancel() {
        task?.cancel()
        task = nil
        isProcessing = false
        progress = 0
        currentIndex = 0
    }

    private func runProcessing(settings: CleaningSettings) async {
        await MainActor.run {
            isProcessing = true
            progress = 0
            currentIndex = 0
            results = []
            showingError = false
            errorMessage = ""
        }

        // Lazy initialization - create cleaners and use cases once
        let imageCleaner = ImageMetadataCleaner()
        let videoCleaner = VideoMetadataCleaner()
        let storage = LocalStorageRepository()
        let imageUseCase = CleanImageUseCaseImpl(cleaner: imageCleaner, storage: storage)
        let videoUseCase = CleanVideoUseCaseImpl(cleaner: videoCleaner, storage: storage)

        let items = await MainActor.run { self.items }
        
        // Process items with controlled concurrency (2 at a time to balance speed and memory)
        let maxConcurrentTasks = 2
        var processedCount = 0
        
        await withTaskGroup(of: (Int, CleaningResult).self) { group in
            var nextIndex = 0
            
            // Start initial batch
            for _ in 0..<min(maxConcurrentTasks, items.count) {
                if nextIndex < items.count {
                    let index = nextIndex
                    let item = items[index]
                    nextIndex += 1
                    
                    group.addTask {
                        do {
                            let result: CleaningResult
                            
                            switch item.type {
                            case .image:
                                result = try await imageUseCase.execute(
                                    mediaItem: item,
                                    settings: settings
                                )
                            case .video:
                                result = try await videoUseCase.execute(
                                    mediaItem: item,
                                    settings: settings
                                )
                            @unknown default:
                                throw NSError(
                                    domain: "BatchProcessorView",
                                    code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "Unsupported media type"]
                                )
                            }
                            
                            return (index, result)
                        } catch {
                            return (index, CleaningResult(
                                mediaItem: item,
                                state: .failed,
                                error: error.localizedDescription
                            ))
                        }
                    }
                }
            }
            
            // Process results as they complete and start new tasks
            for await (index, result) in group {
                if Task.isCancelled { break }
                
                processedCount += 1
                
                await MainActor.run {
                    self.results.append(result)
                    self.currentIndex = processedCount
                    self.progress = Double(processedCount) / Double(items.count)
                    
                    if !result.success, let error = result.error {
                        self.showingError = true
                        self.errorMessage = error
                    }
                }
                
                // Start next task if available
                if nextIndex < items.count && !Task.isCancelled {
                    let nextItemIndex = nextIndex
                    let item = items[nextItemIndex]
                    nextIndex += 1
                    
                    group.addTask {
                        do {
                            let result: CleaningResult
                            
                            switch item.type {
                            case .image:
                                result = try await imageUseCase.execute(
                                    mediaItem: item,
                                    settings: settings
                                )
                            case .video:
                                result = try await videoUseCase.execute(
                                    mediaItem: item,
                                    settings: settings
                                )
                            @unknown default:
                                throw NSError(
                                    domain: "BatchProcessorView",
                                    code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "Unsupported media type"]
                                )
                            }
                            
                            return (nextItemIndex, result)
                        } catch {
                            return (nextItemIndex, CleaningResult(
                                mediaItem: item,
                                state: .failed,
                                error: error.localizedDescription
                            ))
                        }
                    }
                }
            }
        }

        await MainActor.run {
            if Task.isCancelled {
                progress = 0
            }
            isProcessing = false
            task = nil
        }
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            BatchProcessorView()
                .environmentObject(AppState())
        }
    } else {
        // Fallback on earlier versions
    }
}
