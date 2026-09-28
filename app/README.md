# Schwa Notes — Flutter app

The app itself. Product docs, architecture and the binding rules live one level
up in [`../docs/`](../docs/); read [`../docs/RULES.md`](../docs/RULES.md) before
changing anything here.

```bash
flutter pub get
dart run build_runner build          # riverpod, freezed, json, drift
flutter gen-l10n                     # regenerates lib/core/l10n/gen/
flutter run
```

Before pushing — CI runs exactly these:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos --fatal-warnings
flutter test
dart run tool/check_licences.dart
```

Layout follows [`../docs/ARCHITECTURE.md`](../docs/ARCHITECTURE.md) §2 exactly.
The dependency direction `presentation → application → domain ← data` is
enforced by `test/architecture/layer_boundaries_test.dart`, not by a lint —
§3.2 explains why.
