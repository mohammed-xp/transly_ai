import 'package:equatable/equatable.dart';

class LanguageEntity extends Equatable {
  const LanguageEntity({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.isRtl,
  });

  static const english = LanguageEntity(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    isRtl: false,
  );

  static const arabic = LanguageEntity(
    code: 'ar',
    name: 'Arabic',
    nativeName: 'العربية',
    isRtl: true,
  );

  static const defaultSource = english;
  static const defaultTarget = arabic;

  final String code;
  final String name;
  final String nativeName;
  final bool isRtl;

  @override
  List<Object?> get props => [code];
}
