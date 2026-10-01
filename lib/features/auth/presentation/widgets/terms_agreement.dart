import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_links.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/open_external_url.dart';
import '../../../../l10n/app_localizations.dart';

/// "I agree to the Terms of Service and Privacy Policy" checkbox (design
/// `01c · Sign Up`). Tapping the row toggles it; the two links open the
/// hosted documents.
class TermsAgreement extends StatefulWidget {
  const TermsAgreement({
    super.key,
    required this.accepted,
    required this.onToggle,
    this.errorText,
  });

  final bool accepted;
  final VoidCallback onToggle;
  final String? errorText;

  @override
  State<TermsAgreement> createState() => _TermsAgreementState();
}

class _TermsAgreementState extends State<TermsAgreement> {
  static const double _boxSize = 20;

  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()
      ..onTap = () => openExternalUrl(context, AppLinks.termsOfService);
    _privacyTap = TapGestureRecognizer()
      ..onTap = () => openExternalUrl(context, AppLinks.privacyPolicy);
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final errorText = widget.errorText;
    final errorColor = theme.colorScheme.error;
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: c.textSecondary,
      height: 1.5,
    );
    final linkStyle = TextStyle(fontWeight: FontWeight.w600, color: c.coral);

    final uncheckedBorder = errorText != null
        ? errorColor
        : (isDark ? AppColors.radioRingDark : AppColors.radioRingLight);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onToggle,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                checked: widget.accepted,
                label:
                    '${l10n.signUpAgreePrefix}${l10n.profileTermsOfService}'
                    '${l10n.signUpAgreeAnd}${l10n.profilePrivacyPolicy}',
                onTap: widget.onToggle,
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: _boxSize,
                    height: _boxSize,
                    decoration: BoxDecoration(
                      color: widget.accepted ? c.coral : c.inputFill,
                      borderRadius: BorderRadius.circular(6),
                      border: widget.accepted
                          ? null
                          : Border.all(color: uncheckedBorder, width: 1.5),
                    ),
                    child: widget.accepted
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: l10n.signUpAgreePrefix),
                      TextSpan(
                        text: l10n.profileTermsOfService,
                        style: linkStyle,
                        recognizer: _termsTap,
                      ),
                      TextSpan(text: l10n.signUpAgreeAnd),
                      TextSpan(
                        text: l10n.profilePrivacyPolicy,
                        style: linkStyle,
                        recognizer: _privacyTap,
                      ),
                    ],
                  ),
                  style: textStyle,
                ),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText,
            style: theme.textTheme.bodySmall?.copyWith(color: errorColor),
          ),
        ],
      ],
    );
  }
}
