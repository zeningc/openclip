import AppKit
import Carbon
import Combine
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let container = AppContainer()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        container.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        container.stop()
    }
}

@MainActor
final class AppContainer {
    let store = ClipboardStore()
    let picker = PickerController()
    let preferences = PreferencesStore()

    private lazy var hotKey = GlobalHotKey(
        keyCode: preferences.hotKey.keyCode,
        modifiers: preferences.hotKey.modifiers
    ) { [weak self] in
        self?.picker.showPicker()
    }

    private var monitor: PasteboardMonitor?
    private var cancellables = Set<AnyCancellable>()

    func start() {
        picker.configure(store: store, preferences: preferences)
        monitor = PasteboardMonitor(store: store)
        monitor?.start()
        hotKey.register()

        preferences.$hotKey
            .dropFirst()
            .sink { [weak self] setting in
                self?.hotKey.update(keyCode: setting.keyCode, modifiers: setting.modifiers)
            }
            .store(in: &cancellables)
    }

    func stop() {
        monitor?.stop()
        hotKey.unregister()
        cancellables.removeAll()
    }
}
