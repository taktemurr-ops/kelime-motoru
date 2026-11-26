import 'package:flutter_test/flutter_test.dart';
import 'package:kelime_motoru/kelime_motoru.dart';
import 'package:kelime_motoru/src/kinds/ek4.dart';
import 'package:kelime_motoru/src/kinds/theme.dart';
import 'package:studio_core/core/rng.dart';

void main() {
  test('dört resim: her dilde yeterli kavram', () {
    for (final l in kAllWordLangs) {
      final n = PicsKind.validConcepts(Lexicon.of(l)).length;
      // ignore: avoid_print
      print('dort-resim $l: $n kavram');
      expect(n, greaterThanOrEqualTo(30), reason: l);
    }
  });

  test('harf kutusu: kenar dağılımı kuralı', () {
    final sides = BoxKind.arrange(['kitap', 'pembe', 'ensiz'], SeededRandom(3));
    if (sides != null) {
      final p = BoxPuzzle(sides, const [], 3);
      for (final w in ['kitap', 'pembe']) {
        for (var i = 1; i < w.length; i++) {
          expect(p.sideOf(w[i]) == p.sideOf(w[i - 1]), isFalse);
        }
      }
    }
    for (final l in ['tr', 'en', 'ja', 'zh']) {
      final lx = Lexicon.of(l);
      final p = const BoxKind().make(lx, 5, SeededRandom(11)) as BoxPuzzle?;
      if (p == null) continue;
      expect(const BoxKind().check(p, lx), isTrue, reason: l);
      // ignore: avoid_print
      print('harf-kutusu $l: ${p.sides.map((s) => s.map(lx.upCh).join()).join(' | ')} → ${p.solution.map(lx.up).join(' ')}');
    }
  });

  test('beş ipucu: seçenekler tek yanıtlı', () {
    for (final l in ['tr', 'en', 'de', 'ar', 'ja']) {
      final lx = Lexicon.of(l);
      for (var d = 1; d <= 10; d++) {
        final p = const CluesKind().make(lx, d, SeededRandom(d * 7 + l.length));
        if (p == null) continue;
        expect(const CluesKind().check(p, lx), isTrue, reason: '$l $d');
      }
    }
  });
  test('tema avı: Hamilton yolu ve 33 dilde bölüm', () {
    final r = SeededRandom(5);
    for (final (w, h) in [(3, 4), (5, 6), (6, 7)]) {
      final path = ThemeKind.hamiltonPath(w, h, r);
      expect(path.toSet().length, w * h);
      for (var i = 1; i < path.length; i++) {
        expect(ThemeKind.adjacent(path[i - 1], path[i], w), isTrue);
      }
    }
    for (final l in kAllWordLangs) {
      final lx = Lexicon.of(l);
      // ignore: avoid_print
      print('tema-avi $l: ${ThemeKind.themes(lx).length} tema');
      for (final d in [1, 5, 10]) {
        final p = const ThemeKind().make(lx, d, SeededRandom(d * 13 + l.length)) as ThemePuzzle?;
        expect(p, isNotNull, reason: '$l $d');
        expect(const ThemeKind().check(p!, lx), isTrue, reason: '$l $d');
      }
    }
  });
}
