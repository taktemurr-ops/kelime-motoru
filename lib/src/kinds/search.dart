import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:studio_core/app/services/audio.dart';
import 'package:studio_core/core/rng.dart';

import '../core.dart';
import '../texts.dart';
import '../ui.dart';
import '../words.dart';

/// Kelime avı: ızgaraya gizlenmiş kelimeleri bul.
class SearchPuzzle extends WPuzzle {
  final int w, h;
  final List<String> grid;
  final List<String> words;

  /// Her kelime için [başlangıç hücresi, yön dizini].
  final List<List<int>> place;
  const SearchPuzzle(this.w, this.h, this.grid, this.words, this.place);
}

const kDirs8 = [
  [1, 0], [0, 1], [1, 1], [1, -1], [-1, 0], [0, -1], [-1, -1], [-1, 1],
];

class SearchKind extends WordKind {
  @override
  String get id => 'kelime-avi';
  const SearchKind();

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final size = 7 + (d * 5) ~/ 10;
    final count = 6 + d;
    final dirs = d <= 3 ? 2 : (d <= 6 ? 4 : 8);
    final pool = lx.poolRange(3, math.min(size, 9), d);
    if (pool.length < count * 3) return null;
    final grid = List<String>.filled(size * size, '');
    final words = <String>[];
    final place = <List<int>>[];
    var guard = 0;
    while (words.length < count && guard++ < 600) {
      final word = r.pick(pool);
      if (words.contains(word) || words.any((x) => x.contains(word) || word.contains(x))) continue;
      final dir = r.nextInt(dirs);
      final dx = kDirs8[dir][0], dy = kDirs8[dir][1];
      final x0 = r.nextInt(size), y0 = r.nextInt(size);
      final x1 = x0 + dx * (word.length - 1), y1 = y0 + dy * (word.length - 1);
      if (x1 < 0 || y1 < 0 || x1 >= size || y1 >= size) continue;
      var ok = true;
      for (var i = 0; i < word.length; i++) {
        final c = grid[(y0 + dy * i) * size + x0 + dx * i];
        if (c.isNotEmpty && c != word[i]) {
          ok = false;
          break;
        }
      }
      if (!ok) continue;
      for (var i = 0; i < word.length; i++) {
        grid[(y0 + dy * i) * size + x0 + dx * i] = word[i];
      }
      words.add(word);
      place.add([y0 * size + x0, dir]);
    }
    if (words.length < count) return null;
    for (var i = 0; i < grid.length; i++) {
      if (grid[i].isEmpty) grid[i] = lx.randomLetter(r);
    }
    return SearchPuzzle(size, size, grid, words, place);
  }

  @override
  bool check(WPuzzle p, Lexicon lx) {
    if (p is! SearchPuzzle) return false;
    for (var k = 0; k < p.words.length; k++) {
      final w = p.words[k];
      final s = p.place[k][0], dir = kDirs8[p.place[k][1]];
      for (var i = 0; i < w.length; i++) {
        final x = s % p.w + dir[0] * i, y = s ~/ p.w + dir[1] * i;
        if (x < 0 || y < 0 || x >= p.w || y >= p.h || p.grid[y * p.w + x] != w[i]) return false;
      }
    }
    return p.words.isNotEmpty;
  }

  @override
  Widget build(WordPlay play) => _SearchView(play: play);
}

class _SearchView extends StatefulWidget {
  final WordPlay play;
  const _SearchView({required this.play});

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> with SecondsTicker, Flash {
  late SearchPuzzle p;
  final Set<int> found = {};
  int hints = 0;
  int? hintCell;
  int? dragStart, dragEnd;
  double cs = 10;
  Offset origin = Offset.zero;

  WordPlay get play => widget.play;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as SearchPuzzle;
    final f = play.resume['f'];
    if (f is List) found.addAll([for (final x in f) (x as num).toInt()]);
    hints = (play.resume['hn'] as num?)?.toInt() ?? 0;
    startTicker((play.resume['s'] as num?)?.toInt() ?? 0);
  }

  void _save() => play.save({'f': found.toList(), 'hn': hints, 's': seconds});

  int? _cellAt(Offset o) {
    final x = ((o.dx - origin.dx) / cs).floor(), y = ((o.dy - origin.dy) / cs).floor();
    if (x < 0 || y < 0 || x >= p.w || y >= p.h) return null;
    return y * p.w + x;
  }

  /// Başlangıçtan bitişe en yakın 8 yönlü doğru.
  List<int> _line(int a, int b) {
    final ax = a % p.w, ay = a ~/ p.w, bx = b % p.w, by = b ~/ p.w;
    var dx = bx - ax, dy = by - ay;
    final n = math.max(dx.abs(), dy.abs());
    if (n == 0) return [a];
    final ang = math.atan2(dy.toDouble(), dx.toDouble());
    final k = ((ang / (math.pi / 4)).round()) % 8;
    const map = [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]];
    dx = map[k][0];
    dy = map[k][1];
    final out = <int>[];
    for (var i = 0; i <= n; i++) {
      final x = ax + dx * i, y = ay + dy * i;
      if (x < 0 || y < 0 || x >= p.w || y >= p.h) break;
      out.add(y * p.w + x);
    }
    return out;
  }

  void _release() {
    if (dragStart == null || dragEnd == null) return;
    final cells = _line(dragStart!, dragEnd!);
    final s = cells.map((i) => p.grid[i]).join();
    final rev = s.split('').reversed.join();
    setState(() {
      dragStart = null;
      dragEnd = null;
    });
    for (var k = 0; k < p.words.length; k++) {
      if (found.contains(k)) continue;
      final w = p.words[k];
      if (w == s || w == rev) {
        setState(() {
          found.add(k);
          hintCell = null;
        });
        play.ctx.sfx(Sfx.clear);
        _save();
        if (found.length == p.words.length) {
          ended = true;
          play.ctx.sfx(Sfx.win);
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              play.win(
                score: 300 + p.words.length * 50 - hints * 40,
                stars: starsFor(hints: hints),
                seconds: seconds,
                hints: hints,
                stats: {'words_found': p.words.length},
              );
            }
          });
        }
        return;
      }
    }
    if (cells.length > 1) play.ctx.sfx(Sfx.error);
  }

  List<int> _cellsOf(int k) {
    final s = p.place[k][0], dir = kDirs8[p.place[k][1]];
    return [for (var i = 0; i < p.words[k].length; i++) (s ~/ p.w + dir[1] * i) * p.w + s % p.w + dir[0] * i];
  }

  Future<void> _hint() async {
    if (ended) return;
    final k = [for (var i = 0; i < p.words.length; i++) if (!found.contains(i)) i];
    if (k.isEmpty) return;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    setState(() {
      hints++;
      hintCell = p.place[k.first][0];
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final lx = play.lx;
    final lang = play.lang;
    final sel = dragStart != null && dragEnd != null ? _line(dragStart!, dragEnd!) : const <int>[];
    final foundLines = [for (final k in found) _cellsOf(k)];
    return Column(children: [
      WordBar(play: play, left: clock(), status: '${kt(lang, 'found')}: ${found.length}/${p.words.length}', onHint: _hint),
      flashLine(),
      Expanded(
        child: LayoutBuilder(builder: (context, box) {
          cs = math.min((box.maxWidth - 16) / p.w, (box.maxHeight - 8) / p.h);
          origin = Offset((box.maxWidth - cs * p.w) / 2, (box.maxHeight - cs * p.h) / 2);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (dd) => setState(() {
              dragStart = _cellAt(dd.localPosition);
              dragEnd = dragStart;
            }),
            onPanUpdate: (dd) {
              final c = _cellAt(dd.localPosition);
              if (c != null && c != dragEnd) setState(() => dragEnd = c);
            },
            onPanEnd: (_) => _release(),
            child: CustomPaint(
              size: Size(box.maxWidth, box.maxHeight),
              painter: _SearchPainter(p, lx, cs, origin, foundLines, sel, hintCell),
            ),
          );
        }),
      ),
      Panel(
        child: Wrap(spacing: 8, runSpacing: 4, alignment: WrapAlignment.center, children: [
          for (var k = 0; k < p.words.length; k++)
            Text(
              lx.up(p.words[k]),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: found.contains(k) ? WColors.miss : WColors.ink,
                decoration: found.contains(k) ? TextDecoration.lineThrough : null,
              ),
            ),
        ]),
      ),
      const SizedBox(height: 6),
    ]);
  }
}

class _SearchPainter extends CustomPainter {
  final SearchPuzzle p;
  final Lexicon lx;
  final double cs;
  final Offset origin;
  final List<List<int>> found;
  final List<int> sel;
  final int? hint;
  _SearchPainter(this.p, this.lx, this.cs, this.origin, this.found, this.sel, this.hint);

  Offset _c(int i) => origin + Offset((i % p.w + 0.5) * cs, (i ~/ p.w + 0.5) * cs);

  void _capsule(Canvas c, List<int> cells, Color col) {
    if (cells.isEmpty) return;
    final paint = Paint()
      ..color = col
      ..strokeWidth = cs * 0.78
      ..strokeCap = StrokeCap.round;
    c.drawLine(_c(cells.first), _c(cells.last), paint);
  }

  @override
  void paint(Canvas c, Size size) {
    final board = Rect.fromLTWH(origin.dx - 6, origin.dy - 6, cs * p.w + 12, cs * p.h + 12);
    c.drawRRect(RRect.fromRectAndRadius(board, const Radius.circular(14)), Paint()..color = WColors.paper);
    for (var k = 0; k < found.length; k++) {
      _capsule(c, found[k], WColors.marks[k % WColors.marks.length].withValues(alpha: 0.55));
    }
    if (sel.isNotEmpty) _capsule(c, sel, WColors.accent.withValues(alpha: 0.35));
    if (hint != null) c.drawCircle(_c(hint!), cs * 0.42, Paint()..color = WColors.near.withValues(alpha: 0.6));
    for (var i = 0; i < p.grid.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: lx.upCh(p.grid[i]), style: TextStyle(fontSize: cs * 0.5, fontWeight: FontWeight.w700, color: WColors.ink)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(c, _c(i) - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
