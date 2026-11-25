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

/// Kelime listesi olan diller: harf taşlı, klavyeli ve ızgaralı bütün türler
/// bu dillerde oynanır. Japoncada harfler katakanadır (bulmaca geleneği:
/// küçük kana büyük yazılır).
const kWordLangs = [
  'tr', 'en', 'de', 'es', 'fr', 'it', 'pt', 'nl', 'sv', 'da', 'nb', 'pl', 'cs', 'ro', 'hu', 'ru', 'uk', 'el',
  'fi', 'id', 'ms', 'fil', 'ar', 'fa', 'he', 'ur', 'ja',
];

/// Yalnızca bütün-kelime türlerinde (atasözü, eş/zıt anlam, gruplama) içerik
/// dili olan diller. Bu yazılarda tek harf taşı anlamlı değildir: Çince ve
/// Korece yüzlerce hece/karakterle yazılır, Hintçe, Bengalce ve Tayca harfleri
/// birleşik hece kümeleri oluşturur, Vietnamca kelimeleri tek hecelidir.
const kQuizOnlyLangs = ['vi', 'ko', 'zh', 'hi', 'bn', 'th'];

/// İçerik dili olan bütün diller (33).
const kAllWordLangs = [...kWordLangs, ...kQuizOnlyLangs];

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
};

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
class Lexicon {
  final String lang;

  /// Bütün kelimeler (en sık önce).
  final List<String> words;
  final Set<String> all;
  final Map<int, List<String>> _byLen;

  /// Dilin harfleri (sıklık sırasıyla).
  final List<String> letters;

  /// Harf sıklıkları (aynı sırayla).
  final List<int> letterWeights;

  Lexicon._(this.lang, this.words, this.all, this._byLen, this.letters, this.letterWeights);

  static final Map<String, Lexicon> _cache = {};

  static Lexicon of(String lang) {
    final l = _raw.containsKey(lang) || kQuizOnlyLangs.contains(lang) ? lang : 'en';
    return _cache[l] ??= _load(l);
  }

  /// Dilin kelime listesi var mı (yoksa yalnızca bütün-kelime türleri oynanır).
  static bool hasList(String lang) => _raw.containsKey(lang);

  static Lexicon _load(String lang) {
    final seen = <String>{};
    final list = <String>[];
    for (final w0 in (_raw[lang] ?? '').split(' ')) {
      if (w0.isEmpty) continue;
      final w = foldWord(w0, lang);
      if (w.length < 3 || !seen.add(w)) continue;
      list.add(w);
    }
    final byLen = <int, List<String>>{};
    final counts = <String, int>{};
    for (final w in list) {
      byLen.putIfAbsent(w.length, () => <String>[]).add(w);
      for (final ch in w.split('')) {
        counts[ch] = (counts[ch] ?? 0) + 1;
      }
    }
    final letters = counts.keys.toList()..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    return Lexicon._(lang, list, seen, byLen, letters, [for (final l in letters) counts[l]!]);
  }

  bool has(String w) => all.contains(w);

  /// [len] harfli kelimeler (sıklık sırasıyla).
  List<String> ofLength(int len) => _byLen[len] ?? const <String>[];

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

  /// Ağırlıklı rastgele harf.
  String randomLetter(SeededRandom r) => letters[r.weighted(letterWeights)];

  String up(String w) => upWord(w, lang);
  String upCh(String ch) => upLetter(ch, lang);

  /// Kelime oyun tahtası puanı: seyrek harf daha değerli (1..10).
  int letterValue(String ch) {
    final i = letters.indexOf(ch);
    if (i < 0) return 5;
    final n = letters.length;
    if (i < n * 0.30) return 1;
    if (i < n * 0.45) return 2;
    if (i < n * 0.60) return 3;
    if (i < n * 0.72) return 4;
    if (i < n * 0.82) return 5;
    if (i < n * 0.90) return 8;
    return 10;
  }

  /// Klavye düzeni: alfabe sırasında satırlar.
  List<List<String>> keyboardRows() {
    final alpha = alphabet();
    final per = alpha.length <= 26 ? 10 : (alpha.length <= 30 ? 11 : (alpha.length <= 48 ? 12 : 13));
    final rows = <List<String>>[];
    for (var i = 0; i < alpha.length; i += per) {
      rows.add(alpha.sublist(i, i + per > alpha.length ? alpha.length : i + per));
    }
    return rows;
  }

  /// Alfabe sırasında harfler.
  List<String> alphabet() {
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
