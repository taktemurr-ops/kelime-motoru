import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:studio_core/app/services/audio.dart';
import 'package:studio_core/core/rng.dart';

import '../clues.dart';
import '../core.dart';
import '../studio_chrome.dart';
import '../texts.dart';
import '../ui.dart';
import '../words.dart';

/// Taş tepsisinden boşluk doldurma bulmacaları için ortak model:
/// satırlar (kelimeler ya da kare), gizli hücreler ve tepsi harfleri.
class FillPuzzle extends WPuzzle {
  /// Her satırın doğru harfleri.
  final List<String> rows;

  /// Gizli hücreler: satır*100 + sütun.
  final List<int> hidden;

  /// 0 eksik harfler (her satır ayrı kelime), 1 kelime karesi (satır ve sütunlar kelime).
  final int mode;
  const FillPuzzle(this.rows, this.hidden, this.mode);

  List<String> get tray => [for (final h in hidden) rows[h ~/ 100][h % 100]];
}

class MissingKind extends WordKind {
  @override
  String get id => 'bosluk-doldurma';
  const MissingKind();

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final n = 4 + math.min(4, d ~/ 2);
    final words = <String>[];
    var guard = 0;
    // Çincede dört karakterli deyimler (成语) boşluk doldurma; öbür taş
    // dillerinde en az üç taşlı kelimeler.
    final src = !lx.tiled
        ? lx.poolRange(5, 6 + d ~/ 3, d)
        : (lx.lang == 'zh' ? lx.pool(4, d) : lx.poolRange(3, math.max(3, lx.fit(6 + d ~/ 3)), d));
    while (words.length < n && guard++ < 200) {
      final w = r.pick(src);
      if (!words.contains(w)) words.add(w);
    }
    if (words.length < n) return null;
    final hidden = <int>[];
    final per = (lx.tiled ? 1 + d ~/ 6 : 1 + d ~/ 4);
    for (var k = 0; k < words.length; k++) {
      final idx = [for (var i = lx.tiled ? 0 : 1; i < words[k].length; i++) i];
      r.shuffle(idx);
      for (final i in idx.take(math.min(per, words[k].length - (lx.tiled ? 1 : 2)))) {
        hidden.add(k * 100 + i);
      }
    }
    return FillPuzzle(words, hidden, 0);
  }

  @override
  bool check(WPuzzle p, Lexicon lx) => p is FillPuzzle && p.rows.every(lx.has) && p.hidden.isNotEmpty;

  @override
  Widget build(WordPlay play) => _FillView(play: play);
}

/// Kelime kafesi: satırları ve sütunları aynı kelimeler olan kare.
class SquareKind extends WordKind {
  @override
  String get id => 'kelime-kafesi';
  const SquareKind();

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    // Taş dillerinde 2×2 ya da 3×3 taş karesi (karakter/hece kelime karesi).
    final n = lx.tiled ? (d <= 2 ? 2 : 3) : (d <= 3 ? 3 : 4);
    final words = lx.ofLength(n);
    final pool = words.sublist(0, math.min(words.length, 2500 + d * 300));
    final byPrefix = <String, List<String>>{};
    for (final w in pool) {
      for (var k = 1; k <= n; k++) {
        byPrefix.putIfAbsent(w.substring(0, k), () => []).add(w);
      }
    }
    final rows = <String>[];
    var budget = 4000;
    bool fill(int i) {
      if (i == n) return true;
      final prefix = [for (var j = 0; j < i; j++) rows[j][i]].join();
      final cands = prefix.isEmpty ? List.of(pool.take(600)) : List.of(byPrefix[prefix] ?? const <String>[]);
      r.shuffle(cands);
      for (final w in cands) {
        if (--budget < 0) return false;
        rows.add(w);
        if (fill(i + 1)) return true;
        rows.removeLast();
      }
      return false;
    }

    if (!fill(0)) return null;
    // Köşegen ve birkaç hücre verilir; geri kalan tepside.
    final hidden = <int>[];
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (x == y) continue;
        if (d <= 2 && (x + y) % 3 == 0) continue;
        hidden.add(y * 100 + x);
      }
    }
    return FillPuzzle(rows, hidden, 1);
  }

  @override
  bool check(WPuzzle p, Lexicon lx) {
    if (p is! FillPuzzle) return false;
    final n = p.rows.length;
    for (var i = 0; i < n; i++) {
      final col = [for (var j = 0; j < n; j++) p.rows[j][i]].join();
      if (!lx.has(p.rows[i]) || !lx.has(col)) return false;
    }
    return true;
  }

  @override
  Widget build(WordPlay play) => _FillView(play: play);
}

class _FillView extends StatefulWidget {
  final WordPlay play;
  const _FillView({required this.play});

  @override
  State<_FillView> createState() => _FillViewState();
}

class _FillViewState extends State<_FillView> with SecondsTicker, Flash {
  late FillPuzzle p;

  /// Gizli hücre → tepsideki taş dizini.
  final Map<int, int> placed = {};
  int? selCell;
  int hints = 0, mistakes = 0;
  late List<String> tray;

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as FillPuzzle;
    tray = p.tray..shuffle();
    selCell = p.hidden.first;
    startTicker();
  }

  String _at(int y, int x) {
    final key = y * 100 + x;
    if (!p.hidden.contains(key)) return p.rows[y][x];
    final t = placed[key];
    return t == null ? '' : tray[t];
  }

  String _row(int y) => [for (var x = 0; x < p.rows[y].length; x++) _at(y, x)].join();

  bool get full => placed.length == p.hidden.length;

  bool _rowOk(int y) {
    final s = _row(y);
    return s.length == p.rows[y].length && lx.has(s);
  }

  bool _colOk(int x) {
    final s = [for (var y = 0; y < p.rows.length; y++) _at(y, x)].join();
    return s.length == p.rows.length && lx.has(s);
  }

  void _tapTile(int t) {
    if (ended || selCell == null || placed.values.contains(t)) return;
    setState(() {
      placed[selCell!] = t;
      final next = p.hidden.where((h) => !placed.containsKey(h)).toList();
      selCell = next.isEmpty ? null : next.first;
    });
    play.ctx.sfx(Sfx.place);
    if (full) _check();
  }

  void _check() {
    final rowsOk = [for (var y = 0; y < p.rows.length; y++) _rowOk(y)].every((x) => x);
    final colsOk = p.mode == 0 || [for (var x = 0; x < p.rows.length; x++) _colOk(x)].every((x) => x);
    if (rowsOk && colsOk) {
      ended = true;
      play.ctx.sfx(Sfx.win);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          play.win(
            score: 300 + p.hidden.length * 20 - hints * 40,
            stars: starsFor(hints: hints, mistakes: mistakes),
            seconds: seconds,
            hints: hints,
            stats: {'words_found': p.rows.length},
          );
        }
      });
    } else {
      setState(() => mistakes++);
      play.ctx.sfx(Sfx.error);
      flash(kt(play.lang, 'wrong'));
    }
  }

  void _tapCell(int key) {
    if (ended) return;
    setState(() {
      if (placed.containsKey(key)) placed.remove(key);
      selCell = key;
    });
  }

  Future<void> _hint() async {
    if (ended) return;
    int? cell;
    for (final h in p.hidden) {
      final t = placed[h];
      if (t == null || tray[t] != p.rows[h ~/ 100][h % 100]) {
        cell = h;
        break;
      }
    }
    if (cell == null) return;
    final c = cell;
    final want = p.rows[c ~/ 100][c % 100];
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    setState(() {
      hints++;
      placed.remove(c);
      // Doğru harfi taşıyan boştaki taşı bul; yoksa başka hücreden al.
      var t = -1;
      for (var i = 0; i < tray.length; i++) {
        if (tray[i] == want && !placed.values.contains(i)) {
          t = i;
          break;
        }
      }
      if (t < 0) {
        final e = placed.entries.firstWhere((e) => tray[e.value] == want);
        placed.remove(e.key);
        t = e.value;
      }
      placed[c] = t;
      final next = p.hidden.where((h) => !placed.containsKey(h)).toList();
      selCell = next.isEmpty ? null : next.first;
    });
    if (full) _check();
  }

  @override
  Widget build(BuildContext context) {
    final used = placed.values.toSet();
    return Column(children: [
      WordBar(
        play: play,
        left: clock(),
        status: '${kt(play.lang, 'letters')}: ${p.hidden.length - placed.length}',
        onHint: _hint,
        actions: [
          IconButton(
            tooltip: kt(play.lang, 'clear'),
            onPressed: () => setState(() {
              placed.clear();
              selCell = p.hidden.first;
            }),
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      flashLine(),
      Expanded(
        child: LayoutBuilder(builder: (context, box) {
          final longest = p.rows.fold<int>(0, (a, w) => math.max(a, w.length));
          final t = math.min((box.maxWidth - 20) / longest - 4, (box.maxHeight - 10) / p.rows.length - 6).clamp(20.0, 60.0);
          return Center(
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                for (var y = 0; y < p.rows.length; y++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      for (var x = 0; x < p.rows[y].length; x++)
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: p.hidden.contains(y * 100 + x)
                              ? LetterTile(
                                  letter: _at(y, x).isEmpty ? '' : lx.upCh(_at(y, x)),
                                  size: t,
                                  fill: selCell == y * 100 + x ? WColors.near : WColors.paper,
                                  selected: selCell == y * 100 + x,
                                  onTap: () => _tapCell(y * 100 + x),
                                )
                              : LetterTile(letter: lx.upCh(p.rows[y][x]), size: t, fill: WColors.soft, raised: false),
                        ),
                    ]),
                  ),
              ]),
            ),
          );
        }),
      ),
      Panel(
        child: Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: [
          for (var i = 0; i < tray.length; i++)
            Opacity(
              opacity: used.contains(i) ? 0.2 : 1,
              child: LetterTile(letter: lx.upCh(tray[i]), size: 42, onTap: used.contains(i) ? null : () => _tapTile(i)),
            ),
        ]),
      ),
      const SizedBox(height: 8),
    ]);
  }
}

// ---------------------------------------------------------------- Kriptogram

class CipherPuzzle extends WPuzzle {
  final String text;
  final Map<String, int> codes;
  final Set<String> givens;
  const CipherPuzzle(this.text, this.codes, this.givens);
}

class CipherKind extends WordKind {
  @override
  String get id => 'kriptogram';
  const CipherKind();

  @override
  List<String>? get contentLangs => kCipherLangs;

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final list = proverbList(lx.lang);
    String text;
    if (lx.tiled) {
      // Taş dillerinde şifre taş düzeyindedir: her hece/karakter/akşara bir numara.
      final enc = <String>[];
      for (final s in list) {
        final ws = [for (final w in sentenceWords(s, lx.lang)) lx.encode(w.replaceAll(RegExp(r'[，。、！？；：“”‘’（）《》,.!?;:]'), ''))];
        if (ws.isEmpty || ws.any((w) => w == null || w.isEmpty)) continue;
        final t = ws.join(' ');
        if (t.replaceAll(' ', '').length >= 6 + d ~/ 3) enc.add(t);
      }
      if (enc.isEmpty) return null;
      text = r.pick(enc);
    } else {
      final pool = [for (final s in list) if (s.length >= 18 + d * 2) s];
      if (pool.isEmpty) return null;
      final s = r.pick(pool);
      text = sentenceWords(s, lx.lang).join(' ');
    }
    final letters = <String>[];
    for (final ch in text.split('')) {
      if (ch != ' ' && !letters.contains(ch)) letters.add(ch);
    }
    final nums = [for (var i = 1; i <= letters.length; i++) i];
    r.shuffle(nums);
    final codes = {for (var i = 0; i < letters.length; i++) letters[i]: nums[i]};
    // Sık harflerden birkaçı verilir.
    final freq = <String, int>{};
    for (final ch in text.split('')) {
      if (ch != ' ') freq[ch] = (freq[ch] ?? 0) + 1;
    }
    final byFreq = freq.keys.toList()..sort((a, b) => freq[b]!.compareTo(freq[a]!));
    final give = math.max(1, 5 - d ~/ 2);
    return CipherPuzzle(text, codes, byFreq.take(give).toSet());
  }

  @override
  bool check(WPuzzle p, Lexicon lx) => p is CipherPuzzle && p.text.split('').where((c) => c != ' ').every(p.codes.containsKey);

  @override
  Widget build(WordPlay play) => _CipherView(play: play);
}

class _CipherView extends StatefulWidget {
  final WordPlay play;
  const _CipherView({required this.play});

  @override
  State<_CipherView> createState() => _CipherViewState();
}

class _CipherViewState extends State<_CipherView> with SecondsTicker, Flash {
  late CipherPuzzle p;

  /// Taş dillerinde taş havuzu: metnin bütün taşları ve benzer şaşırtmacalar.
  late final List<String> _pool = lx.keyPool(p.codes.keys, play.seed, size: p.codes.length + 6);
  final Map<int, String> guess = {};
  int? selCode;
  int hints = 0;

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as CipherPuzzle;
    for (final g in p.givens) {
      guess[p.codes[g]!] = g;
    }
    for (final ch in p.text.split('')) {
      if (ch != ' ' && !p.givens.contains(ch)) {
        selCode = p.codes[ch];
        break;
      }
    }
    startTicker();
  }

  bool get solved => p.codes.entries.every((e) => guess[e.value] == e.key);

  void _key(String ch) {
    final c = selCode;
    if (ended || c == null) return;
    if (p.givens.contains(guess[c])) return;
    setState(() {
      guess.removeWhere((k, v) => v == ch && !p.givens.contains(v));
      guess[c] = ch;
      _nextCode();
    });
    play.ctx.sfx(Sfx.tap);
    _maybeDone();
  }

  void _nextCode() {
    for (final ch in p.text.split('')) {
      if (ch == ' ') continue;
      final c = p.codes[ch]!;
      if (!guess.containsKey(c)) {
        selCode = c;
        return;
      }
    }
  }

  void _maybeDone() {
    if (!solved) {
      if (guess.length == p.codes.length) flash(kt(play.lang, 'wrong'));
      return;
    }
    ended = true;
    play.ctx.sfx(Sfx.win);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        play.win(score: 400 - hints * 50, stars: starsFor(hints: hints), seconds: seconds, hints: hints, stats: {'words_found': p.text.split(' ').length});
      }
    });
  }

  Future<void> _hint() async {
    if (ended) return;
    MapEntry<String, int>? e;
    for (final x in p.codes.entries) {
      if (guess[x.value] != x.key) {
        e = x;
        break;
      }
    }
    if (e == null) return;
    final entry = e;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    setState(() {
      hints++;
      guess.removeWhere((k, v) => v == entry.key);
      guess[entry.value] = entry.key;
      _nextCode();
    });
    _maybeDone();
  }

  @override
  Widget build(BuildContext context) {
    final words = p.text.split(' ');
    final colors = <String, Color>{for (final v in guess.values) v: WColors.soft};
    return Column(children: [
      WordBar(play: play, left: clock(), status: '${kt(play.lang, 'letters')}: ${guess.length}/${p.codes.length}', onHint: _hint),
      flashLine(),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Wrap(spacing: 14, runSpacing: 12, alignment: WrapAlignment.center, children: [
            for (final w in words)
              Row(mainAxisSize: MainAxisSize.min, children: [
                for (final ch in w.split(''))
                  GestureDetector(
                    onTap: () => setState(() => selCode = p.codes[ch]),
                    child: Container(
                      width: lx.tiled ? 40 : 30,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      child: Column(children: [
                        Container(
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selCode == p.codes[ch] ? WColors.near : WColors.tile,
                            borderRadius: BorderRadius.circular(6),
                            border: Border(bottom: BorderSide(color: WColors.ink.withValues(alpha: 0.6), width: 2)),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              guess[p.codes[ch]] == null ? '' : lx.upCh(guess[p.codes[ch]]!),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: p.givens.contains(guess[p.codes[ch]]) ? const Color(0xFF2B5A96) : WColors.ink,
                              ),
                            ),
                          ),
                        ),
                        Text('${p.codes[ch]}', style: const TextStyle(fontSize: 11, color: kStudioSubtle)),
                      ]),
                    ),
                  ),
              ]),
          ]),
        ),
      ),
      WordKeyboard(
        lx: lx,
        onKey: _key,
        onEnter: _nextCode,
        onBack: () => setState(() {
          final c = selCode;
          if (c != null && !p.givens.contains(guess[c])) guess.remove(c);
        }),
        colors: colors,
        pool: _pool,
      ),
      const SizedBox(height: 6),
    ]);
  }
}

// ---------------------------------------------------------------- Kelime sudoku

class WordokuPuzzle extends WPuzzle {
  final int n, bw, bh;
  final String word;
  final List<int> solution; // 0..n-1 harf dizini
  final List<bool> given;
  const WordokuPuzzle(this.n, this.bw, this.bh, this.word, this.solution, this.given);
}

int countSudoku(List<int> g, int n, int bw, int bh, {int limit = 2}) {
  var count = 0;
  bool okAt(int i, int v) {
    final x = i % n, y = i ~/ n;
    for (var k = 0; k < n; k++) {
      if (g[y * n + k] == v || g[k * n + x] == v) return false;
    }
    final bx = x - x % bw, by = y - y % bh;
    for (var yy = by; yy < by + bh; yy++) {
      for (var xx = bx; xx < bx + bw; xx++) {
        if (g[yy * n + xx] == v) return false;
      }
    }
    return true;
  }

  void solve() {
    if (count >= limit) return;
    var best = -1, bestCnt = n + 1;
    for (var i = 0; i < n * n; i++) {
      if (g[i] >= 0) continue;
      var c = 0;
      for (var v = 0; v < n; v++) {
        if (okAt(i, v)) c++;
      }
      if (c < bestCnt) {
        best = i;
        bestCnt = c;
        if (c == 0) return;
      }
    }
    if (best < 0) {
      count++;
      return;
    }
    for (var v = 0; v < n; v++) {
      if (okAt(best, v)) {
        g[best] = v;
        solve();
        g[best] = -1;
        if (count >= limit) return;
      }
    }
  }

  solve();
  return count;
}

/// Taş dillerinde ilk satırı oluşturan kelimelerin taş sayıları.
List<int> wordokuParts(int n) => n == 4 ? const [4] : (n == 6 ? const [3, 3] : const [3, 3, 3]);

class WordokuKind extends WordKind {
  @override
  String get id => 'kelime-sudoku';
  const WordokuKind();

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final n = d <= 3 ? 4 : (d <= 6 ? 6 : 9);
    final bw = n == 4 ? 2 : (n == 6 ? 3 : 3), bh = n == 4 ? 2 : (n == 6 ? 2 : 3);
    final String word;
    if (lx.tiled) {
      // Taş dillerinde dokuz/altı taşlı kelime yok: ilk satır art arda 3 ya da
      // 2 taşlı kelimelerden oluşur (4'lükte tek dört taşlı kelime), taşlar farklı.
      final parts = wordokuParts(n);
      final seq = <String>[];
      var guard = 0;
      while (seq.length < parts.length && guard++ < 400) {
        final pool = lx.pool(parts[seq.length], d);
        if (pool.isEmpty) return null;
        final w = r.pick(pool.take(1500).toList());
        final all = seq.join() + w;
        if (all.split('').toSet().length == all.length) seq.add(w);
      }
      if (seq.length < parts.length) return null;
      word = seq.join();
    } else {
      final cands = [for (final w in lx.ofLength(n)) if (w.split('').toSet().length == n) w];
      if (cands.isEmpty) return null;
      word = r.pick(cands.take(400).toList());
    }
    // Temel desen: (bh*(y%bh) + y~/bh + x) % n; satır ve sütun karıştırma.
    List<int> base = [for (var y = 0; y < n; y++) for (var x = 0; x < n; x++) (bw * (y % bh) + y ~/ bh + x) % n];
    final perm = [for (var i = 0; i < n; i++) i];
    r.shuffle(perm);
    base = [for (final v in base) perm[v]];
    // İlk satır kelimeyi versin: değerleri ilk satır sırasına göre yeniden adlandır.
    final first = base.sublist(0, n);
    final rename = {for (var i = 0; i < n; i++) first[i]: i};
    final sol = [for (final v in base) rename[v]!];
    final given = List<bool>.filled(n * n, true);
    final order = [for (var i = n; i < n * n; i++) i];
    r.shuffle(order);
    final g = List.of(sol);
    final keep = (n * n * (0.62 - d * 0.03)).round();
    var givenCount = n * n;
    for (final i in order) {
      if (givenCount <= keep) break;
      final save = g[i];
      g[i] = -1;
      if (countSudoku(List.of(g), n, bw, bh) == 1) {
        given[i] = false;
        givenCount--;
      } else {
        g[i] = save;
      }
    }
    // İlk satır gizli (kelime çözülünce görünür).
    for (var i = 0; i < n; i++) {
      final save = g[i];
      g[i] = -1;
      if (countSudoku(List.of(g), n, bw, bh) == 1) {
        given[i] = false;
      } else {
        g[i] = save;
      }
    }
    return WordokuPuzzle(n, bw, bh, word, sol, given);
  }

  @override
  bool check(WPuzzle p, Lexicon lx) {
    if (p is! WordokuPuzzle) return false;
    final g = [for (var i = 0; i < p.n * p.n; i++) p.given[i] ? p.solution[i] : -1];
    if (countSudoku(g, p.n, p.bw, p.bh) != 1 || p.word.split('').toSet().length != p.n) return false;
    if (!lx.tiled) return lx.has(p.word);
    var i = 0;
    for (final k in wordokuParts(p.n)) {
      if (!lx.has(p.word.substring(i, i + k))) return false;
      i += k;
    }
    return true;
  }

  @override
  Widget build(WordPlay play) => _WordokuView(play: play);
}

class _WordokuView extends StatefulWidget {
  final WordPlay play;
  const _WordokuView({required this.play});

  @override
  State<_WordokuView> createState() => _WordokuViewState();
}

class _WordokuViewState extends State<_WordokuView> with SecondsTicker, Flash {
  late WordokuPuzzle p;
  late List<int> cells;
  int sel = -1, hints = 0;

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as WordokuPuzzle;
    cells = [for (var i = 0; i < p.n * p.n; i++) p.given[i] ? p.solution[i] : -1];
    sel = cells.indexOf(-1);
    startTicker();
  }

  bool _conflict(int i) {
    final v = cells[i];
    if (v < 0) return false;
    final n = p.n, x = i % n, y = i ~/ n;
    for (var k = 0; k < n; k++) {
      if (k != x && cells[y * n + k] == v) return true;
      if (k != y && cells[k * n + x] == v) return true;
    }
    final bx = x - x % p.bw, by = y - y % p.bh;
    for (var yy = by; yy < by + p.bh; yy++) {
      for (var xx = bx; xx < bx + p.bw; xx++) {
        final j = yy * n + xx;
        if (j != i && cells[j] == v) return true;
      }
    }
    return false;
  }

  void _put(int v) {
    if (ended || sel < 0 || p.given[sel]) return;
    setState(() => cells[sel] = v);
    play.ctx.sfx(Sfx.tap);
    if (!cells.contains(-1)) {
      final ok = [for (var i = 0; i < cells.length; i++) !_conflict(i)].every((x) => x);
      if (ok) {
        ended = true;
        play.ctx.sfx(Sfx.win);
        flash('★ ${lx.up(p.word)} ★');
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) play.win(score: 400 - hints * 40, stars: starsFor(hints: hints), seconds: seconds, hints: hints, stats: {'words_found': 1});
        });
      } else {
        flash(kt(play.lang, 'mistakes'));
      }
    }
  }

  Future<void> _hint() async {
    if (ended) return;
    var i = sel;
    if (i < 0 || p.given[i] || cells[i] == p.solution[i]) {
      i = -1;
      for (var k = 0; k < cells.length; k++) {
        if (!p.given[k] && cells[k] != p.solution[k]) {
          i = k;
          break;
        }
      }
    }
    if (i < 0) return;
    final cell = i;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    setState(() {
      hints++;
      sel = cell;
    });
    _put(p.solution[cell]);
  }

  @override
  Widget build(BuildContext context) {
    final n = p.n;
    return Column(children: [
      WordBar(play: play, left: clock(), status: '${n}×$n', onHint: _hint),
      flashLine(),
      Expanded(
        child: LayoutBuilder(builder: (context, box) {
          final cs = math.min((box.maxWidth - 20) / n, (box.maxHeight - 10) / n);
          return Center(
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: WColors.ink, width: 2)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                for (var y = 0; y < n; y++)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    for (var x = 0; x < n; x++)
                      GestureDetector(
                        onTap: () => setState(() => sel = y * n + x),
                        child: Container(
                          width: cs,
                          height: cs,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: sel == y * n + x
                                ? WColors.near
                                : (y == 0 ? const Color(0xFFFFF1D6) : (((x ~/ p.bw) + (y ~/ p.bh)).isEven ? WColors.tile : const Color(0xFFEFE7DA))),
                            border: Border(
                              right: BorderSide(color: WColors.ink, width: (x + 1) % p.bw == 0 ? 1.6 : 0.4),
                              bottom: BorderSide(color: WColors.ink, width: (y + 1) % p.bh == 0 ? 1.6 : 0.4),
                            ),
                          ),
                          child: Text(
                            cells[y * n + x] < 0 ? '' : lx.upCh(p.word[cells[y * n + x]]),
                            style: TextStyle(
                              fontSize: cs * 0.5,
                              fontWeight: p.given[y * n + x] ? FontWeight.w900 : FontWeight.w600,
                              color: _conflict(y * n + x) ? WColors.warm : (p.given[y * n + x] ? WColors.ink : WColors.accent),
                            ),
                          ),
                        ),
                      ),
                  ]),
              ]),
            ),
          );
        }),
      ),
      Panel(
        child: Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: [
          for (final v in [for (var i = 0; i < n; i++) i]..sort((a, b) => p.word[a].compareTo(p.word[b])))
            LetterTile(letter: lx.upCh(p.word[v]), size: 40, onTap: () => _put(v)),
          IconButton.filledTonal(
            onPressed: () => setState(() {
              if (sel >= 0 && !p.given[sel]) cells[sel] = -1;
            }),
            icon: const Icon(Icons.backspace_outlined),
          ),
        ]),
      ),
      const SizedBox(height: 8),
    ]);
  }
}
