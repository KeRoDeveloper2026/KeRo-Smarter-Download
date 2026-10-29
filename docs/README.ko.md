<div align="center">

**🌐 Languages**

[العربية](../README.md) · [English](README.en.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md)  
[Русский](README.ru.md) · [Türkçe](README.tr.md) · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · **한국어** · [हिन्दी](README.hi.md)

<br>

<img src="../crates/app/ui/kero-logo.png" alt="KeRo Smarter Download" width="128">

# KeRo Smarter Download

**Rust**와 **Slint**로 개발한 Windows용 다운로드 관리자입니다. 브라우저 확장 기능과 플로팅 다운로드 진행 표시를 제공합니다.

[![Release](https://img.shields.io/badge/release-v1.1.4-0EA5A4?style=flat-square)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.4)

</div>

## 다운로드 — v1.1.4

**완전히 무료로 사용할 수 있습니다.** Windows 버전과 시스템 아키텍처에 맞는 설치 파일을 선택하세요.

| 운영 체제 | 아키텍처 | 다운로드 | 상태 |
|---|---|---|---|
| Windows 10 / Windows 11 | 64-bit · x64 | [EXE 다운로드](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win10_11-x64.exe) | 다운로드 가능 |
| Windows 10 / Windows 11 | 32-bit · x86 | [EXE 다운로드](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win10_11-x86.exe) | 다운로드 가능 |
| Windows 7 SP1 | 64-bit · x64 | [EXE 다운로드](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win7-Experimental-x64.exe) | 실험 버전 |
| Windows 7 SP1 | 32-bit · x86 | [EXE 다운로드](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win7-Experimental-x86.exe) | 실험 버전 |

32비트 Windows 10에서는 x86을 선택하세요. 64비트 Windows 10 또는 Windows 11에서는 x64를 권장하며, x86 앱도 사용할 수 있습니다. Windows 7 SP1에서는 시스템에 맞는 실험 버전을 선택하세요. **제어판 → 시스템 → 시스템 종류**에서 확인할 수 있습니다.

> **Windows 7용은 실험 버전입니다.** Windows Server 2022에서 빌드, 다운로드 엔진 테스트, 보조 도구 및 종속성 검사를 통과했습니다. 실제 Windows 7 기기에서 설치, 화면 동작, 브라우저 연동은 아직 검증하지 않았습니다. [호환성 세부 정보 (영어)](WINDOWS-BUILDS.md).

## 확장 기능 업데이트 — v1.1.1

아래에서 맞는 패키지를 받으세요. 데스크톱 앱을 다시 설치할 필요는 없습니다. v1.1.4 설치 파일에는 확장 기능 1.1.1이 포함됩니다. 이전 설치 파일에는 더 오래된 버전이 포함될 수 있습니다. 압축을 풀고 새 폴더를 로드한 뒤 중복된 이전 확장 기능을 끄고 열려 있는 웹페이지를 새로 고치세요. Chromium 패키지는 Windows의 Chrome, Brave, Edge, Opera / Opera GX, Vivaldi용입니다. Safari와 모바일 브라우저 버전은 포함되지 않습니다.

- [Chromium — v1.1.1](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRo-Extension-v1.1.1-Chromium.zip)
- [Firefox 140+ — v1.1.1](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRo-Extension-v1.1.1-Firefox.zip)
- [Firefox 115 ESR / Win7 — v1.1.1 (실험 버전)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRo-Extension-v1.1.1-Firefox-Win7.zip)

[호환성 및 테스트 범위 (아랍어 / 영어)](BROWSERS.md)

## 주요 기능

- 서버가 지원하는 경우 최대 32개 연결로 다운로드합니다.
- 일시 중지, 이어받기, 대기열, 예약 및 속도 제한을 지원합니다.
- 포함된 보조 도구로 화질과 형식을 선택하고, 재생목록을 다운로드하고, 오디오를 변환합니다.
- Chromium 및 Firefox 확장 기능, 드래그 가능한 플로팅 표시와 다국어 인터페이스를 제공합니다.

속도, 이어받기 및 사용 가능한 형식은 서버, 네트워크 연결, 콘텐츠 접근 권한에 따라 달라집니다.

## 설치 및 브라우저 확장 기능

1. 시스템에 맞는 EXE 설치 파일을 다운로드하여 실행하세요.
2. 앱을 열고 링크를 추가하세요. 확장 기능에서 다운로드를 받으려면 앱이 실행 중이어야 합니다.
3. Chrome, Brave 또는 Edge: 확장 프로그램 페이지에서 **Developer mode(개발자 모드)**를 켜고 **Load unpacked(압축해제된 확장 프로그램을 로드합니다)**를 선택한 뒤 설치 경로의 `extension` 폴더를 지정하세요.
4. Firefox: `about:debugging#/runtime/this-firefox`를 열고 **Load Temporary Add-on(임시 부가 기능 로드)**을 선택한 뒤 설치 경로의 `extension-firefox/manifest.json`을 지정하세요.

설치 파일에는 보조 도구와 두 확장 기능 폴더가 포함되어 있습니다. 선택한 설치 패키지에 포함된 폴더를 사용하세요. Win7 패키지의 Firefox 매니페스트는 **Firefox 115 ESR**에 맞게 조정되어 있으며, 최신 Windows용 패키지에는 Firefox 140 이상이 필요합니다. Firefox 확장 기능은 서명되지 않아 임시로 로드되며, 브라우저를 다시 시작하면 다시 로드해야 합니다.

## 문서 언어와 앱 언어

문서는 **12개 언어**로 제공됩니다. 앱 인터페이스는 **8개 언어**(아랍어, 영어, 프랑스어, 스페인어, 독일어, 포르투갈어, 튀르키예어, 러시아어)를 지원합니다. 이 한국어 문서가 앱의 한국어 인터페이스 지원을 의미하지는 않습니다.

## 소스 코드, 개인정보 보호 및 도움말

전체 소스 코드는 **Code → Download ZIP**에서 받을 수 있습니다. Windows에서 `BUILD.bat`으로 빌드를 준비할 수 있으며, 개발 도구 설치에는 관리자 권한이 필요할 수 있습니다.

확장 기능은 로컬 연결로 앱과 통신하며 다운로드에 필요한 쿠키와 페이지 정보를 전달할 수 있습니다. 쿠키, 민감한 설정 또는 비공개 링크를 공유하지 마세요. 접근하고 저장할 권한이 있는 콘텐츠만 다운로드하세요.

[모든 릴리스 파일](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.4) · [기술 가이드 및 라이선스 현황 (영어)](README.en.md) · [문제 보고](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/issues)

개발: **KeRo HaZem**.

## 라이선스

프로젝트의 자체 코드는 **[GNU GPL-3.0-only](../LICENSE)** 라이선스로 제공됩니다. Copyright (c) 2026 KeRo HaZem. 공식 버전은 무료입니다. 타사 구성 요소에는 각자의 라이선스가 적용됩니다. [자세한 내용 (아랍어 / 영어)](LICENSING.md).
