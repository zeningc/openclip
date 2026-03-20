import AppKit
import Foundation

struct ClipboardItem: Identifiable, Codable, Hashable {
    enum Kind: String, Codable, CaseIterable {
        case text
        case url
        case image
    }

    let id: UUID
    let createdAt: Date
    let kind: Kind
    let title: String
    let subtitle: String?
    let sizeInBytes: Int
    let textContent: String?
    let urlString: String?
    let imageTIFFData: Data?

    init(id: UUID = UUID(), createdAt: Date = .now, kind: Kind, title: String, subtitle: String? = nil, sizeInBytes: Int, textContent: String? = nil, urlString: String? = nil, imageTIFFData: Data? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.sizeInBytes = sizeInBytes
        self.textContent = textContent
        self.urlString = urlString
        self.imageTIFFData = imageTIFFData
    }

    var searchText: String {
        [title, subtitle, textContent, urlString].compactMap { $0 }.joined(separator: " ").lowercased()
    }

    var previewImage: NSImage? {
        guard let imageTIFFData else { return nil }
        return NSImage(data: imageTIFFData)
    }
}

struct RetentionPolicy: Codable, Hashable {
    var maxItems: Int
    var maxAgeDays: Int
    var maxTotalBytes: Int

    static let `default` = RetentionPolicy(maxItems: 150, maxAgeDays: 30, maxTotalBytes: 64 * 1024 * 1024)
}
