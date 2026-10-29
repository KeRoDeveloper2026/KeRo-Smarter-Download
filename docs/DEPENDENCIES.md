# Dependency locking / تثبيت إصدارات المكتبات

## العربية

يحفظ المشروع `Cargo.lock` في Git. هذا الملف يسجّل الإصدارات الدقيقة وبصمات حزم Rust، وتستخدم أوامر البناء والاختبار والجلب وأداة توقيع التحديث `--locked` لمنع تغيير الحل تلقائيًا.

جرى توليد القفل من ملفات Cargo الحالية باستخدام `nightly-2026-10-29`، ومقارنته بإصدارات المكتبات المسجّلة في [البناء الناجح السابق لـWindows 7](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/actions/runs/40833335595). احتفظ القفل بكل الإصدارات الـ405 المختلفة المسجّلة في تنزيلات معماريتَي Windows. لم يُؤرشف القفل الأصلي الكامل؛ لذلك لا ندّعي تطابق المكتبات الخاصة بالمنصات غير المسجّلة مع البناء القديم.

القفل يحتوي على 701 حزمة، منها حزمتا المشروع و699 حزمة خارجية. [تشغيل التحقق](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/actions/runs/40897345323) يولّد القفل ويفحصه، ثم يبني التطبيق ويختبر المحرك لكل من `i686-win7-windows-msvc` و`x86_64-win7-windows-msvc` باستخدام `--locked`، مع فحص imports والتأكد من ثبات بصمة القفل. تتم هذه الاختبارات على Windows Server 2022؛ لا تحل محل تجربة التشغيل على Windows 7 نفسه.

عند تحديث مكتبة عمدًا، استخدم Cargo مثل `cargo update -p PACKAGE --precise VERSION`، وراجع فرق القفل، ثم أعد اختبارات التوافق. لا تعدّل محتوى القفل يدويًا، ولا تحذفه لتجاوز فشل البناء. إصلاح Windows 7 يتحقق من مصادر `windows` و`windows-core` إصدار 0.62.2 وبصماتها، وأي تغيير يحتاج مراجعة مستقلة.

`Cargo.lock` لا يثبّت Rust نفسه أو Windows SDK أو الأدوات الخارجية مثل FFmpeg وyt-dlp؛ تبقى إعداداتها وبصماتها منفصلة. لا يغيّر هذا التعديل أي مثبّت منشور ولا يضمن تطابق EXE بتًا ببت.

## English

Commit `Cargo.lock` with intentional dependency changes. Project build, test, fetch and update-signing commands use `--locked`; Cargo must fail rather than silently change the resolved dependency graph.

The lock was generated with `nightly-2026-10-29` from the current manifests and checked against all 405 distinct package versions recorded in the successful Windows 7 x86/x64 download logs. The original complete lockfile was not archived, so historical identity of unrecorded platform-specific dependencies is not asserted. The lock contains 699 registry packages plus the two workspace packages.

The linked verification run builds both Windows 7 targets, runs their engine tests and the known unsupported-import check, and confirms that the lockfile hash stays unchanged. Its Windows Server 2022 checks do not establish Windows 7 runtime support. Existing published installers are unaffected.

Use Cargo to update selected dependencies intentionally, review the lock diff, and rerun compatibility checks. Do not edit checksums manually or delete the lock to bypass a failure. This file does not pin the Rust compiler, Windows SDK or external helper executables, and does not by itself guarantee bit-for-bit reproducible binaries.

## Quality checks and advisory follow-up / متابعة فحوصات الجودة

The [quality-check run](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/actions/runs/40906542546) checks formatting, strict Clippy, engine tests, browser simulations, Windows 7 compatibility-source hashes and Cargo advisories. Rust quality tools and the main Windows build use 1.99.1; the legacy build uses the previously verified nightly-2026-10-29. Dependencies were not upgraded during CI setup.

Cargo audit completed under its default policy with seven advisory warnings: six unmaintained-package notices (`bincode`, `proc-macro-error`, `ttf-parser`, `zbus_names`, `zvariant`, `zvariant_derive`) and an unsoundness advisory for `glib` ([RUSTSEC-2024-0429](https://rustsec.org/advisories/RUSTSEC-2024-0429.html)). These findings are visible in the logs; no advisory ignore list was added. The audited lockfile includes dependencies for multiple operating systems. The observed Windows compilation did not include `glib`; this observation does not resolve the advisory for other targets or configurations.

نجاح فحص audit لا يعني غياب كل المشكلات: توجد تنبيهات صيانة وتنبيه سلامة ذاكرة في شجرة المكتبات الكاملة تحتاج متابعة. لم نغيّر المكتبات تلقائيًا لإزالة التنبيهات. تُراجع التحديثات المقترحة عبر Dependabot، مع مراجعة التراخيص واختبارات التوافق قبل الدمج والنشر. فحص مصادر Windows 7 ليس بديلًا عن بناء النسخ وتجربة تشغيلها على Windows 7 نفسه.
