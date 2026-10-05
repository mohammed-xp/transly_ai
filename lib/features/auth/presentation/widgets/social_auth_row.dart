import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/toast/app_toast.dart';
import '../../../../core/widgets/toast/coming_soon_toast.dart';
import '../cubit/google_sign_in_cubit.dart';
import '../cubit/google_sign_in_state.dart';
import '../utils/auth_l10n.dart';

/// Row of three equal-width social sign-in buttons (design `01b · Sign In`).
/// Google is wired up and owns its own cubit, so the row works the same on
/// the sign-in and sign-up screens. Apple and Facebook still just announce
/// "coming soon".
class SocialAuthRow extends StatelessWidget {
  const SocialAuthRow({super.key});

  static const double _height = 52;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<GoogleSignInCubit>(),
      child: BlocListener<GoogleSignInCubit, GoogleSignInState>(
        listener: (context, state) {
          switch (state) {
            case GoogleSignInSucceeded():
              context.goNamed(AppRoutes.homeName);
            case GoogleSignInFailed(:final failure):
              AppToast.show(
                context,
                message: googleSignInFailureMessage(context, failure),
                type: AppToastType.error,
              );
            case GoogleSignInLoading():
              AppToast.hide(context);
            case GoogleSignInInitial():
              break;
          }
        },
        child: Row(
          children: [
            const Expanded(child: _GoogleButton()),
            const SizedBox(width: 10),
            Expanded(
              child: _SocialButton(
                icon: Icons.apple_rounded,
                label: 'Apple',
                onTap: () => showComingSoonToast(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SocialButton(
                icon: Icons.facebook_rounded,
                label: 'Facebook',
                onTap: () => showComingSoonToast(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<GoogleSignInCubit, GoogleSignInState, bool>(
      selector: (state) => state is GoogleSignInLoading,
      builder: (context, isLoading) {
        return _SocialButton(
          icon: Icons.g_mobiledata_rounded,
          label: 'Google',
          isLoading: isLoading,
          onTap: () => context.read<GoogleSignInCubit>().signIn(),
        );
      },
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: palette.inputFill,
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusInput),
          onTap: isLoading ? null : onTap,
          child: Container(
            height: SocialAuthRow._height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusInput),
              border: Border.all(color: palette.border),
            ),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox.square(
                    dimension: AppDimens.iconM,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: palette.ink,
                    ),
                  )
                : Icon(icon, size: AppDimens.iconL, color: palette.ink),
          ),
        ),
      ),
    );
  }
}
