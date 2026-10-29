<div align="center">

<img src="../crates/app/ui/kero-logo.png" alt="KeRo Smarter Download" width="128">

# KeRo Smarter Download

[العربية](../README.md) · [English](README.en.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md)  
[Русский](README.ru.md) · [Türkçe](README.tr.md) · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · **हिन्दी**

**Rust** और **Slint** से बना Windows डाउनलोड मैनेजर, जिसमें ब्राउज़र एक्सटेंशन और डाउनलोड की प्रगति दिखाने वाली फ़्लोटिंग विंडो शामिल है।

[![Release](https://img.shields.io/badge/release-v1.1.3-0EA5A4?style=flat-square)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.3)

</div>

## डाउनलोड — v1.1.3

**इस्तेमाल पूरी तरह मुफ़्त है।** अपने Windows संस्करण और सिस्टम आर्किटेक्चर के अनुसार इंस्टॉलर चुनें।

| सिस्टम | आर्किटेक्चर | डाउनलोड | स्थिति |
|---|---|---|---|
| Windows 10 / Windows 11 | 64-bit · x64 | [EXE डाउनलोड करें](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-Setup.exe) | उपलब्ध |
| Windows 10 / Windows 11 | 32-bit · x86 | [EXE डाउनलोड करें](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win10_11-x86.exe) | उपलब्ध |
| Windows 7 SP1 | 64-bit · x64 | [EXE डाउनलोड करें](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win7-Experimental-x64.exe) | प्रयोगात्मक |
| Windows 7 SP1 | 32-bit · x86 | [EXE डाउनलोड करें](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win7-Experimental-x86.exe) | प्रयोगात्मक |

32-बिट Windows 10 के लिए x86 चुनें। 64-बिट Windows 10 या Windows 11 के लिए x64 की सलाह दी जाती है; x86 ऐप भी उपलब्ध है। Windows 7 SP1 के लिए अपने सिस्टम के अनुसार प्रयोगात्मक संस्करण चुनें। जाँचने के लिए **Control Panel → System → System type** खोलें।

> **Windows 7 के संस्करण प्रयोगात्मक हैं।** Windows Server 2022 पर बिल्ड, डाउनलोड इंजन के परीक्षण, सहायक टूल और निर्भरता की जाँच सफल रही। वास्तविक Windows 7 डिवाइस पर इंस्टॉलेशन, इंटरफ़ेस और ब्राउज़र इंटीग्रेशन का परीक्षण अभी नहीं हुआ है। [अनुकूलता की जानकारी (अंग्रेज़ी)](WINDOWS-BUILDS.md).

## मुख्य सुविधाएँ

- सर्वर के समर्थन के अनुसार अधिकतम 32 कनेक्शन से डाउनलोड।
- रोकना, फिर से शुरू करना, कतारें, समय निर्धारित करना और गति सीमा।
- शामिल सहायक टूल से मीडिया की गुणवत्ता और फ़ॉर्मैट चुनना, प्लेलिस्ट डाउनलोड करना और ऑडियो बदलना।
- Chromium और Firefox एक्सटेंशन, खिसकाई जा सकने वाली फ़्लोटिंग विंडो और बहुभाषी इंटरफ़ेस।

डाउनलोड की गति, दोबारा शुरू करने की सुविधा और उपलब्ध फ़ॉर्मैट सर्वर, कनेक्शन तथा सामग्री तक पहुँच की अनुमति पर निर्भर हैं।

## इंस्टॉलेशन और ब्राउज़र एक्सटेंशन

1. अपने सिस्टम के लिए सही EXE इंस्टॉलर डाउनलोड करके चलाएँ।
2. ऐप खोलें और डाउनलोड लिंक जोड़ें। एक्सटेंशन से डाउनलोड लेने के लिए ऐप का चालू रहना ज़रूरी है।
3. Chrome, Brave या Edge में: एक्सटेंशन पेज पर **Developer mode** चालू करें, **Load unpacked** चुनें और इंस्टॉलेशन फ़ोल्डर के अंदर `extension` फ़ोल्डर चुनें।
4. Firefox में: `about:debugging#/runtime/this-firefox` खोलें, **Load Temporary Add-on** चुनें और इंस्टॉलेशन फ़ोल्डर के अंदर `extension-firefox/manifest.json` चुनें।

इंस्टॉलर में सहायक टूल और दोनों एक्सटेंशन फ़ोल्डर शामिल हैं। चुने हुए पैकेज के साथ मिले फ़ोल्डर ही इस्तेमाल करें। Win7 पैकेज का Firefox मैनिफ़ेस्ट **Firefox 115 ESR** के लिए अनुकूलित है; आधुनिक Windows पैकेज के लिए Firefox 140 या नया संस्करण चाहिए। Firefox एक्सटेंशन हस्ताक्षरित नहीं है और अस्थायी रूप से लोड होता है। ब्राउज़र फिर से शुरू करने पर इसे दोबारा लोड करना होगा।

## दस्तावेज़ और ऐप की भाषाएँ

दस्तावेज़ **12 भाषाओं** में उपलब्ध हैं। ऐप इंटरफ़ेस **8 भाषाओं** का समर्थन करता है: अरबी, अंग्रेज़ी, फ़्रेंच, स्पैनिश, जर्मन, पुर्तगाली, तुर्की और रूसी। इस हिंदी पेज का मतलब यह नहीं है कि ऐप इंटरफ़ेस में हिंदी भी उपलब्ध है।

## सोर्स कोड, गोपनीयता और सहायता

पूरा सोर्स कोड पाने के लिए **Code → Download ZIP** इस्तेमाल करें। Windows पर `BUILD.bat` बिल्ड की तैयारी करता है; डेवलपमेंट टूल इंस्टॉल करने के लिए एडमिन की अनुमति लग सकती है।

एक्सटेंशन ऐप से स्थानीय कनेक्शन पर बात करता है और डाउनलोड के लिए ज़रूरी कुकीज़ तथा पेज की जानकारी भेज सकता है। कुकीज़, संवेदनशील सेटिंग या निजी लिंक साझा न करें। केवल वही सामग्री डाउनलोड करें जिसे देखने और सहेजने की आपको अनुमति है।

[रिलीज़ की सभी फ़ाइलें](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.3) · [तकनीकी गाइड और लाइसेंस की स्थिति (अंग्रेज़ी)](README.en.md) · [समस्या बताएँ](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/issues)

डेवलपर: **KeRo HaZem**।
