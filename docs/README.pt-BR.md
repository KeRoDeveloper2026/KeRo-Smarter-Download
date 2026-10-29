<div align="center">

<img src="../crates/app/ui/kero-logo.png" alt="KeRo Smarter Download" width="128">

# KeRo Smarter Download

[العربية](../README.md) · [English](README.en.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · **Português (Brasil)**  
[Русский](README.ru.md) · [Türkçe](README.tr.md) · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [हिन्दी](README.hi.md)

Gerenciador de downloads para Windows, desenvolvido com **Rust** e **Slint**, com extensões de navegador e acompanhamento flutuante dos downloads.

[![Release](https://img.shields.io/badge/release-v1.1.3-0EA5A4?style=flat-square)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.3)

</div>

## Downloads — v1.1.3

**Totalmente gratuito para usar.** Escolha a versão do Windows e a arquitetura do seu sistema.

| Sistema | Arquitetura | Download | Situação |
|---|---|---|---|
| Windows 10 / Windows 11 | 64-bit · x64 | [Baixar EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-Setup.exe) | Disponível |
| Windows 10 / Windows 11 | 32-bit · x86 | [Baixar EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win10_11-x86.exe) | Disponível |
| Windows 7 SP1 | 64-bit · x64 | [Baixar EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win7-Experimental-x64.exe) | Experimental |
| Windows 7 SP1 | 32-bit · x86 | [Baixar EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win7-Experimental-x86.exe) | Experimental |

No Windows 10 de 32 bits, escolha x86. No Windows 10 ou Windows 11 de 64 bits, recomendamos x64; o aplicativo x86 também está disponível. No Windows 7 SP1, escolha a arquitetura correspondente. Confira em **Painel de Controle → Sistema → Tipo de sistema**.

> **Windows 7: versões experimentais.** A compilação, os testes do mecanismo de download e as verificações das ferramentas e dependências passaram no Windows Server 2022. A instalação, a interface e a integração com navegadores ainda não foram testadas em um dispositivo real com Windows 7. [Detalhes de compatibilidade (inglês)](WINDOWS-BUILDS.md).

## Recursos

- Downloads com até 32 conexões, quando o servidor oferece suporte.
- Pausa, retomada, filas, agendamento e limites de velocidade.
- Escolha de qualidade e formato, playlists e conversão de áudio pelas ferramentas incluídas.
- Extensões para Chromium e Firefox, indicador flutuante que pode ser arrastado e interface multilíngue.

A velocidade, a retomada e os formatos disponíveis dependem do servidor, da conexão e das permissões de acesso ao conteúdo.

## Instalação e extensões

1. Baixe e execute o instalador EXE adequado para o seu sistema.
2. Abra o aplicativo e adicione um link. O programa precisa estar aberto para receber downloads da extensão.
3. No Chrome, Brave ou Edge: ative **Developer mode** na página de extensões, selecione **Load unpacked** e escolha a pasta `extension` no diretório de instalação.
4. No Firefox: abra `about:debugging#/runtime/this-firefox`, selecione **Load Temporary Add-on** e o arquivo `extension-firefox/manifest.json` no diretório de instalação.

O instalador inclui as ferramentas e as duas pastas de extensões. Use as pastas do pacote escolhido. Os pacotes Win7 incluem um manifesto adaptado ao **Firefox 115 ESR**; os pacotes modernos exigem Firefox 140 ou posterior. A extensão do Firefox não é assinada: o carregamento é temporário e precisa ser repetido após reiniciar o navegador.

## Idiomas da página e do aplicativo

A documentação está disponível em **12 idiomas**. A interface do aplicativo oferece **8 idiomas**: árabe, inglês, francês, espanhol, alemão, português, turco e russo. O idioma desta página não adiciona idiomas ao aplicativo.

## Código-fonte, privacidade e ajuda

Para obter o código-fonte completo, use **Code → Download ZIP**. No Windows, `BUILD.bat` prepara a compilação; a instalação das ferramentas de desenvolvimento pode exigir permissões de administrador.

A extensão se comunica localmente com o aplicativo e pode enviar os cookies e o contexto necessários ao download. Não compartilhe cookies, configurações confidenciais ou links privados. Baixe apenas conteúdo que você tenha autorização para acessar e salvar.

[Todos os arquivos da versão](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.3) · [Guia técnico e situação da licença (inglês)](README.en.md) · [Relatar um problema](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/issues)

Desenvolvido por **KeRo HaZem**.
