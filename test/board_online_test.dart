import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelime_motoru/kelime_motoru.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studio_core/app/game_api.dart';
import 'package:studio_core/core/game_rules.dart';
import 'package:studio_core/core/global_daily.dart';
import 'package:studio_core/core/level_plan.dart';
import 'package:studio_core/core/rng.dart';

/// Ağ yerine bellek içi, N koltuklu maç bağlantısı (bütün cihazlar aynı günlüğü görür).
class FakeTable {
  final List<(int, String)> log = [];
  final List<FakeSeatLink> links = [];
  final Set<int> dropped = {};
}

class FakeSeatLink implements MatchLink {
  final FakeTable t;
  @override
  final int mySeat;
  @override
  final int seed;
  @override
  final List<String> names;
  final StreamController<(int, String)> ctrl = StreamController.broadcast();
  @override
  final List<(int, String)> history;
  int? winner;
  FakeSeatLink(this.t, this.mySeat, this.names, {this.seed = 42}) : history = List.of(t.log) {
    t.links.add(this);
  }

  @override
  bool get isHost => mySeat == 0 || t.dropped.contains(0) && mySeat == 1;
  @override
  Set<int> get dropped => t.dropped;
  @override
  Stream<(int, String)> get moves => ctrl.stream;
  @override
  Future<void> send(String move, {int? asSeat}) async {
    final e = (asSeat ?? mySeat, move);
    t.log.add(e);
    for (final l in List.of(t.links)) {
      if (l != this) l.ctrl.add(e);
    }
  }

  @override
  Future<void> finish(int winner, {bool? iWon}) async => this.winner = winner;
}

PlayContext ctxFor(GeneratedLevel gl, {FakeSeatLink? link, List<SeatRole> seats = const [], required List<RoundResult> out}) =>
    PlayContext(
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
      finish: out.add,
      saveResume: (_) {},
      requestHint: () async => true,
      requestBooster: () async => true,
      requestContinue: () async => false,
      sfx: (_) {},
      seats: seats,
      match: link,
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final kind = kWordKinds['kelime-kurma']!;
  final lx = kind.lexicon('tr');
  BoardPuzzle puzzle(int seed) => realize(kind, 'tr', 4, seed) as BoardPuzzle;

  group('BoardGame (2–4 kişi, itiraz, pas)', () {
    test('kurallar: 2–4 kişilik masa, Günün Bulmacası dışı', () {
      final r = WordRules(gameId: 'oyun-kelime-kurma-tahtasi', kindFor: (_) => kind, lang: 'tr');
      expect(r.localPlayers, 4);
      expect(r.onlineSeatChoices, [2, 3, 4]);
      expect(r.globalDaily, isFalse);
      final single = WordRules(gameId: 'oyun-anagram', kindFor: (_) => kWordKinds['anagram']!, lang: 'tr');
      expect(single.globalDaily, isTrue);
      expect(single.dailyPerLanguage, isTrue);
      final a = single.globalDailySpec('2026-11-26'), b = single.globalDailySpec('2026-11-26');
      expect(a.seed, b.seed);
      expect(a.seed, GlobalDaily.seed('oyun-anagram', '2026-11-26'));
      expect(single.build(a).validation.ok, isTrue);
    });

    test('dört koltuk: her cihazda aynı raflar, sıra döner, paslarla biter', () {
      final p = puzzle(11);
      final a = BoardGame(BoardRules(lx), p, 4), b = BoardGame(BoardRules(lx), p, 4);
      for (var i = 0; i < 4; i++) {
        expect(a.racks[i], b.racks[i]);
        expect(a.racks[i].length, 7);
      }
      expect(a.bag.length, p.bag.length - 28);
      expect(a.apply(1, 'X'), isNull, reason: 'sırası gelmeyen hamle yok sayılır');
      for (var k = 0; k < 8; k++) {
        expect(a.cur, k % 4);
        expect(a.apply(a.cur, 'X'), isNotNull);
      }
      expect(a.over, isTrue);
      expect(a.winner, -1);
    });

    test('geçerli kelimeye itiraz: itiraz eden sırasını kaybeder', () {
      final g = BoardGame(BoardRules(lx), puzzle(21), 2);
      final moves = g.rules.movesFor(g.board, g.racks[0]);
      expect(moves, isNotEmpty);
      final r = g.apply(0, BoardGame.encode(moves.first.tiles))!;
      expect(r.$1, 'P');
      expect(g.scores[0], moves.first.score);
      expect(g.canChallenge(1), isTrue);
      expect(g.apply(1, 'C')!.$1, 'C-');
      expect(g.cur, 0, reason: 'itiraz eden 1. koltuk sırasını kaybetti');
      expect(g.scores[0], moves.first.score);
      expect(g.canChallenge(1), isFalse);
    });

    test('sözlükte olmayan kelime: itiraz haklı, hamle geri alınır, torba eski haline döner', () {
      final g = BoardGame(BoardRules(lx), puzzle(33), 3);
      final rack = List.of(g.racks[0]);
      final bagBefore = List.of(g.bag);
      // Raftan sözlükte olmayan iki harflik bir dizi bul (ortadan geçer).
      Map<int, String>? tiles;
      for (var i = 0; i < rack.length && tiles == null; i++) {
        for (var j = 0; j < rack.length && tiles == null; j++) {
          if (i != j && !lx.has(rack[i] + rack[j])) tiles = {60: rack[i], 61: rack[j]};
        }
      }
      expect(tiles, isNotNull);
      final r = g.apply(0, BoardGame.encode(tiles!))!;
      expect(r.$1, 'P', reason: 'çevrimiçi/aynı cihazda itiraz edilene kadar tahtada kalır');
      expect(g.lastInvalid, isNotEmpty);
      // Bilgisayar sırası gelince haksız kelimeye itiraz eder.
      expect(g.botMove(SeededRandom(1), 5), 'C');
      final c = g.apply(1, 'C')!;
      expect(c.$1, 'C+');
      expect(g.board[60], isEmpty);
      expect(g.board[61], isEmpty);
      expect(g.scores[0], 0);
      expect(g.racks[0]..sort(), rack..sort());
      expect(g.bag, bagBefore);
      expect(g.cur, 1, reason: 'itiraz eden sırasını korur');
      expect(g.apply(1, 'X'), isNotNull);
      expect(g.cur, 2);
    });

    test('aynı hamle günlüğü her cihazda aynı sonuca varır (bot oyunu)', () {
      final p = puzzle(44);
      final a = BoardGame(BoardRules(lx), p, 3);
      final rng = SeededRandom(9);
      var guard = 0;
      while (!a.over && guard++ < 200) {
        a.apply(a.cur, a.botMove(rng, 6));
      }
      expect(a.over, isTrue);
      final b = BoardGame(BoardRules(lx), p, 3);
      for (final (s, m) in a.history) {
        expect(b.apply(s, m), isNotNull);
      }
      expect(b.scores, a.scores);
      expect(b.board, a.board);
      expect(b.winner, a.winner);
    });
  });

  testWidgets('çevrimiçi 3 kişilik masa: hamleler paylaşılır, kopanın yerine ev sahibi oynar, geri dönüş', (tester) async {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final rules = WordRules(gameId: 'oyun-kelime-kurma-tahtasi', kindFor: (_) => kind, lang: 'tr');
    final planner = LevelPlanner(gameId: rules.gameId, optionalMechanics: const []);
    final gl = rules.build(planner.run(GameModeId.online, 42, difficulty: 4));
    final t = FakeTable();
    const names = ['A', 'B', 'C'];
    // Ev sahibi (0) ekranda; 1 ve 2 uzak oyuncu.
    final host = FakeSeatLink(t, 0, names);
    final out = <RoundResult>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: SafeArea(
              child: WordStage(
                  ctx: ctxFor(gl, link: host, out: out, seats: const [SeatRole.local, SeatRole.remote, SeatRole.remote]),
                  rules: rules))),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(t.log.first.$2, startsWith('L:'));
    // Ev sahibi pas geçer; uzak 1 pas; uzak 2 koparsa ev sahibi onun yerine oynar.
    await tester.tap(find.text(kt('tr', 'pass')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(t.log.last, (0, 'X'));
    final remote1 = FakeSeatLink(t, 1, names);
    await remote1.send('X');
    await tester.pump(const Duration(milliseconds: 200));
    t.dropped.add(2);
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(t.log.where((e) => e.$1 == 2).length, greaterThanOrEqualTo(1), reason: 'bot devraldı');
    expect(tester.takeException(), isNull);
    // Yarıda kalan maça başka bir cihazda geri dönüş: günlük yeniden uygulanır.
    final back = FakeSeatLink(t, 1, names);
    final out2 = <RoundResult>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: SafeArea(
              child: WordStage(
                  ctx: ctxFor(gl, link: back, out: out2, seats: const [SeatRole.remote, SeatRole.local, SeatRole.remote]),
                  rules: rules))),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.text(kt('tr', 'challenge')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('aynı cihazda 3 kişi: sıradaki dokununca raf görünür, sonuçta kazanan koltuk bildirilir', (tester) async {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final rules = WordRules(gameId: 'oyun-kelime-kurma-tahtasi', kindFor: (_) => kind, lang: 'tr');
    final planner = LevelPlanner(gameId: rules.gameId, optionalMechanics: const []);
    final gl = rules.build(planner.run(GameModeId.versus, 3, difficulty: 4));
    final out = <RoundResult>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: SafeArea(
              child: WordStage(ctx: ctxFor(gl, out: out, seats: List.filled(3, SeatRole.local)), rules: rules))),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    final ready = find.textContaining(kt('tr', 'tapReady'));
    // 3 kişi × 2 tur pas = 6 puansız hamle → oyun biter.
    for (var k = 0; k < 6; k++) {
      expect(ready, findsOneWidget);
      await tester.tap(ready);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text(kt('tr', 'pass')));
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(seconds: 2));
    expect(out, hasLength(1));
    expect(out.single.winnerSeat, -1);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}
