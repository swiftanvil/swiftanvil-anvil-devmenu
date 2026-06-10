import SwiftUI

// A menu item in the developer menu.

public struct MenuItem: Sendable, Identifiable {
    public let id = UUID()
    public let title: String
    public let systemImage: String
    public let screen: MenuScreen

    public init(title: String, systemImage: String, screen: MenuScreen) {
        self.title = title
        self.systemImage = systemImage
        self.screen = screen
    }
}

// The available screens in the developer menu.

public enum MenuScreen: Sendable {
    case featureFlags
    case network
    case deviceInfo
    case console
    case customActions
}
