import SwiftUI

/// Displays device and app information.
@available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1, *)
public struct DeviceInfoScreen: View {
    private let info = DeviceInfo.current()
    
    public init() {}
    
    public var body: some View {
        List {
            Section("App") {
                InfoRow(label: "Version", value: info.appVersion)
                InfoRow(label: "Build", value: info.buildNumber)
            }
            
            Section("Device") {
                InfoRow(label: "Model", value: info.deviceModel)
                InfoRow(label: "OS", value: info.osVersion)
            }
        }
        .navigationTitle("Device Info")
    }
}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1, *)
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}
