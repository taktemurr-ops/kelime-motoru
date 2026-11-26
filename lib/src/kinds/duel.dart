import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:studio_core/app/services/audio.dart';
import 'package:studio_core/core/rng.dart';

import '../core.dart';
import '../studio_chrome.dart';
import '../texts.dart';
import '../ui.dart';
import '../words.dart';
import 'bank_base.dart';

int wordValue(Lexicon lx, String w) => w.split('').fold<int>(0, (a, ch) => a + lx.letterValue(ch));

/// Kelime düellosu: aynı harflerle rakibe karşı, turlar halinde.
class DuelRound {
  final List<String> letters;
  final List<String> valid;
  final List<String> botWords;
  final List<int> botTimes;
  const DuelRound(this.letters, this.valid, this.botWords, this.botTimes);
}

class DuelPuzzle extends WPuzzle {
  final List<DuelRound> rounds;
  final int roundTime;
  const DuelPuzzle(this.rounds, this.roundTime);
}

class DuelKind extends WordKind {
  @override
  String get id => 'duello';
  const DuelKind();

  @override
  int get players => 2;

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final rounds = <DuelRound>[];
    const time = 60;
    for (var k = 0; k < 3; k++) {
      // Taş dillerinde raf birkaç kelimenin taşlarından kurulur.
      final rack = lx.tiled ? tileRack(lx, 8, d, r) : scramble(r.pick(lx.pool(7, d)), r);
      final valid = spellable(lx, letterCounts(rack.join()), minLen: lx.minLen);
      if (valid.length < 6) return null;
      final frac = 0.16 + d * 0.045;
      final n = math.max(2, (valid.length * frac).round());
      final bot = <String>[];
      // Sık kelimeleri daha olası seç.
      for (final w in valid) {
        if (bot.length >= n) break;
        if (r.chance(0.35 + d * 0.05)) bot.add(w);
      }
      if (bot.isEmpty) bot.add(valid.first);
      final times = [for (var i = 0; i < bot.length; i++) 4 + r.nextInt(time - 6)]..sort();
      rounds.add(DuelRound(rack, valid, bot, times));
    }
    return DuelPuzzle(rounds, time);
  }

  @override
  bool check(WPuzzle p, Lexicon lx) =>
      p is DuelPuzzle && p.rounds.length == 3 && p.rounds.every((rd) => rd.valid.isNotEmpty && rd.botWords.every(rd.valid.contains));

  @override
  Widget build(WordPlay play) => _DuelView(play: play);
}

class _DuelView extends StatefulWidget {
  final WordPlay play;
  const _DuelView({required this.play});

  @override
  State<_DuelView> createState() => _DuelViewState();
}

class _DuelViewState extends State<_DuelView> with SecondsTicker, Flash {
  late DuelPuzzle p;
  int round = 0;
  int roundStart = 0;
  final List<String> found = [];
  late List<String> letters;
  List<int> picked = [];
  int myTotal = 0, botTotal = 0;
  bool between = false;

  /// Çevrimiçi: bu turun sonucu gönderildi, rakibinki bekleniyor.
  bool waiting = false;
  int myRound = 0;
  final Map<int, List<String>> rivalWords = {};

  WordPlay get play => widget.play;
  WordNet? get net => play.net;
  bool get online => net != null && !net!.oppGone;
  Lexicon get lx => play.lx;
  DuelRound get rd => p.rounds[round];

  @override
  void initState() {
    super.initState();
    p = play.puzzle as DuelPuzzle;
    letters = List.of(rd.letters);
    net?.listen(_onNet);
    _replay();
    startTicker();
  }

  @override
  void dispose() {
    net?.unlisten(_onNet);
    super.dispose();
  }

  /// Maça geri dönüldüyse gönderilmiş turları yeniden kur.
  void _replay() {
    final n = net;
    if (n == null) return;
    final sent = [for (final m in n.mine) if (m.startsWith('R')) m];
    for (var r = 0; r < sent.length && r < p.rounds.length; r++) {
      round = r;
      letters = List.of(rd.letters);
      found
        ..clear()
        ..addAll(_parse(r, sent[r]) ?? const []);
      myRound = found.fold<int>(0, (a, w) => a + wordValue(lx, w));
      between = true;
      waiting = true;
      _resolve(quiet: true);
      if (waiting) break;
    }
  }

  /// "R<tur>:kelime,kelime" → o turun geçerli kelimeleri.
  List<String>? _parse(int r, String m) {
    final head = 'R$r:';
    if (!m.startsWith(head)) return null;
    final body = m.substring(head.length);
    if (body.isEmpty) return const [];
    final valid = p.rounds[r].valid;
    return [for (final w in body.split(',').toSet()) if (valid.contains(w)) w];
  }

  /// Rakibin bu turdaki kelimeleri: çevrimdışında bilgisayarın, çevrimiçinde rakibin.
  List<String>? _rival(int r) {
    if (!online) return p.rounds[r].botWords;
    for (final m in net!.theirs) {
      final w = _parse(r, m);
      if (w != null) return w;
    }
    return null;
  }

  void _onNet() {
    if (mounted && waiting) setState(() => _resolve());
  }

  int get elapsed => seconds - roundStart;
  List<String> get botSeen => online ? const [] : [for (var i = 0; i < rd.botWords.length; i++) if (rd.botTimes[i] <= elapsed) rd.botWords[i]];
  int get myScore => found.fold<int>(0, (a, w) => a + wordValue(lx, w));
  int get botScore => botSeen.fold<int>(0, (a, w) => a + wordValue(lx, w));

  @override
  void onTick() {
    if (ended) return;
    if (waiting) {
      // Rakip koptuysa bilgisayar sonucu ile devam.
      if (net != null && net!.oppGone) setState(() => _resolve());
      return;
    }
    if (between) return;
    if (elapsed >= p.roundTime) _endRound();
  }

  void _endRound() {
    if (between) return;
    myRound = myScore;
    net?.send('R$round:${found.join(',')}');
    setState(() {
      between = true;
      waiting = true;
      _resolve();
    });
  }

  /// İki tarafın tur sonucu hazırsa puanları işle.
  void _resolve({bool quiet = false}) {
    if (!waiting) return;
    final theirs = _rival(round);
    if (theirs == null) return;
    waiting = false;
    rivalWords[round] = theirs;
    final mine = myRound, bots = theirs.fold<int>(0, (a, w) => a + wordValue(lx, w));
    myTotal += mine;
    botTotal += bots;
    if (!quiet) play.ctx.sfx(mine >= bots ? Sfx.combo : Sfx.error);
    if (round == p.rounds.length - 1) {
      ended = true;
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        final h = '${kt(play.lang, 'you')} $myTotal — ${kt(play.lang, 'rival')} $botTotal';
        final n = net;
        if (n != null) n.finish(myTotal > botTotal ? n.me : (myTotal < botTotal ? n.opp : -1));
        if (myTotal >= botTotal) {
          play.ctx.sfx(Sfx.win);
          final margin = myTotal - botTotal;
          play.win(score: myTotal * 10, stars: margin > botTotal * 0.3 ? 3 : (margin > 5 ? 2 : 1), seconds: seconds, stats: {'words_found': found.length});
        } else {
          play.ctx.sfx(Sfx.lose);
          play.lose(score: myTotal * 10, seconds: seconds, headline: h);
        }
      });
    }
  }

  void _next() {
    if (waiting) return;
    setState(() {
      round++;
      found.clear();
      picked = [];
      letters = List.of(rd.letters);
      roundStart = seconds;
      between = false;
    });
  }

  void _submit() {
    if (ended || between) return;
    final w = picked.map((i) => letters[i]).join();
    setState(() => picked = []);
    if (w.length < lx.minLen) return flash(kt(play.lang, 'short'));
    if (found.contains(w)) return flash(kt(play.lang, 'already'));
    if (!rd.valid.contains(w)) {
      play.ctx.sfx(Sfx.error);
      return flash(kt(play.lang, 'notWord'));
    }
    setState(() => found.add(w));
    play.ctx.sfx(Sfx.clear);
    flash('+${wordValue(lx, w)}');
  }

  @override
  Widget build(BuildContext context) {
    final lang = play.lang;
    final vals = {for (final ch in letters) ch: lx.letterValue(ch)};
    return Column(children: [
      WordBar(
        play: play,
        left: clock(math.max(0, p.roundTime - elapsed)),
        status: '${kt(lang, 'round')} ${round + 1}/${p.rounds.length}   ${kt(lang, 'you')} ${myTotal + (between ? 0 : myScore)} · ${kt(lang, 'rival')} ${botTotal + (between ? 0 : botScore)}',
      ),
      flashLine(),
      Expanded(
        child: Row(children: [
          Expanded(
            child: Panel(
              child: SingleChildScrollView(
                child: Column(children: [
                  Text(kt(lang, 'you'), style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  FoundWords(words: found.reversed.toList(), lx: lx),
                ]),
              ),
            ),
          ),
          Expanded(
            child: Panel(
              child: SingleChildScrollView(
                child: Column(children: [
                  Text(kt(lang, 'rival'), style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  if (waiting)
                    Text(kt(lang, 'waitRival'), textAlign: TextAlign.center)
                  else
                    FoundWords(words: between ? (rivalWords[round] ?? rd.botWords) : botSeen.reversed.toList(), lx: lx),
                ]),
              ),
            ),
          ),
        ]),
      ),
      if (between && waiting)
        Padding(padding: const EdgeInsets.all(16), child: Text(kt(lang, 'waitRival'), style: const TextStyle(fontWeight: FontWeight.w800)))
      else if (between && !ended)
        BigButton(label: kt(lang, 'next'), icon: Icons.arrow_forward, onPressed: _next)
      else
        LetterPad(
          lx: lx,
          letters: letters,
          picked: picked,
          lang: lang,
          values: vals,
          onPick: (i) {
            if (ended || between) return;
            setState(() => picked.add(i));
            play.ctx.sfx(Sfx.tap);
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

/// Harf ve sayı yarışı: harf turunda en uzun kelime, sayı turunda hedef sayı.
class LnRound {
  final bool numbers;
  final List<String> letters;
  final List<int> nums;
  final int target;

  /// Rakibin sonucu: harf turunda kelime, sayı turunda ulaştığı sayı.
  final String botWord;
  final int botValue;
  final String best;
  const LnRound.letters(this.letters, this.botWord, this.best)
      : numbers = false,
        nums = const [],
        target = 0,
        botValue = 0;
  const LnRound.nums(this.nums, this.target, this.botValue)
      : numbers = true,
        letters = const [],
        botWord = '',
        best = '';
}

class LnPuzzle extends WPuzzle {
  final List<LnRound> rounds;
  const LnPuzzle(this.rounds);
}

int lnNumberPoints(int value, int target) {
  final diff = (value - target).abs();
  if (diff == 0) return 10;
  if (diff <= 5) return 7;
  if (diff <= 10) return 5;
  return 0;
}

class LettersNumbersKind extends WordKind {
  @override
  String get id => 'harf-sayi';
  const LettersNumbersKind();

  @override
  int get players => 2;

  LnRound? _letters(Lexicon lx, int d, SeededRandom r) {
    final List<String> ls;
    if (lx.tiled) {
      ls = tileRack(lx, 9, d, r);
    } else {
      final len = 7 + r.nextInt(3);
      final base = r.pick(lx.pool(len, d));
      ls = base.split('');
      while (ls.length < 9) {
        ls.add(lx.randomLetter(r));
      }
      r.shuffle(ls);
    }
    final valid = spellable(lx, letterCounts(ls.join()), minLen: lx.minLen);
    if (valid.isEmpty) return null;
    valid.sort((a, b) => b.length.compareTo(a.length));
    final best = valid.first;
    final drop = d >= 9 ? 0 : (d >= 6 ? 1 : (d >= 3 ? 2 : 3));
    final want = math.max(lx.minLen, best.length - drop - r.nextInt(2));
    final bot = valid.firstWhere((w) => w.length <= want, orElse: () => valid.last);
    return LnRound.letters(ls, bot, best);
  }

  LnRound? _numbers(int d, SeededRandom r) {
    final bigPool = [25, 50, 75, 100];
    r.shuffle(bigPool);
    final big = 1 + r.nextInt(2);
    final nums = <int>[...bigPool.take(big)];
    while (nums.length < 6) {
      nums.add(1 + r.nextInt(10));
    }
    for (var t = 0; t < 60; t++) {
      final order = List.of(nums);
      r.shuffle(order);
      var v = order[0];
      final k = 3 + r.nextInt(3);
      var ok = true;
      for (var i = 1; i < k; i++) {
        final b = order[i];
        switch (r.nextInt(4)) {
          case 0:
            v = v + b;
          case 1:
            if (v - b <= 0) {
              ok = false;
            } else {
              v = v - b;
            }
          case 2:
            v = v * b;
          default:
            if (b == 0 || v % b != 0) {
              ok = false;
            } else {
              v = v ~/ b;
            }
        }
        if (!ok) break;
      }
      if (!ok || v < 101 || v > 999) continue;
      final miss = d >= 8 ? 0 : r.nextInt(12 - d);
      final bot = r.chance(0.5) ? v + miss : v - miss;
      r.shuffle(nums);
      return LnRound.nums(nums, v, bot);
    }
    return null;
  }

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final rounds = <LnRound>[];
    for (var i = 0; i < 4; i++) {
      final rd = i.isEven ? _letters(lx, d, r) : _numbers(d, r);
      if (rd == null) return null;
      rounds.add(rd);
    }
    return LnPuzzle(rounds);
  }

  @override
  bool check(WPuzzle p, Lexicon lx) {
    if (p is! LnPuzzle || p.rounds.length != 4) return false;
    for (final rd in p.rounds) {
      if (rd.numbers) {
        if (rd.nums.length != 6 || rd.target < 101 || rd.target > 999) return false;
      } else {
        final pool = letterCounts(rd.letters.join());
        if (!lx.has(rd.botWord) || !canSpell(rd.botWord, pool) || !canSpell(rd.best, pool)) return false;
      }
    }
    return true;
  }

  @override
  Widget build(WordPlay play) => _LnView(play: play);
}

class _LnView extends StatefulWidget {
  final WordPlay play;
  const _LnView({required this.play});

  @override
  State<_LnView> createState() => _LnViewState();
}

class _LnViewState extends State<_LnView> with SecondsTicker, Flash {
  late LnPuzzle p;
  int round = 0, roundStart = 0;
  int me = 0, bot = 0;
  bool between = false;
  String lastNote = '';
  // harf turu
  List<int> picked = [];
  String bestWord = '';
  // sayı turu
  List<int?> vals = [];
  final List<List<int?>> history = [];
  int? selA;
  String? op;

  static const roundTime = 45;

  /// Çevrimiçi: tur sonucu gönderildi, rakibinki bekleniyor.
  bool waiting = false;
  int _myRoundValue = 0;
  String _myRoundWord = '';

  WordPlay get play => widget.play;
  WordNet? get net => play.net;
  bool get online => net != null && !net!.oppGone;
  Lexicon get lx => play.lx;
  LnRound get rd => p.rounds[round];
  int get elapsed => seconds - roundStart;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as LnPuzzle;
    _setupRound();
    net?.listen(_onNet);
    _replay();
    startTicker();
  }

  @override
  void dispose() {
    net?.unlisten(_onNet);
    super.dispose();
  }

  void _replay() {
    final n = net;
    if (n == null) return;
    final sent = [for (final m in n.mine) if (m.startsWith('R')) m];
    for (var r = 0; r < sent.length && r < p.rounds.length; r++) {
      round = r;
      _setupRound();
      final v = _parse(r, sent[r]);
      _myRoundWord = v.$1;
      _myRoundValue = v.$2;
      if (!rd.numbers) bestWord = v.$1;
      between = true;
      waiting = true;
      _resolve(quiet: true);
      if (waiting) break;
    }
  }

  /// "R<tur>:<kelime ya da sayı>" → (kelime, sayı).
  (String, int) _parse(int r, String m) {
    final body = m.substring('R$r:'.length);
    final rr = p.rounds[r];
    if (rr.numbers) return ('', int.tryParse(body) ?? -1);
    final ok = body.length >= lx.minLen && lx.has(body) && canSpell(body, letterCounts(rr.letters.join()));
    return (ok ? body : '', 0);
  }

  (String, int)? _rival(int r) {
    final rr = p.rounds[r];
    if (!online) return (rr.botWord, rr.botValue);
    for (final m in net!.theirs) {
      if (m.startsWith('R$r:')) return _parse(r, m);
    }
    return null;
  }

  void _onNet() {
    if (mounted && waiting) setState(() => _resolve());
  }

  void _setupRound() {
    picked = [];
    bestWord = '';
    vals = <int?>[for (final n in rd.nums) n];
    history.clear();
    selA = null;
    op = null;
  }

  @override
  void onTick() {
    if (ended) return;
    if (waiting) {
      if (net != null && net!.oppGone) setState(() => _resolve());
      return;
    }
    if (between) return;
    if (elapsed >= roundTime) _endRound();
  }

  int get bestNumber {
    var best = -1;
    for (final v in vals) {
      if (v == null) continue;
      if (best < 0 || (v - rd.target).abs() < (best - rd.target).abs()) best = v;
    }
    return best;
  }

  void _endRound() {
    if (between) return;
    _myRoundWord = bestWord;
    _myRoundValue = rd.numbers ? bestNumber : 0;
    net?.send('R$round:${rd.numbers ? '$_myRoundValue' : bestWord}');
    setState(() {
      between = true;
      waiting = true;
      _resolve();
    });
  }

  void _resolve({bool quiet = false}) {
    if (!waiting) return;
    final r = _rival(round);
    if (r == null) return;
    waiting = false;
    int mine, theirs;
    if (rd.numbers) {
      mine = lnNumberPoints(_myRoundValue, rd.target);
      theirs = lnNumberPoints(r.$2, rd.target);
      lastNote = '${rd.target}: ${kt(play.lang, 'you')} $_myRoundValue · ${kt(play.lang, 'rival')} ${r.$2 < 0 ? '—' : r.$2}';
    } else {
      mine = _myRoundWord.length == 9 ? 18 : _myRoundWord.length;
      theirs = r.$1.length == 9 ? 18 : r.$1.length;
      lastNote = '${kt(play.lang, 'you')} ${_myRoundWord.isEmpty ? '—' : lx.up(_myRoundWord)} · ${kt(play.lang, 'rival')} ${r.$1.isEmpty ? '—' : lx.up(r.$1)}';
    }
    me += mine;
    bot += theirs;
    if (!quiet) play.ctx.sfx(mine >= theirs ? Sfx.combo : Sfx.error);
    if (round == p.rounds.length - 1) {
      ended = true;
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        final n = net;
        if (n != null) n.finish(me > bot ? n.me : (me < bot ? n.opp : -1));
        if (me >= bot) {
          play.ctx.sfx(Sfx.win);
          play.win(score: me * 20, stars: me - bot >= 10 ? 3 : (me - bot >= 4 ? 2 : 1), seconds: seconds, stats: {'words_found': 2});
        } else {
          play.ctx.sfx(Sfx.lose);
          play.lose(score: me * 20, seconds: seconds, headline: '${kt(play.lang, 'you')} $me — ${kt(play.lang, 'rival')} $bot');
        }
      });
    }
  }

  void _next() {
    if (waiting) return;
    setState(() {
      round++;
      roundStart = seconds;
      between = false;
      _setupRound();
    });
  }

  void _submitWord() {
    final w = picked.map((i) => rd.letters[i]).join();
    setState(() => picked = []);
    if (w.length < lx.minLen) return flash(kt(play.lang, 'short'));
    if (!lx.has(w)) {
      play.ctx.sfx(Sfx.error);
      return flash(kt(play.lang, 'notWord'));
    }
    if (w.length > bestWord.length) setState(() => bestWord = w);
    play.ctx.sfx(Sfx.clear);
    flash('${lx.up(w)} · ${w.length}');
  }

  void _tapNum(int i) {
    if (between || vals[i] == null) return;
    if (selA == null || op == null) {
      setState(() => selA = i);
      return;
    }
    if (i == selA) return;
    final a = vals[selA!]!, b = vals[i]!;
    int? res;
    switch (op) {
      case '+':
        res = a + b;
      case '−':
        res = a - b > 0 ? a - b : null;
      case '×':
        res = a * b;
      default:
        res = b != 0 && a % b == 0 ? a ~/ b : null;
    }
    if (res == null) {
      play.ctx.sfx(Sfx.error);
      setState(() {
        op = null;
      });
      return;
    }
    final value = res;
    history.add(List.of(vals));
    setState(() {
      vals[i] = value;
      vals[selA!] = null;
      selA = i;
      op = null;
    });
    play.ctx.sfx(Sfx.place);
    if (value == rd.target) _endRound();
  }

  Widget _numbersBody() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text('${rd.target}', style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w900, color: StudioLook.gold)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
        for (var i = 0; i < vals.length; i++)
          if (vals[i] != null)
            GestureDetector(
              onTap: () => _tapNum(i),
              child: Container(
                width: 64,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selA == i ? WColors.near : WColors.tile,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: WColors.tileEdge),
                ),
                child: Text('${vals[i]}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: WColors.ink)),
              ),
            ),
      ]),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (final o in const ['+', '−', '×', '÷'])
          Padding(
            padding: const EdgeInsets.all(4),
            child: ChoiceChip(
              label: Text(o, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              selected: op == o,
              onSelected: selA == null || between ? null : (_) => setState(() => op = o),
            ),
          ),
        IconButton.filledTonal(
          tooltip: kt(play.lang, 'undo'),
          onPressed: history.isEmpty || between
              ? null
              : () => setState(() {
                    vals = history.removeLast();
                    selA = null;
                    op = null;
                  }),
          icon: const Icon(Icons.undo),
        ),
      ]),
      BigButton(label: kt(play.lang, 'submit'), onPressed: between ? null : _endRound),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final lang = play.lang;
    return Column(children: [
      WordBar(
        play: play,
        left: clock(math.max(0, roundTime - elapsed)),
        status: '${kt(lang, rd.numbers ? 'numbers' : 'letters')} ${round + 1}/${p.rounds.length}   ${kt(lang, 'you')} $me · ${kt(lang, 'rival')} $bot',
      ),
      flashLine(),
      if (between) Panel(child: Text(waiting ? kt(lang, 'waitRival') : lastNote, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700))),
      Expanded(
        child: Center(
          child: SingleChildScrollView(
            child: rd.numbers
                ? _numbersBody()
                : Column(mainAxisSize: MainAxisSize.min, children: [
                    if (bestWord.isNotEmpty) Text('★ ${lx.up(bestWord)} (${bestWord.length})', style: const TextStyle(fontWeight: FontWeight.w800)),
                    LetterPad(
                      lx: lx,
                      letters: rd.letters,
                      picked: picked,
                      lang: lang,
                      onPick: (i) {
                        if (between) return;
                        setState(() => picked.add(i));
                        play.ctx.sfx(Sfx.tap);
                      },
                      onBack: () => setState(() {
                        if (picked.isNotEmpty) picked.removeLast();
                      }),
                      onClear: () => setState(() => picked = []),
                      onSubmit: _submitWord,
                    ),
                    if (!between) TextButton(onPressed: _endRound, child: Text(kt(lang, 'next'))),
                  ]),
          ),
        ),
      ),
      if (between && !ended && !waiting) BigButton(label: kt(lang, 'next'), icon: Icons.arrow_forward, onPressed: _next),
      const SizedBox(height: 8),
    ]);
  }
}
