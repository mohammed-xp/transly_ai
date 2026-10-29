import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../core/constants/app_icons.dart';
import '../../../../core/l10n/failure_message.dart';
import '../../../../core/l10n/language_label.dart';
import '../../../../core/l10n/localized_digits.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_icon_source.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/spinning_ring.dart';
import '../../../../core/widgets/toast/app_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/conversation_turn.dart';
import '../cubit/conversation_cubit.dart';
import '../cubit/conversation_state.dart';
import '../widgets/conversation_hero.dart';
import '../widgets/offline_banner.dart';
import '../widgets/read_aloud_row.dart';
import '../widgets/status_pill.dart';
import '../widgets/turn_bubble.dart';
import '../widgets/voice_wave.dart';

/// Voice tab of the home shell (design `Conversation v2`): two people take
/// turns speaking, each in their own language, detected automatically. Sits
/// between the shell's header and language bar and the input dock, where the
/// shell puts [ConversationCubit]'s mic.
///
/// No `Scaffold` — the shell's supplies the `Material` and background.
class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ConversationCubit>();
    _lifecycle = AppLifecycleListener(
      onResume: cubit.appResumed,
      onHide: cubit.pause,
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _showNotice(BuildContext context, ConversationState state) {
    final notice = state.notice;
    if (notice == null) return;
    final l10n = AppLocalizations.of(context)!;
    switch (notice) {
      case NoSpeechNotice():
        AppToast.show(
          context,
          message: l10n.conversationNoSpeech,
          type: AppToastType.neutral,
        );
      case UnsupportedLanguageNotice():
        AppToast.show(
          context,
          message: l10n.conversationUnsupportedLanguage(
            _localizedLanguages(context, state),
          ),
          type: AppToastType.neutral,
        );
      case OutOfTimeNotice():
        AppToast.show(
          context,
          message: l10n.conversationOutOfTime,
          type: AppToastType.error,
        );
      case TurnFailedNotice(:final failure):
        final retry = state.canRetry
            ? context.read<ConversationCubit>().retryLastTurn
            : null;
        AppToast.show(
          context,
          message: failureMessage(context, failure),
          type: AppToastType.error,
          actionLabel: retry == null ? null : l10n.commonRetry,
          onAction: retry,
        );
      case RecordingFailedNotice():
        AppToast.show(
          context,
          message: l10n.conversationRecordingFailed,
          type: AppToastType.error,
        );
      case ReadAloudFailedNotice(:final failure):
        AppToast.show(
          context,
          message: failureMessage(context, failure),
          type: AppToastType.neutral,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConversationCubit, ConversationState>(
      listenWhen: (previous, current) =>
          current.notice != null && previous.notice != current.notice,
      listener: _showNotice,
      child: const Column(
        children: [
          Expanded(child: _BodySection()),
          _StatusCaption(),
        ],
      ),
    );
  }
}

/// "English or العربية" — each language in its own script.
String _nativeLanguages(BuildContext context, ConversationState state) =>
    AppLocalizations.of(
      context,
    )!.conversationLanguagesOr(state.from.nativeName, state.to.nativeName);

/// "English or Arabic" — both in the UI language.
String _localizedLanguages(BuildContext context, ConversationState state) =>
    AppLocalizations.of(context)!.conversationLanguagesOr(
      languageLabel(context, state.from),
      languageLabel(context, state.to),
    );

/// The same gap under the language bar as on the Translate tab.
const double _topInset = AppDimens.spaceL - 2;

class _BodySection extends StatelessWidget {
  const _BodySection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationCubit, ConversationState>(
      buildWhen: (previous, current) =>
          previous.turns != current.turns ||
          previous.status != current.status ||
          previous.from != current.from ||
          previous.to != current.to ||
          previous.readAloud != current.readAloud ||
          previous.isOffline != current.isOffline,
      builder: (context, state) {
        if (state.status is ConversationMicDenied) {
          return _HeroBody(
            isOffline: state.isOffline,
            horizontalPadding: 28,
            hero: _MicDenied(languages: _localizedLanguages(context, state)),
          );
        }
        if (state.isEmpty) {
          return _HeroBody(
            isOffline: state.isOffline,
            horizontalPadding: AppDimens.space2XL,
            hero: _Empty(state: state),
          );
        }
        return _TurnList(state: state);
      },
    );
  }
}

/// Centres [hero] below the offline banner, when there is one, scrolling
/// both when they don't fit.
class _HeroBody extends StatelessWidget {
  const _HeroBody({
    required this.isOffline,
    required this.horizontalPadding,
    required this.hero,
  });

  final bool isOffline;
  final double horizontalPadding;
  final Widget hero;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (isOffline)
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppDimens.spaceL,
              _topInset,
              AppDimens.spaceL,
              0,
            ),
            sliver: SliverToBoxAdapter(child: OfflineBanner()),
          ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: hero,
            ),
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.state});

  final ConversationState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ConversationHero(
      icon: AppIcons.globe,
      title: l10n.conversationEmptyTitle,
      message: l10n.conversationEmptyBody(_localizedLanguages(context, state)),
      child: ReadAloudRow(
        value: state.readAloud,
        onChanged: context.read<ConversationCubit>().setReadAloud,
      ),
    );
  }
}

class _MicDenied extends StatelessWidget {
  const _MicDenied({required this.languages});

  final String languages;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ConversationHero(
      icon: AppIcons.micOff,
      title: l10n.conversationMicDeniedTitle,
      message: l10n.conversationMicDeniedBody(languages),
      child: GradientButton(
        label: l10n.conversationOpenSettings,
        onPressed: context.read<ConversationCubit>().openMicSettings,
      ),
    );
  }
}

/// The offline banner, when there is one, the turns so far, then what the
/// mic is doing now. Follows the newest item as the list grows.
class _TurnList extends StatefulWidget {
  const _TurnList({required this.state});

  final ConversationState state;

  @override
  State<_TurnList> createState() => _TurnListState();
}

class _TurnListState extends State<_TurnList> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void didUpdateWidget(covariant _TurnList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final itemsChanged =
        widget.state.turns.length != oldWidget.state.turns.length ||
        widget.state.status.runtimeType != oldWidget.state.status.runtimeType;
    if (itemsChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_controller.hasClients) return;
        _controller.animateTo(
          _controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _copy(BuildContext context, ConversationTurn turn) async {
    await Clipboard.setData(ClipboardData(text: turn.translation));
    if (!context.mounted) return;
    AppToast.show(
      context,
      message: AppLocalizations.of(context)!.translateCopied,
      icon: const SvgIconSource(AppIcons.copyToast),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.palette;
    final state = widget.state;
    final cubit = context.read<ConversationCubit>();
    final recording = state.status is ConversationRecording;

    final trailing = switch (state.status) {
      ConversationRecording() => StatusPill(
        leading: VoiceWave(height: 18, color: c.coral),
        label: l10n.conversationDetecting,
        caption: _nativeLanguages(context, state),
      ),
      ConversationTranslating() => StatusPill(
        leading: SpinningRing(
          size: 18,
          stroke: 2.4,
          trackColor: c.border,
          activeColor: c.coral,
          duration: const Duration(milliseconds: 900),
        ),
        label: l10n.conversationTranslating,
      ),
      ConversationIdle() || ConversationMicDenied() => null,
    };

    return ListView(
      controller: _controller,
      padding: const EdgeInsets.fromLTRB(
        AppDimens.spaceL,
        _topInset,
        AppDimens.spaceL,
        AppDimens.spaceS,
      ),
      children: [
        if (state.isOffline) ...[
          const OfflineBanner(),
          const SizedBox(height: AppDimens.spaceM),
        ],
        for (final (index, turn) in state.turns.indexed) ...[
          if (index > 0) const SizedBox(height: 6),
          TurnBubble(
            turn: turn,
            isEndSide: turn.language == state.to,
            onSpeak: recording ? null : () => cubit.speakTurn(turn),
            onCopy: () => _copy(context, turn),
          ),
        ],
        if (trailing != null) ...[
          if (state.turns.isNotEmpty) const SizedBox(height: 6),
          trailing,
        ],
      ],
    );
  }
}

/// One line above the dock saying what the mic is doing.
class _StatusCaption extends StatelessWidget {
  const _StatusCaption();

  String _text(BuildContext context, ConversationState state) {
    final l10n = AppLocalizations.of(context)!;
    final resetsAt = state.quotaResetsAt;
    return switch (state.status) {
      ConversationMicDenied() => l10n.conversationStatusMicOff,
      _ when state.isOffline => l10n.conversationStatusOffline,
      _ when state.isOutOfTime && resetsAt != null =>
        l10n.conversationStatusOutOfTime(
          localizedDigitsIn(
            context,
            DateFormat('HH:mm').format(resetsAt.toLocal()),
          ),
        ),
      _ when state.isOutOfTime => l10n.conversationOutOfTime,
      ConversationRecording() => l10n.conversationStatusListening(
        _nativeLanguages(context, state),
      ),
      ConversationTranslating() => l10n.conversationTranslating,
      ConversationIdle() => l10n.conversationStatusIdle,
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return BlocBuilder<ConversationCubit, ConversationState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isOffline != current.isOffline ||
          previous.isOutOfTime != current.isOutOfTime ||
          previous.quotaResetsAt != current.quotaResetsAt ||
          previous.from != current.from ||
          previous.to != current.to,
      builder: (context, state) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.spaceL,
          6,
          AppDimens.spaceL,
          0,
        ),
        child: SizedBox(
          height: AppDimens.spaceXL,
          child: Center(
            child: Text(
              _text(context, state),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
                color: c.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
