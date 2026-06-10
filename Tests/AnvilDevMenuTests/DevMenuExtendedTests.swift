import Foundation
import Testing
@testable import AnvilDevMenu

// MARK: - NetworkLogStore Extended

@Suite("NetworkLogStore Extended")
@MainActor
struct NetworkLogStoreExtendedTests {
    @Test("log limit is exactly 100")
    func exactLogLimit() {
        let store = NetworkLogStore.shared
        store.clear()

        for i in 0 ..< 100 {
            let entry = NetworkLogEntry(
                timestamp: Date(),
                method: "GET",
                url: "https://example.com/\(i)",
                statusCode: 200,
                requestBody: nil,
                responseBody: nil
            )
            store.append(entry)
        }

        #expect(store.entries.count == 100)
    }

    @Test("oldest entries are evicted first")
    func oldestEvictedFirst() {
        let store = NetworkLogStore.shared
        store.clear()

        let firstEntry = NetworkLogEntry(
            timestamp: Date(),
            method: "GET",
            url: "https://first.com",
            statusCode: 200,
            requestBody: nil,
            responseBody: nil
        )
        store.append(firstEntry)

        for i in 0 ..< 100 {
            let entry = NetworkLogEntry(
                timestamp: Date(),
                method: "GET",
                url: "https://example.com/\(i)",
                statusCode: 200,
                requestBody: nil,
                responseBody: nil
            )
            store.append(entry)
        }

        #expect(!store.entries.contains { $0.url == "https://first.com" })
    }

    @Test("newest entries are retained after eviction")
    func newestRetained() {
        let store = NetworkLogStore.shared
        store.clear()

        for i in 0 ..< 105 {
            let entry = NetworkLogEntry(
                timestamp: Date(),
                method: "GET",
                url: "https://example.com/\(i)",
                statusCode: 200,
                requestBody: nil,
                responseBody: nil
            )
            store.append(entry)
        }

        #expect(store.entries.last?.url == "https://example.com/104")
    }

    @Test("clear removes all entries")
    func clearRemovesAll() {
        let store = NetworkLogStore.shared
        store.clear()

        for i in 0 ..< 10 {
            let entry = NetworkLogEntry(
                timestamp: Date(),
                method: "GET",
                url: "https://example.com/\(i)",
                statusCode: 200,
                requestBody: nil,
                responseBody: nil
            )
            store.append(entry)
        }
        store.clear()

        #expect(store.entries.isEmpty)
    }

    @Test("append single entry")
    func appendSingle() {
        let store = NetworkLogStore.shared
        store.clear()

        let entry = NetworkLogEntry(
            timestamp: Date(),
            method: "POST",
            url: "https://api.example.com/data",
            statusCode: 201,
            requestBody: nil,
            responseBody: nil
        )
        store.append(entry)

        #expect(store.entries.count == 1)
        #expect(store.entries[0].method == "POST")
        #expect(store.entries[0].statusCode == 201)
    }

    @Test("entries maintain order")
    func entryOrder() {
        let store = NetworkLogStore.shared
        store.clear()

        let urls = ["a", "b", "c", "d"]
        for url in urls {
            let entry = NetworkLogEntry(
                timestamp: Date(),
                method: "GET",
                url: "https://\(url).com",
                statusCode: 200,
                requestBody: nil,
                responseBody: nil
            )
            store.append(entry)
        }

        #expect(store.entries.map(\.url) == urls.map { "https://\($0).com" })
    }
}

// MARK: - MenuItem Extended

@Suite("MenuItem Extended")
struct MenuItemExtendedTests {
    @Test("init with all screens")
    func allScreens() {
        let items: [MenuItem] = [
            MenuItem(title: "Feature Flags", systemImage: "flag", screen: .featureFlags),
            MenuItem(title: "Network", systemImage: "network", screen: .network),
            MenuItem(title: "Device Info", systemImage: "info", screen: .deviceInfo),
            MenuItem(title: "Console", systemImage: "terminal", screen: .console),
            MenuItem(title: "Custom Actions", systemImage: "bolt", screen: .customActions)
        ]

        #expect(items.count == 5)
        #expect(items[0].screen == .featureFlags)
        #expect(items[1].screen == .network)
        #expect(items[2].screen == .deviceInfo)
        #expect(items[3].screen == .console)
        #expect(items[4].screen == .customActions)
    }

    @Test("MenuItem is Identifiable")
    func identifiable() {
        let item = MenuItem(title: "Test", systemImage: "star", screen: .deviceInfo)
        let id = item.id
        #expect(id != UUID()) // UUIDs are unique, so this just exercises the property
    }

    @Test("MenuItem is Sendable")
    func sendable() {
        let item = MenuItem(title: "Sendable", systemImage: "checkmark", screen: .console)
        _ = item as Sendable
    }

    @Test("different items have different IDs")
    func differentIDs() {
        let a = MenuItem(title: "A", systemImage: "a", screen: .network)
        let b = MenuItem(title: "B", systemImage: "b", screen: .network)
        #expect(a.id != b.id)
    }
}

// MARK: - MenuScreen

@Suite("MenuScreen")
struct MenuScreenTests {
    @Test("all cases are sendable")
    func allCasesSendable() {
        let screens: [MenuScreen] = [.featureFlags, .network, .deviceInfo, .console, .customActions]
        for screen in screens {
            _ = screen as Sendable
        }
    }
}

// MARK: - DeviceInfo Extended

@Suite("DeviceInfo Extended")
struct DeviceInfoExtendedTests {
    @Test("osVersion is not empty")
    func osVersion() {
        let info = DeviceInfo.current()
        #expect(!info.osVersion.isEmpty)
    }

    @Test("deviceModel is not empty")
    func deviceModel() {
        let info = DeviceInfo.current()
        #expect(!info.deviceModel.isEmpty)
    }

    @Test("appVersion is not empty")
    func appVersion() {
        let info = DeviceInfo.current()
        #expect(!info.appVersion.isEmpty)
    }

    @Test("buildNumber is not empty")
    func buildNumber() {
        let info = DeviceInfo.current()
        #expect(!info.buildNumber.isEmpty)
    }

    @Test("DeviceInfo is Sendable")
    func sendable() {
        let info = DeviceInfo.current()
        _ = info as Sendable
    }
}

// MARK: - DeveloperMenu Extended

@Suite("DeveloperMenu Extended")
@MainActor
struct DeveloperMenuExtendedTests {
    @Test("default configuration values")
    func defaultConfiguration() {
        let config = DeveloperMenuConfiguration.default
        #expect(config.title == "Developer Menu")
    }

    @Test("custom configuration values")
    func customConfiguration() {
        let config = DeveloperMenuConfiguration(title: "Debug", accentColor: .green)
        #expect(config.title == "Debug")
    }

    @Test("configure updates shared state")
    func configureUpdatesShared() {
        DeveloperMenu.configure(.default)
        let custom = DeveloperMenuConfiguration(title: "Updated", accentColor: .orange)
        DeveloperMenu.configure(custom)
        #expect(DeveloperMenu.shared.currentConfiguration.title == "Updated")
    }

    @Test("CustomAction stores name and image")
    func customActionProperties() {
        let action = CustomAction(name: "Refresh", systemImage: "arrow.clockwise") { }
        #expect(action.name == "Refresh")
        #expect(action.systemImage == "arrow.clockwise")
    }

    @Test("CustomAction has unique ID")
    func customActionUniqueID() {
        let a = CustomAction(name: "A", systemImage: "a") { }
        let b = CustomAction(name: "B", systemImage: "b") { }
        #expect(a.id != b.id)
    }

    @Test("CustomActionRegistry registers multiple actions")
    func registryMultiple() async {
        let registry = CustomActionRegistry.shared
        let action1 = CustomAction(name: "One", systemImage: "1") { }
        let action2 = CustomAction(name: "Two", systemImage: "2") { }

        await registry.register(action1)
        await registry.register(action2)
        let actions = await registry.allActions()

        #expect(actions.contains { $0.name == "One" })
        #expect(actions.contains { $0.name == "Two" })
    }
}

// MARK: - NetworkLogEntry Extended

@Suite("NetworkLogEntry Extended")
struct NetworkLogEntryExtendedTests {
    @Test("status description for 2xx range")
    func status2xx() {
        for code in [200, 201, 204, 299] {
            let entry = NetworkLogEntry(
                timestamp: Date(),
                method: "GET",
                url: "https://example.com",
                statusCode: code,
                requestBody: nil,
                responseBody: nil
            )
            #expect(entry.statusDescription.contains("✅"))
        }
    }

    @Test("status description for 4xx range")
    func status4xx() {
        for code in [400, 401, 404, 422, 499] {
            let entry = NetworkLogEntry(
                timestamp: Date(),
                method: "GET",
                url: "https://example.com",
                statusCode: code,
                requestBody: nil,
                responseBody: nil
            )
            #expect(entry.statusDescription.contains("⚠️"))
        }
    }

    @Test("status description for 5xx range")
    func status5xx() {
        for code in [500, 502, 503, 599] {
            let entry = NetworkLogEntry(
                timestamp: Date(),
                method: "GET",
                url: "https://example.com",
                statusCode: code,
                requestBody: nil,
                responseBody: nil
            )
            #expect(entry.statusDescription.contains("❌"))
        }
    }

    @Test("status description for unknown codes")
    func statusUnknown() {
        let entry = NetworkLogEntry(
            timestamp: Date(),
            method: "GET",
            url: "https://example.com",
            statusCode: 100,
            requestBody: nil,
            responseBody: nil
        )
        #expect(entry.statusDescription.contains("⬜"))
    }

    @Test("status description includes code")
    func statusIncludesCode() {
        let entry = NetworkLogEntry(
            timestamp: Date(),
            method: "GET",
            url: "https://example.com",
            statusCode: 418,
            requestBody: nil,
            responseBody: nil
        )
        #expect(entry.statusDescription.contains("418"))
    }

    @Test("NetworkLogEntry is Identifiable")
    func identifiable() {
        let entry = NetworkLogEntry(
            timestamp: Date(),
            method: "GET",
            url: "https://example.com",
            statusCode: 200,
            requestBody: nil,
            responseBody: nil
        )
        _ = entry.id
    }

    @Test("NetworkLogEntry is Sendable")
    func sendable() {
        let entry = NetworkLogEntry(
            timestamp: Date(),
            method: "GET",
            url: "https://example.com",
            statusCode: 200,
            requestBody: nil,
            responseBody: nil
        )
        _ = entry as Sendable
    }
}

// MARK: - LogCollector Extended

@Suite("LogCollector Extended")
@MainActor
struct LogCollectorExtendedTests {
    @Test("log limit is exactly 500")
    func exactLogLimit() {
        let collector = LogCollector.shared
        collector.clear()

        for i in 0 ..< 500 {
            collector.append(level: .debug, message: "Message \(i)")
        }

        #expect(collector.messages.count == 500)
    }

    @Test("oldest messages are evicted first")
    func oldestMessagesEvicted() {
        let collector = LogCollector.shared
        collector.clear()

        collector.append(level: .info, message: "first")

        for i in 0 ..< 500 {
            collector.append(level: .debug, message: "Message \(i)")
        }

        #expect(!collector.messages.contains { $0.message == "first" })
    }

    @Test("newest messages are retained")
    func newestRetained() {
        let collector = LogCollector.shared
        collector.clear()

        for i in 0 ..< 505 {
            collector.append(level: .debug, message: "Message \(i)")
        }

        #expect(collector.messages.last?.message == "Message 504")
    }

    @Test("append with file and line")
    func appendWithFileLine() {
        let collector = LogCollector.shared
        collector.clear()

        collector.append(level: .error, message: "error msg", file: "Test.swift", line: 42)

        #expect(collector.messages.count == 1)
        #expect(collector.messages[0].file == "Test.swift")
        #expect(collector.messages[0].line == 42)
    }

    @Test("log levels are preserved")
    func logLevelsPreserved() {
        let collector = LogCollector.shared
        collector.clear()

        collector.append(level: .debug, message: "d")
        collector.append(level: .info, message: "i")
        collector.append(level: .warning, message: "w")
        collector.append(level: .error, message: "e")

        #expect(collector.messages[0].level == .debug)
        #expect(collector.messages[1].level == .info)
        #expect(collector.messages[2].level == .warning)
        #expect(collector.messages[3].level == .error)
    }

    @Test("clear after multiple appends")
    func clearAfterMultiple() {
        let collector = LogCollector.shared
        collector.clear()

        for i in 0 ..< 50 {
            collector.append(level: .info, message: "\(i)")
        }
        collector.clear()

        #expect(collector.messages.isEmpty)
    }
}

// MARK: - LogMessage

@Suite("LogMessage")
struct LogMessageTests {
    @Test("LogMessage properties")
    func properties() {
        let msg = LogMessage(
            timestamp: Date(),
            level: .warning,
            message: "warn",
            file: "File.swift",
            line: 10
        )
        #expect(msg.level == .warning)
        #expect(msg.message == "warn")
        #expect(msg.file == "File.swift")
        #expect(msg.line == 10)
    }

    @Test("LogMessage is Sendable")
    func sendable() {
        let msg = LogMessage(
            timestamp: Date(),
            level: .info,
            message: "test",
            file: "",
            line: 0
        )
        _ = msg as Sendable
    }
}

// MARK: - LogLevel Extended

@Suite("LogLevel Extended")
struct LogLevelExtendedTests {
    @Test("all cases have raw values")
    func rawValues() {
        #expect(LogLevel.debug.rawValue == "DEBUG")
        #expect(LogLevel.info.rawValue == "INFO")
        #expect(LogLevel.warning.rawValue == "WARN")
        #expect(LogLevel.error.rawValue == "ERROR")
    }

    @Test("all cases have colors")
    func allColors() {
        for level in LogLevel.allCases {
            #expect(!level.color.isEmpty)
        }
    }

    @Test("specific colors")
    func specificColors() {
        #expect(LogLevel.debug.color == "⚪")
        #expect(LogLevel.info.color == "🔵")
        #expect(LogLevel.warning.color == "🟡")
        #expect(LogLevel.error.color == "🔴")
    }

    @Test("all cases are CaseIterable")
    func caseIterable() {
        #expect(LogLevel.allCases.count == 4)
    }
}
