import 'package:studio_core/core/rng.dart';

import 'data/words_cs.dart';
import 'data/words_da.dart';
import 'data/words_de.dart';
import 'data/words_el.dart';
import 'data/words_en.dart';
import 'data/words_es.dart';
import 'data/words_fr.dart';
import 'data/words_hu.dart';
import 'data/words_it.dart';
import 'data/words_nb.dart';
import 'data/words_nl.dart';
import 'data/words_pl.dart';
import 'data/words_pt.dart';
import 'data/words_ro.dart';
import 'data/words_ru.dart';
import 'data/words_sv.dart';
import 'data/words_tr.dart';
import 'data/words_uk.dart';
import 'data/words_fi.dart';
import 'data/words_id.dart';
import 'data/words_ms.dart';
import 'data/words_fil.dart';
import 'data/words_ar.dart';
import 'data/words_fa.dart';
import 'data/words_he.dart';
import 'data/words_ur.dart';
import 'data/words_ja.dart';
import 'data/words_bn.dart';
import 'data/words_hi.dart';
import 'data/words_ko.dart';
import 'data/words_th.dart';
import 'data/words_vi.dart';
import 'data/words_zh.dart';
import 'data/accept_tr.dart';
import 'data/accept_en.dart';
import 'data/accept_de.dart';
import 'data/accept_es.dart';
import 'data/accept_fr.dart';
import 'data/accept_it.dart';
import 'data/accept_pt.dart';
import 'data/accept_nl.dart';
import 'data/accept_sv.dart';
import 'data/accept_da.dart';
import 'data/accept_nb.dart';
import 'data/accept_pl.dart';
import 'data/accept_cs.dart';
import 'data/accept_ro.dart';
import 'data/accept_hu.dart';
import 'data/accept_ru.dart';
import 'data/accept_uk.dart';
import 'data/accept_el.dart';
import 'data/accept_fi.dart';
import 'data/accept_id.dart';
import 'data/accept_ms.dart';
import 'data/accept_fil.dart';
import 'data/accept_ar.dart';
import 'data/accept_fa.dart';
import 'data/accept_he.dart';
import 'data/accept_ur.dart';
import 'data/accept_ja.dart';
import 'data/blocklist.dart';
import 'tiles.dart';

/// Harf alfabesiyle yazılan diller: harf taşlı, klavyeli ve ızgaralı bütün
/// türler harf harf oynanır. Japoncada harfler katakanadır (bulmaca geleneği:
/// küçük kana büyük yazılır).
const kLetterLangs = [
  'tr', 'en', 'de', 'es', 'fr', 'it', 'pt', 'nl', 'sv', 'da', 'nb', 'pl', 'cs', 'ro', 'hu', 'ru', 'uk', 'el',
  'fi', 'id', 'ms', 'fil', 'ar', 'fa', 'he', 'ur', 'ja',
];

/// Taş (hece/küme) yazılı diller: tek harf taşı anlamlı değildir, kelimeler
/// taş dizisi olarak oynanır. Çince: her karakter bir taş; Korece: her hece bir
/// taş (klavyeli türlerde jamo); Vietnamca: her hece (ses tonuyla) bir taş;
/// Hintçe ve Bengalce: akşara (bitişik ünsüzlerle); Tayca: hece. Bu dillerde
/// klavye yerine bölümün taşlarından (ve şaşırtmacalardan) oluşan taş havuzu
/// kullanılır.
const kTileLangs = ['vi', 'ko', 'zh', 'hi', 'bn', 'th'];

/// Kelime listesi olan diller: 33 dilin hepsi.
const kWordLangs = [...kLetterLangs, ...kTileLangs];

/// Eski ad (geriye uyum): artık bütün dillerin kelime listesi var.
const kQuizOnlyLangs = <String>[];

/// İçerik dili olan bütün diller (33).
const kAllWordLangs = kWordLangs;

/// Dilin yerel adı (kelime dili seçicisi için).
const kWordLangNames = {
  'tr': 'Türkçe', 'en': 'English', 'de': 'Deutsch', 'es': 'Español', 'fr': 'Français', 'it': 'Italiano',
  'pt': 'Português', 'nl': 'Nederlands', 'sv': 'Svenska', 'da': 'Dansk', 'nb': 'Norsk', 'pl': 'Polski',
  'cs': 'Čeština', 'ro': 'Română', 'hu': 'Magyar', 'ru': 'Русский', 'uk': 'Українська', 'el': 'Ελληνικά',
  'fi': 'Suomi', 'id': 'Bahasa Indonesia', 'ms': 'Bahasa Melayu', 'fil': 'Filipino', 'ar': 'العربية',
  'fa': 'فارسی', 'he': 'עברית', 'ur': 'اردو', 'ja': '日本語', 'vi': 'Tiếng Việt', 'ko': '한국어',
  'zh': '中文', 'hi': 'हिन्दी', 'bn': 'বাংলা', 'th': 'ไทย',
};

const Map<String, String> _raw = {
  'tr': wordsTr, 'en': wordsEn, 'de': wordsDe, 'es': wordsEs, 'fr': wordsFr, 'it': wordsIt,
  'pt': wordsPt, 'nl': wordsNl, 'sv': wordsSv, 'da': wordsDa, 'nb': wordsNb, 'pl': wordsPl,
  'cs': wordsCs, 'ro': wordsRo, 'hu': wordsHu, 'ru': wordsRu, 'uk': wordsUk, 'el': wordsEl,
  'fi': wordsFi, 'id': wordsId, 'ms': wordsMs, 'fil': wordsFil, 'ar': wordsAr, 'fa': wordsFa,
  'he': wordsHe, 'ur': wordsUr, 'ja': wordsJa,
  'vi': wordsVi, 'ko': wordsKo, 'zh': wordsZh, 'hi': wordsHi, 'bn': wordsBn, 'th': wordsTh,
};

const Map<String, String> _accept = {
  'tr': acceptTr, 'en': acceptEn, 'de': acceptDe, 'es': acceptEs, 'fr': acceptFr, 'it': acceptIt, 'pt': acceptPt, 'nl': acceptNl, 'sv': acceptSv, 'da': acceptDa, 'nb': acceptNb, 'pl': acceptPl, 'cs': acceptCs, 'ro': acceptRo, 'hu': acceptHu, 'ru': acceptRu, 'uk': acceptUk, 'el': acceptEl, 'fi': acceptFi, 'id': acceptId, 'ms': acceptMs, 'fil': acceptFil, 'ar': acceptAr, 'fa': acceptFa, 'he': acceptHe, 'ur': acceptUr, 'ja': acceptJa,
};

/// Cevap olarak seçilmeyen ama girildiğinde kabul edilen kelimeler (kısaltma,
/// argo yazım): Wordle benzeri oyunlarda gizli kelime "gonna" olmasın.
const Map<String, String> _noAnswer = {
  'en': 'gonna wanna gotta gimme lemme dunno kinda sorta outta haven hasn wasn isn aren doesn didn couldn shouldn wouldn ain yeah yep nope okay whoa huh hmm ooh aah ohh',
};

Set<String>? _blockCache;
String? _blockLang;

/// Uygunsuz kelime mi (tam eşleşme ya da kök öneki). [natural]: kelimenin doğal
/// yazımı (taş dillerinde taşlar birleştirilmiş; Vietnamcada heceler '_' ile).
bool isBlockedWord(String natural, String lang) {
  if (_blockLang != lang) {
    _blockLang = lang;
    _blockCache = {for (final w in (kBlockedWords[lang] ?? '').split(' ')) if (w.isNotEmpty) foldWord(w, lang)};
  }
  if (_blockCache!.contains(natural)) return true;
  for (final st in kBlockedStems[lang] ?? const <String>[]) {
    if (natural.startsWith(st)) return true;
  }
  return false;
}

/// Taş dillerinde içerikte geçip kelime listesinde olmayan taşlar.
const Map<String, String> _extraTiles = {'vi': tilesVi, 'hi': tilesHi, 'bn': tilesBn, 'th': tilesTh};

/// Eski ya da bölgesel dil kodları.
const Map<String, String> _langAlias = {'no': 'nb', 'tl': 'fil', 'iw': 'he', 'in': 'id', 'zsm': 'ms'};

/// Arayüz dilinden içerik dilini seç.
String wordLangFor(String uiLang, [List<String>? allowed]) {
  final list = allowed ?? kWordLangs;
  final code = _langAlias[uiLang] ?? uiLang;
  if (list.contains(code)) return code;
  return list.contains('en') ? 'en' : list.first;
}

/// Klavye oyunlarında ayrı harf sayılmayan işaretleri sadeleştir.
/// Dilin kendi harfleri (ç, ğ, ñ, å, ł ...) korunur.
const Map<String, Map<String, String>> _fold = {
  'en': {},
  'tr': {'â': 'a', 'î': 'i', 'û': 'u'},
  'de': {},
  'es': {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u'},
  'fr': {'à': 'a', 'â': 'a', 'ç': 'c', 'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', 'î': 'i', 'ï': 'i', 'ô': 'o', 'û': 'u', 'ù': 'u', 'ü': 'u', 'ÿ': 'y'},
  'it': {'à': 'a', 'è': 'e', 'é': 'e', 'ì': 'i', 'ò': 'o', 'ù': 'u'},
  'pt': {'á': 'a', 'â': 'a', 'ã': 'a', 'à': 'a', 'ç': 'c', 'é': 'e', 'ê': 'e', 'í': 'i', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ú': 'u'},
  'nl': {},
  'sv': {},
  'da': {},
  'nb': {},
  'pl': {},
  'cs': {},
  'ro': {},
  'hu': {},
  'ru': {'ё': 'е'},
  'uk': {},
  'el': {'ά': 'α', 'έ': 'ε', 'ή': 'η', 'ί': 'ι', 'ό': 'ο', 'ύ': 'υ', 'ώ': 'ω', 'ϊ': 'ι', 'ϋ': 'υ', 'ΐ': 'ι', 'ΰ': 'υ', 'ς': 'σ'},
  'fi': {'å': 'a', 'é': 'e'},
  'id': {'é': 'e'},
  'ms': {'é': 'e'},
  'fil': {'ñ': 'n', 'é': 'e', 'á': 'a', 'í': 'i', 'ó': 'o', 'ú': 'u'},
  'ar': {..._harakat, 'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ٱ': 'ا'},
  'fa': {..._harakat, 'ي': 'ی', 'ى': 'ی', 'ك': 'ک', 'ة': 'ه', 'أ': 'ا', 'إ': 'ا', 'ؤ': 'و', 'ۀ': 'ه'},
  'ur': {..._harakat, 'ي': 'ی', 'ى': 'ی', 'ك': 'ک', 'ه': 'ہ', 'ۂ': 'ہ', 'ۓ': 'ے', 'أ': 'ا', 'إ': 'ا', 'ة': 'ہ'},
  'he': {..._niqqud, 'ך': 'כ', 'ם': 'מ', 'ן': 'נ', 'ף': 'פ', 'ץ': 'צ'},
  'ja': {'ァ': 'ア', 'ィ': 'イ', 'ゥ': 'ウ', 'ェ': 'エ', 'ォ': 'オ', 'ッ': 'ツ', 'ャ': 'ヤ', 'ュ': 'ユ', 'ョ': 'ヨ', 'ヮ': 'ワ', 'ヵ': 'カ', 'ヶ': 'ケ'},
};

/// Arapça harekeler ve tatvil (harf sayılmaz).
const Map<String, String> _harakat = {
  '\u064B': '', '\u064C': '', '\u064D': '', '\u064E': '', '\u064F': '', '\u0650': '', '\u0651': '', '\u0652': '',
  '\u0670': '', '\u0640': '',
};

/// İbranice nikud işaretleri (harf sayılmaz).
const Map<String, String> _niqqud = {
  '\u05B0': '', '\u05B1': '', '\u05B2': '', '\u05B3': '', '\u05B4': '', '\u05B5': '', '\u05B6': '', '\u05B7': '',
  '\u05B8': '', '\u05B9': '', '\u05BA': '', '\u05BB': '', '\u05BC': '', '\u05BD': '', '\u05BF': '', '\u05C1': '',
  '\u05C2': '', '\u05C7': '',
};

/// İbranice sonek harfler: kelime sonunda bu biçimle yazılır (yalnızca gösterim).
const Map<String, String> _heFinal = {'כ': 'ך', 'מ': 'ם', 'נ': 'ן', 'פ': 'ף', 'צ': 'ץ'};

String foldWord(String w, String lang) {
  final m = _fold[lang] ?? const {};
  if (m.isEmpty) return w;
  final b = StringBuffer();
  for (final ch in w.split('')) {
    b.write(m[ch] ?? ch);
  }
  return b.toString();
}

/// Bir harfi dilin kurallarıyla büyük harfe çevir.
String upLetter(String ch, String lang) {
  if (lang == 'tr') {
    if (ch == 'i') return 'İ';
    if (ch == 'ı') return 'I';
  }
  if (ch == 'ß') return 'ẞ';
  return ch.toUpperCase();
}

/// Kelimeyi büyük harfle yaz (harf sayısı korunur). İbranicede son harf
/// sonek biçimine çevrilir.
String upWord(String w, String lang) {
  final s = [for (final ch in w.split('')) upLetter(ch, lang)].join();
  if (lang == 'he' && s.length > 1) {
    final f = _heFinal[s[s.length - 1]];
    if (f != null) return s.substring(0, s.length - 1) + f;
  }
  return s;
}

/// Dilin kelime listesi: sıklık sırasında, küçük harf ve sadeleştirilmiş.
///
/// Taş yazılı dillerde ([kTileLangs]) her taş tek bir UTF-16 birimiyle
/// saklanır: Çince karakter ve Hangıl hecesi kendisiyle, Vietnamca hece,
/// akşara ve Tay hecesi Özel Kullanım Alanı'ndaki (U+E000…) bir kodla. Böylece
/// türlerin harf işlemleri (`split('')`, `length`, `w[i]`) taşlar üzerinde
/// aynen çalışır; ekrana [up] ve [upCh] taşın yazısını verir.
///
/// Korecede klavyeli türler (`WordKind.keyed`) için ayrıca jamo sözlüğü vardır
/// ([Lexicon.of] `keyed: true`): kelimeler 두벌식 klavye jamolarıdır, ekranda
/// hecelere birleştirilir.
class Lexicon {
  final String lang;

  /// Bütün kelimeler (en sık önce).
  final List<String> words;
  final Set<String> all;
  final Map<int, List<String>> _byLen;

  /// Dilin harfleri ya da taşları (sıklık sırasıyla).
  final List<String> letters;

  /// Harf sıklıkları (aynı sırayla).
  final List<int> letterWeights;

  /// Taş kodu → taşın yazısı (yalnızca kodlanmış taş dillerinde).
  final Map<String, String> _tileText;

  /// Taşın yazısı → taş kodu.
  final Map<String, String> _tileCode;

  /// Doğal yazım → kelime (taş dillerinde dışarıdan gelen kelimeyi tanımak için).
  final Map<String, String> _natural;

  /// Bu sözlük taş sözlüğü mü (klavye yerine taş havuzu).
  final bool tiled;

  /// Korece jamo (klavye) sözlüğü mü.
  final bool jamo;

  Lexicon._(this.lang, this.words, this.all, this._byLen, this.letters, this.letterWeights,
      {this.tiled = false, this.jamo = false, Map<String, String>? tileText, Map<String, String>? tileCode, Map<String, String>? natural, Set<String>? extra})
      : _extra = extra ?? const {},
        _tileText = tileText ?? const {},
        _tileCode = tileCode ?? const {},
        _natural = natural ?? const {};

  static final Map<String, Lexicon> _cache = {};

  /// Dilin sözlüğü. [keyed]: klavyeli türler için (Korecede jamo sözlüğü; öbür
  /// dillerde aynı sözlük).
  static Lexicon of(String lang, {bool keyed = false}) {
    final l = _raw.containsKey(lang) ? lang : 'en';
    if (keyed && l == 'ko') return _cache['ko#jamo'] ??= _loadJamo(of('ko'));
    return _cache[l] ??= kTileLangs.contains(l) ? _loadTiles(l) : _load(l);
  }

  /// Dilin kelime listesi var mı.
  static bool hasList(String lang) => _raw.containsKey(lang);

  static Lexicon _load(String lang) {
    final seen = <String>{};
    final list = <String>[];
    final extra = <String>{};
    final noAns = (_noAnswer[lang] ?? '').split(' ').toSet();
    for (final w0 in (_raw[lang] ?? '').split(' ')) {
      if (w0.isEmpty) continue;
      final w = foldWord(w0, lang);
      if (w.length < 3 || isBlockedWord(w, lang)) continue;
      if (noAns.contains(w)) {
        extra.add(w);
        continue;
      }
      if (!seen.add(w)) continue;
      list.add(w);
    }
    for (final w0 in (_accept[lang] ?? '').split(' ')) {
      if (w0.isEmpty) continue;
      final w = foldWord(w0, lang);
      if (w.length < 3 || seen.contains(w) || isBlockedWord(w, lang)) continue;
      extra.add(w);
    }
    return _finish(lang, list, seen, extra: extra);
  }

  static Lexicon _finish(String lang, List<String> list, Set<String> seen,
      {bool tiled = false, bool jamo = false, Map<String, String>? tileText, Map<String, String>? tileCode, Map<String, String>? natural, Set<String>? extra}) {
    final byLen = <int, List<String>>{};
    final counts = <String, int>{};
    for (final w in list) {
      byLen.putIfAbsent(w.length, () => <String>[]).add(w);
      for (final ch in w.split('')) {
        counts[ch] = (counts[ch] ?? 0) + 1;
      }
    }
    final letters = counts.keys.toList()..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    return Lexicon._(lang, list, seen, byLen, letters, [for (final l in letters) counts[l]!],
        tiled: tiled, jamo: jamo, tileText: tileText, tileCode: tileCode, natural: natural, extra: extra);
  }

  /// Taş dilleri: zh ve ko'da her karakter kendisi, vi/hi/bn/th'de taşlar '+' ile ayrılmış.
  static Lexicon _loadTiles(String lang) {
    final coded = lang != 'zh' && lang != 'ko';
    final text = <String, String>{}, code = <String, String>{}, natural = <String, String>{};
    final seen = <String>{};
    final list = <String>[];
    var next = 0xE000;
    for (final w0 in (_raw[lang] ?? '').split(' ')) {
      if (w0.isEmpty) continue;
      if (isBlockedWord(lang == 'vi' ? w0.replaceAll('+', '_') : w0.replaceAll('+', ''), lang)) continue;
      String w;
      if (coded) {
        final b = StringBuffer();
        for (final t in w0.split('+')) {
          var c = code[t];
          if (c == null) {
            if (next > 0xF8FF) break;
            c = String.fromCharCode(next++);
            code[t] = c;
            text[c] = t;
          }
          b.write(c);
        }
        w = b.toString();
      } else {
        w = w0;
      }
      if (w.length < 2 || !seen.add(w)) continue;
      list.add(w);
      natural[_naturalKey(lang, coded ? w0.split('+') : w0.split(''))] = w;
    }
    // İçerikte geçen ek taşlar: kodları kelimelerden sonra, sabit sırayla.
    for (final t in (_extraTiles[lang] ?? '').split(' ')) {
      if (t.isEmpty || code.containsKey(t) || next > 0xF8FF) continue;
      final c = String.fromCharCode(next++);
      code[t] = c;
      text[c] = t;
    }
    return _finish(lang, list, seen, tiled: true, tileText: text, tileCode: code, natural: natural);
  }

  static String _naturalKey(String lang, List<String> tiles) => lang == 'vi' ? tiles.join(' ') : tiles.join();

  static Lexicon _loadJamo(Lexicon syl) {
    final seen = <String>{};
    final list = <String>[];
    for (final w in syl.words) {
      final j = hangulToJamo(w);
      if (j.length < 3 || !seen.add(j)) continue;
      list.add(j);
    }
    return _finish('ko', list, seen, jamo: true);
  }

  /// Kelime geçerli mi: ana liste ya da yalnızca kabul listesi.
  bool has(String w) => all.contains(w) || _extra.contains(w);

  /// [len] harfli (taş dillerinde taşlı) kelimeler (sıklık sırasıyla).
  List<String> ofLength(int len) => _byLen[len] ?? const <String>[];

  /// En kısa ve en uzun kelime boyu.
  int get minLen => tiled ? 2 : 3;
  int get maxLen => _byLen.keys.fold<int>(0, (a, b) => a > b ? a : b);

  /// Harf sayısı olarak düşünülmüş boyu bu sözlüğün taş boyuna çevir. Harf
  /// dillerinde aynen döner. Taş dillerinde: Hintçe/Bengalce akşaralar kısa
  /// olduğu için 2–5, öbürlerinde 2–4 taş.
  int fit(int n) {
    if (!tiled) return n;
    if (lang == 'hi' || lang == 'bn') return n <= 4 ? 2 : (n <= 6 ? 3 : (n <= 8 ? 4 : 5));
    return n <= 5 ? 2 : (n <= 7 ? 3 : 4);
  }

  /// Zorluğa göre ortak kelime havuzu: kolayda en sık kelimeler.
  /// [d] 1..10; havuz büyüklüğü sıklık sırasından alınır.
  List<String> pool(int len, int d, {int minSize = 40}) {
    final all = ofLength(len);
    if (all.isEmpty) return all;
    final frac = 0.18 + 0.08 * (d - 1);
    var n = (all.length * frac).round();
    if (n < minSize) n = minSize;
    if (n > all.length) n = all.length;
    return all.sublist(0, n);
  }

  /// Uzunluk aralığından havuz.
  List<String> poolRange(int minLen, int maxLen, int d) => [for (var l = minLen; l <= maxLen; l++) ...pool(l, d)];

  /// Harf boyu aralığını bu sözlüğün boyuna çevirip havuz ver.
  List<String> poolFit(int minLen, int maxLen, int d) {
    if (!tiled) return poolRange(minLen, maxLen, d);
    return poolRange(fit(minLen), fit(maxLen), d);
  }

  /// Ağırlıklı rastgele harf.
  String randomLetter(SeededRandom r) => letters[r.weighted(letterWeights)];

  /// Kelimenin ekrandaki yazısı (büyük harfle; taşlar yazılarıyla; Korece jamo hecelere birleşir).
  String up(String w) {
    if (jamo) return jamoToHangul(w);
    if (!tiled) return upWord(w, lang);
    if (_tileText.isEmpty) return w;
    // Kodlu taşlar yazılarına çevrilir; kodsuz karakterler (doğal yazımla
    // gelen atasözü sözcükleri, boşluklar) olduğu gibi kalır.
    final b = StringBuffer();
    var prevTile = false;
    for (final ch in w.split('')) {
      final t = _tileText[ch];
      if (t != null) {
        if (prevTile && lang == 'vi') b.write(' ');
        b.write(t);
        prevTile = true;
      } else {
        b.write(ch);
        prevTile = false;
      }
    }
    return lang == 'vi' ? b.toString().toUpperCase() : b.toString();
  }

  /// Tek harfin/taşın ekrandaki yazısı.
  String upCh(String ch) {
    if (jamo || (tiled && _tileText.isEmpty)) return ch;
    if (tiled) {
      final t = _tileText[ch] ?? ch;
      return lang == 'vi' ? t.toUpperCase() : t;
    }
    return upLetter(ch, lang);
  }

  /// Taşın küçük harfli yazısı (Vietnamcada ses tonu karşılaştırması için).
  String tileText(String ch) => _tileText[ch] ?? ch;

  /// Doğal yazımla verilmiş bir kelimeyi bu sözlüğün biçimine çevir (ipucu
  /// yanıtları, atasözü sözcükleri). Taşlara bölünemezse null.
  String? encode(String natural) {
    if (jamo) return hangulToJamo(natural);
    if (!tiled) return natural;
    final s = natural.trim().toLowerCase();
    final known = _natural[s];
    if (known != null) return known;
    if (lang == 'zh' || lang == 'ko') {
      return s.isEmpty || s.contains(' ') ? null : s;
    }
    List<String>? parts;
    if (lang == 'vi') {
      parts = s.split(' ').where((x) => x.isNotEmpty).toList();
    } else if (lang == 'hi' || lang == 'bn') {
      parts = aksaras(s, lang);
    } else {
      parts = _segmentKnown(s);
    }
    if (parts == null || parts.isEmpty) return null;
    final b = StringBuffer();
    for (final p in parts) {
      final c = _tileCode[p];
      if (c == null) return null;
      b.write(c);
    }
    return b.toString();
  }

  /// Bilinen taşlarla en uzun eşleşme (geri dönüşlü) — Tayca.
  List<String>? _segmentKnown(String s) {
    final memo = <int, List<String>?>{};
    List<String>? go(int i) {
      if (i == s.length) return const [];
      if (memo.containsKey(i)) return memo[i];
      for (var k = s.length < i + 8 ? s.length : i + 8; k > i; k--) {
        final t = s.substring(i, k);
        if (!_tileCode.containsKey(t)) continue;
        final rest = go(k);
        if (rest != null) return memo[i] = [t, ...rest];
      }
      return memo[i] = null;
    }

    return go(0);
  }

  /// Taşın benzerlik anahtarı: Vietnamcada tonsuz hece, Korecede ilk ünsüz,
  /// Hint yazılarında ünsüz iskeleti, Taycada ton/sesli işaretsiz iskelet,
  /// Çincede (okunuş bilinmediğinde) aynı bileşen yerine sıklık komşusu.
  String tileKey(String ch) {
    final t = _tileText[ch] ?? ch;
    switch (lang) {
      case 'vi':
        return viToneless(t);
      case 'ko':
        return hangulInitial(t);
      case 'hi':
      case 'bn':
        return indicSkeleton(t, lang);
      case 'th':
        return thaiSkeleton(t);
      case 'zh':
        return zhReading(ch);
      default:
        return t;
    }
  }

  Map<String, List<String>>? _kin;

  /// Benzer taşlar (aynı [tileKey]), sıklık sırasıyla.
  List<String> kin(String ch) {
    final m = _kin ??= () {
      final out = <String, List<String>>{};
      for (final l in letters) {
        out.putIfAbsent(tileKey(l), () => <String>[]).add(l);
      }
      return out;
    }();
    return [for (final x in m[tileKey(ch)] ?? const <String>[]) if (x != ch) x];
  }

  /// Taş havuzu (klavye yerine): gereken taşlar + benzer ve sık taşlardan
  /// şaşırtmacalar, tohuma göre karışık. Harf dillerinde boş döner (klavye kullanılır).
  List<String> keyPool(Iterable<String> need, int seed, {int size = 16}) {
    if (!tiled) return const [];
    final out = <String>[];
    for (final ch in need) {
      if (!out.contains(ch)) out.add(ch);
    }
    final r = SeededRandom(seed);
    final want = out.length + (size - out.length).clamp(3, 12);
    final base = List.of(out);
    // Önce benzer taşlar (Vietnamcada aynı hecenin öbür tonları).
    for (final ch in base) {
      if (out.length >= want) break;
      final k = kin(ch);
      if (k.isEmpty) continue;
      final pick = k[r.nextInt(k.length < 6 ? k.length : 6)];
      if (!out.contains(pick)) out.add(pick);
    }
    var guard = 0;
    final top = letters.length < 300 ? letters.length : 300;
    while (out.length < want && guard++ < 400) {
      final ch = letters[r.nextInt(top)];
      if (!out.contains(ch)) out.add(ch);
    }
    r.shuffle(out);
    return out;
  }

  /// Çince karakterin okunuşu (pinyin, tonlu); bilinmiyorsa boş.
  String zhReading(String ch) => lang == 'zh' ? (_zhPinyin()[ch] ?? '') : '';

  /// Kelimenin okunuşu (yalnızca Çince; pinyin, tonlu). Yoksa null.
  String? reading(String w) {
    if (lang != 'zh') return null;
    final m = _zhWordPinyin ??= () {
      final py = wordsZhPinyin.split(' ');
      final ws = wordsZh.split(' ');
      return {for (var i = 0; i < ws.length && i < py.length; i++) ws[i]: py[i].replaceAll('-', ' ')};
    }();
    return m[w] ?? [for (final ch in w.split('')) zhReading(ch)].join(' ');
  }

  static Map<String, String>? _zhWordPinyin;
  static Map<String, String>? _zhChar;

  static Map<String, String> _zhPinyin() => _zhChar ??= () {
        final py = wordsZhPinyin.split(' ');
        final ws = wordsZh.split(' ');
        final out = <String, String>{};
        for (var i = 0; i < ws.length && i < py.length; i++) {
          final s = py[i].split('-');
          if (s.length != ws[i].length) continue;
          for (var k = 0; k < s.length; k++) {
            out.putIfAbsent(ws[i][k], () => s[k]);
          }
        }
        return out;
      }();

  /// Kelime oyun tahtası puanı: seyrek harf daha değerli (1..10).
  int letterValue(String ch) {
    final i = letters.indexOf(ch);
    if (i < 0) return 5;
    final n = letters.length;
    if (tiled) {
      // Taş dillerinde yüzlerce taş var: sık taşlar 1-2, seyrekleri 3-8.
      if (i < 40) return 1;
      if (i < 120) return 2;
      if (i < 300) return 3;
      if (i < 600) return 5;
      return 8;
    }
    if (i < n * 0.30) return 1;
    if (i < n * 0.45) return 2;
    if (i < n * 0.60) return 3;
    if (i < n * 0.72) return 4;
    if (i < n * 0.82) return 5;
    if (i < n * 0.90) return 8;
    return 10;
  }

  /// Klavye düzeni: alfabe sırasında satırlar (Korece jamoda 두벌식 düzeni).
  List<List<String>> keyboardRows() {
    if (jamo) {
      final present = letters.toSet();
      return [for (final row in kKoKeyRows) [for (final k in row) if (present.contains(k)) k]];
    }
    final alpha = alphabet();
    final per = alpha.length <= 26 ? 10 : (alpha.length <= 30 ? 11 : (alpha.length <= 48 ? 12 : 13));
    final rows = <List<String>>[];
    for (var i = 0; i < alpha.length; i += per) {
      rows.add(alpha.sublist(i, i + per > alpha.length ? alpha.length : i + per));
    }
    return rows;
  }

  /// Alfabe sırasında harfler (taş dillerinde sıklık sırası).
  List<String> alphabet() {
    if (tiled) return letters;
    final order = _alphaOrder[lang] ?? 'abcdefghijklmnopqrstuvwxyz';
    final present = letters.toSet();
    final out = <String>[for (final ch in order.split('')) if (present.contains(ch)) ch];
    for (final ch in letters) {
      if (!out.contains(ch)) out.add(ch);
    }
    return out;
  }
}

const Map<String, String> _alphaOrder = {
  'tr': 'abcçdefgğhıijklmnoöprsştuüvyz',
  'de': 'abcdefghijklmnopqrstuvwxyzäöüß',
  'es': 'abcdefghijklmnñopqrstuvwxyz',
  'sv': 'abcdefghijklmnopqrstuvwxyzåäö',
  'da': 'abcdefghijklmnopqrstuvwxyzæøå',
  'nb': 'abcdefghijklmnopqrstuvwxyzæøå',
  'pl': 'aąbcćdeęfghijklłmnńoóprsśtuwyzźż',
  'cs': 'aábcčdďeéěfghiíjklmnňoóprřsštťuúůvwxyýzž',
  'ro': 'aăâbcdefghiîjklmnopqrsștțuvwxyz',
  'hu': 'aábcdeéfghiíjklmnoóöőpqrstuúüűvwxyz',
  'ru': 'абвгдежзийклмнопрстуфхцчшщъыьэюя',
  'uk': 'абвгґдеєжзиіїйклмнопрстуфхцчшщьюя',
  'el': 'αβγδεζηθικλμνξοπρστυφχψω',
  'fi': 'abcdefghijklmnopqrstuvwxyzäö',
  'ar': 'ابتثجحخدذرزسشصضطظعغفقكلمنهويءةىؤئ',
  'fa': 'آابپتثجچحخدذرزژسشصضطظعغفقکگلمنوهیئ',
  'ur': 'آابپتٹثجچحخدڈذرڑزژسشصضطظعغفقکگلمنںوؤہھءیےئ',
  'he': 'אבגדהוזחטיכלמנסעפצקרשת',
  'ja': 'アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポヴー',
};

/// Kelimenin harf sayımları.
Map<String, int> letterCounts(String w) {
  final m = <String, int>{};
  for (final ch in w.split('')) {
    m[ch] = (m[ch] ?? 0) + 1;
  }
  return m;
}

/// [w] kelimesi [pool] harfleriyle yazılabilir mi (her harf en çok sayısı kadar).
bool canSpell(String w, Map<String, int> pool) {
  final need = <String, int>{};
  for (final ch in w.split('')) {
    final n = (need[ch] ?? 0) + 1;
    if (n > (pool[ch] ?? 0)) return false;
    need[ch] = n;
  }
  return true;
}
