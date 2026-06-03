import SwiftUI

/// Displays and toggles feature flags.
@available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1, *)
public struct FeatureFlagsScreen: View {
    @State private var flags: [String: Bool] = [:]
    
    public init() {}
    
    public var body: some View {
        List(flags.keys.sorted(), id: \.self) { key in
            HStack {
                Text(key)
                Spacer()
                Toggle("", isOn: binding(for: key))
                    .labelsHidden()
            }
        }
        .navigationTitle("Feature Flags")
        .task {
            await loadFlags()
        }
    }
    
    private func binding(for key: String) -> Binding<Bool> {
        Binding(
            get: { flags[key, default: false] },
            set: { flags[key] = $0 }
        )
    }
    
    private func loadFlags() async {
        // Placeholder: integrates with AnvilFlags via #if canImport
        // For now, show sample data
        flags = [
            "new_onboarding": false,
            "dark_mode": true,
            "beta_features": false,
        ]
    }
}
