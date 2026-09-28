/// Putting an encoded backup where the share sheet can pick it up.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:vocabnote/domain/entities/backup.dart';

/// Writes [bytes] to [folder] as `schwanotes-backup-YYYYMMDD-HHmm.vnb`,
/// named for [now] in local time.
///
/// Earlier exports in [folder] are removed first: each is a full copy of the
/// user's words, and a pile of them in a cache folder helps nobody. Shared by
/// the normal export and the recovery screen's, so both name and tidy the
/// file the same way.
Future<ExportedBackup> writeExport({
  required Directory folder,
  required Uint8List bytes,
  required BackupManifest manifest,
  required DateTime now,
}) async {
  await folder.create(recursive: true);
  await for (final entity in folder.list()) {
    if (entity is File && entity.path.endsWith('.vnb')) await entity.delete();
  }

  final stamp = DateFormat('yyyyMMdd-HHmm').format(now.toLocal());
  final fileName = 'schwanotes-backup-$stamp.vnb';
  final file = File(p.join(folder.path, fileName));
  await file.writeAsBytes(bytes, flush: true);

  return ExportedBackup(
    path: file.path,
    fileName: fileName,
    manifest: manifest,
  );
}
