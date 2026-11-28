/// Oyun içi görsel kimlik: aynı motoru kullanan kelime oyunlarının her biri
/// oyun alanında kendi rengini, zemin desenini ve taş malzemesini taşır
/// (kapak tek başına yetmez). Dış çerçeve (merkezin onaylı tasarımı)
/// değişmez; yalnızca oyun alanı, paneller ve taşlar oyuna özgüdür.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:studio_core/app/studio_look.dart';

/// Zemin deseni.
enum WordMotif { grid, dots, diagonal, honeycomb, waves, tiles, rings, chevrons, plus, sparkles, bricks, steps }

/// Taş malzemesi (açık renk: mürekkep harfler okunur kalır).
class WordTileMaterial {
  final Color face;
  final Color edge;
  final Color paper;
  const WordTileMaterial(this.face, this.edge, this.paper);
}

const kPaperTiles = WordTileMaterial(Color(0xFFFFFBF3), Color(0xFFD9CBB3), Color(0xFFF7F1E6));
const _gold = WordTileMaterial(Color(0xFFFFF6DA), Color(0xFFE3C77A), Color(0xFFFBF0D2));
const _mint = WordTileMaterial(Color(0xFFEFFAF2), Color(0xFFA9D3B8), Color(0xFFE3F3E8));
const _sky = WordTileMaterial(Color(0xFFF0F6FD), Color(0xFFA9C4E2), Color(0xFFE4EEF9));
const _blush = WordTileMaterial(Color(0xFFFDF0F3), Color(0xFFE3B3C2), Color(0xFFF8E4EA));
const _lavender = WordTileMaterial(Color(0xFFF5F1FD), Color(0xFFC2B3E3), Color(0xFFEDE7FA));
const _sand = WordTileMaterial(Color(0xFFFAF3E6), Color(0xFFD6BF94), Color(0xFFF2E7D2));
const _ice = WordTileMaterial(Color(0xFFF1FAFC), Color(0xFFA8D5DE), Color(0xFFE4F3F6));
const _peach = WordTileMaterial(Color(0xFFFEF3EA), Color(0xFFE9B996), Color(0xFFFBE7D8));
const _sage = WordTileMaterial(Color(0xFFF4F7EA), Color(0xFFBCC79E), Color(0xFFEBF0DC));
const _pearl = WordTileMaterial(Color(0xFFF8F8FA), Color(0xFFC7C9D3), Color(0xFFEEEFF3));
const _lemon = WordTileMaterial(Color(0xFFFFFAE3), Color(0xFFE5D27A), Color(0xFFFCF3CC));

/// Bir oyunun oyun içi kimliği.
class WordSkin {
  final Color seed;
  final WordMotif motif;
  final WordTileMaterial tiles;
  const WordSkin(this.seed, this.motif, this.tiles);

  HSLColor get _h => HSLColor.fromColor(seed);
  Color _c(double s, double l, [double shift = 0]) =>
      HSLColor.fromAHSL(1, (_h.hue + shift) % 360, s.clamp(0.0, 1.0), l.clamp(0.0, 1.0)).toColor();
  double get _s => _h.saturation < 0.2 ? 0.35 : _h.saturation.clamp(0.35, 0.8);

  /// Oyun alanının zemin renkleri (koyu: paneller ve taşlar öne çıkar).
  List<Color> get backdrop => [_c(_s * 0.8, 0.24, -10), _c(_s * 0.85, 0.14, -4), _c(_s * 0.9, 0.07)];

  /// Desen çizgisi rengi.
  Color get ink => _c(_s, 0.78).withValues(alpha: 0.075);

  /// Onaylı paletin oyuna özgü hali: vurgu, kart ve oynat rengi oyunun tonunda.
  StudioLook lookOver(StudioLook base) => base.copyWith(
        background: backdrop,
        accent: _c(_s.clamp(0.55, 0.85), 0.66, 6),
        card: _c(_s * 0.7, 0.30, -8),
        play: _c(_s.clamp(0.55, 0.85), 0.45),
      );
}

const Map<String, WordSkin> kWordSkins = {
  'oyun-5-harfli-kelime-tahmini': WordSkin(Color(0xff4f9a6e), WordMotif.tiles, _mint),
  'oyun-adam-asmaca': WordSkin(Color(0xffc0567a), WordMotif.sparkles, _blush),
  'oyun-akrostis': WordSkin(Color(0xff9b4f6e), WordMotif.steps, _blush),
  'oyun-atasozu-ve-deyim-tamamlama': WordSkin(Color(0xff7d6b3f), WordMotif.waves, _sand),
  'oyun-bes-ipucu': WordSkin(Color(0xff2f6db5), WordMotif.rings, _sky),
  'oyun-bosluk-doldurma': WordSkin(Color(0xff5e8c61), WordMotif.dots, _sage),
  'oyun-cengel-bulmaca': WordSkin(Color(0xff5b6c8f), WordMotif.grid, kPaperTiles),
  'oyun-dort-resim-bir-kelime': WordSkin(Color(0xffd0634a), WordMotif.plus, _peach),
  'oyun-dusen-harfler': WordSkin(Color(0xff2f8f9d), WordMotif.diagonal, _ice),
  'oyun-es-zit-anlam-eslestirme': WordSkin(Color(0xff4c8c8a), WordMotif.chevrons, _ice),
  'oyun-harf-izgarasi': WordSkin(Color(0xff6d5ba8), WordMotif.tiles, _lavender),
  'oyun-harf-kaydirma': WordSkin(Color(0xff2e86ab), WordMotif.bricks, _sky),
  'oyun-harf-kutusu': WordSkin(Color(0xffb8862e), WordMotif.grid, _gold),
  'oyun-harf-ve-sayi-yarisi': WordSkin(Color(0xffb54a4a), WordMotif.diagonal, _peach),
  'oyun-heceleme-ve-yazim': WordSkin(Color(0xff4d7ea8), WordMotif.waves, _pearl),
  'oyun-kare-bulmaca': WordSkin(Color(0xff8c5e3c), WordMotif.grid, _sand),
  'oyun-kelime-avi': WordSkin(Color(0xff3e7cb1), WordMotif.dots, _sky),
  'oyun-kelime-avi-tema': WordSkin(Color(0xFF6C5CE7), WordMotif.sparkles, _lavender),
  'oyun-kelime-bloklari': WordSkin(Color(0xffcb6e3b), WordMotif.bricks, _peach),
  'oyun-kelime-duellosu': WordSkin(Color(0xff6b4e9b), WordMotif.chevrons, _lavender),
  'oyun-kelime-gruplama': WordSkin(Color(0xff7a5c99), WordMotif.rings, _lavender),
  'oyun-kelime-kafesi': WordSkin(Color(0xff4a6fa5), WordMotif.grid, _pearl),
  'oyun-kelime-kurma-tahtasi': WordSkin(Color(0xff2f7f73), WordMotif.tiles, _sand),
  'oyun-kelime-merdiveni': WordSkin(Color(0xff5d7b3a), WordMotif.steps, _sage),
  'oyun-kelime-sudoku': WordSkin(Color(0xff3f7f8c), WordMotif.plus, _ice),
  'oyun-kelime-tahmini-dort': WordSkin(Color(0xff3f9a8a), WordMotif.dots, _mint),
  'oyun-kelime-tahmini-alti': WordSkin(Color(0xff4f7f9a), WordMotif.tiles, _sky),
  'oyun-kelime-tahmini-yedi': WordSkin(Color(0xff8a6fb0), WordMotif.tiles, _lavender),
  'oyun-kelime-tahmini-sekiz': WordSkin(Color(0xffa0705a), WordMotif.bricks, _sand),
  'oyun-kelime-tahmini-ikili': WordSkin(Color(0xff3f8fbf), WordMotif.rings, _sky),
  'oyun-kelime-tahmini-dortlu': WordSkin(Color(0xffb0607a), WordMotif.plus, _blush),
  'oyun-kelime-tahmini-sekizli': WordSkin(Color(0xffc08a30), WordMotif.honeycomb, _gold),
  'oyun-kelime-tahmini-zor': WordSkin(Color(0xff7a3f4f), WordMotif.diagonal, _pearl),
  'oyun-kelime-turetme': WordSkin(Color(0xffd9822b), WordMotif.sparkles, _lemon),
  'oyun-kelime-yapbozu': WordSkin(Color(0xffa35c8e), WordMotif.tiles, _blush),
  'oyun-kelime-yigini': WordSkin(Color(0xffb5523b), WordMotif.bricks, _peach),
  'oyun-kelime-zinciri': WordSkin(Color(0xff8a6d3b), WordMotif.rings, _sand),
  'oyun-klavye-hiz-oyunu': WordSkin(Color(0xff3d9970), WordMotif.diagonal, _mint),
  'oyun-kriptogram': WordSkin(Color(0xff374a67), WordMotif.plus, _pearl),
  'oyun-petege-harf': WordSkin(Color(0xffe0a93e), WordMotif.honeycomb, _lemon),
  'oyun-sifreli-bulmaca': WordSkin(Color(0xff46637f), WordMotif.grid, _ice),
  'oyun-ters-kelime-anagram-yarisi': WordSkin(Color(0xffd1603d), WordMotif.chevrons, _peach),
};

/// Oyunun kimliği; tabloda yoksa kimlikten türetilir (her oyun yine farklı).
WordSkin skinFor(String gameId) {
  final hit = kWordSkins[gameId];
  if (hit != null) return hit;
  var h = 0;
  for (final c in gameId.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  const mats = [kPaperTiles, _gold, _mint, _sky, _blush, _lavender, _sand, _ice, _peach, _sage, _pearl, _lemon];
  return WordSkin(HSLColor.fromAHSL(1, (h % 360).toDouble(), 0.55, 0.45).toColor(), WordMotif.values[h % WordMotif.values.length],
      mats[(h ~/ 7) % mats.length]);
}

/// Etkin oyunun taş malzemesi (aynı anda tek oyun oynanır; [WColors] okur).
WordTileMaterial currentTiles = kPaperTiles;

/// Oyun alanı zemini: oyunun tonunda koyu geçiş ve ince desen.
class WordBackdrop extends StatelessWidget {
  final WordSkin skin;
  final Widget child;
  const WordBackdrop({super.key, required this.skin, required this.child});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: skin.backdrop),
        ),
        child: CustomPaint(painter: _MotifPainter(skin.motif, skin.ink), child: child),
      );
}

class _MotifPainter extends CustomPainter {
  final WordMotif motif;
  final Color color;
  const _MotifPainter(this.motif, this.color);

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final f = Paint()..color = color;
    const g = 28.0;
    switch (motif) {
      case WordMotif.grid:
        for (var x = 0.0; x < s.width; x += g) {
          c.drawLine(Offset(x, 0), Offset(x, s.height), p);
        }
        for (var y = 0.0; y < s.height; y += g) {
          c.drawLine(Offset(0, y), Offset(s.width, y), p);
        }
      case WordMotif.dots:
        for (var y = g / 2; y < s.height; y += g) {
          for (var x = g / 2; x < s.width; x += g) {
            c.drawCircle(Offset(x, y), 2.2, f);
          }
        }
      case WordMotif.diagonal:
        for (var x = -s.height; x < s.width; x += g * 0.8) {
          c.drawLine(Offset(x, s.height), Offset(x + s.height, 0), p);
        }
      case WordMotif.honeycomb:
        const r = 18.0;
        final w = r * math.sqrt(3);
        var row = 0;
        for (var y = 0.0; y < s.height + r; y += r * 1.5, row++) {
          for (var x = row.isOdd ? w / 2 : 0.0; x < s.width + w; x += w) {
            final path = Path();
            for (var k = 0; k < 6; k++) {
              final a = math.pi / 6 + k * math.pi / 3;
              final pt = Offset(x + r * math.cos(a), y + r * math.sin(a));
              if (k == 0) {
                path.moveTo(pt.dx, pt.dy);
              } else {
                path.lineTo(pt.dx, pt.dy);
              }
            }
            c.drawPath(path..close(), p);
          }
        }
      case WordMotif.waves:
        for (var y = 0.0; y < s.height; y += g) {
          final path = Path()..moveTo(0, y);
          for (var x = 0.0; x <= s.width; x += 8) {
            path.lineTo(x, y + 5 * math.sin(x / 18));
          }
          c.drawPath(path, p);
        }
      case WordMotif.tiles:
        for (var y = 8.0; y < s.height; y += g * 1.4) {
          for (var x = 8.0; x < s.width; x += g * 1.4) {
            c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, g * 0.9, g * 0.9), const Radius.circular(5)), p);
          }
        }
      case WordMotif.rings:
        final o = Offset(s.width * 0.85, s.height * 0.12);
        for (var r = 30.0; r < s.longestSide * 1.3; r += 34) {
          c.drawCircle(o, r, p);
        }
      case WordMotif.chevrons:
        for (var y = 0.0; y < s.height; y += g) {
          final path = Path()..moveTo(0, y);
          var up = true;
          for (var x = 0.0; x <= s.width + g; x += g / 2) {
            path.lineTo(x, y + (up ? -7 : 7));
            up = !up;
          }
          c.drawPath(path, p);
        }
      case WordMotif.plus:
        for (var y = g / 2; y < s.height; y += g * 1.2) {
          for (var x = g / 2; x < s.width; x += g * 1.2) {
            c.drawLine(Offset(x - 5, y), Offset(x + 5, y), p);
            c.drawLine(Offset(x, y - 5), Offset(x, y + 5), p);
          }
        }
      case WordMotif.sparkles:
        final r = math.Random(7);
        for (var i = 0; i < (s.width * s.height / 2600).clamp(20, 400); i++) {
          final o = Offset(r.nextDouble() * s.width, r.nextDouble() * s.height);
          final k = 3 + r.nextDouble() * 5;
          final path = Path()
            ..moveTo(o.dx, o.dy - k)
            ..quadraticBezierTo(o.dx, o.dy, o.dx + k, o.dy)
            ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy + k)
            ..quadraticBezierTo(o.dx, o.dy, o.dx - k, o.dy)
            ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy - k);
          c.drawPath(path, f);
        }
      case WordMotif.bricks:
        var row = 0;
        for (var y = 0.0; y < s.height; y += g * 0.7, row++) {
          c.drawLine(Offset(0, y), Offset(s.width, y), p);
          for (var x = row.isOdd ? g : 0.0; x < s.width; x += g * 2) {
            c.drawLine(Offset(x, y), Offset(x, y + g * 0.7), p);
          }
        }
      case WordMotif.steps:
        for (var k = -s.height; k < s.width; k += g * 2.2) {
          final path = Path()..moveTo(k, s.height);
          var x = k, y = s.height;
          while (y > 0) {
            x += g * 0.7;
            path.lineTo(x, y);
            y -= g * 0.7;
            path.lineTo(x, y);
          }
          c.drawPath(path, p);
        }
    }
  }

  @override
  bool shouldRepaint(covariant _MotifPainter old) => old.motif != motif || old.color != color;
}
