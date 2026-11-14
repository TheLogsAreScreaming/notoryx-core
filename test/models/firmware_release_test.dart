import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/models/firmware_release.dart';

void main() {
  test('parses versions from firmware strings and tags', () {
    expect(FirmwareVersion.parse('v1.18.0'), const FirmwareVersion(1, 18, 0));
    expect(
      FirmwareVersion.parse('1.17 (Oct 2026)'),
      const FirmwareVersion(1, 17, 0),
    );
    expect(
      FirmwareVersion.parse('MeshCore companion v1.16.2-dev'),
      const FirmwareVersion(1, 16, 2),
    );
    expect(FirmwareVersion.parse('unknown'), isNull);
    expect(FirmwareVersion.parse(null), isNull);
  });

  test('compares by number, not text', () {
    expect(
      const FirmwareVersion(1, 9, 0) < const FirmwareVersion(1, 18, 0),
      isTrue,
    );
    expect(
      const FirmwareVersion(1, 18, 1) < const FirmwareVersion(1, 18, 0),
      isFalse,
    );
  });

  test('picks the newest stable companion release', () {
    final releases = [
      {'tag_name': 'repeater-v1.19.0', 'prerelease': false},
      {'tag_name': 'companion-v1.19.0', 'prerelease': true},
      {'tag_name': 'companion-v1.18.0', 'prerelease': false},
      {'tag_name': 'companion-v1.9.4', 'prerelease': false},
      {'tag_name': 'companion-v1.18.1', 'draft': true},
      'junk',
    ];
    expect(latestCompanionRelease(releases), const FirmwareVersion(1, 18, 0));
    expect(latestCompanionRelease({'message': 'rate limited'}), isNull);
    expect(latestCompanionRelease(<Object>[]), isNull);
  });
}
