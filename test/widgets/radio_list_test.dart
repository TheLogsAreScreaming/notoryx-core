import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/radio_manager.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:meshcore_open/widgets/radio_list.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _host(RadioManager radios, Widget child) => ChangeNotifierProvider.value(
  value: radios,
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      appBar: AppBar(actions: const [RadioSwitcherButton()]),
      body: SingleChildScrollView(child: child),
    ),
  ),
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
  });
  tearDown(PrefsManager.reset);

  testWidgets('one radio: no switcher, and a radio can be added', (
    tester,
  ) async {
    final radios = RadioManager(MeshCoreConnector());
    await tester.pumpWidget(_host(radios, const RadioListSection()));
    expect(find.byKey(const ValueKey('radio-switcher')), findsNothing);
    expect(find.byKey(const ValueKey('radio-')), findsOneWidget);
    expect(find.text('Radio 1'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('add-radio')));
    await tester.pump();
    expect(radios.radios.length, 2);
    expect(radios.active.slot, 'r2');
    expect(find.text('Radio 2'), findsOneWidget);
    expect(find.byKey(const ValueKey('radio-switcher')), findsOneWidget);
  });

  testWidgets('tapping another radio makes it the one in use', (tester) async {
    final radios = RadioManager(MeshCoreConnector());
    final second = radios.add();
    await tester.pumpWidget(_host(radios, const RadioListSection()));
    expect(radios.active, radios.primary);
    await tester.tap(find.byKey(const ValueKey('radio-r2')));
    await tester.pump();
    expect(radios.active, second);
  });

  testWidgets('no add button at the limit', (tester) async {
    final radios = RadioManager(MeshCoreConnector())
      ..add()
      ..add();
    await tester.pumpWidget(_host(radios, const RadioListSection()));
    expect(find.byKey(const ValueKey('add-radio')), findsNothing);
  });

  testWidgets('the switcher lists every radio', (tester) async {
    final radios = RadioManager(MeshCoreConnector())..add();
    await tester.pumpWidget(_host(radios, const SizedBox()));
    await tester.tap(find.byKey(const ValueKey('radio-switcher')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('radio-')), findsOneWidget);
    expect(find.byKey(const ValueKey('radio-r2')), findsOneWidget);
  });
}
