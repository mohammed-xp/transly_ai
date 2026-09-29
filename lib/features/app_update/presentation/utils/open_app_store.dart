import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/toast/app_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/app_update_cubit.dart';

/// Opens the store listing, or shows a toast when it can't be opened.
Future<void> openAppStore(BuildContext context) async {
  final opened = await context.read<AppUpdateCubit>().openStore();
  if (opened || !context.mounted) return;
  AppToast.show(
    context,
    message: AppLocalizations.of(context)!.updateStoreOpenFailed,
    type: AppToastType.error,
  );
}
