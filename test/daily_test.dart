import 'package:flutter_test/flutter_test.dart';
import 'package:kelime_motoru/kelime_motoru.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studio_core/core/global_daily.dart';

/// Günün Bulmacası: tek kişilik kelime türleri herkese (aynı dilde) aynı
/// günlük bölümü verir; tablo her dil için ayrıdır.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final e in kWordKinds.entries) {
    if (e.value.players > 1) continue;
    test('${e.key}: günlük bölüm belirlenimci ve geçerli (tr, en)', () {
      for (final lang in const ['tr', 'en']) {
        final r = WordRules(gameId: 'oyun-g-${e.key}', kindFor: (_) => e.value, lang: lang);
        expect(r.globalDaily, isTrue);
        expect(r.dailyPerLanguage, isTrue);
        final spec = r.globalDailySpec('2026-11-26');
        expect(spec.difficulty, inInclusiveRange(3, 6));
        final a = r.build(spec), b = r.build(r.globalDailySpec('2026-11-26'));
        expect(a.validation.ok, isTrue, reason: '${e.key} $lang');
        expect(a.puzzle.lang, b.puzzle.lang);
        expect(a.spec.seed, b.spec.seed);
      }
      expect(GlobalDaily.board('oyun-g-${e.key}', '2026-11-26', lang: 'tr'), endsWith('-tr_2026-11-26'));
    });
  }
}
