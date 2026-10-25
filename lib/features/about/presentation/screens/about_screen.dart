import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_links.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/localized_digits.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/open_external_url.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../../../core/widgets/profile_row.dart';
import '../../../../core/widgets/section_card.dart';
// import '../../../../core/widgets/transly_logo.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../app_update/presentation/utils/open_app_store.dart';
import '../cubit/app_info_cubit.dart';
// import '../cubit/app_info_state.dart';
import '../utils/share_app.dart';
import '../widgets/about_hero.dart';

/// The installed version, rate/share, support and legal links (design
/// `14 · About`). Opened from the profile screen.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<AppInfoCubit>()..load(),
      child: const Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _Header(),
              Expanded(child: _AboutContent()),
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
            AppLocalizations.of(context)!.aboutTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: c.ink),
          ),
        ),
      ),
    );
  }
}

class _AboutContent extends StatelessWidget {
  const _AboutContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rateLabel = defaultTargetPlatform == TargetPlatform.iOS
        ? l10n.aboutRateOnAppStore
        : l10n.aboutRateOnPlayStore;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.spaceL,
        0,
        AppDimens.spaceL,
        AppDimens.spaceXL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AboutHero(),
          const SizedBox(height: AppDimens.spaceXL),
          SectionCard(
            title: l10n.aboutSupportSection,
            rows: [
              ProfileRow(
                label: rateLabel,
                trailing: const ProfileRowChevron(),
                onTap: () => openAppStore(context),
              ),
              ProfileRow(
                label: l10n.aboutShare,
                trailing: const ProfileRowChevron(),
                onTap: () => shareApp(context),
              ),
              // TODO(coming-soon): restore once there are release notes to show.
              // ProfileRow(
              //   label: l10n.aboutWhatsNew,
              //   trailing: const ProfileRowChevron(),
              //   onTap: () {},
              // ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceXL),
          SectionCard(
            title: l10n.aboutHelpSection,
            rows: [
              // TODO(coming-soon): restore once the help center has a link.
              // ProfileRow(
              //   label: l10n.aboutHelpCenter,
              //   trailing: const _ExternalLinkIcon(),
              //   onTap: () {},
              // ),
              ProfileRow(
                label: l10n.aboutContactUs,
                trailing: const _SupportEmail(),
                onTap: () => openExternalUrl(
                  context,
                  AppLinks.supportEmail,
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceXL),
          SectionCard(
            title: l10n.aboutLegalSection,
            rows: [
              ProfileRow(
                label: l10n.aboutTermsOfUse,
                trailing: const _ExternalLinkIcon(),
                onTap: () => openExternalUrl(context, AppLinks.termsOfService),
              ),
              ProfileRow(
                label: l10n.aboutPrivacyPolicy,
                trailing: const _ExternalLinkIcon(),
                onTap: () => openExternalUrl(context, AppLinks.privacyPolicy),
              ),
              // TODO(coming-soon): restore the licenses row, _showLicenses
              // and the imports above.
              // ProfileRow(
              //   label: l10n.aboutOpenSourceLicenses,
              //   trailing: const ProfileRowChevron(),
              //   onTap: () => _showLicenses(context),
              // ),
            ],
          ),
          const _Copyright(),
        ],
      ),
    );
  }

  // void _showLicenses(BuildContext context) {
  //   final state = context.read<AppInfoCubit>().state;
  //   showLicensePage(
  //     context: context,
  //     applicationName: 'Traduly AI',
  //     applicationVersion: state is AppInfoLoaded ? state.info.version : null,
  //     applicationIcon: const Padding(
  //       padding: EdgeInsets.all(AppDimens.spaceL),
  //       child: TranslyLogo.compact(),
  //     ),
  //   );
  // }
}

class _ExternalLinkIcon extends StatelessWidget {
  const _ExternalLinkIcon();

  @override
  Widget build(BuildContext context) {
    return AppSvgIcon(
      AppIcons.externalLink,
      size: 15,
      color: context.palette.iconLine,
    );
  }
}

class _SupportEmail extends StatelessWidget {
  const _SupportEmail();

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLinks.supportEmailAddress,
      textDirection: TextDirection.ltr,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w500,
        color: context.palette.textMuted,
      ),
    );
  }
}

class _Copyright extends StatelessWidget {
  const _Copyright();

  @override
  Widget build(BuildContext context) {
    final year = localizedDigits(context, DateTime.now().year);

    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: AppDimens.spaceXS),
      child: Text(
        AppLocalizations.of(context)!.aboutCopyright(year),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 13,
          color: context.palette.textMuted,
        ),
      ),
    );
  }
}
