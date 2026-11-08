import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/theme/mesh_theme.dart';
import 'package:meshcore_open/widgets/ember_backdrop.dart';
import 'package:meshcore_open/widgets/tactical_glass_panel.dart';

Widget _app(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: ThemeData.dark(),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: child,
  ),
);

void main() {
  testWidgets('the backdrop paints behind its screen', (tester) async {
    await tester.pumpWidget(
      _app(
        const EmberBackdrop(
          scene: EmberScene.chats,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Text('Chats'),
          ),
        ),
      ),
    );
    expect(find.text('Chats'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is EmberPainter,
      ),
      findsOneWidget,
    );
  });

  test('the backdrop repaints only when its look changes', () {
    EmberPainter painter(EmberScene scene) => EmberPainter(
      scene: scene,
      ground: Colors.black,
      glow: Colors.orange,
      second: Colors.purple,
      contour: Colors.white,
      dark: true,
    );
    expect(
      painter(EmberScene.home).shouldRepaint(painter(EmberScene.home)),
      isFalse,
    );
    expect(
      painter(EmberScene.home).shouldRepaint(painter(EmberScene.nodes)),
      isTrue,
    );
    final glints = EmberPainter(
      scene: EmberScene.home,
      ground: Colors.black,
      glow: Colors.orange,
      second: Colors.purple,
      contour: Colors.white,
      dark: true,
      sparkle: const [Colors.pink, Colors.white],
    );
    expect(glints.shouldRepaint(painter(EmberScene.home)), isTrue);
  });

  testWidgets('only Pink Overload gets sparkle', (tester) async {
    addTearDown(() => MeshPalette.current = BastionTheme.fallback.palette);
    List<Color>? sparkleFor(BastionTheme theme) {
      MeshPalette.current = theme.palette;
      final painter =
          tester
                  .widget<CustomPaint>(
                    find.byWidgetPredicate(
                      (w) => w is CustomPaint && w.painter is EmberPainter,
                    ),
                  )
                  .painter
              as EmberPainter;
      return painter.sparkle;
    }

    for (final theme in BastionTheme.values) {
      MeshPalette.current = theme.palette;
      await tester.pumpWidget(
        _app(EmberBackdrop(key: UniqueKey(), child: const SizedBox())),
      );
      final sparkle = sparkleFor(theme);
      if (theme == BastionTheme.pinkOverload) {
        expect(sparkle, isNotEmpty);
      } else {
        expect(sparkle, isNull, reason: theme.id);
      }
    }
  });

  testWidgets('glass blurs, except with reduced motion', (tester) async {
    await tester.pumpWidget(
      _app(const TacticalGlassPanel(child: Text('Radio'))),
    );
    expect(find.byType(BackdropFilter), findsOneWidget);

    await tester.pumpWidget(
      _app(const TacticalGlassPanel(child: Text('Radio')), reduceMotion: true),
    );
    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.text('Radio'), findsOneWidget);
  });
}
