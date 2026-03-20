import Carbon
import Foundation

@MainActor
final class GlobalHotKey {
    private var keyCode: UInt32
    private var modifiers: UInt32
    private let handler: () -> Void
    private var hotKeyRef: EventHotKeyRef?
    private static var eventHandler: EventHandlerRef?
    private static var handlers: [UInt32: () -> Void] = [:]
    private let identifier: UInt32

    init(keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) {
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.handler = handler
        self.identifier = UInt32.random(in: 1...UInt32.max)
        Self.ensureInstalled()
    }

    func register() {
        unregister()
        Self.handlers[identifier] = handler
        let hotKeyID = EventHotKeyID(signature: OSType(0x434C4950), id: identifier)
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }

    func update(keyCode: UInt32, modifiers: UInt32) {
        self.keyCode = keyCode
        self.modifiers = modifiers
        register()
    }

    func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        hotKeyRef = nil
        Self.handlers.removeValue(forKey: identifier)
    }

    private static func ensureInstalled() {
        guard eventHandler == nil else { return }
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, eventRef, _ in
            var hotKeyID = EventHotKeyID()
            let status = GetEventParameter(eventRef, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
            if status == noErr, let handler = GlobalHotKey.handlers[hotKeyID.id] {
                handler()
            }
            return noErr
        }, 1, &eventType, nil, &eventHandler)
    }
}
