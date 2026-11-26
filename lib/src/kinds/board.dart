import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:studio_core/app/services/audio.dart';
import 'package:studio_core/core/rng.dart';

import '../core.dart';
import '../texts.dart';
import '../ui.dart';
import '../words.dart';

/// Kelime kurma tahtası: rakibe karşı harf taşlarıyla tahtaya kelime dizme.
/// Tahta düzeni ve taş dağılımı stüdyonun kendisine aittir.
const kBoardN = 11;

/// Ödüllü kareler: 0 düz, 1 harf×2, 2 harf×3, 3 kelime×2, 4 kelime×3.
List<int> boardPremiums() {
  const n = kBoardN;
  final b = List<int>.filled(n * n, 0);
  void sym(int x, int y, int v) {
    for (final p in [
      [x, y], [n - 1 - x, y], [x, n - 1 - y], [n - 1 - x, n - 1 - y],
      [y, x], [n - 1 - y, x], [y, n - 1 - x], [n - 1 - y, n - 1 - x],
    ]) {
      b[p[1] * n + p[0]] = v;
    }
  }

  sym(0, 0, 4);
  sym(5, 0, 3);
  sym(2, 2, 3);
  sym(3, 1, 2);
  sym(1, 4, 1);
  sym(4, 4, 1);
  sym(0, 3, 1);
  sym(5, 2, 1);
  b[5 * n + 5] = 3;
  return b;
}

class BoardPuzzle extends WPuzzle {
  /// Torbadaki taşların karışık sırası.
  final List<String> bag;
  final int turns;
  const BoardPuzzle(this.bag, this.turns);
}

class BoardKind extends WordKind {
  @override
  String get id => 'kelime-kurma';
  const BoardKind();

  @override
  int get players => 2;

  @override
  WPuzzle? make(Lexicon lx, int d, SeededRandom r) {
    if (lx.tiled) {
      // Taş dillerinde yüzlerce taş var: torba sık kelimelerin taşlarından
      // kurulur (raflarda kelime kurulabilsin diye), 90 taş.
      final bag = <String>[];
      final pool = lx.poolRange(2, 3, math.max(1, d ~/ 2));
      while (bag.length < 90) {
        bag.addAll(r.pick(pool).split(''));
      }
      r.shuffle(bag);
      return BoardPuzzle(bag, 6 + d ~/ 3);
    }
    // Sıklığa göre 84 taş (her harften en az bir).
    final total = lx.letterWeights.fold<int>(0, (a, b) => a + b);
    final bag = <String>[];
    for (var i = 0; i < lx.letters.length; i++) {
      final c = math.max(1, (lx.letterWeights[i] * 84 / total).round());
      for (var k = 0; k < c; k++) {
        bag.add(lx.letters[i]);
      }
    }
    r.shuffle(bag);
    return BoardPuzzle(bag, 6 + d ~/ 3);
  }

  @override
  bool check(WPuzzle p, Lexicon lx) => p is BoardPuzzle && p.bag.length >= 40;

  @override
  Widget build(WordPlay play) => _BoardView(play: play);
}

/// Bir hamle: yerleştirilen taşlar (hücre → harf) ve puan.
class BMove {
  final Map<int, String> tiles;
  final int score;
  final List<String> words;
  const BMove(this.tiles, this.score, this.words);
}

/// Tahta kuralları: hamle doğrulama ve puanlama (oyuncu ve rakip ortak).
class BoardRules {
  final Lexicon lx;
  final List<int> prem = boardPremiums();
  BoardRules(this.lx);

  static const n = kBoardN;
  static const center = (kBoardN ~/ 2) * kBoardN + kBoardN ~/ 2;

  /// Geçerliyse hamleyi döndürür.
  BMove? evaluate(List<String> board, Map<int, String> tiles) {
    if (tiles.isEmpty) return null;
    final cells = tiles.keys.toList()..sort();
    final ys = cells.map((c) => c ~/ n).toSet(), xs = cells.map((c) => c % n).toSet();
    final across = ys.length == 1;
    if (!across && xs.length != 1) return null;
    String at(int i) => tiles[i] ?? board[i];
    final empty = board.every((c) => c.isEmpty);
    if (empty && !tiles.containsKey(center)) return null;
    // Ana kelime: aynı doğrultuda bitişik.
    final step = across ? 1 : n;
    var start = cells.first;
    while (_prev(start, across) >= 0 && at(_prev(start, across)).isNotEmpty) {
      start = _prev(start, across);
    }
    var end = cells.last;
    while (_next(end, across) >= 0 && at(_next(end, across)).isNotEmpty) {
      end = _next(end, across);
    }
    for (var i = start; i <= end; i += step) {
      if (at(i).isEmpty) return null;
    }
    final words = <String>[];
    var score = 0;
    var touches = false;
    final main = _scoreLine(board, tiles, start, end, step);
    if (main.$1.length >= 2) {
      words.add(main.$1);
      score += main.$2;
    }
    // Dik kelimeler.
    for (final c in cells) {
      var s = c, e = c;
      while (_prev(s, !across) >= 0 && at(_prev(s, !across)).isNotEmpty) {
        s = _prev(s, !across);
      }
      while (_next(e, !across) >= 0 && at(_next(e, !across)).isNotEmpty) {
        e = _next(e, !across);
      }
      if (s != e) {
        final cross = _scoreLine(board, tiles, s, e, across ? n : 1);
        words.add(cross.$1);
        score += cross.$2;
        touches = true;
      }
    }
    for (var i = start; i <= end; i += step) {
      if (board[i].isNotEmpty) touches = true;
    }
    if (!empty && !touches) return null;
    if (words.isEmpty) return null;
    for (final w in words) {
      if (!lx.has(w)) return null;
    }
    if (tiles.length == 7) score += 35;
    return BMove(Map.of(tiles), score, words);
  }

  int _prev(int i, bool across) {
    if (across) return i % n == 0 ? -1 : i - 1;
    return i - n < 0 ? -1 : i - n;
  }

  int _next(int i, bool across) {
    if (across) return i % n == n - 1 ? -1 : i + 1;
    return i + n >= n * n ? -1 : i + n;
  }

  (String, int) _scoreLine(List<String> board, Map<int, String> tiles, int s, int e, int step) {
    final b = StringBuffer();
    var sum = 0, mult = 1;
    for (var i = s; i <= e; i += step) {
      final fresh = tiles.containsKey(i);
      final ch = tiles[i] ?? board[i];
      b.write(ch);
      var v = lx.letterValue(ch);
      if (fresh) {
        switch (prem[i]) {
          case 1:
            v *= 2;
          case 2:
            v *= 3;
          case 3:
            mult *= 2;
          case 4:
            mult *= 3;
        }
      }
      sum += v;
    }
    return (b.toString(), sum * mult);
  }

  /// Rakip: rafla yapılabilecek hamleler (en iyiler önce).
  List<BMove> movesFor(List<String> board, List<String> rack, {int limit = 4000}) {
    final out = <BMove>[];
    final rackCount = letterCounts(rack.join());
    final empty = board.every((c) => c.isEmpty);
    var budget = limit;
    for (final across in [true, false]) {
      for (var line = 0; line < n; line++) {
        final cellsOf = [for (var k = 0; k < n; k++) across ? line * n + k : k * n + line];
        final lineLetters = [for (final c in cellsOf) board[c]];
        if (empty && line != n ~/ 2) continue;
        final hasTile = lineLetters.any((c) => c.isNotEmpty);
        // Komşu satırda taş yoksa ve bu satır boşsa geç.
        if (!empty && !hasTile) {
          var near = false;
          for (final c in cellsOf) {
            for (final d in [-1, 1]) {
              final nb = across ? c + d * n : c + d;
              if (nb >= 0 && nb < n * n && (across || (c % n + d >= 0 && c % n + d < n)) && board[nb].isNotEmpty) near = true;
            }
          }
          if (!near) continue;
        }
        final pool = Map.of(rackCount);
        for (final ch in lineLetters) {
          if (ch.isNotEmpty) pool[ch] = (pool[ch] ?? 0) + 1;
        }
        for (final w in lx.words) {
          if (w.length > n || w.length < 2) continue;
          if (!canSpell(w, pool)) continue;
          for (var s = 0; s + w.length <= n; s++) {
            if (--budget < 0) {
              out.sort((a, b) => b.score.compareTo(a.score));
              return out;
            }
            if (s > 0 && lineLetters[s - 1].isNotEmpty) continue;
            if (s + w.length < n && lineLetters[s + w.length].isNotEmpty) continue;
            final tiles = <int, String>{};
            final need = Map.of(rackCount);
            var ok = true;
            for (var k = 0; k < w.length; k++) {
              final cur = lineLetters[s + k];
              if (cur.isNotEmpty) {
                if (cur != w[k]) {
                  ok = false;
                  break;
                }
              } else {
                final left = need[w[k]] ?? 0;
                if (left <= 0) {
                  ok = false;
                  break;
                }
                need[w[k]] = left - 1;
                tiles[cellsOf[s + k]] = w[k];
              }
            }
            if (!ok || tiles.isEmpty) continue;
            final mv = evaluate(board, tiles);
            if (mv != null) out.add(mv);
          }
        }
      }
    }
    out.sort((a, b) => b.score.compareTo(a.score));
    return out;
  }
}

class _BoardView extends StatefulWidget {
  final WordPlay play;
  const _BoardView({required this.play});

  @override
  State<_BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<_BoardView> with SecondsTicker, Flash {
  late BoardPuzzle p;
  late BoardRules rules;
  late List<String> board;
  late List<String> bag;
  final List<String> rack = [], botRack = [];
  final Map<int, int> pending = {}; // hücre → raf dizini
  int? selRack;
  int me = 0, bot = 0, myTurns = 0, botTurns = 0, passes = 0;
  bool botThinking = false;
  String lastBot = '';
  late SeededRandom botRng;

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;
  WordNet? get net => play.net;

  /// Çevrimiçi rakip hâlâ masada mı (koparsa bilgisayar oynar).
  bool get online => net != null && !net!.oppGone;
  int _oi = 0;
  bool _botBusy = false;

  @override
  void initState() {
    super.initState();
    p = play.puzzle as BoardPuzzle;
    rules = BoardRules(lx);
    board = List<String>.filled(kBoardN * kBoardN, '');
    bag = List.of(p.bag);
    botRng = SeededRandom(play.seed ^ 0xB0A7);
    final n = net;
    // Taşlar koltuk sırasıyla çekilir (0. koltuk önce): iki cihazda aynı torba.
    if (n != null && n.me == 1) {
      _draw(botRack);
      _draw(rack);
    } else {
      _draw(rack);
      _draw(botRack);
    }
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

  void _draw(List<String> r) {
    while (r.length < 7 && bag.isNotEmpty) {
      r.add(bag.removeLast());
    }
  }

  /// Taş değişimi: raf sıralı olarak torbanın dibine gider (iki cihazda aynı sıra).
  void _swapRack(List<String> r) {
    bag.insertAll(0, List.of(r)..sort());
    r.clear();
    _draw(r);
  }

  static String encode(Map<int, String> tiles) => 'P:${[for (final e in tiles.entries) '${e.key}=${e.value}'].join(';')}';

  static Map<int, String>? decode(String mv) {
    if (!mv.startsWith('P:')) return null;
    final out = <int, String>{};
    for (final part in mv.substring(2).split(';')) {
      final k = part.indexOf('=');
      if (k <= 0) return null;
      final cell = int.tryParse(part.substring(0, k));
      if (cell == null || cell < 0 || cell >= kBoardN * kBoardN) return null;
      out[cell] = part.substring(k + 1);
    }
    return out.isEmpty ? null : out;
  }

  /// Bir hamleyi uygula ([mine]: bu cihazın oyuncusu). "P:hücre=harf;…", "S" değişim, "X" pas.
  String _apply(bool mine, String mv) {
    final r = mine ? rack : botRack;
    final tiles = decode(mv);
    if (tiles != null) {
      final m = rules.evaluate(board, tiles);
      final pool = List.of(r);
      final ok = m != null && tiles.values.every(pool.remove);
      if (ok) {
        m.tiles.forEach((k, v) {
          board[k] = v;
          r.remove(v);
        });
        if (mine) {
          me += m.score;
          myTurns++;
        } else {
          bot += m.score;
          botTurns++;
        }
        passes = 0;
        _draw(r);
        return '${m.words.map(lx.up).join(', ')} +${m.score}';
      }
      mv = 'X';
    }
    if (mv == 'S' && bag.length >= 7) _swapRack(r);
    passes++;
    if (mine) {
      myTurns++;
    } else {
      botTurns++;
    }
    return kt(play.lang, 'pass');
  }

  /// Maça geri dönüldüyse hamleleri koltuk sırasıyla yeniden uygula.
  void _replay() {
    final n = net!;
    var seat = 0, im = 0;
    while (true) {
      if (seat == n.me) {
        if (im >= n.mine.length) break;
        _apply(true, n.mine[im++]);
      } else {
        if (_oi >= n.theirs.length) break;
        lastBot = _apply(false, n.theirs[_oi++]);
      }
      seat = 1 - seat;
      if (_gameOver) break;
    }
    botThinking = seat != n.me;
    if (_gameOver) WidgetsBinding.instance.addPostFrameCallback((_) => _finish());
  }

  void _onNet() {
    final n = net;
    if (n == null || !mounted || ended || !botThinking) return;
    if (_oi >= n.theirs.length) return;
    setState(() {
      lastBot = _apply(false, n.theirs[_oi++]);
      botThinking = false;
    });
    play.ctx.sfx(Sfx.tap);
    if (_gameOver) _finish();
  }

  @override
  void onTick() {
    // Rakip koptuysa sırası bilgisayara geçer.
    if (!ended && botThinking && net != null && net!.oppGone && !_botBusy) _afterMine();
  }

  Map<int, String> get pendingTiles => {for (final e in pending.entries) e.key: rack[e.value]};

  void _tapCell(int i) {
    if (ended || botThinking) return;
    if (pending.containsKey(i)) {
      setState(() => pending.remove(i));
      return;
    }
    if (board[i].isNotEmpty || selRack == null) return;
    setState(() {
      pending[i] = selRack!;
      selRack = null;
    });
    play.ctx.sfx(Sfx.place);
  }

  void _submit() {
    if (ended || botThinking || pending.isEmpty) return;
    final tiles = pendingTiles;
    final mv = rules.evaluate(board, tiles);
    if (mv == null) {
      play.ctx.sfx(Sfx.error);
      flash(kt(play.lang, 'notWord'));
      return;
    }
    final code = encode(tiles);
    setState(() {
      pending.clear();
      _apply(true, code);
    });
    net?.send(code);
    play.ctx.sfx(Sfx.combo);
    flash('${mv.words.map(lx.up).join(', ')}  +${mv.score}');
    _afterMine();
  }

  void _pass({bool swap = false}) {
    if (ended || botThinking) return;
    final code = swap ? 'S' : 'X';
    setState(() {
      pending.clear();
      _apply(true, code);
    });
    net?.send(code);
    _afterMine();
  }

  bool get _gameOver =>
      (myTurns >= p.turns && botTurns >= p.turns) || (bag.isEmpty && (rack.isEmpty || botRack.isEmpty)) || passes >= 4;

  void _afterMine() {
    if (_gameOver) return _finish();
    setState(() => botThinking = true);
    if (online) {
      // Rakibin hamlesi ağdan gelir.
      _onNet();
      return;
    }
    _botBusy = true;
    Future.delayed(const Duration(milliseconds: 600), () {
      _botBusy = false;
      if (!mounted || ended) return;
      final moves = rules.movesFor(board, botRack);
      setState(() {
        botThinking = false;
        if (moves.isEmpty) {
          lastBot = _apply(false, 'S');
        } else {
          // Zorluğa göre en iyi hamleden ya da daha zayıf bir hamleden seç.
          final q = (1 - play.d / 10) * 0.6;
          final idx = math.min(moves.length - 1, (moves.length * q * botRng.nextDouble()).floor());
          lastBot = _apply(false, encode(moves[idx].tiles));
        }
      });
      play.ctx.sfx(Sfx.tap);
      if (_gameOver) _finish();
    });
  }

  void _finish() {
    if (ended) return;
    ended = true;
    final h = '${kt(play.lang, 'you')} $me — ${kt(play.lang, 'rival')} $bot';
    final n = net;
    if (n != null) n.finish(me > bot ? n.me : (me < bot ? n.opp : -1));
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (me >= bot) {
        play.ctx.sfx(Sfx.win);
        play.win(score: me * 5, stars: me - bot >= 40 ? 3 : (me - bot >= 15 ? 2 : 1), seconds: seconds, stats: {'words_found': myTurns});
      } else {
        play.ctx.sfx(Sfx.lose);
        play.lose(score: me * 5, seconds: seconds, headline: h);
      }
    });
  }

  Future<void> _hint() async {
    if (ended || botThinking) return;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    final moves = rules.movesFor(board, rack, limit: 3000);
    if (moves.isEmpty) {
      flash(kt(play.lang, 'swap'));
      return;
    }
    final mv = moves.first;
    setState(() {
      pending.clear();
      final usedIdx = <int>{};
      mv.tiles.forEach((cell, ch) {
        for (var i = 0; i < rack.length; i++) {
          if (rack[i] == ch && !usedIdx.contains(i)) {
            usedIdx.add(i);
            pending[cell] = i;
            break;
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = play.lang;
    final prem = rules.prem;
    final usedIdx = pending.values.toSet();
    const premColors = [WColors.tile, Color(0xFFBFD7EA), Color(0xFF7FA7D1), Color(0xFFF1C6B6), Color(0xFFE07A5F)];
    const premLabels = ['', '2H', '3H', '2K', '3K'];
    return Column(children: [
      WordBar(
        play: play,
        left: '${kt(lang, 'you')} $me',
        status: '${kt(lang, 'rival')} $bot · ${kt(lang, 'bag')}: ${bag.length}',
        onHint: _hint,
      ),
      flashLine(),
      if (net != null) Text(kt(lang, botThinking ? 'rivalTurn' : 'yourTurn'), style: const TextStyle(fontWeight: FontWeight.w800)),
      if (lastBot.isNotEmpty) Text('${kt(lang, 'rival')}: $lastBot', style: const TextStyle(fontWeight: FontWeight.w600)),
      Expanded(
        child: LayoutBuilder(builder: (context, box) {
          final cs = math.min((box.maxWidth - 12) / kBoardN, (box.maxHeight - 6) / kBoardN);
          return InteractiveViewer(
            maxScale: 2.5,
            child: Center(
              child: SizedBox(
                width: cs * kBoardN,
                height: cs * kBoardN,
                child: GridView.count(
                  crossAxisCount: kBoardN,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var i = 0; i < kBoardN * kBoardN; i++)
                      GestureDetector(
                        onTap: () => _tapCell(i),
                        child: Container(
                          margin: const EdgeInsets.all(0.6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: board[i].isNotEmpty
                                ? const Color(0xFFF3E1B9)
                                : (pending.containsKey(i) ? WColors.near : premColors[prem[i]]),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: board[i].isNotEmpty || pending.containsKey(i)
                              ? Text(lx.upCh(board[i].isNotEmpty ? board[i] : rack[pending[i]!]),
                                  style: TextStyle(fontSize: cs * 0.52, fontWeight: FontWeight.w800, color: WColors.ink))
                              : (i == BoardRules.center
                                  ? Icon(Icons.star, size: cs * 0.5, color: WColors.on(premColors[prem[i]]))
                                  : Text(premLabels[prem[i]], style: TextStyle(fontSize: cs * 0.28, color: WColors.on(premColors[prem[i]]), fontWeight: FontWeight.w800))),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
      Padding(
        padding: const EdgeInsets.all(4),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var i = 0; i < rack.length; i++)
            Padding(
              padding: const EdgeInsets.all(2),
              child: Opacity(
                opacity: usedIdx.contains(i) ? 0.25 : 1,
                child: LetterTile(
                  letter: lx.upCh(rack[i]),
                  value: lx.letterValue(rack[i]),
                  size: 44,
                  selected: selRack == i,
                  onTap: usedIdx.contains(i) ? null : () => setState(() => selRack = i),
                ),
              ),
            ),
        ]),
      ),
      Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
        IconButton.filledTonal(tooltip: kt(lang, 'clear'), onPressed: () => setState(pending.clear), icon: const Icon(Icons.undo)),
        IconButton.filledTonal(
          tooltip: kt(lang, 'shuffle'),
          onPressed: pending.isEmpty ? () => setState(() => rack.shuffle()) : null,
          icon: const Icon(Icons.shuffle),
        ),
        IconButton.filledTonal(tooltip: kt(lang, 'swap'), onPressed: () => _pass(swap: true), icon: const Icon(Icons.swap_horiz)),
        TextButton(onPressed: () => _pass(), child: Text(kt(lang, 'pass'))),
        BigButton(label: kt(lang, 'submit'), onPressed: botThinking ? null : _submit),
      ]),
      const SizedBox(height: 6),
    ]);
  }
}
