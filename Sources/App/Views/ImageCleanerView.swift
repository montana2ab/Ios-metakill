import SwiftUI
import PhotosUI
import Domain
import Data

struct ImageCleanerView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ImageCleanerViewModel()
    @State private var showingPhotoPicker = false
    @State private var showingFilePicker = false
    
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
                    }
                }
                
                // Action Button
                if !viewModel.isProcessing {
                    Button(action: {
                        Task {
                            await viewModel.processImages(settings: appState.settings)
                        }
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
            PhotoPickerView(selectedImages: $viewModel.selectedImages)
        }
        .sheet(isPresented: $showingFilePicker) {
            DocumentPickerView(selectedFiles: $viewModel.selectedImages)
        }
        .alert("common.error".localized, isPresented: $viewModel.showingError) {
            Button("common.ok".localized, role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
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
    
    private var task: Task<Void, Never>?
    
    func processImages(settings: CleaningSettings) async {
        isProcessing = true
        progress = 0
        currentIndex = 0
        results = []
        
        let cleaner = ImageMetadataCleaner()
        let storage = LocalStorageRepository()
        let useCase = CleanImageUseCaseImpl(cleaner: cleaner, storage: storage)
        
        for (index, item) in selectedImages.enumerated() {
            currentIndex = index + 1
            
            do {
                let result = try await useCase.execute(
                    imageURL: item.sourceURL,
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
            
            progress = Double(currentIndex) / Double(selectedImages.count)
        }
        
        isProcessing = false
    }
    
    func removeImages(at offsets: IndexSet) {
        selectedImages.remove(atOffsets: offsets)
    }
    
    func cancel() {
        task?.cancel()
        isProcessing = false
    }
}

// MARK: - Photo Picker (Placeholder)

struct PhotoPickerView: View {
    @Binding var selectedImages: [MediaItem]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("picker.photo.placeholder".localized)
                .navigationTitle("picker.photo.title".localized)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("common.cancel".localized) { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("common.done".localized) { dismiss() }
                    }
                }
        }
    }
}

// MARK: - Document Picker (Placeholder)

struct DocumentPickerView: View {
    @Binding var selectedFiles: [MediaItem]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("picker.files.placeholder".localized)
                .navigationTitle("picker.files.title".localized)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("common.cancel".localized) { dismiss() }
                    }
                }
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
