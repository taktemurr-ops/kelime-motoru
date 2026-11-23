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

/// Kelime listesi olan diller (oyun içeriği). Arayüz 33 dildedir; içerik
/// dili listede yoksa İngilizce kullanılır.
const kWordLangs = ['tr', 'en', 'de', 'es', 'fr', 'it', 'pt', 'nl', 'sv', 'da', 'nb', 'pl', 'cs', 'ro', 'hu', 'ru', 'uk', 'el'];

/// Dilin yerel adı (kelime dili seçicisi için).
const kWordLangNames = {
  'tr': 'Türkçe', 'en': 'English', 'de': 'Deutsch', 'es': 'Español', 'fr': 'Français', 'it': 'Italiano',
  'pt': 'Português', 'nl': 'Nederlands', 'sv': 'Svenska', 'da': 'Dansk', 'nb': 'Norsk', 'pl': 'Polski',
  'cs': 'Čeština', 'ro': 'Română', 'hu': 'Magyar', 'ru': 'Русский', 'uk': 'Українська', 'el': 'Ελληνικά',
};

const Map<String, String> _raw = {
  'tr': wordsTr, 'en': wordsEn, 'de': wordsDe, 'es': wordsEs, 'fr': wordsFr, 'it': wordsIt,
  'pt': wordsPt, 'nl': wordsNl, 'sv': wordsSv, 'da': wordsDa, 'nb': wordsNb, 'pl': wordsPl,
  'cs': wordsCs, 'ro': wordsRo, 'hu': wordsHu, 'ru': wordsRu, 'uk': wordsUk, 'el': wordsEl,
};

/// Arayüz dilinden içerik dilini seç.
String wordLangFor(String uiLang, [List<String>? allowed]) {
  final list = allowed ?? kWordLangs;
  if (list.contains(uiLang)) return uiLang;
  if (uiLang == 'no' && list.contains('nb')) return 'nb';
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
};

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

/// Kelimeyi büyük harfle yaz (harf sayısı korunur).
String upWord(String w, String lang) => [for (final ch in w.split('')) upLetter(ch, lang)].join();

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
    final l = _raw.containsKey(lang) ? lang : 'en';
    return _cache[l] ??= _load(l);
  }

  static Lexicon _load(String lang) {
    final seen = <String>{};
    final list = <String>[];
    for (final w0 in _raw[lang]!.split(' ')) {
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
    final per = alpha.length <= 26 ? 10 : (alpha.length <= 30 ? 11 : 12);
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
