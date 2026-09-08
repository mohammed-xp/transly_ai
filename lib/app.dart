import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/session_cubit.dart';
import 'features/auth/presentation/cubit/session_state.dart';
import 'l10n/app_localizations.dart';

class TranslyApp extends StatelessWidget {
  const TranslyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SessionCubit>(),
      child: BlocListener<SessionCubit, SessionState>(
        listener: (context, state) {
          switch (state) {
            case SessionExpired():
              _onSessionExpired();
            case SessionSignedOut():
              appRouter.go(AppRoutes.signIn);
            case SessionActive():
              break;
          }
        },
        child: MaterialApp.router(
          title: 'Transly AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          routerConfig: appRouter,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
  }

  /// The backend rejected our token (HTTP 401 on some request) — route back
  /// to sign-in and let the user know why, since a failed background request
  /// otherwise degrades silently to the offline translation fallback. Uses
  /// the router's own navigator context (not the `BlocListener`'s, which
  /// sits above `MaterialApp` and so has no `Localizations`/`ScaffoldMessenger`)
  /// after the frame that applies the redirect has been built.
  void _onSessionExpired() {
    appRouter.go(AppRoutes.signIn);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navContext = appRouter.routerDelegate.navigatorKey.currentContext;
      if (navContext == null) return;
      final l10n = AppLocalizations.of(navContext);
      if (l10n == null) return;
      ScaffoldMessenger.of(
        navContext,
      ).showSnackBar(SnackBar(content: Text(l10n.authErrorSessionExpired)));
    });
  }
}
