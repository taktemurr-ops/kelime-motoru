import 'package:flutter/material.dart';
import 'package:studio_core/core/rng.dart';

import '../texts.dart';
import '../ui.dart';
import '../words.dart';

/// [pool] harfleriyle yazılabilen kelimeler (listenin ilk [limit] kelimesinden).
List<String> spellable(Lexicon lx, Map<String, int> pool, {int minLen = 3, int? limit, String? must}) {
  final out = <String>[];
  final n = limit == null || limit > lx.words.length ? lx.words.length : limit;
  for (var i = 0; i < n; i++) {
    final w = lx.words[i];
    if (w.length < minLen) continue;
    if (must != null && !w.contains(must)) continue;
    if (canSpell(w, pool)) out.add(w);
  }
  return out;
}

/// Harfleri karıştır (asıl sırayla aynı kalmasın).
List<String> scramble(String w, SeededRandom r) {
  final l = w.split('');
  for (var t = 0; t < 8; t++) {
    r.shuffle(l);
    if (l.join() != w) break;
  }
  return l;
}

/// Harf taşlarından kelime kurma paneli.
class LetterPad extends StatelessWidget {
  final Lexicon lx;
  final List<String> letters;
  final List<int> picked;
  final void Function(int i) onPick;
  final VoidCallback onBack;
  final VoidCallback onClear;
  final VoidCallback? onShuffle;
  final VoidCallback onSubmit;
  final String lang;
  final Map<String, int>? values;
  const LetterPad({
    super.key,
    required this.lx,
    required this.letters,
    required this.picked,
    required this.onPick,
    required this.onBack,
    required this.onClear,
    required this.onSubmit,
    required this.lang,
    this.onShuffle,
    this.values,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final n = letters.length;
      final t = ((box.maxWidth - 24) / n - 6).clamp(30.0, 58.0);
      final word = picked.map((i) => letters[i]).join();
      return Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(12)),
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(word.isEmpty ? ' ' : lx.up(word),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 3, color: WColors.ink)),
            ),
          ),
        ),
        Wrap(alignment: WrapAlignment.center, spacing: 6, runSpacing: 6, children: [
          for (var i = 0; i < n; i++)
            Opacity(
              opacity: picked.contains(i) ? 0.25 : 1,
              child: LetterTile(
                letter: lx.upCh(letters[i]),
                size: t,
                value: values?[letters[i]],
                onTap: picked.contains(i) ? null : () => onPick(i),
              ),
            ),
        ]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (onShuffle != null) IconButton.filledTonal(tooltip: kt(lang, 'shuffle'), onPressed: onShuffle, icon: const Icon(Icons.shuffle)),
          IconButton.filledTonal(tooltip: kt(lang, 'clear'), onPressed: onClear, icon: const Icon(Icons.clear)),
          IconButton.filledTonal(tooltip: kt(lang, 'undo'), onPressed: onBack, icon: const Icon(Icons.backspace_outlined)),
          BigButton(label: kt(lang, 'submit'), icon: Icons.keyboard_return, onPressed: onSubmit),
        ]),
      ]);
    });
  }
}

/// Kelime yuvaları (uzunluğa göre, bulunanlar açık).
class WordSlots extends StatelessWidget {
  final Lexicon lx;
  final List<String> targets;
  final Set<String> found;
  final Map<String, Set<int>> revealed;
  const WordSlots({super.key, required this.lx, required this.targets, required this.found, this.revealed = const {}});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final longest = targets.fold<int>(3, (a, w) => w.length > a ? w.length : a);
      final cols = box.maxWidth > 520 ? 3 : 2;
      final t = ((box.maxWidth / cols - 16) / longest - 2).clamp(12.0, 30.0);
      return Wrap(alignment: WrapAlignment.center, spacing: 14, runSpacing: 6, children: [
        for (final w in targets)
          Row(mainAxisSize: MainAxisSize.min, children: [
            for (var i = 0; i < w.length; i++)
              Padding(
                padding: const EdgeInsets.all(1),
                child: LetterTile(
                  letter: found.contains(w) || (revealed[w]?.contains(i) ?? false) ? lx.upCh(w[i]) : '',
                  size: t,
                  fill: found.contains(w) ? WColors.hit : (revealed[w]?.contains(i) ?? false ? WColors.soft : WColors.paper),
                  raised: false,
                ),
              ),
          ]),
      ]);
    });
  }
}
