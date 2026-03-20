import AppKit
import Combine
import SwiftUI

@MainActor
final class PickerController: ObservableObject {
    enum Command {
        case moveLeft
        case moveRight
        case copySelection
        case pasteSelection
        case close
    }

    @Published var query = ""
    @Published var selectedItemID: UUID?

    let commandPublisher = PassthroughSubject<Command, Never>()

    private weak var store: ClipboardStore?
    private weak var preferences: PreferencesStore?
    private var window: NSPanel?
    private var settingsWindow: NSWindow?
    private var keyMonitor: Any?
    private var previouslyActiveApp: NSRunningApplication?

    func configure(store: ClipboardStore, preferences: PreferencesStore) {
        self.store = store
        self.preferences = preferences
    }

    func showPicker() {
        guard let store, let preferences else { return }
        previouslyActiveApp = NSWorkspace.shared.frontmostApplication

        if window == nil {
            let contentView = PickerWindowView()
                .environmentObject(store)
                .environmentObject(self)
                .environmentObject(preferences)

            let hostingController = NSHostingController(rootView: contentView)
            let panel = NSPanel(contentViewController: hostingController)
            panel.identifier = NSUserInterfaceItemIdentifier("picker")
            panel.title = "openclip"
            panel.styleMask = [.titled, .closable, .resizable, .fullSizeContentView]
            panel.isFloatingPanel = true
            panel.level = .floating
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            panel.hidesOnDeactivate = false
            panel.isReleasedWhenClosed = false
            panel.titleVisibility = .hidden
            panel.titlebarAppearsTransparent = true
            panel.backgroundColor = .windowBackgroundColor
            panel.isOpaque = false
            panel.hasShadow = true
            self.window = panel
        }

        layoutWindowAtBottom()
        resetSelection()
        installKeyMonitorIfNeeded()
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
        window?.orderFrontRegardless()
    }

    func closePicker(restoreFocus: Bool = true) {
        removeKeyMonitor()
        window?.orderOut(nil)
        if restoreFocus {
            previouslyActiveApp?.activate(options: [.activateIgnoringOtherApps])
        }
    }

    func openSettings(preferences: PreferencesStore? = nil, store: ClipboardStore? = nil) {
        let resolvedStore = store ?? self.store
        guard let resolvedStore, let preferences else { return }

        if settingsWindow == nil {
            let contentView = SettingsView()
                .environmentObject(resolvedStore)
                .environmentObject(preferences)
            let hostingController = NSHostingController(rootView: contentView)
            let window = NSWindow(contentViewController: hostingController)
            window.title = "openclip Settings"
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.isReleasedWhenClosed = false
            window.center()
            settingsWindow = window
        }

        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
        settingsWindow?.orderFrontRegardless()
    }

    private func resetSelection() {
        query = ""
        selectedItemID = store?.items.first?.id
    }

    private func layoutWindowAtBottom() {
        guard let window else { return }
        let screen = NSApp.keyWindow?.screen ?? NSScreen.main ?? NSScreen.screens.first
        guard let visibleFrame = screen?.visibleFrame else { return }

        let width = min(max(visibleFrame.width * 0.82, 860), 1280)
        let height = min(max(visibleFrame.height * 0.34, 300), 420)
        let originX = visibleFrame.midX - (width / 2)
        let originY = visibleFrame.minY + 20
        window.setFrame(NSRect(x: originX, y: originY, width: width, height: height), display: true)
    }

    private func installKeyMonitorIfNeeded() {
        guard keyMonitor == nil else { return }
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, let window = self.window, window.isVisible, NSApp.keyWindow === window else {
                return event
            }

            switch Int(event.keyCode) {
            case 123:
                self.commandPublisher.send(.moveLeft)
                return nil
            case 124:
                self.commandPublisher.send(.moveRight)
                return nil
            case 36:
                self.commandPublisher.send(.pasteSelection)
                return nil
            case 53:
                self.commandPublisher.send(.close)
                self.closePicker()
                return nil
            default:
                break
            }

            if event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.command),
               event.charactersIgnoringModifiers?.lowercased() == "c" {
                self.commandPublisher.send(.copySelection)
                return nil
            }

            return event
        }
    }

    private func removeKeyMonitor() {
        if let keyMonitor {
            NSEvent.removeMonitor(keyMonitor)
            self.keyMonitor = nil
        }
    }
}
