<div align="center">

<img src="crates/app/ui/kero-logo.png" alt="KeRo Smarter Download" width="144">

# KeRo Smarter Download

### تحميل منظّم · تحكّم أوضح · تجربة عربية

مدير تنزيلات لسطح مكتب **Windows**، مبني بلغة **Rust** وواجهة **Slint**، مع تكامل للمتصفح ولوجو عائم لمتابعة التنزيلات.

![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4?style=flat-square)
![Rust](https://img.shields.io/badge/Rust-engine-DEA584?style=flat-square&logo=rust&logoColor=white)
![Slint](https://img.shields.io/badge/Slint-desktop_UI-2379F4?style=flat-square)
![Version](https://img.shields.io/badge/source-v1.1.1-0EA5A4?style=flat-square)
![Languages](https://img.shields.io/badge/UI-8_languages-6366F1?style=flat-square)

[البدء](#البدء) · [المميزات](#المميزات) · [إضافات المتصفح](#إضافات-المتصفح) · [البناء](#البناء-من-المصدر) · [English](docs/README.en.md)

</div>

---

## التحميل المباشر

| الملف | رابط التنزيل | طريقة الاستخدام |
|---|---|---|
| مثبّت Windows مباشر | [تنزيل Setup — EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.0/KeRoDownload-Setup.exe) | شغّل الملف لبدء التثبيت |
| المثبّت داخل ملف مضغوط | [تنزيل Setup — ZIP](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.0/KeRoDownload-Setup.zip) | فك الضغط ثم شغّل `KeRoDownload-Setup.exe` |
| إضافة Chrome وBrave وEdge | [تنزيل إضافة Chromium](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.0/KeRo-Extension-Chromium.zip) | فك الضغط ثم اختر المجلد عبر Load unpacked |
| إضافة Firefox | [تنزيل إضافة Firefox](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.0/KeRo-Extension-Firefox.zip) | فك الضغط ثم حمّل manifest.json مؤقتًا من about:debugging |
| حزمة الإضافتين كاملة | [تنزيل حزمة الإضافات](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.0/KeRo-Smarter-Download.zip) | تحتوي على مجلدي extension وextension-firefox |
| بصمات الملفات | [SHA256SUMS.txt](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.0/SHA256SUMS.txt) | للتحقق من سلامة التنزيل |

**مهم:** ملف `KeRo-Smarter-Download.zip` هنا حزمة إضافات فقط. للحصول على المصدر الكامل استخدم **Code → Download ZIP**. نسخة Firefox غير موقّعة ومخصصة للتحميل المؤقت. المثبّت المرفق مقدّم من مالك المشروع ولم يُختبر تشغيله في بيئة تجهيز المستودع.

## عن المشروع

يجمع **KeRo Smarter Download** تنزيل الملفات وتنظيمها واستئنافها ومتابعة تقدمها في تطبيق واحد. يدعم الروابط المباشرة ووسائط الصفحات وقوائم التشغيل، ويتيح اختيار الجودة والصيغة عندما يوفرهما المصدر.

تدعم الواجهة **العربية والإنجليزية والفرنسية والإسبانية والألمانية والبرتغالية والتركية والروسية**، مع اتجاه من اليمين إلى اليسار للعربية.

> **حالة النسخة:** مصدر الإصدار **1.1.1** يربط التحديثات بهذا المستودع؛ نشر مثبّت جديد يتطلب تجهيز مفتاح التوقيع كما في [دليل الإصدارات](docs/RELEASING.md). المثبّت المقدّم من مالك المشروع متاح الآن في [الإصدار v1.1.0](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.0)؛ لم يُختبر تشغيله على Windows في بيئة تجهيز المستودع.

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

1. نزّل **Setup — EXE** من جدول التحميل المباشر أعلاه، أو اختر ZIP إذا كنت تفضّل نسخة مضغوطة.
2. شغّل `KeRoDownload-Setup.exe`؛ عند اختيار ZIP فك الضغط أولًا.
3. افتح البرنامج وأضف رابطًا، أو نزّل إضافة متصفحك واتبع خطوات تركيبها أدناه.

للحصول على إصدار تبنيه بنفسك، اتبع [البناء من المصدر](#البناء-من-المصدر). ملف المصدر الذي يوفّره GitHub عبر **Code → Download ZIP** يحتاج إلى تجميع، بعكس ملف المثبّت المرفق.

**متطلبات التشغيل:** Windows 10 أو Windows 11 بنواة 64-bit، واتصال بالإنترنت. التثبيت مخصص للمستخدم الحالي؛ أما تثبيت أدوات التطوير أثناء البناء فقد يطلب صلاحيات المسؤول.

### متابعة التنزيل باللوجو العائم

- اضغط **◉** في شريط عنوان نافذة التنزيل لإظهار اللوجو.
- اسحبه لتغيير موقعه، واستخدم **+ / −** لتغيير حجمه.
- استخدم **Ⅱ / ▶** للإيقاف المؤقت أو الاستئناف، و**↗** للعودة إلى التفاصيل.
- إخفاء النافذة أو اللوجو لا يوقف التنزيل؛ يمكنك استعادة النافذة من منطقة الإشعارات.
- إذا لم يكن الحجم معروفًا، تظهر **…** إلى أن تتوفر بيانات لحساب النسبة.

## إضافات المتصفح

يجب تشغيل تطبيق سطح المكتب لكي يستقبل التنزيلات من الإضافة.

### Chrome وBrave وEdge

1. فك ضغط المصدر أو انسخ المستودع إلى جهازك.
2. افتح `chrome://extensions` أو `brave://extensions` أو `edge://extensions`.
3. فعّل **Developer mode** ثم اختر **Load unpacked**.
4. اختر مجلد [`extension`](extension)، ثم أعد تحميل صفحة الموقع.

عند تحديث الملفات اضغط **Reload** في بطاقة الإضافة ثم أعد تحميل الصفحة. أوقف النسخة القديمة لتجنب تشغيل إضافتين لنفس البرنامج.

### Firefox

1. افتح `about:debugging#/runtime/this-firefox`.
2. اختر **Load Temporary Add-on**.
3. اختر [`extension-firefox/manifest.json`](extension-firefox/manifest.json).

الإضافة المرفقة غير موقّعة، والتحميل بهذه الطريقة مؤقت ويحتاج إلى تكراره بعد إعادة تشغيل Firefox. متطلب إصدار Firefox في manifest هو **140 أو أحدث**. التوزيع الدائم يحتاج إلى حزمة موقّعة من Mozilla؛ ملف XPI غير الموقّع مخصص للتطوير.

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
| لا يوجد EXE بعد تنزيل ZIP | تأكد أنك نزّلت Setup ZIP؛ أرشيف الإضافات والمصدر لا يحتويان على المثبّت |

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
