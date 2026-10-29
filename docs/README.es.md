<div align="center">

**🌐 Languages**

[العربية](../README.md) · [English](README.en.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · **Español** · [Português (Brasil)](README.pt-BR.md)  
[Русский](README.ru.md) · [Türkçe](README.tr.md) · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [हिन्दी](README.hi.md)

<br>

<img src="../crates/app/ui/kero-logo.png" alt="KeRo Smarter Download" width="128">

# KeRo Smarter Download

Gestor de descargas para Windows, desarrollado con **Rust** y **Slint**, con extensiones de navegador y seguimiento flotante de las descargas.

[![Release](https://img.shields.io/badge/release-v1.1.3-0EA5A4?style=flat-square)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.3)

</div>

## Descargas — v1.1.3

**Uso totalmente gratuito.** Elige la versión de Windows y la arquitectura de tu sistema.

| Sistema | Arquitectura | Descarga | Estado |
|---|---|---|---|
| Windows 10 / Windows 11 | 64-bit · x64 | [Descargar EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-Setup.exe) | Disponible |
| Windows 10 / Windows 11 | 32-bit · x86 | [Descargar EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win10_11-x86.exe) | Disponible |
| Windows 7 SP1 | 64-bit · x64 | [Descargar EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win7-Experimental-x64.exe) | Experimental |
| Windows 7 SP1 | 32-bit · x86 | [Descargar EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win7-Experimental-x86.exe) | Experimental |

En Windows 10 de 32 bits, elige x86. En Windows 10 o Windows 11 de 64 bits, se recomienda x64; la aplicación x86 también está disponible. En Windows 7 SP1, elige la arquitectura correspondiente. Compruébala en **Panel de control → Sistema → Tipo de sistema**.

> **Windows 7: versiones experimentales.** La compilación, las pruebas del motor y las comprobaciones de herramientas y dependencias se completaron en Windows Server 2022. La instalación, la interfaz y la integración con navegadores todavía no se han probado en un dispositivo real con Windows 7. [Detalles de compatibilidad (inglés)](WINDOWS-BUILDS.md).

## Actualización de la extensión — v1.1.1

Descarga el paquete adecuado sin reinstalar el programa. Los instaladores publicados pueden incluir una extensión anterior. Descomprime y carga la nueva carpeta, desactiva copias antiguas duplicadas y actualiza las páginas abiertas. El paquete Chromium está destinado a Chrome, Brave, Edge, Opera / Opera GX y Vivaldi en Windows. Safari y los navegadores móviles no están incluidos.

- [Chromium — v1.1.1](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRo-Extension-v1.1.1-Chromium.zip)
- [Firefox 140+ — v1.1.1](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRo-Extension-v1.1.1-Firefox.zip)
- [Firefox 115 ESR / Win7 — v1.1.1 (Experimental)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRo-Extension-v1.1.1-Firefox-Win7.zip)

[Compatibilidad y alcance de las pruebas (árabe / inglés)](BROWSERS.md)

## Funciones

- Descargas con hasta 32 conexiones, si el servidor lo permite.
- Pausa, reanudación, colas, programación y límites de velocidad.
- Selección de calidad y formato, listas de reproducción y conversión de audio mediante las herramientas incluidas.
- Extensiones para Chromium y Firefox, indicador flotante desplazable e interfaz multilingüe.

La velocidad, la reanudación y los formatos disponibles dependen del servidor, de la conexión y de los permisos de acceso al contenido.

## Instalación y extensiones

1. Descarga y ejecuta el instalador EXE adecuado para tu sistema.
2. Abre la aplicación y añade un enlace. La aplicación debe estar abierta para recibir descargas de la extensión.
3. Para Chrome, Brave o Edge: activa **Developer mode** en la página de extensiones, selecciona **Load unpacked** y elige la carpeta `extension` del directorio de instalación.
4. Para Firefox: abre `about:debugging#/runtime/this-firefox`, selecciona **Load Temporary Add-on** y el archivo `extension-firefox/manifest.json` del directorio de instalación.

El instalador incluye las herramientas y las dos carpetas de extensiones. Usa las del paquete elegido. Los paquetes Win7 incluyen un manifiesto adaptado a **Firefox 115 ESR**; los paquetes modernos requieren Firefox 140 o posterior. La extensión de Firefox no está firmada: se carga temporalmente y hay que volver a cargarla tras reiniciar el navegador.

## Idiomas de la página y de la aplicación

La documentación está disponible en **12 idiomas**. La interfaz de la aplicación ofrece **8 idiomas**: árabe, inglés, francés, español, alemán, portugués, turco y ruso. El idioma de esta página no añade idiomas a la aplicación.

## Código fuente, privacidad y ayuda

Para obtener el código fuente completo, usa **Code → Download ZIP**. En Windows, `BUILD.bat` prepara la compilación; instalar las herramientas de desarrollo puede requerir permisos de administrador.

La extensión se comunica localmente con la aplicación y puede enviar las cookies y el contexto necesarios para la descarga. No compartas cookies, ajustes confidenciales ni enlaces privados. Descarga únicamente contenido al que tengas permiso para acceder y guardar.

[Todos los archivos de la versión](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.3) · [Guía técnica y estado de la licencia (inglés)](README.en.md) · [Informar de un problema](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/issues)

Desarrollado por **KeRo HaZem**.

## Licencia

El código original del proyecto está bajo **[GNU GPL-3.0-only](../LICENSE)**. Copyright (c) 2026 KeRo HaZem. La versión oficial es gratuita. Los componentes de terceros conservan sus propias licencias. [Detalles (árabe / inglés)](LICENSING.md).
