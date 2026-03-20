import AppKit
import Carbon
import Combine
import Foundation

struct HotKeySetting: Codable, Hashable {
    var keyCode: UInt32
    var modifiers: UInt32

    static let `default` = HotKeySetting(keyCode: UInt32(kVK_ANSI_V), modifiers: UInt32(cmdKey | optionKey))

    var displayString: String {
        let modifierText = modifierSymbols(modifiers)
        let keyText = keyDisplay(for: keyCode)
        return modifierText + keyText
    }

    private func modifierSymbols(_ modifiers: UInt32) -> String {
        var parts: [String] = []
        if modifiers & UInt32(cmdKey) != 0 { parts.append("⌘") }
        if modifiers & UInt32(optionKey) != 0 { parts.append("⌥") }
        if modifiers & UInt32(controlKey) != 0 { parts.append("⌃") }
        if modifiers & UInt32(shiftKey) != 0 { parts.append("⇧") }
        return parts.joined()
    }

    private func keyDisplay(for keyCode: UInt32) -> String {
        let map: [UInt32: String] = [
            UInt32(kVK_ANSI_A): "A", UInt32(kVK_ANSI_B): "B", UInt32(kVK_ANSI_C): "C", UInt32(kVK_ANSI_D): "D",
            UInt32(kVK_ANSI_E): "E", UInt32(kVK_ANSI_F): "F", UInt32(kVK_ANSI_G): "G", UInt32(kVK_ANSI_H): "H",
            UInt32(kVK_ANSI_I): "I", UInt32(kVK_ANSI_J): "J", UInt32(kVK_ANSI_K): "K", UInt32(kVK_ANSI_L): "L",
            UInt32(kVK_ANSI_M): "M", UInt32(kVK_ANSI_N): "N", UInt32(kVK_ANSI_O): "O", UInt32(kVK_ANSI_P): "P",
            UInt32(kVK_ANSI_Q): "Q", UInt32(kVK_ANSI_R): "R", UInt32(kVK_ANSI_S): "S", UInt32(kVK_ANSI_T): "T",
            UInt32(kVK_ANSI_U): "U", UInt32(kVK_ANSI_V): "V", UInt32(kVK_ANSI_W): "W", UInt32(kVK_ANSI_X): "X",
            UInt32(kVK_ANSI_Y): "Y", UInt32(kVK_ANSI_Z): "Z",
            UInt32(kVK_ANSI_0): "0", UInt32(kVK_ANSI_1): "1", UInt32(kVK_ANSI_2): "2", UInt32(kVK_ANSI_3): "3",
            UInt32(kVK_ANSI_4): "4", UInt32(kVK_ANSI_5): "5", UInt32(kVK_ANSI_6): "6", UInt32(kVK_ANSI_7): "7",
            UInt32(kVK_ANSI_8): "8", UInt32(kVK_ANSI_9): "9",
            UInt32(kVK_Space): "Space", UInt32(kVK_Return): "↩", UInt32(kVK_Escape): "⎋"
        ]
        return map[keyCode] ?? "Key \(keyCode)"
    }
}

@MainActor
final class PreferencesStore: ObservableObject {
    @Published var hotKey: HotKeySetting {
        didSet { save() }
    }

    @Published var language: AppLanguage {
        didSet { save() }
    }

    var l10n: L10n { L10n(language: language) }

    private let defaults = UserDefaults.standard
    private let hotKeyKey = "clipcache.hotkey"
    private let languageKey = "clipcache.language"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        if let data = defaults.data(forKey: hotKeyKey),
           let decoded = try? decoder.decode(HotKeySetting.self, from: data) {
            hotKey = decoded
        } else {
            hotKey = .default
        }

        if let raw = defaults.string(forKey: languageKey),
           let value = AppLanguage(rawValue: raw) {
            language = value
        } else {
            language = .english
        }
    }

    private func save() {
        if let data = try? encoder.encode(hotKey) {
            defaults.set(data, forKey: hotKeyKey)
        }
        defaults.set(language.rawValue, forKey: languageKey)
    }
}
