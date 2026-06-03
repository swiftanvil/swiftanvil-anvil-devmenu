import SwiftUI

/// Displays collected log messages.
@available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1, *)
public struct ConsoleScreen: View {
    @StateObject private var collector = LogCollector.shared
    @State private var filter: LogLevel?
    
    public init() {}
    
    public var body: some View {
        List(filteredMessages) { message in
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(message.level.color)
                    Text(message.level.rawValue)
                        .font(.caption)
                        .fontWeight(.bold)
                    Spacer()
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Text(message.message)
                    .font(.caption)
                    .lineLimit(3)
            }
            .padding(.vertical, 2)
        }
        .navigationTitle("Console")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Menu("Filter", systemImage: "line.3.horizontal.decrease.circle") {
                    Button("All") { filter = nil }
                    ForEach(LogLevel.allCases, id: \.self) { level in
                        Button(level.rawValue) { filter = level }
                    }
                }
            }
            ToolbarItem(placement: .automatic) {
                Button("Clear", systemImage: "trash") {
                    collector.clear()
                }
            }
        }
        .overlay {
            if collector.messages.isEmpty {
                emptyView
            }
        }
    }
    
    @ViewBuilder
    private var emptyView: some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *) {
            ContentUnavailableView("No Logs", systemImage: "terminal", description: Text("Log messages will appear here"))
        } else {
            VStack {
                Image(systemName: "terminal")
                Text("No Logs")
                Text("Log messages will appear here")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
    }
    
    private var filteredMessages: [LogMessage] {
        if let filter = filter {
            return collector.messages.filter { $0.level == filter }
        }
        return collector.messages
    }
}
