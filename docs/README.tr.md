<div align="center">

**🌐 Languages**

[العربية](../README.md) · [English](README.en.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md)  
[Русский](README.ru.md) · **Türkçe** · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [हिन्दी](README.hi.md)

<br>

<img src="../crates/app/ui/kero-logo.png" alt="KeRo Smarter Download" width="128">

# KeRo Smarter Download

**Rust** ve **Slint** ile geliştirilen; tarayıcı uzantıları ve yüzen indirme göstergesi sunan bir Windows indirme yöneticisi.

[![Release](https://img.shields.io/badge/release-v1.1.3-0EA5A4?style=flat-square)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.3)

</div>

## İndirmeler — v1.1.3

**Kullanımı tamamen ücretsizdir.** Windows sürümünüze ve sistem mimarinize uygun yükleyiciyi seçin.

| Sistem | Mimari | İndir | Durum |
|---|---|---|---|
| Windows 10 / Windows 11 | 64-bit · x64 | [EXE indir](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-Setup.exe) | Kullanılabilir |
| Windows 10 / Windows 11 | 32-bit · x86 | [EXE indir](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win10_11-x86.exe) | Kullanılabilir |
| Windows 7 SP1 | 64-bit · x64 | [EXE indir](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win7-Experimental-x64.exe) | Deneysel |
| Windows 7 SP1 | 32-bit · x86 | [EXE indir](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win7-Experimental-x86.exe) | Deneysel |

32 bit Windows 10 için x86 seçin. 64 bit Windows 10 veya Windows 11 için x64 önerilir; x86 uygulaması da kullanılabilir. Windows 7 SP1 için sisteminize uygun mimariyi seçin. Kontrol etmek için **Denetim Masası → Sistem → Sistem türü** yolunu izleyin.

> **Windows 7 sürümleri deneyseldir.** Derleme, indirme motoru testleri, yardımcı araç ve bağımlılık kontrolleri Windows Server 2022 üzerinde başarılı oldu. Kurulum, arayüz ve tarayıcı entegrasyonu henüz gerçek bir Windows 7 cihazında test edilmedi. [Uyumluluk ayrıntıları (İngilizce)](WINDOWS-BUILDS.md).

## Uzantı güncellemesi — v1.1.1

Programı yeniden kurmadan uygun paketi indirin. Yayımlanmış yükleyiciler daha eski bir uzantı içerebilir. Yeni paketi açıp klasörünü yükleyin, yinelenen eski kopyaları devre dışı bırakın ve açık sayfaları yenileyin. Chromium paketi Windows üzerinde Chrome, Brave, Edge, Opera / Opera GX ve Vivaldi için hazırlanmıştır. Safari ve mobil tarayıcılar dahil değildir.

- [Chromium — v1.1.1](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRo-Extension-v1.1.1-Chromium.zip)
- [Firefox 140+ — v1.1.1](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRo-Extension-v1.1.1-Firefox.zip)
- [Firefox 115 ESR / Win7 — v1.1.1 (Deneysel)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRo-Extension-v1.1.1-Firefox-Win7.zip)

[Uyumluluk ve test kapsamı (Arapça / İngilizce)](BROWSERS.md)

## Özellikler

- Sunucu destekliyorsa 32 bağlantıya kadar indirme.
- Duraklatma, devam ettirme, kuyruklar, zamanlama ve hız sınırları.
- Birlikte sunulan araçlarla medya kalitesi ve biçimi seçimi, oynatma listeleri ve ses dönüştürme.
- Chromium ve Firefox uzantıları, sürüklenebilir yüzen gösterge ve çok dilli arayüz.

Hız, devam ettirme ve kullanılabilir biçimler sunucuya, bağlantıya ve içeriğe erişim izinlerine bağlıdır.

## Kurulum ve uzantılar

1. Sisteminize uygun EXE yükleyicisini indirin ve çalıştırın.
2. Uygulamayı açıp bir bağlantı ekleyin. Uzantıdan indirme alabilmek için programın açık olması gerekir.
3. Chrome, Brave veya Edge için: uzantılar sayfasında **Developer mode** seçeneğini etkinleştirin, **Load unpacked** seçeneğine tıklayın ve kurulum dizinindeki `extension` klasörünü seçin.
4. Firefox için: `about:debugging#/runtime/this-firefox` sayfasını açın, **Load Temporary Add-on** seçeneğini ve kurulum dizinindeki `extension-firefox/manifest.json` dosyasını seçin.

Yükleyici, yardımcı araçları ve her iki uzantı klasörünü içerir. Seçtiğiniz paketin klasörlerini kullanın. Win7 paketlerinin Firefox manifesti **Firefox 115 ESR** için uyarlanmıştır; modern paketler Firefox 140 veya üzerini gerektirir. Firefox uzantısı imzasızdır ve geçici olarak yüklenir; tarayıcı yeniden başlatıldığında tekrar yüklenmelidir.

## Sayfanın ve uygulamanın dilleri

Dokümantasyon **12 dilde** sunulmaktadır. Uygulama arayüzü **8 dili** destekler: Arapça, İngilizce, Fransızca, İspanyolca, Almanca, Portekizce, Türkçe ve Rusça. Bu sayfanın dili, uygulamaya yeni bir arayüz dili eklemez.

## Kaynak kodu, gizlilik ve destek

Kaynak kodunun tamamı için **Code → Download ZIP** yolunu kullanın. Windows üzerinde `BUILD.bat` derleme ortamını hazırlar; geliştirme araçlarının kurulumu yönetici izni gerektirebilir.

Uzantı uygulamayla yerel olarak iletişim kurar ve indirme için gereken çerezleri ve sayfa bağlamını aktarabilir. Çerezleri, hassas ayarları veya özel bağlantıları paylaşmayın. Yalnızca erişmeye ve kaydetmeye yetkili olduğunuz içerikleri indirin.

[Sürümün tüm dosyaları](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.3) · [Teknik kılavuz ve lisans durumu (İngilizce)](README.en.md) · [Sorun bildir](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/issues)

Geliştirici: **KeRo HaZem**.
