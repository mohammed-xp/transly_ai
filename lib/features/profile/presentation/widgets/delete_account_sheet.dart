import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/domain/entities/sign_in_method.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/auth_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/delete_account_cubit.dart';
import '../cubit/delete_account_state.dart';
import '../utils/delete_account_l10n.dart';

/// Shows [DeleteAccountSheet]. It can't be dismissed by a tap outside or a
/// drag, and not at all while the deletion is in flight. On success the app
/// routes to sign-in, which removes the sheet along with the profile route.
Future<void> showDeleteAccountSheet(
  BuildContext context,
  SignInMethod signInMethod,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    useSafeArea: true,
    backgroundColor: context.palette.surface,
    barrierColor: isDark
        ? Colors.black.withValues(alpha: 0.6)
        : AppColors.backgroundDark.withValues(alpha: 0.45),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(DeleteAccountSheet.topRadius),
      ),
    ),
    builder: (_) => BlocProvider(
      create: (_) => serviceLocator<DeleteAccountCubit>(),
      child: DeleteAccountSheet(signInMethod: signInMethod),
    ),
  );
}

/// The deletion is confirmed the way the session was started: an email
/// session re-enters its password, a Google session signs in with Google
/// again (it has no password to enter).
class DeleteAccountSheet extends StatelessWidget {
  const DeleteAccountSheet({super.key, required this.signInMethod});

  final SignInMethod signInMethod;

  static const double topRadius = 28;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    return _PopBlockedWhileBusy(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              22,
              AppDimens.space2XL,
              22,
              AppDimens.spaceXL,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: _WarningIcon()),
                const SizedBox(height: AppDimens.spaceL),
                Text(
                  l10n.profileDeleteAccountTitle,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: c.ink,
                  ),
                ),
                const SizedBox(height: AppDimens.spaceS),
                Text(
                  l10n.profileDeleteAccountWarning,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: c.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppDimens.spaceXL),
                switch (signInMethod) {
                  SignInMethod.email => const _PasswordConfirmation(),
                  SignInMethod.google => const _GoogleConfirmation(),
                },
                const SizedBox(height: AppDimens.spaceS),
                const _CancelButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PopBlockedWhileBusy extends StatelessWidget {
  const _PopBlockedWhileBusy({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DeleteAccountCubit, DeleteAccountState, bool>(
      selector: (state) => state.isBusy,
      builder: (context, isBusy) => PopScope(canPop: !isBusy, child: child),
    );
  }
}

class _WarningIcon extends StatelessWidget {
  const _WarningIcon();

  static const double _size = 56;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: c.coral.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.delete_outline_rounded,
        size: AppDimens.iconL,
        color: c.coral,
      ),
    );
  }
}

class _PasswordConfirmation extends StatefulWidget {
  const _PasswordConfirmation();

  @override
  State<_PasswordConfirmation> createState() => _PasswordConfirmationState();
}

class _PasswordConfirmationState extends State<_PasswordConfirmation> {
  late final TextEditingController _passwordController;
  late final FocusNode _passwordFocus;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final password = _passwordController.text;
    if (password.isEmpty) return;
    context.read<DeleteAccountCubit>().deleteAccount(password);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PasswordField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          onSubmitted: _submit,
        ),
        const SizedBox(height: AppDimens.spaceXL),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _passwordController,
          builder: (context, value, _) => _DeleteButton(
            isEnabled: value.text.isNotEmpty,
            onPressed: _submit,
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocSelector<DeleteAccountCubit, DeleteAccountState, Failure?>(
      selector: (state) => switch (state) {
        DeleteAccountFailed(:final failure) => failure,
        _ => null,
      },
      builder: (context, failure) => AuthTextField(
        label: l10n.signInPasswordLabel,
        hint: l10n.profileDeleteAccountPasswordHint,
        controller: controller,
        focusNode: focusNode,
        prefixIcon: Icons.lock_outline_rounded,
        obscureText: true,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.password],
        onChanged: (_) {},
        onFieldSubmitted: (_) => onSubmitted(),
        errorText: failure == null
            ? null
            : deleteAccountFailureMessage(context, failure),
      ),
    );
  }
}

class _GoogleConfirmation extends StatelessWidget {
  const _GoogleConfirmation();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!.profileDeleteAccountGoogleHint,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: context.palette.textMuted),
        ),
        const _GoogleConfirmationError(),
        const SizedBox(height: AppDimens.spaceXL),
        _DeleteButton(
          onPressed: () =>
              context.read<DeleteAccountCubit>().deleteAccountWithGoogle(),
        ),
      ],
    );
  }
}

class _GoogleConfirmationError extends StatelessWidget {
  const _GoogleConfirmationError();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DeleteAccountCubit, DeleteAccountState, Failure?>(
      selector: (state) => switch (state) {
        DeleteAccountFailed(:final failure) => failure,
        _ => null,
      },
      builder: (context, failure) {
        if (failure == null) return const SizedBox.shrink();
        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.only(top: AppDimens.spaceS),
          child: Text(
            deleteAccountWithGoogleFailureMessage(context, failure),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        );
      },
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onPressed, this.isEnabled = true});

  final VoidCallback onPressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context)!.profileDeleteAccountConfirm;
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    final radius = BorderRadius.circular(AppDimens.radiusButton);

    return BlocSelector<DeleteAccountCubit, DeleteAccountState, bool>(
      selector: (state) => state.isBusy,
      builder: (context, isBusy) {
        final canTap = isEnabled && !isBusy;

        return Material(
          color: canTap || isBusy ? c.coral : c.coral.withValues(alpha: 0.4),
          borderRadius: radius,
          child: InkWell(
            onTap: canTap ? onPressed : null,
            borderRadius: radius,
            child: SizedBox(
              height: AppDimens.buttonHeight,
              child: Center(
                child: isBusy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        label,
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton();

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context)!.profileDeleteAccountCancel;
    final c = context.palette;

    return BlocSelector<DeleteAccountCubit, DeleteAccountState, bool>(
      selector: (state) => state.isBusy,
      builder: (context, isBusy) => TextButton(
        onPressed: isBusy ? null : () => Navigator.of(context).pop(),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: c.textMuted),
        ),
      ),
    );
  }
}
