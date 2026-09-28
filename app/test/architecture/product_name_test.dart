import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The app is called Schwa Notes (M8).
///
/// It was VocabNote until another vocabulary app turned out to use that name.
/// The Dart package, the database file and internal folders keep the old
/// name on purpose - users never see them, and renaming a database file is
/// the kind of change DATABASE.md exists to prevent. What a user *can* see is
/// held here: every UI string, the launcher label, and the store identity.
void main() {
  const name = 'Schwa Notes';
  final oldName = RegExp('vocab ?note', caseSensitive: false);

  test('no UI string still says VocabNote', () {
    final arb = jsonDecode(
      File('lib/core/l10n/app_en.arb').readAsStringSync(),
    ) as Map<String, Object?>;
    final stale = <String>[
      for (final MapEntry(:key, :value) in arb.entries)
        if (!key.startsWith('@') && value is String && oldName.hasMatch(value))
          key,
    ];

    expect(stale, isEmpty);
    expect(arb['appTitle'], name);
  });

  test('the Android launcher label and app ID', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(manifest, contains('android:label="$name"'));
    // Permanent once uploaded to Play.
    expect(
      gradle,
      contains('applicationId = "io.github.hongphuc_pham.schwanotes"'),
    );
    expect(
      File(
        'android/app/src/main/kotlin/io/github/hongphuc_pham/schwanotes/MainActivity.kt',
      ).readAsStringSync(),
      startsWith('package io.github.hongphuc_pham.schwanotes'),
    );
  });

  test('the iOS display name and bundle ID', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    final project = File('ios/Runner.xcodeproj/project.pbxproj')
        .readAsStringSync();

    expect(
      plist,
      contains('<key>CFBundleDisplayName</key>\n\t<string>$name</string>'),
    );
    expect(project, isNot(contains('com.vocabnote')));
    expect(
      project,
      contains(
        'PRODUCT_BUNDLE_IDENTIFIER = io.github.hongphuc-pham.schwanotes;',
      ),
    );
  });
}
