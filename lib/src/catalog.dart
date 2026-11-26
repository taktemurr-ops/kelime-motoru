import 'core.dart';
import 'kinds/bank.dart';
import 'kinds/board.dart';
import 'kinds/cross.dart';
import 'kinds/duel.dart';
import 'kinds/ek4.dart';
import 'kinds/fill.dart';
import 'kinds/guess.dart';
import 'kinds/motion.dart';
import 'kinds/paths.dart';
import 'kinds/quiz.dart';
import 'kinds/search.dart';
import 'kinds/theme.dart';
import 'kinds/turns.dart';

/// Kelime oyunu türleri (tür kimliği → tür).
const Map<String, WordKind> kWordKinds = {
  'kelime-avi': SearchKind(),
  'cengel-bulmaca': CrossKind('cengel-bulmaca', 0),
  'tahmin': GuessKind('tahmin'),
  'kelime-turetme': BankKind('kelime-turetme', 0),
  'kelime-yigini': BankKind('kelime-yigini', 1),
  'adam-asmaca': PetalKind(),
  'kelime-kurma': BoardKind(),
  'harf-izgarasi': BoggleKind(),
  'kriptogram': CipherKind(),
  'kelime-zinciri': ChainKind(),
  'gruplama': GroupsKind(),
  'harf-kaydirma': SlideKind(),
  'es-zit': PairsKind(),
  'kelime-bloklari': BlocksKind(),
  'klavye-hizi': TypingKind('klavye-hizi'),
  'kelime-merdiveni': LadderKind(),
  'petek': BankKind('petek', 2),
  'sifreli-bulmaca': CrossKind('sifreli-bulmaca', 2),
  'kare-bulmaca': CrossKind('kare-bulmaca', 1),
  'akrostis': AcrosticKind(),
  'kelime-sudoku': WordokuKind(),
  'atasozu': ProverbKind(),
  'heceleme': SpellKind(),
  'harf-sayi': LettersNumbersKind(),
  'duello': DuelKind(),
  'bosluk-doldurma': MissingKind(),
  'kelime-yapbozu': JigsawKind(),
  'anagram': AnagramKind(),
  'kelime-kafesi': SquareKind(),
  'dusen-harfler': TypingKind('dusen-harfler', falling: true),
  // 4. tur
  'dort-resim': PicsKind(),
  'bes-ipucu': CluesKind(),
  'harf-kutusu': BoxKind(),
  'tema-avi': ThemeKind(),
  // Kelime tahmini çeşit paketi
  'tahmin-4': GuessKind('tahmin-4', len: 4),
  'tahmin-6': GuessKind('tahmin-6', len: 6),
  'tahmin-7': GuessKind('tahmin-7', len: 7),
  'tahmin-8': GuessKind('tahmin-8', len: 8),
  'tahmin-ikili': GuessKind('tahmin-ikili', boards: 2),
  'tahmin-dortlu': GuessKind('tahmin-dortlu', boards: 4),
  'tahmin-sekizli': GuessKind('tahmin-sekizli', boards: 8),
  'tahmin-zor': GuessKind('tahmin-zor', hard: true),
};

/// Oyun deposu için kurallar.
WordRules wordRulesFor(String gameId, String kind) => wordRules(gameId, kWordKinds[kind]!);
