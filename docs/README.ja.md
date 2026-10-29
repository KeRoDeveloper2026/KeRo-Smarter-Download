<div align="center">

**🌐 Languages**

[العربية](../README.md) · [English](README.en.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md)  
[Русский](README.ru.md) · [Türkçe](README.tr.md) · [简体中文](README.zh-CN.md) · **日本語** · [한국어](README.ko.md) · [हिन्दी](README.hi.md)

<br>

<img src="../crates/app/ui/kero-logo.png" alt="KeRo Smarter Download" width="128">

# KeRo Smarter Download

**Rust** と **Slint** で開発された Windows 向けダウンロードマネージャーです。ブラウザー拡張機能とフローティング進捗表示を備えています。

[![Release](https://img.shields.io/badge/release-v1.1.4-0EA5A4?style=flat-square)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.4)

</div>

## ダウンロード — v1.1.4

**無料で利用できます。** Windows のバージョンとシステムのアーキテクチャに合うインストーラーを選んでください。

| システム | アーキテクチャ | ダウンロード | 状態 |
|---|---|---|---|
| Windows 10 / Windows 11 | 64-bit · x64 | [EXE をダウンロード](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win10_11-x64.exe) | ダウンロード可能 |
| Windows 10 / Windows 11 | 32-bit · x86 | [EXE をダウンロード](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win10_11-x86.exe) | ダウンロード可能 |
| Windows 7 SP1 | 64-bit · x64 | [EXE をダウンロード](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win7-Experimental-x64.exe) | 実験版 |
| Windows 7 SP1 | 32-bit · x86 | [EXE をダウンロード](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win7-Experimental-x86.exe) | 実験版 |

32 ビット版 Windows 10 では x86 を選んでください。64 ビット版 Windows 10 または Windows 11 では x64 を推奨します。x86 アプリも利用できます。Windows 7 SP1 ではシステムに合う実験版を選んでください。**コントロール パネル → システム → システムの種類** で確認できます。

> **Windows 7 向けは実験版です。** Windows Server 2022 上でビルド、ダウンロードエンジンのテスト、補助ツールと依存関係の確認を実施しました。実際の Windows 7 端末でのインストール、画面の動作、ブラウザー連携は未検証です。 [互換性の詳細（英語）](WINDOWS-BUILDS.md).

## 拡張機能の更新 — v1.1.4

下の対応するパッケージをダウンロードしてください。アプリの再インストールは不要です。v1.1.4 のインストーラーには拡張機能 1.1.1 が含まれます。それ以前のインストーラーには古い拡張機能が含まれる場合があります。新しいフォルダーを展開して読み込み、重複する古い拡張機能を無効にしてから、開いているページを更新してください。Chromium パッケージは Windows の Chrome、Brave、Edge、Opera / Opera GX、Vivaldi 向けです。Safari とモバイルブラウザーは含まれていません。

- [Chromium — v1.1.4](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRo-Extension-v1.1.4-Chromium.zip)
- [Firefox 140+ — v1.1.4](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRo-Extension-v1.1.4-Firefox.zip)
- [Firefox 115 ESR / Win7 — v1.1.4 (実験版)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRo-Extension-v1.1.4-Firefox-Win7.zip)

[互換性とテスト範囲（アラビア語／英語）](BROWSERS.md)

## 主な機能

- サーバーが対応している場合、最大 32 接続でダウンロード。
- 一時停止、再開、キュー、スケジュール、速度制限。
- 付属ツールによる画質・形式の選択、プレイリストのダウンロード、音声変換。
- Chromium と Firefox の拡張機能、ドラッグ可能なフローティング表示、多言語インターフェース。

ダウンロード速度、再開の可否、利用できる形式は、サーバー、接続環境、コンテンツへのアクセス権によって異なります。

## インストールとブラウザー拡張機能

1. システムに合う EXE インストーラーをダウンロードして実行します。
2. アプリを開いてリンクを追加します。拡張機能からダウンロードを受け取るには、アプリを起動しておく必要があります。
3. Chrome、Brave、Edge：拡張機能のページで **Developer mode（デベロッパーモード）** を有効にし、**Load unpacked（パッケージ化されていない拡張機能を読み込む）** からインストール先の `extension` フォルダーを選びます。
4. Firefox：`about:debugging#/runtime/this-firefox` を開き、**Load Temporary Add-on（一時的なアドオンを読み込む）** からインストール先の `extension-firefox/manifest.json` を選びます。

インストーラーには補助ツールと 2 つの拡張機能フォルダーが含まれています。選んだパッケージに付属するものを使用してください。Win7 パッケージの Firefox マニフェストは **Firefox 115 ESR** 向けに調整済みです。新しい Windows 向けのパッケージには Firefox 140 以降が必要です。Firefox 拡張機能は未署名で、一時的に読み込まれます。ブラウザーを再起動したら再読み込みが必要です。

## 文書とアプリの対応言語

ドキュメントは **12 言語** で提供しています。アプリの画面は **8 言語**（アラビア語、英語、フランス語、スペイン語、ドイツ語、ポルトガル語、トルコ語、ロシア語）に対応しています。この日本語ページは、アプリの画面が日本語に対応していることを意味しません。

## ソースコード・プライバシー・サポート

完全なソースコードは **Code → Download ZIP** から入手できます。Windows では `BUILD.bat` でビルドを準備します。開発ツールのインストールには管理者権限が必要な場合があります。

拡張機能はローカル接続でアプリと通信し、ダウンロードに必要な Cookie やページ情報を渡す場合があります。Cookie、機密設定、非公開リンクを共有しないでください。アクセスと保存が許可されたコンテンツのみをダウンロードしてください。

[リリースの全ファイル](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.4) · [技術ガイドとライセンスの状況（英語）](README.en.md) · [問題を報告](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/issues)

開発：**KeRo HaZem**。

## ライセンス

プロジェクト独自のコードは **[GNU GPL-3.0-only](../LICENSE)** の下で提供されます。Copyright (c) 2026 KeRo HaZem。公式版は無料です。第三者のコンポーネントには、それぞれのライセンスが適用されます。[詳細（アラビア語 / 英語）](LICENSING.md)。
