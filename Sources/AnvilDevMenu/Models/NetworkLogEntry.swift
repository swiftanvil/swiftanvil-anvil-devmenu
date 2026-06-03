import Foundation

/// A logged network request/response pair.
@available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1, *)
public struct NetworkLogEntry: Sendable, Identifiable {
    public let id = UUID()
    public let timestamp: Date
    public let method: String
    public let url: String
    public let statusCode: Int
    public let requestBody: Data?
    public let responseBody: Data?
    
    public var statusDescription: String {
        switch statusCode {
        case 200...299: return "✅ \(statusCode)"
        case 400...499: return "⚠️ \(statusCode)"
        case 500...599: return "❌ \(statusCode)"
        default: return "⬜ \(statusCode)"
        }
    }
}
