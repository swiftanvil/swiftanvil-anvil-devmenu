import SwiftUI

/// Displays and runs user-defined custom actions.
@available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1, *)
public struct CustomActionsScreen: View {
    @State private var actions: [CustomAction] = []
    @State private var isRunning: Set<UUID> = []
    
    public init() {}
    
    public var body: some View {
        List(actions) { action in
            Button {
                Task {
                    isRunning.insert(action.id)
                    await action.action()
                    isRunning.remove(action.id)
                }
            } label: {
                HStack {
                    Image(systemName: action.systemImage)
                    Text(action.name)
                    Spacer()
                    if isRunning.contains(action.id) {
                        ProgressView()
                    }
                }
            }
            .disabled(isRunning.contains(action.id))
        }
        .navigationTitle("Custom Actions")
        .task {
            actions = await CustomActionRegistry.shared.allActions()
        }
        .overlay {
            if actions.isEmpty {
                emptyView
            }
        }
    }
    
    @ViewBuilder
    private var emptyView: some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *) {
            ContentUnavailableView(
                "No Actions",
                systemImage: "bolt.slash",
                description: Text("Use DeveloperMenu.addAction() to add custom actions")
            )
        } else {
            VStack {
                Image(systemName: "bolt.slash")
                Text("No Actions")
                Text("Use DeveloperMenu.addAction() to add custom actions")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
    }
}
