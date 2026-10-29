import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/network/endpoints.dart';
import 'package:transly_ai/features/conversation/data/datasources/conversation_remote_data_source_impl.dart';
import 'package:transly_ai/features/conversation/data/models/conversation_turn_response_model.dart';

import '../../../../helpers/fake_api_consumer.dart';

void main() {
  late Directory dir;
  late String wavPath;
  late FakeApiConsumer api;
  late ConversationRemoteDataSourceImpl remote;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('turn_test_');
    wavPath = '${dir.path}/turn_1.wav';
    await File(wavPath).writeAsBytes(List.filled(64, 0));
    api = FakeApiConsumer({
      'success': true,
      'data': {
        'status': 'noSpeech',
        'audioSeconds': 1,
        'model': 'gemini-3.1-flash-lite',
        'createdAt': '2026-10-28T12:00:05.0000000+00:00',
      },
    });
    remote = ConversationRemoteDataSourceImpl(api);
  });

  tearDown(() => dir.delete(recursive: true));

  Future<FormData> send({
    List<({String language, String text})> history = const [],
  }) async {
    await remote.sendTurn(
      audioPath: wavPath,
      languageA: 'ar',
      languageB: 'en',
      history: history,
    );
    return api.multipartRequests.single.$2;
  }

  Map<String, String> fieldsOf(FormData form) => {
    for (final field in form.fields) field.key: field.value,
  };

  test('posts to the conversation turns endpoint', () async {
    await send();

    expect(api.multipartRequests.single.$1, Endpoints.conversationTurns);
  });

  test('waits long enough for the translation service', () async {
    await send();

    expect(
      api.multipartRequests.single.$3,
      ConversationRemoteDataSourceImpl.receiveTimeout,
    );
  });

  test('sends the recording as turn.wav, audio/wav', () async {
    final form = await send();

    final audio = form.files.single;
    expect(audio.key, 'audio');
    expect(audio.value.filename, 'turn.wav');
    expect(audio.value.contentType.toString(), 'audio/wav');
  });

  test('sends both languages', () async {
    final fields = fieldsOf(await send());

    expect(fields['languageA'], 'ar');
    expect(fields['languageB'], 'en');
  });

  test('names the history fields with dots, oldest first', () async {
    final fields = fieldsOf(
      await send(
        history: [
          (language: 'en', text: 'I bought a new car yesterday'),
          (language: 'ar', text: 'هي لونها إيه؟'),
        ],
      ),
    );

    expect(fields['history[0].language'], 'en');
    expect(fields['history[0].text'], 'I bought a new car yesterday');
    expect(fields['history[1].language'], 'ar');
    expect(fields['history[1].text'], 'هي لونها إيه؟');
  });

  test('cuts a history text down to what the server accepts', () async {
    final fields = fieldsOf(
      await send(history: [(language: 'en', text: 'a' * 600)]),
    );

    expect(
      fields['history[0].text'],
      hasLength(ConversationRemoteDataSourceImpl.maxHistoryText),
    );
  });

  test('reads the turn and the seconds left', () async {
    api.responseHeaders = {
      'x-audio-seconds-remaining': ['258'],
    };

    final reply = await remote.sendTurn(
      audioPath: wavPath,
      languageA: 'ar',
      languageB: 'en',
      history: const [],
    );

    expect(reply.turn.status, ConversationTurnStatus.noSpeech);
    expect(reply.secondsRemaining, 258);
  });

  test('leaves the seconds left unknown without the header', () async {
    final reply = await remote.sendTurn(
      audioPath: wavPath,
      languageA: 'ar',
      languageB: 'en',
      history: const [],
    );

    expect(reply.secondsRemaining, isNull);
  });
}
