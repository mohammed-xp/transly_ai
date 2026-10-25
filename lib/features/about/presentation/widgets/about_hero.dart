import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/transly_logo.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/app_info_cubit.dart';
import '../cubit/app_info_state.dart';

/// Logo, "Traduly AI" wordmark, tagline and the installed version (design
/// `14 · About`).
class AboutHero extends StatelessWidget {
  const AboutHero({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: AppDimens.spaceM),
      child: Column(
        children: [
          const TranslyLogo.medium(),
          const SizedBox(height: 18),
          const _Wordmark(),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.aboutTagline,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: c.textMuted),
          ),
          const _VersionPill(),
        ],
      ),
    );
  }
}

/// Brand name, not localized.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return Text.rich(
      TextSpan(
        text: 'Traduly',
        children: [
          TextSpan(
            text: ' AI',
            style: TextStyle(color: c.coral),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
        fontSize: 26,
        letterSpacing: -0.26,
        color: c.ink,
      ),
    );
  }
}

/// Space is kept while the version loads so the sections below don't jump;
/// the pill is left out if the version can't be read.
class _VersionPill extends StatelessWidget {
  const _VersionPill();

  static const double _gap = 14;
  static const double _height = 28;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppInfoCubit, AppInfoState>(
      builder: (context, state) => switch (state) {
        AppInfoLoading() => const SizedBox(height: _gap + _height),
        AppInfoLoaded(:final info) => Padding(
          padding: const EdgeInsets.only(top: _gap),
          child: _Pill(
            label: AppLocalizations.of(context)!.aboutVersion(info.version),
          ),
        ),
        AppInfoFailed() => const SizedBox.shrink(),
      },
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return Container(
      height: _VersionPill._height,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceM),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(color: c.border),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          label,
          textDirection: TextDirection.ltr,
          maxLines: 1,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1,
            color: c.textSecondary,
          ),
        ),
      ),
    );
  }
}
