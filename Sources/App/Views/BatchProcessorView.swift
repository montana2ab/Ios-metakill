import SwiftUI
import Domain
import Platform

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
                Text("Selected \(viewModel.items.count) items")
                    .font(.headline)
                    .padding()
                
                Spacer()
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
    }
}

@MainActor
final class BatchProcessorViewModel: ObservableObject {
    @Published var items: [MediaItem] = []
    @Published var isProcessing = false
}

#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            BatchProcessorView()
                .environmentObject(AppState())
        }
    } else {
        // Fallback on earlier versions
    };if #available(iOS 16.0, *) {
        NavigationStack {
            BatchProcessorView()
                .environmentObject(AppState())
        }
    } else {
        // Fallback on earlier versions
    }
}
