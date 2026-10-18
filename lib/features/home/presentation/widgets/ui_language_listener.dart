import 'package:flutter/widgets.dart';

/// Calls [onChanged] whenever the language the UI is shown in changes —
/// whether picked in the app or followed from the device — but not on the
/// first build.
class UiLanguageListener extends StatefulWidget {
  const UiLanguageListener({
    super.key,
    required this.onChanged,
    required this.child,
  });

  final VoidCallback onChanged;
  final Widget child;

  @override
  State<UiLanguageListener> createState() => _UiLanguageListenerState();
}

class _UiLanguageListenerState extends State<UiLanguageListener> {
  String? _languageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = Localizations.localeOf(context).languageCode;
    final previous = _languageCode;
    _languageCode = code;
    if (previous != null && previous != code) widget.onChanged();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
