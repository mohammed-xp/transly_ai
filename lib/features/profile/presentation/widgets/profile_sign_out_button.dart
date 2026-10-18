import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../../auth/presentation/cubit/session_state.dart';

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
      child: BlocSelector<SessionCubit, SessionState, bool>(
        selector: (state) => state is! SessionActive,
        builder: (context, isSigningOut) => InkWell(
          onTap: isSigningOut
              ? null
              : () => context.read<SessionCubit>().signOut(),
          child: SizedBox(
            height: _height,
            child: Center(
              child: isSigningOut
                  ? SizedBox.square(
                      dimension: AppDimens.iconM,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.ink,
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context)!.authSignOut,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: c.ink,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
