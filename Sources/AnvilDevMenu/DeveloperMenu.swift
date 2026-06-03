import SwiftUI

/// The public API for the developer menu.
///
/// Use `#if DEBUG` at the call site to strip from release builds:
///
/// ```swift
/// #if DEBUG
/// import AnvilDevMenu
///
/// ContentView()
///     .developerMenuOverlay()
/// #endif
/// ```
@available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1, *)
public struct DeveloperMenu: Sendable {
    @MainActor
    public static var shared = DeveloperMenu()
    
    @MainActor
    private var configuration: DeveloperMenuConfiguration = .default
    
    @MainActor
    private init() {}
    
    /// Configures the developer menu with integrations.
    @MainActor
    public static func configure(_ configuration: DeveloperMenuConfiguration) {
        shared.configuration = configuration
    }
    
    /// Adds a custom action to the menu.
    @MainActor
    public static func addAction(_ action: CustomAction) {
        Task {
            await CustomActionRegistry.shared.register(action)
        }
    }
    
    /// Presents the developer menu programmatically.
    @MainActor
    public static func present() {
        NotificationCenter.default.post(name: .presentDeveloperMenu, object: nil)
    }
    
    @MainActor
    var currentConfiguration: DeveloperMenuConfiguration {
        configuration
    }
}

// MARK: - Configuration

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1, *)
public struct DeveloperMenuConfiguration: Sendable {
    public let title: String
    public let accentColor: Color
    
    public init(
        title: String = "Developer Menu",
        accentColor: Color = .blue
    ) {
        self.title = title
        self.accentColor = accentColor
    }
    
    public static let `default` = DeveloperMenuConfiguration()
}

// MARK: - Custom Action

public struct CustomAction: Sendable, Identifiable {
    public let id: UUID
    public let name: String
    public let systemImage: String
    public let action: @Sendable () async -> Void
    
    public init(
        id: UUID = UUID(),
        name: String,
        systemImage: String,
        action: @escaping @Sendable () async -> Void
    ) {
        self.id = id
        self.name = name
        self.systemImage = systemImage
        self.action = action
    }
}

// MARK: - Registry

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1, *)
public actor CustomActionRegistry {
    public static let shared = CustomActionRegistry()
    private var actions: [CustomAction] = []
    
    public func register(_ action: CustomAction) {
        actions.append(action)
    }
    
    public func allActions() -> [CustomAction] {
        actions
    }
}

// MARK: - Notification

extension Notification.Name {
    static let presentDeveloperMenu = Notification.Name("com.swiftanvil.devmenu.present")
}
