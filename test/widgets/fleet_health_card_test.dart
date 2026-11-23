import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/models/fleet.dart';
import 'package:meshcore_open/screens/fleet_screen.dart';

void main() {
  final now = DateTime(2026, 11, 23, 12);

  Future<void> pump(WidgetTester tester, FleetHealth health) =>
      tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FleetHealthCard(
              repeater: FleetRepeater(
                publicKeyHex: 'ab' * 32,
                name: 'Ridge',
                addedAt: now,
              ),
              health: health,
              now: now,
            ),
          ),
        ),
      );

  testWidgets('shows the readings and a Low battery pill', (tester) async {
    await pump(
      tester,
      FleetHealth(
        batteryMv: 3520,
        noiseFloor: -109,
        lastSnr: 7.5,
        uptimeSecs: 90000,
        firmware: 'v1.18.0',
        neighbours: 4,
        lastHeard: now.subtract(const Duration(minutes: 10)),
      ),
    );
    expect(find.text('Ridge'), findsOneWidget);
    expect(find.text('Low battery'), findsOneWidget);
    expect(find.text('3.52 V'), findsOneWidget);
    expect(find.text('-109 dBm'), findsOneWidget);
    expect(find.text('7.5 dB'), findsOneWidget);
    expect(find.text('1 d 1 h'), findsOneWidget);
    expect(find.text('10 min ago'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('says why the last poll failed', (tester) async {
    await pump(
      tester,
      FleetHealth(
        lastPoll: FleetSample(
          at: now.subtract(const Duration(hours: 2)),
          ok: false,
          error: 'no_contact',
        ),
      ),
    );
    expect(find.text('Quiet'), findsOneWidget);
    expect(
      find.text("Last poll: Not in the radio's contacts, 2 h ago"),
      findsOneWidget,
    );
  });
}
