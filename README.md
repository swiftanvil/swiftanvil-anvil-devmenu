# AnvilDevMenu

> In-app debug menu for development builds. View logs, toggle flags, inspect network.

## Overview

AnvilDevMenu provides a SwiftUI-based developer menu that can be triggered by triple-tap or shake gesture. It integrates with other SwiftAnvil packages to provide runtime inspection and manipulation.

## Installation

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/swiftanvil/swiftanvil-anvil-devmenu.git", from: "1.0.0"),
]
```

```swift
targets: [.target(name: "MyTarget", dependencies: [.product(name: "AnvilDevMenu", package: "swiftanvil-anvil-devmenu")])]
```

## Quick Start

```swift
#if DEBUG
import AnvilDevMenu

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .developerMenuOverlay()  // Triple-tap to open
        }
    }
}
#endif
```

## Entry Points

```swift
// Triple-tap gesture
ContentView()
    .developerMenuOverlay()

// Shake gesture (iOS)
ContentView()
    .developerMenuOnShake()

// Programmatic
DeveloperMenu.present()
```

## Custom Actions

```swift
#if DEBUG
DeveloperMenu.addAction(
    CustomAction(
        name: "Clear Cache",
        systemImage: "trash",
        action: { await Cache.shared.clear() }
    )
)
#endif
```

## Screens

| Screen | Description |
|--------|-------------|
| Feature Flags | Toggle flags (integrates with AnvilFlags) |
| Network | View recent requests/responses (integrates with AnvilNetwork) |
| Device Info | OS version, app version, device model |
| Console | In-app log viewer |
| Custom Actions | Run user-defined actions |

## Compile-Time Stripping

Wrap all usage in `#if DEBUG` to completely strip from release builds:

```swift
#if DEBUG
import AnvilDevMenu
#endif

struct ContentView: View {
    var body: some View {
        Text("Hello")
            #if DEBUG
            .developerMenuOverlay()
            #endif
    }
}
```

## Architecture

```
AnvilDevMenu
├── DeveloperMenu.swift           # Public API + configuration
├── EntryPoints/
│   ├── GestureOverlay.swift      # Triple-tap overlay
│   └── ShakeGesture.swift        # Shake-to-open
├── Screens/
│   ├── DeveloperMenuView.swift   # Main menu
│   ├── FeatureFlagsScreen.swift  # Flag toggles
│   ├── NetworkScreen.swift       # Request log
│   ├── DeviceInfoScreen.swift    # System info
│   ├── ConsoleScreen.swift       # Log viewer
│   └── CustomActionsScreen.swift # User actions
├── Data/
│   ├── NetworkLogStore.swift     # Captures network traffic
│   └── LogCollector.swift        # Log message store
└── Models/
    ├── MenuItem.swift            # Menu item model
    ├── NetworkLogEntry.swift     # Network request model
    └── DeviceInfo.swift          # Device info model
```

## Requirements

- iOS 16+ / macOS 13+ / tvOS 16+ / watchOS 9+ / visionOS 1+
- Swift 6.0+

## License

MIT
