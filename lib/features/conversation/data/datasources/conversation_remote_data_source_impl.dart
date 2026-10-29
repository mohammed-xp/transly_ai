import 'package:dio/dio.dart';

import '../../../../core/network/api_consumer.dart';
import '../../../../core/network/endpoints.dart';
import '../models/conversation_turn_response_model.dart';
import 'conversation_remote_data_source.dart';

class ConversationRemoteDataSourceImpl implements ConversationRemoteDataSource {
  ConversationRemoteDataSourceImpl(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  /// The server waits up to 30 s for the translation service.
  static const Duration receiveTimeout = Duration(seconds: 40);

  /// The longest history text the server accepts.
  static const int maxHistoryText = 500;

  @override
  Future<TurnReply> sendTurn({
    required String audioPath,
    required String languageA,
    required String languageB,
    required List<HistoryEntry> history,
  }) async {
    final form = FormData();
    form.files.add(
      MapEntry(
        'audio',
        await MultipartFile.fromFile(
          audioPath,
          filename: 'turn.wav',
          contentType: DioMediaType('audio', 'wav'),
        ),
      ),
    );
    form.fields
      ..add(MapEntry('languageA', languageA))
      ..add(MapEntry('languageB', languageB));
    // Built by hand: the server reads `history[0].text`, while
    // `FormData.fromMap` would send `history[0][text]`.
    for (final (index, entry) in history.indexed) {
      form.fields
        ..add(MapEntry('history[$index].language', entry.language))
        ..add(MapEntry('history[$index].text', _clip(entry.text)));
    }

    final response = await _apiConsumer.postMultipart(
      Endpoints.conversationTurns,
      formData: form,
      receiveTimeout: receiveTimeout,
    );
    return (
      turn: ConversationTurnResponseModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      ),
      secondsRemaining: int.tryParse(
        response.header('x-audio-seconds-remaining') ?? '',
      ),
    );
  }

  /// Cut to [maxHistoryText], without splitting a surrogate pair.
  static String _clip(String text) {
    if (text.length <= maxHistoryText) return text;
    var end = maxHistoryText;
    final last = text.codeUnitAt(end - 1);
    if (last >= 0xD800 && last <= 0xDBFF) end--;
    return text.substring(0, end);
  }
}
