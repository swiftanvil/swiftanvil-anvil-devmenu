import SwiftUI

/// A view modifier that presents the developer menu on device shake.
@available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1, *)
public struct DeveloperMenuShakeModifier: ViewModifier {
    @State private var isPresented = false
    
    public init() {}
    
    public func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                DeveloperMenuView()
            }
            .onReceive(NotificationCenter.default.publisher(for: .deviceShake)) { _ in
                isPresented = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .presentDeveloperMenu)) { _ in
                isPresented = true
            }
    }
}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1, *)
extension View {
    /// Adds shake-to-open support for the developer menu.
    public func developerMenuOnShake() -> some View {
        modifier(DeveloperMenuShakeModifier())
    }
}

// MARK: - Shake Notification

#if canImport(UIKit)
import UIKit

extension Notification.Name {
    static let deviceShake = Notification.Name("com.swiftanvil.devmenu.shake")
}

/// Intercepts motion events and posts a notification on shake.
public final class ShakeDetectingWindow: UIWindow {
    public override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            NotificationCenter.default.post(name: .deviceShake, object: nil)
        }
    }
}
#else
extension Notification.Name {
    static let deviceShake = Notification.Name("com.swiftanvil.devmenu.shake")
}
#endif
