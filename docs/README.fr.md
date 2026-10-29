<div align="center">

**🌐 Languages**

[العربية](../README.md) · [English](README.en.md) · **Français** · [Deutsch](README.de.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md)  
[Русский](README.ru.md) · [Türkçe](README.tr.md) · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [हिन्दी](README.hi.md)

<br>

<img src="../crates/app/ui/kero-logo.png" alt="KeRo Smarter Download" width="128">

# KeRo Smarter Download

Gestionnaire de téléchargements pour Windows, développé avec **Rust** et **Slint**, avec extensions de navigateur et suivi flottant des téléchargements.

[![Release](https://img.shields.io/badge/release-v1.1.4-0EA5A4?style=flat-square)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.4)

</div>

## Téléchargements — v1.1.4

**Utilisation entièrement gratuite.** Choisissez votre version de Windows et l’architecture de votre système.

| Système | Architecture | Téléchargement | État |
|---|---|---|---|
| Windows 10 / Windows 11 | 64-bit · x64 | [Télécharger EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win10_11-x64.exe) | Disponible |
| Windows 10 / Windows 11 | 32-bit · x86 | [Télécharger EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win10_11-x86.exe) | Disponible |
| Windows 7 SP1 | 64-bit · x64 | [Télécharger EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win7-Experimental-x64.exe) | Expérimental |
| Windows 7 SP1 | 32-bit · x86 | [Télécharger EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win7-Experimental-x86.exe) | Expérimental |

Sous Windows 10 32 bits, choisissez x86. Sous Windows 10 ou Windows 11 64 bits, privilégiez x64 ; l’application x86 est également disponible. Sous Windows 7 SP1, choisissez l’architecture correspondante. Pour vérifier : **Panneau de configuration → Système → Type du système**.

> **Windows 7 : versions expérimentales.** La compilation, les tests du moteur, les vérifications des outils et des dépendances ont réussi sur Windows Server 2022. L’installation, l’interface et l’intégration aux navigateurs n’ont pas encore été testées sur un véritable appareil Windows 7. [Détails de compatibilité (anglais)](WINDOWS-BUILDS.md).

## Mise à jour de l’extension — v1.1.4

Téléchargez le paquet ci-dessous sans réinstaller le programme. Les installateurs v1.1.4 incluent l’extension 1.1.1 ; les versions plus anciennes peuvent contenir une extension antérieure. Décompressez la nouvelle version, chargez son dossier, désactivez toute ancienne copie en double et actualisez les pages ouvertes. La version Chromium cible Chrome, Brave, Edge, Opera / Opera GX et Vivaldi sur Windows. Safari et les navigateurs mobiles ne sont pas inclus.

- [Chromium — v1.1.4](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRo-Extension-v1.1.4-Chromium.zip)
- [Firefox 140+ — v1.1.4](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRo-Extension-v1.1.4-Firefox.zip)
- [Firefox 115 ESR / Win7 — v1.1.4 (Expérimental)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRo-Extension-v1.1.4-Firefox-Win7.zip)

[Compatibilité et limites des tests (arabe / anglais)](BROWSERS.md)

## Fonctionnalités

- Téléchargements avec jusqu’à 32 connexions, si le serveur les prend en charge.
- Pause, reprise, files d’attente, planification et limites de débit.
- Choix de la qualité et du format des médias, listes de lecture et conversion audio via les outils intégrés.
- Extensions Chromium et Firefox, fenêtre flottante déplaçable et interface multilingue.

Le débit, la reprise et les formats disponibles dépendent du serveur, de la connexion et des droits d’accès au contenu.

## Installation et extensions

1. Téléchargez et exécutez le fichier EXE adapté à votre système.
2. Ouvrez l’application et ajoutez un lien. Le programme doit être lancé pour recevoir les téléchargements de l’extension.
3. Pour Chrome, Brave ou Edge : activez **Developer mode** dans la page des extensions, puis **Load unpacked** et sélectionnez le dossier `extension` dans le répertoire d’installation.
4. Pour Firefox : ouvrez `about:debugging#/runtime/this-firefox`, choisissez **Load Temporary Add-on**, puis `extension-firefox/manifest.json` dans le répertoire d’installation.

Les outils et les deux dossiers d’extensions sont inclus dans l’installateur. Utilisez ceux du paquet choisi. Le manifeste Firefox des versions Win7 est adapté à **Firefox 115 ESR** ; les paquets modernes exigent Firefox 140 ou ultérieur. L’extension Firefox n’est pas signée : son chargement est temporaire et doit être renouvelé après le redémarrage du navigateur.

## Langues de la page et de l’application

La documentation est disponible en **12 langues**. L’interface de l’application propose **8 langues** : arabe, anglais, français, espagnol, allemand, portugais, turc et russe. La langue de cette page n’ajoute pas de langue à l’application.

## Code source, confidentialité et assistance

Pour obtenir le code source complet, utilisez **Code → Download ZIP**. Sur Windows, `BUILD.bat` prépare la compilation ; l’installation des outils de développement peut demander les droits administrateur.

L’extension communique localement avec l’application et peut transmettre les cookies et le contexte nécessaires au téléchargement. Ne partagez pas vos cookies, paramètres sensibles ou liens privés. Téléchargez uniquement les contenus auxquels vous êtes autorisé à accéder et à enregistrer.

[Tous les fichiers de la version](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.4) · [Guide technique et statut de la licence (anglais)](README.en.md) · [Signaler un problème](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/issues)

Développé par **KeRo HaZem**.

## Licence

Le code original du projet est sous licence **[GNU GPL-3.0-only](../LICENSE)**. Copyright (c) 2026 KeRo HaZem. La version officielle est gratuite. Les composants tiers conservent leurs propres licences. [Détails (arabe / anglais)](LICENSING.md).
