import 'package:flutter_test/flutter_test.dart';
import 'package:kelime_motoru/kelime_motoru.dart';

/// Pazar kalitesi: uygunsuz kelime hiçbir bölümde çıkmaz; yaygın kelimeler
/// (çekimli biçimler dahil) tahminde kabul edilir; argo kısaltmalar gizli
/// kelime olmaz.
void main() {
  test('uygunsuz kelimeler sözlükte yok (tr, en, ar, ja, nb, hi)', () {
    const bad = {
      'tr': ['piç', 'ibne', 'pezevenk', 'kahpe', 'fahişe', 'tecavüz', 'orospu', 'siktir', 'yavşak', 'esrar', 'votka'],
      'en': ['fuck', 'shit', 'bitch', 'whore', 'cocaine', 'whiskey', 'drunk', 'naked', 'idiot'],
      'ar': ['قتل', 'مخدرات', 'خمر', 'انتحار'],
      'ja': ['カジノ', 'ビール', 'マヤク', 'コロス'],
      'nb': ['faen', 'helvete', 'fitte', 'pikk'],
    };
    for (final e in bad.entries) {
      final lx = Lexicon.of(e.key);
      for (final w in e.value) {
        expect(lx.has(w), isFalse, reason: '${e.key}: $w');
        expect(lx.words.contains(w), isFalse, reason: '${e.key}: $w');
      }
    }
    for (final l in kWordLangs) {
      final lx = Lexicon.of(l);
      expect(lx.words.where((w) => isBlockedWord(w, l)), isEmpty, reason: l);
    }
  });

  test('yaygın kelimeler kabul edilir, argo kısaltma cevap olmaz', () {
    final en = Lexicon.of('en');
    for (final w in ['after', 'later', 'tears', 'years', 'crane', 'slate', 'gonna']) {
      expect(en.has(w), isTrue, reason: w);
    }
    expect(en.words.contains('gonna'), isFalse);
    expect(en.ofLength(5).contains('wanna'), isFalse);
    final tr = Lexicon.of('tr');
    for (final w in ['için', 'daha', 'kitap', 'kalem']) {
      expect(tr.has(w), isTrue, reason: w);
    }
    expect(Lexicon.of('ja').has('アリガトウ'), isTrue);
  });
}
