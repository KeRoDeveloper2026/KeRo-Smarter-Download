# الترخيص / Licensing

## العربية

حقوق الكود والتوثيق الأصليين: **Copyright (c) 2026 KeRo HaZem**.

من هذا التعديل، الترخيص المختار هو **GNU General Public License version 3 only**، ومعرّفه `GPL-3.0-only`. النص القانوني الكامل في [LICENSE](../LICENSE)، وبيان الحقوق في [COPYRIGHT](../COPYRIGHT).

- النسخة الرسمية مجانية تمامًا. استخدام GPL لا يتطلب شراء ترخيص.
- يُسمح بالاستخدام والتعديل وإعادة التوزيع، بما في ذلك بمقابل.
- عند توزيع نسخة تنفيذية مشتقة، يجب توفير المصدر المقابل لمستلميها بالطريقة التي تشترطها GPL، مع ملفات البناء اللازمة وإشعارات الحقوق والترخيص.
- لا يلزم نشر التعديلات المستخدمة بشكل خاص دون توزيع.
- لا يمنح الترخيص حقوق ملكية اسم البرنامج أو شعاره، ولا يجيز الادعاء بأن نسخة معدّلة صادرة عن المطور الأصلي.
- لا يُلغى بأثر رجعي أي إذن مُنح بصورة صحيحة لنسخ سابقة تحت ترخيص آخر.
- المكوّنات الخارجية تحتفظ بتراخيصها؛ تغيير ترخيص المشروع لا يعيد ترخيصها.

هذه الصفحة شرح مختصر؛ النص الكامل للترخيص هو المرجع. لا تغيّر هذه الإضافة ملفات Setup أو ZIP المنشورة سابقًا.

## English

Original project code and documentation: **Copyright (c) 2026 KeRo HaZem**.

From this change onward, the selected license is the **GNU General Public License version 3 only**, SPDX identifier `GPL-3.0-only`. See the complete [LICENSE](../LICENSE) and the project [COPYRIGHT](../COPYRIGHT) notice.

Use, modification and redistribution, including for a fee, are permitted subject to the GPL. When distributing derived executables, provide recipients with the Corresponding Source, including necessary build scripts, using an option permitted by GPL section 6. Preserve applicable copyright and license notices. Private modifications that are not distributed do not need to be published. The license does not grant ownership of the project's name or logo or permit misrepresenting a modified build as an official release.

This decision does not retroactively revoke permissions validly granted for earlier copies under another license. It does not alter previously published Setup or ZIP files.

## Third-party components / المكوّنات الخارجية

See [THIRD-PARTY-NOTICES.txt](../THIRD-PARTY-NOTICES.txt) for component sources, versions and license distinctions.

- Slint 1.18.1 provides a GPLv3 option, selected for future builds from this source revision. Its attribution is retained.
- Rust dependency licenses continue to apply independently; the workspace license field describes our code, not every dependency.
- yt-dlp, FFmpeg, LAME and aria2 are separately packaged helper executables with their own terms and source obligations.
- Shipping helper executables or linked libraries still requires compliance with their respective licenses; this document is not a complete license inventory or a certification of every resolved dependency.

Before a new binary release, record exact dependency versions and helper sources, retain required license texts/notices, and provide the corresponding source and build instructions required for the actual distributed binaries. Review the resolved dependency tree again when dependencies change.

Official references: [GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.html), [GNU GPL FAQ](https://www.gnu.org/licenses/gpl-faq.html), [Slint 1.18.1 licensing](https://github.com/slint-ui/slint/blob/v1.18.1/LICENSE.md).
