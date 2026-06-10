import SwiftUI

// A view modifier that presents the developer menu on triple-tap.

public struct DeveloperMenuGestureOverlay: ViewModifier {
    @State private var isPresented = false

    public init() { }

    public func body(content: Content) -> some View {
        content
            .onTapGesture(count: 3) {
                isPresented = true
            }
            .sheet(isPresented: $isPresented) {
                DeveloperMenuView()
            }
            .onReceive(NotificationCenter.default.publisher(for: .presentDeveloperMenu)) { _ in
                isPresented = true
            }
    }
}

public extension View {
    /// Adds a triple-tap gesture to present the developer menu.
    func developerMenuOverlay() -> some View {
        modifier(DeveloperMenuGestureOverlay())
    }
}
