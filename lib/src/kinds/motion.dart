import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:studio_core/app/services/audio.dart';
import 'package:studio_core/core/rng.dart';

import '../core.dart';
import '../texts.dart';
import '../ui.dart';
import '../words.dart';

// ---------------------------------------------------------------- Harf kaydırma

/// Her sütun bir harf çarkı; orta sıra kelime olunca bulunur.
class SlidePuzzle extends WPuzzle {
  final List<List<String>> cols;
  final List<String> targets;
  final int need;
  const SlidePuzzle(this.cols, this.targets, this.need);
}

class SlideKind extends WordKind {
  @override
  String get id => 'harf-kaydirma';
  const SlideKind();

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final len = lx.fit((d <= 3 ? 4 : (d <= 7 ? 5 : 6)) + (lx.tiled ? 1 : 0));
    final want = 3 + d ~/ 2;
    final pool = lx.pool(len, d);
    if (pool.length < want * 2) return null;
    final targets = <String>[];
    var guard = 0;
    while (targets.length < want && guard++ < 200) {
      final w = r.pick(pool);
      if (!targets.contains(w)) targets.add(w);
    }
    final cols = <List<String>>[];
    for (var i = 0; i < len; i++) {
      final set = <String>[];
      for (final t in targets) {
        if (!set.contains(t[i])) set.add(t[i]);
      }
      while (set.length < 3) {
        final ch = lx.randomLetter(r);
        if (!set.contains(ch)) set.add(ch);
      }
      r.shuffle(set);
      cols.add(set);
    }
    // Bütün olası orta sıra kelimeleri.
    final all = _allWords(cols, lx);
    final need = math.min(all.length, want);
    return SlidePuzzle(cols, all, need);
  }

  static List<String> _allWords(List<List<String>> cols, Lexicon lx) {
    final out = <String>[];
    for (final w in lx.ofLength(cols.length)) {
      var ok = true;
      for (var i = 0; i < cols.length; i++) {
        if (!cols[i].contains(w[i])) {
          ok = false;
          break;
        }
      }
      if (ok) out.add(w);
    }
    return out;
  }

  @override
  bool check(WPuzzle p, Lexicon lx) => p is SlidePuzzle && p.need >= 3 && p.targets.length >= p.need;

  @override
  Widget build(WordPlay play) => _SlideView(play: play);
}

class _SlideView extends StatefulWidget {
  final WordPlay play;
  const _SlideView({required this.play});

  @override
  State<_SlideView> createState() => _SlideViewState();
}

class _SlideViewState extends State<_SlideView> with SecondsTicker, Flash {
  late SlidePuzzle p;
  late List<int> pos;
  final List<String> found = [];
  int hints = 0;

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as SlidePuzzle;
    pos = List<int>.filled(p.cols.length, 0);
    startTicker();
  }

  String get row => [for (var i = 0; i < p.cols.length; i++) p.cols[i][pos[i] % p.cols[i].length]].join();

  void _turn(int c, int dir) {
    if (ended) return;
    setState(() => pos[c] = (pos[c] + dir) % p.cols[c].length);
    play.ctx.sfx(Sfx.tap);
    final w = row;
    if (p.targets.contains(w) && !found.contains(w)) {
      setState(() => found.add(w));
      play.ctx.sfx(Sfx.clear);
      flash(lx.up(w));
      if (found.length >= p.need) {
        ended = true;
        play.ctx.sfx(Sfx.win);
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) {
            play.win(
              score: 300 + found.length * 40 - hints * 40,
              stars: starsFor(hints: hints),
              seconds: seconds,
              hints: hints,
              stats: {'words_found': found.length},
            );
          }
        });
      }
    }
  }

  Future<void> _hint() async {
    if (ended) return;
    final left = p.targets.where((w) => !found.contains(w)).toList();
    if (left.isEmpty) return;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    final w = left.first;
    setState(() {
      hints++;
      // İlk iki sütunu doğru harfe çevir.
      for (var i = 0; i < math.min(2, p.cols.length); i++) {
        pos[i] = p.cols[i].indexOf(w[i]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final n = p.cols.length;
    return Column(children: [
      WordBar(play: play, left: clock(), status: '${kt(play.lang, 'found')}: ${found.length}/${p.need}', onHint: _hint),
      flashLine(),
      Expanded(
        child: LayoutBuilder(builder: (context, box) {
          final t = math.min((box.maxWidth - 30) / n - 8, 64.0);
          return Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var c = 0; c < n; c++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onVerticalDragEnd: (dd) => _turn(c, (dd.primaryVelocity ?? 0) < 0 ? 1 : p.cols[c].length - 1),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(onPressed: () => _turn(c, p.cols[c].length - 1), icon: const Icon(Icons.keyboard_arrow_up)),
                      Opacity(
                        opacity: 0.35,
                        child: LetterTile(letter: lx.upCh(p.cols[c][(pos[c] + p.cols[c].length - 1) % p.cols[c].length]), size: t * 0.8, raised: false),
                      ),
                      const SizedBox(height: 4),
                      LetterTile(letter: lx.upCh(p.cols[c][pos[c] % p.cols[c].length]), size: t, fill: p.targets.contains(row) ? WColors.hit : null),
                      const SizedBox(height: 4),
                      Opacity(
                        opacity: 0.35,
                        child: LetterTile(letter: lx.upCh(p.cols[c][(pos[c] + 1) % p.cols[c].length]), size: t * 0.8, raised: false),
                      ),
                      IconButton(onPressed: () => _turn(c, 1), icon: const Icon(Icons.keyboard_arrow_down)),
                    ]),
                  ),
                ),
            ]),
          );
        }),
      ),
      Panel(child: FoundWords(words: found, lx: lx)),
      const SizedBox(height: 8),
    ]);
  }
}

// ---------------------------------------------------------------- Kelime yapbozu

/// Kelimeler 2-3 harflik parçalara bölünür; parçaları birleştir.
class JigsawPuzzle extends WPuzzle {
  final List<String> words;
  final List<String> pieces;
  const JigsawPuzzle(this.words, this.pieces);
}

class JigsawKind extends WordKind {
  @override
  String get id => 'kelime-yapbozu';
  const JigsawKind();

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final n = 4 + math.min(4, d ~/ 2);
    final words = <String>[];
    var guard = 0;
    while (words.length < n && guard++ < 200) {
      // Taş dillerinde en az üç taşlı kelimeler; parçalar bir ya da iki taş.
      final w = r.pick(lx.tiled ? lx.poolRange(3, math.max(3, lx.fit(7 + d ~/ 3)), d) : lx.poolRange(6, 7 + d ~/ 3, d));
      if (!words.contains(w)) words.add(w);
    }
    if (words.length < n) return null;
    final pieces = <String>[];
    for (final w in words) {
      var i = 0;
      while (i < w.length) {
        int k;
        if (lx.tiled) {
          k = w.length - i <= 2 ? w.length - i : 1 + r.nextInt(2);
        } else {
          k = w.length - i <= 3 ? w.length - i : 2 + r.nextInt(2);
          if (w.length - i - k == 1) k++;
        }
        pieces.add(w.substring(i, i + k));
        i += k;
      }
    }
    r.shuffle(pieces);
    return JigsawPuzzle(words, pieces);
  }

  @override
  bool check(WPuzzle p, Lexicon lx) =>
      p is JigsawPuzzle && p.words.every(lx.has) && p.pieces.join().length == p.words.join().length && p.pieces.every((x) => x.length >= (lx.tiled ? 1 : 2));

  @override
  Widget build(WordPlay play) => _JigsawView(play: play);
}

class _JigsawView extends StatefulWidget {
  final WordPlay play;
  const _JigsawView({required this.play});

  @override
  State<_JigsawView> createState() => _JigsawViewState();
}

class _JigsawViewState extends State<_JigsawView> with SecondsTicker, Flash {
  late JigsawPuzzle p;
  final List<int> picked = [];
  final Set<int> used = {};
  final List<String> found = [];
  int hints = 0;

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as JigsawPuzzle;
    startTicker();
  }

  String get current => picked.map((i) => p.pieces[i]).join();

  void _tap(int i) {
    if (ended || used.contains(i) || picked.contains(i)) return;
    setState(() => picked.add(i));
    play.ctx.sfx(Sfx.tap);
    final w = current;
    if (p.words.contains(w) && !found.contains(w)) {
      setState(() {
        found.add(w);
        used.addAll(picked);
        picked.clear();
      });
      play.ctx.sfx(Sfx.clear);
      if (found.length == p.words.length) {
        ended = true;
        play.ctx.sfx(Sfx.win);
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            play.win(score: 300 + found.length * 40 - hints * 40, stars: starsFor(hints: hints), seconds: seconds, hints: hints, stats: {'words_found': found.length});
          }
        });
      }
    } else if (!p.words.any((x) => x.startsWith(w) && !found.contains(x))) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) setState(picked.clear);
      });
      play.ctx.sfx(Sfx.error);
    }
  }

  Future<void> _hint() async {
    if (ended) return;
    final left = p.words.where((w) => !found.contains(w)).toList();
    if (left.isEmpty) return;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    setState(() {
      hints++;
      picked.clear();
    });
    final w = left.first;
    // Kelimenin ilk parçasını seç.
    for (var i = 0; i < p.pieces.length; i++) {
      if (!used.contains(i) && w.startsWith(p.pieces[i])) {
        _tap(i);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      WordBar(play: play, left: clock(), status: '${kt(play.lang, 'found')}: ${found.length}/${p.words.length}', onHint: _hint),
      flashLine(),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            for (final w in p.words)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (var i = 0; i < w.length; i++)
                    Padding(
                      padding: const EdgeInsets.all(1),
                      child: LetterTile(
                        letter: found.contains(w) ? lx.upCh(w[i]) : '',
                        size: 26,
                        fill: found.contains(w) ? WColors.hit : WColors.paper,
                        raised: false,
                      ),
                    ),
                ]),
              ),
          ]),
        ),
      ),
      Container(
        height: 48,
        alignment: Alignment.center,
        child: Text(current.isEmpty ? ' ' : lx.up(current), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 2)),
      ),
      Panel(
        child: Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
          for (var i = 0; i < p.pieces.length; i++)
            if (!used.contains(i))
              GestureDetector(
                onTap: () => _tap(i),
                child: Opacity(
                  opacity: picked.contains(i) ? 0.35 : 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: WColors.marks[i % WColors.marks.length],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white38),
                    ),
                    child: Text(lx.up(p.pieces[i]),
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: WColors.on(WColors.marks[i % WColors.marks.length]))),
                  ),
                ),
              ),
        ]),
      ),
      TextButton(onPressed: () => setState(picked.clear), child: Text(kt(play.lang, 'clear'))),
    ]);
  }
}

// ---------------------------------------------------------------- Klavye hızı ve düşen harfler

/// Süreli akış: kelimeler belirir (yazma) ya da harfler düşer (kelime kur).
class StreamPuzzle extends WPuzzle {
  final List<String> words;
  final int time;
  final int need;

  /// Düşen harfler türü için harf dizisi.
  final List<String> drops;
  const StreamPuzzle(this.words, this.time, this.need, {this.drops = const []});
}

class TypingKind extends WordKind {
  @override
  final String id;

  /// false: klavye hızı, true: düşen harfler.
  final bool falling;
  const TypingKind(this.id, {this.falling = false});

  /// Klavye hızı Korecede 두벌식 jamo klavyesiyle yazılır; düşen harfler hecelerle.
  @override
  bool get keyed => !falling;

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    if (!falling) {
      final n = 10 + d * 2;
      final words = [for (var i = 0; i < n; i++) r.pick(lx.poolFit(3, 5 + d ~/ 3, d))];
      final time = 70 + d * 4;
      return StreamPuzzle(words, time, (n * 0.8).round());
    }
    // Düşen harfler: hedef kelimelerin harfleri karışık sırayla düşer.
    final words = [for (var i = 0; i < 6 + d; i++) r.pick(lx.poolFit(3, lx.tiled ? 6 : 5, d))];
    final drops = <String>[];
    for (final w in words) {
      final l = w.split('');
      r.shuffle(l);
      drops.addAll(l);
      if (r.chance(0.3)) drops.add(lx.randomLetter(r));
    }
    return StreamPuzzle(words, 0, math.max(3, words.length - 2), drops: drops);
  }

  @override
  bool check(WPuzzle p, Lexicon lx) => p is StreamPuzzle && p.words.every(lx.has) && p.need > 0;

  @override
  Widget build(WordPlay play) => falling ? _FallingView(play: play) : _TypingView(play: play);
}

class _TypingView extends StatefulWidget {
  final WordPlay play;
  const _TypingView({required this.play});

  @override
  State<_TypingView> createState() => _TypingViewState();
}

class _TypingViewState extends State<_TypingView> with SecondsTicker, Flash {
  late StreamPuzzle p;
  int idx = 0, done = 0, mistakes = 0;
  int _poolAt = -1;
  List<String> _poolCache = const [];

  /// Taş dillerinde taş havuzu: bu ve sonraki kelimenin taşları + şaşırtmacalar
  /// (taşlara sırayla hızlı dokunma).
  List<String> get _pool {
    if (!lx.tiled) return const [];
    if (_poolAt == idx) return _poolCache;
    final need = <String>[
      if (idx < p.words.length) ...p.words[idx].split(''),
      if (idx + 1 < p.words.length) ...p.words[idx + 1].split(''),
    ];
    _poolAt = idx;
    return _poolCache = lx.keyPool(need, play.seed ^ idx, size: need.toSet().length + 4);
  }
  String input = '';
  bool started = false;

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as StreamPuzzle;
  }

  @override
  void onTick() {
    if (ended) return;
    if (seconds >= p.time || idx >= p.words.length) _finish();
  }

  void _finish() {
    if (ended) return;
    ended = true;
    if (done >= p.need) {
      play.ctx.sfx(Sfx.win);
      final wpm = seconds == 0 ? 0 : (done * 60 / seconds).round();
      play.win(
        score: done * 30 + wpm * 5 - mistakes * 10,
        stars: mistakes <= 1 ? 3 : (mistakes <= 4 ? 2 : 1),
        seconds: seconds,
        stats: {'words_found': done},
      );
    } else {
      play.ctx.sfx(Sfx.lose);
      play.lose(seconds: seconds, stats: {'words_found': done}, headline: '${kt(play.lang, 'found')}: $done/${p.need}');
    }
  }

  void _key(String ch) {
    if (ended) return;
    if (!started) {
      started = true;
      startTicker();
    }
    final w = p.words[idx];
    final next = input + ch;
    if (!w.startsWith(next)) {
      setState(() => mistakes++);
      play.ctx.sfx(Sfx.error);
      return;
    }
    setState(() => input = next);
    if (input == w) {
      play.ctx.sfx(Sfx.clear);
      setState(() {
        done++;
        idx++;
        input = '';
      });
      if (idx >= p.words.length) _finish();
    } else {
      play.ctx.sfx(Sfx.tap);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = idx < p.words.length ? p.words[idx] : '';
    return Column(children: [
      WordBar(
        play: play,
        left: clock(math.max(0, p.time - seconds)),
        status: '${kt(play.lang, 'found')}: $done/${p.need} · ${kt(play.lang, 'mistakes')}: $mistakes',
      ),
      flashLine(),
      Expanded(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (idx + 1 < p.words.length)
              Text(lx.up(p.words[idx + 1]), style: TextStyle(fontSize: 22, color: WColors.ink.withValues(alpha: 0.35), fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(children: [
                TextSpan(text: lx.up(input), style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: WColors.hit)),
                TextSpan(text: lx.up(w.substring(math.min(input.length, w.length))), style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: WColors.ink)),
              ]),
            ),
            if (!started) Padding(padding: const EdgeInsets.only(top: 12), child: Text(kt(play.lang, 'go'), style: const TextStyle(fontSize: 18))),
          ]),
        ),
      ),
      WordKeyboard(lx: lx, onKey: _key, onEnter: () {}, onBack: () {}, showEnter: false, pool: _pool),
      const SizedBox(height: 6),
    ]);
  }
}

class _FallingView extends StatefulWidget {
  final WordPlay play;
  const _FallingView({required this.play});

  @override
  State<_FallingView> createState() => _FallingViewState();
}

class _Drop {
  final String ch;
  final double x;
  double y;
  _Drop(this.ch, this.x, this.y);
}

class _FallingViewState extends State<_FallingView> with Flash {
  late StreamPuzzle p;
  final List<_Drop> drops = [];
  final List<String> tray = [];
  final List<int> picked = [];
  final List<String> found = [];
  int next = 0, lost = 0, frames = 0;
  bool ended = false;
  Timer? _timer;
  late SeededRandom rng;

  static const trayMax = 8;

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as StreamPuzzle;
    rng = SeededRandom(play.seed ^ 0x77);
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) => _step());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double get speed => 0.006 + play.d * 0.0008;

  void _step() {
    if (ended || !mounted) return;
    frames++;
    setState(() {
      if (frames % 26 == 0 && next < p.drops.length) {
        drops.add(_Drop(p.drops[next++], 0.08 + rng.nextDouble() * 0.84, 0));
      }
      for (final d in drops) {
        d.y += speed;
      }
      final gone = drops.where((d) => d.y > 1).toList();
      lost += gone.length;
      drops.removeWhere((d) => d.y > 1);
    });
    if (next >= p.drops.length && drops.isEmpty) _end();
  }

  void _catch(_Drop d) {
    if (ended || tray.length >= trayMax) return;
    setState(() {
      drops.remove(d);
      tray.add(d.ch);
    });
    play.ctx.sfx(Sfx.tap);
  }

  void _submit() {
    final w = picked.map((i) => tray[i]).join();
    if (w.length < lx.minLen) return flash(kt(play.lang, 'short'));
    if (!lx.has(w)) {
      play.ctx.sfx(Sfx.error);
      return flash(kt(play.lang, 'notWord'));
    }
    final rm = List.of(picked)..sort();
    setState(() {
      for (final i in rm.reversed) {
        tray.removeAt(i);
      }
      picked.clear();
      found.add(w);
    });
    play.ctx.sfx(Sfx.clear);
    if (found.length >= p.need) _end();
  }

  void _end() {
    if (ended) return;
    ended = true;
    _timer?.cancel();
    final secs = frames ~/ 20;
    if (found.length >= p.need) {
      play.ctx.sfx(Sfx.win);
      play.win(score: found.length * 60 - lost * 5, stars: lost <= 3 ? 3 : (lost <= 8 ? 2 : 1), seconds: secs, stats: {'words_found': found.length});
    } else {
      play.ctx.sfx(Sfx.lose);
      play.lose(seconds: secs, stats: {'words_found': found.length}, headline: '${kt(play.lang, 'found')}: ${found.length}/${p.need}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      WordBar(play: play, status: '${kt(play.lang, 'found')}: ${found.length}/${p.need}'),
      flashLine(),
      Expanded(
        child: LayoutBuilder(builder: (context, box) {
          final s = math.min(54.0, box.maxWidth / 8);
          return Stack(children: [
            for (final d in drops)
              Positioned(
                left: d.x * (box.maxWidth - s),
                top: d.y * (box.maxHeight - s),
                child: LetterTile(letter: lx.upCh(d.ch), size: s, onTap: () => _catch(d)),
              ),
          ]);
        }),
      ),
      Panel(
        child: Column(children: [
          Text(picked.isEmpty ? ' ' : lx.up(picked.map((i) => tray[i]).join()), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Wrap(spacing: 4, children: [
            for (var i = 0; i < trayMax; i++)
              i < tray.length
                  ? Opacity(
                      opacity: picked.contains(i) ? 0.3 : 1,
                      child: LetterTile(
                        letter: lx.upCh(tray[i]),
                        size: 38,
                        onTap: picked.contains(i) ? null : () => setState(() => picked.add(i)),
                      ),
                    )
                  : LetterTile(letter: '', size: 38, fill: WColors.paper, raised: false),
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton.filledTonal(onPressed: () => setState(picked.clear), icon: const Icon(Icons.clear)),
            IconButton.filledTonal(
              onPressed: () => setState(() {
                if (tray.isNotEmpty) {
                  tray.removeLast();
                  picked.removeWhere((i) => i >= tray.length);
                }
              }),
              icon: const Icon(Icons.delete_outline),
            ),
            BigButton(label: kt(play.lang, 'submit'), onPressed: _submit),
          ]),
        ]),
      ),
      const SizedBox(height: 6),
    ]);
  }
}
