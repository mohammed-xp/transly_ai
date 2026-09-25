import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/service_locator.dart';
import 'core/init/hive_initializer.dart';
import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/session_cubit.dart';
import 'features/auth/presentation/cubit/session_state.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveInitializer.initHive();
  await _initFirebase();
  await configureDependencies();
  runApp(const TranslyApp());
}

class TranslyApp extends StatelessWidget {
  const TranslyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<SessionCubit>(),
      child: BlocListener<SessionCubit, SessionState>(
        listener: (context, state) {
          switch (state) {
            case SessionExpired():
              _onSessionExpired();
            case SessionSignedOut():
              appRouter.goNamed(AppRoutes.signInName);
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

  /// This listener sits above [MaterialApp], so its own context has no
  /// Navigator or ScaffoldMessenger — reach them through the router instead.
  void _onSessionExpired() {
    appRouter.goNamed(AppRoutes.signInName);
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

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    if (kDebugMode) {
      debugPrint('Firebase.initializeApp() failed: $error');
    }
  }
}
