# إضافات المتصفح · Browser extensions

**إصدار الإضافة: 1.1.4**. يمكن استخدام الحزم المحدثة مع برنامج KeRo Smarter Download 1.1.3 أو 1.1.4 المثبّت بالفعل. الإضافة لا تحتاج نسخة مختلفة حسب x86 أو x64؛ اختر الحزمة وفق المتصفح.

## المتصفحات المستهدفة على Windows

| المتصفح | الحزمة | صفحة تركيب الإضافة |
|---|---|---|
| Google Chrome | Chromium | `chrome://extensions` |
| Brave | Chromium | `brave://extensions` |
| Microsoft Edge | Chromium | `edge://extensions` |
| Opera وOpera GX | Chromium | `opera://extensions` |
| Vivaldi | Chromium | `vivaldi://extensions` |
| Mozilla Firefox 140 أو أحدث | Firefox | `about:debugging#/runtime/this-firefox` |
| Firefox 115 ESR على Windows 7 | Firefox-Win7، تجريبي | `about:debugging#/runtime/this-firefox` |
| Safari على macOS / iOS | غير متاح حاليًا | يحتاج حزمة Safari وتكاملًا مع تطبيق سطح مكتب مناسب لنظام Apple |
| متصفحات الهاتف | غير مدعومة بهذه الحزم | الحزم تستهدف متصفحات سطح المكتب مع تطبيق Windows المحلي |

المتصفحات المبنية على Chromium تستخدم الحزمة نفسها. اختبارات المحاكاة تتحقق من مسار Chromium ومسار Firefox؛ لم تُنفَّذ تجربة حية لكل متصفح مدرج أو لكل موقع. اختيار المتصفح ضمن هذه القائمة ليس ضمانًا لتوافق كل إصدار قديم منه. توافق Windows 7 والتقاط الوسائط فيه يحتاجان إلى اختبار فعلي.

## التركيب والتحديث

1. نزّل حزمة متصفحك وفكها في مجلد ثابت.
2. في Chrome أو Brave أو Edge أو Opera أو Vivaldi، فعّل **Developer mode** ثم **Load unpacked** وحدد مجلد `extension`.
3. في Firefox، افتح صفحة التصحيح أعلاه، ثم **Load Temporary Add-on** واختر `manifest.json` من مجلد `extension-firefox`.
4. إن كانت الإضافة محمّلة من مجلد قديم، حمّل النسخة الجديدة من مجلدها وحدّث المسار؛ اضغط Reload إذا استبدلت الملفات في المجلد نفسه. أوقف أي نسخة قديمة مكررة.
5. شغّل برنامج KeRo على الجهاز نفسه ثم حدّث صفحات المواقع المفتوحة مرة واحدة بـ**Ctrl+R**. الكود القديم المحمّل قبل التحديث لا يتغير داخل التبويب تلقائيًا.

إضافة Firefox غير موقّعة وتحميلها مؤقت؛ يجب إعادة تحميلها بعد إعادة تشغيل Firefox. حزمة Firefox الحديثة تتطلب إصدار 140 أو أحدث. حزمة Firefox-Win7 تضبط manifest لإصدار 115 ESR وتحذف حقولًا أحدث غير مدعومة فيه، مع بقاء الاختبار الفعلي مطلوبًا.

## إصلاح Extension context invalidated

- فحص صلاحية سياق الإضافة قبل اعتراض النقر على روابط الملفات أو روابط magnet.
- معالجة أخطاء الإرسال المتزامنة ورفض Promise و`runtime.lastError` عبر مسار واحد.
- إرجاع التنزيل إلى المتصفح مرة واحدة إذا فشل الإرسال بعد اعتراض النقرة.
- إيقاف المراقبات والمؤقتات وإزالة الأزرار والمعالجات القديمة عند انتهاء السياق.
- إلغاء طلب تصدير Blob الجاري عند إنهاء السياق.
- عدم إعادة تحميل الإضافة لمجرد أن البرنامج يعرض رقم إصدار أقدم منها.

لا تعيد هذه المعالجة إحياء سياق قديم انتهى؛ تحديث الصفحة يشغّل النسخة الجديدة من الإضافة. فشل مؤقت في استقبال الرسالة لا يُعامل تلقائيًا كتحديث أو حذف للإضافة.

## Safari وحدود الأنظمة

Safari يحتاج حزمة Safari Web Extension تُجهَّز عبر Xcode على Mac أو خدمة التغليف في App Store Connect، مع مراجعة واجهات WebExtensions المختلفة. تطبيق KeRo الحالي مخصص لـWindows ويتصل محليًا؛ لم يُبنَ تطبيق macOS أو iOS أو تكامل Safari في هذا التحديث.

## الاختبارات والنشر

تشغّل [.github/workflows/extension-packages.yml](../.github/workflows/extension-packages.yml) اختبارات الإضافة وتجهّز ثلاث حزم مستقلة وبصمات SHA-256، ثم تضيفها إلى إصدار البرنامج الحالي. لا تعيد بناء مثبّتات Windows أو تستبدلها. بعد اختيار هذه الحزم، تحديث الإضافة يدوي؛ لا توجد دعوى بأنها منشورة في متاجر المتصفحات أو موقّعة من Mozilla.

The Chromium package targets desktop Chrome, Brave, Edge, Opera / Opera GX and Vivaldi on Windows. Separate Firefox 140+ and experimental Firefox 115 ESR packages are provided. API simulations cover message failures, click fallback, lifecycle cleanup, media capture and Chromium/Firefox API styles. Live testing on every browser and Windows 7 remains outstanding. Safari, mobile browsers and a macOS desktop client are not included.

## مراجع المتصفحات · Browser references

- Chrome: https://developer.chrome.com/docs/extensions/get-started/tutorial/debug
- Opera: https://help.opera.com/en/extensions/testing/
- Vivaldi: https://help.vivaldi.com/desktop/appearance-customization/extensions/
- Safari packaging: https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari

## ترقيم الإصدارات المتزامن

رقم حزم الإضافة الجديدة يطابق إصدار البرنامج في Cargo.toml. بعد تعديل رقم البرنامج شغّل `python tools/sync-extension-version.py` لتحديث ملفات manifest الثلاثة معًا. يتحقق التغليف وCI من التطابق ويرفضان نشر حزم مختلفة الرقم.

حزم الإضافة المستقلة 1.1.4 تحدّث الترقيم، وتحتفظ بنفس سلوك الإضافة 1.1.1 وتوافقها. مثبّتات البرنامج v1.1.4 المنشورة سابقًا تتضمن الإضافة 1.1.1 ولم يُعد بناؤها؛ حدّث مجلد الإضافة من الحزمة المستقلة ثم أعد تحميلها والمتصفحات المفتوحة. الإضافة 1.1.4 لا تحاول الرجوع للرقم الأقدم الذي يعلنه البرنامج المثبّت. توقيع Mozilla وإصدار المتجر منفصلان عن تغيير الرقم في manifest.
