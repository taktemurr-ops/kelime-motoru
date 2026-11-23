import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studio_core/app/game_api.dart';
import 'package:studio_core/core/game_rules.dart';
import 'package:studio_core/core/level_plan.dart';
import 'package:studio_core/core/missions.dart';
import 'package:studio_core/core/rng.dart';
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
    return wordLangFor(code);
  } catch (_) {
    return 'en';
  }
}

WordRules wordRules(String gameId, WordKind kind, {int Function(int d)? diffMap}) =>
    WordRules(gameId: gameId, kindFor: (_) => kind, diffMap: diffMap);

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

  @override
  void initState() {
    super.initState();
    registerWordLicenses();
    lv = widget.ctx.generated.puzzle as WLevel;
    kind = widget.rules.kindForLevel(widget.ctx.spec.difficulty);
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
    if (l == wl) return;
    setState(() => _apply(l, keepResume: false));
    widget.ctx.saveResume({'wl': wl});
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_prefKey, wl);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final play = WordPlay(
      ctx: widget.ctx,
      rules: widget.rules,
      puzzle: puzzle!,
      lx: Lexicon.of(wl),
      d: lv.d,
      seed: lv.seed,
      resume: resume,
      switchLang: _switch,
      langs: kind.contentLangs ?? kWordLangs,
    );
    return KeyedSubtree(key: ValueKey('$wl-$_gen'), child: kind.build(play));
  }
}

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
        'Clues, proverb selections, categories and word pairs were written by the studio.',
      )));
}
