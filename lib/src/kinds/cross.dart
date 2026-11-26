import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:studio_core/app/services/audio.dart';
import 'package:studio_core/core/rng.dart';

import '../clues.dart';
import '../core.dart';
import '../texts.dart';
import '../ui.dart';
import '../words.dart';

/// Izgaraya yerleşmiş bir kelime.
class Slot {
  final String word;
  final int x, y;
  final bool down;
  final String clue;
  const Slot(this.word, this.x, this.y, this.down, this.clue);

  int cellX(int i) => down ? x : x + i;
  int cellY(int i) => down ? y + i : y;
}

/// Kesişen kelime ızgarası.
class CrossPuzzle extends WPuzzle {
  final int w, h;
  final List<Slot> slots;

  /// Hücre harfleri ('' boş, '#' ipucu kutusu).
  final List<String> cells;

  /// Şifreli bulmaca: harf → numara; verilen harfler.
  final Map<String, int> codes;
  final Set<String> givens;

  /// 0 çengel (numaralı ipuçları), 1 kare bulmaca (ipucu kutuları), 2 şifreli.
  final int style;
  const CrossPuzzle(this.w, this.h, this.slots, this.cells, this.style, {this.codes = const {}, this.givens = const {}});

  int idx(int x, int y) => y * w + x;
}

/// Açgözlü yerleşim: kesişmeli, yan yana harf oluşturmayan kelime ızgarası.
class _Builder {
  final Map<int, String> grid = {};
  final Set<int> clueCells = {};
  final List<Slot> slots = [];
  final bool clueBoxes;
  final int maxW, maxH;
  int minX = 0, maxX = 0, minY = 0, maxY = 0;
  _Builder(this.clueBoxes, this.maxW, this.maxH);

  static int key(int x, int y) => (y + 200) * 1000 + (x + 200);
  String at(int x, int y) => grid[key(x, y)] ?? '';
  bool isClue(int x, int y) => clueCells.contains(key(x, y));

  bool fits(String w, int x, int y, bool down) {
    final dx = down ? 0 : 1, dy = down ? 1 : 0;
    final bx = x - dx, by = y - dy, ax = x + dx * w.length, ay = y + dy * w.length;
    if (at(bx, by).isNotEmpty || at(ax, ay).isNotEmpty) return false;
    if (isClue(ax, ay)) return false;
    var cross = 0;
    for (var i = 0; i < w.length; i++) {
      final cx = x + dx * i, cy = y + dy * i;
      if (isClue(cx, cy)) return false;
      final c = at(cx, cy);
      if (c.isNotEmpty) {
        if (c != w[i]) return false;
        cross++;
        continue;
      }
      // Yeni harfin iki yanı boş olmalı.
      if (at(cx + dy, cy + dx).isNotEmpty || at(cx - dy, cy - dx).isNotEmpty) return false;
    }
    if (slots.isNotEmpty && cross == 0) return false;
    if (cross == w.length) return false;
    // Boyut sınırı.
    final nminX = math.min(minX, clueBoxes ? bx : x), nmaxX = math.max(maxX, x + dx * (w.length - 1));
    final nminY = math.min(minY, clueBoxes ? by : y), nmaxY = math.max(maxY, y + dy * (w.length - 1));
    if (slots.isNotEmpty && (nmaxX - nminX + 1 > maxW || nmaxY - nminY + 1 > maxH)) return false;
    return true;
  }

  void put(String w, int x, int y, bool down, String clue) {
    final dx = down ? 0 : 1, dy = down ? 1 : 0;
    for (var i = 0; i < w.length; i++) {
      grid[key(x + dx * i, y + dy * i)] = w[i];
    }
    if (clueBoxes) clueCells.add(key(x - dx, y - dy));
    slots.add(Slot(w, x, y, down, clue));
    final xs = [x, x + dx * (w.length - 1), if (clueBoxes) x - dx];
    final ys = [y, y + dy * (w.length - 1), if (clueBoxes) y - dy];
    if (slots.length == 1) {
      minX = xs.reduce(math.min);
      maxX = xs.reduce(math.max);
      minY = ys.reduce(math.min);
      maxY = ys.reduce(math.max);
    } else {
      minX = math.min(minX, xs.reduce(math.min));
      maxX = math.max(maxX, xs.reduce(math.max));
      minY = math.min(minY, ys.reduce(math.min));
      maxY = math.max(maxY, ys.reduce(math.max));
    }
  }

  /// Kelimeyi mevcut harflerle kesiştirerek yerleştirmeyi dene.
  bool tryPlace(String w, String clue, SeededRandom r) {
    if (slots.isEmpty) {
      put(w, 0, 0, false, clue);
      return true;
    }
    final opts = <List<int>>[];
    for (final s in slots) {
      for (var i = 0; i < s.word.length; i++) {
        for (var j = 0; j < w.length; j++) {
          if (s.word[i] != w[j]) continue;
          final down = !s.down;
          final cx = s.cellX(i), cy = s.cellY(i);
          final x = down ? cx : cx - j, y = down ? cy - j : cy;
          if (fits(w, x, y, down)) opts.add([x, y, down ? 1 : 0]);
        }
      }
    }
    if (opts.isEmpty) return false;
    final o = r.pick(opts);
    put(w, o[0], o[1], o[2] == 1, clue);
    return true;
  }

  CrossPuzzle finish(int style, {Map<String, int> codes = const {}, Set<String> givens = const {}}) {
    final w = maxX - minX + 1, h = maxY - minY + 1;
    final cells = List<String>.filled(w * h, '');
    grid.forEach((k, v) {
      final x = k % 1000 - 200 - minX, y = k ~/ 1000 - 200 - minY;
      cells[y * w + x] = v;
    });
    for (final k in clueCells) {
      final x = k % 1000 - 200 - minX, y = k ~/ 1000 - 200 - minY;
      cells[y * w + x] = '#';
    }
    final norm = [for (final s in slots) Slot(s.word, s.x - minX, s.y - minY, s.down, s.clue)];
    return CrossPuzzle(w, h, norm, cells, style, codes: codes, givens: givens);
  }
}

class CrossKind extends WordKind {
  @override
  final String id;
  final int style;
  const CrossKind(this.id, this.style);

  @override
  List<String>? get contentLangs => style == 2 ? null : kClueLangs;

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    // Taş dillerinde kelimeler 2-4 taş: daha az ve daha kısa kelimeli ızgara.
    final count = lx.tiled ? 5 + d ~/ 3 : 6 + d;
    final maxSide = lx.tiled ? 7 + d ~/ 3 : 9 + d ~/ 2;
    final b = _Builder(style == 1, maxSide, maxSide + 2);
    final List<(String, String)> cands;
    if (style == 2) {
      cands = [for (final w in lx.poolFit(3, 8, d)) (w, '')];
    } else {
      cands = [for (final c in clueList(lx.lang)) if (c.$1.length <= maxSide) c];
    }
    if (cands.length < count * 2) return null;
    final order = List.of(cands);
    r.shuffle(order);
    // İlk kelime uzun olsun.
    final long = lx.tiled ? 3 : 6;
    order.sort((a, b2) => (b2.$1.length >= long ? 1 : 0).compareTo(a.$1.length >= long ? 1 : 0));
    final used = <String>{};
    var tries = 0;
    // Taş dillerinde kesişme az: aday listesi birkaç kez taranır.
    for (var pass = 0; pass < (lx.tiled ? 8 : 1); pass++) {
      for (final c in order) {
        if (b.slots.length >= count || tries++ > (lx.tiled ? 6000 : 900)) break;
        if (used.contains(c.$1)) continue;
        if (b.tryPlace(c.$1, c.$2, r)) used.add(c.$1);
      }
    }
    // Kare bulmacada (ipucu kutulu) taş dillerinde kesişme seyrek: en az dört kelime.
    final least = lx.tiled && style == 1 ? 4 : 5;
    if (b.slots.length < math.max(least, count - (lx.tiled ? 2 : 3))) return null;
    if (style == 2) {
      final letters = <String>[];
      for (final s in b.slots) {
        for (final ch in s.word.split('')) {
          if (!letters.contains(ch)) letters.add(ch);
        }
      }
      r.shuffle(letters);
      final codes = {for (var i = 0; i < letters.length; i++) letters[i]: i + 1};
      final give = math.max(1, 4 - d ~/ 3);
      final givens = letters.take(give).toSet();
      return b.finish(2, codes: codes, givens: givens);
    }
    return b.finish(style);
  }

  @override
  bool check(WPuzzle p, Lexicon lx) {
    if (p is! CrossPuzzle) return false;
    for (final s in p.slots) {
      for (var i = 0; i < s.word.length; i++) {
        final x = s.cellX(i), y = s.cellY(i);
        if (x < 0 || y < 0 || x >= p.w || y >= p.h || p.cells[p.idx(x, y)] != s.word[i]) return false;
      }
      if (style != 2 && s.clue.isEmpty) return false;
      if (style == 2 && !lx.has(s.word)) return false;
      if (style == 1) {
        final bx = s.down ? s.x : s.x - 1, by = s.down ? s.y - 1 : s.y;
        if (bx < 0 || by < 0 || p.cells[p.idx(bx, by)] != '#') return false;
      }
    }
    return p.slots.length >= (lx.tiled && style == 1 ? 4 : 5);
  }

  @override
  Widget build(WordPlay play) => _CrossView(play: play);
}

class _CrossView extends StatefulWidget {
  final WordPlay play;
  const _CrossView({required this.play});

  @override
  State<_CrossView> createState() => _CrossViewState();
}

class _CrossViewState extends State<_CrossView> with SecondsTicker, Flash {
  late CrossPuzzle p;
  late List<String> entry;
  int sel = -1;
  bool down = false;
  int hints = 0;
  final Map<int, String> codeGuess = {}; // şifreli: numara → harf

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as CrossPuzzle;
    entry = List<String>.filled(p.cells.length, '');
    final e = play.resume['e'];
    if (e is List && e.length == entry.length) {
      for (var i = 0; i < e.length; i++) {
        entry[i] = '${e[i]}';
      }
    }
    if (p.style == 2) {
      for (final g in p.givens) {
        codeGuess[p.codes[g]!] = g;
      }
      final cg = play.resume['cg'];
      if (cg is Map) cg.forEach((k, v) => codeGuess[int.parse('$k')] = '$v');
    }
    hints = (play.resume['hn'] as num?)?.toInt() ?? 0;
    // İlk boş harf hücresini seç.
    for (var i = 0; i < p.cells.length; i++) {
      if (_isLetter(i)) {
        sel = i;
        break;
      }
    }
    down = _slotsAt(sel).every((s) => s.down);
    startTicker((play.resume['s'] as num?)?.toInt() ?? 0);
  }

  bool _isLetter(int i) => i >= 0 && p.cells[i].isNotEmpty && p.cells[i] != '#';

  void _save() => play.save({
        'e': entry,
        'cg': {for (final e in codeGuess.entries) '${e.key}': e.value},
        'hn': hints,
        's': seconds,
      });

  String _shown(int i) {
    if (p.style == 2) return codeGuess[p.codes[p.cells[i]]] ?? '';
    return entry[i];
  }

  List<Slot> _slotsAt(int i) {
    if (i < 0) return const [];
    final x = i % p.w, y = i ~/ p.w;
    return [
      for (final s in p.slots)
        if (s.down ? (s.x == x && y >= s.y && y < s.y + s.word.length) : (s.y == y && x >= s.x && x < s.x + s.word.length)) s,
    ];
  }

  Slot? get current {
    final ss = _slotsAt(sel);
    if (ss.isEmpty) return null;
    return ss.firstWhere((s) => s.down == down, orElse: () => ss.first);
  }

  void _tap(int i) {
    if (!_isLetter(i)) return;
    setState(() {
      if (i == sel) {
        final ss = _slotsAt(i);
        if (ss.any((s) => s.down != down)) down = !down;
      } else {
        sel = i;
        final ss = _slotsAt(i);
        if (!ss.any((s) => s.down == down)) down = !down;
      }
    });
  }

  void _advance() {
    final s = current;
    if (s == null) return;
    final x = sel % p.w, y = sel ~/ p.w;
    final k = s.down ? y - s.y : x - s.x;
    for (var j = k + 1; j < s.word.length; j++) {
      final ci = p.idx(s.cellX(j), s.cellY(j));
      if (_shown(ci).isEmpty) {
        sel = ci;
        return;
      }
    }
    if (k + 1 < s.word.length) sel = p.idx(s.cellX(k + 1), s.cellY(k + 1));
  }

  void _key(String ch) {
    if (ended || sel < 0) return;
    setState(() {
      if (p.style == 2) {
        final code = p.codes[p.cells[sel]]!;
        if (p.givens.contains(p.cells[sel])) return;
        codeGuess.removeWhere((k, v) => v == ch && !p.givens.contains(v));
        codeGuess[code] = ch;
      } else {
        entry[sel] = ch;
      }
      _advance();
    });
    play.ctx.sfx(Sfx.tap);
    _save();
    _checkDone();
  }

  void _back() {
    if (ended || sel < 0) return;
    setState(() {
      if (p.style == 2) {
        final code = p.codes[p.cells[sel]]!;
        if (!p.givens.contains(p.cells[sel])) codeGuess.remove(code);
      } else if (entry[sel].isNotEmpty) {
        entry[sel] = '';
      } else {
        final s = current;
        if (s != null) {
          final x = sel % p.w, y = sel ~/ p.w;
          final k = s.down ? y - s.y : x - s.x;
          if (k > 0) {
            sel = p.idx(s.cellX(k - 1), s.cellY(k - 1));
            entry[sel] = '';
          }
        }
      }
    });
    _save();
  }

  bool get solved {
    for (var i = 0; i < p.cells.length; i++) {
      if (_isLetter(i) && _shown(i) != p.cells[i]) return false;
    }
    return true;
  }

  int get wrongFilled {
    var n = 0;
    for (var i = 0; i < p.cells.length; i++) {
      if (_isLetter(i) && _shown(i).isNotEmpty && _shown(i) != p.cells[i]) n++;
    }
    return n;
  }

  bool get full {
    for (var i = 0; i < p.cells.length; i++) {
      if (_isLetter(i) && _shown(i).isEmpty) return false;
    }
    return true;
  }

  void _checkDone() {
    if (solved) {
      ended = true;
      play.ctx.sfx(Sfx.win);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          play.win(
            score: 400 + p.slots.length * 40 - hints * 40,
            stars: starsFor(hints: hints),
            seconds: seconds,
            hints: hints,
            stats: {'words_found': p.slots.length},
          );
        }
      });
    } else if (full) {
      flash('${kt(play.lang, 'mistakes')}: $wrongFilled');
    }
  }

  Future<void> _hint() async {
    if (ended) return;
    var i = sel;
    if (!_isLetter(i) || _shown(i) == p.cells[i]) {
      i = -1;
      for (var k = 0; k < p.cells.length; k++) {
        if (_isLetter(k) && _shown(k) != p.cells[k]) {
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
      if (p.style == 2) {
        final ch = p.cells[cell];
        codeGuess.removeWhere((k, v) => v == ch);
        codeGuess[p.codes[ch]!] = ch;
      } else {
        entry[cell] = p.cells[cell];
      }
    });
    _save();
    _checkDone();
  }

  /// Hücredeki numara (çengel) ya da kod (şifreli).
  String _label(int i) {
    if (p.style == 2) return '${p.codes[p.cells[i]]}';
    if (p.style == 1) return '';
    final x = i % p.w, y = i ~/ p.w;
    final starts = _numbers();
    for (final e in starts.entries) {
      if (e.key == y * p.w + x) return '${e.value}';
    }
    return '';
  }

  Map<int, int>? _numCache;
  Map<int, int> _numbers() {
    if (_numCache != null) return _numCache!;
    final starts = <int>{for (final s in p.slots) p.idx(s.x, s.y)}.toList()..sort();
    return _numCache = {for (var k = 0; k < starts.length; k++) starts[k]: k + 1};
  }

  /// Kare bulmacada ipucu kutusunun ipuçları (→ ve ↓).
  List<Slot> _cluesInBox(int i) {
    final x = i % p.w, y = i ~/ p.w;
    return [
      for (final s in p.slots)
        if ((!s.down && s.x - 1 == x && s.y == y) || (s.down && s.x == x && s.y - 1 == y)) s,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cur = current;
    final clueText = cur == null
        ? ''
        : (p.style == 2 ? '' : (p.style == 0 ? '${_numbers()[p.idx(cur.x, cur.y)]}${cur.down ? '↓' : '→'} ${cur.clue}' : '${cur.down ? '↓' : '→'} ${cur.clue}'));
    final keyColors = <String, Color>{};
    if (p.style == 2) {
      for (final v in codeGuess.values) {
        keyColors[v] = WColors.soft;
      }
    }
    return Column(children: [
      WordBar(play: play, left: clock(), status: '${kt(play.lang, 'found')}: ${_doneSlots()}/${p.slots.length}', onHint: _hint),
      flashLine(),
      Expanded(
        child: LayoutBuilder(builder: (context, box) {
          final cs = math.min((box.maxWidth - 12) / p.w, (box.maxHeight - 8) / p.h).clamp(14.0, 64.0);
          final active = <int>{};
          if (cur != null) {
            for (var k = 0; k < cur.word.length; k++) {
              active.add(p.idx(cur.cellX(k), cur.cellY(k)));
            }
          }
          return InteractiveViewer(
            maxScale: 3,
            child: Center(
              child: SizedBox(
                width: cs * p.w,
                height: cs * p.h,
                child: Stack(children: [
                  for (var i = 0; i < p.cells.length; i++)
                    if (p.cells[i].isNotEmpty)
                      Positioned(
                        left: (i % p.w) * cs,
                        top: (i ~/ p.w) * cs,
                        width: cs,
                        height: cs,
                        child: p.cells[i] == '#' ? _clueBox(i, cs) : _cell(i, cs, active),
                      ),
                ]),
              ),
            ),
          );
        }),
      ),
      if (clueText.isNotEmpty)
        Panel(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(clueText, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white)),
        ),
      WordKeyboard(
        lx: lx,
        onKey: _key,
        onEnter: () => setState(() => down = !down),
        onBack: _back,
        colors: keyColors,
        // Taş dillerinde seçili kelimenin taşları ve şaşırtmacalar (aday havuzu).
        pool: lx.tiled && cur != null ? lx.keyPool(cur.word.split(''), play.seed ^ p.slots.indexOf(cur), size: cur.word.length + 7) : null,
      ),
      const SizedBox(height: 6),
    ]);
  }

  int _doneSlots() {
    var n = 0;
    for (final s in p.slots) {
      var ok = true;
      for (var k = 0; k < s.word.length; k++) {
        if (_shown(p.idx(s.cellX(k), s.cellY(k))) != s.word[k]) ok = false;
      }
      if (ok) n++;
    }
    return n;
  }

  Widget _cell(int i, double cs, Set<int> active) {
    final shown = _shown(i);
    final given = p.style == 2 && p.givens.contains(p.cells[i]);
    final bg = i == sel ? WColors.near : (active.contains(i) ? const Color(0xFFDCE8F5) : WColors.tile);
    final label = _label(i);
    return GestureDetector(
      onTap: () => _tap(i),
      child: Container(
        margin: const EdgeInsets.all(0.5),
        decoration: BoxDecoration(color: bg, border: Border.all(color: WColors.ink.withValues(alpha: 0.55), width: 0.8)),
        child: Stack(children: [
          if (label.isNotEmpty)
            Positioned(left: 2, top: 1, child: Text(label, style: TextStyle(fontSize: cs * 0.24, color: WColors.ink.withValues(alpha: 0.7)))),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: cs * 0.06),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  shown.isEmpty ? '' : lx.upCh(shown),
                  style: TextStyle(fontSize: cs * 0.55, fontWeight: given ? FontWeight.w900 : FontWeight.w700, color: given ? const Color(0xFF2B5A96) : WColors.ink),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _clueBox(int i, double cs) {
    final cl = _cluesInBox(i);
    return GestureDetector(
      onTap: () {
        if (cl.isEmpty) return;
        setState(() {
          sel = p.idx(cl.first.x, cl.first.y);
          down = cl.first.down;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(0.5),
        padding: const EdgeInsets.all(1),
        color: const Color(0xFFE9DCC4),
        child: Column(children: [
          for (final s in cl)
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('${s.clue} ${s.down ? '↓' : '→'}',
                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: WColors.ink)),
              ),
            ),
        ]),
      ),
    );
  }
}
