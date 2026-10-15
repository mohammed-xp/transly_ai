import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/domain/entities/language_side.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/l10n/failure_message.dart';
import '../../../../core/l10n/language_badge.dart';
import '../../../../core/l10n/localized_digits.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/language_leading_tile.dart';
import '../../../../core/widgets/language_option_tile.dart';
import '../../../../core/widgets/selection_mark.dart';
import '../../../../core/widgets/sheet_close_button.dart';
import '../../../../core/widgets/sheet_drag_handle.dart';
import '../../../../core/widgets/spinning_ring.dart';
import '../../../../core/widgets/toast/app_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/language_pair.dart';
import '../../domain/entities/offline_model_status.dart';
import '../cubit/language_picker_cubit.dart';
import '../cubit/language_picker_state.dart';
import '../utils/language_picker_l10n.dart';
import 'language_search_field.dart';
import 'language_side_toggle.dart';
import 'language_swap_pill.dart';
import 'offline_model_button.dart';
import 'recent_language_chips.dart';
import 'remove_offline_model_dialog.dart';

/// Shows [LanguagePickerSheet] (design `02c · Language Picker`) opened on
/// [initialSide], and returns the pair picked in it once it closes, however
/// it was closed. Applying the pair only then means one translation per
/// visit, not one per tap.
Future<LanguagePair> showLanguagePickerSheet(
  BuildContext context, {
  required LanguageSide initialSide,
  required LanguagePair initialPair,
}) async {
  final cubit = serviceLocator<LanguagePickerCubit>(param1: initialPair)
    ..load();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.palette.surface,
      barrierColor: isDark
          ? Colors.black.withValues(alpha: 0.6)
          : AppColors.backgroundDark.withValues(alpha: 0.45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(LanguagePickerSheet.topRadius),
        ),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: LanguagePickerSheet(initialSide: initialSide),
      ),
    );
    return cubit.state.pair;
  } finally {
    await cubit.close();
  }
}

class LanguagePickerSheet extends StatefulWidget {
  const LanguagePickerSheet({super.key, required this.initialSide});

  static const double topRadius = 28;
  static const double _heightFactor = 0.9;

  final LanguageSide initialSide;

  @override
  State<LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<LanguagePickerSheet> {
  late LanguageSide _side = widget.initialSide;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectSide(LanguageSide side) {
    if (side == _side) return;
    setState(() => _side = side);
  }

  void _pick(LanguageEntity language) =>
      context.read<LanguagePickerCubit>().pick(_side, language);

  void _showModelError(BuildContext context, LanguagePickerState state) {
    final error = state.modelError;
    if (error == null) return;
    AppToast.show(
      context,
      message: failureMessage(context, error.failure),
      type: AppToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LanguagePickerCubit, LanguagePickerState>(
      listenWhen: (previous, current) =>
          previous.modelError != current.modelError,
      listener: _showModelError,
      child: FractionallySizedBox(
        heightFactor: LanguagePickerSheet._heightFactor,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: SheetDragHandle()),
                    const SizedBox(height: AppDimens.spaceL),
                    const _Header(),
                    const SizedBox(height: 14),
                    BlocSelector<
                      LanguagePickerCubit,
                      LanguagePickerState,
                      LanguagePair
                    >(
                      selector: (state) => state.pair,
                      builder: (context, pair) => LanguageSideToggle(
                        side: _side,
                        from: pair.from,
                        to: pair.to,
                        onChanged: _selectSide,
                      ),
                    ),
                    const SizedBox(height: AppDimens.spaceM),
                    LanguageSearchField(
                      controller: _searchController,
                      onChanged: context
                          .read<LanguagePickerCubit>()
                          .queryChanged,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _Body(side: _side, onPick: _pick),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceXS),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.languagePickerTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: context.palette.ink,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.spaceM),
          const SheetCloseButton(),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.side, required this.onPick});

  final LanguageSide side;
  final ValueChanged<LanguageEntity> onPick;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguagePickerCubit, LanguagePickerState>(
      // Each row's offline control selects its own status.
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.pair != current.pair ||
          previous.recents != current.recents,
      builder: (context, state) => switch (state.status) {
        LanguagesLoading() => const _Loading(),
        LanguagesFailed(:final failure) => _LoadFailed(failure: failure),
        LanguagesLoaded(:final visibleLanguages) => _LanguageList(
          state: state,
          languages: visibleLanguages,
          side: side,
          onPick: onPick,
        ),
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return Center(
      child: SpinningRing(
        size: 28,
        stroke: 3,
        trackColor: c.border,
        activeColor: c.coral,
        duration: const Duration(milliseconds: 900),
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.space2XL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              failureMessage(context, failure),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimens.spaceS),
            TextButton(
              onPressed: context.read<LanguagePickerCubit>().load,
              child: Text(AppLocalizations.of(context)!.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageList extends StatelessWidget {
  const _LanguageList({
    required this.state,
    required this.languages,
    required this.side,
    required this.onPick,
  });

  final LanguagePickerState state;
  final List<LanguageEntity> languages;
  final LanguageSide side;
  final ValueChanged<LanguageEntity> onPick;

  static const double _fadeHeight = 90;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.palette;

    if (languages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.space2XL),
          child: Text(
            l10n.languagePickerNoResults,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 15, color: c.textMuted),
          ),
        ),
      );
    }

    final isSource = side == LanguageSide.source;
    final active = isSource ? state.pair.from : state.pair.to;
    final other = isSource ? state.pair.to : state.pair.from;
    final otherTag = isSource
        ? l10n.languagePickerTargetTag
        : l10n.languagePickerSourceTag;

    return Stack(
      children: [
        ListView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            18,
            0,
            18,
            AppDimens.space3XL + MediaQuery.paddingOf(context).bottom,
          ),
          itemCount: languages.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _ListHeader(
                state: state,
                count: languages.length,
                selected: active,
                onPick: onPick,
              );
            }
            final language = languages[index - 1];
            final isSelected = language == active;
            final isOther = language == other;
            final secondary = secondaryLanguageLabel(context, language);

            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: LanguageOptionTile(
                leading: LanguageBadgeTile(
                  badge: languageBadge(language.code),
                  isSelected: isSelected,
                ),
                title: language.nativeName,
                subtitle: !isOther
                    ? secondary
                    : secondary == null
                    ? otherTag
                    : '$secondary · $otherTag',
                isSelected: isSelected,
                minHeight: 58,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _OfflineModelSection(language: language),
                    if (isSelected)
                      const SelectionMark(isSelected: true)
                    else if (isOther)
                      const LanguageSwapPill(),
                  ],
                ),
                onTap: () => onPick(language),
              ),
            );
          },
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: _fadeHeight,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [c.surface.withValues(alpha: 0), c.surface],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OfflineModelSection extends StatelessWidget {
  const _OfflineModelSection({required this.language});

  final LanguageEntity language;

  Future<void> _remove(BuildContext context) async {
    final cubit = context.read<LanguagePickerCubit>();
    if (await confirmRemoveOfflineModel(context, language)) {
      await cubit.deleteModel(language);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      LanguagePickerCubit,
      LanguagePickerState,
      OfflineModelStatus?
    >(
      selector: (state) => state.modelStatuses[language.code],
      builder: (context, status) => OfflineModelButton(
        status: status,
        onDownload: () =>
            context.read<LanguagePickerCubit>().downloadModel(language),
        onRemove: () => _remove(context),
      ),
    );
  }
}

/// The recents (hidden while searching, or when there are none yet) and the
/// caption of the full list.
class _ListHeader extends StatelessWidget {
  const _ListHeader({
    required this.state,
    required this.count,
    required this.selected,
    required this.onPick,
  });

  final LanguagePickerState state;
  final int count;
  final LanguageEntity selected;
  final ValueChanged<LanguageEntity> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showRecents = !state.isSearching && state.recents.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showRecents) ...[
          _Caption(
            l10n.languagePickerRecent,
            padding: const EdgeInsets.fromLTRB(6, 16, 6, 8),
          ),
          RecentLanguageChips(
            languages: state.recents,
            selected: selected,
            onPick: onPick,
          ),
        ],
        _Caption(
          l10n.languagePickerAllLanguages(localizedDigits(context, count)),
          padding: const EdgeInsets.fromLTRB(6, 18, 6, 6),
        ),
      ],
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption(this.text, {required this.padding});

  final String text;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.36,
          color: context.palette.textMuted,
        ),
      ),
    );
  }
}
