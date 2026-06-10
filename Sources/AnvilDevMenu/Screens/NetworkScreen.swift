import SwiftUI

// Displays network request/response logs.

public struct NetworkScreen: View {
    @StateObject private var store = NetworkLogStore.shared

    public init() { }

    public var body: some View {
        List(store.entries) { entry in
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.method)
                        .font(.caption)
                        .fontWeight(.bold)
                    Text(entry.statusDescription)
                        .font(.caption)
                    Spacer()
                    Text(entry.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Text(entry.url)
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)
        }
        .navigationTitle("Network")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Clear", systemImage: "trash") {
                    store.clear()
                }
            }
        }
        .overlay {
            if store.entries.isEmpty {
                emptyView
            }
        }
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "No Requests",
            systemImage: "network",
            description: Text("Network activity will appear here")
        )
    }
}
