import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/auth_text_field.dart';
import '../../../../core/widgets/decorative_blob.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/toast/app_toast.dart';
import '../../../../core/widgets/toast/app_toast_scope.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/password_strength.dart';
import '../../domain/entities/sign_in_form_errors.dart';
import '../../domain/entities/sign_up_form_errors.dart';
import '../../domain/usecases/validate_sign_up_form_usecase.dart';
import '../cubit/sign_up_cubit.dart';
import '../cubit/sign_up_state.dart';
import '../utils/auth_l10n.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_switch_prompt.dart';
import '../widgets/password_strength_meter.dart';
import '../widgets/password_visibility_toggle.dart';
import '../widgets/social_auth_row.dart';
import '../widgets/terms_agreement.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<SignUpCubit>(),
      // Listens above this screen's toast scope so the success toast lands in
      // the app-wide one and stays visible on the sign-in screen.
      child: BlocListener<SignUpCubit, SignUpState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status is SignUpSucceeded,
        listener: (context, state) {
          AppToast.show(
            context,
            message: AppLocalizations.of(context)!.signUpAccountCreated,
          );
          context.pushReplacementNamed(AppRoutes.signInName);
        },
        child: const AppToastScope(child: _SignUpView()),
      ),
    );
  }
}

class _SignUpView extends StatefulWidget {
  const _SignUpView();

  @override
  State<_SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<_SignUpView> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _nameFocus;
  late final FocusNode _emailFocus;
  late final FocusNode _passwordFocus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameFocus = FocusNode();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocus.dispose();
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

    return BlocListener<SignUpCubit, SignUpState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        switch (state.status) {
          case SignUpFailed(:final failure):
            AppToast.show(
              context,
              message: signUpFailureMessage(context, failure),
              type: AppToastType.error,
            );
          case SignUpSubmitting():
            AppToast.hide(context);
          case SignUpInitial() || SignUpSucceeded():
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
                      child: AppBackButton(onTap: () => _handleBack(context)),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(26, 20, 26, 0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.signUpTitle,
                                  style: textTheme.headlineLarge?.copyWith(
                                    fontSize: 29,
                                    color: c.ink,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  l10n.signUpSubtitle,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontSize: 15,
                                    color: c.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _NameField(
                                  controller: _nameController,
                                  focusNode: _nameFocus,
                                ),
                                const SizedBox(height: 12),
                                _EmailField(
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                ),
                                const SizedBox(height: 12),
                                _PasswordField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  onSubmitted: () =>
                                      context.read<SignUpCubit>().submit(),
                                ),
                                const _PasswordStrengthIndicator(),
                                const SizedBox(height: 16),
                                const _TermsField(),
                                const SizedBox(height: 20),
                                const _SubmitButton(),
                                const SizedBox(height: 20),
                                AuthDivider(label: l10n.signUpOrRegisterWith),
                                const SizedBox(height: 20),
                                const SocialAuthRow(),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 20,
                                    bottom: 26,
                                  ),
                                  child: AuthSwitchPrompt(
                                    question: l10n.signUpHaveAccount,
                                    action: l10n.signUpSignIn,
                                    onTap: () => context.pushReplacementNamed(
                                      AppRoutes.signInName,
                                    ),
                                  ),
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

class _NameField extends StatelessWidget {
  const _NameField({required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocSelector<SignUpCubit, SignUpState, NameFieldError?>(
      selector: (state) => state.showFieldErrors ? state.errors.name : null,
      builder: (context, error) {
        return AuthTextField(
          label: l10n.signUpNameLabel,
          hint: l10n.signUpNameHint,
          controller: controller,
          focusNode: focusNode,
          prefixIcon: Icons.person_outline_rounded,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          maxLength: ValidateSignUpFormUseCase.maxNameLength,
          autofillHints: const [AutofillHints.name],
          onChanged: context.read<SignUpCubit>().nameChanged,
          onFieldSubmitted: (_) => focusNode.nextFocus(),
          errorText: nameFieldErrorMessage(context, error),
        );
      },
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
    return BlocSelector<SignUpCubit, SignUpState, EmailFieldError?>(
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
          autofillHints: const [AutofillHints.email],
          onChanged: context.read<SignUpCubit>().emailChanged,
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
    return BlocSelector<SignUpCubit, SignUpState, (PasswordFieldError?, bool)>(
      selector: (state) => (
        state.showFieldErrors ? state.errors.password : null,
        state.isPasswordVisible,
      ),
      builder: (context, data) {
        final (error, isVisible) = data;
        return AuthTextField(
          label: l10n.signInPasswordLabel,
          hint: l10n.signUpPasswordHint,
          controller: controller,
          focusNode: focusNode,
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: !isVisible,
          textInputAction: TextInputAction.done,
          maxLength: ValidateSignUpFormUseCase.maxPasswordLength,
          autofillHints: const [AutofillHints.newPassword],
          onChanged: context.read<SignUpCubit>().passwordChanged,
          onFieldSubmitted: (_) => onSubmitted(),
          errorText: signUpPasswordErrorMessage(context, error),
          suffixIcon: PasswordVisibilityToggle(
            isVisible: isVisible,
            onTap: context.read<SignUpCubit>().passwordVisibilityToggled,
          ),
        );
      },
    );
  }
}

class _PasswordStrengthIndicator extends StatelessWidget {
  const _PasswordStrengthIndicator();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SignUpCubit, SignUpState, PasswordStrength?>(
      selector: (state) => state.passwordStrength,
      builder: (context, strength) {
        if (strength == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: PasswordStrengthMeter(strength: strength),
        );
      },
    );
  }
}

class _TermsField extends StatelessWidget {
  const _TermsField();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SignUpCubit, SignUpState, (bool, bool)>(
      selector: (state) => (
        state.termsAccepted,
        state.showFieldErrors && state.errors.termsNotAccepted,
      ),
      builder: (context, data) {
        final (accepted, showError) = data;
        return TermsAgreement(
          accepted: accepted,
          onToggle: context.read<SignUpCubit>().termsToggled,
          errorText: showError
              ? AppLocalizations.of(context)!.signUpTermsRequired
              : null,
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SignUpCubit, SignUpState, bool>(
      selector: (state) => state.isSubmitting,
      builder: (context, isSubmitting) {
        return GradientButton(
          label: AppLocalizations.of(context)!.signUpSubmit,
          isLoading: isSubmitting,
          onPressed: () => context.read<SignUpCubit>().submit(),
        );
      },
    );
  }
}
