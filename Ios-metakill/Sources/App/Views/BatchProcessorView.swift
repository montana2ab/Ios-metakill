import SwiftUI
import Domain

struct BatchProcessorView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = BatchProcessorViewModel()
    
    var body: some View {
        VStack {
            Text("batch_processor.title".localized)
                .font(.title2)
            
            Text("batch_processor.description".localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            Button("batch_processor.select_files".localized) {
                // Implement file selection
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("batch_processor.title".localized)
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
