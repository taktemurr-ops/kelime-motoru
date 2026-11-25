import 'data/clues_en.dart';
import 'data/clues_tr.dart';
import 'data/content_index.dart';
import 'data/groups.dart';
import 'data/pairs.dart';
import 'data/proverbs.dart';
import 'words.dart';

/// İpuçlu harf türlerinin (çengel, kare bulmaca, akrostiş) dilleri: 33 dil
/// (taş dillerinde yanıtlar taş dizisidir).
const kClueLangs = kWordLangs;

/// Kriptogram: atasözü harfleri klavyede olmalı (Japonca atasözleri kanji ve
/// hiragana ile yazılır, klavye katakanadır). Taş dillerinde şifre taş
/// (hece/karakter/akşara) düzeyindedir ve taş havuzuyla çözülür.
final kCipherLangs = [for (final l in kWordLangs) if (l != 'ja') l];

/// Bütün-kelime türlerinin (atasözü, eş/zıt anlam, gruplama) dilleri: 33 dil.
const kQuizLangs = kAllWordLangs;

/// Kelimeler harf taşına bölünmeden gösterilen diller (atasözü boşluğu ve
/// gruplama kelimeleri doğal yazımıyla).
bool _natural(String lang) => lang == 'ja' || kTileLangs.contains(lang);

/// Atasözü boşluğuna seçilebilecek en kısa parça (harf/hece sayısı).
int proverbMinToken(String lang) => (lang == 'zh' || lang == 'ja' || lang == 'ko') ? 2 : 4;

List<String> _src(String lang, List<String> tr, List<String> en, Map<String, List<String>> other) =>
    lang == 'tr' ? tr : (lang == 'en' ? en : (other[lang] ?? en));

String _lowerWord(String w, String lang) {
  var s = w.trim();
  if (lang == 'tr') s = s.replaceAll('I', 'ı').replaceAll('İ', 'i');
  return foldWord(s.toLowerCase(), lang);
}

bool _letters(String w, String lang) {
  if (!Lexicon.hasList(lang)) return w.length >= 2 && !w.contains(' ');
  if (kTileLangs.contains(lang)) return (Lexicon.of(lang).encode(w)?.length ?? 0) >= 2;
  final alpha = Lexicon.of(lang).letters.toSet();
  return w.length >= 3 && w.split('').every(alpha.contains);
}

final Map<String, List<(String, String)>> _clues = {};

/// İpuçlu kelimeler: (yanıt, ipucu). Yanıt küçük harf, sadeleştirilmiş; taş
/// dillerinde sözlüğün taş biçiminde (bkz. [Lexicon.encode]).
List<(String, String)> clueList(String lang) => _clues[lang] ??= () {
      final src = _src(lang, kCluesTr, kCluesEn, kCluesByLang);
      final tiled = kTileLangs.contains(lang);
      final seen = <String>{};
      final out = <(String, String)>[];
      for (final e in src) {
        final i = e.indexOf('|');
        if (i < 0) continue;
        var w = _lowerWord(e.substring(0, i), lang);
        if (tiled) {
          final c = Lexicon.of(lang).encode(w);
          if (c == null || c.length < 2) continue;
          w = c;
        } else if (w.contains(' ') || !_letters(w, lang)) {
          continue;
        }
        if (!seen.add(w)) continue;
        out.add((w, e.substring(i + 1)));
      }
      if (tiled) {
        // Taş dillerinde bulmaca ızgarası kesişmeye muhtaç: kategori ve eş/zıt
        // anlam içeriğinden de ipucu üretilir ("Kategori: Meyve", "X'in zıttı").
        final t = _autoClue[lang]!;
        void add(String word, String clue) {
          final c = Lexicon.of(lang).encode(_lowerWord(word, lang));
          if (c == null || c.length < 2 || !seen.add(c)) return;
          out.add((c, clue));
        }

        for (final g in _src(lang, kGroupsTr, kGroupsEn, kGroupsByLang)) {
          final k = g.indexOf('|');
          if (k < 0) continue;
          for (final w in g.substring(k + 1).split(' ')) {
            if (w.isNotEmpty) add(w, t[0].replaceAll('%', g.substring(0, k)));
          }
        }
        for (final p in _src(lang, kSynonymsTr, kSynonymsEn, kSynonymsByLang)) {
          final q = p.split('|');
          if (q.length != 2) continue;
          add(q[0], t[1].replaceAll('%', q[1]));
          add(q[1], t[1].replaceAll('%', q[0]));
        }
        for (final p in _src(lang, kAntonymsTr, kAntonymsEn, kAntonymsByLang)) {
          final q = p.split('|');
          if (q.length != 2) continue;
          add(q[0], t[2].replaceAll('%', q[1]));
          add(q[1], t[2].replaceAll('%', q[0]));
        }
      }
      return out;
    }();

/// Taş dillerinde otomatik ipucu kalıpları: kategori, eş anlam, zıt anlam (% yerine kelime).
const Map<String, List<String>> _autoClue = {
  'zh': ['类别：%', '近义词：%', '反义词：%'],
  'ko': ['분류: %', '비슷한 말: %', '반대말: %'],
  'vi': ['Nhóm: %', 'Đồng nghĩa với “%”', 'Trái nghĩa với “%”'],
  'hi': ['श्रेणी: %', '“%” का पर्यायवाची', '“%” का विलोम'],
  'bn': ['শ্রেণি: %', '“%”-এর সমার্থক', '“%”-এর বিপরীত'],
  'th': ['หมวด: %', 'คำพ้องความหมายของ “%”', 'คำตรงข้ามของ “%”'],
};

/// Atasözleri (yazıldığı gibi).
List<String> proverbList(String lang) => _src(lang, kProverbsTr, kProverbsEn, kProverbsByLang);

final Map<String, List<(String, List<String>)>> _groups = {};

/// Kategoriler: (başlık, kelimeler).
List<(String, List<String>)> groupList(String lang) => _groups[lang] ??= [
      for (final e in _src(lang, kGroupsTr, kGroupsEn, kGroupsByLang))
        (
          e.substring(0, e.indexOf('|')),
          [
            for (final w in e.substring(e.indexOf('|') + 1).split(' '))
              if (w.isNotEmpty && (_natural(lang) ? _lowerWord(w, lang).length >= 2 : _letters(_lowerWord(w, lang), lang)))
                _lowerWord(w, lang),
          ],
        ),
    ];

List<(String, String)> _pairs(List<String> src, String lang) => [
      for (final e in src)
        if (e.contains('|')) (_lowerWord(e.split('|')[0], lang), _lowerWord(e.split('|')[1], lang)),
    ];

/// Eş anlamlı çiftler.
List<(String, String)> synonymList(String lang) => _pairs(_src(lang, kSynonymsTr, kSynonymsEn, kSynonymsByLang), lang);

/// Zıt anlamlı çiftler.
List<(String, String)> antonymList(String lang) => _pairs(_src(lang, kAntonymsTr, kAntonymsEn, kAntonymsByLang), lang);

/// Cümleyi kelimelere ayır (noktalama atılır, kesme işareti ve kısa çizgi
/// kelimeyi böler), küçük harf.
List<String> sentenceWords(String s, String lang) => [
      for (final w in s.replaceAll(RegExp(r"['’\-]"), ' ').split(' '))
        if (w.replaceAll(RegExp(r"[.,;:!?'’،؛؟。、！？\u200c\u200d]"), '').trim().isNotEmpty)
          _lowerWord(w.replaceAll(RegExp(r"[.,;:!?'’،؛؟。、！？\u200c\u200d]"), ''), lang),
    ];
