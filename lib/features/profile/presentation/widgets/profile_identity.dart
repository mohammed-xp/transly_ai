import 'package:flutter/material.dart';

import '../../../../core/domain/entities/user_entity.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../l10n/app_localizations.dart';

/// Avatar with the change-photo badge, then name and email (design
/// `12 · Profile`).
class ProfileIdentity extends StatelessWidget {
  const ProfileIdentity({
    super.key,
    required this.user,
    required this.onChangePhoto,
  });

  final UserEntity user;
  final VoidCallback onChangePhoto;

  static const double _avatarSize = 84;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              UserAvatar(name: user.username, size: _avatarSize, ringWidth: 4),
              PositionedDirectional(
                end: 0,
                bottom: 0,
                child: _ChangePhotoBadge(onTap: onChangePhoto),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            user.username,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: c.ink,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            user.email,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ChangePhotoBadge extends StatelessWidget {
  const _ChangePhotoBadge({required this.onTap});

  final VoidCallback onTap;

  static const double _size = 32;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return Semantics(
      button: true,
      label: AppLocalizations.of(context)!.profileChangePhoto,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: c.cardShadow == null
              ? null
              : [
                  BoxShadow(
                    color: c.cardShadow!,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: c.surface,
          shape: CircleBorder(side: BorderSide(color: c.border)),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox.square(
              dimension: _size,
              child: Icon(
                Icons.photo_camera_outlined,
                size: 15,
                color: c.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
