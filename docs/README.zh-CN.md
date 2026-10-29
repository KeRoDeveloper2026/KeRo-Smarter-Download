<div align="center">

**🌐 Languages**

[العربية](../README.md) · [English](README.en.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md)  
[Русский](README.ru.md) · [Türkçe](README.tr.md) · **简体中文** · [日本語](README.ja.md) · [한국어](README.ko.md) · [हिन्दी](README.hi.md)

<br>

<img src="../crates/app/ui/kero-logo.png" alt="KeRo Smarter Download" width="128">

# KeRo Smarter Download

使用 **Rust** 和 **Slint** 开发的 Windows 下载管理器，提供浏览器扩展和悬浮下载进度窗口。

[![Release](https://img.shields.io/badge/release-v1.1.3-0EA5A4?style=flat-square)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.3)

</div>

## 下载 — v1.1.3

**完全免费使用。** 请根据 Windows 版本和系统架构选择安装程序。

| 系统 | 架构 | 直接下载 | 状态 |
|---|---|---|---|
| Windows 10 / Windows 11 | 64-bit · x64 | [下载 EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-Setup.exe) | 可下载 |
| Windows 10 / Windows 11 | 32-bit · x86 | [下载 EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win10_11-x86.exe) | 可下载 |
| Windows 7 SP1 | 64-bit · x64 | [下载 EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win7-Experimental-x64.exe) | 实验版 |
| Windows 7 SP1 | 32-bit · x86 | [下载 EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win7-Experimental-x86.exe) | 实验版 |

32 位 Windows 10 请选择 x86。64 位 Windows 10 或 Windows 11 建议选择 x64，也可使用 x86 应用。Windows 7 SP1 请选择与系统架构相符的实验版。可在 **控制面板 → 系统 → 系统类型** 中查看架构。

> **Windows 7 版本为实验版。** 已在 Windows Server 2022 上完成编译、下载引擎测试、辅助工具和依赖检查。尚未在真实的 Windows 7 设备上验证安装、界面运行或浏览器集成。 [兼容性详情（英文）](WINDOWS-BUILDS.md).

## 扩展更新 — v1.1.1

下载下方对应安装包即可，无需重新安装桌面程序。已发布的桌面安装程序可能仍附带旧版扩展。解压并加载新文件夹，禁用重复的旧扩展，然后刷新已打开的网页。Chromium 包适用于 Windows 上的 Chrome、Brave、Edge、Opera / Opera GX 和 Vivaldi。不包含 Safari 或移动浏览器版本。

- [Chromium — v1.1.1](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRo-Extension-v1.1.1-Chromium.zip)
- [Firefox 140+ — v1.1.1](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRo-Extension-v1.1.1-Firefox.zip)
- [Firefox 115 ESR / Win7 — v1.1.1 (实验版)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRo-Extension-v1.1.1-Firefox-Win7.zip)

[兼容性与测试范围（阿拉伯文／英文）](BROWSERS.md)

## 功能

- 服务器支持时，最多使用 32 个连接下载。
- 暂停、继续下载、队列、定时任务和速度限制。
- 通过附带工具选择媒体画质和格式、下载播放列表及转换音频。
- Chromium 和 Firefox 扩展、可拖动的悬浮进度窗口以及多语言界面。

下载速度、断点续传和可用格式取决于服务器、网络连接及内容访问权限。

## 安装与浏览器扩展

1. 下载并运行适合系统的 EXE 安装程序。
2. 打开应用并添加下载链接。接收浏览器扩展发送的下载任务时，应用必须保持运行。
3. Chrome、Brave 或 Edge：在扩展管理页面启用 **Developer mode（开发者模式）**，选择 **Load unpacked（加载已解压的扩展程序）**，然后选择安装目录中的 `extension` 文件夹。
4. Firefox：打开 `about:debugging#/runtime/this-firefox`，选择 **Load Temporary Add-on（临时载入附加组件）**，再选择安装目录中的 `extension-firefox/manifest.json`。

安装包包含辅助工具和两个扩展文件夹，请使用所选安装包自带的版本。Win7 安装包的 Firefox 清单已适配 **Firefox 115 ESR**；现代 Windows 安装包要求 Firefox 140 或更高版本。Firefox 扩展未经签名，只能临时载入，重启浏览器后需要重新载入。

## 文档语言与应用界面语言

文档提供 **12 种语言**。应用界面目前支持 **8 种语言**：阿拉伯语、英语、法语、西班牙语、德语、葡萄牙语、土耳其语和俄语。本页面提供中文文档，并不表示应用界面已支持中文。

## 源代码、隐私与帮助

完整源代码请通过 **Code → Download ZIP** 下载。在 Windows 上可使用 `BUILD.bat` 准备构建；安装开发工具可能需要管理员权限。

扩展通过本机连接与应用通信，并可能传递下载所需的 Cookie 和页面上下文。请勿分享 Cookie、敏感设置或私人链接。仅下载您有权访问并保存的内容。

[查看全部发行文件](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.3) · [技术指南与许可证状态（英文）](README.en.md) · [报告问题](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/issues)

开发者：**KeRo HaZem**。

## 许可证

项目原创代码采用 **[GNU GPL-3.0-only](../LICENSE)** 许可证。Copyright (c) 2026 KeRo HaZem。官方版本免费。第三方组件保留各自的许可证。[详情（阿拉伯语 / 英语）](LICENSING.md)。
