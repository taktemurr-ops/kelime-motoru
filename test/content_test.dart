import 'package:flutter_test/flutter_test.dart';
import 'package:kelime_motoru/kelime_motoru.dart';
import 'package:kelime_motoru/src/clues.dart';
import 'package:kelime_motoru/src/data/content_index.dart';
import 'package:kelime_motoru/src/words.dart' show upWord;

/// 2. dalgada eklenen 15 dil (içerikleri birbiriyle çakışmasız yazıldı).
const _wave2 = ['fi', 'id', 'ms', 'fil', 'ar', 'fa', 'he', 'ur', 'ja', 'vi', 'ko', 'zh', 'hi', 'bn', 'th'];

void main() {
  test('33 içerik dili: her dilin kendi içeriği var (İngilizceye düşmez)', () {
    expect(kAllWordLangs.toSet().length, 33);
    for (final l in kAllWordLangs) {
      expect(kWordLangNames.containsKey(l), isTrue, reason: l);
      if (l == 'tr' || l == 'en') continue;
      expect(kProverbsByLang.containsKey(l), isTrue, reason: 'atasözü $l');
      expect(kGroupsByLang.containsKey(l), isTrue, reason: 'gruplar $l');
      expect(kSynonymsByLang.containsKey(l), isTrue, reason: 'eş anlam $l');
      expect(kAntonymsByLang.containsKey(l), isTrue, reason: 'zıt anlam $l');
      if (kWordLangs.contains(l)) expect(kCluesByLang.containsKey(l), isTrue, reason: 'ipucu $l');
    }
  });

  test('içerik nicelik ve kalite denetimi', () {
    for (final l in kQuizLangs) {
      expect(proverbList(l).length, greaterThanOrEqualTo(15), reason: 'atasözü $l');
      final groups = groupList(l);
      expect(groups.length, greaterThanOrEqualTo(12), reason: 'gruplar $l');
      final seen = <String, String>{};
      for (final g in groups) {
        expect(g.$2.length, greaterThanOrEqualTo(5), reason: '$l ${g.$1}');
        for (final w in g.$2) {
          if (_wave2.contains(l)) expect(seen[w], isNull, reason: '$l: "$w" iki grupta (${g.$1}, ${seen[w]})');
          seen[w] = g.$1;
        }
      }
      expect(synonymList(l).length, greaterThanOrEqualTo(12), reason: 'eş anlam $l');
      expect(antonymList(l).length, greaterThanOrEqualTo(12), reason: 'zıt anlam $l');
      for (final p in [...synonymList(l), ...antonymList(l)]) {
        expect(p.$1 == p.$2, isFalse, reason: '$l $p');
      }
    }
    for (final l in kClueLangs) {
      final clues = clueList(l);
      expect(clues.length, greaterThanOrEqualTo(_wave2.contains(l) ? 90 : 60), reason: 'ipucu $l');
      final lx = Lexicon.of(l);
      for (final c in clues) {
        expect(c.$1.split('').every(lx.letters.contains), isTrue, reason: '$l ${c.$1}');
        expect(c.$2.trim().isNotEmpty, isTrue, reason: '$l ${c.$1}');
      }
    }
  });

  test('dil kodları ve yazım', () {
    expect(wordLangFor('tl'), 'fil');
    expect(wordLangFor('iw'), 'he');
    expect(wordLangFor('no'), 'nb');
    expect(wordLangFor('ko'), 'en');
    expect(wordLangFor('ko', kQuizLangs), 'ko');
    expect(upWord('שלומ', 'he'), 'שלום');
    expect(Lexicon.of('ar').alphabet().length, greaterThanOrEqualTo(28));
    expect(Lexicon.of('vi').lang, 'vi');
  });
}
