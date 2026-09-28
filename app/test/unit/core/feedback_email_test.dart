import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/utils/external_links.dart';

/// The feedback email's `mailto:` link (F-072).
///
/// Two ways this goes wrong silently. `Uri(queryParameters:)` encodes a space
/// as `+`, which mail apps show literally (dart-lang/sdk#43838). And a link
/// much past ~2,000 characters is cut off or refused by some mail apps, so an
/// attached error log has to be trimmed to fit.
void main() {
  const to = 'feedback@example.com';

  String query(Uri uri) => uri.toString().split('?').last;

  test('spaces are %20 and new lines %0A, never +', () {
    final uri = FeedbackEmail.uri(
      to: to,
      subject: 'Schwa Notes feedback',
      body: 'App version: 1.0.0\nDevice: Pixel 9',
    );

    expect(query(uri), contains('Schwa%20Notes%20feedback'));
    expect(query(uri), contains('%0A'));
    expect(query(uri), isNot(contains('+')));
  });

  test('the address is the recipient, and the text survives the trip', () {
    final uri = FeedbackEmail.uri(
      to: to,
      subject: 'Hello & welcome',
      body: 'Line one\nˈtʃɜːtʃ',
    );

    expect(uri.scheme, 'mailto');
    expect(uri.path, to);
    final parts = <String, String>{
      for (final pair in query(uri).split('&'))
        pair.split('=').first: Uri.decodeComponent(pair.split('=').last),
    };
    expect(parts['subject'], 'Hello & welcome');
    expect(parts['body'], 'Line one\nˈtʃɜːtʃ');
  });

  group('fitting an error log beside the message', () {
    String line(int i) => '[2026-09-11T03:00:00.000Z] StateError: error $i';

    test('a short log fits whole', () {
      final log = '${line(1)}\n${line(2)}';

      final excerpt = FeedbackEmail.fitLog(
        to: to,
        subject: 'Feedback',
        body: 'Hello',
        log: log,
      );

      expect(excerpt, log);
    });

    test('a long log keeps its newest lines, and the link stays short', () {
      final log = <String>[for (var i = 0; i < 200; i++) line(i)].join('\n');

      final excerpt = FeedbackEmail.fitLog(
        to: to,
        subject: 'Feedback',
        body: 'Hello',
        log: log,
      );
      final uri = FeedbackEmail.uri(
        to: to,
        subject: 'Feedback',
        body: 'Hello\n\n$excerpt',
      );

      expect(excerpt, endsWith(line(199)), reason: 'newest kept');
      expect(excerpt, isNot(contains(line(0))), reason: 'oldest dropped');
      expect(excerpt.split('\n').every((l) => l.startsWith('[')), isTrue);
      expect(uri.toString().length, lessThanOrEqualTo(FeedbackEmail.maxLength));
    });

    test('when nothing fits, nothing is attached', () {
      final excerpt = FeedbackEmail.fitLog(
        to: to,
        subject: 'Feedback',
        body: 'x' * FeedbackEmail.maxLength,
        log: line(1),
      );

      expect(excerpt, isEmpty);
    });
  });

  test("Buy me a coffee goes to the owner's Ko-fi page, over https", () {
    // A tip there unlocks nothing; the link is public and not a secret.
    expect(
      ProjectLinks.support.toString(),
      'https://ko-fi.com/williamphucpham',
    );
  });

  test('GitHub Issues is the project page, over https', () {
    expect(
      ProjectLinks.issues.toString(),
      'https://github.com/hongphuc-pham/SchwaNotes/issues',
    );
  });
}
