import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';

/// Full-width sign-out card. Ending the session is owned by the app-level
/// [SessionCubit], whose listener routes back to sign-in.
class ProfileSignOutButton extends StatelessWidget {
  const ProfileSignOutButton({super.key});

  static const double _height = 50;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    return Material(
      color: c.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        side: BorderSide(color: c.border),
      ),
      child: InkWell(
        onTap: () => context.read<SessionCubit>().signOut(),
        child: SizedBox(
          height: _height,
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.authSignOut,
              style: textTheme.titleMedium?.copyWith(
                fontSize: 15,
                color: c.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
