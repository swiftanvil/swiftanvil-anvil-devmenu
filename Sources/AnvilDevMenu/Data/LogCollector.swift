import Foundation

/// Collects log messages for the console screen.
@available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1, *)
@MainActor
public final class LogCollector: ObservableObject, Sendable {
    public static let shared = LogCollector()
    
    @Published public private(set) var messages: [LogMessage] = []
    private let maxMessages = 500
    
    private init() {}
    
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
    
    /// Clears all messages.
    public func clear() {
        messages.removeAll()
    }
}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1, *)
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
