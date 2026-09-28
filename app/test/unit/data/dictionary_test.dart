import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/data/dictionary/dto/dictionary_dto.dart';
import 'package:vocabnote/data/dictionary/free_dictionary_client.dart';
import 'package:vocabnote/data/dictionary/suggestion_mapper.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/entities/word_suggestion.dart';

/// Dictionary look-up (F-004, F-006).
///
/// Parsing is tested against **real captured responses** in
/// `test/fixtures/dictionary/`, not against hand-written JSON that matches
/// whatever the parser happens to expect.
void main() {
  DictionaryResponseDto fixture(String name) {
    final raw = File('test/fixtures/dictionary/$name.json').readAsStringSync();
    return DictionaryResponseDto.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  group('parsing real responses', () {
    test('reads the cough fixture', () {
      final response = fixture('cough');
      expect(response.word, 'cough');
      expect(response.entries, isNotEmpty);
      expect(response.source?.url, 'https://en.wiktionary.org/wiki/cough');
      expect(response.source?.license?.name, 'CC BY-SA 4.0');
    });

    test('reads pronunciations with their accent tags', () {
      final entry = fixture('cough').entries.first;
      expect(entry.pronunciations, isNotEmpty);
      expect(entry.pronunciations.map((p) => p.text), contains('/kɒf/'));
      expect(
        entry.pronunciations.expand((p) => p.tags),
        contains('Received Pronunciation'),
      );
    });

    test('a miss is HTTP 200 with no entries, not a 404', () {
      // The behaviour that decides when the offline fallback kicks in.
      final response = fixture('notaword');
      expect(response.word, 'zzzzqqqxx');
      expect(response.entries, isEmpty);
    });

    test('parses every fixture without throwing', () {
      for (final name in <String>['cough', 'through', 'schedule', 'notaword']) {
        expect(() => fixture(name), returnsNormally, reason: name);
      }
    });
  });

  group('mapping to per-field suggestions', () {
    test('separates UK from US by pronunciation tag', () {
      final result = mapResponseToSuggestions(
        fixture('cough'),
        headword: 'cough',
      );

      final uk = result.forField(SuggestionField.ipaUk);
      final us = result.forField(SuggestionField.ipaUs);

      expect(uk, isNotEmpty);
      expect(us, isNotEmpty);
      // Received Pronunciation -> UK.
      expect(uk.map((s) => s.value), contains('kɒf'));
      // General American -> US.
      expect(us.map((s) => s.value), contains('kɔf'));
    });

    test('strips the slashes the API sends', () {
      final result = mapResponseToSuggestions(
        fixture('cough'),
        headword: 'cough',
      );
      for (final suggestion in <FieldSuggestion>[
        ...result.forField(SuggestionField.ipaUk),
        ...result.forField(SuggestionField.ipaUs),
      ]) {
        expect(suggestion.value, isNot(startsWith('/')));
        expect(suggestion.value, isNot(endsWith('/')));
      }
    });

    test('offers definitions, examples and parts of speech', () {
      final result = mapResponseToSuggestions(
        fixture('cough'),
        headword: 'cough',
      );

      expect(result.forField(SuggestionField.partOfSpeech), isNotEmpty);
      expect(result.forField(SuggestionField.definition), isNotEmpty);
      expect(result.forField(SuggestionField.example), isNotEmpty);
    });

    test('caps how many chips each field offers', () {
      // `cough` returns seven pronunciations and eight senses; the card must
      // not become a wall of near-identical chips.
      final result = mapResponseToSuggestions(
        fixture('cough'),
        headword: 'cough',
      );
      for (final field in SuggestionField.values) {
        expect(
          result.forField(field).length,
          lessThanOrEqualTo(3),
          reason: field.name,
        );
      }
    });

    test('carries the attribution and source link the licence requires', () {
      final result = mapResponseToSuggestions(
        fixture('cough'),
        headword: 'cough',
      );

      expect(result.requiresAttribution, isTrue);
      expect(result.attribution, WordSuggestions.wiktionaryAttribution);
      expect(result.attribution, contains('CC BY-SA 4.0'));
      expect(result.sourceUrl, 'https://en.wiktionary.org/wiki/cough');
      expect(result.licenseName, 'CC BY-SA 4.0');
      expect(
        result.licenseUrl,
        'https://creativecommons.org/licenses/by-sa/4.0/',
      );
      expect(result.source, WordSource.api);
    });

    test('a miss produces no suggestions and no attribution', () {
      // Nothing was taken, so nothing is owed.
      final result = mapResponseToSuggestions(
        fixture('notaword'),
        headword: 'zzzzqqqxx',
      );
      expect(result.isEmpty, isTrue);
      expect(result.attribution, isNull);
      expect(result.requiresAttribution, isFalse);
    });

    test('does not invent a UK pronunciation from an untagged one', () {
      // Offering an untagged (American-leaning) transcription as "UK" would be
      // a guess presented as fact.
      const response = DictionaryResponseDto(
        entries: <DictionaryEntryDto>[
          DictionaryEntryDto(
            pronunciations: <PronunciationDto>[
              PronunciationDto(type: 'ipa', text: '/kɑf/'),
            ],
          ),
        ],
      );
      final result = mapResponseToSuggestions(response, headword: 'cough');

      expect(result.forField(SuggestionField.ipaUk), isEmpty);
      expect(result.forField(SuggestionField.ipaUs), hasLength(1));
    });

    test('ignores non-English entries', () {
      const response = DictionaryResponseDto(
        entries: <DictionaryEntryDto>[
          DictionaryEntryDto(
            language: DictionaryLanguageDto(code: 'fr'),
            partOfSpeech: 'nom',
            pronunciations: <PronunciationDto>[
              PronunciationDto(type: 'ipa', text: '/ku/', tags: <String>['UK']),
            ],
          ),
        ],
      );
      expect(
        mapResponseToSuggestions(response, headword: 'coup').isEmpty,
        isTrue,
      );
    });
  });

  group('client behaviour', () {
    late DioAdapter adapter;
    late FreeDictionaryClient client;
    late List<Duration> sleeps;

    late Dio dio;

    setUp(() {
      sleeps = <Duration>[];
      dio = Dio();
      adapter = DioAdapter();
      dio.httpClientAdapter = adapter;
      client = FreeDictionaryClient(
        dio: dio,
        baseUrl: 'https://example.test/api/v1',
        userAgent: 'SchwaNotes/test',
        sleep: (d) async => sleeps.add(d),
      );
    });

    test('sends a descriptive User-Agent', () async {
      adapter.respond(200, jsonEncode(<String, Object?>{'word': 'cough'}));
      await client.lookup('cough');

      expect(adapter.lastHeaders?['user-agent'], 'SchwaNotes/test');
    });

    // F-092: the version in the User-Agent comes from a platform channel that
    // start-up no longer waits for, so the client may be built before it is
    // known - and must still send it, not a placeholder.
    test('sends a User-Agent that was not known when it was built', () async {
      final agent = Completer<String>();
      final pending = FreeDictionaryClient(
        dio: dio,
        baseUrl: 'https://example.test/api/v1',
        userAgent: agent.future,
        sleep: (d) async => sleeps.add(d),
      );
      adapter.respond(200, jsonEncode(<String, Object?>{'word': 'cough'}));

      final lookup = pending.lookup('cough');
      agent.complete('SchwaNotes/1.2.3');
      await lookup;

      expect(adapter.lastHeaders?['user-agent'], 'SchwaNotes/1.2.3');
    });

    test(
      'percent-encodes the word so odd input cannot break the URL',
      () async {
        adapter.respond(200, jsonEncode(<String, Object?>{'word': 'x'}));
        await client.lookup('a/b c');

        expect(adapter.lastPath, '/entries/en/a%2Fb%20c');
      },
    );

    test('returns a rate-limit failure on 429, after backing off', () async {
      adapter.respond(429, '');
      final result = await client.lookup('cough');

      expect(result.failureOrNull, isA<NetworkFailure>());
      expect(
        (result.failureOrNull! as NetworkFailure).kind,
        NetworkFailureKind.rateLimited,
      );
      expect(sleeps, hasLength(1), reason: 'exactly one retry');
      expect(sleeps.single, FreeDictionaryClient.baseBackoff);
    });

    test('retries exactly once, never more', () async {
      adapter.respond(429, '');
      await client.lookup('cough');
      expect(adapter.callCount, 2, reason: 'one attempt plus one retry');
    });

    test('does not retry a server error', () async {
      adapter.respond(500, '');
      final result = await client.lookup('cough');

      expect(adapter.callCount, 1);
      expect(
        (result.failureOrNull! as NetworkFailure).kind,
        NetworkFailureKind.server,
      );
    });

    test('reports malformed JSON without throwing', () async {
      adapter.respond(200, 'not json at all');
      final result = await client.lookup('cough');

      expect(result.isErr, isTrue);
      expect(
        (result.failureOrNull! as NetworkFailure).kind,
        NetworkFailureKind.malformedResponse,
      );
    });

    test('a 404 is not found, not a network error', () async {
      adapter.respond(404, '');
      final result = await client.lookup('cough');

      expect(result.failureOrNull, isA<NotFoundFailure>());
      expect(adapter.callCount, 1, reason: 'no point retrying a 404');
    });

    test('a successful response parses', () async {
      adapter.respond(
        200,
        File('test/fixtures/dictionary/cough.json').readAsStringSync(),
      );
      final result = await client.lookup('cough');

      expect(result.isOk, isTrue);
      expect(result.valueOrNull!.word, 'cough');
    });
  });
}

/// A minimal dio adapter, so the tests never touch the real API.
class DioAdapter implements HttpClientAdapter {
  int _status = 200;
  String _body = '{}';

  /// How many requests were made.
  int callCount = 0;

  /// The path of the most recent request.
  String? lastPath;

  /// The headers of the most recent request.
  Map<String, Object?>? lastHeaders;

  /// Sets the canned response.
  void respond(int status, String body) {
    _status = status;
    _body = body;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount++;
    lastPath = options.path;
    lastHeaders = options.headers.map(
      (key, value) => MapEntry(key.toLowerCase(), value),
    );
    return ResponseBody.fromString(
      _body,
      _status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
