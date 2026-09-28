import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/toast/coming_soon_toast.dart';
import '../cubit/plan_usage_cubit.dart';
import '../cubit/plan_usage_state.dart';
import 'free_plan_card.dart';

/// Plan card under the identity block, carrying its own top gap so nothing is
/// left behind when a paid plan (no card yet) hides it.
class ProfilePlanUsage extends StatelessWidget {
  const ProfilePlanUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlanUsageCubit, PlanUsageState>(
      builder: (context, state) {
        final Widget? card = switch (state) {
          PlanUsageInitial() ||
          PlanUsageLoading() => const FreePlanCardSkeleton(),
          PlanUsageLoaded(:final usage) when usage.isFree => FreePlanCard(
            usage: usage,
            onUpgrade: () => showComingSoonToast(context),
          ),
          PlanUsageLoaded() => null,
          PlanUsageFailed(:final failure) => PlanUsageErrorCard(
            failure: failure,
            onRetry: () => context.read<PlanUsageCubit>().loadUsage(),
          ),
        };
        if (card == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: AppDimens.spaceM),
          child: card,
        );
      },
    );
  }
}
