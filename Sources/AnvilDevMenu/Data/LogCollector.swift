import Foundation
import AnvilCore

/// Collects log messages for the console screen.

@MainActor
public final class LogCollector: ObservableObject, Sendable {
    public static let shared = LogCollector()
    
    @Published public private(set) var messages: [LogMessage] = []
    private let maxMessages = 500
    
    /// The underlying `AnvilLogger` that backs this collector.
    public let anvilLogger = AnvilLogger()
    
    private init() {}
    
    /// Creates a fresh collector for testing. Not for production use.
    static func makeForTesting() -> LogCollector {
        LogCollector()
    }
    
    /// Appends a log message.
    public func append(level: LogLevel, message: String, file: String = "", line: Int = 0) {
        let entry = LogMessage(
            timestamp: Date(),
            level: level,
            message: message,
            file: file,
            line: line
        )
        messages.append(entry)
        if messages.count > maxMessages {
            messages.removeFirst(messages.count - maxMessages)
        }
    }
    
    /// Bridges a message to `AnvilLogger` and also appends it locally.
    public func bridgeToAnvilLogger(level: AnvilLogger.Level, message: String, file: String = #file, line: Int = #line) async {
        await anvilLogger.log(level, message, file: file, line: line)
        let localLevel: LogLevel
        switch level {
        case .trace, .debug: localLevel = .debug
        case .info: localLevel = .info
        case .warn: localLevel = .warning
        case .error: localLevel = .error
        }
        append(level: localLevel, message: message, file: file, line: line)
    }
    
    /// Clears all messages and the underlying `AnvilLogger`.
    public func clear() {
        messages.removeAll()
        Task {
            await anvilLogger.clear()
        }
    }
}


public struct LogMessage: Sendable, Identifiable {
    public let id = UUID()
    public let timestamp: Date
    public let level: LogLevel
    public let message: String
    public let file: String
    public let line: Int
}

public enum LogLevel: String, Sendable, CaseIterable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARN"
    case error = "ERROR"
    
    public var color: String {
        switch self {
        case .debug: return "⚪"
        case .info: return "🔵"
        case .warning: return "🟡"
        case .error: return "🔴"
        }
    }
}
