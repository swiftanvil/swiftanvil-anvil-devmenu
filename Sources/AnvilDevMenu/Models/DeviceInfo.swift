import Foundation

// System and app information for the device info screen.

public struct DeviceInfo: Sendable {
    public let osVersion: String
    public let deviceModel: String
    public let appVersion: String
    public let buildNumber: String

    public static func current() -> DeviceInfo {
        DeviceInfo(
            osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
            deviceModel: deviceModel(),
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            buildNumber: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
        )
    }

    #if canImport(UIKit)
        private static func deviceModel() -> String {
            UIDevice.current.model
        }
    #else
        private static func deviceModel() -> String {
            var utsname = utsname()
            uname(&utsname)
            return withUnsafePointer(to: &utsname.machine) {
                $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                    String(cString: $0)
                }
            }
        }
    #endif
}

#if canImport(UIKit)
    import UIKit
#endif
