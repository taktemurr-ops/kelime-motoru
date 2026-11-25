import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:studio_core/app/services/audio.dart';
import 'package:studio_core/core/rng.dart';

import '../clues.dart';
import '../core.dart';
import '../texts.dart';
import '../ui.dart';
import '../words.dart';

/// Çoktan seçmeli soru.
class Question {
  final String prompt;
  final List<String> options;
  final int answer;
  const Question(this.prompt, this.options, this.answer);
}

class QuizPuzzle extends WPuzzle {
  final List<Question> qs;
  final int lives;

  /// Seçenekler kelime mi (büyük harfle yazılır), cümle mi.
  final bool upperOptions;
  const QuizPuzzle(this.qs, this.lives, {this.upperOptions = true});
}

/// Yanlış yazımlar: bitişik harf takası, harf düşürme, ikileme, ünlü değişimi.
List<String> misspellings(String w, Lexicon lx, SeededRandom r, int n) {
  if (lx.tiled) return tileMisspellings(w, lx, r, n);
  const vowelsAll = 'aeiouıöüyåäæøéáóúíàèùâêîôûăεηιουωаеиоуыэюяєії';
  final vowels = [for (final ch in lx.letters) if (vowelsAll.contains(ch)) ch];
  final out = <String>{};
  var guard = 0;
  while (out.length < n && guard++ < 200) {
    final kind = r.nextInt(4);
    String m;
    final i = r.nextInt(w.length);
    switch (kind) {
      case 0:
        if (i >= w.length - 1 || w[i] == w[i + 1]) continue;
        m = w.substring(0, i) + w[i + 1] + w[i] + w.substring(i + 2);
      case 1:
        if (w.length <= 4) continue;
        m = w.substring(0, i) + w.substring(i + 1);
      case 2:
        m = w.substring(0, i) + w[i] + w.substring(i);
      default:
        if (!vowels.contains(w[i]) || vowels.length < 2) continue;
        var v = r.pick(vowels);
        if (v == w[i]) v = vowels[(vowels.indexOf(v) + 1) % vowels.length];
        m = w.substring(0, i) + v + w.substring(i + 1);
    }
    if (m != w && !lx.has(m)) out.add(m);
  }
  return out.toList();
}

/// Taş dillerinde yanlış yazım: bir (zorda iki) taş benzeriyle değişir —
/// Vietnamcada aynı hecenin başka tonu, Çincede aynı okunuşlu başka karakter
/// (错别字), Hint yazılarında kısa/uzun sesli ya da nazal işaret, Taycada ton
/// işareti, Korecede aynı ilk ünsüzlü başka hece. Sonuç sözlükte olmamalı.
List<String> tileMisspellings(String w, Lexicon lx, SeededRandom r, int n) {
  final out = <String>{};
  var guard = 0;
  while (out.length < n && guard++ < 120) {
    final chars = w.split('');
    final swaps = guard > 60 && chars.length > 2 ? 2 : 1;
    for (var k = 0; k < swaps; k++) {
      final i = r.nextInt(chars.length);
      final kin = lx.kin(w[i]);
      if (kin.isEmpty) continue;
      chars[i] = kin[r.nextInt(math.min(kin.length, 5))];
    }
    final m = chars.join();
    if (m != w && !lx.has(m)) out.add(m);
  }
  return out.toList();
}

class SpellKind extends WordKind {
  @override
  String get id => 'heceleme';
  const SpellKind();

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final n = 8 + d ~/ 2;
    final qs = <Question>[];
    final used = <String>{};
    var guard = 0;
    while (qs.length < n && guard++ < 200) {
      final w = r.pick(lx.poolFit(5, 6 + d ~/ 3, d));
      if (!used.add(w)) continue;
      final bad = misspellings(w, lx, r, d <= 3 ? 2 : 3);
      if (bad.length < 2) continue;
      final opts = [w, ...bad];
      r.shuffle(opts);
      qs.add(Question('', opts, opts.indexOf(w)));
    }
    if (qs.length < n) return null;
    return QuizPuzzle(qs, d <= 4 ? 3 : 2);
  }

  @override
  bool check(WPuzzle p, Lexicon lx) =>
      p is QuizPuzzle && p.qs.every((q) => lx.has(q.options[q.answer]) && q.options.where(lx.has).length == 1);

  @override
  Widget build(WordPlay play) => _QuizView(play: play);
}

class ProverbKind extends WordKind {
  @override
  String get id => 'atasozu';
  const ProverbKind();

  @override
  List<String>? get contentLangs => kQuizLangs;

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final all = proverbList(lx.lang);
    final n = 6 + d ~/ 2;
    final order = List.of(all);
    r.shuffle(order);
    final qs = <Question>[];
    final minTok = proverbMinToken(lx.lang);
    final pool = <String>[for (final s in all) ...sentenceWords(s, lx.lang).where((w) => w.length >= minTok)];
    for (final s in order.take(n)) {
      final raw = s.split(' ');
      final cands = [
        for (var i = 0; i < raw.length; i++)
          if (sentenceWords(raw[i], lx.lang).length == 1 && sentenceWords(raw[i], lx.lang).first.length >= minTok) i,
      ];
      if (cands.isEmpty) continue;
      final k = r.pick(cands);
      final answer = sentenceWords(raw[k], lx.lang).first;
      final shown = [for (var i = 0; i < raw.length; i++) i == k ? '_____' : raw[i]].join(' ');
      final opts = <String>{answer};
      var guard = 0;
      while (opts.length < 3 + (d >= 6 ? 1 : 0) && guard++ < 100) {
        opts.add(r.pick(pool));
      }
      final list = opts.toList();
      r.shuffle(list);
      qs.add(Question(shown, list, list.indexOf(answer)));
    }
    if (qs.length < n - 1) return null;
    return QuizPuzzle(qs, d <= 4 ? 3 : 2);
  }

  @override
  bool check(WPuzzle p, Lexicon lx) => p is QuizPuzzle && p.qs.isNotEmpty && p.qs.every((q) => q.answer >= 0 && q.options.length >= 3);

  @override
  Widget build(WordPlay play) => _QuizView(play: play);
}

class _QuizView extends StatefulWidget {
  final WordPlay play;
  const _QuizView({required this.play});

  @override
  State<_QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<_QuizView> with SecondsTicker, Flash {
  late QuizPuzzle p;
  int idx = 0, mistakes = 0, hints = 0;
  int? picked;
  final Set<int> removed = {};

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;
  Question get q => p.qs[idx];

  @override
  void initState() {
    super.initState();
    p = play.puzzle as QuizPuzzle;
    idx = ((play.resume['i'] as num?)?.toInt() ?? 0).clamp(0, p.qs.length - 1);
    mistakes = (play.resume['m'] as num?)?.toInt() ?? 0;
    startTicker((play.resume['s'] as num?)?.toInt() ?? 0);
  }

  void _pick(int i) {
    if (ended || picked != null) return;
    setState(() => picked = i);
    final ok = i == q.answer;
    play.ctx.sfx(ok ? Sfx.clear : Sfx.error);
    if (!ok) mistakes++;
    Future.delayed(const Duration(milliseconds: 750), () {
      if (!mounted) return;
      if (mistakes >= p.lives) {
        ended = true;
        play.ctx.sfx(Sfx.lose);
        play.lose(seconds: seconds, hints: hints, headline: '${kt(play.lang, 'mistakes')}: $mistakes');
        return;
      }
      if (idx + 1 >= p.qs.length) {
        ended = true;
        play.ctx.sfx(Sfx.win);
        play.win(
          score: 300 + (p.qs.length - mistakes) * 40 - hints * 40,
          stars: starsFor(hints: hints, mistakes: mistakes * 2),
          seconds: seconds,
          hints: hints,
          stats: {'words_found': p.qs.length - mistakes},
        );
        return;
      }
      setState(() {
        idx++;
        picked = null;
        removed.clear();
      });
      play.save({'i': idx, 'm': mistakes, 's': seconds});
    });
  }

  Future<void> _hint() async {
    if (ended || picked != null) return;
    final wrong = [for (var i = 0; i < q.options.length; i++) if (i != q.answer && !removed.contains(i)) i];
    if (wrong.length <= 1) return;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    setState(() {
      hints++;
      removed.add(wrong.first);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = play.lang;
    return Column(children: [
      WordBar(
        play: play,
        left: clock(),
        status: '${idx + 1}/${p.qs.length}   ${kt(lang, 'tries')}: ${p.lives - mistakes}',
        onHint: _hint,
      ),
      flashLine(),
      Expanded(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (q.prompt.isNotEmpty)
                Panel(
                  padding: const EdgeInsets.all(16),
                  child: Text(q.prompt, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: WColors.ink)),
                ),
              const SizedBox(height: 14),
              for (var i = 0; i < q.options.length; i++)
                if (!removed.contains(i))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: SizedBox(
                      width: 320,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(200, 54),
                          backgroundColor: picked == null
                              ? WColors.paper
                              : (i == q.answer ? WColors.hit : (i == picked ? WColors.warm : WColors.paper)),
                          foregroundColor: picked != null && (i == q.answer || i == picked) ? Colors.white : WColors.ink,
                        ),
                        onPressed: () => _pick(i),
                        child: Text(
                          lx.up(q.options[i]),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                        ),
                      ),
                    ),
                  ),
            ]),
          ),
        ),
      ),
    ]);
  }
}

// ---------------------------------------------------------------- Eş / zıt anlam eşleştirme

class PairRound {
  final bool antonyms;
  final List<String> left, right;

  /// left[i] ile right[match[i]] eş.
  final List<int> match;
  const PairRound(this.antonyms, this.left, this.right, this.match);
}

class PairsPuzzle extends WPuzzle {
  final List<PairRound> rounds;
  const PairsPuzzle(this.rounds);
}

class PairsKind extends WordKind {
  @override
  String get id => 'es-zit';
  const PairsKind();

  @override
  List<String>? get contentLangs => kQuizLangs;

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final per = 4 + math.min(3, d ~/ 3);
    final rounds = <PairRound>[];
    for (var k = 0; k < 3; k++) {
      final ant = k.isOdd;
      final src = List.of(ant ? antonymList(lx.lang) : synonymList(lx.lang));
      r.shuffle(src);
      final chosen = <(String, String)>[];
      final used = <String>{};
      for (final pr in src) {
        if (chosen.length >= per) break;
        if (used.contains(pr.$1) || used.contains(pr.$2)) continue;
        used
          ..add(pr.$1)
          ..add(pr.$2);
        chosen.add(pr);
      }
      if (chosen.length < per) return null;
      final right = [for (final c in chosen) c.$2];
      r.shuffle(right);
      rounds.add(PairRound(ant, [for (final c in chosen) c.$1], right, [for (final c in chosen) right.indexOf(c.$2)]));
    }
    return PairsPuzzle(rounds);
  }

  @override
  bool check(WPuzzle p, Lexicon lx) =>
      p is PairsPuzzle && p.rounds.every((rd) => rd.match.toSet().length == rd.left.length && rd.right.toSet().length == rd.right.length);

  @override
  Widget build(WordPlay play) => _PairsView(play: play);
}

class _PairsView extends StatefulWidget {
  final WordPlay play;
  const _PairsView({required this.play});

  @override
  State<_PairsView> createState() => _PairsViewState();
}

class _PairsViewState extends State<_PairsView> with SecondsTicker, Flash {
  late PairsPuzzle p;
  int round = 0, mistakes = 0, hints = 0;
  int? selL;
  final Set<int> doneL = {};
  int? wrongR;

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;
  PairRound get rd => p.rounds[round];

  @override
  void initState() {
    super.initState();
    p = play.puzzle as PairsPuzzle;
    startTicker();
  }

  void _tapRight(int j) {
    if (ended || selL == null) return;
    final i = selL!;
    if (rd.match[i] == j) {
      setState(() {
        doneL.add(i);
        selL = null;
      });
      play.ctx.sfx(Sfx.clear);
      if (doneL.length == rd.left.length) {
        if (round + 1 >= p.rounds.length) {
          ended = true;
          play.ctx.sfx(Sfx.win);
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              play.win(
                score: 400 - mistakes * 30 - hints * 40,
                stars: starsFor(hints: hints, mistakes: mistakes),
                seconds: seconds,
                hints: hints,
                stats: {'words_found': p.rounds.fold<int>(0, (a, x) => a + x.left.length)},
              );
            }
          });
        } else {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            setState(() {
              round++;
              doneL.clear();
            });
          });
        }
      }
    } else {
      setState(() {
        mistakes++;
        wrongR = j;
      });
      play.ctx.sfx(Sfx.error);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => wrongR = null);
      });
    }
  }

  Future<void> _hint() async {
    if (ended) return;
    final left = [for (var i = 0; i < rd.left.length; i++) if (!doneL.contains(i)) i];
    if (left.isEmpty) return;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    setState(() {
      hints++;
      selL = left.first;
    });
    _tapRight(rd.match[left.first]);
  }

  Widget _chip(String w, {required bool on, required bool done, required bool bad, required VoidCallback onTap}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        child: GestureDetector(
          onTap: done ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? WColors.hit.withValues(alpha: 0.35) : (bad ? WColors.warm : (on ? WColors.near : WColors.tile)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WColors.tileEdge),
            ),
            child: FittedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(lx.up(w), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: done ? WColors.miss : WColors.ink)),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final title = kt(play.lang, rd.antonyms ? 'opposites' : 'sameMeaning');
    final doneR = {for (final i in doneL) rd.match[i]};
    return Column(children: [
      WordBar(play: play, left: clock(), status: '$title · ${round + 1}/${p.rounds.length}', onHint: _hint),
      flashLine(),
      Expanded(
        child: SingleChildScrollView(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(children: [
                for (var i = 0; i < rd.left.length; i++)
                  _chip(rd.left[i], on: selL == i, done: doneL.contains(i), bad: false, onTap: () => setState(() => selL = i)),
              ]),
            ),
            Icon(rd.antonyms ? Icons.compare_arrows : Icons.drag_handle, color: WColors.miss),
            Expanded(
              child: Column(children: [
                for (var j = 0; j < rd.right.length; j++)
                  _chip(rd.right[j], on: false, done: doneR.contains(j), bad: wrongR == j, onTap: () => _tapRight(j)),
              ]),
            ),
          ]),
        ),
      ),
    ]);
  }
}

// ---------------------------------------------------------------- Kelime gruplama

class GroupsPuzzle extends WPuzzle {
  final List<String> titles;
  final List<List<String>> groups;
  final List<String> board;
  final int lives;
  const GroupsPuzzle(this.titles, this.groups, this.board, this.lives);
}

class GroupsKind extends WordKind {
  @override
  String get id => 'gruplama';
  const GroupsKind();

  @override
  List<String>? get contentLangs => kQuizLangs;

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final all = List.of(groupList(lx.lang));
    r.shuffle(all);
    final picked = <(String, List<String>)>[];
    final chosenWords = <String>{};
    for (final g in all) {
      if (picked.length == 4) break;
      // Bu grubun kelimeleri seçilmiş diğer gruplarda olmasın.
      if (g.$2.any(chosenWords.contains)) continue;
      final clash = picked.any((pg) => pg.$2.any(g.$2.contains));
      if (clash) continue;
      final words = List.of(g.$2);
      r.shuffle(words);
      final four = words.take(4).toList();
      if (four.length < 4) continue;
      picked.add((g.$1, four));
      chosenWords.addAll(four);
    }
    if (picked.length < 4) return null;
    final board = [for (final g in picked) ...g.$2];
    r.shuffle(board);
    return GroupsPuzzle([for (final g in picked) g.$1], [for (final g in picked) g.$2], board, d <= 5 ? 4 : 3);
  }

  @override
  bool check(WPuzzle p, Lexicon lx) => p is GroupsPuzzle && p.board.toSet().length == 16 && p.groups.length == 4;

  @override
  Widget build(WordPlay play) => _GroupsView(play: play);
}

class _GroupsView extends StatefulWidget {
  final WordPlay play;
  const _GroupsView({required this.play});

  @override
  State<_GroupsView> createState() => _GroupsViewState();
}

class _GroupsViewState extends State<_GroupsView> with SecondsTicker, Flash {
  late GroupsPuzzle p;
  late List<String> board;
  final Set<String> sel = {};
  final List<int> solved = [];
  int mistakes = 0, hints = 0;

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as GroupsPuzzle;
    board = List.of(p.board);
    startTicker();
  }

  void _submit() {
    if (ended || sel.length != 4) return;
    for (var g = 0; g < 4; g++) {
      if (solved.contains(g)) continue;
      if (p.groups[g].toSet().containsAll(sel)) {
        setState(() {
          solved.add(g);
          board.removeWhere(sel.contains);
          sel.clear();
        });
        play.ctx.sfx(Sfx.combo);
        if (solved.length == 4) {
          ended = true;
          play.ctx.sfx(Sfx.win);
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              play.win(
                score: 500 - mistakes * 80 - hints * 60,
                stars: starsFor(hints: hints, mistakes: mistakes),
                seconds: seconds,
                hints: hints,
                stats: {'words_found': 16},
              );
            }
          });
        }
        return;
      }
    }
    final near = [for (var g = 0; g < 4; g++) if (!solved.contains(g)) p.groups[g].where(sel.contains).length].fold<int>(0, math.max);
    setState(() => mistakes++);
    play.ctx.sfx(Sfx.error);
    flash(near == 3 ? kt(play.lang, 'oneAway') : kt(play.lang, 'wrong'));
    if (mistakes >= p.lives) {
      ended = true;
      play.ctx.sfx(Sfx.lose);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) play.lose(seconds: seconds, hints: hints, headline: p.titles.join(' · '));
      });
    }
  }

  Future<void> _hint() async {
    if (ended) return;
    final g = [for (var i = 0; i < 4; i++) if (!solved.contains(i)) i];
    if (g.isEmpty) return;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    setState(() {
      hints++;
      sel
        ..clear()
        ..addAll(p.groups[g.first].take(2));
    });
    flash(p.titles[g.first]);
  }

  @override
  Widget build(BuildContext context) {
    final lang = play.lang;
    return Column(children: [
      WordBar(play: play, left: clock(), status: '${kt(lang, 'mistakes')}: $mistakes/${p.lives}', onHint: _hint),
      flashLine(),
      for (final g in solved)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          padding: const EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(color: WColors.marks[g * 2], borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Text(p.titles[g], style: const TextStyle(fontWeight: FontWeight.w800, color: WColors.ink)),
            Text(p.groups[g].map(lx.up).join(', '), style: const TextStyle(color: WColors.ink)),
          ]),
        ),
      Expanded(
        child: LayoutBuilder(builder: (context, box) {
          final rows = (board.length / 4).ceil();
          final cw = (box.maxWidth - 30) / 4;
          final ch = rows == 0 ? 0.0 : math.max(30.0, math.min(70.0, (box.maxHeight - 10) / rows - 8));
          return Center(
            child: Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: [
              for (final w in board)
                GestureDetector(
                  onTap: () => setState(() {
                    if (sel.contains(w)) {
                      sel.remove(w);
                    } else if (sel.length < 4) {
                      sel.add(w);
                    }
                  }),
                  child: Container(
                    width: cw,
                    height: ch,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: sel.contains(w) ? WColors.ink : WColors.tile,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: WColors.tileEdge),
                    ),
                    child: FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(lx.up(w),
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: sel.contains(w) ? Colors.white : WColors.ink)),
                      ),
                    ),
                  ),
                ),
            ]),
          );
        }),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton.filledTonal(
          tooltip: kt(lang, 'shuffle'),
          onPressed: () => setState(() => board.shuffle()),
          icon: const Icon(Icons.shuffle),
        ),
        IconButton.filledTonal(tooltip: kt(lang, 'clear'), onPressed: () => setState(sel.clear), icon: const Icon(Icons.clear)),
        BigButton(label: kt(lang, 'submit'), onPressed: sel.length == 4 ? _submit : null),
      ]),
      const SizedBox(height: 8),
    ]);
  }
}

// ---------------------------------------------------------------- Akrostiş

class AcrosticPuzzle extends WPuzzle {
  final String key;
  final List<String> answers;
  final List<String> clues;
  const AcrosticPuzzle(this.key, this.answers, this.clues);
}

class AcrosticKind extends WordKind {
  @override
  String get id => 'akrostis';
  const AcrosticKind();

  @override
  List<String>? get contentLangs => kClueLangs;

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    final clues = clueList(lx.lang);
    final byFirst = <String, List<(String, String)>>{};
    for (final c in clues) {
      byFirst.putIfAbsent(c.$1[0], () => []).add(c);
    }
    final len = lx.fit(4 + math.min<int>(4, d ~/ 2));
    final keys = [for (final w in lx.pool(len, d)) if (w.split('').every(byFirst.containsKey)) w];
    if (keys.isEmpty) return null;
    final key = r.pick(keys);
    final answers = <String>[], cl = <String>[];
    for (final ch in key.split('')) {
      final opts = [for (final c in byFirst[ch]!) if (!answers.contains(c.$1) && c.$1 != key) c];
      if (opts.isEmpty) return null;
      final c = r.pick(opts);
      answers.add(c.$1);
      cl.add(c.$2);
    }
    return AcrosticPuzzle(key, answers, cl);
  }

  @override
  bool check(WPuzzle p, Lexicon lx) =>
      p is AcrosticPuzzle && p.answers.length == p.key.length && [for (var i = 0; i < p.key.length; i++) p.answers[i][0] == p.key[i]].every((x) => x);

  @override
  Widget build(WordPlay play) => _AcrosticView(play: play);
}

class _AcrosticView extends StatefulWidget {
  final WordPlay play;
  const _AcrosticView({required this.play});

  @override
  State<_AcrosticView> createState() => _AcrosticViewState();
}

class _AcrosticViewState extends State<_AcrosticView> with SecondsTicker, Flash {
  late AcrosticPuzzle p;
  late List<String> typed;
  late List<bool> done;
  int sel = 0, hints = 0, mistakes = 0;

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as AcrosticPuzzle;
    typed = List<String>.filled(p.answers.length, '');
    done = List<bool>.filled(p.answers.length, false);
    startTicker();
  }

  void _enter() {
    if (ended || done[sel]) return;
    final a = p.answers[sel];
    if (typed[sel].length < a.length) return flash(kt(play.lang, 'short'));
    if (typed[sel] != a) {
      setState(() => mistakes++);
      play.ctx.sfx(Sfx.error);
      return flash(kt(play.lang, 'wrong'));
    }
    setState(() => done[sel] = true);
    play.ctx.sfx(Sfx.clear);
    if (done.every((x) => x)) {
      ended = true;
      play.ctx.sfx(Sfx.win);
      flash('★ ${lx.up(p.key)} ★');
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          play.win(
            score: 300 + p.answers.length * 40 - hints * 40,
            stars: starsFor(hints: hints, mistakes: mistakes),
            seconds: seconds,
            hints: hints,
            stats: {'words_found': p.answers.length},
          );
        }
      });
      return;
    }
    for (var k = 1; k <= p.answers.length; k++) {
      final j = (sel + k) % p.answers.length;
      if (!done[j]) {
        setState(() => sel = j);
        break;
      }
    }
  }

  Future<void> _hint() async {
    if (ended || done[sel]) return;
    final a = p.answers[sel];
    var k = 0;
    while (k < typed[sel].length && k < a.length && typed[sel][k] == a[k]) {
      k++;
    }
    if (k >= a.length) return;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    setState(() {
      hints++;
      typed[sel] = a.substring(0, k + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      WordBar(play: play, left: clock(), status: '${kt(play.lang, 'found')}: ${done.where((x) => x).length}/${p.answers.length}', onHint: _hint),
      flashLine(),
      Padding(
        padding: const EdgeInsets.all(6),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var i = 0; i < p.key.length; i++)
            Padding(
              padding: const EdgeInsets.all(2),
              child: LetterTile(letter: done[i] ? lx.upCh(p.key[i]) : '', size: 34, fill: done[i] ? WColors.near : WColors.paper),
            ),
        ]),
      ),
      Expanded(
        child: ListView(padding: const EdgeInsets.symmetric(horizontal: 8), children: [
          for (var i = 0; i < p.answers.length; i++)
            GestureDetector(
              onTap: () => setState(() => sel = i),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: i == sel ? const Color(0xFFDCE8F5) : WColors.paper.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: i == sel ? WColors.accent : WColors.tileEdge),
                ),
                child: Row(children: [
                  Expanded(child: Text(p.clues[i], style: const TextStyle(fontWeight: FontWeight.w600, color: WColors.ink))),
                  Wrap(spacing: 1, children: [
                    for (var k = 0; k < p.answers[i].length; k++)
                      LetterTile(
                        letter: done[i] ? lx.upCh(p.answers[i][k]) : (k < typed[i].length ? lx.upCh(typed[i][k]) : ''),
                        size: 22,
                        fill: done[i] ? (k == 0 ? WColors.near : WColors.hit) : (k == 0 ? WColors.soft : null),
                        raised: false,
                      ),
                  ]),
                ]),
              ),
            ),
        ]),
      ),
      WordKeyboard(
        lx: lx,
        // Taş dillerinde seçili yanıtın taşları ve şaşırtmacalar.
        pool: lx.tiled ? lx.keyPool(p.answers[sel].split(''), play.seed ^ sel, size: p.answers[sel].length + 7) : null,
        onKey: (ch) {
          if (ended || done[sel] || typed[sel].length >= p.answers[sel].length) return;
          setState(() => typed[sel] += ch);
        },
        onEnter: _enter,
        onBack: () => setState(() {
          if (typed[sel].isNotEmpty) typed[sel] = typed[sel].substring(0, typed[sel].length - 1);
        }),
      ),
      const SizedBox(height: 6),
    ]);
  }
}
