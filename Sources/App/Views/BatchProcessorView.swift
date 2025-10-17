import SwiftUI
import Domain
import Platform
import Data

struct BatchProcessorView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = BatchProcessorViewModel()
    @State private var showingPhotoPicker = false
    @State private var showingFilePicker = false
    
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

        let imageCleaner = ImageMetadataCleaner()
        let videoCleaner = VideoMetadataCleaner()
        let storage = LocalStorageRepository()
        let imageUseCase = CleanImageUseCaseImpl(cleaner: imageCleaner, storage: storage)
        let videoUseCase = CleanVideoUseCaseImpl(cleaner: videoCleaner, storage: storage)

        let items = await MainActor.run { self.items }

        for (index, item) in items.enumerated() {
            if Task.isCancelled { break }

            await MainActor.run {
                currentIndex = index + 1
            }

            do {
                let result: CleaningResult

                switch item.type {
                case .image:
                    result = try await imageUseCase.execute(
                        imageURL: item.sourceURL,
                        settings: settings
                    )
                case .video:
                    result = try await videoUseCase.execute(
                        videoURL: item.sourceURL,
                        settings: settings
                    )
                }

                if Task.isCancelled { break }

                await MainActor.run {
                    results.append(result)
                    progress = Double(currentIndex) / Double(items.count)
                }
            } catch {
                if Task.isCancelled || error is CancellationError { break }

                await MainActor.run {
                    results.append(CleaningResult(
                        mediaItem: item,
                        state: .failed,
                        error: error.localizedDescription
                    ))
                    progress = Double(currentIndex) / Double(items.count)
                    showingError = true
                    errorMessage = error.localizedDescription
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
