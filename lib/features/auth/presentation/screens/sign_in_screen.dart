import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/decorative_blob.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/sign_in_form_errors.dart';
import '../cubit/sign_in_cubit.dart';
import '../cubit/sign_in_state.dart';
import '../utils/auth_l10n.dart';
import '../widgets/auth_back_button.dart';
import '../widgets/auth_brand_mark.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/sign_up_prompt.dart';
import '../widgets/social_auth_row.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<SignInCubit>(),
      child: const _SignInView(),
    );
  }
}

class _SignInView extends StatefulWidget {
  const _SignInView();

  @override
  State<_SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<_SignInView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _emailFocus;
  late final FocusNode _passwordFocus;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.onboardingName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    return BlocListener<SignInCubit, SignInState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        switch (state.status) {
          case SignInSucceeded():
            context.goNamed(AppRoutes.homeName);
          case SignInFailed(:final failure):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(authFailureMessage(context, failure))),
            );
          case SignInInitial():
          case SignInSubmitting():
            break;
        }
      },
      child: Scaffold(
        backgroundColor: c.screenBackground,
        body: Stack(
          children: [
            DecorativeBlob(
              isDark ? AppColors.accentDark : AppColors.primary,
              opacity: isDark ? 0.32 : 0.10,
              diameter: isDark ? 340 : 320,
              top: isDark ? -150 : -140,
              right: isDark ? -120 : -110,
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AuthBackButton(onTap: () => _handleBack(context)),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(26, 22, 26, 0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AuthBrandMark(),
                                const SizedBox(height: 20),
                                Text(
                                  l10n.signInTitle,
                                  style: textTheme.headlineLarge?.copyWith(
                                    fontSize: 29,
                                    color: c.ink,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  l10n.signInSubtitle,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontSize: 15,
                                    color: c.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 26),
                                _EmailField(
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                ),
                                const SizedBox(height: 12),
                                _PasswordField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  onSubmitted: () =>
                                      context.read<SignInCubit>().submit(),
                                ),
                                const SizedBox(height: 14),
                                const _ForgotPasswordLink(),
                                const SizedBox(height: 24),
                                const _SubmitButton(),
                                const SizedBox(height: 22),
                                const AuthDivider(),
                                const SizedBox(height: 22),
                                const SocialAuthRow(),
                                const Spacer(),
                                const Padding(
                                  padding: EdgeInsets.only(top: 22, bottom: 26),
                                  child: SignUpPrompt(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocSelector<SignInCubit, SignInState, EmailFieldError?>(
      selector: (state) => state.showFieldErrors ? state.errors.email : null,
      builder: (context, error) {
        return AuthTextField(
          label: l10n.signInEmailLabel,
          hint: l10n.signInEmailHint,
          controller: controller,
          focusNode: focusNode,
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username, AutofillHints.email],
          onChanged: context.read<SignInCubit>().emailChanged,
          onFieldSubmitted: (_) => focusNode.nextFocus(),
          errorText: emailFieldErrorMessage(context, error),
        );
      },
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
    return BlocSelector<SignInCubit, SignInState, (PasswordFieldError?, bool)>(
      selector: (state) => (
        state.showFieldErrors ? state.errors.password : null,
        state.isPasswordVisible,
      ),
      builder: (context, data) {
        final (error, isVisible) = data;
        return AuthTextField(
          label: l10n.signInPasswordLabel,
          hint: l10n.signInPasswordHint,
          controller: controller,
          focusNode: focusNode,
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: !isVisible,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          onChanged: context.read<SignInCubit>().passwordChanged,
          onFieldSubmitted: (_) => onSubmitted(),
          errorText: passwordFieldErrorMessage(context, error),
          suffixIcon: Semantics(
            button: true,
            label: isVisible
                ? l10n.signInHidePassword
                : l10n.signInShowPassword,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: context.read<SignInCubit>().passwordVisibilityToggled,
              child: Icon(
                isVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 19,
                color: context.palette.textMuted,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ForgotPasswordLink extends StatelessWidget {
  const _ForgotPasswordLink();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Semantics(
        button: true,
        child: GestureDetector(
          onTap: () => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.signInComingSoon))),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              l10n.signInForgotPassword,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.palette.coral,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppDimens.radiusButton);

    return BlocSelector<SignInCubit, SignInState, bool>(
      selector: (state) => state.isSubmitting,
      builder: (context, isSubmitting) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: AppColors.deep.withValues(alpha: isDark ? 0.4 : 0.3),
                blurRadius: isDark ? 30 : 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            child: InkWell(
              onTap: isSubmitting
                  ? null
                  : () => context.read<SignInCubit>().submit(),
              borderRadius: radius,
              child: SizedBox(
                height: AppDimens.buttonHeight,
                child: Center(
                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.signInSubmit,
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
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
