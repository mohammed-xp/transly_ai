import '../../../../core/errors/failure.dart';

extension ConversationFailure on Failure {
  /// The turns endpoint answers 429 once the conversation minutes run out.
  bool get isOutOfConversationTime =>
      this is TooManyRequestsFailure && statusCode == 429;
}
