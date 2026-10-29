import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/domain/entities/language_side.dart';
import '../../../../core/l10n/language_label.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/toast/app_toast_scope.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../app_update/presentation/widgets/optional_update_prompter.dart';
import '../../../camera_scan/presentation/screens/camera_scan_screen.dart';
import '../../../conversation/presentation/cubit/conversation_cubit.dart';
import '../../../conversation/presentation/screens/conversation_screen.dart';
import '../../../conversation/presentation/widgets/voice_dock_tab.dart';
import '../../../language_picker/presentation/widgets/language_picker_sheet.dart';
import '../../../translate/presentation/cubit/translate_cubit.dart';
import '../../../translate/presentation/screens/translate_screen.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/input_dock.dart';
import '../widgets/language_bar.dart';
import '../widgets/translate_header.dart';
import '../widgets/ui_language_listener.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<HomeCubit>()..refreshPlan()),
        BlocProvider(
          create: (context) {
            final home = context.read<HomeCubit>().state;
            return serviceLocator<TranslateCubit>()
              ..languagesChanged(from: home.from, to: home.to);
          },
        ),
        BlocProvider(
          create: (context) {
            final home = context.read<HomeCubit>().state;
            return serviceLocator<ConversationCubit>()
              ..languagesChanged(from: home.from, to: home.to);
          },
        ),
      ],
      child: BlocListener<HomeCubit, HomeState>(
        listenWhen: _pairChanged,
        listener: (context, state) {
          context.read<ConversationCubit>().languagesChanged(
            from: state.from,
            to: state.to,
          );
        },
        child: Builder(
          builder: (context) => UiLanguageListener(
            onChanged: context.read<TranslateCubit>().uiLanguageChanged,
            child: const OptionalUpdatePrompter(child: _HomeView()),
          ),
        ),
      ),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  TranslateInputMode _mode = TranslateInputMode.keyboard;

  // Built once (the header once per tab), so the keyboard's inset changing
  // every frame of its animation doesn't rebuild them.
  late Widget _header = _buildHeader();
  late final Widget _languageBar = _LanguageBarSection(
    onCover: _pauseConversation,
  );

  Widget _buildHeader() =>
      _HeaderSection(mode: _mode, onCover: _pauseConversation);

  void _selectMode(TranslateInputMode mode) {
    if (mode == _mode) return;
    FocusManager.instance.primaryFocus?.unfocus();
    _pauseConversation();
    if (mode == TranslateInputMode.voice) {
      unawaited(context.read<ConversationCubit>().refreshQuota());
    }
    if (mode == TranslateInputMode.keyboard) _applyPairToTranslate();
    setState(() {
      _mode = mode;
      _header = _buildHeader();
    });
  }

  /// Stops the mic and speech when the Voice tab is left or covered, so they
  /// don't carry on out of sight.
  void _pauseConversation() {
    if (_mode != TranslateInputMode.voice) return;
    unawaited(context.read<ConversationCubit>().pause());
  }

  /// The Translate tab takes a new pair only while it shows: translating out
  /// of sight would spend quota and toast its errors over another tab.
  void _applyPairToTranslate() {
    final home = context.read<HomeCubit>().state;
    context.read<TranslateCubit>().languagesChanged(
      from: home.from,
      to: home.to,
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final isVoice = _mode == TranslateInputMode.voice;

    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) =>
          _mode == TranslateInputMode.keyboard &&
          _pairChanged(previous, current),
      listener: (context, _) => _applyPairToTranslate(),
      child: PopScope(
        canPop: _mode == TranslateInputMode.keyboard,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _selectMode(TranslateInputMode.keyboard);
        },
        child: Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _header,
                _languageBar,
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: keyboardOpen ? AppDimens.spaceL : 0,
                    ),
                    child: AppToastScope(
                      bottomSpacing: AppDimens.spaceM,
                      avoidSystemInsets: false,
                      child: IndexedStack(
                        index: _mode.index,
                        children: const [
                          TranslateScreen(),
                          ConversationScreen(),
                          CameraScanScreen(),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!keyboardOpen)
                  InputDock(
                    currentMode: _mode,
                    onModeSelected: _selectMode,
                    voiceTab: isVoice ? const VoiceDockTab() : null,
                    voiceTabRaise: VoiceDockTab.raise,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

bool _pairChanged(HomeState previous, HomeState current) =>
    previous.from != current.from || previous.to != current.to;

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.mode, required this.onCover});

  /// The open tab, named above the wordmark.
  final TranslateInputMode mode;

  /// Called right before the profile covers the shell.
  final VoidCallback onCover;

  @override
  Widget build(BuildContext context) {
    final kicker = mode.label(AppLocalizations.of(context)!);
    return BlocSelector<HomeCubit, HomeState, (String?, bool)>(
      selector: (state) => (state.user?.username, state.isPro),
      builder: (context, header) {
        final (userName, isPro) = header;
        return TranslateHeader(
          kicker: kicker,
          userName: userName,
          isPro: isPro,
          onProfileTap: () {
            onCover();
            context.pushNamed(AppRoutes.profileName);
          },
        );
      },
    );
  }
}

class _LanguageBarSection extends StatelessWidget {
  const _LanguageBarSection({required this.onCover});

  /// Called right before a language picker covers the shell.
  final VoidCallback onCover;

  Future<void> _openPicker(BuildContext context, LanguageSide side) async {
    // A second tap that lands together with the first must not stack another
    // sheet: closing the lower one would put its stale pair back.
    if (ModalRoute.of(context)?.isCurrent == false) return;
    onCover();
    final homeCubit = context.read<HomeCubit>();
    final pair = await showLanguagePickerSheet(
      context,
      initialSide: side,
      initialPair: (from: homeCubit.state.from, to: homeCubit.state.to),
    );
    if (!homeCubit.isClosed) homeCubit.setLanguages(pair);
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeCubit, HomeState, (LanguageEntity, LanguageEntity)>(
      selector: (state) => (state.from, state.to),
      builder: (context, languages) {
        final (from, to) = languages;
        return LanguageBar(
          fromLanguage: languageLabel(context, from),
          toLanguage: languageLabel(context, to),
          onSwap: context.read<HomeCubit>().swapLanguages,
          onFromTap: () => _openPicker(context, LanguageSide.source),
          onToTap: () => _openPicker(context, LanguageSide.target),
        );
      },
    );
  }
}
