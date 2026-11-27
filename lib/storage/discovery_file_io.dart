import 'dart:io';

import 'package:path_provider/path_provider.dart';

const _fileBaseName = 'discovered_contacts';

String _discoveryFileName(String key) =>
    key.isEmpty ? '$_fileBaseName.json' : '${_fileBaseName}_$key.json';

/// Where the heard-node list is kept, or null when there is no app support
/// folder (tests without the path_provider plugin), so callers fall back to
/// preferences.
Future<String?> discoveryDirectory() async {
  try {
    return (await getApplicationSupportDirectory()).path;
  } on Object {
    return null;
  }
}

/// The saved list, or null when it has never been written.
Future<String?> readDiscoveryFile(String directory, {String key = ''}) async {
  final file = File('$directory/${_discoveryFileName(key)}');
  if (!await file.exists()) return null;
  return file.readAsString();
}

/// Writes to a temporary file and renames it, so a crash mid-write never
/// leaves a half-written list.
Future<void> writeDiscoveryFile(
  String directory,
  String json, {
  String key = '',
}) async {
  final fileName = _discoveryFileName(key);
  await Directory(directory).create(recursive: true);
  final tmp = File('$directory/$fileName.tmp');
  await tmp.writeAsString(json, flush: true);
  await tmp.rename('$directory/$fileName');
}
