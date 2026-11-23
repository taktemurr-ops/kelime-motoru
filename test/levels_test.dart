import 'package:flutter_test/flutter_test.dart';
import 'package:kelime_motoru/kelime_motoru.dart';
import 'package:studio_core/core/level_plan.dart';

void main() {
  test('bütün kelime listeleri yüklenir', () {
    for (final l in kWordLangs) {
      final lx = Lexicon.of(l);
      expect(lx.words.length, greaterThan(5000), reason: l);
      expect(lx.ofLength(5).length, greaterThan(500), reason: l);
      expect(lx.alphabet().length, greaterThanOrEqualTo(20), reason: l);
    }
  });

  for (final e in kWordKinds.entries) {
    test('${e.key}: bölümler her dilde kurulur ve doğrulanır', () {
      final langs = e.value.contentLangs ?? kWordLangs;
      for (final l in langs) {
        final rules = WordRules(gameId: 'oyun-test-${e.key}', kindFor: (_) => e.value, lang: l);
        final planner = LevelPlanner(gameId: rules.gameId, optionalMechanics: const []);
        final levels = (l == 'tr' || l == 'en') ? const [1, 7, 40, 300, 5000, 99999] : const [3, 99999];
        for (final n in levels) {
          final gl = rules.build(planner.spec(n));
          expect(gl.validation.ok, isTrue, reason: '${e.key} $l bölüm $n');
          expect(gl.puzzle.lang, l, reason: '${e.key} $l');
        }
      }
    }, timeout: const Timeout(Duration(minutes: 10)));
  }

  test('aynı tohum aynı bölüm', () {
    final rules = wordRulesFor('oyun-kelime-avi', 'kelime-avi')..lang = 'tr';
    final planner = LevelPlanner(gameId: rules.gameId, optionalMechanics: const []);
    final a = rules.build(planner.spec(123)).puzzle;
    final b = rules.build(planner.spec(123)).puzzle;
    expect(a.seed, b.seed);
    expect(a.d, b.d);
  });
}
