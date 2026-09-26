import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/l10n/language_label.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/toast/app_toast_scope.dart';
import '../../../camera_scan/presentation/screens/camera_scan_screen.dart';
import '../../../conversation/presentation/screens/conversation_screen.dart';
import '../../../translate/presentation/cubit/translate_cubit.dart';
import '../../../translate/presentation/cubit/translate_state.dart';
import '../../../translate/presentation/screens/translate_screen.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/input_dock.dart';
import '../widgets/language_bar.dart';
import '../widgets/translate_header.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<HomeCubit>()),
        BlocProvider(create: (_) => serviceLocator<TranslateCubit>()),
      ],
      child: BlocListener<HomeCubit, HomeState>(
        listenWhen: (previous, current) =>
            previous.from != current.from || previous.to != current.to,
        listener: (context, state) => context
            .read<TranslateCubit>()
            .languagesChanged(from: state.from, to: state.to),
        child: const _HomeView(),
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

  void _selectMode(TranslateInputMode mode) {
    if (mode == _mode) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _mode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return PopScope(
      canPop: _mode == TranslateInputMode.keyboard,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _selectMode(TranslateInputMode.keyboard);
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _HeaderSection(),
              const _LanguageBarSection(),
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
                InputDock(currentMode: _mode, onModeSelected: _selectMode),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeCubit, HomeState, String?>(
      selector: (state) => state.user?.username,
      builder: (context, userName) => TranslateHeader(
        userName: userName,
        onProfileTap: () => context.pushNamed(AppRoutes.profileName),
      ),
    );
  }
}

class _LanguageBarSection extends StatelessWidget {
  const _LanguageBarSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeCubit, HomeState, (LanguageEntity, LanguageEntity)>(
      selector: (state) => (state.from, state.to),
      builder: (context, languages) {
        final (from, to) = languages;
        return BlocSelector<TranslateCubit, TranslateState, bool>(
          selector: (state) => state.isBusy,
          builder: (context, isBusy) => LanguageBar(
            fromLanguage: languageLabel(context, from),
            toLanguage: languageLabel(context, to),
            onSwap: context.read<HomeCubit>().swapLanguages,
            isBusy: isBusy,
          ),
        );
      },
    );
  }
}
