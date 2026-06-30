# Gold-Standard Example

This is the reference post **written and approved by the user**. Match this voice exactly: conversational developer Arabic, technical terms in English inline, hook with a twist, numbered problem breakdown, concrete fix, short result lines, and a closing question asking for genuinely better approaches.

The output is ONE block the user pastes into LinkedIn as-is: Arabic → dash separator → English → hashtags. Exactly one blank line between paragraphs. No version labels.

## Input (summary of the diff)

Signup screen freezing on "Create Account". Old code read 3 identity images with `readAsBytesSync()` and Base64-encoded them synchronously on the main thread, inside the Cubit. Fix: moved encoding to the data layer, added a helper that compresses (resize 1080px, JPEG 70) and encodes inside `compute()`. Cubit now passes `File` objects only.

## Output (verbatim — this whole block is the deliverable)

السلام عليكم — كان عندي مشكلة في شاشة انشاء حساب كانت بتتجمّد لثوانٍ، والسبب لم يكن الشبكة.

في أحد التطبيقات، يرفع السائق 3 صور عند انشاء الحساب: بطاقة الهوية، الرخصة، والاستمارة. الكود كان بيقرأ كل صورة بـ readAsBytesSync() ويحوله لـ base64 — بشكل تزامني، على الـ main thread، داخل الـ Cubit مباشرةً.

المشكلة على مستويين:

1. أداء: الـ UI thread يتجمّد كلياً أثناء قراءة الصور وترميزها

2. معمارية: الـ presentation layer لا شأن لها بصيغ الـ API

الحل: نقل منطق الترميز إلى data layer، وعملت helper كلاس بيضغط الصور على isolate منفصل عبر compute(). الصور تُعاد تحجيمها إلى 1080px وتُضغط بجودة JPEG 70 قبل الإرسال.

الـ Cubit الآن يمرّر File فقط.

الـ UI لم يعد يتجمّد، وحجم الصور قلّ قبل الوصول إلى الـ API.

وريني رايك هل في طرق افضل تحسن من جودة العملية اكتر من كدا؟

------------------------------------------

The signup screen was freezing for several seconds — and the cause wasn't the network.

In one of the apps, drivers upload 3 images at signup: ID card, license, and registration form. The code was reading each one with readAsBytesSync() and converting it to base64 — synchronously, on the main thread, directly inside the Cubit.

The problem on two levels:

1. Performance: the UI thread freezes completely while reading and encoding the images

2. Architecture: the presentation layer has no business knowing API formats

The fix: moved the encoding logic to the data layer, and built a helper class that compresses images on a separate isolate via compute(). Images are resized to 1080px and compressed at JPEG quality 70 before sending.

The Cubit now passes File objects only.

The UI no longer freezes, and payloads got smaller before reaching the API.

Is there a better way to push this further? I'd genuinely like to hear it.

#Flutter #CleanArchitecture #Dart #MobileDevelopment #Performance

## What to replicate from this example

- السلام عليكم merged into a hook that ends with a twist ("والسبب لم يكن الشبكة")
- Conversational Arabic verbs ("كان بيقرأ", "عملت") — not formal MSA
- Technical terms stay in English inline, never translated
- Exactly one blank line between every paragraph and every numbered item
- No "Arabic version" / "English version" labels — just the dash separator line
- Hashtags appear once, at the very end after the English text
- Closing question asks for genuinely better approaches — not generic engagement bait