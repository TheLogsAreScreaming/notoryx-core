import '../connector/meshcore_protocol.dart';

/// Optional radio features the app turns on only with evidence from the
/// radio itself.
enum RadioFeature {
  /// Live radio statistics (companion protocol v8+).
  radioStats,

  /// The text command line over the companion link (v14+).
  textCli,

  /// Channel data packets (v13+).
  channelData,

  /// Signing channel posts with the radio's key: needs channel data and
  /// the radio's public key.
  signedPosts,

  /// Sending raw packets (v13+).
  rawPackets,

  /// Flood corridor commands: custom firmware only. Turned on only after
  /// the radio answers a probe, never because of a version number.
  floodCorridor,
}

enum RadioFeatureStatus { unknown, supported, unsupported }

/// Why the app thinks what it does about a feature.
enum RadioFeatureEvidence {
  /// No radio connected, so nothing is known.
  notConnected,

  /// The companion protocol version the radio reported at connect.
  protocolVersion,

  /// The radio answered a probe command.
  probeAnswered,

  /// The radio replied that the command is unsupported.
  probeRejected,

  /// The probe hasn't been answered yet.
  notChecked,

  /// Built from other features and the radio's key.
  derived,
}

class RadioFeatureCheck {
  const RadioFeatureCheck(
    this.feature,
    this.status,
    this.evidence, {
    this.reportedVersion,
    this.requiredVersion,
  });

  final RadioFeature feature;
  final RadioFeatureStatus status;
  final RadioFeatureEvidence evidence;

  /// For [RadioFeatureEvidence.protocolVersion]: what the radio said and
  /// what the feature needs.
  final int? reportedVersion;
  final int? requiredVersion;

  bool get supported => status == RadioFeatureStatus.supported;
}

/// Lowest companion protocol version for each version-gated feature.
const radioFeatureMinVersion = <RadioFeature, int>{
  RadioFeature.radioStats: 8,
  RadioFeature.textCli: minFirmwareVerCodeForCompanionCli,
  RadioFeature.channelData: 13,
  RadioFeature.rawPackets: minFirmwareVerCodeForRawPacket,
};

/// What the connected radio has shown it supports, and how.
///
/// [verCode] is the companion protocol version the radio reported; null
/// when it didn't. [corridorProbe] is null until the corridor probe is
/// answered. [hasSelfKey] is whether the radio's 32-byte key is known.
List<RadioFeatureCheck> radioFeatureChecks({
  required bool connected,
  int? verCode,
  bool? corridorProbe,
  bool hasSelfKey = false,
}) {
  if (!connected) {
    return [
      for (final f in RadioFeature.values)
        RadioFeatureCheck(
          f,
          RadioFeatureStatus.unknown,
          RadioFeatureEvidence.notConnected,
        ),
    ];
  }
  RadioFeatureCheck byVersion(RadioFeature f) {
    final need = radioFeatureMinVersion[f]!;
    return RadioFeatureCheck(
      f,
      verCode == null
          ? RadioFeatureStatus.unknown
          : verCode >= need
          ? RadioFeatureStatus.supported
          : RadioFeatureStatus.unsupported,
      verCode == null
          ? RadioFeatureEvidence.notChecked
          : RadioFeatureEvidence.protocolVersion,
      reportedVersion: verCode,
      requiredVersion: need,
    );
  }

  final channelData = byVersion(RadioFeature.channelData);
  return [
    byVersion(RadioFeature.radioStats),
    byVersion(RadioFeature.textCli),
    channelData,
    RadioFeatureCheck(
      RadioFeature.signedPosts,
      channelData.status == RadioFeatureStatus.unknown
          ? RadioFeatureStatus.unknown
          : channelData.supported && hasSelfKey
          ? RadioFeatureStatus.supported
          : RadioFeatureStatus.unsupported,
      RadioFeatureEvidence.derived,
    ),
    byVersion(RadioFeature.rawPackets),
    RadioFeatureCheck(
      RadioFeature.floodCorridor,
      switch (corridorProbe) {
        true => RadioFeatureStatus.supported,
        false => RadioFeatureStatus.unsupported,
        null => RadioFeatureStatus.unknown,
      },
      switch (corridorProbe) {
        true => RadioFeatureEvidence.probeAnswered,
        false => RadioFeatureEvidence.probeRejected,
        null => RadioFeatureEvidence.notChecked,
      },
    ),
  ];
}
