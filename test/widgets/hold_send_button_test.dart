import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Holding Send opens the scheduler, so the button's tooltip must not take
// the long press for itself.
void main() {
  testWidgets('a long press reaches a button that has a tooltip', (t) async {
    var held = 0;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IconButton.filled(
            tooltip: 'Send',
            icon: const Icon(Icons.send),
            onPressed: () {},
            onLongPress: () => held++,
          ),
        ),
      ),
    );
    await t.longPress(find.byIcon(Icons.send));
    await t.pumpAndSettle();
    expect(held, 1);
  });
}
