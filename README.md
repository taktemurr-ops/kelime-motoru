# kelime-motoru

Kelime ailesinin ortak motoru (Flutter). 30 kelime oyunu ve 8 çeşitlik tahmin paketi bu motoru kullanır; her oyun kendi deposundadır, hepsi **Kelime Oyunları** merkez uygulamasında ([merkez-kelime-oyunlari](https://github.com/taktemurr-ops/merkez-kelime-oyunlari)) toplanır.

- **33 içerik dili**: 27 harf dili (tr, en, de, es, fr, it, pt, nl, sv, da, nb, pl, cs, ro, hu, ru, uk, el, fi, id, ms, fil, ar, fa, he, ur, ja) ve 6 taş dili (vi, ko, zh, hi, bn, th). Her oyun oyuncunun dilinde açılır; kelime dili oyunda ayrıca seçilebilir.
- **İpuçlu oyunlar** (çengel, kare bulmaca, akrostiş, atasözü, kriptogram, eş/zıt anlam, gruplama): 33 dilde; ipuçları stüdyonun kendi yazdığı metinlerdir (taş dillerinde kategori ve eş/zıt anlam içeriğinden ek ipuçları üretilir).
- **Bölümler**: her oyunda 100.000 bölüm; deterministik üretim + kural denetimi (`WordKind.check`).
- **Türler**: kelime avı, çengel/kare/şifreli bulmaca, kelime tahmini (tekli, çoklu tahta, zor mod), harf çarkı, kelime yığını, harf peteği, harf ızgarası, kelime blokları, yapboz, eksik harfler, kelime kafesi, kelime sudoku, merdiven, zincir, yaprak tahmini, harf kaydırma, hızlı klavye, düşen harfler, anagram yarışı, doğru yazım, atasözü, eş/zıt, gruplama, akrostiş, kriptogram, kelime tahtası ve kelime düellosu (rakibe karşı), harf ve sayı yarışı.

Kelime listeleri `tool/build_words.py` ile üretilir; lisans bilgisi için [NOTICE.md](NOTICE.md).

## Taş dilleri (vi, ko, zh, hi, bn, th)

Bu yazılarda tek harf taşı anlamlı değildir; kelimeler **taş** dizisidir (`Lexicon.tiled`). Her taş tek bir UTF-16 birimiyle saklanır (Çince karakter ve Hangıl hecesi kendisiyle; Vietnamca hece, akşara ve Tay hecesi Özel Kullanım Alanı kodlarıyla), böylece bütün türlerin harf mantığı taşlar üzerinde aynen çalışır; ekrana `up`/`upCh` taşın yazısını verir.

| Dil | Taş | Klavyeli türler |
| --- | --- | --- |
| zh | karakter (2–4 karakterli kelimeler, 4'lü deyimler/成语) | aday taş havuzu; ipucundan sonra pinyin |
| ko | hece (anagram, ızgara, kurma, zincir/끝말잇기, bulmaca) | **jamo**: tahmin, adam asmaca, merdiven ve klavye hızı 두벌식 klavyeyle jamo jamo oynanır, ekranda hecelere birleşir |
| vi | hece, ses tonuyla (học ≠ hóc) | taş havuzu; şaşırtmacalar aynı hecenin öbür tonlarıdır |
| hi, bn | akşara (bitişik ünsüzler tek taş: क्ष, त्रि) | taş havuzu |
| th | Tay hecesi | taş havuzu |

Klavye yerine **taş havuzu** (`Lexicon.keyPool`): bölümün gerektirdiği taşlar + benzer taşlardan şaşırtmacalar (Vietnamcada ton, Çincede aynı okunuş, Hint yazılarında sesli işareti, Taycada ton işareti, Korecede aynı ilk ünsüz). Kelime boyları `Lexicon.fit` ile taş sayısına çevrilir.

Taş dillerinde türlerin en yakın anlamlı karşılıkları:
- **Kelime tahmini**: Çincede dört karakterli deyim (汉兜 benzeri), öbürlerinde 2–4 taş; Korecede jamo kutuları (꼬들 benzeri).
- **Harf çarkı / yığın / düello / harf-sayı**: raf tek kelimeden değil, birkaç sık kelimenin taşlarından kurulur; "tam kelime" hedefi yerine en uzun kelimeler.
- **Harf peteği**: yedi taş, en az iki taşlı kelimeler; pangram yerine en çok farklı taş kullanan kelimeler yıldızlıdır.
- **Harf ızgarası**: ızgaraya önce sık kelimeler komşu yollar halinde yerleştirilir.
- **Kelime sudoku**: 6'lı/9'lu bulmacada ilk satır art arda iki/üç üç-taşlı kelimedir.
- **Kelime kafesi**: 2×2 ya da 3×3 taş karesi. **Kare bulmaca**: en az dört kelime (ipucu kutulu ızgarada kesişme seyrek).
- **Doğru yazım**: yanlış seçenekler benzer taşla değişir (ton, 错别字, kısa/uzun sesli).
- **Kriptogram**: şifre taş düzeyindedir (her hece/karakter/akşara bir numara).
- **Eksik harfler**: Çincede deyim (成语) boşluk doldurma.

Taş dili listeleri `tool/build_tiles.py` ile üretilir.
