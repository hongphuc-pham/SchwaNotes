import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// What the release build asks Android for (M8).
///
/// Flutter's template declares INTERNET only in the debug and profile
/// manifests. Without it in `main`, a release build cannot open a socket, and
/// Look up (F-006) fails as though the phone were offline - which is how it
/// shipped in every release build until M8, found with
/// `aapt dump permissions` on the APK. Debug runs and widget tests cannot see
/// it, so this reads the manifest itself.
void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml')
      .readAsStringSync();

  Set<String> permissions() => <String>{
    for (final match in RegExp(
      r'<uses-permission\s+android:name="([^"]+)"',
    ).allMatches(manifest))
      match.group(1)!,
  };

  test('the release build may use the internet, for Look up (F-006)', () {
    expect(permissions(), contains('android.permission.INTERNET'));
  });

  test('asks for nothing the privacy policy does not name', () {
    // The app's own manifest only. Plugins merge more in at build time
    // (flutter_local_notifications adds VIBRATE), so check the built APK with
    // `aapt dump permissions` whenever a plugin is added.
    expect(permissions(), <String>{
      'android.permission.INTERNET',
      'android.permission.POST_NOTIFICATIONS',
      'android.permission.RECEIVE_BOOT_COMPLETED',
    });
  });
}
