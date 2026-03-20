# openclip

English | [中文](#中文)

A lightweight macOS clipboard history app with a bottom-edge picker, keyboard-first navigation, and local-only storage.

Repo: https://github.com/zeningc/openclip

## English

### What is openclip?

openclip is a lightweight clipboard history tool for macOS, built with SwiftUI + AppKit.
It watches your clipboard, keeps a searchable local history, and lets you quickly bring back older copied items with a global hotkey.

### Highlights

- Menu bar utility app
- Clipboard history for **text**, **URLs**, and **images**
- Bottom-edge picker UI
- Searchable history panel
- Global hotkey (default: `⌘⌥V`)
- Arrow-key navigation
- `⌘C` copies the selected history item back to the clipboard and closes the panel
- `Return` restores the selected item and attempts to paste it into the previously active app
- Retention controls by item count, age, and total storage size
- UI language option: **English / 中文**
- Local-only data storage

### Installation

#### Run from source

```bash
git clone https://github.com/zeningc/openclip.git
cd openclip
swift build
swift run openclip
```

#### Open in Xcode

You can also open the package folder in Xcode and run it as a macOS app target.

### Permissions

To allow automatic paste into the frontmost app after choosing a history item, grant **Accessibility** permission:

- System Settings → Privacy & Security → Accessibility

Without that permission, openclip can still restore content to the clipboard, but it will not synthesize `⌘V`.

### Data storage

History is stored locally at:

`~/Library/Application Support/openclip/history.json`

### Notes

- openclip behaves like a menu bar utility instead of a normal Dock app.
- Duplicate consecutive clipboard entries are ignored.
- Image entries are stored as TIFF data, so retention limits matter for disk usage.

---

## 中文

### openclip 是什么？

openclip 是一个面向 macOS 的轻量级剪贴板历史工具，基于 SwiftUI + AppKit 开发。
它会监听你的剪贴板变化，把历史内容保存在本地，并通过全局快捷键快速呼出历史面板，帮助你找回之前复制过的内容。

### 功能亮点

- 菜单栏常驻工具
- 支持 **文本 / 链接 / 图片** 剪贴板历史
- 屏幕底部呼出的历史面板
- 支持搜索历史内容
- 全局快捷键（默认：`⌘⌥V`）
- 支持方向键切换选择
- 按 `⌘C` 可将当前选中的历史项复制回剪贴板并关闭面板
- 按 `Return` 可恢复该项，并尝试回到上一个应用自动粘贴
- 支持按数量、天数、总容量自动清理历史
- 支持 **英文 / 中文** 界面切换
- 所有数据仅保存在本地

### 安装方式

#### 从源码运行

```bash
git clone https://github.com/zeningc/openclip.git
cd openclip
swift build
swift run openclip
```

#### 用 Xcode 打开

你也可以直接用 Xcode 打开这个 Swift Package，并作为 macOS app 运行。

### 权限说明

如果你希望在选中历史项后自动粘贴到前台应用，需要给 openclip 开启 **辅助功能（Accessibility）权限**：

- 系统设置 → 隐私与安全性 → 辅助功能

如果不开启该权限，openclip 仍然可以把内容恢复到剪贴板，但不会自动模拟 `⌘V`。

### 数据存储

历史记录保存在本地：

`~/Library/Application Support/openclip/history.json`

### 补充说明

- openclip 更像菜单栏工具，而不是普通 Dock 应用。
- 连续重复复制的内容会被忽略，不会重复入库。
- 图片以 TIFF 形式保存，因此历史容量上限对磁盘占用很重要。
