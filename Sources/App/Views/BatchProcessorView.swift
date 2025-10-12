import SwiftUI
import Domain

struct BatchProcessorView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = BatchProcessorViewModel()
    
    var body: some View {
        VStack {
            Text("Batch Processor")
                .font(.title2)
            
            Text("Select multiple photos and videos to process together")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            Button("Select Files") {
                // Implement file selection
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Batch Processing")
    }
}

@MainActor
final class BatchProcessorViewModel: ObservableObject {
    @Published var items: [MediaItem] = []
    @Published var isProcessing = false
}

#Preview {
    NavigationStack {
        BatchProcessorView()
            .environmentObject(AppState())
    }
}
