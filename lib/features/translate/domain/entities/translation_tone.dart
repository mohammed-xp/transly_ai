import 'package:equatable/equatable.dart';

/// A tone offered by the server. [name] is already in the UI language the
/// tones were fetched in.
class TranslationTone extends Equatable {
  const TranslationTone({required this.code, required this.name});

  final String code;
  final String name;

  @override
  List<Object?> get props => [code];
}
