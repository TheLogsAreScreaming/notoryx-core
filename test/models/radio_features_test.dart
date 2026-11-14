import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/l10n/app_localizations_en.dart';
import 'package:meshcore_open/models/radio_features.dart';
import 'package:meshcore_open/screens/bastion_diagnostics_screen.dart';

RadioFeatureCheck _of(List<RadioFeatureCheck> all, RadioFeature f) =>
    all.firstWhere((c) => c.feature == f);

void main() {
  test('with no radio nothing is claimed', () {
    final all = radioFeatureChecks(connected: false, verCode: 20);
    expect(all.map((c) => c.status), everyElement(RadioFeatureStatus.unknown));
    expect(
      all.map((c) => c.evidence),
      everyElement(RadioFeatureEvidence.notConnected),
    );
  });

  test('version-gated features follow the reported protocol version', () {
    final all = radioFeatureChecks(connected: true, verCode: 13);
    expect(_of(all, RadioFeature.radioStats).supported, isTrue);
    expect(_of(all, RadioFeature.channelData).supported, isTrue);
    expect(_of(all, RadioFeature.rawPackets).supported, isTrue);
    final cli = _of(all, RadioFeature.textCli);
    expect(cli.status, RadioFeatureStatus.unsupported);
    expect(cli.reportedVersion, 13);
    expect(cli.requiredVersion, 14);
  });

  test('a radio that reported no version is unknown, not unsupported', () {
    final all = radioFeatureChecks(connected: true);
    expect(_of(all, RadioFeature.textCli).status, RadioFeatureStatus.unknown);
  });

  test(
    'custom firmware commands need a probe answer, whatever the version',
    () {
      final high = radioFeatureChecks(connected: true, verCode: 99);
      final corridor = _of(high, RadioFeature.floodCorridor);
      expect(corridor.status, RadioFeatureStatus.unknown);
      expect(corridor.evidence, RadioFeatureEvidence.notChecked);
      final rejected = radioFeatureChecks(
        connected: true,
        verCode: 99,
        corridorProbe: false,
      );
      expect(
        _of(rejected, RadioFeature.floodCorridor).evidence,
        RadioFeatureEvidence.probeRejected,
      );
      final answered = radioFeatureChecks(
        connected: true,
        verCode: 1,
        corridorProbe: true,
      );
      expect(_of(answered, RadioFeature.floodCorridor).supported, isTrue);
    },
  );

  test('signed posts need channel data and the radio key', () {
    expect(
      _of(
        radioFeatureChecks(connected: true, verCode: 14),
        RadioFeature.signedPosts,
      ).status,
      RadioFeatureStatus.unsupported,
    );
    expect(
      _of(
        radioFeatureChecks(connected: true, verCode: 14, hasSelfKey: true),
        RadioFeature.signedPosts,
      ).supported,
      isTrue,
    );
    expect(
      _of(
        radioFeatureChecks(connected: true, verCode: 12, hasSelfKey: true),
        RadioFeature.signedPosts,
      ).supported,
      isFalse,
    );
  });

  test('every feature has a name and a reason in words', () {
    final l10n = AppLocalizationsEn();
    for (final c in [
      ...radioFeatureChecks(connected: false),
      ...radioFeatureChecks(connected: true, verCode: 13, corridorProbe: false),
    ]) {
      expect(radioFeatureName(l10n, c.feature), isNotEmpty);
      expect(radioFeatureSummary(l10n, c), contains('.'));
    }
    final cli = _of(
      radioFeatureChecks(connected: true, verCode: 13),
      RadioFeature.textCli,
    );
    expect(
      radioFeatureSummary(l10n, cli),
      'Not supported. Radio reports protocol v13; needs v14.',
    );
  });
}
