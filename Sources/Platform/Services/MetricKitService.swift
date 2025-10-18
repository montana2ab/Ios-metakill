#if canImport(MetricKit) && canImport(OSLog)
import Foundation
import MetricKit
import OSLog

/// Service for collecting and managing MetricKit diagnostics
@available(iOS 14.0, *)
public final class MetricKitService: NSObject, MXMetricManagerSubscriber {
    public static let shared = MetricKitService()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.metadatakill", category: "metrics")
    
    private override init() {
        super.init()
        setupMetricKit()
    }
    
    private func setupMetricKit() {
        MXMetricManager.shared.add(self)
        logger.info("MetricKit monitoring started")
    }
    
    deinit {
        MXMetricManager.shared.remove(self)
    }
    
    // MARK: - MXMetricManagerSubscriber
    
    /// Called when new metric payloads are available
    public func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            processMetricPayload(payload)
        }
    }
    
    /// Called when diagnostic payloads (crashes, hangs) are available
    public func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            processDiagnosticPayload(payload)
        }
    }
    
    // MARK: - Processing
    
    private func processMetricPayload(_ payload: MXMetricPayload) {
        logger.info("Received metric payload from \(payload.timeStampBegin) to \(payload.timeStampEnd)")
        
        // Log CPU metrics
        if let cpuMetrics = payload.cpuMetrics {
            logger.info("CPU Time: \(cpuMetrics.cumulativeCPUTime.description)")
        }
        
        // Log memory metrics
        if let memoryMetrics = payload.memoryMetrics {
            logger.info("Peak Memory: \(memoryMetrics.peakMemoryUsage.description)")
            logger.info("Average Memory: \(memoryMetrics.averageSuspendedMemory?.description ?? "N/A")")
        }
        
        // Log display metrics
        if let displayMetrics = payload.displayMetrics {
            logger.info("Average Pixel Luminance: \(displayMetrics.averagePixelLuminance.description)")
        }
        
        // Log cellular condition metrics
        if let cellularMetrics = payload.cellularConditionMetrics {
            logger.info("Cellular condition metrics available")
        }
        
        // Log app time metrics
        if let appTimeMetrics = payload.applicationTimeMetrics {
            logger.info("Foreground Time: \(appTimeMetrics.cumulativeForegroundTime.description)")
            logger.info("Background Time: \(appTimeMetrics.cumulativeBackgroundTime.description)")
        }
        
        // Log location activity metrics
        if let locationMetrics = payload.locationActivityMetrics {
            logger.info("Location activity metrics available")
        }
        
        // Log network transfer metrics
        if let networkMetrics = payload.networkTransferMetrics {
            logger.info("Network cellular downloads: \(networkMetrics.cumulativeCellularDownload.description)")
            logger.info("Network wifi downloads: \(networkMetrics.cumulativeWifiDownload.description)")
        }
        
        // Log app launch metrics
        if let launchMetrics = payload.applicationLaunchMetrics {
            logger.info("Launch metrics available")
        }
        
        // Log app responsiveness metrics
        if let responsivenessMetrics = payload.applicationResponsivenessMetrics {
            logger.info("Responsiveness metrics available")
        }
        
        // Log disk write exception metrics
        if let diskMetrics = payload.diskIOMetrics {
            logger.info("Disk write metrics available")
        }
        
        // Log animation metrics (iOS 14+)
        if let animationMetrics = payload.animationMetrics {
            logger.info("Animation metrics available")
        }
        
        // Log app exit metrics (iOS 14+)
        if let exitMetrics = payload.applicationExitMetrics {
            processAppExitMetrics(exitMetrics)
        }
        
        // Save payload for later analysis if needed
        saveMetricPayload(payload)
    }
    
    private func processDiagnosticPayload(_ payload: MXDiagnosticPayload) {
        logger.warning("Received diagnostic payload from \(payload.timeStampBegin) to \(payload.timeStampEnd)")
        
        // Log crash diagnostics
        if let crashDiagnostics = payload.crashDiagnostics {
            for crash in crashDiagnostics {
                logger.error("Crash detected: \(crash.callStackTree.jsonRepresentation())")
            }
        }
        
        // Log hang diagnostics
        if let hangDiagnostics = payload.hangDiagnostics {
            for hang in hangDiagnostics {
                logger.warning("Hang detected: \(hang.callStackTree.jsonRepresentation())")
            }
        }
        
        // Log CPU exception diagnostics
        if let cpuDiagnostics = payload.cpuExceptionDiagnostics {
            for cpuException in cpuDiagnostics {
                logger.warning("CPU exception detected: \(cpuException.callStackTree.jsonRepresentation())")
            }
        }
        
        // Log disk write exception diagnostics
        if let diskDiagnostics = payload.diskWriteExceptionDiagnostics {
            for diskException in diskDiagnostics {
                logger.warning("Disk write exception detected: \(diskException.callStackTree.jsonRepresentation())")
            }
        }
        
        // Save diagnostic payload
        saveDiagnosticPayload(payload)
    }
    
    private func processAppExitMetrics(_ exitMetrics: MXAppExitMetric) {
        logger.info("App Exit Metrics:")
        logger.info("- Foreground exits: \(exitMetrics.foregroundExitData)")
        logger.info("- Background exits: \(exitMetrics.backgroundExitData)")
    }
    
    // MARK: - Persistence
    
    private func saveMetricPayload(_ payload: MXMetricPayload) {
        do {
            let data = try JSONEncoder().encode(payload.jsonRepresentation())
            let fileName = "metrics_\(payload.timeStampBegin.timeIntervalSince1970).json"
            let fileURL = getMetricsDirectory().appendingPathComponent(fileName)
            try data.write(to: fileURL)
            logger.debug("Saved metric payload to \(fileURL.path)")
        } catch {
            logger.error("Failed to save metric payload: \(error.localizedDescription)")
        }
    }
    
    private func saveDiagnosticPayload(_ payload: MXDiagnosticPayload) {
        do {
            let data = try JSONEncoder().encode(payload.jsonRepresentation())
            let fileName = "diagnostics_\(payload.timeStampBegin.timeIntervalSince1970).json"
            let fileURL = getDiagnosticsDirectory().appendingPathComponent(fileName)
            try data.write(to: fileURL)
            logger.debug("Saved diagnostic payload to \(fileURL.path)")
        } catch {
            logger.error("Failed to save diagnostic payload: \(error.localizedDescription)")
        }
    }
    
    private func getMetricsDirectory() -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Metrics", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
    
    private func getDiagnosticsDirectory() -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Diagnostics", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}
#else
import Foundation

/// Stub MetricKit service for non-iOS platforms
public final class MetricKitService {
    public static let shared = MetricKitService()
    
    private init() {
        print("[MetricKit] Stub service initialized (iOS-only feature)")
    }
}
#endif
