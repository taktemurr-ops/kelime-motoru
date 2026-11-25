# Lisans bildirimi · License notice

- `lib/src/data/words_*.dart`: [FrequencyWords](https://github.com/hermitdave/FrequencyWords) (Hermit Dave, OpenSubtitles 2018) listelerinden türetilmiştir. Lisans: **CC BY-SA 4.0**. Türetilmiş listeler aynı lisansla paylaşılır.
- Uygunsuz kelime süzgeci: [LDNOOBW](https://github.com/LDNOOBW/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words), CC BY 4.0 (yalnızca üretimde kullanılır).
- Hunspell sözlükleri ([wooorm/dictionaries](https://github.com/wooorm/dictionaries)) yalnızca üretim sırasında süzgeç olarak kullanıldı; dağıtılmaz.
- Taş yazılı diller (`words_zh/ko/vi/hi/bn/th.dart`, `tool/build_tiles.py`):
  - zh: [jieba](https://github.com/fxsjy/jieba) sözlüğü (MIT; kelime, sıklık, sözcük türü — özel adlar ayıklandı), sıra wordfreq (CC BY-SA 4.0); pinyin [pypinyin](https://github.com/mozillazg/python-pinyin) (MIT).
  - ko, hi, bn: [wordfreq](https://github.com/rspeer/wordfreq) (veri CC BY-SA 4.0). hunspell-ko (GPL/LGPL/MPL) ile LibreOffice hi_IN ve bn_BD sözlükleri yalnızca üretimde süzgeç olarak kullanıldı; dağıtılmaz.
  - vi: [pyvi](https://github.com/trungtv/pyvi) kelime listesi (MIT) ve [UD Vietnamese-VTB](https://github.com/UniversalDependencies/UD_Vietnamese-VTB) (CC BY-SA 4.0).
  - th: [PyThaiNLP](https://github.com/PyThaiNLP/pythainlp) kelime listesi, TNC sıklıkları ve heceleme (derlem CC0, kod Apache-2.0); ad listeleri (CC BY-SA 4.0) yalnızca süzgeç.
  - Uygunsuz kelime: LDNOOBW (zh, ko, th) + elle eklenen listeler (vi, hi, bn ve hepsi için ek).
- İpuçları, atasözü seçkisi, kategoriler ve eş/zıt anlam çiftleri stüdyo tarafından yazılmıştır.
- Uygulama içinde bu bildirim "Lisanslar" sayfasında gösterilir (`registerWordLicenses`).
