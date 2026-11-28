import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'core.dart';
import 'identity.dart';
import 'studio_chrome.dart';
import 'texts.dart';
import 'words.dart';

/// Kelime ailesinin özgün renkleri.
class WColors {
  /// Kâğıt, taş yüzü ve taş kenarı oyunun malzemesinden gelir (bkz. [skinFor]).
  static Color get paper => currentTiles.paper;
  static const ink = Color(0xFF243142);
  static Color get tile => currentTiles.face;
  static Color get tileEdge => currentTiles.edge;
  static const hit = Color(0xFF4F9A6E);
  static const near = Color(0xFFD9A441);
  static const miss = Color(0xFF7B8494);
  static const accent = Color(0xFF3E6FB0);
  static const warm = Color(0xFFC8553D);
  static const soft = Color(0xFFE8DFD0);

  /// Zemin üstünde en okunur yazı rengi: beyaz ya da koyu mürekkep.
  static Color on(Color bg) {
    final l = bg.computeLuminance();
    final white = 1.05 / (l + 0.05);
    final ink = (l + 0.05) / (WColors.ink.computeLuminance() + 0.05);
    return white >= ink ? Colors.white : WColors.ink;
  }

  /// Klavye tuşu ve taş havuzu zemini (onaylı koyu tasarım).
  static Color key(BuildContext context) => Color.lerp(StudioLook.of(context).card, Colors.white, 0.10)!;
  static const List<Color> marks = [
    Color(0xFF5B8FD1), Color(0xFFE07A5F), Color(0xFF81B29A), Color(0xFFF2CC8F),
    Color(0xFFB08BBB), Color(0xFF6CC3C3), Color(0xFFE5989B), Color(0xFF9DB469),
  ];
}

/// Saniye sayacı.
mixin SecondsTicker<T extends StatefulWidget> on State<T> {
  int seconds = 0;
  bool ended = false;
  Timer? _ticker;

  void startTicker([int from = 0]) {
    seconds = from;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!ended && mounted) setState(() => seconds++);
      onTick();
    });
  }

  /// Her saniye (süreli oyunlar için).
  void onTick() {}

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String clock([int? s]) {
    final v = s ?? seconds;
    return '${v ~/ 60}:${(v % 60).toString().padLeft(2, '0')}';
  }
}

/// Kısa bildirim satırı.
mixin Flash<T extends StatefulWidget> on State<T> {
  String flashText = '';
  Timer? _flashTimer;

  void flash(String s) {
    _flashTimer?.cancel();
    setState(() => flashText = s);
    _flashTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => flashText = '');
    });
  }

  Widget flashLine() => SizedBox(
        height: 26,
        child: AnimatedOpacity(
          opacity: flashText.isEmpty ? 0 : 1,
          duration: const Duration(milliseconds: 160),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(flashText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      );
}

/// Üst çubuk: durum, kelime dili ve düğmeler.
class WordBar extends StatelessWidget {
  final WordPlay play;
  final String left;
  final String status;
  final VoidCallback? onHint;
  final List<Widget> actions;
  const WordBar({super.key, required this.play, this.left = '', this.status = '', this.onHint, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    final look = StudioLook.of(context);
    final lang = play.lang;
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      padding: const EdgeInsetsDirectional.only(start: 12),
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: look.accent.withValues(alpha: 0.45), width: 1.2),
      ),
      child: Row(children: [
        if (left.isNotEmpty)
          Flexible(
            child: Text(left,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w900, color: look.number)),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(status,
                maxLines: 1, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, color: kStudioSubtle)),
          ),
        ),
        if (play.langs.length > 1)
          Tooltip(
            message: kt(lang, 'wordLang'),
            child: ActionChip(
              visualDensity: VisualDensity.compact,
              label: Text(play.wl.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700)),
              avatar: const Icon(Icons.translate, size: 16),
              onPressed: () => pickWordLang(context, play),
            ),
          ),
        ...actions,
        if (onHint != null)
          IconButton(
            tooltip: kt(lang, 'hint'),
            visualDensity: VisualDensity.compact,
            onPressed: onHint,
            icon: const Icon(Icons.lightbulb_rounded, color: StudioLook.gold),
          ),
      ]),
    );
  }
}

Future<void> pickWordLang(BuildContext context, WordPlay play) async {
  final l = await showDialog<String>(
    context: context,
    builder: (c) => SimpleDialog(
      title: Text(kt(play.lang, 'wordLang')),
      children: [
        for (final code in play.langs)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(c, code),
            child: Row(children: [
              Icon(code == play.wl ? Icons.radio_button_checked : Icons.radio_button_off,
                  size: 18, color: code == play.wl ? StudioLook.of(c).accent : Colors.white70),
              const SizedBox(width: 10),
              Text(kWordLangNames[code] ?? code),
            ]),
          ),
      ],
    ),
  );
  if (l != null) play.switchLang(l);
}

/// Harf taşı.
class LetterTile extends StatelessWidget {
  final String letter;
  final double size;
  final Color? fill;
  final Color? textColor;
  final bool raised;
  final int? value;
  final VoidCallback? onTap;
  final bool selected;
  const LetterTile({
    super.key,
    required this.letter,
    this.size = 44,
    this.fill,
    this.textColor,
    this.raised = true,
    this.value,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = fill ?? WColors.tile;
    final fg = textColor ?? WColors.on(bg);
    final box = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.18),
        border: Border.all(color: selected ? StudioLook.of(context).accent : (fill == null ? WColors.tileEdge : bg), width: selected ? 3 : 1.2),
        boxShadow: raised ? [BoxShadow(color: Colors.black.withValues(alpha: 0.18), offset: Offset(0, size * 0.06), blurRadius: 2)] : null,
      ),
      child: Stack(children: [
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size * 0.07),
            // Taş dillerinde taş birkaç harf olabilir (Vietnamca hece, Tay hecesi): sığdır.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(letter, style: TextStyle(fontSize: size * 0.52, fontWeight: FontWeight.w800, color: fg, height: 1.0)),
            ),
          ),
        ),
        if (value != null)
          Positioned(
            right: size * 0.08,
            bottom: size * 0.04,
            child: Text('$value', style: TextStyle(fontSize: size * 0.22, fontWeight: FontWeight.w700, color: fg.withValues(alpha: 0.75))),
          ),
      ]),
    );
    if (onTap == null) return box;
    return GestureDetector(onTap: onTap, child: box);
  }
}

/// Ekran klavyesi (dilin alfabesiyle). Taş dillerinde ([Lexicon.tiled])
/// klavye yerine [pool] taş havuzu gösterilir: bölümün gerektirdiği taşlar ve
/// şaşırtmacalar (bkz. [Lexicon.keyPool]).
class WordKeyboard extends StatelessWidget {
  final Lexicon lx;
  final void Function(String ch) onKey;
  final VoidCallback onEnter;
  final VoidCallback onBack;
  final Map<String, Color> colors;
  final bool showEnter;
  final List<String>? pool;
  const WordKeyboard({
    super.key,
    required this.lx,
    required this.onKey,
    required this.onEnter,
    required this.onBack,
    this.colors = const {},
    this.showEnter = true,
    this.pool,
  });

  @override
  Widget build(BuildContext context) {
    if (lx.tiled) {
      return TilePool(
        lx: lx,
        tiles: pool ?? lx.letters.take(16).toList(),
        onKey: onKey,
        onEnter: showEnter ? onEnter : null,
        onBack: onBack,
        colors: colors,
      );
    }
    final rows = lx.keyboardRows();
    return LayoutBuilder(builder: (context, box) {
      final per = rows.first.length + 1;
      final kw = ((box.maxWidth - 8) / per - 4).clamp(18.0, 46.0);
      final keyBg = WColors.key(context);
      Widget key(String label, VoidCallback onTap, {Color? color, double w = 1, IconData? icon}) => Padding(
            padding: const EdgeInsets.all(2),
            child: Material(
              color: color ?? keyBg,
              borderRadius: BorderRadius.circular(7),
              child: InkWell(
                borderRadius: BorderRadius.circular(7),
                onTap: onTap,
                child: SizedBox(
                  width: kw * w,
                  height: kw * 1.25 > 50 ? 50.0 : kw * 1.25,
                  child: Center(
                    child: icon != null
                        ? Icon(icon, size: 20, color: WColors.on(color ?? keyBg))
                        : Text(label,
                            style: TextStyle(
                              fontSize: kw * 0.5,
                              fontWeight: FontWeight.w700,
                              color: WColors.on(color ?? keyBg),
                            )),
                  ),
                ),
              ),
            ),
          );
      return Column(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < rows.length; i++)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (final ch in rows[i]) key(lx.upCh(ch), () => onKey(ch), color: colors[ch]),
            if (i == rows.length - 1) key('', onBack, w: 1.4, icon: Icons.backspace_outlined),
          ]),
        if (showEnter)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            key('', onEnter, w: 3, icon: Icons.keyboard_return, color: WColors.near),
          ]),
      ]);
    });
  }
}

/// Taş havuzu: taş dillerinde klavyenin yerini alır. Her düğme bir taştır
/// (hece, karakter ya da akşara); geri al ve onay düğmeleri altta.
class TilePool extends StatelessWidget {
  final Lexicon lx;
  final List<String> tiles;
  final void Function(String ch) onKey;
  final VoidCallback? onEnter;
  final VoidCallback? onBack;
  final Map<String, Color> colors;
  const TilePool({
    super.key,
    required this.lx,
    required this.tiles,
    required this.onKey,
    this.onEnter,
    this.onBack,
    this.colors = const {},
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final longest = tiles.fold<int>(1, (a, t) => math.max(a, lx.upCh(t).runes.length));
      final per = longest > 4 ? 4 : (longest > 2 ? 5 : 6);
      final kw = ((box.maxWidth - 8) / per - 6).clamp(40.0, 96.0);
      final keyBg = WColors.key(context);
      Widget key(Widget child, VoidCallback? onTap, {Color? color, double w = 1}) => Padding(
            padding: const EdgeInsets.all(3),
            child: Material(
              color: color ?? keyBg,
              borderRadius: BorderRadius.circular(9),
              child: InkWell(
                borderRadius: BorderRadius.circular(9),
                onTap: onTap,
                child: SizedBox(width: kw * w, height: 46, child: Center(child: child)),
              ),
            ),
          );
      // Çok tahtalı tahminde havuz büyür: en çok ekranın üçte biri, gerisi kaydırılır.
      final maxH = MediaQuery.sizeOf(context).height * 0.3;
      return Column(mainAxisSize: MainAxisSize.min, children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH < 110 ? 110 : maxH),
          child: SingleChildScrollView(
            child: Wrap(alignment: WrapAlignment.center, children: [
              for (final t in tiles)
                key(
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(lx.upCh(t),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: WColors.on(colors[t] ?? keyBg),
                          )),
                    ),
                  ),
                  () => onKey(t),
                  color: colors[t],
                ),
            ]),
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (onBack != null) key(Icon(Icons.backspace_outlined, size: 20, color: WColors.on(keyBg)), onBack, w: 1.4),
          if (onEnter != null) key(Icon(Icons.keyboard_return, size: 20, color: WColors.on(WColors.near)), onEnter, w: 2, color: WColors.near),
        ]),
      ]);
    });
  }
}

/// Bulunan kelimeler şeridi.
class FoundWords extends StatelessWidget {
  final List<String> words;
  final Lexicon lx;
  final Set<String> highlight;
  const FoundWords({super.key, required this.words, required this.lx, this.highlight = const {}});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 6, runSpacing: 4, alignment: WrapAlignment.center, children: [
      for (final w in words)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: highlight.contains(w) ? WColors.near : Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: highlight.contains(w) ? WColors.near : Colors.white30),
          ),
          child: Text(lx.up(w),
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13, color: highlight.contains(w) ? WColors.ink : Colors.white)),
        ),
    ]);
  }
}

/// Yuvarlak çerçeveli kart.
class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(10)});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.26),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: StudioLook.of(context).accent.withValues(alpha: 0.40), width: 1.2),
        ),
        child: DefaultTextStyle.merge(style: const TextStyle(color: Colors.white), child: child),
      );
}

/// Basit büyük düğme.
class BigButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? color;
  const BigButton({super.key, required this.label, this.icon, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(4),
        child: StudioButton(
          expand: false,
          height: 48,
          fontSize: 16,
          tone: color == null ? StudioButtonTone.play : StudioButtonTone.gold,
          onPressed: onPressed,
          icon: icon ?? Icons.check_rounded,
          label: label,
        ),
      );
}

/// Yıldız: ipucu ve hataya göre.
int starsFor({int hints = 0, int mistakes = 0}) {
  final p = hints * 2 + mistakes;
  if (p == 0) return 3;
  if (p <= 3) return 2;
  return 1;
}
