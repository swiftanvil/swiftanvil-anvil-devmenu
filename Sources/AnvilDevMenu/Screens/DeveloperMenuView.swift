import SwiftUI

/// The main developer menu view.

public struct DeveloperMenuView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let configuration: DeveloperMenuConfiguration
    
    private var menuItems: [MenuItem] {
        [
            MenuItem(title: "Feature Flags", systemImage: "flag.fill", screen: .featureFlags),
            MenuItem(title: "Network", systemImage: "network", screen: .network),
            MenuItem(title: "Device Info", systemImage: "info.circle.fill", screen: .deviceInfo),
            MenuItem(title: "Console", systemImage: "terminal.fill", screen: .console),
            MenuItem(title: "Custom Actions", systemImage: "bolt.fill", screen: .customActions),
        ]
    }
    
    public init(configuration: DeveloperMenuConfiguration = DeveloperMenu.shared.currentConfiguration) {
        self.configuration = configuration
    }
    
    public var body: some View {
        NavigationStack {
            List(menuItems) { item in
                NavigationLink(value: item.screen) {
                    Label(item.title, systemImage: item.systemImage)
                }
            }
            .navigationTitle(configuration.title)
            .navigationDestination(for: MenuScreen.self) { screen in
                switch screen {
                case .featureFlags:
                    FeatureFlagsScreen()
                case .network:
                    NetworkScreen()
                case .deviceInfo:
                    DeviceInfoScreen()
                case .console:
                    ConsoleScreen()
                case .customActions:
                    CustomActionsScreen()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
