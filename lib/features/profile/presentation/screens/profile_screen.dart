import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_links.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/domain/entities/user_entity.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/l10n/failure_message.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/open_external_url.dart';
import '../../../../core/widgets/toast/coming_soon_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../app_language/domain/entities/app_language.dart';
import '../../../app_language/presentation/cubit/app_language_cubit.dart';
import '../../../app_language/presentation/utils/app_language_l10n.dart';
import '../../../app_language/presentation/widgets/app_language_sheet.dart';
import '../cubit/plan_usage_cubit.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/delete_account_sheet.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_identity.dart';
import '../widgets/profile_plan_usage.dart';
import '../widgets/profile_row.dart';
import '../widgets/profile_section.dart';
import '../widgets/profile_sign_out_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<ProfileCubit>()..loadProfile(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<PlanUsageCubit>()..loadUsage(),
        ),
      ],
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.homeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ProfileHeader(
              onBack: () => _handleBack(context),
              onEdit: () => showComingSoonToast(context),
            ),
            Expanded(
              child: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) => switch (state) {
                  ProfileInitial() => const SizedBox.shrink(),
                  ProfileLoaded(:final user) => _ProfileContent(user: user),
                  ProfileFailed(:final failure) => _ProfileError(
                    failure: failure,
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    void comingSoon() => showComingSoonToast(context);

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
          ProfileIdentity(user: user, onChangePhoto: comingSoon),
          const ProfilePlanUsage(),
          const SizedBox(height: AppDimens.spaceXL),
          ProfileSection(
            title: l10n.profileAccountSection,
            rows: [
              ProfileRow(label: l10n.profileName, value: user.username),
              ProfileRow(
                label: l10n.profileEmail,
                value: user.email,
                valueDirection: TextDirection.ltr,
              ),
              const _AppLanguageRow(),
              ProfileRow(
                label: l10n.profileSignInMethod,
                value: l10n.profileSignInMethodEmail,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceXL),
          ProfileSection(
            title: l10n.profilePrivacySection,
            rows: [
              // ProfileRow(
              //   label: l10n.profileSyncHistory,
              //   trailing: Switch(value: false, onChanged: (_) => comingSoon()),
              //   onTap: comingSoon,
              // ),
              // ProfileRow(
              //   label: l10n.profileDownloadData,
              //   trailing: const ProfileRowChevron(),
              //   onTap: comingSoon,
              // ),
              ProfileRow(
                label: l10n.profilePrivacyPolicy,
                trailing: const ProfileRowChevron(),
                onTap: () => openExternalUrl(context, AppLinks.privacyPolicy),
              ),
              ProfileRow(
                label: l10n.profileTermsOfService,
                trailing: const ProfileRowChevron(),
                onTap: () => openExternalUrl(context, AppLinks.termsOfService),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceL),
          const ProfileSignOutButton(),
          const SizedBox(height: AppDimens.spaceM),
          _DeleteAccountButton(onTap: () => showDeleteAccountSheet(context)),
        ],
      ),
    );
  }
}

class _AppLanguageRow extends StatelessWidget {
  const _AppLanguageRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLanguageCubit, AppLanguage>(
      builder: (context, language) => ProfileRow(
        label: AppLocalizations.of(context)!.profileAppLanguage,
        value: appLanguageLabel(context, language),
        trailing: const ProfileRowChevron(),
        onTap: () => showAppLanguageSheet(context),
      ),
    );
  }
}

class _DeleteAccountButton extends StatelessWidget {
  const _DeleteAccountButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusChip),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spaceM,
            vertical: 6,
          ),
          child: Text(
            AppLocalizations.of(context)!.profileDeleteAccount,
            style: textTheme.titleMedium?.copyWith(
              fontSize: 14,
              color: c.coral,
            ),
          ),
        ),
      ),
    );
  }
}

/// No cached user to show. Sign-out stays reachable so the user isn't stuck
/// on a dead screen.
class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.spaceL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              failureMessage(context, failure),
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: AppDimens.spaceL),
            const ProfileSignOutButton(),
          ],
        ),
      ),
    );
  }
}
