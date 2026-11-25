/// Kelime ailesinin ortak motoru: 27 dilde açık lisanslı kelime listeleri,
/// 33 dilde atasözü, kategori ve eş/zıt anlam içeriği, bölüm üretimi,
/// doğrulama ve oyun ekranları.
library;

export 'src/catalog.dart';
export 'src/core.dart' show WordStage, WordRules, WordKind, WLevel, WPuzzle, WordNet, realize, wordRules;
export 'src/kinds/board.dart' show BoardPuzzle;
export 'src/texts.dart';
export 'src/words.dart' show Lexicon, kWordLangs, kQuizOnlyLangs, kAllWordLangs, kWordLangNames, wordLangFor;
