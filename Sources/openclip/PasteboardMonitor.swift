import AppKit
import Foundation
import UniformTypeIdentifiers

@MainActor
final class PasteboardMonitor {
    private let pasteboard = NSPasteboard.general
    private weak var store: ClipboardStore?
    private var timer: Timer?
    private var lastChangeCount: Int
    private var isRestoring = false

    init(store: ClipboardStore) {
        self.store = store
        self.lastChangeCount = pasteboard.changeCount
    }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.poll()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func poll() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount
        guard let item = captureCurrentContents() else { return }
        Task { @MainActor [weak store] in
            store?.add(item)
        }
    }

    private func captureCurrentContents() -> ClipboardItem? {
        if let url = pasteboard.readObjects(forClasses: [NSURL.self], options: nil)?.first as? URL {
            let value = url.absoluteString
            return ClipboardItem(kind: .url, title: value, subtitle: url.host, sizeInBytes: value.utf8.count, urlString: value)
        }

        if let text = pasteboard.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            let title = text.replacingOccurrences(of: "\n", with: " ").prefix(120)
            let kind: ClipboardItem.Kind = URL(string: text) != nil ? .url : .text
            return ClipboardItem(kind: kind, title: String(title), subtitle: kind == .url ? URL(string: text)?.host : nil, sizeInBytes: text.utf8.count, textContent: kind == .text ? text : nil, urlString: kind == .url ? text : nil)
        }

        if let image = NSImage(pasteboard: pasteboard), let tiff = image.tiffRepresentation {
            let size = image.size
            return ClipboardItem(kind: .image, title: "Image \(Int(size.width))×\(Int(size.height))", subtitle: ByteCountFormatter.string(fromByteCount: Int64(tiff.count), countStyle: .file), sizeInBytes: tiff.count, imageTIFFData: tiff)
        }

        return nil
    }
}
