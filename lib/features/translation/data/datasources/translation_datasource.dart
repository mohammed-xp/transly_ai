import '../../domain/entities/translation.dart';

abstract interface class TranslationDatasource {
  Future<Translation> translate(TranslationRequest request);
}
