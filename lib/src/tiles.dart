/// Hece ve küme yazıları için yardımcılar: Hangıl jamo ayırma/birleştirme,
/// Vietnamca ses tonu ayıklama, Hint yazılarında akşara bölme ve taş benzerliği.
library;

// ---------------- Hangıl ----------------

const _cho = ['ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'];
const _jung = ['ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ', 'ㅘ', 'ㅙ', 'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ', 'ㅢ', 'ㅣ'];
const _jong = ['', 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ', 'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'];

/// Bileşik sesli ve son ünsüzlerin iki tuşluk karşılığı (두벌식 klavye).
const Map<String, String> _split = {
  'ㅘ': 'ㅗㅏ', 'ㅙ': 'ㅗㅐ', 'ㅚ': 'ㅗㅣ', 'ㅝ': 'ㅜㅓ', 'ㅞ': 'ㅜㅔ', 'ㅟ': 'ㅜㅣ', 'ㅢ': 'ㅡㅣ',
  'ㄳ': 'ㄱㅅ', 'ㄵ': 'ㄴㅈ', 'ㄶ': 'ㄴㅎ', 'ㄺ': 'ㄹㄱ', 'ㄻ': 'ㄹㅁ', 'ㄼ': 'ㄹㅂ', 'ㄽ': 'ㄹㅅ', 'ㄾ': 'ㄹㅌ',
  'ㄿ': 'ㄹㅍ', 'ㅀ': 'ㄹㅎ', 'ㅄ': 'ㅂㅅ',
};
final Map<String, String> _join = {for (final e in _split.entries) e.value: e.key};

/// Korece ekran klavyesi (두벌식 düzeni; üst sıra Shift harfleri).
const List<List<String>> kKoKeyRows = [
  ['ㅂ', 'ㅈ', 'ㄷ', 'ㄱ', 'ㅅ', 'ㅛ', 'ㅕ', 'ㅑ', 'ㅐ', 'ㅔ'],
  ['ㅁ', 'ㄴ', 'ㅇ', 'ㄹ', 'ㅎ', 'ㅗ', 'ㅓ', 'ㅏ', 'ㅣ'],
  ['ㅋ', 'ㅌ', 'ㅊ', 'ㅍ', 'ㅠ', 'ㅜ', 'ㅡ'],
  ['ㅃ', 'ㅉ', 'ㄸ', 'ㄲ', 'ㅆ', 'ㅒ', 'ㅖ'],
];

bool isHangulSyllable(String ch) {
  final c = ch.codeUnitAt(0);
  return c >= 0xAC00 && c <= 0xD7A3;
}

bool _isVowel(String j) => _jung.contains(j);

/// Heceleri klavye jamolarına ayır: 사랑 → ㅅㅏㄹㅏㅇ, 왜 → ㅇㅗㅐ.
String hangulToJamo(String s) {
  final b = StringBuffer();
  for (final ch in s.split('')) {
    if (!isHangulSyllable(ch)) {
      b.write(_split[ch] ?? ch);
      continue;
    }
    final i = ch.codeUnitAt(0) - 0xAC00;
    final l = i ~/ 588, v = (i % 588) ~/ 28, t = i % 28;
    b
      ..write(_cho[l])
      ..write(_split[_jung[v]] ?? _jung[v]);
    if (t > 0) b.write(_split[_jong[t]] ?? _jong[t]);
  }
  return b.toString();
}

/// Jamo dizisini hecelere birleştir (yazım sırasındaki yarım heceler de gösterilir).
String jamoToHangul(String s) {
  final out = StringBuffer();
  String? l, v, t;
  void flush() {
    if (l != null && v != null) {
      out.writeCharCode(0xAC00 + (_cho.indexOf(l!) * 21 + _jung.indexOf(v!)) * 28 + (t == null ? 0 : _jong.indexOf(t!)));
    } else {
      if (l != null) out.write(l);
      if (v != null) out.write(v);
    }
    l = v = t = null;
  }

  for (final j in s.split('')) {
    if (_isVowel(j)) {
      if (l != null && v == null) {
        v = j;
      } else if (l != null && v != null && t == null) {
        final c = _join['$v$j'];
        if (c != null) {
          v = c;
        } else {
          flush();
          v = j;
        }
      } else if (t != null) {
        // Son ünsüz yeni hecenin ilk ünsüzü olur.
        final sp = _split[t!];
        String nl;
        if (sp != null) {
          t = sp[0];
          nl = sp[1];
        } else {
          nl = t!;
          t = null;
        }
        flush();
        l = nl;
        v = j;
      } else {
        // Ünsüzsüz sesli.
        final c = v == null ? null : _join['$v$j'];
        if (c != null) {
          v = c;
        } else {
          flush();
          v = j;
        }
      }
    } else if (_cho.contains(j) || _jong.contains(j)) {
      if (l == null && v == null) {
        l = _cho.contains(j) ? j : null;
        if (l == null) out.write(j);
      } else if (l != null && v == null) {
        flush();
        l = j;
      } else if (l != null && v != null && t == null) {
        if (_jong.contains(j)) {
          t = j;
        } else {
          flush();
          l = j;
        }
      } else if (t != null) {
        final c = _join['$t$j'];
        if (c != null && _jong.contains(c)) {
          t = c;
        } else {
          flush();
          l = j;
        }
      } else {
        flush();
        l = _cho.contains(j) ? j : null;
        if (l == null) out.write(j);
      }
    } else {
      flush();
      out.write(j);
    }
  }
  flush();
  return out.toString();
}

/// Hecenin ilk ünsüzü (benzer taş seçimi için).
String hangulInitial(String ch) => isHangulSyllable(ch) ? _cho[(ch.codeUnitAt(0) - 0xAC00) ~/ 588] : ch;

// ---------------- Vietnamca ----------------

const _viTone = {
  'á': 'a', 'à': 'a', 'ả': 'a', 'ã': 'a', 'ạ': 'a',
  'ắ': 'ă', 'ằ': 'ă', 'ẳ': 'ă', 'ẵ': 'ă', 'ặ': 'ă',
  'ấ': 'â', 'ầ': 'â', 'ẩ': 'â', 'ẫ': 'â', 'ậ': 'â',
  'é': 'e', 'è': 'e', 'ẻ': 'e', 'ẽ': 'e', 'ẹ': 'e',
  'ế': 'ê', 'ề': 'ê', 'ể': 'ê', 'ễ': 'ê', 'ệ': 'ê',
  'í': 'i', 'ì': 'i', 'ỉ': 'i', 'ĩ': 'i', 'ị': 'i',
  'ó': 'o', 'ò': 'o', 'ỏ': 'o', 'õ': 'o', 'ọ': 'o',
  'ố': 'ô', 'ồ': 'ô', 'ổ': 'ô', 'ỗ': 'ô', 'ộ': 'ô',
  'ớ': 'ơ', 'ờ': 'ơ', 'ở': 'ơ', 'ỡ': 'ơ', 'ợ': 'ơ',
  'ú': 'u', 'ù': 'u', 'ủ': 'u', 'ũ': 'u', 'ụ': 'u',
  'ứ': 'ư', 'ừ': 'ư', 'ử': 'ư', 'ữ': 'ư', 'ự': 'ư',
  'ý': 'y', 'ỳ': 'y', 'ỷ': 'y', 'ỹ': 'y', 'ỵ': 'y',
};

/// Heceyi ses tonu işaretsiz yaz (học → hoc değil, hoc yerine: học → hoc; ơ, ư gibi harfler korunur).
String viToneless(String s) => [for (final ch in s.split('')) _viTone[ch] ?? ch].join();

// ---------------- Hint yazıları ----------------

bool _inR(int c, int a, int b) => c >= a && c <= b;

/// Devanagari ve Bengal yazısında akşaralara böl (ünsüz + bitişik ünsüzler + sesli işareti).
/// Bölünemezse null.
List<String>? aksaras(String w, String lang) {
  final deva = lang == 'hi';
  bool cons(int c) => deva
      ? (_inR(c, 0x915, 0x939) || _inR(c, 0x958, 0x95F) || _inR(c, 0x978, 0x97F))
      : (_inR(c, 0x995, 0x9B9) || _inR(c, 0x9DC, 0x9DF) || c == 0x9CE || c == 0x9F0 || c == 0x9F1);
  bool indep(int c) => deva ? (_inR(c, 0x904, 0x914) || c == 0x960 || c == 0x961 || _inR(c, 0x972, 0x977)) : (_inR(c, 0x985, 0x994) || c == 0x9E0 || c == 0x9E1);
  bool matra(int c) => deva
      ? (_inR(c, 0x93A, 0x93B) || _inR(c, 0x93E, 0x94C) || _inR(c, 0x94E, 0x94F) || _inR(c, 0x955, 0x957) || c == 0x962 || c == 0x963)
      : (_inR(c, 0x9BE, 0x9CC) || c == 0x9D7 || c == 0x9E2 || c == 0x9E3);
  bool sign(int c) => deva ? _inR(c, 0x900, 0x903) : _inR(c, 0x981, 0x983);
  final nukta = deva ? 0x93C : 0x9BC, virama = deva ? 0x94D : 0x9CD;
  final cs = w.codeUnits;
  final out = <String>[];
  var i = 0;
  while (i < cs.length) {
    final s = i;
    if (cons(cs[i])) {
      i++;
      if (i < cs.length && cs[i] == nukta) i++;
      while (i + 1 < cs.length && cs[i] == virama) {
        var k = i + 1;
        if (cs[k] == 0x200C || cs[k] == 0x200D) k++;
        if (k < cs.length && cons(cs[k])) {
          i = k + 1;
          if (i < cs.length && cs[i] == nukta) i++;
        } else {
          break;
        }
      }
      if (i < cs.length && (matra(cs[i]) || cs[i] == virama)) i++;
    } else if (indep(cs[i])) {
      i++;
    } else {
      return null;
    }
    while (i < cs.length && sign(cs[i])) {
      i++;
    }
    out.add(String.fromCharCodes(cs.sublist(s, i)));
  }
  return out;
}

/// Akşaranın iskeleti: sesli işaretleri ve nazal işaretler atılır (kardeş taş arama).
String indicSkeleton(String t, String lang) {
  final deva = lang == 'hi';
  return String.fromCharCodes(t.codeUnits.where((c) => deva
      ? !(_inR(c, 0x900, 0x903) || _inR(c, 0x93A, 0x94C) || _inR(c, 0x94E, 0x94F) || c == 0x962 || c == 0x963)
      : !(_inR(c, 0x981, 0x983) || _inR(c, 0x9BE, 0x9CC) || c == 0x9D7 || c == 0x9E2 || c == 0x9E3)));
}

/// Tay hecesinin iskeleti: ton işaretleri ve sesli işaretleri atılır.
String thaiSkeleton(String t) =>
    String.fromCharCodes(t.codeUnits.where((c) => !(c == 0xE31 || _inR(c, 0xE34, 0xE3A) || _inR(c, 0xE47, 0xE4E) || _inR(c, 0xE40, 0xE44) || _inR(c, 0xE30, 0xE33))));
