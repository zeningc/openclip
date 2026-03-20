# openclip

English | [中文](#中文)

openclip is a lightweight macOS clipboard history app built with SwiftUI + AppKit.

## English

### Features

- Menu bar app
- Clipboard history for text, URLs, and images
- Bottom-edge picker UI
- Searchable history
- Global hotkey (default: `⌘⌥V`)
- Keyboard navigation with arrow keys
- `⌘C` copies the selected history item back to the clipboard and closes the panel
- `Return` restores the item and attempts to paste it into the previous app
- Retention limits by count, age, and total storage size
- Language option: English / 中文

### Data storage

History is stored locally at:

`~/Library/Application Support/openclip/history.json`

### Build

```bash
swift build
```

### Run

```bash
swift run openclip
```

### Permissions

For automatic paste into the frontmost app after selecting a history item, grant **Accessibility** permission:

- System Settings → Privacy & Security → Accessibility

Without that permission, openclip can still restore content to the clipboard, but it will not synthesize `⌘V`.

### Notes

- The app behaves like a menu bar utility instead of a normal Dock app.
- Duplicate consecutive clipboard entries are ignored.
- Image entries are stored as TIFF data, so retention limits matter for disk usage.

---

## 中文

openclip 是一个用 SwiftUI + AppKit 开发的轻量级 macOS 剪贴板历史工具。

### 功能

- 菜单栏常驻应用
- 支持文本、链接、图片的剪贴板历史
- 屏幕底部呼出的历史面板
- 支持搜索历史内容
- 全局快捷键（默认：`⌘⌥V`）
- 支持方向键切换选择
- 按 `⌘C` 可将当前选中的历史项复制回剪贴板并关闭面板
- 按 `Return` 可恢复该项并尝试回到原应用自动粘贴
- 支持按数量、天数、总容量自动清理历史
- 支持英文 / 中文界面切换

### 数据存储

历史记录保存在本地：

`~/Library/Application Support/openclip/history.json`

### 构建

```bash
swift build
```

### 运行

```bash
swift run openclip
```

### 权限说明

如果你希望在选择历史项后自动粘贴到前台应用，需要给 openclip 开启 **辅助功能（Accessibility）权限**：

- 系统设置 → 隐私与安全性 → 辅助功能

如果不开启该权限，openclip 仍然可以把内容恢复到剪贴板，但不会自动模拟 `⌘V`。

### 说明

- 这个应用更像菜单栏工具，而不是普通 Dock 应用。
- 连续重复复制的内容会被忽略，不会重复入库。
- 图片以 TIFF 形式保存，因此历史容量上限对磁盘占用很重要。
