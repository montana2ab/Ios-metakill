import SwiftUI
import Combine
import Domain

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        Form {
            Section(header: Text("settings.app_preferences".localized)) {
                Picker("settings.language".localized, selection: $appState.settings.appLanguage) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        Text(language.localizationKey.localized).tag(language)
                    }
                }
                
                Text("settings.language_note".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("settings.metadata_removal".localized)) {
                Toggle("settings.remove_gps".localized, isOn: $appState.settings.removeGPS)
                Toggle("settings.remove_all_metadata".localized, isOn: $appState.settings.removeAllMetadata)
                    .disabled(true) // Always on by default
            }
            
            Section(header: Text("settings.file_options".localized)) {
                Toggle("settings.preserve_file_date".localized, isOn: $appState.settings.preserveFileDate)
                
                Picker("settings.output_mode".localized, selection: $appState.settings.outputMode) {
                    ForEach(OutputMode.allCases, id: \.self) { mode in
                        Text(mode.localizationKey.localized).tag(mode)
                    }
                }
                
                Toggle("settings.save_to_photo_library".localized, isOn: $appState.settings.saveToPhotoLibrary)
                
                Toggle("settings.delete_original_file".localized, isOn: $appState.settings.deleteOriginalFile)
                
                if appState.settings.deleteOriginalFile {
                    Text("settings.delete_original_warning".localized)
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Section(header: Text("settings.image_settings".localized)) {
                Toggle("settings.convert_heic_to_jpeg".localized, isOn: $appState.settings.heicToJPEG)
                
                HStack {
                    Text("settings.heic_quality".localized)
                    Spacer()
                    Text("\(Int(appState.settings.heicQuality * 100))%")
                        .foregroundColor(.secondary)
                }
                Slider(value: $appState.settings.heicQuality, in: 0.5...1.0, step: 0.05)
                
                HStack {
                    Text("settings.jpeg_quality".localized)
                    Spacer()
                    Text("\(Int(appState.settings.jpegQuality * 100))%")
                        .foregroundColor(.secondary)
                }
                Slider(value: $appState.settings.jpegQuality, in: 0.5...1.0, step: 0.05)
                
                Toggle("settings.force_srgb".localized, isOn: $appState.settings.forceSRGB)
                Toggle("settings.bake_orientation".localized, isOn: $appState.settings.bakeOrientation)
            }
            
            Section(header: Text("settings.video_settings".localized)) {
                Picker("settings.processing_mode".localized, selection: $appState.settings.videoProcessingMode) {
                    ForEach(VideoProcessingMode.allCases, id: \.self) { mode in
                        Text(mode.localizationKey.localized).tag(mode)
                    }
                }
                
                Text(appState.settings.videoProcessingMode.descriptionKey.localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Toggle("settings.preserve_hdr".localized, isOn: $appState.settings.preserveHDR)
            }
            
            Section(header: Text("settings.performance".localized)) {
                Toggle("settings.thermal_monitoring".localized, isOn: $appState.settings.enableThermalMonitoring)
                
                Stepper("settings.concurrent_operations".localized(appState.settings.maxConcurrentOperations),
                       value: $appState.settings.maxConcurrentOperations,
                       in: 1...8)
            }
            
            Section(header: Text("settings.privacy".localized)) {
                Toggle("settings.enable_logging".localized, isOn: $appState.settings.enablePrivateLogging)
                
                Text("settings.privacy_note".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section {
                Button("settings.reset_defaults".localized) {
                    appState.settings = .default
                    appState.saveSettings()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("settings.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(appState.$settings) { _ in
            appState.saveSettings()
        }
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            SettingsView()
                .environmentObject(AppState())
        }
    } else {
        // Fallback on earlier versions
    }
}
