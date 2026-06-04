import SwiftUI

/// Displays and runs user-defined custom actions.

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
        ContentUnavailableView(
            "No Actions",
            systemImage: "bolt.slash",
            description: Text("Use DeveloperMenu.addAction() to add custom actions")
        )
    }
}
