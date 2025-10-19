import SwiftUI
import PhotosUI
import Domain
import Data
import Platform

struct ImageCleanerView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ImageCleanerViewModel()
    @State private var showingPhotoPicker = false
    @State private var showingFilePicker = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.selectedImages.isEmpty {
                // Empty State
                VStack(spacing: 24) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                    
                    Text("image_cleaner.empty.title".localized)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("image_cleaner.empty.description".localized)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    VStack(spacing: 12) {
                        Button(action: { showingPhotoPicker = true }) {
                            Label("image_cleaner.select_from_photos".localized, systemImage: "photo.stack")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: { showingFilePicker = true }) {
                            Label("image_cleaner.select_from_files".localized, systemImage: "folder")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .frame(maxHeight: .infinity)
            } else {
                // Selected Images List
                List {
                    Section(header: Text("\("image_cleaner.selected_photos".localized) (\(viewModel.selectedImages.count))")) {
                        ForEach(viewModel.selectedImages) { item in
                            ImageItemRow(item: item)
                        }
                        .onDelete { indexSet in
                            viewModel.removeImages(at: indexSet)
                        }
                    }
                    
                    if !viewModel.results.isEmpty {
                        Section(header: Text("image_cleaner.results".localized)) {
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
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                
                // Action Button
                if !viewModel.isProcessing {
                    Button(action: {
                        viewModel.processImages(settings: appState.settings)
                    }) {
                        Text(viewModel.selectedImages.count > 1 ? "image_cleaner.clean_button_plural".localized(viewModel.selectedImages.count) : "image_cleaner.clean_button".localized(viewModel.selectedImages.count))
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
                        
                        Text("image_cleaner.processing".localized(viewModel.currentIndex, viewModel.selectedImages.count))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("image_cleaner.cancel".localized) {
                            viewModel.cancel()
                        }
                        .foregroundColor(.red)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("image_cleaner.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoLibraryPicker(selectedItems: $viewModel.selectedImages)
        }
        .sheet(isPresented: $showingFilePicker) {
            ImageDocumentPicker(selectedItems: $viewModel.selectedImages)
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
    }
}

// MARK: - Image Item Row

struct ImageItemRow: View {
    let item: MediaItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "photo")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.1))
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

// MARK: - Result Row

struct ResultRow: View {
    let result: CleaningResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(result.mediaItem.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
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
final class ImageCleanerViewModel: ObservableObject {
    @Published var selectedImages: [MediaItem] = []
    @Published var results: [CleaningResult] = []
    @Published var isProcessing = false
    @Published var progress: Double = 0
    @Published var currentIndex = 0
    @Published var showingError = false
    @Published var errorMessage = ""
    @Published var showingDeleteConfirm = false
    @Published var deletedCount = 0
    
    private var task: Task<Void, Never>?
    
    func processImages(settings: CleaningSettings) {
        cancel()

        task = Task(priority: .userInitiated) { [weak self, settings] in
            guard let self else { return }
            await self.runProcessing(settings: settings)
        }
    }

    func removeImages(at offsets: IndexSet) {
        selectedImages.remove(atOffsets: offsets)
    }

    func cancel() {
        task?.cancel()
        task = nil
        isProcessing = false
        progress = 0
        currentIndex = 0
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
            
            for result in successfulResults {
                do {
                    try await storage.deleteOriginal(mediaItem: result.mediaItem)
                    await MainActor.run {
                        self.deletedCount += 1
                    }
                } catch {
                    await MainActor.run {
                        self.showingError = true
                        self.errorMessage = "results.deletion_failed".localized(error.localizedDescription)
                    }
                }
            }
        }
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

        let cleaner = ImageMetadataCleaner()
        let storage = LocalStorageRepository()
        let useCase = CleanImageUseCaseImpl(cleaner: cleaner, storage: storage)

        let images = await MainActor.run { selectedImages }

        for (index, item) in images.enumerated() {
            if Task.isCancelled { break }

            await MainActor.run {
                currentIndex = index + 1
            }

            do {
                let result = try await useCase.execute(
                    imageURL: item.sourceURL,
                    settings: settings
                )

                if Task.isCancelled { break }

                await MainActor.run {
                    results.append(result)
                    progress = Double(currentIndex) / Double(images.count)
                }
            } catch {
                if Task.isCancelled || error is CancellationError { break }

                await MainActor.run {
                    results.append(CleaningResult(
                        mediaItem: item,
                        state: .failed,
                        error: error.localizedDescription
                    ))
                    progress = Double(currentIndex) / Double(images.count)
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
            ImageCleanerView()
                .environmentObject(AppState())
        }
    } else {
        // Fallback on earlier versions
    }
}
