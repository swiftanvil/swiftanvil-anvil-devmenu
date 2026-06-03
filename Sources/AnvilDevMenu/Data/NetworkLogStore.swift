import Foundation
import SwiftUI

/// Stores network request/response logs for the developer menu.
@available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1, *)
@MainActor
public final class NetworkLogStore: ObservableObject, Sendable {
    public static let shared = NetworkLogStore()
    
    @Published public private(set) var entries: [NetworkLogEntry] = []
    private let maxEntries = 100
    
    private init() {}
    
    /// Appends a network log entry.
    public func append(_ entry: NetworkLogEntry) {
        entries.append(entry)
        if entries.count > maxEntries {
            entries.removeFirst(entries.count - maxEntries)
        }
    }
    
    /// Clears all log entries.
    public func clear() {
        entries.removeAll()
    }
}
