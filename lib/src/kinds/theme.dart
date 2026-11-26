import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:studio_core/app/services/audio.dart';
import 'package:studio_core/core/rng.dart';

import '../clues.dart';
import '../core.dart';
import '../texts.dart';
import '../ui.dart';
import '../words.dart';

/// Tema avı (Kelime Avı'nın kipi): ızgaranın bütün harfleri tek bir temanın
/// kelimeleridir. Kelimeler düz çizgide değil, yan yana hücrelerden kıvrılan
/// yollardır; her hücre tam bir kelimeye aittir.
class ThemePuzzle extends WPuzzle {
  final int w, h;
  final String theme;
  final List<String> grid;
  final List<String> words;

  /// Her kelimenin hücreleri (ilk harften son harfe).
  final List<List<int>> paths;
  const ThemePuzzle(this.w, this.h, this.theme, this.grid, this.words, this.paths);
}

class ThemeKind extends WordKind {
  const ThemeKind();

  @override
  String get id => 'tema-avi';

  /// Yeterli temanın kurulabildiği diller (sözlük ve kategori listesine göre).
  static final List<String> langs = [
    for (final l in kAllWordLangs)
      if (Lexicon.hasList(l) && themes(Lexicon.of(l)).length >= 6) l
  ];

  @override
  List<String>? get contentLangs => langs;

  /// Hiragana → katakana (Japonca sözlük katakanadır).
  static String _kata(String s) => String.fromCharCodes([
        for (final c in s.runes) (c >= 0x3041 && c <= 0x3096) ? c + 0x60 : c,
      ]);

  /// Tema kelimesinin bu sözlükteki birimleri (harf ya da taş); kurulamazsa null.
  static String? unitsOf(String natural, Lexicon lx) {
    var s = natural.trim();
    if (lx.lang == 'ja') s = foldWord(_kata(s), 'ja');
    final code = lx.tiled ? lx.encode(s) : s;
    if (code == null) return null;
    final min = lx.tiled ? 2 : 3;
    if (code.length < min || code.length > 9) return null;
    final letters = lx.letters.toSet();
    if (code.split('').any((c) => !letters.contains(c))) return null;
    return code;
  }

  static final Map<String, List<(String, List<String>)>> _themes = {};

  /// Bu dilde kullanılabilir temalar: (başlık, kelimeler).
  static List<(String, List<String>)> themes(Lexicon lx) => _themes[lx.lang] ??= [
        for (final g in groupList(lx.lang))
          (
            g.$1,
            {
              for (final w in g.$2)
                if (unitsOf(w, lx) != null) unitsOf(w, lx)!,
            }.toList(),
          ),
      ].where((g) => g.$2.length >= 3).toList();

  /// Zorluğa göre hedef ızgara boyutları (en büyükten küçüğe denenir).
  static List<(int, int)> dims(int d) {
    const all = [(3, 4), (4, 4), (4, 5), (5, 5), (5, 6), (6, 6), (6, 7)];
    final top = const [1, 1, 2, 2, 3, 3, 4, 4, 5, 6][d - 1];
    final out = [for (var i = top; i >= 0; i--) all[i]];
    // Yedek: daha küçük öbür dikdörtgenler (az kelimeli temalar için).
    final rest = [
      for (var w = 3; w <= 6; w++)
        for (var h = w; h <= 7; h++)
          if (w * h <= all[top].$1 * all[top].$2 && !out.contains((w, h))) (w, h)
    ]..sort((a, b) => (b.$1 * b.$2).compareTo(a.$1 * a.$2));
    return [...out, ...rest];
  }

  /// Rastgele Hamilton yolu (w × h ızgarada, "backbite" yöntemi).
  static List<int> hamiltonPath(int w, int h, SeededRandom r) {
    final path = <int>[];
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        path.add(y * w + (y.isEven ? x : w - 1 - x));
      }
    }
    final pos = List<int>.filled(w * h, 0);
    void index() {
      for (var i = 0; i < path.length; i++) {
        pos[path[i]] = i;
      }
    }

    index();
    final n = path.length;
    for (var it = 0; it < n * 40; it++) {
      final atStart = r.nextInt(2) == 0;
      final end = atStart ? path.first : path.last;
      final ex = end % w, ey = end ~/ w;
      final nb = <int>[
        if (ex > 0) end - 1,
        if (ex < w - 1) end + 1,
        if (ey > 0) end - w,
        if (ey < h - 1) end + w,
      ];
      final m = nb[r.nextInt(nb.length)];
      final j = pos[m];
      if (atStart) {
        if (j == 1) continue;
        final seg = path.sublist(0, j).reversed.toList();
        path.setRange(0, j, seg);
      } else {
        if (j == n - 2) continue;
        final seg = path.sublist(j + 1).reversed.toList();
        path.setRange(j + 1, n, seg);
      }
      index();
    }
    return path;
  }

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final ts = themes(lx);
    if (ts.isEmpty) return null;
    final order = [for (var i = 0; i < ts.length; i++) i];
    r.shuffle(order);
    for (final (w, h) in dims(d)) {
      final area = w * h;
      for (final ti in order.take(16)) {
        final (title, pool0) = ts[ti];
        final pool = pool0.take(12).toList();
        // Toplam uzunluğu tam alana eşit, en az 3 kelimelik alt kümeler.
        final subs = <int>[];
        for (var mask = 1; mask < (1 << pool.length); mask++) {
          var sum = 0, cnt = 0;
          for (var i = 0; i < pool.length; i++) {
            if (mask & (1 << i) != 0) {
              sum += pool[i].length;
              cnt++;
            }
          }
          if (sum == area && cnt >= 3) subs.add(mask);
        }
        if (subs.isEmpty) continue;
        final mask = subs[r.nextInt(subs.length)];
        final words = [for (var i = 0; i < pool.length; i++) if (mask & (1 << i) != 0) pool[i]];
        r.shuffle(words);
        final path = hamiltonPath(w, h, r);
        final grid = List<String>.filled(area, '');
        final paths = <List<int>>[];
        var off = 0;
        for (final word in words) {
          final cells = path.sublist(off, off + word.length);
          off += word.length;
          final p = r.nextInt(2) == 0 ? cells : cells.reversed.toList();
          for (var i = 0; i < word.length; i++) {
            grid[p[i]] = word[i];
          }
          paths.add(p);
        }
        return ThemePuzzle(w, h, title, grid, words, paths);
      }
    }
    return null;
  }

  static bool adjacent(int a, int b, int w) {
    final dx = (a % w - b % w).abs(), dy = (a ~/ w - b ~/ w).abs();
    return dx + dy == 1;
  }

  @override
  bool check(WPuzzle p, Lexicon lx) {
    if (p is! ThemePuzzle) return false;
    if (p.grid.length != p.w * p.h || p.words.length < 3) return false;
    final t = themes(lx).where((g) => g.$1 == p.theme).toList();
    if (t.isEmpty) return false;
    final seen = <int>{};
    for (var k = 0; k < p.words.length; k++) {
      final word = p.words[k], path = p.paths[k];
      if (!t.first.$2.contains(word) || path.length != word.length) return false;
      for (var i = 0; i < path.length; i++) {
        if (path[i] < 0 || path[i] >= p.grid.length || !seen.add(path[i])) return false;
        if (p.grid[path[i]] != word[i]) return false;
        if (i > 0 && !adjacent(path[i - 1], path[i], p.w)) return false;
      }
    }
    return seen.length == p.grid.length;
  }

  @override
  Widget build(WordPlay play) => _ThemeView(play: play);
}

class _ThemeView extends StatefulWidget {
  final WordPlay play;
  const _ThemeView({required this.play});

  @override
  State<_ThemeView> createState() => _ThemeViewState();
}

class _ThemeViewState extends State<_ThemeView> with SecondsTicker, Flash {
  late ThemePuzzle p;
  final Set<int> found = {};
  final List<int> sel = [];
  int hints = 0, mistakes = 0;
  int? hintWord;
  double cs = 10;
  Offset origin = Offset.zero;

  WordPlay get play => widget.play;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as ThemePuzzle;
    final f = play.resume['f'];
    if (f is List) found.addAll([for (final x in f) (x as num).toInt()]);
    hints = (play.resume['hn'] as num?)?.toInt() ?? 0;
    mistakes = (play.resume['m'] as num?)?.toInt() ?? 0;
    startTicker((play.resume['s'] as num?)?.toInt() ?? 0);
  }

  void _save() => play.save({'f': found.toList(), 'hn': hints, 'm': mistakes, 's': seconds});

  int? _cellAt(Offset o) {
    final fx = (o.dx - origin.dx) / cs, fy = (o.dy - origin.dy) / cs;
    final x = fx.floor(), y = fy.floor();
    if (x < 0 || y < 0 || x >= p.w || y >= p.h) return null;
    // Hücre ortasına yakın dokunuş (çapraz geçişte komşuya atlamasın).
    if ((fx - x - 0.5).abs() > 0.42 || (fy - y - 0.5).abs() > 0.42) return null;
    return y * p.w + x;
  }

  bool _taken(int c) => found.any((k) => p.paths[k].contains(c));

  void _touch(int? c) {
    if (c == null || _taken(c)) return;
    setState(() {
      if (sel.isEmpty) {
        sel.add(c);
      } else if (sel.length >= 2 && sel[sel.length - 2] == c) {
        sel.removeLast();
      } else if (!sel.contains(c) && ThemeKind.adjacent(sel.last, c, p.w)) {
        sel.add(c);
      }
    });
  }

  void _release() {
    if (sel.isEmpty) return;
    final cells = List.of(sel);
    setState(() => sel.clear());
    for (var k = 0; k < p.words.length; k++) {
      if (found.contains(k)) continue;
      final path = p.paths[k];
      if (cells.length != path.length) continue;
      final fwd = List.generate(path.length, (i) => path[i] == cells[i]).every((x) => x);
      final back = List.generate(path.length, (i) => path[path.length - 1 - i] == cells[i]).every((x) => x);
      if (fwd || back) {
        setState(() {
          found.add(k);
          if (hintWord == k) hintWord = null;
        });
        play.ctx.sfx(Sfx.clear);
        _save();
        if (found.length == p.words.length) {
          ended = true;
          play.ctx.sfx(Sfx.win);
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              play.win(
                score: 300 + p.words.length * 60 - hints * 40 - mistakes * 10,
                stars: starsFor(hints: hints, mistakes: mistakes ~/ 3),
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
    if (cells.length > 2) {
      mistakes++;
      play.ctx.sfx(Sfx.error);
      _save();
    }
  }

  Future<void> _hint() async {
    if (ended) return;
    final k = [for (var i = 0; i < p.words.length; i++) if (!found.contains(i)) i];
    if (k.isEmpty) return;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    setState(() {
      hints++;
      hintWord = k.first;
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final lx = play.lx;
    final lang = play.lang;
    return Column(children: [
      WordBar(play: play, left: clock(), status: '${kt(lang, 'found')}: ${found.length}/${p.words.length}', onHint: _hint),
      flashLine(),
      Panel(
        child: Column(children: [
          Text(kt(lang, 'theme'), style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(p.theme, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        ]),
      ),
      Expanded(
        child: LayoutBuilder(builder: (context, box) {
          cs = math.min((box.maxWidth - 16) / p.w, (box.maxHeight - 8) / p.h);
          origin = Offset((box.maxWidth - cs * p.w) / 2, (box.maxHeight - cs * p.h) / 2);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (dd) {
              sel.clear();
              _touch(_cellAt(dd.localPosition));
            },
            onPanUpdate: (dd) => _touch(_cellAt(dd.localPosition)),
            onPanEnd: (_) => _release(),
            child: CustomPaint(
              size: Size(box.maxWidth, box.maxHeight),
              painter: _ThemePainter(p, lx, cs, origin, [for (final k in found) p.paths[k]], sel,
                  hintWord == null ? const [] : [p.paths[hintWord!].first, p.paths[hintWord!].last]),
            ),
          );
        }),
      ),
      Panel(
        child: Wrap(spacing: 10, runSpacing: 4, alignment: WrapAlignment.center, children: [
          for (var k = 0; k < p.words.length; k++)
            Text(
              found.contains(k) ? lx.up(p.words[k]) : List.filled(p.words[k].length, '•').join(),
              style: TextStyle(fontWeight: FontWeight.w700, color: found.contains(k) ? Colors.white : Colors.white54),
            ),
        ]),
      ),
      const SizedBox(height: 6),
    ]);
  }
}

class _ThemePainter extends CustomPainter {
  final ThemePuzzle p;
  final Lexicon lx;
  final double cs;
  final Offset origin;
  final List<List<int>> found;
  final List<int> sel;
  final List<int> hint;
  _ThemePainter(this.p, this.lx, this.cs, this.origin, this.found, this.sel, this.hint);

  Offset _c(int i) => origin + Offset((i % p.w + 0.5) * cs, (i ~/ p.w + 0.5) * cs);

  void _snake(Canvas c, List<int> cells, Color col) {
    if (cells.isEmpty) return;
    final paint = Paint()
      ..color = col
      ..style = PaintingStyle.stroke
      ..strokeWidth = cs * 0.62
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()..moveTo(_c(cells.first).dx, _c(cells.first).dy);
    for (final i in cells.skip(1)) {
      path.lineTo(_c(i).dx, _c(i).dy);
    }
    if (cells.length == 1) {
      c.drawCircle(_c(cells.first), cs * 0.31, Paint()..color = col);
    } else {
      c.drawPath(path, paint);
    }
  }

  @override
  void paint(Canvas c, Size size) {
    final board = Rect.fromLTWH(origin.dx - 6, origin.dy - 6, cs * p.w + 12, cs * p.h + 12);
    c.drawRRect(RRect.fromRectAndRadius(board, const Radius.circular(14)), Paint()..color = WColors.paper);
    for (var k = 0; k < found.length; k++) {
      _snake(c, found[k], WColors.marks[k % WColors.marks.length].withValues(alpha: 0.6));
    }
    _snake(c, sel, WColors.accent.withValues(alpha: 0.4));
    for (final h in hint) {
      c.drawCircle(_c(h), cs * 0.42, Paint()..color = WColors.near.withValues(alpha: 0.6));
    }
    for (var i = 0; i < p.grid.length; i++) {
      var tp = TextPainter(
        text: TextSpan(text: lx.upCh(p.grid[i]), style: TextStyle(fontSize: cs * 0.46, fontWeight: FontWeight.w700, color: WColors.ink)),
        textDirection: TextDirection.ltr,
      )..layout();
      if (tp.width > cs * 0.86) {
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
