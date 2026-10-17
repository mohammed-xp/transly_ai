import 'package:equatable/equatable.dart';

class TranslationTone extends Equatable {
  const TranslationTone({
    required this.code,
    required this.name,
    required this.nameAr,
  });

  final String code;
  final String name;

  /// Empty when the server has no Arabic name for this tone.
  final String nameAr;

  @override
  List<Object?> get props => [code];
}
