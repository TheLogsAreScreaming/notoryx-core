/// Web build: there is no file system, so heard nodes stay in preferences.
Future<String?> discoveryDirectory() async => null;

Future<String?> readDiscoveryFile(String directory, {String key = ''}) async =>
    null;

Future<void> writeDiscoveryFile(
  String directory,
  String json, {
  String key = '',
}) async {}
