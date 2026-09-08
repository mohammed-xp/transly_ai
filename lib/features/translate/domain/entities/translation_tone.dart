/// Desired tone of a translation. The online (backend API) source honours it;
/// the offline (ML Kit) source ignores it. [formal] is the default (matches
/// the tone selector's initial selection).
enum TranslationTone { formal, casual, concise }
