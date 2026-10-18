import '../../domain/entities/tone_catalog.dart';
import 'tone_model.dart';

class ToneCatalogModel {
  const ToneCatalogModel({required this.tones, required this.defaultTone});

  final List<ToneModel> tones;
  final String defaultTone;

  factory ToneCatalogModel.fromJson(Map<String, dynamic> json) =>
      ToneCatalogModel(
        tones: [
          for (final tone in json['tones'] as List<dynamic>)
            ToneModel.fromJson(tone as Map<String, dynamic>),
        ],
        defaultTone: json['defaultTone'] as String,
      );

  Map<String, dynamic> toJson() => {
    'tones': [for (final tone in tones) tone.toJson()],
    'defaultTone': defaultTone,
  };

  ToneCatalog toEntity() => ToneCatalog(
    tones: [for (final tone in tones) tone.toEntity()],
    defaultCode: defaultTone,
  );
}
