import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:studio_core/app/services/audio.dart';
import 'package:studio_core/core/rng.dart';

import '../core.dart';
import '../texts.dart';
import '../ui.dart';
import '../words.dart';

/// Önek ağacı (komşu harf yollarında kelime aramak için).
class Trie {
  final Map<String, Trie> next = {};
  bool end = false;

  static Trie of(Iterable<String> words) {
    final root = Trie();
    for (final w in words) {
      var t = root;
      for (final ch in w.split('')) {
        t = t.next.putIfAbsent(ch, () => Trie());
      }
      t.end = true;
    }
    return root;
  }
}

final Map<String, Trie> _tries = {};
Trie trieFor(Lexicon lx) => _tries[lx.jamo ? 'ko#jamo' : lx.lang] ??= Trie.of(lx.words.where((w) => w.length <= 9));

List<int> gridNeighbors(int i, int w, int h) {
  final x = i % w, y = i ~/ w;
  return [
    for (var dy = -1; dy <= 1; dy++)
      for (var dx = -1; dx <= 1; dx++)
        if ((dx != 0 || dy != 0) && x + dx >= 0 && y + dy >= 0 && x + dx < w && y + dy < h) (y + dy) * w + x + dx,
  ];
}

/// Izgaradaki bütün kelimeler (komşu hücre yolları, hücre tekrar yok).
Set<String> solveGrid(List<String> g, int w, int h, Trie root, {int minLen = 3}) {
  final out = <String>{};
  final used = List<bool>.filled(g.length, false);
  void dfs(int i, Trie t, String acc) {
    final nt = t.next[g[i]];
    if (nt == null) return;
    final s = acc + g[i];
    if (nt.end && s.length >= minLen) out.add(s);
    used[i] = true;
    for (final n in gridNeighbors(i, w, h)) {
      if (!used[n] && g[n].isNotEmpty) dfs(n, nt, s);
    }
    used[i] = false;
  }

  for (var i = 0; i < g.length; i++) {
    if (g[i].isNotEmpty) dfs(i, root, '');
  }
  return out;
}

/// Kelimenin ızgaradaki komşu yolu (yoksa boş).
List<int> findPath(List<String> g, int w, int h, String word) {
  final used = List<bool>.filled(g.length, false);
  final route = <int>[];
  bool dfs(int i, int k) {
    if (g[i] != word[k]) return false;
    route.add(i);
    if (k == word.length - 1) return true;
    used[i] = true;
    for (final n in gridNeighbors(i, w, h)) {
      if (!used[n] && dfs(n, k + 1)) return true;
    }
    used[i] = false;
    route.removeLast();
    return false;
  }

  for (var i = 0; i < g.length; i++) {
    if (dfs(i, 0)) return route;
  }
  return const [];
}

/// Kelime puanı; taş dillerinde boy taş sayısıdır (iki taş 3 harf gibi sayılır).
int boggleScore(String w, [bool tiled = false]) {
  switch (w.length + (tiled ? 1 : 0)) {
    case 3:
    case 4:
      return 1;
    case 5:
      return 2;
    case 6:
      return 3;
    case 7:
      return 5;
    default:
      return 11;
  }
}

/// Harf ızgarası: komşu harflerden kelime, süre içinde hedef puan.
class BogglePuzzle extends WPuzzle {
  final int n;
  final List<String> grid;
  final List<String> words;
  final int need;
  final int time;
  const BogglePuzzle(this.n, this.grid, this.words, this.need, this.time);
}

class BoggleKind extends WordKind {
  @override
  String get id => 'harf-izgarasi';
  const BoggleKind();

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final n = d <= 4 ? 4 : (d <= 8 ? 5 : 6);
    final g = lx.tiled ? _seededGrid(lx, n, d, r) : [for (var i = 0; i < n * n; i++) lx.randomLetter(r)];
    final words = solveGrid(g, n, n, trieFor(lx), minLen: lx.minLen).toList()..sort();
    if (words.length < (lx.tiled ? 6 + n : 10 + n * 2)) return null;
    final total = words.fold<int>(0, (a, w) => a + boggleScore(w, lx.tiled));
    final need = math.max(6, (total * (0.10 + d * 0.025)).round());
    return BogglePuzzle(n, g, words, need, 150 + n * 15);
  }

  /// Taş dillerinde rastgele taşlar nadiren kelime kurar: ızgaraya önce birkaç
  /// sık kelime komşu yollar halinde yerleştirilir, kalan hücreler sık
  /// kelimelerin taşlarıyla doldurulur.
  static List<String> _seededGrid(Lexicon lx, int n, int d, SeededRandom r) {
    final g = List<String>.filled(n * n, '');
    final common = lx.letters.take(150 + d * 15).toSet();
    final pool = [for (final w in lx.poolRange(2, 4, d)) if (w.split('').every(common.contains)) w];
    if (pool.isEmpty) pool.addAll(lx.poolRange(2, 3, d));
    var placed = 0, guard = 0;
    while (placed < n + 1 && guard++ < 200) {
      final w = r.pick(pool);
      final empty = [for (var i = 0; i < g.length; i++) if (g[i].isEmpty) i];
      if (empty.length < w.length) break;
      var cur = r.pick(empty);
      final route = <int>[cur];
      for (var k = 1; k < w.length; k++) {
        final opts = [for (final x in gridNeighbors(cur, n, n)) if (g[x].isEmpty && !route.contains(x)) x];
        if (opts.isEmpty) break;
        cur = r.pick(opts);
        route.add(cur);
      }
      if (route.length < w.length) continue;
      for (var k = 0; k < w.length; k++) {
        g[route[k]] = w[k];
      }
      placed++;
    }
    for (var i = 0; i < g.length; i++) {
      if (g[i].isEmpty) {
        final w = r.pick(pool);
        g[i] = w[r.nextInt(w.length)];
      }
    }
    return g;
  }

  @override
  bool check(WPuzzle p, Lexicon lx) => p is BogglePuzzle && p.words.every(lx.has) && p.need > 0;

  @override
  Widget build(WordPlay play) => _PathView(play: play, blocks: false);
}

/// Kelime blokları: kelime yolunu kaydır, harfler kaybolsun, üsttekiler düşsün.
/// Tahtayı tamamen temizle. Bölüm geriye doğru kurulur, çözümü kesindir.
class BlocksPuzzle extends WPuzzle {
  final int w, h;

  /// Sütunlar (alttan üste).
  final List<List<String>> cols;

  /// Kurulum sırasının tersi: çözüm sırasıyla kelimeler.
  final List<String> order;
  const BlocksPuzzle(this.w, this.h, this.cols, this.order);
}

class BlocksKind extends WordKind {
  @override
  String get id => 'kelime-bloklari';
  const BlocksKind();

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final w = d <= 3 ? 4 : (d <= 7 ? 5 : 6);
    final h = d <= 3 ? 5 : (d <= 7 ? 6 : 7);
    final cols = [for (var i = 0; i < w; i++) <String>[]];
    final placed = <String>[];
    final pool = lx.poolFit(3, d <= 4 ? 5 : 6, d);
    var guard = 0;
    final cap = (w * h * (0.7 + d * 0.02)).round();
    while (guard++ < 400) {
      final total = cols.fold<int>(0, (a, c) => a + c.length);
      if (total >= cap) break;
      final word = r.pick(pool);
      if (total + word.length > w * h) continue;
      final ins = _insert(cols, h, word, r);
      if (ins != null) {
        for (var c = 0; c < w; c++) {
          cols[c]
            ..clear()
            ..addAll(ins[c]);
        }
        placed.add(word);
      }
    }
    if (placed.length < 3) return null;
    return BlocksPuzzle(w, h, cols, placed.reversed.toList());
  }

  /// Kelimeyi komşu yol halinde sütunlara yerleştir.
  List<List<String>>? _insert(List<List<String>> cols0, int h, String word, SeededRandom r) {
    for (var attempt = 0; attempt < 30; attempt++) {
      final cols = [for (final c in cols0) List.of(c)];
      // Bu kelimenin harflerinin (sütun, satır) konumları.
      final pos = <List<int>>[];
      var ok = true;
      for (var k = 0; k < word.length && ok; k++) {
        final choices = <List<int>>[];
        final cs = k == 0 ? [for (var c = 0; c < cols.length; c++) c] : [pos.last[0] - 1, pos.last[0], pos.last[0] + 1];
        for (final c in cs) {
          if (c < 0 || c >= cols.length || cols[c].length >= h) continue;
          // Aynı sütundaki önceki harflerin üstüne ekle (kaymasınlar).
          var minRow = 0;
          for (final p in pos) {
            if (p[0] == c && p[1] + 1 > minRow) minRow = p[1] + 1;
          }
          for (var row = minRow; row <= cols[c].length; row++) {
            if (k > 0 && (row - pos.last[1]).abs() > 1) continue;
            choices.add([c, row]);
          }
        }
        if (choices.isEmpty) {
          ok = false;
          break;
        }
        final ch = r.pick(choices);
        final c = ch[0], row = ch[1];
        // Başka sütundaki önceki harfler etkilenmez; aynı sütunda daha yukarıdaki
        // eski harfler bir kayar (bu kelimenin harfleri altta kaldığı için kaymaz).
        cols[c].insert(row, word[k]);
        pos.add([c, row]);
      }
      if (!ok) continue;
      // Komşuluğu son konumlarla doğrula.
      var adj = true;
      for (var k = 1; k < pos.length; k++) {
        if ((pos[k][0] - pos[k - 1][0]).abs() > 1 || (pos[k][1] - pos[k - 1][1]).abs() > 1) adj = false;
      }
      if (adj) return cols;
    }
    return null;
  }

  @override
  bool check(WPuzzle p, Lexicon lx) {
    if (p is! BlocksPuzzle) return false;
    final total = p.cols.fold<int>(0, (a, c) => a + c.length);
    final letters = p.order.fold<int>(0, (a, w) => a + w.length);
    return total == letters && p.order.every(lx.has) && p.cols.every((c) => c.length <= p.h);
  }

  @override
  Widget build(WordPlay play) => _PathView(play: play, blocks: true);
}

class _PathView extends StatefulWidget {
  final WordPlay play;
  final bool blocks;
  const _PathView({required this.play, required this.blocks});

  @override
  State<_PathView> createState() => _PathViewState();
}

class _PathViewState extends State<_PathView> with SecondsTicker, Flash {
  late int w, h;
  late List<String> grid; // satır 0 üstte
  final List<int> path = [];
  final List<String> found = [];
  int hints = 0, restarts = 0;
  int? hintCell;
  double cs = 10;
  Offset origin = Offset.zero;
  // bloklar
  List<List<String>> cols = [];
  int step = 0;
  bool onTrack = true;

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;

  @override
  void initState() {
    super.initState();
    if (widget.blocks) {
      final p = play.puzzle as BlocksPuzzle;
      w = p.w;
      h = p.h;
      _resetBlocks();
    } else {
      final p = play.puzzle as BogglePuzzle;
      w = p.n;
      h = p.n;
      grid = List.of(p.grid);
      final f = play.resume['f'];
      if (f is List) found.addAll([for (final x in f) '$x']);
    }
    startTicker((play.resume['s'] as num?)?.toInt() ?? 0);
  }

  void _resetBlocks() {
    final p = play.puzzle as BlocksPuzzle;
    cols = [for (final c in p.cols) List.of(c)];
    step = 0;
    onTrack = true;
    found.clear();
    _gridFromCols();
  }

  void _gridFromCols() {
    grid = List<String>.filled(w * h, '');
    for (var c = 0; c < w; c++) {
      for (var r = 0; r < cols[c].length; r++) {
        grid[(h - 1 - r) * w + c] = cols[c][r];
      }
    }
  }

  int get score => found.fold<int>(0, (a, x) => a + boggleScore(x, lx.tiled));

  @override
  void onTick() {
    if (widget.blocks || ended) return;
    final p = play.puzzle as BogglePuzzle;
    if (seconds >= p.time) {
      ended = true;
      play.ctx.sfx(Sfx.lose);
      play.lose(seconds: seconds, hints: hints, stats: {'words_found': found.length});
    }
  }

  int? _cellAt(Offset o) {
    final fx = (o.dx - origin.dx) / cs, fy = (o.dy - origin.dy) / cs;
    final x = fx.floor(), y = fy.floor();
    if (x < 0 || y < 0 || x >= w || y >= h) return null;
    // Çapraz geçişte yanlış hücre seçilmesin: hücre merkezine yakınlık şartı.
    final cx = fx - x - 0.5, cy = fy - y - 0.5;
    if (cx * cx + cy * cy > 0.2) return null;
    final i = y * w + x;
    return grid[i].isEmpty ? null : i;
  }

  void _touch(int? i) {
    if (i == null || ended) return;
    if (path.isEmpty) {
      setState(() => path.add(i));
      return;
    }
    if (path.length >= 2 && path[path.length - 2] == i) {
      setState(() => path.removeLast());
      return;
    }
    if (path.contains(i)) return;
    if (!gridNeighbors(path.last, w, h).contains(i)) return;
    setState(() => path.add(i));
    play.ctx.sfx(Sfx.tap);
  }

  void _release() {
    final word = path.map((i) => grid[i]).join();
    final cells = List.of(path);
    setState(() => path.clear());
    if (word.length < lx.minLen) return;
    if (widget.blocks) {
      if (!lx.has(word)) {
        play.ctx.sfx(Sfx.error);
        return flash(kt(play.lang, 'notWord'));
      }
      final p = play.puzzle as BlocksPuzzle;
      if (onTrack && (step >= p.order.length || p.order[step] != word)) onTrack = false;
      // Hücreleri sil, sütunlar düşsün.
      setState(() {
        for (final i in cells) {
          grid[i] = '';
        }
        cols = [
          for (var c = 0; c < w; c++) [for (var r = h - 1; r >= 0; r--) if (grid[r * w + c].isNotEmpty) grid[r * w + c]],
        ];
        _gridFromCols();
        found.add(word);
        step++;
        hintCell = null;
      });
      play.ctx.sfx(Sfx.clear);
      if (cols.every((c) => c.isEmpty)) {
        ended = true;
        play.ctx.sfx(Sfx.win);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            play.win(
              score: 300 + found.length * 40 - hints * 40 - restarts * 30,
              stars: starsFor(hints: hints, mistakes: restarts),
              seconds: seconds,
              hints: hints,
              stats: {'words_found': found.length},
            );
          }
        });
      } else if (solveGrid(grid, w, h, trieFor(lx)).isEmpty) {
        flash(kt(play.lang, 'undo'));
      }
      return;
    }
    final p = play.puzzle as BogglePuzzle;
    if (found.contains(word)) return flash(kt(play.lang, 'already'));
    if (!p.words.contains(word)) {
      play.ctx.sfx(Sfx.error);
      return flash(kt(play.lang, 'notWord'));
    }
    setState(() {
      found.add(word);
      hintCell = null;
    });
    play.ctx.sfx(Sfx.clear);
    flash('+${boggleScore(word, lx.tiled)}');
    play.save({'f': found, 's': seconds});
    if (score >= p.need) {
      ended = true;
      play.ctx.sfx(Sfx.win);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          play.win(
            score: score * 30 + (p.time - seconds) * 3,
            stars: math.min(starsFor(hints: hints), seconds < p.time * 0.5 ? 3 : 2),
            seconds: seconds,
            hints: hints,
            stats: {'words_found': found.length},
          );
        }
      });
    }
  }

  Future<void> _hint() async {
    if (ended) return;
    String? target;
    if (widget.blocks) {
      final p = play.puzzle as BlocksPuzzle;
      if (onTrack && step < p.order.length) {
        target = p.order[step];
      } else {
        // Yoldan çıkıldı: tahtayı baştan kur.
        setState(() {
          restarts++;
          _resetBlocks();
        });
        return;
      }
    } else {
      final p = play.puzzle as BogglePuzzle;
      final left = p.words.where((x) => !found.contains(x)).toList()..sort((a, b) => b.length.compareTo(a.length));
      if (left.isEmpty) return;
      target = left.first;
    }
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    // Hedef kelimenin başladığı hücreyi bul.
    final route = findPath(grid, w, h, target);
    final int? cell = route.isEmpty ? null : route.first;
    setState(() {
      hints++;
      hintCell = cell;
    });
    flash('${lx.up(target.substring(0, math.min(2, target.length)))}…');
  }

  @override
  Widget build(BuildContext context) {
    final lang = play.lang;
    final status = widget.blocks
        ? '${kt(lang, 'found')}: ${found.length}'
        : '${kt(lang, 'score')}: $score/${(play.puzzle as BogglePuzzle).need}';
    final left = widget.blocks ? clock() : clock(math.max(0, (play.puzzle as BogglePuzzle).time - seconds));
    final current = path.map((i) => grid[i]).join();
    return Column(children: [
      WordBar(
        play: play,
        left: left,
        status: status,
        onHint: _hint,
        actions: [
          if (widget.blocks)
            IconButton(
              tooltip: kt(lang, 'clear'),
              icon: const Icon(Icons.restart_alt),
              onPressed: () => setState(() {
                restarts++;
                _resetBlocks();
              }),
            ),
        ],
      ),
      flashLine(),
      SizedBox(
        height: 44,
        child: Center(child: Text(current.isEmpty ? '' : lx.up(current), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 2))),
      ),
      Expanded(
        flex: 3,
        child: LayoutBuilder(builder: (context, box) {
          cs = math.min((box.maxWidth - 24) / w, (box.maxHeight - 12) / h);
          origin = Offset((box.maxWidth - cs * w) / 2, (box.maxHeight - cs * h) / 2);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (d) => _touch(_cellAt(d.localPosition)),
            onPanUpdate: (d) => _touch(_cellAt(d.localPosition)),
            onPanEnd: (_) => _release(),
            onTapUp: (d) {
              _touch(_cellAt(d.localPosition));
            },
            child: CustomPaint(
              size: Size(box.maxWidth, box.maxHeight),
              painter: _PathPainter(grid, w, h, cs, origin, List.of(path), hintCell, lx, widget.blocks),
            ),
          );
        }),
      ),
      if (!widget.blocks)
        Expanded(
          flex: 1,
          child: SingleChildScrollView(padding: const EdgeInsets.all(6), child: FoundWords(words: found.reversed.toList(), lx: lx)),
        ),
      if (path.isNotEmpty)
        TextButton(onPressed: _release, child: Text(kt(lang, 'submit')))
      else
        const SizedBox(height: 40),
    ]);
  }
}

class _PathPainter extends CustomPainter {
  final List<String> grid;
  final int w, h;
  final double cs;
  final Offset origin;
  final List<int> path;
  final int? hint;
  final Lexicon lx;
  final bool blocks;
  _PathPainter(this.grid, this.w, this.h, this.cs, this.origin, this.path, this.hint, this.lx, this.blocks);

  Offset _c(int i) => origin + Offset((i % w + 0.5) * cs, (i ~/ w + 0.5) * cs);

  @override
  void paint(Canvas c, Size size) {
    if (!blocks) {
      c.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(origin.dx - 8, origin.dy - 8, cs * w + 16, cs * h + 16), const Radius.circular(16)),
        Paint()..color = WColors.ink.withValues(alpha: 0.85),
      );
    }
    if (path.length > 1) {
      final pp = Path()..moveTo(_c(path.first).dx, _c(path.first).dy);
      for (final i in path.skip(1)) {
        pp.lineTo(_c(i).dx, _c(i).dy);
      }
      c.drawPath(
        pp,
        Paint()
          ..color = WColors.accent.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = cs * 0.22
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
    for (var i = 0; i < grid.length; i++) {
      if (grid[i].isEmpty) continue;
      final r = Rect.fromCenter(center: _c(i), width: cs * 0.88, height: cs * 0.88);
      final on = path.contains(i);
      c.drawRRect(RRect.fromRectAndRadius(r.shift(Offset(0, cs * 0.04)), Radius.circular(cs * 0.16)), Paint()..color = Colors.black.withValues(alpha: 0.2));
      c.drawRRect(
        RRect.fromRectAndRadius(r, Radius.circular(cs * 0.16)),
        Paint()..color = on ? WColors.near : (hint == i ? WColors.soft : WColors.tile),
      );
      var tp = TextPainter(
        text: TextSpan(text: lx.upCh(grid[i]), style: TextStyle(fontSize: cs * 0.46, fontWeight: FontWeight.w800, color: WColors.ink)),
        textDirection: TextDirection.ltr,
      )..layout();
      if (tp.width > cs * 0.86) {
        // Taş dillerinde uzun taş (Tay hecesi, Vietnamca hece): hücreye sığdır.
        tp = TextPainter(
          text: TextSpan(text: (tp.text! as TextSpan).text, style: (tp.text! as TextSpan).style!.copyWith(fontSize: cs * 0.46 * cs * 0.86 / tp.width)),
          textDirection: TextDirection.ltr,
        )..layout();
      }
      tp.paint(c, _c(i) - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
