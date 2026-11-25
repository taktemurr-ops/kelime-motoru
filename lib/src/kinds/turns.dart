import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:studio_core/app/services/audio.dart';
import 'package:studio_core/core/rng.dart';

import '../core.dart';
import '../texts.dart';
import '../ui.dart';
import '../words.dart';

// ---------------------------------------------------------------- Çiçek tahmini

/// Harf tahmini: gizli kelimeyi yaprakları dökülmeden bul.
class PetalPuzzle extends WPuzzle {
  final String word;
  final int lives;
  final List<int> shown;
  const PetalPuzzle(this.word, this.lives, this.shown);
}

class PetalKind extends WordKind {
  @override
  String get id => 'adam-asmaca';
  const PetalKind();

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final len = 5 + math.min<int>(4, d ~/ 2);
    final pool = lx.pool(len, d);
    if (pool.isEmpty) return null;
    final w = r.pick(pool);
    final lives = d <= 3 ? 7 : (d <= 7 ? 6 : 5);
    return PetalPuzzle(w, lives, d <= 2 ? [0] : const []);
  }

  @override
  bool check(WPuzzle p, Lexicon lx) => p is PetalPuzzle && lx.has(p.word) && p.lives > 0;

  @override
  Widget build(WordPlay play) => _PetalView(play: play);
}

class _PetalView extends StatefulWidget {
  final WordPlay play;
  const _PetalView({required this.play});

  @override
  State<_PetalView> createState() => _PetalViewState();
}

class _PetalViewState extends State<_PetalView> with SecondsTicker, Flash {
  late PetalPuzzle p;
  final Set<String> tried = {};
  int hints = 0;

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as PetalPuzzle;
    for (final i in p.shown) {
      tried.add(p.word[i]);
    }
    final t = play.resume['t'];
    if (t is List) tried.addAll([for (final x in t) '$x']);
    hints = (play.resume['hn'] as num?)?.toInt() ?? 0;
    startTicker((play.resume['s'] as num?)?.toInt() ?? 0);
  }

  int get wrong => tried.where((c) => !p.word.contains(c)).length;
  bool get solved => p.word.split('').every(tried.contains);

  void _key(String ch) {
    if (ended || tried.contains(ch)) return;
    setState(() => tried.add(ch));
    play.save({'t': tried.toList(), 'hn': hints, 's': seconds});
    if (p.word.contains(ch)) {
      play.ctx.sfx(Sfx.place);
    } else {
      play.ctx.sfx(Sfx.error);
    }
    if (solved) {
      ended = true;
      play.ctx.sfx(Sfx.win);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          play.win(
            score: 200 + (p.lives - wrong) * 80 - hints * 50,
            stars: starsFor(hints: hints, mistakes: wrong ~/ 2),
            seconds: seconds,
            hints: hints,
            moves: tried.length,
            stats: {'words_found': 1},
          );
        }
      });
    } else if (wrong >= p.lives) {
      ended = true;
      play.ctx.sfx(Sfx.lose);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) play.lose(seconds: seconds, hints: hints, headline: '${kt(play.lang, 'answer')}: ${lx.up(p.word)}');
      });
    }
  }

  Future<void> _hint() async {
    if (ended) return;
    final missing = p.word.split('').where((c) => !tried.contains(c)).toList();
    if (missing.isEmpty) return;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    setState(() => hints++);
    _key(missing.first);
  }

  @override
  Widget build(BuildContext context) {
    final colors = <String, Color>{for (final c in tried) c: p.word.contains(c) ? WColors.hit : WColors.miss};
    return Column(children: [
      WordBar(play: play, left: clock(), status: '${kt(play.lang, 'tries')}: ${p.lives - wrong}', onHint: _hint),
      flashLine(),
      Expanded(
        child: LayoutBuilder(builder: (context, box) {
          final s = math.min(box.maxWidth, box.maxHeight * 0.6);
          return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(width: s * 0.7, height: s * 0.7, child: CustomPaint(painter: _FlowerPainter(p.lives, p.lives - wrong))),
            const SizedBox(height: 12),
            Wrap(spacing: 4, children: [
              for (var i = 0; i < p.word.length; i++)
                LetterTile(
                  letter: tried.contains(p.word[i]) || ended ? lx.upCh(p.word[i]) : '',
                  size: math.min(46.0, (box.maxWidth - 30) / p.word.length - 4),
                  fill: tried.contains(p.word[i]) ? null : WColors.paper,
                ),
            ]),
          ]);
        }),
      ),
      WordKeyboard(lx: lx, onKey: _key, onEnter: () {}, onBack: () {}, colors: colors, showEnter: false),
      const SizedBox(height: 6),
    ]);
  }
}

/// Yapraklı çiçek: her yanlış tahminde bir yaprak düşer.
class _FlowerPainter extends CustomPainter {
  final int total, left;
  _FlowerPainter(this.total, this.left);

  @override
  void paint(Canvas c, Size s) {
    final o = Offset(s.width / 2, s.height * 0.42);
    final r = s.width * 0.18;
    c.drawLine(o, Offset(o.dx, s.height), Paint()
      ..color = const Color(0xFF5B8C51)
      ..strokeWidth = s.width * 0.04);
    c.drawOval(Rect.fromCenter(center: Offset(o.dx + s.width * 0.12, s.height * 0.8), width: s.width * 0.22, height: s.width * 0.1),
        Paint()..color = const Color(0xFF6FA35F));
    for (var i = 0; i < total; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / total;
      final pc = o + Offset(math.cos(a), math.sin(a)) * r * 1.25;
      final paint = Paint()..color = i < left ? WColors.marks[(i * 3) % WColors.marks.length] : Colors.black12;
      c.save();
      c.translate(pc.dx, pc.dy);
      c.rotate(a + math.pi / 2);
      c.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 0.95, height: r * 1.6), paint);
      c.restore();
    }
    c.drawCircle(o, r * 0.75, Paint()..color = const Color(0xFFF2C14E));
  }

  @override
  bool shouldRepaint(covariant _FlowerPainter old) => old.left != left;
}

// ---------------------------------------------------------------- Kelime merdiveni

/// Bir harf değiştirerek başlangıç kelimesinden hedefe ulaş.
class LadderPuzzle extends WPuzzle {
  final String start, goal;
  final List<String> path;
  const LadderPuzzle(this.start, this.goal, this.path);
}

bool oneApart(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i] && ++diff > 1) return false;
  }
  return diff == 1;
}

class LadderKind extends WordKind {
  @override
  String get id => 'kelime-merdiveni';
  const LadderKind();

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final len = d <= 6 ? 4 : 5;
    final words = lx.ofLength(len);
    final pool = words.sublist(0, math.min(words.length, 1200 + d * 150));
    if (pool.length < 50) return null;
    final want = 3 + d ~/ 2;
    final set = pool.toSet();
    final start = r.pick(pool.sublist(0, math.min(pool.length, 400)));
    // Genişlik öncelikli arama.
    final prev = <String, String>{start: ''};
    var frontier = [start];
    var best = <String>[];
    var reached = 0;
    for (var depth = 0; depth < want && frontier.isNotEmpty; depth++) {
      final nxt = <String>[];
      for (final w in frontier) {
        for (var i = 0; i < len; i++) {
          for (final ch in lx.letters) {
            if (ch == w[i]) continue;
            final cand = w.substring(0, i) + ch + w.substring(i + 1);
            if (set.contains(cand) && !prev.containsKey(cand)) {
              prev[cand] = w;
              nxt.add(cand);
            }
          }
        }
      }
      frontier = nxt;
      if (nxt.isNotEmpty) {
        best = nxt;
        reached = depth + 1;
      }
    }
    // Hedef derinliğe ulaşılamazsa en az üç adımlık en uzak kelime.
    if (reached < math.min(3, want)) return null;
    final goal = r.pick(best);
    final path = <String>[goal];
    while (prev[path.last]!.isNotEmpty) {
      path.add(prev[path.last]!);
    }
    return LadderPuzzle(start, goal, path.reversed.toList());
  }

  @override
  bool check(WPuzzle p, Lexicon lx) {
    if (p is! LadderPuzzle || p.path.length < 3) return false;
    for (var i = 1; i < p.path.length; i++) {
      if (!oneApart(p.path[i - 1], p.path[i]) || !lx.has(p.path[i])) return false;
    }
    return p.path.first == p.start && p.path.last == p.goal;
  }

  @override
  Widget build(WordPlay play) => _LadderView(play: play);
}

class _LadderView extends StatefulWidget {
  final WordPlay play;
  const _LadderView({required this.play});

  @override
  State<_LadderView> createState() => _LadderViewState();
}

class _LadderViewState extends State<_LadderView> with SecondsTicker, Flash {
  late LadderPuzzle p;
  final List<String> steps = [];
  String input = '';
  int hints = 0, mistakes = 0;

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;
  String get last => steps.isEmpty ? p.start : steps.last;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as LadderPuzzle;
    final s = play.resume['st'];
    if (s is List) steps.addAll([for (final x in s) '$x']);
    hints = (play.resume['hn'] as num?)?.toInt() ?? 0;
    startTicker((play.resume['s'] as num?)?.toInt() ?? 0);
  }

  void _enter() {
    if (ended) return;
    final w = input;
    if (w.length != p.start.length) return flash(kt(play.lang, 'short'));
    if (!oneApart(last, w)) {
      mistakes++;
      play.ctx.sfx(Sfx.error);
      return flash(kt(play.lang, 'wrong'));
    }
    if (!lx.has(w)) {
      play.ctx.sfx(Sfx.error);
      return flash(kt(play.lang, 'notWord'));
    }
    _accept(w);
  }

  void _accept(String w) {
    setState(() {
      steps.add(w);
      input = '';
    });
    play.ctx.sfx(Sfx.place);
    play.save({'st': steps, 'hn': hints, 's': seconds});
    if (w == p.goal) {
      ended = true;
      play.ctx.sfx(Sfx.win);
      final best = p.path.length - 1;
      final extra = steps.length - best;
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          play.win(
            score: 300 - extra * 30 - hints * 50,
            stars: math.min(starsFor(hints: hints, mistakes: mistakes), extra <= 0 ? 3 : (extra <= 2 ? 2 : 1)),
            seconds: seconds,
            moves: steps.length,
            hints: hints,
            stats: {'words_found': steps.length},
          );
        }
      });
    }
  }

  Future<void> _hint() async {
    if (ended) return;
    // En kısa yoldaki bir sonraki adım; yoldan çıkıldıysa son kelimeden aranır.
    String? next;
    final i = p.path.indexOf(last);
    if (i >= 0 && i + 1 < p.path.length) {
      next = p.path[i + 1];
    } else {
      for (final w in p.path) {
        if (oneApart(last, w)) next = w;
      }
    }
    if (next == null) {
      setState(() => steps.clear());
      return;
    }
    final word = next;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    setState(() => hints++);
    _accept(word);
  }

  Widget _row(String w, {Color? fill, bool ghost = false}) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (var i = 0; i < p.start.length; i++)
          Padding(
            padding: const EdgeInsets.all(2),
            child: LetterTile(
              letter: i < w.length ? lx.upCh(w[i]) : '',
              size: 40,
              fill: fill,
              raised: !ghost,
            ),
          ),
      ]);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      WordBar(
        play: play,
        left: clock(),
        status: '${lx.up(p.start)} → ${lx.up(p.goal)}  ·  ${steps.length}/${p.path.length - 1}',
        onHint: _hint,
        actions: [
          IconButton(
            tooltip: kt(play.lang, 'undo'),
            onPressed: steps.isEmpty || ended ? null : () => setState(() => steps.removeLast()),
            icon: const Icon(Icons.undo),
          ),
        ],
      ),
      flashLine(),
      Expanded(
        child: SingleChildScrollView(
          reverse: true,
          child: Column(children: [
            _row(p.start, fill: WColors.soft),
            for (final s in steps) _row(s, fill: s == p.goal ? WColors.hit : null),
            if (!ended) _row(input, fill: WColors.paper, ghost: true),
            const SizedBox(height: 10),
            Opacity(opacity: 0.8, child: _row(p.goal, fill: WColors.near)),
          ]),
        ),
      ),
      WordKeyboard(
        lx: lx,
        onKey: (ch) {
          if (ended || input.length >= p.start.length) return;
          setState(() => input += ch);
        },
        onEnter: _enter,
        onBack: () => setState(() {
          if (input.isNotEmpty) input = input.substring(0, input.length - 1);
        }),
      ),
      const SizedBox(height: 6),
    ]);
  }
}

// ---------------------------------------------------------------- Kelime zinciri

/// Son harfle başlayan kelimeyi sırayla söyle: rakiple karşılıklı.
class ChainPuzzle extends WPuzzle {
  final String start;
  final int need;
  final int turnTime;
  const ChainPuzzle(this.start, this.need, this.turnTime);
}

/// Sonraki kelimenin başlayacağı harf: sondan geriye, kelime başlatabilen ilk harf.
String chainLetter(Lexicon lx, String w) {
  for (var i = w.length - 1; i >= 0; i--) {
    final ch = w[i];
    if (lx.words.any((x) => x.startsWith(ch))) return ch;
  }
  return w[0];
}

class ChainKind extends WordKind {
  @override
  String get id => 'kelime-zinciri';
  const ChainKind();

  @override
  int get players => 2;

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final w = r.pick(lx.pool(5, d));
    return ChainPuzzle(w, 5 + d ~/ 2, 30 - d * 2);
  }

  @override
  bool check(WPuzzle p, Lexicon lx) => p is ChainPuzzle && lx.has(p.start);

  @override
  Widget build(WordPlay play) => _ChainView(play: play);
}

class _ChainView extends StatefulWidget {
  final WordPlay play;
  const _ChainView({required this.play});

  @override
  State<_ChainView> createState() => _ChainViewState();
}

class _ChainViewState extends State<_ChainView> with SecondsTicker, Flash {
  late ChainPuzzle p;
  final List<String> chain = [];
  final List<bool> mine = [];
  String input = '';
  int turnStart = 0;
  int hints = 0;
  late SeededRandom botRng;
  bool botThinking = false;

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;
  int get myCount => mine.where((x) => x).length;
  int get rivalCount => mine.skip(1).where((x) => !x).length;
  String get need => chainLetter(lx, chain.last);
  WordNet? get net => play.net;
  bool get online => net != null && !net!.oppGone;
  int _oi = 0;

  /// Çevrimiçinde rakibin süresi dolduktan sonra tanınan pay (ağ gecikmesi).
  static const _grace = 15;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as ChainPuzzle;
    chain.add(p.start);
    mine.add(false);
    botRng = SeededRandom(play.seed ^ 0x5151);
    final n = net;
    if (n != null) {
      n.listen(_onNet);
      _replay();
    }
    startTicker();
  }

  @override
  void dispose() {
    net?.unlisten(_onNet);
    super.dispose();
  }

  /// Bir hamle geçerli mi ("W:kelime").
  String? _valid(String mv) {
    if (!mv.startsWith('W:')) return null;
    final w = mv.substring(2);
    if (w.length < 3 || !w.startsWith(need) || chain.contains(w) || !lx.has(w)) return null;
    return w;
  }

  void _replay() {
    final n = net!;
    var seat = 0, im = 0;
    while (!ended) {
      final list = seat == n.me ? n.mine : n.theirs;
      final i = seat == n.me ? im : _oi;
      if (i >= list.length) break;
      if (seat == n.me) {
        im++;
      } else {
        _oi++;
      }
      final mv = list[i];
      final w = _valid(mv);
      if (w == null) {
        // Süre doldu ("T"): sırası gelen kaybeder.
        WidgetsBinding.instance.addPostFrameCallback((_) => _end(seat != n.me));
        ended = true;
        return;
      }
      chain.add(w);
      mine.add(seat == n.me);
      if ((seat == n.me ? myCount : rivalCount) >= p.need) {
        final won = seat == n.me;
        WidgetsBinding.instance.addPostFrameCallback((_) => _end(won));
        ended = true;
        return;
      }
      seat = 1 - seat;
    }
    botThinking = seat != n.me;
  }

  void _onNet() {
    final n = net;
    if (n == null || !mounted || ended || !botThinking || _oi >= n.theirs.length) return;
    final w = _valid(n.theirs[_oi++]);
    if (w == null) return _end(true);
    setState(() {
      chain.add(w);
      mine.add(false);
      botThinking = false;
      turnStart = seconds;
    });
    play.ctx.sfx(Sfx.tap);
    if (rivalCount >= p.need) _end(false);
  }

  @override
  void onTick() {
    if (ended) return;
    if (botThinking) {
      final n = net;
      if (n == null) return;
      if (n.oppGone) {
        // Rakip koptu: sıra bilgisayarda.
        _botTurn();
      } else if (seconds - turnStart >= p.turnTime + _grace) {
        _end(true);
      }
      return;
    }
    if (seconds - turnStart >= p.turnTime) {
      net?.send('T');
      _end(false);
    }
  }

  /// Oyun bitti: çevrimiçinde iki koltuğa sonuç, çevrimdışında eski kural.
  void _end(bool won) {
    if (ended && net == null) return;
    ended = true;
    final n = net;
    if (n != null) n.finish(won ? n.me : n.opp);
    if (won) return _win();
    play.ctx.sfx(Sfx.lose);
    play.lose(seconds: seconds, hints: hints, stats: {'words_found': myCount}, headline: '${kt(play.lang, 'found')}: $myCount/${p.need}');
  }

  String? _botWord() {
    final ch = need;
    final opts = [for (final w in lx.words.take(5000)) if (w.startsWith(ch) && !chain.contains(w)) w];
    if (opts.isEmpty) return null;
    return opts[botRng.nextInt(math.min(opts.length, 60))];
  }

  bool _botBusy = false;

  void _botTurn() {
    if (_botBusy) return;
    _botBusy = true;
    Future.delayed(Duration(milliseconds: 700 + botRng.nextInt(900)), () {
      _botBusy = false;
      if (!mounted || ended) return;
      final b = _botWord();
      if (b == null) return _end(true);
      setState(() {
        chain.add(b);
        mine.add(false);
        botThinking = false;
        turnStart = seconds;
      });
      play.ctx.sfx(Sfx.tap);
      if (net != null && rivalCount >= p.need) _end(false);
    });
  }

  void _enter() {
    if (ended || botThinking) return;
    final w = input;
    setState(() => input = '');
    if (w.length < 3) return flash(kt(play.lang, 'short'));
    if (!w.startsWith(need)) {
      play.ctx.sfx(Sfx.error);
      return flash('${lx.upCh(need)}…');
    }
    if (chain.contains(w)) return flash(kt(play.lang, 'already'));
    if (!lx.has(w)) {
      play.ctx.sfx(Sfx.error);
      return flash(kt(play.lang, 'notWord'));
    }
    net?.send('W:$w');
    setState(() {
      chain.add(w);
      mine.add(true);
      botThinking = true;
      turnStart = seconds;
    });
    play.ctx.sfx(Sfx.place);
    if (myCount >= p.need) return _end(true);
    if (online) return _onNet();
    _botTurn();
  }

  void _win() {
    ended = true;
    play.ctx.sfx(Sfx.win);
    play.win(score: 200 + myCount * 40 - hints * 40, stars: starsFor(hints: hints), seconds: seconds, hints: hints, stats: {'words_found': myCount});
  }

  Future<void> _hint() async {
    if (ended || botThinking) return;
    final ch = need;
    String? w;
    for (final x in lx.words) {
      if (x.startsWith(ch) && !chain.contains(x) && x.length >= 3) {
        w = x;
        break;
      }
    }
    if (w == null) return;
    final word = w;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    setState(() {
      hints++;
      input = word;
    });
  }

  @override
  Widget build(BuildContext context) {
    final left = math.max(0, p.turnTime - (seconds - turnStart));
    return Column(children: [
      WordBar(
        play: play,
        left: botThinking ? '…' : clock(left),
        status: net != null
            ? '${kt(play.lang, botThinking ? 'rivalTurn' : 'yourTurn')} · ${kt(play.lang, 'you')} $myCount/${p.need} · ${kt(play.lang, 'rival')} $rivalCount'
            : '${kt(play.lang, 'found')}: $myCount/${p.need}',
        onHint: _hint,
      ),
      flashLine(),
      Expanded(
        child: ListView(reverse: true, padding: const EdgeInsets.all(8), children: [
          for (var i = chain.length - 1; i >= 0; i--)
            Align(
              alignment: mine[i] ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: mine[i] ? WColors.accent : WColors.paper,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(lx.up(chain[i]),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: mine[i] ? Colors.white : WColors.ink)),
              ),
            ),
        ]),
      ),
      Container(
        height: 50,
        alignment: Alignment.center,
        child: Text(input.isEmpty ? '${lx.upCh(need)}…' : lx.up(input),
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: input.isEmpty ? WColors.miss : WColors.ink)),
      ),
      WordKeyboard(
        lx: lx,
        onKey: (ch) {
          if (ended || input.length >= 12) return;
          setState(() => input += ch);
        },
        onEnter: _enter,
        onBack: () => setState(() {
          if (input.isNotEmpty) input = input.substring(0, input.length - 1);
        }),
      ),
      const SizedBox(height: 6),
    ]);
  }
}
