import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/app_update_cubit.dart';
import '../cubit/app_update_state.dart';
import '../utils/open_app_store.dart';
import 'optional_update_sheet.dart';

/// Shows the optional-update sheet over [child] once an optional update is
/// found.
class OptionalUpdatePrompter extends StatefulWidget {
  const OptionalUpdatePrompter({super.key, required this.child});

  final Widget child;

  @override
  State<OptionalUpdatePrompter> createState() => _OptionalUpdatePrompterState();
}

class _OptionalUpdatePrompterState extends State<OptionalUpdatePrompter> {
  @override
  void initState() {
    super.initState();
    // The check usually finishes during splash, before this widget exists,
    // and a BlocListener only reports later changes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _prompt(context.read<AppUpdateCubit>().state);
    });
  }

  void _prompt(AppUpdateState state) {
    if (state is! AppUpdateOptional) return;
    unawaited(context.read<AppUpdateCubit>().optionalUpdatePrompted());
    unawaited(
      showOptionalUpdateSheet(
        context,
        update: state.update,
        onUpdate: () => openAppStore(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppUpdateCubit, AppUpdateState>(
      listenWhen: (_, current) => current is AppUpdateOptional,
      listener: (_, state) => _prompt(state),
      child: widget.child,
    );
  }
}
