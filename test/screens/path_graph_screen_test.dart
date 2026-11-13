import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/models/channel.dart';
import 'package:meshcore_open/models/channel_message.dart';
import 'package:meshcore_open/models/path_graph.dart';
import 'package:meshcore_open/screens/path_graph_screen.dart';
import 'package:meshcore_open/services/path_graph_source.dart';
import 'package:meshcore_open/widgets/network_diagram.dart';
import 'package:meshcore_open/widgets/path_sankey.dart';

ChannelMessage _msg(
  List<int> path, {
  int? width,
  List<List<int>> variants = const [],
  bool outgoing = false,
  Duration age = const Duration(hours: 1),
}) => ChannelMessage(
  senderKey: null,
  senderName: 'Alex',
  text: 'hi',
  timestamp: DateTime.now().subtract(age),
  isOutgoing: outgoing,
  status: ChannelMessageStatus.sent,
  channelIndex: 0,
  pathBytes: Uint8List.fromList(path),
  pathHashWidth: width,
  pathVariants: [for (final v in variants) Uint8List.fromList(v)],
);

final _public = Channel(
  index: 0,
  name: 'Public',
  psk: Uint8List.fromList(List.filled(16, 1)),
);

class _Radio extends MeshCoreConnector {
  @override
  List<Channel> get channels => [_public];
  @override
  Future<List<ChannelMessage>> loadFullChannelHistory(Channel c) async => [
    _msg([0xab, 0x12, 0xcd, 0x34], width: 2),
    _msg([0xef, 0x56, 0xcd, 0x34], width: 2),
    _msg(
      [0xab, 0xcd],
      width: 1,
      variants: [
        [0xef, 0xcd],
      ],
    ),
    _msg([0x11], outgoing: true),
    _msg([0x22, 0x33], width: 1, age: const Duration(days: 30)),
  ];
}

void main() {
  test('a message counts once per distinct path it arrived by', () {
    final paths = pathsOf(
      _msg(
        [0xab, 0xcd],
        width: 1,
        variants: [
          [0xab, 0xcd],
          [0xef, 0xcd],
        ],
      ),
      1,
      'Alex on Public',
    );
    expect(paths.map((p) => p.hops), [
      ['AB', 'CD'],
      ['EF', 'CD'],
    ]);
    expect(pathsOf(_msg([0xab, 0xcd, 0xef], width: 2), 1, 's'), isEmpty);
  });

  test('collects incoming channel paths in the time range', () async {
    final radio = _Radio();
    final week = await collectChannelPaths(
      radio,
      since: DateTime.now().subtract(const Duration(days: 7)),
    );
    expect(week, hasLength(4));
    expect(await collectChannelPaths(radio), hasLength(5));
    radio.dispose();
  });

  test('sankey layout: you on the right, bands stack within boxes', () {
    final graph = PathGraph.build([
      PathObservation(hops: ['AB12', 'CD34'], width: 2, at: _t, source: 's'),
      PathObservation(hops: ['EF56', 'CD34'], width: 2, at: _t, source: 's'),
      PathObservation(hops: ['CD34'], width: 2, at: _t, source: 's'),
    ]);
    final layout = layoutSankey(graph, const Size(300, 200));
    final you = layout.boxes.firstWhere((b) => b.id == pathGraphSelf);
    final cd = layout.boxes.firstWhere((b) => b.id == 'CD34');
    final ab = layout.boxes.firstWhere((b) => b.id == 'AB12');
    expect(you.rect.left, greaterThan(cd.rect.left));
    expect(cd.rect.left, greaterThan(ab.rect.left));
    expect(you.rect.right, lessThanOrEqualTo(300));
    for (final b in layout.boxes) {
      expect(b.rect.bottom, lessThanOrEqualTo(200.001));
    }
    final intoCd = layout.bands.where((b) => b.to == 'CD34').toList();
    expect(intoCd, hasLength(2));
    expect(intoCd[1].y1, closeTo(intoCd[0].y1 + intoCd[0].thickness, 0.001));
    expect(
      layoutSankey(PathGraph.build(const []), const Size(300, 200)).boxes,
      isEmpty,
    );
  });

  test('network layout: you in the middle, repeaters on rings by hops', () {
    final graph = PathGraph.build([
      PathObservation(hops: ['AB12', 'CD34'], width: 2, at: _t, source: 's'),
      PathObservation(hops: ['EF56', 'CD34'], width: 2, at: _t, source: 's'),
      PathObservation(hops: ['CD34'], width: 2, at: _t, source: 's'),
    ]);
    const size = Size(300, 300);
    final layout = layoutNetwork(graph, size);
    final you = layout.dots[pathGraphSelf]!;
    expect(you.center, const Offset(150, 150));
    expect(layout.rings, 2);
    expect(layout.dots['CD34']!.ring, 1);
    expect(layout.dots['AB12']!.ring, 2);
    double r(String id) => (layout.dots[id]!.center - you.center).distance;
    expect(r('CD34'), closeTo(layout.ringGap, 0.001));
    expect(r('AB12'), closeTo(layout.ringGap * 2, 0.001));
    for (final d in layout.dots.values) {
      expect(d.center.dx - d.radius, greaterThanOrEqualTo(0));
      expect(d.center.dx + d.radius, lessThanOrEqualTo(300));
    }
    // CD34 relayed every message, so it's the biggest repeater dot.
    expect(
      layout.dots['CD34']!.radius,
      greaterThan(layout.dots['AB12']!.radius),
    );
    expect(layout.links, hasLength(3));
    expect(layout.hit(layout.dots['AB12']!.center), 'AB12');
    expect(layout.hit(const Offset(-100, -100)), isNull);
    final empty = layoutNetwork(PathGraph.build(const []), size);
    expect(empty.dots.keys, [pathGraphSelf]);
    expect(empty.rings, 0);
  });

  test('network layout keeps only the busiest repeaters', () {
    final graph = PathGraph.build([
      for (var i = 0; i < 30; i++)
        PathObservation(
          hops: [i.toRadixString(16).padLeft(4, '0').toUpperCase(), 'FFEE'],
          width: 2,
          at: _t,
          source: 's',
        ),
    ]);
    final layout = layoutNetwork(graph, const Size(300, 300), maxNodes: 10);
    expect(layout.dots, hasLength(11));
    expect(layout.dots.containsKey('FFEE'), isTrue);
  });

  testWidgets('the screen shows the summary, chart and busiest repeaters', (
    tester,
  ) async {
    final radio = _Radio();
    await tester.pumpWidget(
      ChangeNotifierProvider<MeshCoreConnector>.value(
        value: radio,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PathGraphScreen(),
        ),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(find.text('4 paths heard · 3 repeaters'), findsOneWidget);
    expect(find.byKey(const ValueKey('path-sankey')), findsOneWidget);
    expect(find.text('Busiest repeaters'), findsOneWidget);
    expect(
      find.textContaining('matched to a specific repeater'),
      findsOneWidget,
    );

    // A busiest repeater opens where its traffic comes from and goes.
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pump();
    final first = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('busiest-'),
    );
    await tester.ensureVisible(first.first);
    await tester.tap(first.first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('hop-sheet')), findsOneWidget);
    expect(find.textContaining('Relayed'), findsOneWidget);
  });

  testWidgets('the network view swaps in for the flow chart', (tester) async {
    final radio = _Radio();
    await tester.pumpWidget(
      ChangeNotifierProvider<MeshCoreConnector>.value(
        value: radio,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PathGraphScreen(),
        ),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    await tester.tap(find.text('Network'));
    await tester.pump();
    expect(find.byKey(const ValueKey('path-network')), findsOneWidget);
    expect(find.byKey(const ValueKey('path-sankey')), findsNothing);
    await tester.tap(find.text('Flows'));
    await tester.pump();
    expect(find.byKey(const ValueKey('path-sankey')), findsOneWidget);
  });
}

final _t = DateTime.utc(2026, 10, 16);
