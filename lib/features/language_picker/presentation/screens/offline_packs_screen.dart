import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/l10n/failure_message.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/spinning_ring.dart';
import '../../../../core/widgets/toast/app_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/offline_packs_settings.dart';
import '../cubit/offline_packs_cubit.dart';
import '../cubit/offline_packs_state.dart';
import '../widgets/offline_pack_row.dart';
import '../widgets/remove_offline_model_dialog.dart';

/// Auto-download settings, the languages on the device for offline
/// translation, and the ones that can be downloaded (design
/// `12d · Offline Packs`). Opened from the profile screen.
class OfflinePacksScreen extends StatelessWidget {
  const OfflinePacksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<OfflinePacksCubit>()..load(),
      child: const _OfflinePacksView(),
    );
  }
}

class _OfflinePacksView extends StatelessWidget {
  const _OfflinePacksView();

  void _showModelError(BuildContext context, OfflinePacksState state) {
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
    return BlocListener<OfflinePacksCubit, OfflinePacksState>(
      listenWhen: (previous, current) =>
          previous.modelError != current.modelError,
      listener: _showModelError,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const _Header(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.spaceL,
                    0,
                    AppDimens.spaceL,
                    AppDimens.spaceXL,
                  ),
                  children: const [_AutoDownloadSection(), _PacksSections()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Back chip · centered title, sized like the profile header.
class _Header extends StatelessWidget {
  const _Header();

  static const double _height = 40;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.profileName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.spaceXL,
        6,
        AppDimens.spaceXL,
        14,
      ),
      child: SizedBox(
        height: _height,
        child: NavigationToolbar(
          leading: AppBackButton(
            onTap: () => _back(context),
            fillColor: c.surface,
          ),
          middle: Text(
            AppLocalizations.of(context)!.offlinePacksTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: c.ink),
          ),
        ),
      ),
    );
  }
}

class _AutoDownloadSection extends StatelessWidget {
  const _AutoDownloadSection();

  Future<void> _change(
    BuildContext context,
    Future<bool> Function(OfflinePacksCubit cubit) change,
  ) async {
    final saved = await change(context.read<OfflinePacksCubit>());
    if (saved || !context.mounted) return;
    AppToast.show(
      context,
      message: AppLocalizations.of(context)!.offlinePacksSettingsSaveFailed,
      type: AppToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocSelector<
      OfflinePacksCubit,
      OfflinePacksState,
      OfflinePacksSettings
    >(
      selector: (state) => state.settings,
      builder: (context, settings) => SectionCard(
        title: l10n.offlinePacksAutoSection,
        rows: [
          _SwitchRow(
            label: l10n.offlinePacksAutoDownload,
            description: l10n.offlinePacksAutoDownloadBody,
            value: settings.autoDownload,
            onChanged: (value) =>
                _change(context, (cubit) => cubit.setAutoDownload(value)),
          ),
          _SwitchRow(
            label: l10n.offlinePacksWifiOnly,
            value: settings.wifiOnly,
            onChanged: settings.autoDownload
                ? (value) =>
                      _change(context, (cubit) => cubit.setWifiOnly(value))
                : null,
          ),
        ],
      ),
    );
  }
}

/// A settings switch; a [description] grows the row past its 50px height.
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.description,
  });

  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  static const double _minHeight = 50;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    final description = this.description;
    final onChanged = this.onChanged;

    return MergeSemantics(
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spaceL,
              vertical: 14,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          color: onChanged == null ? c.textMuted : c.ink,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          description,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            height: 1.5,
                            color: c.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppDimens.spaceM),
                Switch(value: value, onChanged: onChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PacksSections extends StatelessWidget {
  const _PacksSections();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OfflinePacksCubit, OfflinePacksState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.modelStatuses != current.modelStatuses,
      builder: (context, state) => switch (state.status) {
        OfflinePacksLoading() => const _Loading(),
        OfflinePacksFailed(:final failure) => _LoadFailed(failure: failure),
        OfflinePacksLoaded() => _PacksList(state: state),
      },
    );
  }
}

class _PacksList extends StatelessWidget {
  const _PacksList({required this.state});

  final OfflinePacksState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final installed = state.installed;
    final available = state.available;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (installed.isNotEmpty) ...[
          const SizedBox(height: AppDimens.spaceXL),
          _PacksSection(
            title: l10n.offlinePacksInstalledSection,
            languages: installed,
            state: state,
          ),
        ],
        if (available.isNotEmpty) ...[
          const SizedBox(height: AppDimens.spaceXL),
          _PacksSection(
            title: l10n.offlinePacksAvailableSection,
            languages: available,
            state: state,
          ),
        ],
      ],
    );
  }
}

class _PacksSection extends StatelessWidget {
  const _PacksSection({
    required this.title,
    required this.languages,
    required this.state,
  });

  final String title;
  final List<LanguageEntity> languages;
  final OfflinePacksState state;

  Future<void> _remove(BuildContext context, LanguageEntity language) async {
    final cubit = context.read<OfflinePacksCubit>();
    if (await confirmRemoveOfflineModel(context, language)) {
      await cubit.deleteModel(language);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OfflinePacksCubit>();

    return SectionCard(
      title: title,
      rows: [
        for (final language in languages)
          OfflinePackRow(
            language: language,
            status: state.modelStatuses[language.code]!,
            onDownload: () => cubit.downloadModel(language),
            onRemove: () => _remove(context, language),
          ),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.space3XL),
      child: Center(
        child: SpinningRing(
          size: 28,
          stroke: 3,
          trackColor: c.border,
          activeColor: c.coral,
          duration: const Duration(milliseconds: 900),
        ),
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space2XL,
        AppDimens.space3XL,
        AppDimens.space2XL,
        0,
      ),
      child: Column(
        children: [
          Text(
            failureMessage(context, failure),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 15,
              color: context.palette.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimens.spaceS),
          TextButton(
            onPressed: context.read<OfflinePacksCubit>().load,
            child: Text(AppLocalizations.of(context)!.commonRetry),
          ),
        ],
      ),
    );
  }
}
