import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../domain/entities/language.dart';
import '../cubit/translate_cubit.dart';
import '../cubit/translate_state.dart';
import '../utils/translate_l10n.dart';
import '../widgets/input_dock.dart';
import '../widgets/language_bar.dart';
import '../widgets/translate_header.dart';

/// Persistent chrome around the translate feature's three input modes
/// (design `02 · Translate`). Owns the single [TranslateCubit] instance so it
/// survives switching between Keyboard/Voice/Camera, and renders the header,
/// language bar and input dock — the only part of the screen that changes
/// per mode is [child], supplied by the router's `StatefulShellRoute`.
///
/// Router-agnostic on purpose: it takes [currentMode]/[onModeSelected]/[child]
/// rather than a go_router type, so it stays testable and reusable.
class TranslateShell extends StatelessWidget {
  const TranslateShell({
    super.key,
    required this.currentMode,
    required this.onModeSelected,
    required this.child,
  });

  final TranslateInputMode currentMode;
  final ValueChanged<TranslateInputMode> onModeSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Read above the Scaffold: with the default `resizeToAvoidBottomInset:
    // true`, the Scaffold consumes `viewInsets.bottom` for its own body, so
    // any descendant of that body always sees it as zero.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return BlocProvider(
      create: (_) => sl<TranslateCubit>(),
      child: PopScope(
        canPop: currentMode == TranslateInputMode.keyboard,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) onModeSelected(TranslateInputMode.keyboard);
        },
        child: Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                TranslateHeader(
                  onSignOut: () => context.read<SessionCubit>().signOut(),
                ),
                const _LanguageBarSection(),
                Expanded(
                  // The dock normally supplies the gap below the content; while
                  // the keyboard is open it takes the dock's place instead, so
                  // this makes up that gap. Applied here rather than inside each
                  // branch because a branch's own `MediaQuery.viewInsetsOf` read
                  // would see zero — the `Scaffold` below already consumed the
                  // real inset for its body.
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: keyboardOpen ? AppDimens.spaceL : 0,
                    ),
                    child: child,
                  ),
                ),
                // While the keyboard is open it takes the dock's place at the
                // bottom; the dock reappears when the keyboard closes.
                if (!keyboardOpen)
                  _DockSlot(
                    currentMode: currentMode,
                    onModeSelected: onModeSelected,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Selects only the language pair — rebuilds on swap, not on every keystroke.
class _LanguageBarSection extends StatelessWidget {
  const _LanguageBarSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      TranslateCubit,
      TranslateState,
      (Language, Language, bool)
    >(
      selector: (state) => (state.from, state.to, state.isBusy),
      builder: (context, data) {
        return LanguageBar(
          fromLanguage: languageLabel(context, data.$1),
          toLanguage: languageLabel(context, data.$2),
          onSwap: context.read<TranslateCubit>().swapLanguages,
          isBusy: data.$3,
        );
      },
    );
  }
}

/// Wraps [InputDock] to drop focus before switching modes. The previous
/// mode's text field (e.g. the source card) can stay mounted offstage and
/// keep focus, which would silently re-raise the keyboard after switching
/// tabs — without this, tapping Voice while the keyboard is up would leave it
/// open behind the (now hidden) dock.
class _DockSlot extends StatelessWidget {
  const _DockSlot({required this.currentMode, required this.onModeSelected});

  final TranslateInputMode currentMode;
  final ValueChanged<TranslateInputMode> onModeSelected;

  @override
  Widget build(BuildContext context) {
    return InputDock(
      currentMode: currentMode,
      onModeSelected: (mode) {
        FocusManager.instance.primaryFocus?.unfocus();
        onModeSelected(mode);
      },
    );
  }
}
