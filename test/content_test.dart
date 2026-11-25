import 'package:flutter_test/flutter_test.dart';
import 'package:kelime_motoru/kelime_motoru.dart';
import 'package:kelime_motoru/src/clues.dart';
import 'package:kelime_motoru/src/data/content_index.dart';
import 'package:kelime_motoru/src/tiles.dart';
import 'package:kelime_motoru/src/words.dart' show upWord;
import 'package:studio_core/core/rng.dart';
import 'package:kelime_motoru/src/kinds/quiz.dart' show tileMisspellings;

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
      expect(kCluesByLang.containsKey(l), isTrue, reason: 'ipucu $l');
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
        if (kTileLangs.contains(l)) {
          // Taş dillerinde yanıt en az iki taş; her taşın yazısı var.
          expect(c.$1.length, greaterThanOrEqualTo(2), reason: '$l ${c.$1}');
          expect(c.$1.split('').every((t) => lx.upCh(t).isNotEmpty && !lx.upCh(t).contains(RegExp('[\uE000-\uF8FF]'))), isTrue, reason: '$l ${lx.up(c.$1)}');
          continue;
        }
        expect(c.$1.split('').every(lx.letters.contains), isTrue, reason: '$l ${c.$1}');
        expect(c.$2.trim().isNotEmpty, isTrue, reason: '$l ${c.$1}');
      }
    }
  });

  test('dil kodları ve yazım', () {
    expect(wordLangFor('tl'), 'fil');
    expect(wordLangFor('iw'), 'he');
    expect(wordLangFor('no'), 'nb');
    expect(wordLangFor('ko'), 'ko');
    expect(wordLangFor('zh'), 'zh');
    expect(wordLangFor('ko', kQuizLangs), 'ko');
    expect(upWord('שלומ', 'he'), 'שלום');
    expect(Lexicon.of('ar').alphabet().length, greaterThanOrEqualTo(28));
    expect(Lexicon.of('vi').lang, 'vi');
  });

  test('taş dilleri: kelime listesi, taşlar ve yazım', () {
    for (final l in kTileLangs) {
      final lx = Lexicon.of(l);
      expect(lx.tiled, isTrue, reason: l);
      expect(lx.words.length, greaterThan(8000), reason: l);
      expect(lx.ofLength(2).length, greaterThan(1500), reason: l);
      expect(lx.ofLength(3).length, greaterThan(500), reason: l);
      expect(lx.ofLength(4).length, greaterThan(300), reason: l);
      for (final w in lx.words.take(300)) {
        // Ekrandaki yazı geri kodlanınca aynı kelime olur.
        expect(lx.encode(lx.up(w).toLowerCase()), w, reason: '$l ${lx.up(w)}');
      }
      final w = lx.words[10];
      final pool = lx.keyPool(w.split(''), 3);
      expect(w.split('').every(pool.contains), isTrue, reason: l);
      expect(pool.length, greaterThan(w.split('').toSet().length), reason: l);
    }
    // Vietnamca: ses tonu ayrı taş, benzer taşlar aynı hecenin öbür tonları.
    final vi = Lexicon.of('vi');
    final hoc = vi.encode('học sinh')!;
    expect(hoc.length, 2);
    expect(vi.up(hoc), 'HỌC SINH');
    final lam = vi.encode('làm việc')!;
    expect(vi.kin(lam[0]).map(vi.tileText), contains('lạm'));
    for (final w in vi.words.take(100)) {
      for (final ch in w.split('')) {
        expect(vi.kin(ch).every((k) => viToneless(vi.tileText(k)) == viToneless(vi.tileText(ch))), isTrue);
      }
      final bad = tileMisspellings(w, vi, SeededRandom(5), 2);
      for (final b in bad) {
        expect(vi.has(b), isFalse);
        expect(viToneless(vi.up(b).toLowerCase()), viToneless(vi.up(w).toLowerCase()));
      }
    }
    // Çince: okunuş (pinyin) ipucu.
    expect(Lexicon.of('zh').reading('学生'), 'xué shēng');
    // Hintçe: bitişik ünsüzler tek taş.
    expect(aksaras('क्षत्रिय', 'hi'), ['क्ष', 'त्रि', 'य']);
  });

  test('Korece: hece taşları ve jamo klavyesi', () {
    final syl = Lexicon.of('ko');
    final jamo = Lexicon.of('ko', keyed: true);
    expect(syl.tiled, isTrue);
    expect(jamo.jamo, isTrue);
    expect(jamo.tiled, isFalse);
    expect(hangulToJamo('괜찮아'), 'ㄱㅗㅐㄴㅊㅏㄴㅎㅇㅏ');
    for (final w in syl.words) {
      expect(jamoToHangul(hangulToJamo(w)), w);
    }
    expect(jamo.up(hangulToJamo('사랑')), '사랑');
    expect(jamo.ofLength(5).length, greaterThan(1000));
    final keys = jamo.keyboardRows().expand((r) => r).toSet();
    expect(jamo.letters.every(keys.contains), isTrue);
  });
}
