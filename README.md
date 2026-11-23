# kelime-motoru

Kelime ailesinin ortak motoru (Flutter). 30 kelime oyunu ve 8 çeşitlik tahmin paketi bu motoru kullanır; her oyun kendi deposundadır, hepsi **Kelime Oyunları** merkez uygulamasında ([merkez-kelime-oyunlari](https://github.com/taktemurr-ops/merkez-kelime-oyunlari)) toplanır.

- **18 içerik dili**: tr, en, de, es, fr, it, pt, nl, sv, da, nb, pl, cs, ro, hu, ru, uk, el. Arayüz 33 dildedir; kelime dili oyunda ayrıca seçilebilir.
- **İpuçlu oyunlar** (çengel, kare bulmaca, akrostiş, atasözü, kriptogram, eş/zıt anlam, gruplama): Türkçe ve İngilizce; ipuçları stüdyonun kendi yazdığı metinlerdir.
- **Bölümler**: her oyunda 100.000 bölüm; deterministik üretim + kural denetimi (`WordKind.check`).
- **Türler**: kelime avı, çengel/kare/şifreli bulmaca, kelime tahmini (tekli, çoklu tahta, zor mod), harf çarkı, kelime yığını, harf peteği, harf ızgarası, kelime blokları, yapboz, eksik harfler, kelime kafesi, kelime sudoku, merdiven, zincir, yaprak tahmini, harf kaydırma, hızlı klavye, düşen harfler, anagram yarışı, doğru yazım, atasözü, eş/zıt, gruplama, akrostiş, kriptogram, kelime tahtası ve kelime düellosu (rakibe karşı), harf ve sayı yarışı.

Kelime listeleri `tool/build_words.py` ile üretilir; lisans bilgisi için [NOTICE.md](NOTICE.md).
