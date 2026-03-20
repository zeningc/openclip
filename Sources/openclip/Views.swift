import AppKit
import Carbon
import SwiftUI

struct MenuBarMenuView: View {
    @EnvironmentObject private var store: ClipboardStore
    @EnvironmentObject private var picker: PickerController
    @EnvironmentObject private var preferences: PreferencesStore

    private var l10n: L10n { preferences.l10n }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("openclip")
                .font(.headline)
            Text(l10n.text(.hotkey, preferences.hotKey.displayString))
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            Button(l10n.text(.openClipboardHistory)) {
                picker.showPicker()
            }

            Button(l10n.text(.settings)) {
                picker.openSettings(preferences: preferences, store: store)
            }

            Button(l10n.text(.clearHistory), role: .destructive) {
                store.clearAll()
            }

            Divider()

            Text(l10n.text(.storedItems, store.items.count))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(width: 240)
    }
}

struct PickerWindowView: View {
    @EnvironmentObject private var store: ClipboardStore
    @EnvironmentObject private var picker: PickerController
    @EnvironmentObject private var preferences: PreferencesStore

    private var l10n: L10n { preferences.l10n }

    private var filteredItems: [ClipboardItem] {
        let query = picker.query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if query.isEmpty { return store.items }
        return store.items.filter { $0.searchText.contains(query) }
    }

    var body: some View {
        VStack(spacing: 14) {
            header
            cardRail
            footer
        }
        .padding(18)
        .background(.regularMaterial)
        .onReceive(picker.commandPublisher) { command in
            switch command {
            case .moveLeft:
                moveSelection(by: -1)
            case .moveRight:
                moveSelection(by: 1)
            case .copySelection:
                if let item = selectedItem {
                    store.restore(item, autoPaste: false)
                    picker.closePicker(restoreFocus: true)
                }
            case .pasteSelection:
                if let item = selectedItem {
                    store.restore(item, autoPaste: false)
                    picker.closePicker(restoreFocus: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        store.restore(item, autoPaste: true)
                    }
                }
            case .close:
                picker.closePicker()
            }
        }
        .onChange(of: picker.query) { _ in
            syncSelectionToFilteredItems()
        }
        .onAppear {
            syncSelectionToFilteredItems()
        }
    }

    private var selectedItem: ClipboardItem? {
        if let id = picker.selectedItemID {
            return filteredItems.first(where: { $0.id == id })
        }
        return filteredItems.first
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(l10n.text(.searchPlaceholder), text: $picker.query)
                .textFieldStyle(.plain)
                .font(.title3)
            Spacer()
            Button(l10n.text(.close)) { picker.closePicker() }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.9))
        )
    }

    private var cardRail: some View {
        Group {
            if filteredItems.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "clipboard")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                    Text(l10n.text(.noMatches))
                        .font(.headline)
                    Text(l10n.text(.noMatchesHint))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(alignment: .top, spacing: 14) {
                            ForEach(filteredItems) { item in
                                ClipboardCardView(item: item, isSelected: picker.selectedItemID == item.id)
                                    .frame(width: 280, height: 180)
                                    .id(item.id)
                                    .onTapGesture {
                                        picker.selectedItemID = item.id
                                    }
                                    .onTapGesture(count: 2) {
                                        store.restore(item, autoPaste: false)
                                        picker.closePicker(restoreFocus: true)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                            store.restore(item, autoPaste: true)
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    .onChange(of: picker.selectedItemID) { newValue in
                        guard let newValue else { return }
                        withAnimation(.easeInOut(duration: 0.12)) {
                            proxy.scrollTo(newValue, anchor: .center)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var footer: some View {
        HStack {
            Text(l10n.text(.footerHint))
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            if let selectedItem {
                Text(selectedItem.kind.rawValue.uppercased())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 4)
    }

    private func moveSelection(by delta: Int) {
        guard !filteredItems.isEmpty else { return }
        if let currentID = picker.selectedItemID,
           let currentIndex = filteredItems.firstIndex(where: { $0.id == currentID }) {
            let nextIndex = max(0, min(filteredItems.count - 1, currentIndex + delta))
            picker.selectedItemID = filteredItems[nextIndex].id
        } else {
            picker.selectedItemID = filteredItems[0].id
        }
    }

    private func syncSelectionToFilteredItems() {
        guard !filteredItems.isEmpty else {
            picker.selectedItemID = nil
            return
        }
        if let selectedID = picker.selectedItemID,
           filteredItems.contains(where: { $0.id == selectedID }) {
            return
        }
        picker.selectedItemID = filteredItems[0].id
    }
}

struct ClipboardCardView: View {
    let item: ClipboardItem
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            preview
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(item.title)
                        .font(.headline)
                        .lineLimit(2)
                    Spacer(minLength: 8)
                    Text(item.kind.rawValue.uppercased())
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                if let subtitle = item.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(isSelected ? 1.0 : 0.82))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)
        )
        .shadow(color: .black.opacity(isSelected ? 0.15 : 0.06), radius: isSelected ? 12 : 6, y: 6)
        .scaleEffect(isSelected ? 1.0 : 0.985)
        .animation(.easeInOut(duration: 0.12), value: isSelected)
    }

    @ViewBuilder
    private var preview: some View {
        switch item.kind {
        case .text:
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.quaternary)
                Text(item.textContent ?? item.title)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
                    .padding(10)
            }
            .frame(height: 92)
        case .url:
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.quaternary)
                HStack(spacing: 10) {
                    Image(systemName: "link")
                    Text(item.urlString ?? item.title)
                        .font(.system(size: 12))
                        .lineLimit(3)
                }
                .padding(12)
            }
            .frame(height: 92)
        case .image:
            if let image = item.previewImage {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 92)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.quaternary)
                    .overlay(Image(systemName: "photo"))
                    .frame(height: 92)
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var store: ClipboardStore
    @EnvironmentObject private var preferences: PreferencesStore

    private var l10n: L10n { preferences.l10n }

    var body: some View {
        Form {
            Section(l10n.text(.hotkeySection)) {
                HotKeyRecorder(setting: $preferences.hotKey, l10n: l10n)
                Text(l10n.text(.currentHotkey, preferences.hotKey.displayString))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section(l10n.text(.retentionSection)) {
                Stepper(l10n.text(.maxItems, store.retentionPolicy.maxItems), value: $store.retentionPolicy.maxItems, in: 10...1000, step: 10)
                Stepper(l10n.text(.maxAgeDays, store.retentionPolicy.maxAgeDays), value: $store.retentionPolicy.maxAgeDays, in: 1...365)
                Stepper(l10n.text(.storageCap, ByteCountFormatter.string(fromByteCount: Int64(store.retentionPolicy.maxTotalBytes), countStyle: .file)), value: $store.retentionPolicy.maxTotalBytes, in: 1024 * 1024...512 * 1024 * 1024, step: 1024 * 1024)
            }

            Section(l10n.text(.languageSection)) {
                Picker(selection: $preferences.language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                } label: {
                    EmptyView()
                }
                .labelsHidden()
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 520, height: 260)
    }
}

struct HotKeyRecorder: View {
    @Binding var setting: HotKeySetting
    let l10n: L10n
    @State private var isRecording = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(isRecording ? l10n.text(.pressNewHotkey) : l10n.text(.recordNewHotkey)) {
                isRecording.toggle()
            }
            .keyboardShortcut(.defaultAction)

            Text(isRecording ? l10n.text(.recordingHint) : l10n.text(.hotkeyHint))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .background(
            HotKeyCaptureRepresentable(isRecording: $isRecording) { event in
                let modifiers = carbonModifiers(from: event.modifierFlags)
                guard modifiers != 0 else { return }
                setting = HotKeySetting(keyCode: UInt32(event.keyCode), modifiers: modifiers)
            }
        )
    }

    private func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var modifiers: UInt32 = 0
        if flags.contains(.command) { modifiers |= UInt32(cmdKey) }
        if flags.contains(.option) { modifiers |= UInt32(optionKey) }
        if flags.contains(.shift) { modifiers |= UInt32(shiftKey) }
        if flags.contains(.control) { modifiers |= UInt32(controlKey) }
        return modifiers
    }
}

struct HotKeyCaptureRepresentable: NSViewRepresentable {
    @Binding var isRecording: Bool
    let onCapture: (NSEvent) -> Void

    func makeNSView(context: Context) -> HotKeyCaptureView {
        let view = HotKeyCaptureView()
        view.onCapture = onCapture
        view.onFinish = { isRecording = false }
        return view
    }

    func updateNSView(_ nsView: HotKeyCaptureView, context: Context) {
        nsView.isRecording = isRecording
        nsView.onCapture = onCapture
        nsView.onFinish = { isRecording = false }
    }
}

final class HotKeyCaptureView: NSView {
    var isRecording = false {
        didSet {
            window?.makeFirstResponder(isRecording ? self : nil)
        }
    }
    var onCapture: ((NSEvent) -> Void)?
    var onFinish: (() -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        guard isRecording else {
            super.keyDown(with: event)
            return
        }
        onCapture?(event)
        onFinish?()
    }
}
