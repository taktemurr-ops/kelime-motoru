// Eş anlamlı ve zıt anlamlı kelime çiftleri (stüdyonun kendi listesi).
const List<String> kSynonymsTr = [
  'siyah|kara', 'beyaz|ak', 'kırmızı|al', 'yaşlı|ihtiyar', 'genç|toy', 'hediye|armağan', 'cevap|yanıt', 'soru|sual',
  'okul|mektep', 'öğrenci|talebe', 'öğretmen|muallim', 'doktor|hekim', 'misafir|konuk', 'yıl|sene', 'ülke|yurt', 'şehir|kent',
  'zengin|varlıklı', 'fakir|yoksul', 'güzel|hoş', 'çabuk|hızlı', 'kolay|basit', 'zor|güç', 'akıl|us', 'fikir|düşünce',
  'ses|seda', 'sözcük|kelime', 'cümle|tümce', 'örnek|misal', 'sınav|imtihan', 'neden|sebep', 'amaç|hedef', 'istek|dilek',
  'barış|sulh', 'savaş|harp', 'tehlike|risk', 'kuvvet|güç', 'ilk|birinci', 'son|nihayet', 'özgür|hür',
  'dost|arkadaş', 'düşman|hasım', 'ev|konut', 'deniz|derya', 'ırmak|nehir', 'orman|koru',
  'pazar|çarşı', 'eş|zevce', 'anne|ana', 'çocuk|evlat', 'vatan|yurt', 'millet|ulus',
  'tarih|geçmiş', 'gelecek|istikbal', 'kural|ilke', 'hata|yanlış', 'doğru|gerçek', 'yalan|uydurma', 'gizli|saklı',
  'sessiz|suskun', 'neşeli|şen', 'üzgün|kederli', 'korku|dehşet', 'cesur|yürekli', 'yorgun|bitkin', 'hasta|rahatsız', 'sağlık|esenlik',
  'bilgi|malumat', 'bilim|ilim', 'yazar|müellif', 'kitap|eser', 'resim|tablo', 'hikâye|öykü', 'şiir|nazım', 'müzik|musiki',
];

const List<String> kAntonymsTr = [
  'büyük|küçük', 'uzun|kısa', 'sıcak|soğuk', 'yeni|eski', 'açık|kapalı', 'temiz|kirli', 'hızlı|yavaş', 'güzel|çirkin',
  'zengin|fakir', 'genç|yaşlı', 'kolay|zor', 'ağır|hafif', 'derin|sığ', 'geniş|dar', 'yüksek|alçak', 'iyi|kötü',
  'doğru|yanlış', 'gece|gündüz', 'sabah|akşam', 'yaz|kış', 'ön|arka', 'sağ|sol', 'alt|üst', 'iç|dış',
  'yakın|uzak', 'erken|geç', 'dolu|boş', 'ıslak|kuru', 'tatlı|acı', 'sert|yumuşak', 'aydınlık|karanlık', 'mutlu|mutsuz',
  'gelmek|gitmek', 'almak|vermek', 'açmak|kapamak', 'girmek|çıkmak', 'başlamak|bitirmek', 'gülmek|ağlamak', 'kazanmak|kaybetmek', 'sevgi|nefret',
  'var|yok', 'evet|hayır', 'az|çok', 'ince|kalın', 'düz|eğri', 'canlı|cansız', 'cesur|korkak', 'çalışkan|tembel',
  'savaş|barış', 'dost|düşman', 'soru|cevap', 'giriş|çıkış', 'başlangıç|son', 'kuzey|güney', 'doğu|batı', 'yer|gök',
  'ak|kara', 'siyah|beyaz', 'hasta|sağlıklı', 'tok|aç', 'ucuz|pahalı', 'neşeli|üzgün', 'sessiz|gürültülü', 'aşağı|yukarı',
];

const List<String> kSynonymsEn = [
  'big|large', 'small|little', 'fast|quick', 'happy|glad', 'sad|unhappy', 'begin|start', 'end|finish', 'smart|clever',
  'hard|difficult', 'easy|simple', 'gift|present', 'answer|reply', 'shout|yell', 'close|shut', 'buy|purchase', 'help|assist',
  'rich|wealthy', 'poor|needy', 'pretty|lovely', 'calm|peaceful', 'brave|bold', 'tired|weary', 'angry|mad', 'scared|afraid',
  'friend|pal', 'house|home', 'road|street', 'stone|rock', 'cup|mug', 'child|kid', 'mother|mom', 'father|dad',
  'look|see', 'speak|talk', 'walk|stroll', 'jump|leap', 'cry|weep', 'laugh|giggle', 'think|ponder', 'choose|pick',
  'big|huge', 'tiny|minute', 'wet|damp', 'cold|chilly', 'hot|warm', 'loud|noisy', 'quiet|silent', 'dark|dim',
  'idea|notion', 'job|work', 'rule|law', 'error|mistake', 'reason|cause', 'goal|aim', 'wish|desire', 'fear|dread',
  'true|correct', 'false|wrong', 'old|aged', 'new|fresh', 'odd|strange', 'nice|kind', 'sick|ill', 'well|healthy',
  'world|earth', 'sea|ocean', 'hill|mound', 'forest|woods', 'shop|store', 'trip|journey', 'story|tale', 'picture|image',
  'fix|repair', 'build|make', 'keep|hold', 'hurry|rush', 'hide|conceal', 'gather|collect', 'show|display', 'stop|halt',
];

const List<String> kAntonymsEn = [
  'big|small', 'long|short', 'hot|cold', 'new|old', 'open|closed', 'clean|dirty', 'fast|slow', 'rich|poor',
  'young|old', 'easy|hard', 'heavy|light', 'deep|shallow', 'wide|narrow', 'high|low', 'good|bad', 'right|wrong',
  'night|day', 'early|late', 'full|empty', 'wet|dry', 'sweet|bitter', 'soft|hard', 'light|dark', 'happy|sad',
  'come|go', 'give|take', 'enter|exit', 'start|finish', 'laugh|cry', 'win|lose', 'love|hate', 'buy|sell',
  'yes|no', 'few|many', 'thin|thick', 'alive|dead', 'brave|afraid', 'busy|idle', 'war|peace', 'friend|enemy',
  'question|answer', 'north|south', 'east|west', 'up|down', 'left|right', 'inside|outside', 'above|below', 'front|back',
  'near|far', 'cheap|expensive', 'loud|quiet', 'strong|weak', 'sharp|blunt', 'tall|short', 'true|false', 'first|last',
  'push|pull', 'arrive|leave', 'remember|forget', 'accept|refuse', 'always|never', 'before|after', 'summer|winter', 'sunrise|sunset',
];
