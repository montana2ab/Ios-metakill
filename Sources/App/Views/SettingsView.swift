import SwiftUI
import Domain

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        Form {
            Section(header: Text("Metadata Removal")) {
                Toggle("Remove GPS Location", isOn: $appState.settings.removeGPS)
                Toggle("Remove All Metadata", isOn: $appState.settings.removeAllMetadata)
                    .disabled(true) // Always on by default
            }
            
            Section(header: Text("File Options")) {
                Toggle("Preserve File Date", isOn: $appState.settings.preserveFileDate)
                
                Picker("Output Mode", selection: $appState.settings.outputMode) {
                    ForEach(OutputMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
            }
            
            Section(header: Text("Image Settings")) {
                Toggle("Convert HEIC to JPEG", isOn: $appState.settings.heicToJPEG)
                
                HStack {
                    Text("HEIC Quality")
                    Spacer()
                    Text("\(Int(appState.settings.heicQuality * 100))%")
                        .foregroundColor(.secondary)
                }
                Slider(value: $appState.settings.heicQuality, in: 0.5...1.0, step: 0.05)
                
                HStack {
                    Text("JPEG Quality")
                    Spacer()
                    Text("\(Int(appState.settings.jpegQuality * 100))%")
                        .foregroundColor(.secondary)
                }
                Slider(value: $appState.settings.jpegQuality, in: 0.5...1.0, step: 0.05)
                
                Toggle("Force sRGB Color", isOn: $appState.settings.forceSRGB)
                Toggle("Bake Orientation", isOn: $appState.settings.bakeOrientation)
            }
            
            Section(header: Text("Video Settings")) {
                Picker("Processing Mode", selection: $appState.settings.videoProcessingMode) {
                    ForEach(VideoProcessingMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                
                Text(appState.settings.videoProcessingMode.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Toggle("Preserve HDR", isOn: $appState.settings.preserveHDR)
            }
            
            Section(header: Text("Performance")) {
                Toggle("Thermal Monitoring", isOn: $appState.settings.enableThermalMonitoring)
                
                Stepper("Concurrent Operations: \(appState.settings.maxConcurrentOperations)",
                       value: $appState.settings.maxConcurrentOperations,
                       in: 1...8)
            }
            
            Section(header: Text("Privacy")) {
                Toggle("Enable Logging", isOn: $appState.settings.enablePrivateLogging)
                
                Text("All processing happens on-device. No data is collected or shared.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section {
                Button("Reset to Defaults") {
                    appState.settings = .default
                    appState.saveSettings()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: appState.settings) { _ in
            appState.saveSettings()
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppState())
    }
}
