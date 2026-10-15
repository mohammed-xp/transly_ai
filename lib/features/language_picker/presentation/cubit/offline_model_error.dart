import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/errors/failure.dart';

/// Compared by identity on purpose, so the same failure happening twice in a
/// row is still reported twice.
class OfflineModelError {
  OfflineModelError(this.language, this.failure);

  final LanguageEntity language;
  final Failure failure;
}
