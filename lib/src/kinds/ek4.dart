import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:studio_core/app/services/audio.dart';
import 'package:studio_core/core/rng.dart';

import '../clues.dart';
import '../core.dart';
import '../data/pics.dart';
import '../texts.dart';
import '../ui.dart';
import '../words.dart';

const _rtl = {'ar', 'fa', 'he', 'ur'};

// ======================================================================
// Dört Resim Bir Kelime: dört simgenin ortak kelimesini harf taşlarıyla yaz.

class PicsPuzzle extends WPuzzle {
  final int concept;
  final List<int> icons; // kavramın 5 simgesinden 4'ü (sırası karışık)
  final List<String> answer; // harf ya da taş birimleri
  final List<String> bank;
  const PicsPuzzle(this.concept, this.icons, this.answer, this.bank);
}

/// Zemin rengine göre okunaklı simge rengi (beyaz ya da mürekkep).
Color _iconOn(Color bg) {
  final l = bg.computeLuminance();
  final white = 1.05 / (l + 0.05);
  final ink = (l + 0.05) / (WColors.ink.computeLuminance() + 0.05);
  return white >= ink ? Colors.white : WColors.ink;
}

class PicsKind extends WordKind {
  const PicsKind();

  @override
  String get id => 'dort-resim';

  @override
  List<String>? get contentLangs => kAllWordLangs;

  /// Kavramın bu dildeki yanıtı (birimlere bölünmüş); yoksa null.
  static List<String>? answerOf(int concept, Lexicon lx) {
    final li = kPicLangs.indexOf(lx.lang);
    if (li < 0) return null;
    final natural = kPicWords[concept][li].toLowerCase();
    if (lx.tiled) {
      final code = lx.encode(natural);
      if (code == null) return null;
      final u = code.split('');
      return u.length >= 2 && u.length <= 6 ? u : null;
    }
    final u = natural.split('');
    if (u.length < 2 || u.length > 12 || u.any((c) => c.trim().isEmpty)) return null;
    return u;
  }

  static final Map<String, List<int>> _valid = {};

  /// Bu dilde yanıtı kurulabilen kavramlar.
  static List<int> validConcepts(Lexicon lx) =>
      _valid[lx.lang] ??= [for (var i = 0; i < kPicWords.length; i++) if (answerOf(i, lx) != null) i];

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final valid = validConcepts(lx);
    if (valid.isEmpty) return null;
    final concept = valid[r.nextInt(valid.length)];
    final ans = answerOf(concept, lx);
    if (ans == null) return null;
    final icons = [0, 1, 2, 3, 4]..removeAt(r.nextInt(5));
    r.shuffle(icons);
    final extra = math.min(const [2, 3, 4, 4, 5, 6, 6, 7, 8, 8][d - 1], (lx.tiled ? 10 : 14) - ans.length);
    final bank = [...ans];
    for (var i = 0; i < math.max(0, extra); i++) {
      bank.add(lx.randomLetter(r));
    }
    r.shuffle(bank);
    return PicsPuzzle(concept, icons, ans, bank);
  }

  @override
  bool check(WPuzzle p, Lexicon lx) {
    if (p is! PicsPuzzle) return false;
    final ans = answerOf(p.concept, lx);
    if (ans == null || ans.join() != p.answer.join() || p.icons.toSet().length != 4) return false;
    final left = List.of(p.bank);
    for (final u in p.answer) {
      if (!left.remove(u)) return false;
    }
    return true;
  }

  @override
  Widget build(WordPlay play) => _PicsView(play: play);
}

class _PicsView extends StatefulWidget {
  final WordPlay play;
  const _PicsView({required this.play});

  @override
  State<_PicsView> createState() => _PicsViewState();
}

class _PicsViewState extends State<_PicsView> with SecondsTicker, Flash {
  late PicsPuzzle p;

  /// Yuvalar: bankadaki taşın sırası (-1 boş).
  late List<int> slots;
  final Set<int> locked = {};
  int mistakes = 0, hints = 0;

  WordPlay get play => widget.play;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as PicsPuzzle;
    slots = List.filled(p.answer.length, -1);
    startTicker();
  }

  void _put(int bankIx) {
    if (ended || slots.contains(bankIx)) return;
    final i = slots.indexOf(-1);
    if (i < 0) return;
    play.ctx.sfx(Sfx.tap);
    setState(() => slots[i] = bankIx);
    if (!slots.contains(-1)) _check();
  }

  void _take(int slot) {
    if (ended || slots[slot] < 0 || locked.contains(slot)) return;
    setState(() => slots[slot] = -1);
  }

  void _check() {
    final word = [for (final b in slots) p.bank[b]].join();
    if (word == p.answer.join()) {
      ended = true;
      play.ctx.sfx(Sfx.win);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          play.win(
            score: math.max(60, 400 + p.answer.length * 20 - mistakes * 50 - hints * 70),
            stars: starsFor(hints: hints, mistakes: mistakes),
            seconds: seconds,
            hints: hints,
            stats: {'words_found': 1},
          );
        }
      });
      return;
    }
    play.ctx.sfx(Sfx.error);
    setState(() {
      mistakes++;
      for (var i = 0; i < slots.length; i++) {
        if (!locked.contains(i)) slots[i] = -1;
      }
    });
    flash(kt(play.lang, 'wrong'));
  }

  Future<void> _hint() async {
    if (ended) return;
    final free = [for (var k = 0; k < slots.length; k++) if (!locked.contains(k)) k];
    if (free.isEmpty) return;
    final i = free.first;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    setState(() {
      hints++;
      // Bu yuvanın doğru taşını yerleştir ve kilitle.
      final want = p.answer[i];
      if (slots[i] >= 0 && p.bank[slots[i]] != want) slots[i] = -1;
      if (slots[i] < 0) {
        var b = -1;
        for (var k = 0; k < p.bank.length; k++) {
          if (p.bank[k] == want && !slots.contains(k)) {
            b = k;
            break;
          }
        }
        if (b < 0) {
          // Taş başka bir yuvadaysa oradan al.
          final j = [for (var k = 0; k < slots.length; k++) if (slots[k] >= 0 && p.bank[slots[k]] == want && !locked.contains(k)) k].first;
          b = slots[j];
          slots[j] = -1;
        }
        slots[i] = b;
      }
      locked.add(i);
    });
    if (!slots.contains(-1)) _check();
  }

  @override
  Widget build(BuildContext context) {
    final lx = play.lx;
    final rtl = _rtl.contains(lx.lang);
    final icons = kPicIcons[p.concept];
    return Column(children: [
      WordBar(play: play, left: clock(), status: '${kt(play.lang, 'mistakes')}: $mistakes', onHint: _hint),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(kt(play.lang, 'commonWord'),
            textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white70)),
      ),
      flashLine(),
      Expanded(
        child: LayoutBuilder(builder: (context, box) {
          final side = math.min(box.maxWidth - 24, box.maxHeight - 8);
          final cell = side / 2 - 8;
          return Center(
            child: SizedBox(
              width: side,
              height: side,
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                for (var k = 0; k < 4; k++)
                  Container(
                    width: cell,
                    height: cell,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [WColors.marks[(p.concept + k * 3) % 8], Color.lerp(WColors.marks[(p.concept + k * 3) % 8], Colors.black, 0.3)!],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 2),
                    ),
                    child: Icon(icons[p.icons[k]], size: cell * 0.62, color: _iconOn(WColors.marks[(p.concept + k * 3) % 8])),
                  ),
              ]),
            ),
          );
        }),
      ),
      Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Wrap(alignment: WrapAlignment.center, spacing: 4, runSpacing: 4, children: [
            for (var i = 0; i < slots.length; i++)
              LetterTile(
                letter: slots[i] < 0 ? '' : lx.upCh(p.bank[slots[i]]),
                size: slots.length > 9 ? 32 : 40,
                fill: locked.contains(i) ? WColors.hit : (slots[i] < 0 ? WColors.soft : WColors.tile),
                onTap: () => _take(i),
              ),
          ]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
        child: Wrap(alignment: WrapAlignment.center, spacing: 6, runSpacing: 6, children: [
          for (var b = 0; b < p.bank.length; b++)
            Opacity(
              opacity: slots.contains(b) ? 0.25 : 1,
              child: LetterTile(letter: lx.upCh(p.bank[b]), size: 44, onTap: () => _put(b)),
            ),
        ]),
      ),
    ]);
  }
}

// ======================================================================
// Beş İpucu: kelimeler birer birer açılır; ortak kategoriyi seçeneklerden bul.

class CluesPuzzle extends WPuzzle {
  final List<String> clues; // 5 kelime
  final List<String> options; // kategori başlıkları
  final int answer;
  final int lives;
  const CluesPuzzle(this.clues, this.options, this.answer, this.lives);
}

class CluesKind extends WordKind {
  const CluesKind();

  @override
  String get id => 'bes-ipucu';

  @override
  List<String>? get contentLangs => kQuizLangs;

  static int optionCount(int d) => const [3, 3, 3, 4, 4, 4, 5, 5, 6, 6][d - 1];

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final groups = [
      for (final g in groupList(lx.lang))
        if (g.$2.toSet().length >= 5) g
    ];
    if (groups.length < optionCount(d)) return null;
    final pick = groups[r.nextInt(groups.length)];
    final words = pick.$2.toSet().toList();
    r.shuffle(words);
    final clues = words.take(5).toList();
    final others = [
      for (final g in groupList(lx.lang))
        if (g.$1 != pick.$1 && !g.$2.any(clues.contains)) g.$1
    ].toSet().toList();
    r.shuffle(others);
    final n = optionCount(d);
    if (others.length < n - 1) return null;
    final options = [pick.$1, ...others.take(n - 1)];
    r.shuffle(options);
    return CluesPuzzle(clues, options, options.indexOf(pick.$1), d <= 5 ? 3 : 2);
  }

  @override
  bool check(WPuzzle p, Lexicon lx) {
    if (p is! CluesPuzzle) return false;
    if (p.clues.toSet().length != 5 || p.options.toSet().length != p.options.length) return false;
    final gs = groupList(lx.lang);
    // Doğru başlık bütün ipuçlarını içerir; diğer seçenekler hiçbirini.
    for (var i = 0; i < p.options.length; i++) {
      final g = gs.where((x) => x.$1 == p.options[i]).toList();
      if (g.isEmpty) return false;
      final words = {for (final x in g) ...x.$2};
      if (i == p.answer ? !p.clues.every(words.contains) : p.clues.any(words.contains)) return false;
    }
    return true;
  }

  @override
  Widget build(WordPlay play) => _CluesView(play: play);
}

class _CluesView extends StatefulWidget {
  final WordPlay play;
  const _CluesView({required this.play});

  @override
  State<_CluesView> createState() => _CluesViewState();
}

class _CluesViewState extends State<_CluesView> with SecondsTicker, Flash {
  late CluesPuzzle p;
  int shown = 1, mistakes = 0, hints = 0;
  final Set<int> out = {};

  WordPlay get play => widget.play;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as CluesPuzzle;
    startTicker();
  }

  void _more() {
    if (ended || shown >= 5) return;
    play.ctx.sfx(Sfx.tap);
    setState(() => shown++);
  }

  void _pick(int i) {
    if (ended || out.contains(i)) return;
    if (i == p.answer) {
      ended = true;
      play.ctx.sfx(Sfx.win);
      setState(() => shown = 5);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          play.win(
            score: math.max(50, 600 - (shown - 1) * 90 - mistakes * 80 - hints * 60),
            stars: mistakes == 0 && hints == 0 ? (shown <= 2 ? 3 : (shown <= 4 ? 2 : 1)) : 1,
            seconds: seconds,
            hints: hints,
            stats: {'words_found': 5},
          );
        }
      });
      return;
    }
    play.ctx.sfx(Sfx.error);
    setState(() {
      mistakes++;
      out.add(i);
      if (shown < 5) shown++;
    });
    flash(kt(play.lang, 'wrong'));
    if (mistakes >= p.lives) {
      ended = true;
      play.ctx.sfx(Sfx.lose);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) play.lose(seconds: seconds, hints: hints, headline: p.options[p.answer]);
      });
    }
  }

  Future<void> _hint() async {
    if (ended) return;
    final wrong = [for (var i = 0; i < p.options.length; i++) if (i != p.answer && !out.contains(i)) i];
    if (wrong.isEmpty) return;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    setState(() {
      hints++;
      out.add(wrong.first);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lx = play.lx;
    final lang = play.lang;
    return Column(children: [
      WordBar(play: play, left: clock(), status: '${kt(lang, 'mistakes')}: $mistakes/${p.lives}', onHint: _hint),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text(kt(lang, 'whatCategory'),
            textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
      ),
      flashLine(),
      Expanded(
        child: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          for (var k = 0; k < 5; k++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: k < shown ? WColors.tile : WColors.soft.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: k < shown ? WColors.marks[k] : Colors.white24, width: 2),
              ),
              child: Row(children: [
                CircleAvatar(radius: 13, backgroundColor: WColors.marks[k], child: Text('${k + 1}', style: const TextStyle(color: WColors.ink, fontWeight: FontWeight.w900))),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(k < shown ? lx.up(p.clues[k]) : '?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: k < shown ? WColors.ink : Colors.white54)),
                ),
              ]),
            ),
          const SizedBox(height: 6),
          Center(
            child: TextButton.icon(
              onPressed: ended || shown >= 5 ? null : _more,
              icon: const Icon(Icons.add_circle_outline),
              label: Text(kt(lang, 'moreClue')),
            ),
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
          for (var i = 0; i < p.options.length; i++)
            Opacity(
              opacity: out.contains(i) ? 0.35 : 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ended && i == p.answer ? WColors.hit : WColors.tile,
                  foregroundColor: ended && i == p.answer ? Colors.white : WColors.ink,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: out.contains(i) || ended ? null : () => _pick(i),
                child: Text(p.options[i], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
        ]),
      ),
    ]);
  }
}

// ======================================================================
// Harf Kutusu: kare kenarlarındaki 12 harfle zincir kelimeler. Art arda iki
// harf aynı kenardan seçilmez; her kelime öncekinin son harfiyle başlar.
// Bütün harfleri kelime sınırı içinde kullan.

class BoxPuzzle extends WPuzzle {
  final List<List<String>> sides; // 4 × 3
  final List<String> solution;
  final int limit;
  const BoxPuzzle(this.sides, this.solution, this.limit);

  int sideOf(String ch) {
    for (var s = 0; s < 4; s++) {
      if (sides[s].contains(ch)) return s;
    }
    return -1;
  }
}

/// Harf Kutusu'nun içerik dilleri.
final kBoxLangs = [for (final l in kAllWordLangs) if (l != 'vi' && l != 'th') l];

class BoxKind extends WordKind {
  const BoxKind();

  @override
  String get id => 'harf-kutusu';

  /// Harf dilleri (Vietnamca ve Tay dilinde hece taşlarıyla on iki taşlık
  /// zincir kurulamaz; taş dillerinden yalnızca kurulabilenler).
  @override
  List<String>? get contentLangs => kBoxLangs;

  static int limitFor(int d) => const [6, 6, 5, 5, 5, 4, 4, 4, 3, 3][d - 1];

  /// Kelime kutuya uyar mı: art arda aynı harf yok.
  static bool _ok(String w) {
    for (var i = 1; i < w.length; i++) {
      if (w[i] == w[i - 1]) return false;
    }
    return true;
  }

  /// 12 harfi 4 kenara, art arda gelen harfler ayrı kenarda olacak biçimde
  /// dağıt (her kenarda 3 harf).
  static List<List<String>>? arrange(List<String> words, SeededRandom r) {
    final letters = {for (final w in words) ...w.split('')}.toList();
    if (letters.length != 12) return null;
    final adj = {for (final l in letters) l: <String>{}};
    for (final w in words) {
      for (var i = 1; i < w.length; i++) {
        adj[w[i]]!.add(w[i - 1]);
        adj[w[i - 1]]!.add(w[i]);
      }
    }
    r.shuffle(letters);
    letters.sort((a, b) => adj[b]!.length.compareTo(adj[a]!.length));
    final side = <String, int>{};
    final count = [0, 0, 0, 0];
    var steps = 0;
    bool go(int i) {
      if (++steps > 20000) return false;
      if (i == letters.length) return true;
      final l = letters[i];
      final order = [0, 1, 2, 3];
      r.shuffle(order);
      for (final s in order) {
        if (count[s] >= 3) continue;
        if (adj[l]!.any((x) => side[x] == s)) continue;
        side[l] = s;
        count[s]++;
        if (go(i + 1)) return true;
        side.remove(l);
        count[s]--;
      }
      return false;
    }

    if (!go(0)) return null;
    return [
      for (var s = 0; s < 4; s++) [for (final l in letters) if (side[l] == s) l]
    ];
  }

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final maxWords = lx.tiled ? 4 : 3;
    final pool = [for (final w in lx.poolFit(4, 9, d)) if (_ok(w) && w.length >= lx.minLen && w.split('').toSet().length >= (lx.tiled ? 2 : 3)) w];
    if (pool.length < 50) return null;
    final byFirst = <String, List<String>>{};
    for (final w in pool) {
      byFirst.putIfAbsent(w[0], () => []).add(w);
    }
    for (var attempt = 0; attempt < 30; attempt++) {
      final w1 = pool[r.nextInt(pool.length)];
      final chain = [w1];
      final used = w1.split('').toSet();
      if (used.length > 12) continue;
      var steps = 0;
      List<String>? found;
      void dfs() {
        if (found != null || ++steps > 600) return;
        if (used.length == 12) {
          found = List.of(chain);
          return;
        }
        if (chain.length >= maxWords) return;
        final next = byFirst[chain.last[chain.last.length - 1]] ?? const <String>[];
        if (next.isEmpty) return;
        final start = r.nextInt(next.length);
        for (var k = 0; k < next.length && k < 160 && found == null; k++) {
          final w = next[(start + k) % next.length];
          if (chain.contains(w)) continue;
          final add = w.split('').where((c) => !used.contains(c)).toSet();
          if (add.isEmpty || used.length + add.length > 12) continue;
          // Son kelime 12'ye tamamlamıyorsa yeterince yeni harf getirmeli.
          if (chain.length == maxWords - 1 && used.length + add.length != 12) continue;
          chain.add(w);
          used.addAll(add);
          dfs();
          if (found == null) {
            chain.removeLast();
            used.removeAll(add);
          }
        }
      }

      dfs();
      final f = found;
      if (f == null) continue;
      final sides = arrange(f, r);
      if (sides == null) continue;
      return BoxPuzzle(sides, f, math.max(limitFor(d), f.length));
    }
    return null;
  }

  @override
  bool check(WPuzzle p, Lexicon lx) {
    if (p is! BoxPuzzle) return false;
    if (p.sides.length != 4 || p.sides.any((s) => s.length != 3)) return false;
    final all = {for (final s in p.sides) ...s};
    if (all.length != 12) return false;
    final covered = <String>{};
    for (var i = 0; i < p.solution.length; i++) {
      final w = p.solution[i];
      if (!lx.has(w)) return false;
      if (i > 0 && w[0] != p.solution[i - 1][p.solution[i - 1].length - 1]) return false;
      for (var k = 0; k < w.length; k++) {
        final s = p.sideOf(w[k]);
        if (s < 0) return false;
        if (k > 0 && s == p.sideOf(w[k - 1])) return false;
        covered.add(w[k]);
      }
    }
    return covered.length == 12 && p.solution.length <= p.limit;
  }

  @override
  Widget build(WordPlay play) => _BoxView(play: play);
}

class _BoxView extends StatefulWidget {
  final WordPlay play;
  const _BoxView({required this.play});

  @override
  State<_BoxView> createState() => _BoxViewState();
}

class _BoxViewState extends State<_BoxView> with SecondsTicker, Flash {
  late BoxPuzzle p;
  final List<String> words = [];
  String cur = '';
  int hints = 0, mistakes = 0;

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as BoxPuzzle;
    final saved = play.resume['words'];
    if (saved is List) words.addAll(saved.whereType<String>());
    cur = words.isEmpty ? '' : words.last[words.last.length - 1];
    startTicker();
  }

  Set<String> get used => {for (final w in words) ...w.split('')};

  void _tapLetter(String ch) {
    if (ended) return;
    if (cur.isNotEmpty && p.sideOf(cur[cur.length - 1]) == p.sideOf(ch)) {
      play.ctx.sfx(Sfx.error);
      flash(kt(play.lang, 'sameSide'));
      return;
    }
    play.ctx.sfx(Sfx.tap);
    setState(() => cur += ch);
  }

  void _back() {
    if (ended) return;
    setState(() {
      if (cur.length > 1 || (cur.length == 1 && words.isEmpty)) {
        cur = cur.substring(0, cur.length - 1);
      } else if (words.isNotEmpty) {
        // Önceki kelimeyi geri aç.
        cur = words.removeLast();
      }
    });
  }

  void _submit() {
    if (ended) return;
    if (cur.length < lx.minLen) {
      flash(kt(play.lang, 'short'));
      return;
    }
    if (!lx.has(cur)) {
      play.ctx.sfx(Sfx.error);
      setState(() => mistakes++);
      flash(kt(play.lang, 'notWord'));
      return;
    }
    play.ctx.sfx(Sfx.combo);
    setState(() {
      words.add(cur);
      cur = cur[cur.length - 1];
    });
    play.save({'words': words});
    if (used.length == 12) {
      ended = true;
      play.ctx.sfx(Sfx.win);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          play.win(
            score: math.max(60, 700 - (words.length - p.solution.length) * 80 - hints * 90),
            stars: hints == 0 && words.length <= p.solution.length ? 3 : (hints <= 1 ? 2 : 1),
            seconds: seconds,
            hints: hints,
            stats: {'words_found': words.length},
          );
        }
      });
    } else if (words.length >= p.limit) {
      ended = true;
      play.ctx.sfx(Sfx.lose);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) play.lose(seconds: seconds, hints: hints, headline: p.solution.map(lx.up).join(' → '));
      });
    }
  }

  Future<void> _hint() async {
    if (ended) return;
    var k = 0;
    while (k < words.length && k < p.solution.length && words[k] == p.solution[k]) {
      k++;
    }
    if (k >= p.solution.length) return;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    setState(() {
      hints++;
      words
        ..clear()
        ..addAll(p.solution.take(k));
      cur = p.solution[k];
    });
  }

  void _restart() {
    if (ended) return;
    setState(() {
      words.clear();
      cur = '';
    });
  }

  Offset _pos(int side, int k, double s) {
    final t = (k + 1) / 4;
    return switch (side) {
      0 => Offset(s * t, 0),
      1 => Offset(s, s * t),
      2 => Offset(s * (1 - t), s),
      _ => Offset(0, s * (1 - t)),
    };
  }

  @override
  Widget build(BuildContext context) {
    final lang = play.lang;
    final u = used;
    final rtl = _rtl.contains(lx.lang);
    return Column(children: [
      WordBar(play: play, left: clock(), status: '${words.length}/${p.limit}', onHint: _hint),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(kt(lang, 'sameSide'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
      ),
      flashLine(),
      Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          child: Text(cur.isEmpty ? '·' : lx.up(cur), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
        ),
      ),
      Wrap(spacing: 6, children: [
        for (final w in words)
          Chip(label: Text(lx.up(w), style: const TextStyle(fontWeight: FontWeight.w700)), visualDensity: VisualDensity.compact),
      ]),
      Expanded(
        child: LayoutBuilder(builder: (context, box) {
          final s = math.min(box.maxWidth - 80, box.maxHeight - 60).clamp(120.0, 420.0);
          final r = math.max(18.0, s * 0.075);
          final last = cur.isEmpty ? null : cur[cur.length - 1];
          return Center(
            child: SizedBox(
              width: s + r * 2,
              height: s + r * 2,
              child: Stack(children: [
                Positioned(
                  left: r,
                  top: r,
                  child: CustomPaint(size: Size(s, s), painter: _BoxPainter(cur, p, (side, k) => _pos(side, k, s))),
                ),
                for (var side = 0; side < 4; side++)
                  for (var k = 0; k < 3; k++)
                    () {
                      final ch = p.sides[side][k];
                      final o = _pos(side, k, s);
                      final isLast = ch == last;
                      return Positioned(
                        left: o.dx,
                        top: o.dy,
                        child: GestureDetector(
                          onTap: () => _tapLetter(ch),
                          child: Container(
                            width: r * 2,
                            height: r * 2,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isLast ? WColors.warm : (u.contains(ch) || cur.contains(ch) ? WColors.hit : WColors.tile),
                              border: Border.all(color: WColors.ink, width: 2),
                            ),
                            child: Text(lx.upCh(ch),
                                style: TextStyle(fontSize: r * 0.9, fontWeight: FontWeight.w900, color: isLast || u.contains(ch) || cur.contains(ch) ? Colors.white : WColors.ink)),
                          ),
                        ),
                      );
                    }(),
              ]),
            ),
          );
        }),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton.filledTonal(tooltip: kt(lang, 'clear'), onPressed: _restart, icon: const Icon(Icons.restart_alt)),
          const SizedBox(width: 8),
          IconButton.filledTonal(tooltip: kt(lang, 'undo'), onPressed: _back, icon: const Icon(Icons.backspace_outlined)),
          const SizedBox(width: 8),
          BigButton(label: kt(lang, 'submit'), onPressed: cur.length >= lx.minLen ? _submit : null),
        ]),
      ),
    ]);
  }
}

/// Kutunun kenarları ve yazılan kelimenin çizgisi.
class _BoxPainter extends CustomPainter {
  final String cur;
  final BoxPuzzle p;
  final Offset Function(int side, int k) pos;
  _BoxPainter(this.cur, this.p, this.pos);

  Offset _of(String ch) {
    for (var s = 0; s < 4; s++) {
      final k = p.sides[s].indexOf(ch);
      if (k >= 0) return pos(s, k);
    }
    return Offset.zero;
  }

  @override
  void paint(Canvas c, Size size) {
    c.drawRect(Offset.zero & size, Paint()..color = WColors.paper);
    c.drawRect(
        Offset.zero & size,
        Paint()
          ..color = WColors.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
    if (cur.length < 2) return;
    final path = Path()..moveTo(_of(cur[0]).dx, _of(cur[0]).dy);
    for (var i = 1; i < cur.length; i++) {
      final o = _of(cur[i]);
      path.lineTo(o.dx, o.dy);
    }
    c.drawPath(
        path,
        Paint()
          ..color = WColors.warm
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(covariant _BoxPainter old) => old.cur != cur;
}
