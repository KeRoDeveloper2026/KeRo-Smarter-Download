<div align="center">

<img src="crates/app/ui/kero-logo.png" alt="KeRo Smarter Download" width="144">

# KeRo Smarter Download

**العربية** · [English](docs/README.en.md) · [Français](docs/README.fr.md) · [Deutsch](docs/README.de.md) · [Español](docs/README.es.md) · [Português (Brasil)](docs/README.pt-BR.md)  
[Русский](docs/README.ru.md) · [Türkçe](docs/README.tr.md) · [简体中文](docs/README.zh-CN.md) · [日本語](docs/README.ja.md) · [한국어](docs/README.ko.md) · [हिन्दी](docs/README.hi.md)

### تحميل منظّم · تحكّم أوضح · تجربة عربية

مدير تنزيلات لسطح مكتب **Windows**، مبني بلغة **Rust** وواجهة **Slint**، مع تكامل للمتصفح ولوجو عائم لمتابعة التنزيلات.

![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4?style=flat-square)
![Rust](https://img.shields.io/badge/Rust-engine-DEA584?style=flat-square&logo=rust&logoColor=white)
![Slint](https://img.shields.io/badge/Slint-desktop_UI-2379F4?style=flat-square)
[![Version](https://img.shields.io/badge/release-v1.1.3-0EA5A4?style=flat-square)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.3)
![Windows 7 Experimental](https://img.shields.io/badge/Windows_7-SP1_Experimental-B7791F?style=flat-square)
![Languages](https://img.shields.io/badge/UI-8_languages-6366F1?style=flat-square)
[![Documentation languages](https://img.shields.io/badge/docs-12_languages-0EA5A4?style=flat-square)](docs/LANGUAGES.md)

[تحميل البرنامج](#التحميل-المباشر) · [البدء](#البدء) · [المميزات](#المميزات) · [إضافات المتصفح](#إضافات-المتصفح) · [البناء](#البناء-من-المصدر) · [English](docs/README.en.md)

</div>

**اختر لغة الصفحة من القائمة بالأعلى.** صفحات التعريف والتنزيل متاحة بـ**12 لغة**، وواجهة البرنامج تدعم **8 لغات**. ترجمة صفحة المشروع لا تغيّر اللغات المتاحة داخل التطبيق. [دليل اللغات](docs/LANGUAGES.md).

---

## التحميل المباشر

**الإصدار الحالي: v1.1.3 · البرنامج مجاني تمامًا**

اختر المثبّت المناسب لنظام جهازك ونوعه. اضغط زر التحميل في الصف المطلوب لتنزيل ملف **EXE** مباشرة.

| نظام التشغيل | نوع النسخة | التحميل المباشر | الحالة |
|---|---|---|---|
| **Windows 10 / Windows 11** | 64-bit · x64 | [![تحميل Windows 10 / Windows 11 64-bit · x64](https://img.shields.io/badge/Download-Win10%2F11%20x64-0078D4?style=for-the-badge)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-Setup.exe) | النسخة الأساسية |
| **Windows 10 / Windows 11** | 32-bit · x86 | [![تحميل Windows 10 / Windows 11 32-bit · x86](https://img.shields.io/badge/Download-Win10%2F11%20x86-0078D4?style=for-the-badge)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win10_11-x86.exe) | تطبيق 32-bit |
| **Windows 7 SP1** | 64-bit · x64 | [![تحميل Windows 7 SP1 64-bit · x64](https://img.shields.io/badge/Download-Win7%20x64%20Experimental-B7791F?style=for-the-badge)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win7-Experimental-x64.exe) | تجريبي |
| **Windows 7 SP1** | 32-bit · x86 | [![تحميل Windows 7 SP1 32-bit · x86](https://img.shields.io/badge/Download-Win7%20x86%20Experimental-B7791F?style=for-the-badge)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win7-Experimental-x86.exe) | تجريبي |

**كيف تختار نسختك؟**
- **Windows 10 بنواة 32-bit:** اختر Win10/11 x86.
- **Windows 10 أو Windows 11 بنواة 64-bit:** اختر Win10/11 x64. نسخة x86 متاحة أيضًا كتطبيق 32-bit.
- **Windows 7 SP1:** اختر Win7 x64 أو Win7 x86 وفق نوع نظامك.

لمعرفة نوع النظام، افتح **لوحة التحكم → النظام → نوع النظام (System type)**. تسميتا x86 و32-bit تعنيان النسخة نفسها.

> **نسختا Windows 7 تجريبيتان:** نجحت اختبارات المحرك وفحوص ملفات البرنامج والأدوات على Windows Server 2022. لم يُختبر التثبيت والتشغيل أو تكامل المتصفح على جهاز Windows 7 فعلي بعد. [تفاصيل التوافق والفحوص](docs/WINDOWS-BUILDS.md).

### الإضافات المرفقة والتحميل المنفصل

**المثبّت يتضمن البرنامج والأدوات المساعدة ومجلدي الإضافات.** بعد التثبيت، استخدم مجلد `extension` لمتصفحات Chrome وBrave وEdge، أو `extension-firefox` لمتصفح Firefox من داخل مجلد تثبيت البرنامج. [خطوات تركيب الإضافة](#إضافات-المتصفح).

**لمستخدمي Windows 7:** استخدم الإضافة المرفقة مع مثبّت Win7؛ حزمة Firefox داخلها مجهزة لـ**Firefox 115 ESR**. تشغيل الإضافات على Windows 7 ما زال بحاجة إلى تجربة فعلية.

الروابط التالية لتنزيل الإضافات منفصلة، وهي حزم منشورة سابقًا ضمن **v1.1.0**:

| الإضافة | رابط التنزيل | طريقة التركيب |
|---|---|---|
| Chrome / Brave / Edge | [تنزيل إضافة Chromium — ZIP](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.0/KeRo-Extension-Chromium.zip) | فك الضغط ثم اختر المجلد عبر Load unpacked |
| Firefox | [تنزيل إضافة Firefox — ZIP](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.0/KeRo-Extension-Firefox.zip) | تحميل مؤقت من about:debugging؛ الإضافة غير موقّعة |
| الإضافتان معًا | [تنزيل حزمة الإضافات — ZIP](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.0/KeRo-Smarter-Download.zip) | مجلدا الإضافات في حزمة واحدة |

[عرض كل ملفات الإصدار v1.1.3](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.3) · [المصدر الكامل — Code → Download ZIP](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download)

<details>
<summary>التحقق من الملفات وبيانات التحديث</summary>

كل نسخة لها ملف تحديث مستقل يتضمن بصمة SHA-256 وتوقيع Ed25519. هذه ملفات بيانات وليست ملفات تثبيت.

| النسخة | ملف التحديث |
|---|---|
| Windows 10/11 — x64 | [version.json](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/version.json) |
| Windows 10/11 — x86 | [version-Win10_11-x86.json](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/version-Win10_11-x86.json) |
| Windows 7 — x64 | [version-Win7-x64.json](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/version-Win7-x64.json) |
| Windows 7 — x86 | [version-Win7-x86.json](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/version-Win7-x86.json) |

أرشيف `KeRo-Smarter-Download.zip` في جدول الإضافات يحتوي على الإضافات فقط. المصدر الكامل يُنزّل من **Code → Download ZIP** ويحتاج إلى تجميع.

</details>

## عن المشروع

يجمع **KeRo Smarter Download** تنزيل الملفات وتنظيمها واستئنافها ومتابعة تقدمها في تطبيق واحد. يدعم الروابط المباشرة ووسائط الصفحات وقوائم التشغيل، ويتيح اختيار الجودة والصيغة عندما يوفرهما المصدر.

تدعم الواجهة **العربية والإنجليزية والفرنسية والإسبانية والألمانية والبرتغالية والتركية والروسية**، مع اتجاه من اليمين إلى اليسار للعربية.

> **حالة النسخة:** الإصدار **1.1.3** يربط التحديثات بهذا المستودع ويُرفق المثبّت مع `version.json` الموقّع في [الإصدار v1.1.3](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.3). ثبّت هذه النسخة يدويًا مرة واحدة بدل النسخة القديمة لتفعيل التحديثات التالية. اختبارات البناء نجحت؛ تجربة التثبيت والتشغيل الفعلي تحتاج إلى Windows.

## المميزات

| المجال | ما يقدّمه البرنامج |
|---|---|
| تنزيل الملفات | اتصالات متعددة تصل إلى **32 اتصالًا** عندما يدعم الخادم تقسيم الملف، مع إيقاف مؤقت واستئناف |
| الفيديو والصوت | اختيار الجودة والصيغة، وقوائم التشغيل، ودمج الفيديو والصوت وتحويل MP3 عبر الأدوات المساعدة |
| تكامل المتصفح | إضافتان لمتصفحات Chromium وFirefox لالتقاط الروابط وإرسالها إلى التطبيق |
| متابعة عائمة | لوجو قابل للسحب يعرض نسبة التقدم وأزرار الإيقاف والاستئناف والعودة إلى التفاصيل |
| تنظيم الملفات | تصنيف تلقائي حسب النوع، وإضافة روابط متعددة، واستيراد القوائم وتصديرها |
| إدارة المهام | قوائم انتظار، وجدولة، وحد عام للسرعة أو حد لكل تنزيل، وخيارات عند اكتمال المهام |
| جمع الروابط | أداة Grabber لجمع روابط الملفات من الصفحات |
| استخدام يومي | مراقبة اختيارية للحافظة، وتكامل مع منطقة الإشعارات، وتحديد متعدد للمهام |

سرعة التنزيل وإمكانية الاستئناف والجودات المتاحة تعتمد على الخادم والاتصال وصلاحيات الوصول إلى المحتوى.

## البدء

1. نزّل **Setup** المطابق لمعمارية جهازك من جدول التحميل المباشر أعلاه.
2. شغّل ملف المثبّت الذي نزّلته لتثبيت النسخة الجديدة.
3. افتح البرنامج وأضف رابطًا، أو ركّب إضافة متصفحك المرفقة مع المثبّت واتبع خطوات تركيبها أدناه.

للحصول على إصدار تبنيه بنفسك، اتبع [البناء من المصدر](#البناء-من-المصدر). ملف المصدر الذي يوفّره GitHub عبر **Code → Download ZIP** يحتاج إلى تجميع، بعكس ملف المثبّت المرفق.

**متطلبات التشغيل:** Windows 10 بنواة 32-bit أو 64-bit، أو Windows 11 بنواة 64-bit مع دعم تطبيقات x86، واتصال بالإنترنت. تتوفر نسختان تجريبيتان مستقلتان لـWindows 7 SP1 بنواتي x86 وx64 في الجدول أعلاه. اجتازتا فحوص البناء على Windows Server 2022، ولم يُختبر تشغيلهما بعد على جهاز Windows 7 فعلي؛ راجع [حالة بناء Windows](docs/WINDOWS-BUILDS.md). التثبيت مخصص للمستخدم الحالي؛ أما تثبيت أدوات التطوير أثناء البناء فقد يطلب صلاحيات المسؤول.

### متابعة التنزيل باللوجو العائم

- اضغط **◉** في شريط عنوان نافذة التنزيل لإظهار اللوجو.
- اسحبه لتغيير موقعه، واستخدم **+ / −** لتغيير حجمه.
- استخدم **Ⅱ / ▶** للإيقاف المؤقت أو الاستئناف، و**↗** للعودة إلى التفاصيل.
- إخفاء النافذة أو اللوجو لا يوقف التنزيل؛ يمكنك استعادة النافذة من منطقة الإشعارات.
- إذا لم يكن الحجم معروفًا، تظهر **…** إلى أن تتوفر بيانات لحساب النسبة.

## إضافات المتصفح

يجب تشغيل تطبيق سطح المكتب لكي يستقبل التنزيلات من الإضافة.

### Chrome وBrave وEdge

1. استخدم مجلد `extension` داخل مجلد تثبيت البرنامج، أو فك ضغط حزمة الإضافة المنفصلة.
2. افتح `chrome://extensions` أو `brave://extensions` أو `edge://extensions`.
3. فعّل **Developer mode** ثم اختر **Load unpacked**.
4. اختر مجلد [`extension`](extension)، ثم أعد تحميل صفحة الموقع.

عند تحديث الملفات اضغط **Reload** في بطاقة الإضافة ثم أعد تحميل الصفحة. أوقف النسخة القديمة لتجنب تشغيل إضافتين لنفس البرنامج.

### Firefox

1. افتح `about:debugging#/runtime/this-firefox`.
2. اختر **Load Temporary Add-on**.
3. اختر `manifest.json` من مجلد `extension-firefox` داخل مجلد تثبيت البرنامج. لمستخدمي Windows 7، استخدم المجلد المرفق مع مثبّت Win7 لتثبيت نسخة Firefox 115 ESR.

الإضافة المرفقة غير موقّعة، والتحميل بهذه الطريقة مؤقت ويحتاج إلى تكراره بعد إعادة تشغيل Firefox. متطلب إصدار Firefox في الحزم الحديثة هو **140 أو أحدث**؛ أما حزم Windows 7 التجريبية فتتضمن manifest مخصصًا لـ**Firefox 115 ESR**. التوزيع الدائم يحتاج إلى حزمة موقّعة من Mozilla؛ ملف XPI غير الموقّع مخصص للتطوير.

## البناء من المصدر

### الطريقة المبسّطة على Windows

```powershell
git clone https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download.git
cd KeRo-Smarter-Download
.\BUILD.bat
```

يمكن أيضًا تنزيل ZIP وفكّه ثم تشغيل `BUILD.bat`. يعتمد السكربت على **winget**، ويثبّت أدوات Visual Studio C++ وRust وInno Setup إذا كانت ناقصة، وينزّل الأدوات المساعدة. يحتاج إلى الإنترنت وقد يستغرق وقتًا في المرة الأولى.

| الناتج | المسار |
|---|---|
| التطبيق بعد التجميع | `target/release/KeRoDownload.exe` |
| ملف التثبيت بعد نجاح التعبئة | `dist/KeRoDownload-Setup.exe` |

### للمطورين

بعد تجهيز Rust stable MSVC وأدوات Visual Studio C++ على Windows:

```powershell
cargo build --release
cargo test -p swiftget-engine --no-fail-fast
```

أسماء حزم Rust الداخلية ما زالت تستخدم `swiftget` في بعض المواضع. التجميع وحده لا يجهّز بالضرورة الأدوات الخارجية أو المثبّت؛ استخدم سكربت البناء للحصول على الحزمة الكاملة.

## الاختبارات وحالة التحقق

تعمل اختبارات إضافة المتصفح باستخدام Node.js:

```sh
node extension/test/compat.test.js
node extension/test/yt-core.test.js
node extension/test/background.sim.js
node extension/test/background.sim.js --firefox
node extension/test/content.sim.js
node extension/test/content.sim.js --firefox
```

هذه الاختبارات تحاكي واجهات المتصفح؛ لا تثبت عمل كل موقع في متصفح فعلي، ولا تمثل قياسًا لسرعة الشبكة أو استهلاك الذاكرة. راجع [تقرير الاختبار](TEST_REPORT.md) لمعرفة نطاق التحقق السابق وحدوده.

## GitHub Actions والإصدارات

يتضمن المشروع [سير عمل لبناء Windows](.github/workflows/build.yml) لبناء FFmpeg وتشغيل الاختبارات وتجميع التطبيق وتعبئته. بعد نجاحه يمكن تنزيل الناتج من **Artifacts** في صفحة [Actions](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/actions).

لنشر Release موقّع، اختر `main` وفعّل `publish_release` عند تشغيل سير العمل يدويًا، أو استخدم رسالة commit تتضمن `[release]` على `main`. راجع [تجهيز الإصدارات](docs/RELEASING.md) لضبط مفتاح التوقيع. تُحفظ الإصدارات الأقدم وروابطها.

## الخصوصية والاتصالات

| المكوّن | السلوك في المصدر الحالي |
|---|---|
| اتصال الإضافة | اتصال محلي عبر `127.0.0.1`؛ المنفذ الافتراضي `9614` |
| صلاحيات المتصفح | صلاحيات للتنزيلات والصفحات وCookies لالتقاط الروابط ونقل سياق التنزيل؛ راجع ملفات manifest قبل التثبيت |
| بيانات جلسة الموقع | قد تُمرّر Cookies وعنوان الصفحة إلى التطبيق المحلي لطلب المحتوى المصرّح للمستخدم بالوصول إليه |
| حفظ البيانات الحساسة | يستخدم Windows DPAPI للحقول المخصصة لكلمات المرور وCookies، مع مسارات رجوع للنص العادي عند تعذر الحماية؛ لا تشارك الإعدادات أو قوائم التنزيل |
| تحديث التطبيق | يتحقق دوريًا من بيانات الإصدار؛ يفحص التحديث المقبول بتوقيع Ed25519 وبصمة SHA-256، ويمكن تثبيته بصمت مع إعادة تشغيل التطبيق |
| الأدوات المساعدة | يستخدم yt-dlp وFFmpeg وaria2 لبعض الوظائف، وقد ينزّل الأدوات أو يحدّثها بحسب مسار التشغيل |
| الحافظة والتشغيل التلقائي | توجد خيارات في الإعدادات لمراقبة الحافظة والتشغيل مع Windows |

للمشكلات الأمنية، راجع [سياسة الإبلاغ](SECURITY.md). لا تضع Cookies أو كلمات مرور أو روابط خاصة في Issues.

## حل المشكلات

| المشكلة | الخطوة المقترحة |
|---|---|
| `ffmpeg.exe` غير موجود | شغّل `REPAIR-FFMPEG.bat` ثم أعد فتح التطبيق واستأنف التنزيل؛ يحتاج الإصلاح إلى الإنترنت ويتحقق من الملف المنزّل |
| الإضافة لا ترسل التنزيل | تأكد من تشغيل التطبيق والإضافة، وأعد تحميل الصفحة، وأوقف النسخ القديمة المتكررة |
| لا تظهر كل الجودات | قد يقيّد الموقع الجودات أو يحتاج إلى جلسة دخول؛ أعد تحليل الرابط وتحقق من صلاحية الوصول |
| تحذير SmartScreen | قد يظهر للملفات غير الموقّعة؛ تحقّق من مصدر الملف قبل تشغيله |
| لا يوجد EXE بعد تنزيل ZIP | نزّل Setup — EXE من جدول التحميل؛ أرشيف الإضافات والمصدر لا يحتويان على المثبّت |

## خريطة المشروع

| المسار | المحتوى |
|---|---|
| [`crates/engine`](crates/engine) | محرك التنزيلات والإعدادات والتعامل مع الوسائط |
| [`crates/app`](crates/app) | التطبيق وواجهات Slint والترجمات |
| [`extension`](extension) | إضافة Chromium واختبارات JavaScript |
| [`extension-firefox`](extension-firefox) | نسخة إضافة Firefox |
| [`installer`](installer) | إعدادات مثبّت Inno Setup |
| [`tools/ffmpeg`](tools/ffmpeg) | سكربت بناء FFmpeg |
| [تحديث 1.1.0](UPDATE_1.1.0_AR.md) | تفاصيل تغييرات النسخة المرفقة |

## المساهمة والتواصل

افتح [Issue](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/issues/new/choose) للإبلاغ عن عطل أو اقتراح تحسين، وراجع [دليل المساهمة](CONTRIBUTING.md) قبل إرسال تعديل.

**تطوير KeRo — [KeRoDeveloper2026](https://github.com/KeRoDeveloper2026)**

## الحقوق والمكوّنات الخارجية

المصدر المرفق يذكر `MIT` داخل `Cargo.toml`، بينما وثائق النسخة الأصلية تذكر «جميع الحقوق محفوظة»، ولا تتضمن ملف `LICENSE` مستقلًا. يلزم أن يحدّد مالك المشروع الترخيص المقصود؛ هذه التهيئة لا تمنح ترخيصًا جديدًا ولا تغيّر حقوقه.

راجع [THIRD-PARTY-NOTICES.txt](THIRD-PARTY-NOTICES.txt) للمكوّنات الخارجية. استخدم البرنامج لتنزيل المحتوى الذي تملك حق الوصول إليه وتنزيله، مع احترام حقوق الملكية وشروط المواقع.
