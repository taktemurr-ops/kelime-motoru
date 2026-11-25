import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:studio_core/app/services/audio.dart';
import 'package:studio_core/core/rng.dart';

import '../core.dart';
import '../texts.dart';
import '../ui.dart';
import '../words.dart';

/// Kelime tahmini: [len] harfli gizli kelime(ler), harf geri bildirimiyle.
class GuessPuzzle extends WPuzzle {
  final List<String> answers;
  final int len;
  final int rows;
  final bool hard;
  const GuessPuzzle(this.answers, this.len, this.rows, this.hard);
}

/// 0 yok, 1 yerinde değil, 2 yerinde.
List<int> scoreGuess(String guess, String answer) {
  final n = guess.length;
  final res = List<int>.filled(n, 0);
  final left = <String, int>{};
  for (var i = 0; i < n; i++) {
    if (guess[i] == answer[i]) {
      res[i] = 2;
    } else {
      left[answer[i]] = (left[answer[i]] ?? 0) + 1;
    }
  }
  for (var i = 0; i < n; i++) {
    if (res[i] == 2) continue;
    final c = left[guess[i]] ?? 0;
    if (c > 0) {
      res[i] = 1;
      left[guess[i]] = c - 1;
    }
  }
  return res;
}

class GuessKind extends WordKind {
  @override
  final String id;
  final int len;
  final int boards;
  final bool hard;
  const GuessKind(this.id, {this.len = 5, this.boards = 1, this.hard = false});

  /// Korecede jamo kutuları ve 두벌식 klavye (꼬들 benzeri).
  @override
  bool get keyed => true;

  /// Taş dillerinde kelime boyu: Çincede dört karakterli deyimler (汉兜 benzeri),
  /// öbürlerinde harf boyunun bir fazlasına karşılık gelen taş sayısı.
  int tilesFor(Lexicon lx) {
    if (!lx.tiled) return len;
    if (lx.lang == 'zh') return len <= 4 ? 3 : 4;
    return lx.fit(len + 1);
  }

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final len = tilesFor(lx);
    final pool = lx.pool(len, (d + 1) ~/ 2, minSize: 60);
    if (pool.length < boards * 3) return null;
    final picks = <String>[];
    var guard = 0;
    while (picks.length < boards && guard++ < 200) {
      final w = r.pick(pool);
      if (!picks.contains(w)) picks.add(w);
    }
    if (picks.length < boards) return null;
    final rows = len + 1 + (boards > 1 ? boards + 1 : 0) - (d >= 8 && boards == 1 ? 1 : 0);
    return GuessPuzzle(picks, len, rows, hard);
  }

  @override
  bool check(WPuzzle p, Lexicon lx) {
    if (p is! GuessPuzzle) return false;
    if (p.answers.length != boards || p.answers.toSet().length != boards) return false;
    return p.answers.every((w) => w.length == p.len && lx.has(w)) && p.len == tilesFor(lx) && p.rows >= p.len;
  }

  @override
  Widget build(WordPlay play) => _GuessView(play: play, kind: this);
}

class _GuessView extends StatefulWidget {
  final WordPlay play;
  final GuessKind kind;
  const _GuessView({required this.play, required this.kind});

  @override
  State<_GuessView> createState() => _GuessViewState();
}

class _GuessViewState extends State<_GuessView> with SecondsTicker, Flash {
  late GuessPuzzle p;

  /// Taş dillerinde taş havuzu: yanıtların taşları ve aynı boyda birkaç
  /// "tuzak" kelimenin taşları (geçerli tahminler kurulabilsin diye).
  late final List<String> _pool = () {
    if (!lx.tiled) return const <String>[];
    final r = SeededRandom(play.seed ^ 0x6e55);
    final need = <String>[for (final a in p.answers) ...a.split('')];
    final words = lx.pool(p.len, 3, minSize: 60);
    for (var k = 0; k < (p.answers.length > 2 ? 2 : 3 + p.answers.length) && words.isNotEmpty; k++) {
      need.addAll(r.pick(words).split(''));
    }
    return lx.keyPool(need, play.seed, size: need.toSet().length + 4);
  }();
  final List<String> guesses = [];
  String input = '';
  final Set<int> hintCells = {}; // board*100 + pos
  int hints = 0;

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as GuessPuzzle;
    final g = play.resume['g'];
    if (g is List) guesses.addAll([for (final x in g) '$x']);
    final h = play.resume['h'];
    if (h is List) hintCells.addAll([for (final x in h) (x as num).toInt()]);
    hints = (play.resume['hn'] as num?)?.toInt() ?? 0;
    startTicker((play.resume['s'] as num?)?.toInt() ?? 0);
  }

  void _save() => play.save({'g': guesses, 'h': hintCells.toList(), 'hn': hints, 's': seconds});

  int solvedAt(int b) => guesses.indexOf(p.answers[b]);
  bool solved(int b) => solvedAt(b) >= 0;

  void _key(String ch) {
    if (ended || input.length >= p.len) return;
    setState(() => input += ch);
    play.ctx.sfx(Sfx.tap);
  }

  void _back() {
    if (ended || input.isEmpty) return;
    setState(() => input = input.substring(0, input.length - 1));
  }

  String? _hardViolation(String w) {
    if (!p.hard || guesses.isEmpty) return null;
    for (var b = 0; b < p.answers.length; b++) {
      if (solved(b)) continue;
      for (final g in guesses) {
        final sc = scoreGuess(g, p.answers[b]);
        for (var i = 0; i < p.len; i++) {
          if (sc[i] == 2 && w[i] != g[i]) return lx.upCh(g[i]);
          if (sc[i] == 1 && !w.contains(g[i])) return lx.upCh(g[i]);
        }
      }
      break;
    }
    return null;
  }

  void _enter() {
    if (ended) return;
    if (input.length < p.len) {
      flash(kt(play.lang, 'short'));
      play.ctx.sfx(Sfx.error);
      return;
    }
    if (!lx.has(input)) {
      flash(kt(play.lang, 'notWord'));
      play.ctx.sfx(Sfx.error);
      return;
    }
    final hv = _hardViolation(input);
    if (hv != null) {
      flash('$hv !');
      play.ctx.sfx(Sfx.error);
      return;
    }
    setState(() {
      guesses.add(input);
      input = '';
    });
    play.ctx.sfx(Sfx.place);
    _save();
    final all = [for (var b = 0; b < p.answers.length; b++) solved(b)].every((x) => x);
    if (all) {
      ended = true;
      play.ctx.sfx(Sfx.win);
      final spare = p.rows - guesses.length;
      final stars = math.min(starsFor(hints: hints), spare >= 2 ? 3 : (spare >= 1 ? 2 : 1));
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          play.win(
            score: 200 + spare * 120 - hints * 60,
            stars: stars,
            seconds: seconds,
            moves: guesses.length,
            hints: hints,
            stats: {'words_found': p.answers.length},
          );
        }
      });
    } else if (guesses.length >= p.rows) {
      ended = true;
      play.ctx.sfx(Sfx.lose);
      final ans = [for (final a in p.answers) lx.up(a)].join(', ');
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) play.lose(seconds: seconds, moves: guesses.length, hints: hints, headline: '${kt(play.lang, 'answer')}: $ans');
      });
    }
  }

  Future<void> _hint() async {
    if (ended) return;
    int? cell;
    for (var b = 0; b < p.answers.length && cell == null; b++) {
      if (solved(b)) continue;
      for (var i = 0; i < p.len; i++) {
        final known = guesses.any((g) => g[i] == p.answers[b][i]) || hintCells.contains(b * 100 + i);
        if (!known) {
          cell = b * 100 + i;
          break;
        }
      }
    }
    if (cell == null) return;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    setState(() {
      hintCells.add(cell!);
      hints++;
    });
    _save();
  }

  Map<String, Color> _keyColors() {
    final best = <String, int>{};
    for (var b = 0; b < p.answers.length; b++) {
      if (solved(b)) continue;
      for (final g in guesses) {
        final sc = scoreGuess(g, p.answers[b]);
        for (var i = 0; i < p.len; i++) {
          final cur = best[g[i]];
          final v = sc[i];
          if (cur == null || v > cur) best[g[i]] = v;
        }
      }
    }
    return {for (final e in best.entries) e.key: [WColors.miss, WColors.near, WColors.hit][e.value]};
  }

  Widget _composed(String w, double tile) => SizedBox(
        width: tile * 1.8,
        child: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(lx.up(w), style: TextStyle(fontSize: tile * 0.45, fontWeight: FontWeight.w700, color: WColors.ink)),
          ),
        ),
      );

  Widget _board(int b, double tile) {
    final ans = p.answers[b];
    final stop = solvedAt(b);
    final shown = stop >= 0 ? guesses.sublist(0, stop + 1) : guesses;
    final rows = <Widget>[];
    for (final g in shown) {
      final sc = scoreGuess(g, ans);
      rows.add(Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < p.len; i++)
          Padding(
            padding: const EdgeInsets.all(1.5),
            child: LetterTile(letter: lx.upCh(g[i]), size: tile, fill: [WColors.miss, WColors.near, WColors.hit][sc[i]], raised: false),
          ),
        // Korecede jamo kutularının yanında hecelere birleşmiş yazım.
        if (lx.jamo) _composed(g, tile),
      ]));
    }
    if (stop < 0 && !ended) {
      rows.add(Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < p.len; i++)
          Padding(
            padding: const EdgeInsets.all(1.5),
            child: LetterTile(
              letter: i < input.length ? lx.upCh(input[i]) : (hintCells.contains(b * 100 + i) ? lx.upCh(ans[i]) : ''),
              size: tile,
              fill: i < input.length ? null : (hintCells.contains(b * 100 + i) ? WColors.soft : WColors.paper),
              textColor: i < input.length ? WColors.ink : WColors.miss,
              raised: i < input.length,
            ),
          ),
        if (lx.jamo) _composed(input, tile),
      ]));
      final empty = p.rows - guesses.length - 1;
      for (var k = 0; k < empty && k < 12; k++) {
        rows.add(Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < p.len; i++)
            Padding(padding: const EdgeInsets.all(1.5), child: LetterTile(letter: '', size: tile, fill: WColors.paper.withValues(alpha: 0.55), raised: false)),
          if (lx.jamo) SizedBox(width: tile * 1.8),
        ]));
      }
    }
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: stop >= 0 ? WColors.hit.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = play.lang;
    final n = p.answers.length;
    return Column(children: [
      WordBar(
        play: play,
        left: clock(),
        status: '${kt(lang, 'tries')}: ${p.rows - guesses.length}',
        onHint: _hint,
      ),
      flashLine(),
      Expanded(
        child: LayoutBuilder(builder: (context, box) {
          final cols = n == 1 ? 1 : (n == 2 ? 2 : (n == 4 ? 2 : 4));
          final rowsOfBoards = (n / cols).ceil();
          final perW = (box.maxWidth - 12) / cols;
          final perH = (box.maxHeight - 8) / rowsOfBoards;
          final tile = math.min((perW - 12) / (p.len + (lx.jamo ? 1.8 : 0)) - 3, (perH - 12) / p.rows - 3).clamp(10.0, 58.0);
          return SingleChildScrollView(
            child: Center(
              child: Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: [
                for (var b = 0; b < n; b++) _board(b, tile),
              ]),
            ),
          );
        }),
      ),
      if (hints > 0 && p.answers.length == 1 && lx.reading(p.answers.first) != null)
        Text(lx.reading(p.answers.first)!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: WColors.ink)),
      WordKeyboard(lx: lx, onKey: _key, onEnter: _enter, onBack: _back, colors: _keyColors(), pool: _pool),
      const SizedBox(height: 6),
    ]);
  }
}
