#if canImport(OSLog)
import Foundation
import OSLog

/// Centralized logging service using OSLog
public final class LoggingService {
    public static let shared = LoggingService()
    
    // Subsystem identifier for the app
    private let subsystem = Bundle.main.bundleIdentifier ?? "com.metadatakill"
    
    // Category-specific loggers
    public let app: Logger
    public let metadata: Logger
    public let processing: Logger
    public let storage: Logger
    public let platform: Logger
    public let performance: Logger
    
    private init() {
        app = Logger(subsystem: subsystem, category: "app")
        metadata = Logger(subsystem: subsystem, category: "metadata")
        processing = Logger(subsystem: subsystem, category: "processing")
        storage = Logger(subsystem: subsystem, category: "storage")
        platform = Logger(subsystem: subsystem, category: "platform")
        performance = Logger(subsystem: subsystem, category: "performance")
    }
    
    // Convenience methods for common logging patterns
    public func logError(_ message: String, category: LogCategory = .app, error: Error? = nil) {
        let logger = getLogger(for: category)
        if let error = error {
            logger.error("\(message): \(error.localizedDescription)")
        } else {
            logger.error("\(message)")
        }
    }
    
    public func logInfo(_ message: String, category: LogCategory = .app) {
        let logger = getLogger(for: category)
        logger.info("\(message)")
    }
    
    public func logDebug(_ message: String, category: LogCategory = .app) {
        let logger = getLogger(for: category)
        logger.debug("\(message)")
    }
    
    public func logWarning(_ message: String, category: LogCategory = .app) {
        let logger = getLogger(for: category)
        logger.warning("\(message)")
    }
    
    private func getLogger(for category: LogCategory) -> Logger {
        switch category {
        case .app: return app
        case .metadata: return metadata
        case .processing: return processing
        case .storage: return storage
        case .platform: return platform
        case .performance: return performance
        }
    }
}

public enum LogCategory {
    case app
    case metadata
    case processing
    case storage
    case platform
    case performance
}
#else
import Foundation

/// Stub logging service for non-iOS platforms
public final class LoggingService {
    public static let shared = LoggingService()
    
    private init() {}
    
    public func logError(_ message: String, category: LogCategory = .app, error: Error? = nil) {
        if let error = error {
            print("[ERROR] \(message): \(error.localizedDescription)")
        } else {
            print("[ERROR] \(message)")
        }
    }
    
    public func logInfo(_ message: String, category: LogCategory = .app) {
        print("[INFO] \(message)")
    }
    
    public func logDebug(_ message: String, category: LogCategory = .app) {
        print("[DEBUG] \(message)")
    }
    
    public func logWarning(_ message: String, category: LogCategory = .app) {
        print("[WARNING] \(message)")
    }
}

public enum LogCategory {
    case app
    case metadata
    case processing
    case storage
    case platform
    case performance
}
#endif
