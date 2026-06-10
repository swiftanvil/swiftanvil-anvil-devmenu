import AnvilCore
import Foundation
import Testing
@testable import AnvilDevMenu

// MARK: - DeviceInfo Tests

@Suite("DeviceInfo")
struct DeviceInfoTests {
    @Test("current returns valid info")
    func current() {
        let info = DeviceInfo.current()
        #expect(!info.osVersion.isEmpty)
        #expect(!info.deviceModel.isEmpty)
        #expect(!info.appVersion.isEmpty)
        #expect(!info.buildNumber.isEmpty)
    }
}

// MARK: - NetworkLogEntry Tests

@Suite("NetworkLogEntry")
struct NetworkLogEntryTests {
    @Test("status description for 200")
    func status200() {
        let entry = NetworkLogEntry(
            timestamp: Date(),
            method: "GET",
            url: "https://example.com",
            statusCode: 200,
            requestBody: nil,
            responseBody: nil
        )
        #expect(entry.statusDescription.contains("✅"))
    }

    @Test("status description for 404")
    func status404() {
        let entry = NetworkLogEntry(
            timestamp: Date(),
            method: "GET",
            url: "https://example.com",
            statusCode: 404,
            requestBody: nil,
            responseBody: nil
        )
        #expect(entry.statusDescription.contains("⚠️"))
    }

    @Test("status description for 500")
    func status500() {
        let entry = NetworkLogEntry(
            timestamp: Date(),
            method: "GET",
            url: "https://example.com",
            statusCode: 500,
            requestBody: nil,
            responseBody: nil
        )
        #expect(entry.statusDescription.contains("❌"))
    }
}

// MARK: - NetworkLogStore Tests

@Suite("NetworkLogStore")
@MainActor
struct NetworkLogStoreTests {
    @Test("appends entries")
    func append() {
        let store = NetworkLogStore.shared
        store.clear()

        let entry = NetworkLogEntry(
            timestamp: Date(),
            method: "GET",
            url: "https://example.com",
            statusCode: 200,
            requestBody: nil,
            responseBody: nil
        )
        store.append(entry)

        #expect(store.entries.count == 1)
        #expect(store.entries[0].method == "GET")
    }

    @Test("clears entries")
    func clear() {
        let store = NetworkLogStore.shared
        store.clear()

        let entry = NetworkLogEntry(
            timestamp: Date(),
            method: "GET",
            url: "https://example.com",
            statusCode: 200,
            requestBody: nil,
            responseBody: nil
        )
        store.append(entry)
        store.clear()

        #expect(store.entries.isEmpty)
    }

    @Test("max entries limit")
    func maxEntries() {
        let store = NetworkLogStore.shared
        store.clear()

        for i in 0 ..< 110 {
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
}

// MARK: - LogCollector Tests

@Suite("LogCollector")
@MainActor
struct LogCollectorTests {
    @Test("appends messages")
    func append() {
        let collector = LogCollector.shared
        collector.clear()

        collector.append(level: .info, message: "Test message")

        #expect(collector.messages.count == 1)
        #expect(collector.messages[0].message == "Test message")
        #expect(collector.messages[0].level == .info)
    }

    @Test("clears messages")
    func clear() {
        let collector = LogCollector.shared
        collector.clear()

        collector.append(level: .debug, message: "Debug")
        collector.clear()

        #expect(collector.messages.isEmpty)
    }

    @Test("max messages limit")
    func maxMessages() {
        let collector = LogCollector.shared
        collector.clear()

        for i in 0 ..< 550 {
            collector.append(level: .debug, message: "Message \(i)")
        }

        #expect(collector.messages.count == 500)
    }

    @Test("bridgeToAnvilLogger logs to AnvilLogger and local messages")
    func bridgeToAnvilLogger() async {
        let collector = LogCollector.makeForTesting()

        await collector.bridgeToAnvilLogger(level: .info, message: "Bridged message")

        #expect(collector.messages.count == 1)
        #expect(collector.messages[0].message == "Bridged message")
        #expect(collector.messages[0].level == .info)

        let entries = await collector.anvilLogger.allEntries
        #expect(entries.count == 1)
        #expect(entries[0].level == .info)
        #expect(entries[0].message == "Bridged message")
    }

    @Test("bridgeToAnvilLogger maps levels correctly")
    func bridgeLevelMapping() async {
        let collector = LogCollector.makeForTesting()

        await collector.bridgeToAnvilLogger(level: .debug, message: "Debug msg")
        await collector.bridgeToAnvilLogger(level: .warn, message: "Warn msg")
        await collector.bridgeToAnvilLogger(level: .error, message: "Error msg")

        let entries = await collector.anvilLogger.allEntries
        #expect(entries.count == 3)
        #expect(entries[0].level == .debug)
        #expect(entries[1].level == .warn)
        #expect(entries[2].level == .error)

        #expect(collector.messages[0].level == .debug)
        #expect(collector.messages[1].level == .warning)
        #expect(collector.messages[2].level == .error)
    }

    @Test("clear clears AnvilLogger entries")
    func clearClearsAnvilLogger() async {
        let collector = LogCollector.makeForTesting()

        await collector.bridgeToAnvilLogger(level: .info, message: "Message")
        collector.clear()

        // Allow the async clear task to complete
        try? await Task.sleep(nanoseconds: 10_000_000)

        let entries = await collector.anvilLogger.allEntries
        #expect(entries.isEmpty)
    }
}

// MARK: - LogLevel Tests

@Suite("LogLevel")
struct LogLevelTests {
    @Test("all cases have colors")
    func colors() {
        for level in LogLevel.allCases {
            #expect(!level.color.isEmpty)
        }
    }
}

// MARK: - CustomAction Tests

@Suite("CustomAction")
struct CustomActionTests {
    @Test("init with defaults")
    func initDefaults() {
        let action = CustomAction(name: "Test", systemImage: "star") { }
        #expect(action.name == "Test")
        #expect(action.systemImage == "star")
    }

    @Test("is Sendable")
    func sendable() {
        let action = CustomAction(name: "Test", systemImage: "star") { }
        _ = action as Sendable
    }
}

// MARK: - CustomActionRegistry Tests

@Suite("CustomActionRegistry")
struct CustomActionRegistryTests {
    @Test("registers and returns actions")
    func register() async {
        let registry = CustomActionRegistry.shared
        let action = CustomAction(name: "Clear", systemImage: "trash") { }

        await registry.register(action)
        let actions = await registry.allActions()

        #expect(actions.contains { $0.name == "Clear" })
    }
}

// MARK: - MenuItem Tests

@Suite("MenuItem")
struct MenuItemTests {
    @Test("init")
    func initTest() {
        let item = MenuItem(title: "Test", systemImage: "star", screen: .deviceInfo)
        #expect(item.title == "Test")
        #expect(item.systemImage == "star")
    }
}

// MARK: - DeveloperMenu Tests

@Suite("DeveloperMenu")
@MainActor
struct DeveloperMenuTests {
    @Test("configure updates configuration")
    func configure() {
        let config = DeveloperMenuConfiguration(title: "Test Menu", accentColor: .red)
        DeveloperMenu.configure(config)

        #expect(DeveloperMenu.shared.currentConfiguration.title == "Test Menu")
    }
}
