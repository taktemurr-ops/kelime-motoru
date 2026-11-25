import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:studio_core/app/services/audio.dart';
import 'package:studio_core/core/rng.dart';

import '../core.dart';
import '../texts.dart';
import '../ui.dart';
import '../words.dart';
import 'bank_base.dart';

/// Harf kümesinden kelime bulma bölümü.
class BankPuzzle extends WPuzzle {
  /// Gösterilen harfler.
  final List<String> letters;

  /// Bulunması gereken kelimeler (tür: hepsi ya da bir kısmı).
  final List<String> targets;

  /// Geçerli bütün kelimeler.
  final List<String> valid;

  /// Gereken sayı / puan.
  final int need;

  /// Süre (saniye, 0 süresiz).
  final int time;

  /// Arı türü: ortadaki harf.
  final String center;
  const BankPuzzle(this.letters, this.targets, this.valid, this.need, this.time, {this.center = ''});
}

/// 0 harf çarkı (bütün hedefler), 1 kelime yığını (süreli, hedef sayı),
/// 2 petek (ortadaki harf şart, puan hedefi).
class BankKind extends WordKind {
  @override
  final String id;
  final int mode;
  const BankKind(this.id, this.mode);

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    switch (mode) {
      case 0:
        if (lx.tiled) {
          // Taş dillerinde raf birkaç kelimenin taşlarından kurulur.
          final rack = tileRack(lx, d <= 3 ? 6 : (d <= 6 ? 7 : 8), d, r);
          final pool = letterCounts(rack.join());
          final valid = spellable(lx, pool, minLen: 2);
          final common = spellable(lx, pool, minLen: 2, limit: 2500 + d * 900);
          final want = math.min(common.length, 4 + d);
          if (want < 3) return null;
          final targets = common.take(want).toList()
            ..sort((a, b) => a.length != b.length ? a.length.compareTo(b.length) : a.compareTo(b));
          return BankPuzzle(rack, targets, valid, targets.length, 0);
        }
        final len = d <= 3 ? 5 : (d <= 6 ? 6 : 7);
        final base = r.pick(lx.pool(len, d));
        final pool = letterCounts(base);
        final limit = 2500 + d * 900;
        final common = spellable(lx, pool, limit: limit);
        if (!common.contains(base)) common.add(base);
        final want = math.min(common.length, 4 + d);
        if (want < 3) return null;
        // En sık kelimeler ve mutlaka taban kelime.
        final targets = <String>[base, ...common.where((w) => w != base).take(want - 1)];
        targets.sort((a, b) => a.length != b.length ? a.length.compareTo(b.length) : a.compareTo(b));
        final valid = spellable(lx, pool);
        return BankPuzzle(scramble(base, r), targets, valid, targets.length, 0);
      case 1:
        if (lx.tiled) {
          final rack = tileRack(lx, d <= 5 ? 7 : 8, d, r);
          final valid = spellable(lx, letterCounts(rack.join()), minLen: 2);
          if (valid.length < 8) return null;
          final need = math.max(4, (valid.length * (0.22 + d * 0.025)).ceil());
          // "Tam kelime" yerine en uzun kelimeler hedeftir.
          final top = valid.fold<int>(0, (a, w) => math.max(a, w.length));
          final longest = valid.where((w) => w.length == top).toList();
          return BankPuzzle(rack, longest, valid, math.min(need, valid.length), 160 - d * 7);
        }
        final len = d <= 5 ? 6 : 7;
        final base = r.pick(lx.pool(len, d));
        final pool = letterCounts(base);
        final valid = spellable(lx, pool);
        if (valid.length < 8) return null;
        final need = math.max(4, (valid.length * (0.22 + d * 0.025)).ceil());
        final fulls = valid.where((w) => w.length == len).toList();
        return BankPuzzle(scramble(base, r), fulls, valid, math.min(need, valid.length), 160 - d * 7);
      default:
        if (lx.tiled) {
          // Taş peteği: ortadaki taşı içeren kelimelerin taşlarından yedi taş
          // (birkaç orta taş denenir).
          for (var attempt = 0; attempt < 6; attempt++) {
            final center = lx.letters[r.nextInt(math.min(40, lx.letters.length))];
            final set = <String>[center];
            for (final w in lx.words.take(6000)) {
              if (set.length >= 7) break;
              if (!w.contains(center) || w.length > 3) continue;
              final add = w.split('').where((c) => !set.contains(c)).toSet();
              if (set.length + add.length <= 7 && r.chance(0.5)) set.addAll(add);
            }
            for (final ch in lx.letters.take(60)) {
              if (set.length >= 7) break;
              if (!set.contains(ch) && r.chance(0.3)) set.add(ch);
            }
            if (set.length < 7) continue;
            r.shuffle(set);
            final pool = {for (final ch in set) ch: 99};
            final valid = spellable(lx, pool, minLen: 2, must: center);
            if (valid.length < 8) continue;
            final maxScore = valid.fold<int>(0, (a, w) => a + beeScore(w, set, true));
            final need = (maxScore * (0.22 + d * 0.035)).round();
            final top = valid.fold<int>(0, (a, w) => math.max(a, w.split('').toSet().length));
            final stars = valid.where((w) => w.split('').toSet().length == top).toList();
            return BankPuzzle(set, stars, valid, math.max(need, 6), 0, center: center);
          }
          return null;
        }
        final cands = <String>[];
        for (final w in lx.words) {
          if (w.length >= 7 && w.length <= 10 && w.split('').toSet().length == 7) cands.add(w);
          if (cands.length > 400) break;
        }
        if (cands.isEmpty) return null;
        final pang = r.pick(cands);
        final set = pang.split('').toSet().toList();
        r.shuffle(set);
        final center = set.first;
        final pool = {for (final ch in set) ch: 99};
        final valid = spellable(lx, pool, minLen: 4, must: center);
        if (valid.length < 8) return null;
        final maxScore = valid.fold<int>(0, (a, w) => a + beeScore(w, set));
        final need = (maxScore * (0.22 + d * 0.035)).round();
        final pangs = valid.where((w) => w.split('').toSet().length == 7).toList();
        return BankPuzzle(set, pangs, valid, math.max(need, 6), 0, center: center);
    }
  }

  @override
  bool check(WPuzzle p, Lexicon lx) {
    if (p is! BankPuzzle) return false;
    final pool = mode == 2 ? {for (final ch in p.letters) ch: 99} : letterCounts(p.letters.join());
    final allOk = p.valid.every((w) => lx.has(w) && canSpell(w, pool));
    if (!allOk) return false;
    if (mode == 0) return p.targets.every(p.valid.contains) && p.targets.isNotEmpty;
    if (mode == 1) return p.targets.isNotEmpty && p.need <= p.valid.length;
    return p.targets.isNotEmpty && p.valid.every((w) => w.contains(p.center));
  }

  @override
  Widget build(WordPlay play) => _BankView(play: play, mode: mode);
}

/// Petek puanı: 4 harf 1, uzun kelime harf sayısı, bütün harfler +7.
int beeScore(String w, List<String> set, [bool tiled = false]) {
  if (tiled) return (w.length == 2 ? 1 : w.length + 1) + (w.split('').toSet().length == set.length ? 7 : 0);
  final base = w.length == 4 ? 1 : w.length;
  return base + (w.split('').toSet().length == set.length ? 7 : 0);
}

class _BankView extends StatefulWidget {
  final WordPlay play;
  final int mode;
  const _BankView({required this.play, required this.mode});

  @override
  State<_BankView> createState() => _BankViewState();
}

class _BankViewState extends State<_BankView> with SecondsTicker, Flash {
  late BankPuzzle p;
  late List<String> letters;
  final List<int> picked = [];
  final List<String> found = [];
  final Map<String, Set<int>> revealed = {};
  int hints = 0;

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as BankPuzzle;
    letters = List.of(p.letters);
    final f = play.resume['f'];
    if (f is List) found.addAll([for (final x in f) '$x']);
    final rv = play.resume['rv'];
    if (rv is Map) {
      rv.forEach((k, v) {
        if (v is List) revealed['$k'] = {for (final x in v) (x as num).toInt()};
      });
    }
    hints = (play.resume['hn'] as num?)?.toInt() ?? 0;
    startTicker((play.resume['s'] as num?)?.toInt() ?? 0);
  }

  void _save() => play.save({
        'f': found,
        'rv': {for (final e in revealed.entries) e.key: e.value.toList()},
        'hn': hints,
        's': seconds,
      });

  int get score => widget.mode == 2 ? found.fold<int>(0, (a, w) => a + beeScore(w, p.letters, lx.tiled)) : found.length;

  bool get goalMet {
    if (widget.mode == 0) return p.targets.every(found.contains);
    if (widget.mode == 1) return found.length >= p.need && found.any((w) => lx.tiled ? p.targets.contains(w) : w.length == p.letters.length);
    return score >= p.need;
  }

  @override
  void onTick() {
    if (ended || p.time == 0) return;
    if (seconds >= p.time) {
      ended = true;
      play.ctx.sfx(Sfx.lose);
      final miss = p.targets.isEmpty ? '' : lx.up(p.targets.first);
      play.lose(seconds: seconds, hints: hints, stats: {'words_found': found.length}, headline: miss.isEmpty ? null : '${kt(play.lang, 'answer')}: $miss');
    }
  }

  void _submit() {
    if (ended) return;
    final w = picked.map((i) => letters[i]).join();
    setState(() => picked.clear());
    final min = lx.tiled ? 2 : (widget.mode == 2 ? 4 : 3);
    if (w.length < min) {
      flash(kt(play.lang, 'short'));
      return;
    }
    if (widget.mode == 2 && !w.contains(p.center)) {
      flash(kt(play.lang, 'center'));
      play.ctx.sfx(Sfx.error);
      return;
    }
    if (found.contains(w)) {
      flash(kt(play.lang, 'already'));
      return;
    }
    if (!p.valid.contains(w)) {
      flash(kt(play.lang, 'notWord'));
      play.ctx.sfx(Sfx.error);
      return;
    }
    setState(() => found.add(w));
    play.ctx.sfx(widget.mode == 0 && !p.targets.contains(w) ? Sfx.coin : Sfx.clear);
    if (widget.mode == 2 && w.split('').toSet().length == 7) flash('★ ${lx.up(w)} ★');
    _save();
    if (goalMet) {
      ended = true;
      play.ctx.sfx(Sfx.win);
      final bonus = widget.mode == 0 ? found.where((x) => !p.targets.contains(x)).length : 0;
      final timeStars = p.time == 0 ? 3 : (seconds < p.time * 0.5 ? 3 : (seconds < p.time * 0.8 ? 2 : 1));
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          play.win(
            score: 200 + found.length * 30 + bonus * 20 - hints * 40,
            stars: math.min(starsFor(hints: hints), timeStars),
            seconds: seconds,
            hints: hints,
            moves: found.length,
            stats: {'words_found': found.length},
          );
        }
      });
    }
  }

  Future<void> _hint() async {
    if (ended) return;
    String? w;
    if (widget.mode == 0) {
      for (final t in p.targets) {
        if (!found.contains(t) && (revealed[t]?.length ?? 0) < t.length - 1) {
          w = t;
          break;
        }
      }
    } else {
      final left = p.valid.where((x) => !found.contains(x)).toList()..sort((a, b) => b.length.compareTo(a.length));
      if (left.isNotEmpty) w = left.first;
    }
    if (w == null) return;
    final word = w;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    setState(() {
      hints++;
      if (widget.mode == 0) {
        final s = revealed.putIfAbsent(word, () => <int>{});
        s.add(s.length);
      }
    });
    if (widget.mode != 0) flash('${lx.up(word.substring(0, math.min(3, word.length)))}…');
    _save();
  }

  Widget _bee(double size) {
    final others = [for (final ch in letters) if (ch != p.center) ch];
    final r = size * 1.05;
    Widget hex(String ch, bool center) {
      final idx = letters.indexOf(ch);
      return GestureDetector(
        onTap: () {
          if (ended) return;
          setState(() => picked.add(idx));
          play.ctx.sfx(Sfx.tap);
        },
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: center ? WColors.near : WColors.tile,
            shape: const StarBorder.polygon(sides: 6, pointRounding: 0.3),
            shadows: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 3, offset: const Offset(0, 2))],
          ),
          child: Text(lx.upCh(ch), style: TextStyle(fontSize: size * 0.42, fontWeight: FontWeight.w800, color: WColors.ink)),
        ),
      );
    }

    return SizedBox(
      width: size + r * 2,
      height: size + r * 2,
      child: Stack(children: [
        for (var i = 0; i < others.length; i++)
          Positioned(
            left: r + math.cos(math.pi / 3 * i - math.pi / 2) * r,
            top: r + math.sin(math.pi / 3 * i - math.pi / 2) * r,
            child: hex(others[i], false),
          ),
        Positioned(left: r, top: r, child: hex(p.center, true)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = play.lang;
    final mode = widget.mode;
    final status = mode == 0
        ? '${kt(lang, 'found')}: ${p.targets.where(found.contains).length}/${p.targets.length}'
        : (mode == 1 ? '${kt(lang, 'found')}: ${found.length}/${p.need}' : '${kt(lang, 'score')}: $score/${p.need}');
    final left = p.time > 0 ? clock(math.max(0, p.time - seconds)) : clock();
    final current = picked.map((i) => letters[i]).join();
    return Column(children: [
      WordBar(play: play, left: left, status: status, onHint: _hint),
      flashLine(),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: mode == 0
              ? WordSlots(lx: lx, targets: p.targets, found: found.toSet(), revealed: revealed)
              : FoundWords(words: found.reversed.toList(), lx: lx, highlight: {for (final w in found) if (w.length >= p.letters.length) w}),
        ),
      ),
      if (mode == 2) ...[
        Container(
          height: 48,
          alignment: Alignment.center,
          child: Text(current.isEmpty ? ' ' : lx.up(current), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 3)),
        ),
        _bee(64),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton.filledTonal(
            tooltip: kt(lang, 'shuffle'),
            onPressed: () => setState(() {
              final c = p.center;
              final rest = letters.where((x) => x != c).toList()..shuffle();
              letters = [c, ...rest];
              picked.clear();
            }),
            icon: const Icon(Icons.shuffle),
          ),
          IconButton.filledTonal(
            tooltip: kt(lang, 'undo'),
            onPressed: () => setState(() {
              if (picked.isNotEmpty) picked.removeLast();
            }),
            icon: const Icon(Icons.backspace_outlined),
          ),
          BigButton(label: kt(lang, 'submit'), icon: Icons.keyboard_return, onPressed: _submit),
        ]),
      ] else
        LetterPad(
          lx: lx,
          letters: letters,
          picked: picked,
          lang: lang,
          onPick: (i) {
            if (ended) return;
            setState(() => picked.add(i));
            play.ctx.sfx(Sfx.tap);
          },
          onBack: () => setState(() {
            if (picked.isNotEmpty) picked.removeLast();
          }),
          onClear: () => setState(picked.clear),
          onShuffle: () => setState(() {
            letters.shuffle();
            picked.clear();
          }),
          onSubmit: _submit,
        ),
      const SizedBox(height: 8),
    ]);
  }
}

/// Anagram yarışı: karışık kelimeleri süre bitmeden çöz.
class AnagramPuzzle extends WPuzzle {
  final List<String> words;
  final List<List<String>> mixed;
  final int time;
  const AnagramPuzzle(this.words, this.mixed, this.time);
}

class AnagramKind extends WordKind {
  @override
  String get id => 'anagram';
  const AnagramKind();

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final n = 5 + d ~/ 2;
    final words = <String>[];
    var guard = 0;
    while (words.length < n && guard++ < 300) {
      // Taş dillerinde en az üç taş (Çincede dört karakterli deyimler de gelir).
      final len = lx.tiled ? math.max(3, lx.fit(6 + r.nextInt(2 + d ~/ 3))) : 4 + r.nextInt(2 + d ~/ 3);
      final pool = lx.pool(len, d);
      if (pool.isEmpty) continue;
      final w = r.pick(pool);
      if (!words.contains(w) && w.split('').toSet().length > 1) words.add(w);
    }
    if (words.length < n) return null;
    return AnagramPuzzle(words, [for (final w in words) scramble(w, r)], words.length * (26 - d));
  }

  @override
  bool check(WPuzzle p, Lexicon lx) => p is AnagramPuzzle && p.words.every(lx.has) && p.words.length == p.mixed.length;

  @override
  Widget build(WordPlay play) => _AnagramView(play: play);
}

class _AnagramView extends StatefulWidget {
  final WordPlay play;
  const _AnagramView({required this.play});

  @override
  State<_AnagramView> createState() => _AnagramViewState();
}

class _AnagramViewState extends State<_AnagramView> with SecondsTicker, Flash {
  late AnagramPuzzle p;
  int idx = 0;
  List<int> picked = [];
  late List<String> letters;
  int hints = 0, mistakes = 0;

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as AnagramPuzzle;
    idx = (play.resume['i'] as num?)?.toInt() ?? 0;
    hints = (play.resume['hn'] as num?)?.toInt() ?? 0;
    letters = List.of(p.mixed[idx.clamp(0, p.words.length - 1)]);
    startTicker((play.resume['s'] as num?)?.toInt() ?? 0);
  }

  void _save() => play.save({'i': idx, 'hn': hints, 's': seconds});

  @override
  void onTick() {
    if (ended) return;
    if (seconds >= p.time) {
      ended = true;
      play.ctx.sfx(Sfx.lose);
      play.lose(seconds: seconds, hints: hints, stats: {'words_found': idx}, headline: '${kt(play.lang, 'answer')}: ${lx.up(p.words[idx])}');
    }
  }

  void _submit() {
    if (ended) return;
    final w = picked.map((i) => letters[i]).join();
    final target = p.words[idx];
    if (w.length != target.length) {
      flash(kt(play.lang, 'short'));
      return;
    }
    if (w != target && !lx.has(w)) {
      setState(() {
        picked = [];
        mistakes++;
      });
      flash(kt(play.lang, 'wrong'));
      play.ctx.sfx(Sfx.error);
      return;
    }
    play.ctx.sfx(Sfx.clear);
    if (idx + 1 >= p.words.length) {
      ended = true;
      play.ctx.sfx(Sfx.win);
      final spare = p.time - seconds;
      play.win(
        score: 200 + spare * 5 - hints * 40,
        stars: math.min(starsFor(hints: hints, mistakes: mistakes), spare > p.time * 0.4 ? 3 : (spare > p.time * 0.15 ? 2 : 1)),
        seconds: seconds,
        hints: hints,
        stats: {'words_found': p.words.length},
      );
      return;
    }
    setState(() {
      idx++;
      picked = [];
      letters = List.of(p.mixed[idx]);
    });
    _save();
  }

  Future<void> _hint() async {
    if (ended) return;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    final target = p.words[idx];
    // Doğru sıradaki ilk harfi yerleştir.
    final cur = picked.map((i) => letters[i]).join();
    setState(() {
      hints++;
      if (!target.startsWith(cur) || picked.length >= target.length) picked = [];
      final want = target[picked.length];
      for (var i = 0; i < letters.length; i++) {
        if (!picked.contains(i) && letters[i] == want) {
          picked.add(i);
          break;
        }
      }
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final lang = play.lang;
    return Column(children: [
      WordBar(play: play, left: clock(math.max(0, p.time - seconds)), status: '${idx + 1}/${p.words.length}', onHint: _hint),
      flashLine(),
      Expanded(
        child: Center(
          child: Wrap(spacing: 6, children: [
            for (var i = 0; i < p.words.length; i++)
              Icon(i < idx ? Icons.check_circle : Icons.circle_outlined, color: i < idx ? WColors.hit : WColors.miss, size: 20),
          ]),
        ),
      ),
      LetterPad(
        lx: lx,
        letters: letters,
        picked: picked,
        lang: lang,
        onPick: (i) {
          if (ended) return;
          setState(() => picked.add(i));
          play.ctx.sfx(Sfx.tap);
          if (picked.length == letters.length) _submit();
        },
        onBack: () => setState(() {
          if (picked.isNotEmpty) picked.removeLast();
        }),
        onClear: () => setState(() => picked = []),
        onShuffle: () => setState(() {
          letters.shuffle();
          picked = [];
        }),
        onSubmit: _submit,
      ),
      const SizedBox(height: 8),
    ]);
  }
}
