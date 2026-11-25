import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studio_core/app/game_api.dart';
import 'package:studio_core/core/game_rules.dart';
import 'package:studio_core/core/level_plan.dart';
import 'package:studio_core/core/missions.dart';
import 'package:studio_core/core/rng.dart';
import 'package:studio_core/core/strings.dart';
import 'package:studio_core/core/stats.dart';

import 'words.dart';

/// Bir kelime oyununun kurulmuş bölümü (türe özgü veri).
abstract class WPuzzle {
  const WPuzzle();
}

/// Bölüm tarifi: tür, tohum ve zorluk; [lang] dilinde kurulmuş hali [puzzle].
class WLevel {
  final String kind;
  final int seed;
  final int d;
  final String lang;
  final WPuzzle puzzle;
  const WLevel(this.kind, this.seed, this.d, this.lang, this.puzzle);
}

/// Kelime oyunu türü: bölüm kurma, denetim ve oyun ekranı.
abstract class WordKind {
  const WordKind();

  String get id;

  /// İçeriğin olduğu diller (null: kelime listesi olan bütün diller).
  List<String>? get contentLangs => null;

  /// Zorluk 1..10 için deterministik bölüm. Kurulamazsa null.
  WPuzzle? make(Lexicon lx, int d, SeededRandom r);

  /// Bölüm kurallara uygun ve çözülebilir mi.
  bool check(WPuzzle p, Lexicon lx) => true;

  /// Oyun ekranı.
  Widget build(WordPlay play);

  /// İki kişilik (rakipli) tür mü: çevrimiçi masa ve bilgisayara karşı oyun.
  int get players => 1;

  List<GameStat> get stats => const [
        GameStat('rounds_won', 'Kazanılan bölüm', 'Levels won', scale: 10),
        GameStat('words_found', 'Bulunan kelime', 'Words found', scale: 200),
      ];

  List<MissionTemplate> get missions => const [
        MissionTemplate('win', 'rounds_won', [3, 10, 25]),
        MissionTemplate('words', 'words_found', [30, 100, 250]),
      ];
}

/// Türü verilen dil ve zorlukta kur: birkaç tohum dener, olmazsa kolaylaştırır.
WPuzzle realize(WordKind k, String lang, int d, int seed) {
  final lx = Lexicon.of(lang);
  for (var dd = d; dd >= 1; dd = dd > 3 ? dd - 2 : dd - 1) {
    for (var a = 0; a < 24; a++) {
      WPuzzle? p;
      try {
        p = k.make(lx, dd, SeededRandom(mixSeed([seed, a, dd, 7717])));
      } catch (_) {
        p = null;
      }
      if (p != null && k.check(p, lx)) return p;
    }
  }
  throw StateError('kelime bölümü kurulamadı: ${k.id} $lang $d');
}

/// Kelime ailesi kuralları.
class WordRules extends GameRules<WLevel> {
  @override
  final String gameId;
  final WordKind Function(int d) kindFor;
  final int levels;
  final int Function(int d)? diffMap;

  /// Sonraki bölümlerin kurulacağı içerik dili (oyun ekranı günceller).
  String lang;

  WordRules({required this.gameId, required this.kindFor, this.levels = 100000, this.diffMap, String? lang})
      : lang = lang ?? _deviceWordLang();

  int mapDifficulty(int d) => (diffMap?.call(d) ?? d).clamp(1, 10);
  WordKind kindForLevel(int d) => kindFor(mapDifficulty(d));

  @override
  int get levelCount => levels;

  /// Rakipli türlerde 2: merkez "Bilgisayara karşı" ve "Çevrimiçi masa" sunar.
  @override
  int get localPlayers => kindFor(5).players;

  @override
  List<String> get optionalMechanics => const [];

  @override
  List<GameModeId> get modes => const [GameModeId.campaign, GameModeId.daily, GameModeId.weekly, GameModeId.challenge];

  @override
  List<GameStat> get gameStats => kindFor(5).stats;

  @override
  List<MissionTemplate> get missionTemplates => kindFor(5).missions;

  @override
  WLevel generate(LevelSpec spec) {
    final d = mapDifficulty(spec.difficulty);
    final k = kindFor(d);
    final l = wordLangFor(lang, k.contentLangs);
    return WLevel(k.id, spec.seed, d, l, realize(k, l, d, spec.seed));
  }

  @override
  Validation validate(WLevel puzzle, LevelSpec spec) {
    final k = kindFor(mapDifficulty(spec.difficulty));
    if (k.id != puzzle.kind) return const Validation.fail('kind mismatch');
    return k.check(puzzle.puzzle, Lexicon.of(puzzle.lang)) ? const Validation.ok() : const Validation.fail('invalid');
  }
}

String _deviceWordLang() {
  try {
    final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    // Bütün içerik dilleri: tür kendi dillerinde yoksa generate() en yakın dile düşer.
    return wordLangFor(code, kAllWordLangs);
  } catch (_) {
    return 'en';
  }
}

WordRules wordRules(String gameId, WordKind kind, {int Function(int d)? diffMap}) =>
    WordRules(gameId: gameId, kindFor: (_) => kind, diffMap: diffMap);

/// Çevrimiçi kelime maçı (iki koltuk): rakip hamlelerinin günlüğü.
///
/// Hamleler türün kendi kodladığı kısa metinlerdir. "L:<dil>" hamlesi kelime
/// dilini taşır: 0. koltuk belirler, diğer koltuk aynı dilde oynar. Rakip
/// bağlantıyı koparırsa ([oppGone]) türler bilgisayar rakibine geçer.
class WordNet {
  final MatchLink link;
  final int me;
  final int opp;
  final List<String> mine = [];
  final List<String> theirs = [];
  String? lang;
  final List<VoidCallback> _listeners = [];
  StreamSubscription<(int, String)>? _sub;

  WordNet(this.link) : me = link.mySeat, opp = link.mySeat == 0 ? 1 : 0;

  /// Maçta gerçek bir rakip varsa ağ bağlantısı; bot rakipte null (çevrimdışı gibi oynanır).
  static WordNet? of(PlayContext ctx) {
    final m = ctx.match;
    if (m == null) return null;
    final opp = m.mySeat == 0 ? 1 : 0;
    if (ctx.role(opp) != SeatRole.remote) return null;
    return WordNet(m).._start();
  }

  void _take(int seat, String mv) {
    if (mv.startsWith('L:')) {
      if (seat == 0) lang = mv.substring(2);
      return;
    }
    if (seat == me) {
      mine.add(mv);
    } else if (seat == opp) {
      theirs.add(mv);
    }
  }

  void _start() {
    for (final (s, mv) in link.history) {
      _take(s, mv);
    }
    _sub = link.moves.listen((e) {
      if (e.$1 == me) return;
      _take(e.$1, e.$2);
      for (final l in List.of(_listeners)) {
        l();
      }
    });
  }

  /// Rakip bağlantıyı kopardı mı (artık bilgisayar oynar).
  bool get oppGone => link.dropped.contains(opp);

  /// Hamle gönder (kendi günlüğüne de yazılır).
  void send(String mv) {
    if (!mv.startsWith('L:')) mine.add(mv);
    unawaited(link.send(mv).catchError((Object _) {}));
  }

  /// Bu türde daha önce gönderilmiş dil hamlesi var mı.
  bool get langSent => link.history.any((e) => e.$1 == me && e.$2.startsWith('L:'));

  void listen(VoidCallback f) => _listeners.add(f);
  void unlisten(VoidCallback f) => _listeners.remove(f);

  /// Maç sonucu: kazanan koltuk (-1 berabere).
  void finish(int winner) => unawaited(link.finish(winner, iWon: winner == me).catchError((Object _) {}));

  void dispose() {
    _sub?.cancel();
    _listeners.clear();
  }
}

/// Oyun ekranına verilen her şey.
class WordPlay {
  final PlayContext ctx;
  final WordRules rules;
  final WPuzzle puzzle;
  final Lexicon lx;
  final int d;
  final int seed;

  /// Kayıtlı yarım kalmış oyun (dil değişince boş).
  final Map<String, Object?> resume;

  /// Kelime dilini değiştir (bölüm o dilde yeniden kurulur).
  final void Function(String lang) switchLang;

  /// Seçilebilecek içerik dilleri.
  final List<String> langs;

  /// Çevrimiçi maçta rakip bağlantısı; çevrimdışında ya da bot rakipte null.
  final WordNet? net;

  const WordPlay({
    required this.ctx,
    required this.rules,
    required this.puzzle,
    required this.lx,
    required this.d,
    required this.seed,
    required this.resume,
    required this.switchLang,
    required this.langs,
    this.net,
  });

  String get lang => ctx.lang;
  String get wl => lx.lang;

  /// Durumu kaydet (dil bilgisiyle).
  void save(Map<String, Object?> state) => ctx.saveResume({...state, 'wl': lx.lang});

  void win({int score = 0, int stars = 3, int seconds = 0, int moves = 0, int hints = 0, Map<String, int> stats = const {}}) {
    ctx.finish(RoundResult(
      won: true,
      score: score,
      stars: stars.clamp(1, 3),
      seconds: seconds,
      moves: moves,
      hintsUsed: hints,
      gameStats: {'rounds_won': 1, ...stats},
    ));
  }

  void lose({int score = 0, int seconds = 0, int moves = 0, int hints = 0, Map<String, int> stats = const {}, String? headline}) {
    ctx.finish(RoundResult(won: false, score: score, seconds: seconds, moves: moves, hintsUsed: hints, gameStats: stats, headline: headline));
  }
}

const _prefKey = 'kelime_dili';

/// Kelime oyunlarının ortak sahnesi: içerik dilini seçer, gerekirse bölümü
/// o dilde yeniden kurar ve türün ekranını gösterir.
class WordStage extends StatefulWidget {
  final PlayContext ctx;
  final WordRules rules;
  const WordStage({super.key, required this.ctx, required this.rules});

  @override
  State<WordStage> createState() => _WordStageState();
}

class _WordStageState extends State<WordStage> {
  late WLevel lv;
  late WordKind kind;
  late String wl;
  WPuzzle? puzzle;
  Map<String, Object?> resume = const {};
  int _gen = 0;
  WordNet? net;

  /// Çevrimiçi maçta 0. koltuğun kelime dili bekleniyor.
  bool _waitLang = false;

  @override
  void initState() {
    super.initState();
    registerWordLicenses();
    lv = widget.ctx.generated.puzzle as WLevel;
    kind = widget.rules.kindForLevel(widget.ctx.spec.difficulty);
    net = kind.players >= 2 ? WordNet.of(widget.ctx) : null;
    final n = net;
    if (n != null) {
      // Çevrimiçi: kelime dilini 0. koltuk belirler, iki taraf aynı harflerle oynar.
      if (n.me == 0) {
        _apply(wordLangFor(widget.ctx.lang, kind.contentLangs), keepResume: false);
        if (!n.langSent) n.send('L:$wl');
      } else if (n.lang != null) {
        _apply(n.lang!, keepResume: false);
      } else {
        wl = lv.lang;
        puzzle = lv.puzzle;
        _waitLang = true;
        n.listen(_onNet);
      }
      return;
    }
    final saved = widget.ctx.resume['wl'];
    wl = saved is String ? saved : lv.lang;
    resume = saved is String ? widget.ctx.resume : const {};
    if (saved is! String) {
      // İlk açılış: kayıtlı tercih ya da arayüz dili.
      wl = wordLangFor(widget.ctx.lang, kind.contentLangs);
      _loadPref();
    }
    _apply(wl, keepResume: true);
  }

  void _onNet() {
    final n = net;
    if (n == null || !_waitLang || !mounted) return;
    if (n.lang != null || n.oppGone) {
      setState(() {
        _waitLang = false;
        _apply(n.lang ?? lv.lang, keepResume: false);
      });
    }
  }

  @override
  void dispose() {
    net?.dispose();
    super.dispose();
  }

  Future<void> _loadPref() async {
    try {
      final p = await SharedPreferences.getInstance();
      final v = p.getString(_prefKey);
      if (v != null && v != wl && mounted && (kind.contentLangs ?? kWordLangs).contains(v)) {
        setState(() => _apply(v, keepResume: false));
      }
    } catch (_) {}
  }

  void _apply(String l, {required bool keepResume}) {
    final allowed = kind.contentLangs ?? kWordLangs;
    wl = allowed.contains(l) ? l : wordLangFor(l, allowed);
    widget.rules.lang = wl;
    puzzle = wl == lv.lang ? lv.puzzle : realize(kind, wl, lv.d, lv.seed);
    if (!keepResume) resume = const {};
    _gen++;
  }

  Future<void> _switch(String l) async {
    if (l == wl || net != null) return;
    setState(() => _apply(l, keepResume: false));
    widget.ctx.saveResume({'wl': wl});
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_prefKey, wl);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_waitLang) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(Strings.pick(_kWait, widget.ctx.lang), style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
      );
    }
    final play = WordPlay(
      ctx: widget.ctx,
      rules: widget.rules,
      puzzle: puzzle!,
      lx: Lexicon.of(wl),
      d: lv.d,
      seed: lv.seed,
      resume: resume,
      switchLang: _switch,
      langs: net != null ? [wl] : (kind.contentLangs ?? kWordLangs),
      net: net,
    );
    return KeyedSubtree(key: ValueKey('$wl-$_gen'), child: kind.build(play));
  }
}

const _kWait = ['Rakip bekleniyor…', 'Waiting for rival…', 'Warte auf Gegner…', 'Esperando al rival…', 'En attente de l’adversaire…', 'بانتظار الخصم…', 'در انتظار حریف…', 'ממתינים ליריב…', 'حریف کا انتظار…', 'Ждём соперника…', 'Чекаємо суперника…', 'Czekam na rywala…', 'Čekáme na soupeře…', 'Se așteaptă adversarul…', 'Várakozás az ellenfélre…', 'Αναμονή αντιπάλου…', 'In attesa dell’avversario…', 'Aguardando o rival…', 'Wachten op tegenstander…', 'Väntar på motståndaren…', 'Venter på modstanderen…', 'Venter på motstanderen…', 'Odotetaan vastustajaa…', '相手を待っています…', '상대를 기다리는 중…', '等待对手…', 'प्रतिद्वंद्वी की प्रतीक्षा…', 'প্রতিদ্বন্দ্বীর অপেক্ষায়…', 'Menunggu lawan…', 'Menunggu lawan…', 'รอคู่แข่ง…', 'Đang chờ đối thủ…', 'Hinihintay ang kalaban…'];

bool _licensed = false;

/// Kelime listelerinin lisans bildirimi (uygulamanın lisanslar sayfasında görünür).
void registerWordLicenses() {
  if (_licensed) return;
  _licensed = true;
  LicenseRegistry.addLicense(() => Stream.value(const LicenseEntryWithLineBreaks(
        ['kelime-motoru (word lists)'],
        'Word lists are derived from FrequencyWords by Hermit Dave '
        '(https://github.com/hermitdave/FrequencyWords), built from OpenSubtitles 2018, '
        'licensed under CC BY-SA 4.0 (https://creativecommons.org/licenses/by-sa/4.0/). '
        'The derived lists are shared under the same license.\n\n'
        'Inappropriate-word filtering uses the List of Dirty, Naughty, Obscene, and Otherwise Bad Words '
        '(https://github.com/LDNOOBW), CC BY 4.0. Dictionaries from wooorm/dictionaries were used only '
        'as a build-time filter and are not distributed.\n\n'
        'Filipino and Urdu lists and Japanese word frequencies come from wordfreq by Robyn Speer '
        '(https://github.com/rspeer/wordfreq), data CC BY-SA 4.0. Japanese readings come from JMdict '
        '(Electronic Dictionary Research and Development Group, https://www.edrdg.org/), CC BY-SA 4.0. '
        'The Finnish list is filtered with the Kotus word list (Institute for the Languages of Finland), '
        'CC BY 4.0. LibreOffice hunspell dictionaries (ar, fa, he, id) were used only as a build-time '
        'filter and are not distributed.\n\n'
        'Clues, proverb selections, categories and word pairs were written by the studio.',
      )));
}
