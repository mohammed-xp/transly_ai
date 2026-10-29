import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../core/constants/app_icons.dart';
import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/l10n/localized_digits.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/conversation_turn.dart';

/// One turn: what was said, its translation under a rule, and a row with the
/// language, time and actions (design `Conversation v2`). Turns in the
/// screen's second language sit on the end side, tinted. A null [onSpeak]
/// dims the speaker.
class TurnBubble extends StatelessWidget {
  const TurnBubble({
    super.key,
    required this.turn,
    required this.isEndSide,
    required this.onSpeak,
    required this.onCopy,
  });

  final ConversationTurn turn;
  final bool isEndSide;
  final VoidCallback? onSpeak;
  final VoidCallback onCopy;

  static const double _maxWidthFactor = 0.84;

  /// Rounded everywhere but the corner nearest the speaker's side.
  static BorderRadiusDirectional _radius({required bool isEndSide}) {
    const round = Radius.circular(AppDimens.radiusCard);
    const tail = Radius.circular(6);
    return BorderRadiusDirectional.only(
      topStart: round,
      topEnd: round,
      bottomStart: isEndSide ? round : tail,
      bottomEnd: isEndSide ? tail : round,
    );
  }

  /// Arabic script sits on taller lines than Latin in the design.
  static double _lineHeight(LanguageEntity language) =>
      language.isRtl ? 1.55 : 1.45;

  static TextDirection _directionOf(LanguageEntity language) =>
      language.isRtl ? TextDirection.rtl : TextDirection.ltr;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    final bubble = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceL,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: isEndSide ? null : c.surface,
        gradient: isEndSide ? c.tintGradient : null,
        borderRadius: _radius(isEndSide: isEndSide),
        border: Border.all(color: isEndSide ? c.tintBorder : c.border),
      ),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              turn.text,
              textDirection: _directionOf(turn.language),
              style: textTheme.bodyMedium?.copyWith(
                color: c.ink,
                height: _lineHeight(turn.language),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: AppDimens.spaceS),
              padding: const EdgeInsets.only(top: AppDimens.spaceS),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isEndSide
                        ? c.tintDivider
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Text(
                turn.translation,
                textDirection: _directionOf(turn.translationLanguage),
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  color: c.coralLabel,
                  height: _lineHeight(turn.translationLanguage),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Align(
      alignment: isEndSide
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      // Only the bubble is capped; the row under it may run wider.
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: isEndSide
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * _maxWidthFactor,
              ),
              child: bubble,
            ),
            _metaRow(context),
          ],
        ),
      ),
    );
  }

  Widget _metaRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final time = localizedDigitsIn(
      context,
      DateFormat('HH:mm').format(turn.spokenAt),
    );
    final items = [
      _MetaLabel(l10n.conversationTurnMeta(turn.language.nativeName, time)),
      _MetaAction(
        icon: AppIcons.speaker,
        tooltip: l10n.translateListen,
        onTap: onSpeak,
      ),
      _MetaAction(
        icon: AppIcons.copy,
        tooltip: l10n.translateCopy,
        onTap: onCopy,
      ),
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: isEndSide ? items.reversed.toList() : items,
    );
  }
}

/// ✦ language · time
class _MetaLabel extends StatelessWidget {
  const _MetaLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvgIcon(AppIcons.spark, size: 11, color: c.textSecondary),
          const SizedBox(width: 5),
          Text(
            text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaAction extends StatelessWidget {
  const _MetaAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  /// One of the [AppIcons].
  final String icon;
  final String tooltip;
  final VoidCallback? onTap;

  static const double _size = 44;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimens.radiusChipL);
    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: onTap != null ? 1 : 0.45,
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: SizedBox.square(
              dimension: _size,
              child: Center(
                child: AppSvgIcon(
                  icon,
                  size: 18,
                  color: context.palette.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
