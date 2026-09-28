import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/data/dictionary/dto/dictionary_dto.dart';

/// HTTP client for FreeDictionaryAPI.com (`docs/DATA-SOURCES.md` §1).
///
/// The only outbound request the app ever makes on the user's behalf, and it
/// happens **only** when they tap *Look up* - never automatically, never as
/// they type. Everything about it is arranged so that failing is cheap: the
/// form stays fully usable and the user can type the IPA themselves (F-006).
///
/// Rate limit is 1,000 requests/hour/IP, so the client sends a descriptive
/// `User-Agent`, retries once, and backs off exponentially on `429`.
class FreeDictionaryClient {
  /// Creates a client.
  ///
  /// [dio] is injectable so tests can drive it with a mock adapter instead of
  /// hitting the real API - which would be rude, slow, and flaky.
  ///
  /// The user agent may still be on its way: it carries the app version, which
  /// start-up no longer waits for (F-092). Each request waits for it instead.
  new({
    required this._userAgent,
    Dio? dio,
    String? baseUrl,
    Future<void> Function(Duration)? sleep,
  }) : _sleep = sleep ?? Future<void>.delayed,
       _dio = dio ?? Dio() {
    _dio.options = _dio.options.copyWith(
      baseUrl: baseUrl ?? defaultBaseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      headers: <String, String>{HttpHeaders.acceptHeader: 'application/json'},
      // Statuses are inspected rather than thrown on, so a 429 can be backed
      // off and a 404 can become a clean "no entry" instead of an exception.
      validateStatus: (_) => true,
    );
  }

  /// The documented endpoint, overridable with
  /// `--dart-define=DICTIONARY_BASE_URL=...`.
  static const String defaultBaseUrl = String.fromEnvironment(
    'DICTIONARY_BASE_URL',
    defaultValue: 'https://freedictionaryapi.com/api/v1',
  );

  /// The per-request budget from F-006.
  static const Duration timeout = Duration(seconds: 6);

  /// How many times a failed request is retried. One, as specified - a user
  /// waiting on a form should not sit through five.
  static const int maxRetries = 1;

  /// The first back-off delay; doubles per attempt.
  static const Duration baseBackoff = Duration(milliseconds: 500);

  final Dio _dio;
  final FutureOr<String> _userAgent;
  final Future<void> Function(Duration) _sleep;

  /// Looks up [word].
  ///
  /// Returns:
  /// * `Ok(response)` when the API answered, **including** when it answered
  ///   with no entries - a miss is HTTP 200 with `entries: []`, not a 404;
  /// * `Err(NotFoundFailure)` when there is genuinely no entry;
  /// * `Err(NetworkFailure)` for offline, timeout, rate limit or server error.
  AsyncResult<DictionaryResponseDto> lookup(String word) async {
    final path = '/entries/en/${Uri.encodeComponent(word.trim())}';

    var attempt = 0;
    while (true) {
      final outcome = await _attempt(path);

      final failure = outcome.failureOrNull;
      final shouldRetry =
          failure is NetworkFailure &&
          _isRetryable(failure.kind) &&
          attempt < maxRetries;

      if (!shouldRetry) return outcome;

      // Exponential back-off, and only ever on the kinds worth retrying.
      await _sleep(baseBackoff * (1 << attempt));
      attempt++;
    }
  }

  Future<AppResult<DictionaryResponseDto>> _attempt(String path) async {
    Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(
        path,
        options: Options(
          headers: <String, String>{
            // Courteous and expected by community APIs (DATA-SOURCES.md §1).
            HttpHeaders.userAgentHeader: await _userAgent,
          },
        ),
      );
    } on DioException catch (error, stackTrace) {
      return Err<DictionaryResponseDto, AppFailure>(
        NetworkFailure(
          kind: _kindOf(error),
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } on Object catch (error, stackTrace) {
      return Err<DictionaryResponseDto, AppFailure>(
        NetworkFailure(
          kind: NetworkFailureKind.offline,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }

    final status = response.statusCode ?? 0;

    if (status == 429) {
      return const Err<DictionaryResponseDto, AppFailure>(
        NetworkFailure(kind: NetworkFailureKind.rateLimited, statusCode: 429),
      );
    }
    if (status == 404) {
      return const Err<DictionaryResponseDto, AppFailure>(
        NotFoundFailure(what: 'dictionary entry'),
      );
    }
    if (status < 200 || status >= 300) {
      return Err<DictionaryResponseDto, AppFailure>(
        NetworkFailure(kind: NetworkFailureKind.server, statusCode: status),
      );
    }

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      return const Err<DictionaryResponseDto, AppFailure>(
        NetworkFailure(kind: NetworkFailureKind.malformedResponse),
      );
    }

    try {
      return Ok<DictionaryResponseDto, AppFailure>(
        DictionaryResponseDto.fromJson(data),
      );
    } on Object catch (error, stackTrace) {
      // The API changed shape. Not the user's problem: they get the quiet
      // inline message and carry on typing.
      return Err<DictionaryResponseDto, AppFailure>(
        NetworkFailure(
          kind: NetworkFailureKind.malformedResponse,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Retrying a timeout or a rate limit can help; retrying a malformed
  /// response or a 500 just makes the user wait twice for the same answer.
  bool _isRetryable(NetworkFailureKind kind) =>
      kind == NetworkFailureKind.timeout ||
      kind == NetworkFailureKind.rateLimited ||
      kind == NetworkFailureKind.offline;

  NetworkFailureKind _kindOf(DioException error) => switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => NetworkFailureKind.timeout,
    DioExceptionType.connectionError => NetworkFailureKind.offline,
    DioExceptionType.badResponse => NetworkFailureKind.server,
    // A wildcard rather than an exhaustive list: dio adds exception types
    // between minor versions, and a new one must not stop the app compiling.
    _ => _kindOfUnknown(error),
  };

  /// Classifies the exceptions dio reports as `unknown`.
  ///
  /// Two of them matter and look nothing alike:
  ///
  /// * a [SocketException] means there is no connection - worth one retry;
  /// * a [FormatException] means dio's transformer could not decode the body.
  ///   That is a malformed response, **not** a server error, and retrying it
  ///   just makes the user wait twice for the same unparseable bytes.
  NetworkFailureKind _kindOfUnknown(DioException error) {
    final cause = error.error;
    if (cause is SocketException) return NetworkFailureKind.offline;
    if (cause is FormatException) return NetworkFailureKind.malformedResponse;
    return NetworkFailureKind.server;
  }

  /// Releases the underlying HTTP client.
  void close() => _dio.close();
}
