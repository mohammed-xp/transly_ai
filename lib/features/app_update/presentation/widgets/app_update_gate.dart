import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/app_update_cubit.dart';
import '../cubit/app_update_state.dart';
import '../screens/force_update_screen.dart';

/// Replaces the whole app with [ForceUpdateScreen] while a required update is
/// pending. Sits above the router, so no navigation can get past it.
class AppUpdateGate extends StatelessWidget {
  const AppUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppUpdateCubit, AppUpdateState>(
      buildWhen: (previous, current) =>
          (previous is AppUpdateRequired) != (current is AppUpdateRequired),
      builder: (context, state) => switch (state) {
        AppUpdateRequired(:final update) => ForceUpdateScreen(update: update),
        _ => child,
      },
    );
  }
}
