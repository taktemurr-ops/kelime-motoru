import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelime_motoru/kelime_motoru.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studio_core/app/game_api.dart';
import 'package:studio_core/core/game_rules.dart';
import 'package:studio_core/core/level_plan.dart';

/// Ağ yerine bellek içi maç bağlantısı.
class FakeLink implements MatchLink {
  @override
  final int mySeat;
  @override
  final int seed;
  final StreamController<(int, String)> ctrl = StreamController.broadcast();
  final List<String> sent = [];
  @override
  final List<(int, String)> history;
  @override
  final Set<int> dropped = {};
  int? winner;
  FakeLink(this.mySeat, {this.seed = 42, this.history = const []});

  @override
  List<String> get names => const ['A', 'B'];
  @override
  bool get isHost => mySeat == 0;
  @override
  Stream<(int, String)> get moves => ctrl.stream;
  @override
  Future<void> send(String move, {int? asSeat}) async => sent.add(move);
  @override
  Future<void> finish(int winner, {bool? iWon}) async => this.winner = winner;
  void opp(String m) => ctrl.add((mySeat == 0 ? 1 : 0, m));
}

PlayContext onlineCtx(GeneratedLevel gl, FakeLink link, List<RoundResult> results) => PlayContext(
      spec: gl.spec,
      generated: gl,
      resume: const {},
      pieceColors: const [Color(0xFF3E6FB0), Color(0xFFC8553D), Color(0xFF4F9A6E)],
      background: const [Color(0xFF203040), Color(0xFF304050)],
      colorBlind: false,
      reducedMotion: false,
      leftHanded: false,
      lang: 'tr',
      t: (k, [p = const {}]) => k,
      finish: results.add,
      saveResume: (_) {},
      requestHint: () async => true,
      requestBooster: () async => true,
      requestContinue: () async => false,
      sfx: (_) {},
      seats: [for (var i = 0; i < 2; i++) i == link.mySeat ? SeatRole.local : SeatRole.remote],
      match: link,
    );

const rival = ['duello', 'harf-sayi', 'kelime-kurma', 'kelime-zinciri'];

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('rakipli türler iki kişilik, diğerleri tek kişilik', () {
    for (final e in kWordKinds.entries) {
      final r = WordRules(gameId: 'oyun-t-${e.key}', kindFor: (_) => e.value, lang: 'tr');
      expect(r.localPlayers, e.key == 'kelime-kurma' ? 4 : (rival.contains(e.key) ? 2 : 1), reason: e.key);
      expect(r.globalDaily, !rival.contains(e.key), reason: e.key);
    }
  });

  for (final k in rival) {
    for (final seat in const [0, 1]) {
      testWidgets('$k çevrimiçi (koltuk $seat): dil eşlenir, rakip hamleleri işlenir', (tester) async {
        tester.view.physicalSize = const Size(1080, 2280);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(tester.view.reset);
        final rules = WordRules(gameId: 'oyun-o-$k', kindFor: (_) => kWordKinds[k]!, lang: 'tr');
        final planner = LevelPlanner(gameId: rules.gameId, optionalMechanics: const []);
        final gl = rules.build(planner.run(GameModeId.online, 42, difficulty: 4));
        final link = FakeLink(seat);
        final results = <RoundResult>[];
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: SafeArea(child: WordStage(ctx: onlineCtx(gl, link, results), rules: rules))),
        ));
        await tester.pump(const Duration(milliseconds: 300));
        if (seat == 0) {
          expect(link.sent.first, startsWith('L:'));
        } else {
          // Dil gelene kadar bekleme ekranı.
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          link.opp('L:en');
          await tester.pump(const Duration(milliseconds: 300));
          expect(find.byType(CircularProgressIndicator), findsNothing);
        }
        expect(tester.takeException(), isNull);
        // Rakibin olası hamleleri (geçersizler güvenle yok sayılır ya da pas sayılır).
        for (final m in const ['R0:', 'X', 'W:zzzzz', 'R1:12', 'S', 'R2:', 'R3:100']) {
          link.opp(m);
          await tester.pump(const Duration(milliseconds: 200));
          expect(tester.takeException(), isNull);
        }
        // Süreler dolar; rakip koparsa bilgisayar devralır.
        link.dropped.add(seat == 0 ? 1 : 0);
        for (var i = 0; i < 260; i++) {
          await tester.pump(const Duration(seconds: 1));
          final next = find.byIcon(Icons.arrow_forward);
          if (next.evaluate().isNotEmpty) await tester.tap(next.first);
          if (results.isNotEmpty) break;
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 3));
      });
    }
  }

  testWidgets('kelime tahtası: iki cihaz aynı torbadan aynı rafları çeker', (tester) async {
    final rules = WordRules(gameId: 'oyun-o-tahta', kindFor: (_) => kWordKinds['kelime-kurma']!, lang: 'tr');
    final planner = LevelPlanner(gameId: rules.gameId, optionalMechanics: const []);
    final spec = planner.run(GameModeId.online, 7, difficulty: 4);
    final a = rules.build(spec).puzzle;
    final b = rules.build(spec).puzzle;
    expect(a.lang, b.lang);
    expect((a.puzzle as BoardPuzzle).bag, (b.puzzle as BoardPuzzle).bag);
  });
}
