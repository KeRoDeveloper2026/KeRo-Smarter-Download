<div align="center">

**🌐 Languages**

[العربية](../README.md) · [English](README.en.md) · [Français](README.fr.md) · **Deutsch** · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md)  
[Русский](README.ru.md) · [Türkçe](README.tr.md) · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [हिन्दी](README.hi.md)

<br>

<img src="../crates/app/ui/kero-logo.png" alt="KeRo Smarter Download" width="128">

# KeRo Smarter Download

Downloadmanager für Windows, entwickelt mit **Rust** und **Slint**, mit Browser-Erweiterungen und schwebender Fortschrittsanzeige.

[![Release](https://img.shields.io/badge/release-v1.1.4-0EA5A4?style=flat-square)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.4)

</div>

## Downloads — v1.1.4

**Vollständig kostenlos nutzbar.** Wählen Sie die passende Windows-Version und Systemarchitektur.

| System | Architektur | Download | Status |
|---|---|---|---|
| Windows 10 / Windows 11 | 64-bit · x64 | [EXE herunterladen](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win10_11-x64.exe) | Verfügbar |
| Windows 10 / Windows 11 | 32-bit · x86 | [EXE herunterladen](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win10_11-x86.exe) | Verfügbar |
| Windows 7 SP1 | 64-bit · x64 | [EXE herunterladen](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win7-Experimental-x64.exe) | Experimentell |
| Windows 7 SP1 | 32-bit · x86 | [EXE herunterladen](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win7-Experimental-x86.exe) | Experimentell |

Für Windows 10 mit 32 Bit wählen Sie x86. Für Windows 10 oder Windows 11 mit 64 Bit wird x64 empfohlen; die x86-Anwendung ist ebenfalls verfügbar. Unter Windows 7 SP1 wählen Sie die passende Architektur. Prüfen Sie dies unter **Systemsteuerung → System → Systemtyp**.

> **Windows 7: experimentelle Versionen.** Kompilierung, Tests der Download-Engine sowie Prüfungen der Hilfsprogramme und Abhängigkeiten waren unter Windows Server 2022 erfolgreich. Installation, Oberfläche und Browser-Integration wurden noch nicht auf einem tatsächlichen Windows-7-Gerät getestet. [Kompatibilitätsdetails (Englisch)](WINDOWS-BUILDS.md).

## Erweiterungsupdate — v1.1.1

Laden Sie das passende Paket herunter; die Anwendung muss nicht neu installiert werden. Die Installer v1.1.4 enthalten die Erweiterung 1.1.1; ältere Installer können frühere Versionen enthalten. Entpacken und laden Sie den neuen Ordner, deaktivieren Sie doppelte alte Kopien und aktualisieren Sie offene Webseiten. Das Chromium-Paket richtet sich an Chrome, Brave, Edge, Opera / Opera GX und Vivaldi unter Windows. Safari und mobile Browser sind nicht enthalten.

- [Chromium — v1.1.1](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRo-Extension-v1.1.1-Chromium.zip)
- [Firefox 140+ — v1.1.1](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRo-Extension-v1.1.1-Firefox.zip)
- [Firefox 115 ESR / Win7 — v1.1.1 (Experimentell)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRo-Extension-v1.1.1-Firefox-Win7.zip)

[Kompatibilität und Testumfang (Arabisch / Englisch)](BROWSERS.md)

## Funktionen

- Downloads mit bis zu 32 Verbindungen, sofern der Server dies unterstützt.
- Pausieren, Fortsetzen, Warteschlangen, Zeitplanung und Geschwindigkeitsbegrenzungen.
- Auswahl von Medienqualität und Format, Wiedergabelisten und Audiokonvertierung über die mitgelieferten Hilfsprogramme.
- Chromium- und Firefox-Erweiterungen, verschiebbare Fortschrittsanzeige und mehrsprachige Oberfläche.

Geschwindigkeit, Fortsetzen und verfügbare Formate hängen vom Server, der Verbindung und den Zugriffsrechten ab.

## Installation und Erweiterungen

1. Laden Sie die passende EXE-Datei herunter und führen Sie sie aus.
2. Öffnen Sie das Programm und fügen Sie einen Link hinzu. Für Downloads aus der Erweiterung muss die Anwendung laufen.
3. Für Chrome, Brave oder Edge: Aktivieren Sie **Developer mode** auf der Erweiterungsseite, wählen Sie **Load unpacked** und anschließend den Ordner `extension` im Installationsverzeichnis.
4. Für Firefox: Öffnen Sie `about:debugging#/runtime/this-firefox`, wählen Sie **Load Temporary Add-on** und dann `extension-firefox/manifest.json` im Installationsverzeichnis.

Hilfsprogramme und beide Erweiterungsordner sind im Installer enthalten. Nutzen Sie die Ordner Ihres gewählten Pakets. Das Firefox-Manifest der Win7-Pakete ist für **Firefox 115 ESR** angepasst; moderne Pakete benötigen Firefox 140 oder neuer. Die Firefox-Erweiterung ist unsigniert und wird temporär geladen. Nach einem Browser-Neustart muss sie erneut geladen werden.

## Sprachen der Dokumentation und der Anwendung

Die Dokumentation ist in **12 Sprachen** verfügbar. Die Anwendung bietet **8 Oberflächensprachen**: Arabisch, Englisch, Französisch, Spanisch, Deutsch, Portugiesisch, Türkisch und Russisch. Die Sprache dieser Seite ändert die Sprachunterstützung der Anwendung nicht.

## Quellcode, Datenschutz und Hilfe

Den vollständigen Quellcode erhalten Sie über **Code → Download ZIP**. Unter Windows bereitet `BUILD.bat` den Build vor. Die Installation von Entwicklungswerkzeugen kann Administratorrechte erfordern.

Die Erweiterung kommuniziert lokal mit der Anwendung und kann Cookies sowie den für einen Download nötigen Seitenkontext übermitteln. Teilen Sie keine Cookies, vertraulichen Einstellungen oder privaten Links. Laden Sie nur Inhalte herunter, auf die Sie zugreifen und die Sie speichern dürfen.

[Alle Dateien der Version](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.4) · [Technische Anleitung und Lizenzstatus (Englisch)](README.en.md) · [Problem melden](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/issues)

Entwickelt von **KeRo HaZem**.

## Lizenz

Der ursprüngliche Projektcode steht unter **[GNU GPL-3.0-only](../LICENSE)**. Copyright (c) 2026 KeRo HaZem. Die offizielle Version ist kostenlos. Für Drittanbieterkomponenten gelten deren eigene Lizenzen. [Details (Arabisch / Englisch)](LICENSING.md).
