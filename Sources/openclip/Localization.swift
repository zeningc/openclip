import Foundation

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case english
    case chinese

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .chinese: return "中文"
        }
    }
}

struct L10n {
    let language: AppLanguage

    func text(_ key: Key, _ args: CVarArg...) -> String {
        let format: String
        switch (language, key) {
        case (.english, .hotkey): format = "Hotkey: %@"
        case (.chinese, .hotkey): format = "快捷键：%@"

        case (.english, .openClipboardHistory): format = "Open openclip"
        case (.chinese, .openClipboardHistory): format = "打开剪贴板历史"

        case (.english, .settings): format = "Settings…"
        case (.chinese, .settings): format = "设置…"

        case (.english, .clearHistory): format = "Clear History"
        case (.chinese, .clearHistory): format = "清空历史"

        case (.english, .quit): format = "Quit openclip"
        case (.chinese, .quit): format = "退出 openclip"

        case (.english, .storedItems): format = "Stored: %d items"
        case (.chinese, .storedItems): format = "已存储：%d 条"

        case (.english, .searchPlaceholder): format = "Search clipboard history…"
        case (.chinese, .searchPlaceholder): format = "搜索历史剪贴板…"

        case (.english, .close): format = "Close"
        case (.chinese, .close): format = "关闭"

        case (.english, .noMatches): format = "No matching items"
        case (.chinese, .noMatches): format = "没有匹配内容"

        case (.english, .noMatchesHint): format = "Try a shorter keyword, or copy something first."
        case (.chinese, .noMatchesHint): format = "试试更短的关键词，或者先复制一些内容。"

        case (.english, .footerHint): format = "← → Select   •   ⌘C Copy & Close   •   Return Paste   •   Esc Exit"
        case (.chinese, .footerHint): format = "← → 选择   •   ⌘C 复制并关闭   •   Return 粘贴   •   Esc 退出"

        case (.english, .hotkeySection): format = "Hotkey"
        case (.chinese, .hotkeySection): format = "快捷键"

        case (.english, .currentHotkey): format = "Current hotkey: %@"
        case (.chinese, .currentHotkey): format = "当前快捷键：%@"

        case (.english, .retentionSection): format = "Retention"
        case (.chinese, .retentionSection): format = "历史保留"

        case (.english, .maxItems): format = "Max items: %d"
        case (.chinese, .maxItems): format = "最大条数：%d"

        case (.english, .maxAgeDays): format = "Retention days: %d"
        case (.chinese, .maxAgeDays): format = "保留天数：%d"

        case (.english, .storageCap): format = "Storage cap: %@"
        case (.chinese, .storageCap): format = "容量上限：%@"

        case (.english, .languageSection): format = "Language"
        case (.chinese, .languageSection): format = "语言"

        case (.english, .recordNewHotkey): format = "Record New Hotkey"
        case (.chinese, .recordNewHotkey): format = "录制新快捷键"

        case (.english, .pressNewHotkey): format = "Press new hotkey…"
        case (.chinese, .pressNewHotkey): format = "按下新的快捷键…"

        case (.english, .recordingHint): format = "Press a key combination with modifiers, such as ⌘⇧V or ⌥Space."
        case (.chinese, .recordingHint): format = "请按带修饰键的组合键，比如 ⌘⇧V / ⌥Space"

        case (.english, .hotkeyHint): format = "Use at least one modifier to avoid conflicts with normal typing."
        case (.chinese, .hotkeyHint): format = "建议至少包含一个修饰键，避免与普通输入冲突。"
        }

        return String(format: format, arguments: args)
    }

    enum Key {
        case hotkey, openClipboardHistory, settings, clearHistory, quit, storedItems
        case searchPlaceholder, close, noMatches, noMatchesHint, footerHint
        case hotkeySection, currentHotkey, retentionSection, maxItems, maxAgeDays, storageCap, languageSection
        case recordNewHotkey, pressNewHotkey, recordingHint, hotkeyHint
    }
}
