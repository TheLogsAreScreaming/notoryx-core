/// A MeshCore firmware version such as `v1.18.0`, compared by number.
class FirmwareVersion implements Comparable<FirmwareVersion> {
  const FirmwareVersion(this.major, this.minor, this.patch);

  final int major;
  final int minor;
  final int patch;

  /// Reads the first `1.18` or `v1.18.0` in [text], or null.
  static FirmwareVersion? parse(String? text) {
    if (text == null) return null;
    final m = RegExp(r'v?(\d+)\.(\d+)(?:\.(\d+))?').firstMatch(text);
    if (m == null) return null;
    return FirmwareVersion(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.tryParse(m.group(3) ?? '') ?? 0,
    );
  }

  @override
  int compareTo(FirmwareVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  bool operator <(FirmwareVersion other) => compareTo(other) < 0;

  @override
  bool operator ==(Object other) =>
      other is FirmwareVersion && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => 'v$major.$minor.$patch';
}

/// Picks the newest stable companion firmware from the GitHub releases
/// list of the MeshCore repository (tags like `companion-v1.18.0`).
/// Pre-releases and drafts are skipped. Null when none is found.
FirmwareVersion? latestCompanionRelease(Object? releasesJson) {
  if (releasesJson is! List) return null;
  FirmwareVersion? best;
  for (final r in releasesJson) {
    if (r is! Map) continue;
    if (r['prerelease'] == true || r['draft'] == true) continue;
    final tag = r['tag_name'];
    if (tag is! String || !tag.startsWith('companion-')) continue;
    final v = FirmwareVersion.parse(tag.substring('companion-'.length));
    if (v != null && (best == null || best < v)) best = v;
  }
  return best;
}

/// The official MeshCore web flasher.
const meshCoreFlasherUrl = 'https://flasher.meshcore.io';

/// Where the latest companion release is looked up, only when asked.
const meshCoreReleasesApi =
    'https://api.github.com/repos/meshcore-dev/MeshCore/releases?per_page=30';
