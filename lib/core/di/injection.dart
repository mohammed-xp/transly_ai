import 'package:get_it/get_it.dart';

/// Service locator. Register infrastructure, repositories, use cases, and
/// cubits here. Feature modules add their registrations as they are built.
final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // ── Infrastructure (networking, storage, services) ──

  // ── Data sources ──

  // ── Repositories ──

  // ── Use cases ──

  // ── Cubits (registerFactory — fresh instance per route) ──
}
