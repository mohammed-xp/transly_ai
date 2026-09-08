import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:transly_ai/firebase_options.dart';

import 'app.dart';
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebase();
  await configureDependencies();
  runApp(const TranslyApp());
}

/// Auth and translation both talk to our own backend now, not Firebase — this
/// stays only to initialize whatever future Firebase services (crashlytics,
/// analytics, remote config) get added. Guarded so a misconfigured or
/// unreachable Firebase project never takes down the whole app.
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
