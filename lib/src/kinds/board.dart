import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:studio_core/app/game_api.dart';
import 'package:studio_core/app/services/audio.dart';
import 'package:studio_core/core/game_rules.dart';
import 'package:studio_core/core/rng.dart';

import '../core.dart';
import '../texts.dart';
import '../ui.dart';
import '../words.dart';

/// Kelime kurma tahtası: 2–4 kişi (bilgisayar, aynı cihaz ya da çevrimiçi)
/// harf taşlarıyla tahtaya kelime dizer. Çevrimiçi maçta hamle günlüğü
/// ("P:hücre=harf;…" yerleştirme, "S" değişim, "X" pas, "C" itiraz) bütün
/// cihazlarda aynı sırayla uygulanır; torba maçın ortak tohumundan kurulur.
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

  /// Aynı cihazda ya da çevrimiçi masada 2–4 kişi.
  @override
  int get maxPlayers => 4;

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

  /// Geçerliyse hamleyi döndürür. [dict] false: yalnızca dizilim denetlenir
  /// (sözlükte olmayan kelime itiraz edilene kadar tahtada kalabilir).
  BMove? evaluate(List<String> board, Map<int, String> tiles, {bool dict = true}) {
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
    if (dict) {
      for (final w in words) {
        if (!lx.has(w)) return null;
      }
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

/// İtiraz edilebilecek son yerleştirme (geri alma için her şeyi tutar).
class _LastPlay {
  final int seat, score, prevScoreless;
  final Map<int, String> tiles;
  final List<String> words;

  /// Hamleden sonra torbadan çekilen taşlar (çekiliş sırasıyla).
  final List<String> drawn;
  const _LastPlay(this.seat, this.tiles, this.words, this.score, this.drawn, this.prevScoreless);
}

/// Tahtanın oyun durumu: arayüzden bağımsız, her cihazda aynı hamlelerle
/// aynı sonuca varır (testlerde doğrudan kullanılır).
class BoardGame {
  final BoardRules rules;
  final int seats;
  final int turnLimit;
  final List<String> board = List<String>.filled(kBoardN * kBoardN, '');
  final List<String> bag;
  final List<List<String>> racks;
  final List<int> scores, turns;
  int cur = 0;

  /// Art arda puansız hamle sayısı (pas, değişim, geri alınan hamle, boş itiraz).
  int scoreless = 0;
  _LastPlay? last;

  /// Uygulanan bütün hamleler (kayıt ve geri dönüş için).
  final List<(int, String)> history = [];

  BoardGame(this.rules, BoardPuzzle p, this.seats)
      : turnLimit = p.turns,
        bag = List.of(p.bag),
        racks = [for (var i = 0; i < seats; i++) <String>[]],
        scores = List<int>.filled(seats, 0),
        turns = List<int>.filled(seats, 0) {
    // Taşlar koltuk sırasıyla çekilir: her cihazda aynı raflar.
    for (final r in racks) {
      _draw(r);
    }
  }

  Lexicon get lx => rules.lx;

  void _draw(List<String> r) {
    while (r.length < 7 && bag.isNotEmpty) {
      r.add(bag.removeLast());
    }
  }

  /// Taş değişimi: raf sıralı olarak torbanın dibine gider (her cihazda aynı sıra).
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

  bool get over =>
      turns.every((t) => t >= turnLimit) || (bag.isEmpty && racks.any((r) => r.isEmpty)) || scoreless >= 2 * seats;

  /// Kazanan koltuk; eşitlikte -1.
  int get winner {
    final top = scores.reduce(math.max);
    final at = [for (var i = 0; i < seats; i++) if (scores[i] == top) i];
    return at.length == 1 ? at.first : -1;
  }

  /// [seat] şimdi itiraz edebilir mi (yalnızca hemen sonraki oyuncu).
  bool canChallenge(int seat) {
    final l = last;
    return l != null && seat == cur && (l.seat + 1) % seats == seat && !over;
  }

  /// Son yerleştirmede sözlükte olmayan kelimeler.
  List<String> get lastInvalid => [for (final w in last?.words ?? const <String>[]) if (!lx.has(w)) w];

  void _endTurn(int seat) {
    turns[seat]++;
    cur = (cur + 1) % seats;
  }

  /// Bir hamleyi uygula ve olayı anlatan kısa metni döndür. Sırası gelmeyen
  /// koltuğun hamlesi (bozuk günlük) her cihazda aynı biçimde yok sayılır: null.
  /// Dönen kayıt: (tür, kelimeler, puan) — tür 'P','S','X','C+','C-'.
  (String, List<String>, int)? apply(int seat, String mv) {
    if (seat != cur || over) return null;
    history.add((seat, mv));
    final r = racks[seat];
    if (mv == 'C') {
      final l = last;
      last = null;
      if (l == null || (l.seat + 1) % seats != seat) {
        scoreless++;
        _endTurn(seat);
        return ('X', const [], 0);
      }
      final bad = [for (final w in l.words) if (!lx.has(w)) w];
      if (bad.isEmpty) {
        // Kelimeler geçerli: itiraz eden sırasını kaybeder.
        scoreless++;
        _endTurn(seat);
        return ('C-', l.words, 0);
      }
      // Hamle geri alınır: taşlar rafa, çekilenler torbaya, puan düşer.
      l.tiles.forEach((k, _) => board[k] = '');
      final lr = racks[l.seat];
      for (final t in l.drawn) {
        lr.remove(t);
      }
      bag.addAll(l.drawn.reversed);
      lr.addAll(l.tiles.values);
      scores[l.seat] -= l.score;
      scoreless = l.prevScoreless + 1;
      // İtiraz eden sırasını korur ve şimdi oynar.
      return ('C+', bad, l.score);
    }
    final prev = scoreless;
    last = null;
    final tiles = decode(mv);
    if (tiles != null) {
      final m = rules.evaluate(board, tiles, dict: false);
      final pool = List.of(r);
      if (m != null && tiles.values.every(pool.remove)) {
        m.tiles.forEach((k, v) {
          board[k] = v;
          r.remove(v);
        });
        scores[seat] += m.score;
        final before = r.length;
        _draw(r);
        last = _LastPlay(seat, Map.of(m.tiles), m.words, m.score, r.sublist(before), prev);
        scoreless = 0;
        _endTurn(seat);
        return ('P', m.words, m.score);
      }
      mv = 'X';
    }
    if (mv == 'S' && bag.length >= 7) {
      _swapRack(r);
    } else {
      mv = 'X';
    }
    scoreless++;
    _endTurn(seat);
    return (mv, const [], 0);
  }

  /// Bilgisayarın hamlesi: önce haksız kelimeye itiraz, sonra zorluğa göre
  /// en iyi ya da daha zayıf bir yerleştirme; yoksa değişim/pas.
  String botMove(SeededRandom rng, int d) {
    if (canChallenge(cur) && lastInvalid.isNotEmpty) return 'C';
    final moves = rules.movesFor(board, racks[cur]);
    if (moves.isEmpty) return bag.length >= 7 ? 'S' : 'X';
    final q = (1 - d / 10) * 0.6;
    final idx = math.min(moves.length - 1, (moves.length * q * rng.nextDouble()).floor());
    return encode(moves[idx].tiles);
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
  late BoardGame g;
  late List<SeatRole> roles;
  final Map<int, int> pending = {}; // hücre → raf dizini
  int? selRack;
  String lastMsg = '';
  late SeededRandom botRng;
  bool _botBusy = false;

  /// Aynı cihazda oyun: sıradaki oyuncu dokunana kadar raflar gizli.
  bool _covered = false;
  int _logPos = 0;

  WordPlay get play => widget.play;
  Lexicon get lx => play.lx;
  WordNet? get net => play.net;
  String get lang => play.lang;
  int get me => net?.me ?? 0;

  bool get _localMulti => net == null && play.ctx.passAndPlay;

  /// Ekranda rafı gösterilen koltuk.
  int get viewer => _localMulti ? g.cur : me;
  List<String> get rack => g.racks[viewer];

  /// Koltuğu bu cihazda bilgisayar mı oynuyor (bot ya da kopan oyuncu).
  bool _isBot(int s) {
    if (roles[s] == SeatRole.ai) return true;
    final n = net;
    return n != null && roles[s] == SeatRole.remote && n.gone(s);
  }

  bool get myTurn => !ended && roles[g.cur] == SeatRole.local && (_localMulti || g.cur == me);

  String seatName(int s) {
    if (net == null && !_localMulti) return s == me ? kt(lang, 'you') : kt(lang, 'bot');
    final name = play.ctx.seatName(s);
    if (s == me && !_localMulti) return '${kt(lang, 'you')} ($name)';
    return roles[s] == SeatRole.ai ? '$name 🤖' : name;
  }

  @override
  void initState() {
    super.initState();
    p = play.puzzle as BoardPuzzle;
    rules = BoardRules(lx);
    botRng = SeededRandom(play.seed ^ 0xB0A7);
    final n = net;
    final ctx = play.ctx;
    int seats;
    if (n != null) {
      seats = n.seats.clamp(2, 4);
      roles = [for (var i = 0; i < seats; i++) i == n.me ? SeatRole.local : (ctx.role(i) == SeatRole.local ? SeatRole.remote : ctx.role(i))];
    } else if (ctx.passAndPlay) {
      seats = ctx.seats.length.clamp(2, 4);
      roles = List.filled(seats, SeatRole.local);
    } else {
      seats = 2;
      roles = const [SeatRole.local, SeatRole.ai];
    }
    g = BoardGame(rules, p, seats);
    if (n != null) {
      n.listen(_onNet);
      _pump(replay: true);
    } else {
      // Kaldığı yerden: kayıtlı hamleler yeniden uygulanır.
      final saved = play.resume['bl'];
      if (saved is List && play.resume['bn'] == seats) {
        for (final e in saved) {
          if (e is List && e.length == 2 && e[0] is num && e[1] is String) g.apply((e[0] as num).toInt(), e[1] as String);
        }
      }
      _covered = _localMulti;
    }
    startTicker((play.resume['s'] as num?)?.toInt() ?? 0);
    WidgetsBinding.instance.addPostFrameCallback((_) => _afterChange());
  }

  @override
  void dispose() {
    net?.unlisten(_onNet);
    super.dispose();
  }

  void _save() {
    if (net != null) return;
    play.save({
      'bn': g.seats,
      's': seconds,
      'bl': [for (final (s, m) in g.history) [s, m]],
    });
  }

  /// Günlükteki yeni hamleleri sırayla uygular (çevrimiçi).
  void _pump({bool replay = false}) {
    final n = net;
    if (n == null) return;
    while (_logPos < n.log.length) {
      final (seat, mv) = n.log[_logPos++];
      final r = g.apply(seat, mv);
      if (r != null && !replay) _announce(seat, r);
    }
  }

  void _announce(int seat, (String, List<String>, int) r) {
    final who = seatName(seat);
    switch (r.$1) {
      case 'P':
        lastMsg = '$who: ${r.$2.map(lx.up).join(', ')} +${r.$3}';
      case 'C+':
        lastMsg = '$who: ${kt(lang, 'upheld')} (${r.$2.map(lx.up).join(', ')})';
        flash(kt(lang, 'upheld'));
      case 'C-':
        lastMsg = '$who: ${kt(lang, 'rejected')}';
        flash(kt(lang, 'rejected'));
      case 'S':
        lastMsg = '$who: ${kt(lang, 'swap')}';
      default:
        lastMsg = '$who: ${kt(lang, 'pass')}';
    }
  }

  void _onNet() {
    if (!mounted || ended) return;
    setState(_pump);
    play.ctx.sfx(Sfx.tap);
    _afterChange();
  }

  @override
  void onTick() {
    // Kopan oyuncunun sırası bilgisayara geçer (ev sahibi oynatır).
    if (!ended) _afterChange();
  }

  /// Bu cihazın bir hamlesini uygula (çevrimiçiyse yayınla).
  void _act(String mv, {int? asSeat}) {
    final seat = asSeat ?? g.cur;
    final n = net;
    pending.clear();
    selRack = null;
    if (n != null) {
      n.send(mv, asSeat: seat == me ? null : seat);
      _pump();
    } else {
      final r = g.apply(seat, mv);
      if (r != null) _announce(seat, r);
      if (_localMulti && roles[g.cur] == SeatRole.local && g.cur != seat) _covered = true;
      _save();
    }
  }

  /// Sıra bilgisayardaysa oynat; oyun bittiyse bitir.
  void _afterChange() {
    if (!mounted || ended) return;
    if (g.over) return _finish();
    final cur = g.cur;
    if (!_isBot(cur) || _botBusy) return;
    final n = net;
    if (n != null && !n.isHost) return;
    _botBusy = true;
    Future.delayed(const Duration(milliseconds: 600), () {
      _botBusy = false;
      if (!mounted || ended || g.cur != cur || !_isBot(cur)) return;
      if (n != null && !n.isHost) return;
      setState(() => _act(g.botMove(botRng, play.d), asSeat: cur));
      play.ctx.sfx(Sfx.tap);
      _afterChange();
    });
  }

  Map<int, String> get pendingTiles => {for (final e in pending.entries) e.key: rack[e.value]};

  void _tapCell(int i) {
    if (!myTurn || _covered) return;
    if (pending.containsKey(i)) {
      setState(() => pending.remove(i));
      return;
    }
    if (g.board[i].isNotEmpty || selRack == null) return;
    setState(() {
      pending[i] = selRack!;
      selRack = null;
    });
    play.ctx.sfx(Sfx.place);
  }

  /// İnsan rakip varken (çevrimiçi ya da aynı cihaz) sözlükte olmayan kelime
  /// itiraz edilmek üzere oynanabilir; bilgisayara karşı sözlük kesindir.
  bool get _challengeMode => net != null || _localMulti;

  Future<void> _submit() async {
    if (!myTurn || pending.isEmpty) return;
    final tiles = pendingTiles;
    var mv = rules.evaluate(g.board, tiles);
    if (mv == null) {
      final loose = _challengeMode ? rules.evaluate(g.board, tiles, dict: false) : null;
      if (loose == null) {
        play.ctx.sfx(Sfx.error);
        flash(kt(lang, 'notWord'));
        return;
      }
      // Oyunu bitirecek hamle (son tur ya da raf + torba boşalıyor) itiraz
      // edilemeyeceği için sözlükte olmalı.
      final s = g.cur;
      final ending = g.turns[s] + 1 >= g.turnLimit && g.turns.where((t) => t >= g.turnLimit).length >= g.seats - 1;
      if (ending || (g.bag.isEmpty && tiles.length == rack.length)) {
        play.ctx.sfx(Sfx.error);
        flash(kt(lang, 'mustBeValid'));
        return;
      }
      final ok = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              content: Text(kt(lang, 'notInDict')),
              actions: [
                TextButton(onPressed: () => Navigator.pop(c, false), child: Text(MaterialLocalizations.of(c).cancelButtonLabel)),
                FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(kt(lang, 'playAnyway'))),
              ],
            ),
          ) ??
          false;
      if (!ok || !mounted || !myTurn) return;
      mv = loose;
    }
    final words = mv.words, score = mv.score;
    setState(() => _act(BoardGame.encode(tiles)));
    play.ctx.sfx(Sfx.combo);
    flash('${words.map(lx.up).join(', ')}  +$score');
    _afterChange();
  }

  void _pass({bool swap = false}) {
    if (!myTurn || _covered) return;
    setState(() => _act(swap ? 'S' : 'X'));
    _afterChange();
  }

  void _challenge() {
    if (!myTurn || _covered || !g.canChallenge(g.cur)) return;
    setState(() => _act('C'));
    play.ctx.sfx(Sfx.tap);
    _afterChange();
  }

  void _finish() {
    if (ended) return;
    ended = true;
    final w = g.winner;
    final n = net;
    if (n != null) n.finish(w);
    final h = [for (var i = 0; i < g.seats; i++) '${seatName(i)} ${g.scores[i]}'].join(' — ');
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final mine = g.scores[me];
      if (_localMulti) {
        play.ctx.sfx(Sfx.win);
        play.ctx.finish(RoundResult(
          won: true,
          score: g.scores.reduce(math.max) * 5,
          stars: 3,
          seconds: seconds,
          headline: w >= 0 ? '${play.ctx.seatName(w)} 🏆 · $h' : '${kt(lang, 'draw')} · $h',
          gameStats: {'rounds_won': 1, 'words_found': g.turns.reduce((a, b) => a + b)},
          winnerSeat: w,
        ));
        return;
      }
      final best = g.scores.reduce(math.max);
      if (mine >= best) {
        play.ctx.sfx(Sfx.win);
        final second = [for (var i = 0; i < g.seats; i++) if (i != me) g.scores[i]].fold<int>(0, math.max);
        play.win(
            score: mine * 5,
            stars: mine - second >= 40 ? 3 : (mine - second >= 15 ? 2 : 1),
            seconds: seconds,
            stats: {'words_found': g.turns[me]});
      } else {
        play.ctx.sfx(Sfx.lose);
        play.lose(score: mine * 5, seconds: seconds, headline: h);
      }
    });
  }

  Future<void> _hint() async {
    if (!myTurn || _covered) return;
    if (!await play.ctx.requestHint()) return;
    if (!mounted) return;
    final moves = rules.movesFor(g.board, rack, limit: 3000);
    if (moves.isEmpty) {
      flash(kt(lang, 'swap'));
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
    final prem = rules.prem;
    final usedIdx = pending.values.toSet();
    const premColors = [WColors.tile, Color(0xFFBFD7EA), Color(0xFF7FA7D1), Color(0xFFF1C6B6), Color(0xFFE07A5F)];
    const premLabels = ['', '2H', '3H', '2K', '3K'];
    final board = g.board;
    final canAct = myTurn && !_covered;
    final scores = [
      for (var i = 0; i < g.seats; i++) '${i == g.cur ? '▶ ' : ''}${seatName(i)} ${g.scores[i]}',
    ];
    return Column(children: [
      WordBar(
        play: play,
        left: _localMulti ? seatName(g.cur) : '${kt(lang, 'you')} ${g.scores[me]}',
        status: '${kt(lang, 'bag')}: ${g.bag.length}',
        onHint: _hint,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Wrap(alignment: WrapAlignment.center, spacing: 10, children: [
          for (var i = 0; i < scores.length; i++)
            Text(scores[i],
                style: TextStyle(fontWeight: i == g.cur ? FontWeight.w900 : FontWeight.w600, fontSize: 13)),
        ]),
      ),
      flashLine(),
      if (net != null || _localMulti)
        Text(
            myTurn
                ? (_localMulti ? kt(lang, 'turnOf').replaceAll('{0}', seatName(g.cur)) : kt(lang, 'yourTurn'))
                : kt(lang, 'turnOf').replaceAll('{0}', seatName(g.cur)),
            style: const TextStyle(fontWeight: FontWeight.w800)),
      if (lastMsg.isNotEmpty)
        Text(lastMsg, maxLines: 2, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
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
                                ? (g.last?.tiles.containsKey(i) == true ? const Color(0xFFFFE08A) : const Color(0xFFF3E1B9))
                                : (pending.containsKey(i) ? WColors.near : premColors[prem[i]]),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: board[i].isNotEmpty || pending.containsKey(i)
                              ? Text(lx.upCh(board[i].isNotEmpty ? board[i] : rack[pending[i]!]),
                                  style: TextStyle(fontSize: cs * 0.52, fontWeight: FontWeight.w800, color: WColors.ink))
                              : (i == BoardRules.center
                                  ? Icon(Icons.star, size: cs * 0.5, color: WColors.on(premColors[prem[i]]))
                                  : Text(premLabels[prem[i]],
                                      style: TextStyle(fontSize: cs * 0.28, color: WColors.on(premColors[prem[i]]), fontWeight: FontWeight.w800))),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
      if (_covered)
        Padding(
          padding: const EdgeInsets.all(8),
          child: BigButton(
            label: '${kt(lang, 'turnOf').replaceAll('{0}', seatName(g.cur))} · ${kt(lang, 'tapReady')}',
            onPressed: () => setState(() => _covered = false),
          ),
        )
      else
        Padding(
          padding: const EdgeInsets.all(4),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < rack.length; i++)
              Padding(
                padding: const EdgeInsets.all(2),
                child: Opacity(
                  opacity: usedIdx.contains(i) || !canAct ? 0.35 : 1,
                  child: LetterTile(
                    letter: lx.upCh(rack[i]),
                    value: lx.letterValue(rack[i]),
                    size: 44,
                    selected: selRack == i,
                    onTap: usedIdx.contains(i) || !canAct ? null : () => setState(() => selRack = i),
                  ),
                ),
              ),
          ]),
        ),
      Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
        IconButton.filledTonal(tooltip: kt(lang, 'clear'), onPressed: () => setState(pending.clear), icon: const Icon(Icons.undo)),
        IconButton.filledTonal(
          tooltip: kt(lang, 'shuffle'),
          onPressed: pending.isEmpty && canAct ? () => setState(() => rack.shuffle()) : null,
          icon: const Icon(Icons.shuffle),
        ),
        IconButton.filledTonal(
            tooltip: kt(lang, 'swap'), onPressed: canAct ? () => _pass(swap: true) : null, icon: const Icon(Icons.swap_horiz)),
        if (_challengeMode)
          TextButton.icon(
            key: const ValueKey('board-challenge'),
            onPressed: canAct && g.canChallenge(g.cur) ? _challenge : null,
            icon: const Icon(Icons.gavel_rounded),
            label: Text(kt(lang, 'challenge')),
          ),
        TextButton(onPressed: canAct ? () => _pass() : null, child: Text(kt(lang, 'pass'))),
        BigButton(label: kt(lang, 'submit'), onPressed: canAct ? _submit : null),
      ]),
      const SizedBox(height: 6),
    ]);
  }
}
