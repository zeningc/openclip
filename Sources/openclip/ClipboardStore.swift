import AppKit
import Foundation

@MainActor
final class ClipboardStore: ObservableObject {
    @Published private(set) var items: [ClipboardItem] = []
    @Published var retentionPolicy: RetentionPolicy = .default {
        didSet {
            applyRetentionPolicy()
            save()
        }
    }

    private let persistenceURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init() {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = appSupport.appendingPathComponent("openclip", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        persistenceURL = folder.appendingPathComponent("history.json")
        load()
    }

    func add(_ item: ClipboardItem) {
        if let existing = items.first, isEffectivelyDuplicate(lhs: existing, rhs: item) {
            return
        }
        items.insert(item, at: 0)
        applyRetentionPolicy()
        save()
    }

    func remove(ids: Set<UUID>) {
        items.removeAll { ids.contains($0.id) }
        save()
    }

    func clearAll() {
        items.removeAll()
        save()
    }

    func restore(_ item: ClipboardItem, autoPaste: Bool = false) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch item.kind {
        case .text:
            if let text = item.textContent {
                pasteboard.setString(text, forType: .string)
            }
        case .url:
            if let urlString = item.urlString, let url = URL(string: urlString) {
                pasteboard.writeObjects([url as NSURL])
                pasteboard.setString(urlString, forType: .string)
            }
        case .image:
            if let image = item.previewImage {
                pasteboard.writeObjects([image])
            }
        }

        if autoPaste {
            synthesizePasteShortcut()
        }
    }

    private func applyRetentionPolicy() {
        let cutoff = Calendar.current.date(byAdding: .day, value: -retentionPolicy.maxAgeDays, to: .now) ?? .distantPast
        items = items
            .filter { $0.createdAt >= cutoff }
            .prefix(retentionPolicy.maxItems)
            .map { $0 }

        var totalBytes = 0
        items = items.filter { item in
            totalBytes += item.sizeInBytes
            return totalBytes <= retentionPolicy.maxTotalBytes
        }
    }

    private func isEffectivelyDuplicate(lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        lhs.kind == rhs.kind && lhs.textContent == rhs.textContent && lhs.urlString == rhs.urlString && lhs.imageTIFFData == rhs.imageTIFFData
    }

    private func load() {
        guard let data = try? Data(contentsOf: persistenceURL) else { return }
        struct Persisted: Codable { let items: [ClipboardItem]; let retentionPolicy: RetentionPolicy }
        guard let persisted = try? decoder.decode(Persisted.self, from: data) else { return }
        items = persisted.items
        retentionPolicy = persisted.retentionPolicy
        applyRetentionPolicy()
    }

    private func save() {
        struct Persisted: Codable { let items: [ClipboardItem]; let retentionPolicy: RetentionPolicy }
        let persisted = Persisted(items: items, retentionPolicy: retentionPolicy)
        guard let data = try? encoder.encode(persisted) else { return }
        try? data.write(to: persistenceURL, options: [.atomic])
    }

    private func synthesizePasteShortcut() {
        guard AXIsProcessTrusted() else { return }
        let source = CGEventSource(stateID: .hidSystemState)
        let vDown = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: true)
        vDown?.flags = .maskCommand
        let vUp = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: false)
        vUp?.flags = .maskCommand
        vDown?.post(tap: .cghidEventTap)
        vUp?.post(tap: .cghidEventTap)
    }
}
