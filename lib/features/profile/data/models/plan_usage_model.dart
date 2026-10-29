import '../../domain/entities/plan_usage_entity.dart';

class PlanUsageModel {
  const PlanUsageModel({
    required this.plan,
    required this.charactersLimit,
    required this.charactersUsed,
    required this.resetsAt,
    this.audioSecondsLimit,
    this.audioSecondsRemaining,
  });

  final String plan;
  final int charactersLimit;
  final int charactersUsed;
  final DateTime resetsAt;
  final int? audioSecondsLimit;
  final int? audioSecondsRemaining;

  factory PlanUsageModel.fromJson(Map<String, dynamic> json) {
    return PlanUsageModel(
      plan: json['plan'] as String,
      charactersLimit: (json['charactersLimit'] as num).toInt(),
      charactersUsed: (json['charactersUsed'] as num).toInt(),
      resetsAt: DateTime.parse(json['resetsAt'] as String),
      audioSecondsLimit: (json['audioSecondsLimit'] as num?)?.toInt(),
      audioSecondsRemaining: (json['audioSecondsRemaining'] as num?)?.toInt(),
    );
  }

  PlanUsageEntity toEntity() {
    return PlanUsageEntity(
      plan: plan,
      charactersLimit: charactersLimit,
      charactersUsed: charactersUsed,
      resetsAt: resetsAt,
      audioSecondsLimit: audioSecondsLimit,
      audioSecondsRemaining: audioSecondsRemaining,
    );
  }
}
