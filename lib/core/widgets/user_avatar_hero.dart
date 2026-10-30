import 'package:flutter/material.dart';

import 'user_avatar.dart';

/// Flies [child] between routes that show the user's avatar. Use at most one
/// per route.
class UserAvatarHero extends StatelessWidget {
  const UserAvatarHero({super.key, required this.child});

  final UserAvatar child;

  static const String _tag = 'user-avatar';

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: _tag,
      // Not on Android: committing a predictive back restarts the route's
      // animation from its end, which would snap the flying avatar back.
      transitionOnUserGestures:
          Theme.of(context).platform == TargetPlatform.iOS,
      // Scaled as a whole: the flight's rect alone would leave the letter at
      // its own size and stretch the circle when the rect isn't square.
      flightShuttleBuilder: (_, _, _, _, _) => FittedBox(child: child),
      child: child,
    );
  }
}
