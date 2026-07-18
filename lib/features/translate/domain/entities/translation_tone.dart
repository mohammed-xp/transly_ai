/// Desired tone of a translation. Part of the domain contract from the start so
/// the online (Gemini) source can honour it later without a signature change;
/// the offline (ML Kit) source ignores it. [formal] is the default (matches the
/// tone selector's initial selection).
enum TranslationTone { formal, casual, concise }
