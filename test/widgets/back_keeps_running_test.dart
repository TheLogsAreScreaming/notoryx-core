import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/widgets/back_keeps_running.dart';

void main() {
  Future<int> pumpAndBack(
    WidgetTester tester, {
    required bool connected,
  }) async {
    var moved = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: BackKeepsRunning(
          connected: connected,
          moveToBack: () async {
            moved++;
            return true;
          },
          child: const Text('home'),
        ),
      ),
    );
    await tester.binding.handlePopRoute();
    await tester.pump();
    return moved;
  }

  testWidgets('Back while connected sends the app to the background', (
    tester,
  ) async {
    expect(await pumpAndBack(tester, connected: true), 1);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('Back while not connected behaves normally', (tester) async {
    expect(await pumpAndBack(tester, connected: false), 0);
  });

  testWidgets('a pushed screen still pops normally while connected', (
    tester,
  ) async {
    var moved = 0;
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: key,
        home: BackKeepsRunning(
          connected: true,
          moveToBack: () async {
            moved++;
            return true;
          },
          child: const Text('home'),
        ),
      ),
    );
    key.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const Text('settings')),
    );
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(moved, 0);
  });
}
