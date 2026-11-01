import '../../domain/entities/plan_usage_entity.dart';

class PlanUsageModel {
  const PlanUsageModel({
    required this.plan,
    required this.charactersLimit,
    required this.charactersUsed,
    required this.resetsAt,
    this.audioSecondsLimit,
    this.audioSecondsRemaining,
    this.audioResetsAt,
  });

  final String plan;
  final int charactersLimit;
  final int charactersUsed;
  final DateTime resetsAt;
  final int? audioSecondsLimit;
  final int? audioSecondsRemaining;
  final DateTime? audioResetsAt;

  factory PlanUsageModel.fromJson(Map<String, dynamic> json) {
    final audioResetsAt = json['audioResetsAt'] as String?;

    return PlanUsageModel(
      plan: json['plan'] as String,
      charactersLimit: (json['charactersLimit'] as num).toInt(),
      charactersUsed: (json['charactersUsed'] as num).toInt(),
      resetsAt: DateTime.parse(json['resetsAt'] as String),
      audioSecondsLimit: (json['audioSecondsLimit'] as num?)?.toInt(),
      audioSecondsRemaining: (json['audioSecondsRemaining'] as num?)?.toInt(),
      audioResetsAt: audioResetsAt == null
          ? null
          : DateTime.parse(audioResetsAt),
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
      audioResetsAt: audioResetsAt,
    );
  }
}
