import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/coming_soon_panel.dart';
import '../../../../l10n/app_localizations.dart';

/// Voice-input tab of the home shell (design `Conversation`). Renders
/// only the middle content — the header, language bar and input dock are
/// owned by `HomeShell` and stay on screen across all three modes.
///
/// Placeholder until conversation mode (mic capture + chat bubbles) is built;
/// no `Scaffold` — the shell's `Scaffold` already supplies the `Material`
/// ancestor and background.
class ConversationScreen extends StatelessWidget {
  const ConversationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spaceL),
        child: ComingSoonPanel(
          icon: Icons.mic_none_rounded,
          title: l10n.conversationComingSoonTitle,
          message: l10n.conversationComingSoonBody,
        ),
      ),
    );
  }
}
