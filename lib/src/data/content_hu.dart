// hu: kelime ailesinin ipucu, atasözü, kategori ve eş/zıt anlam içeriği.
// Stüdyonun kendi metinleri; atasözleri halk malıdır (kamu malı).

const List<String> kCluesHu = [
  'alma|Piros vagy zöld gyümölcs', 'kenyér|Kemencében sül', 'folyó|Medrében áramló víz', 'tenger|Nagy sós víz',
  'sziget|Vízzel körülvett föld', 'hegy|Nagyon magas domb', 'erdő|Sok fa együtt', 'sivatag|Száraz homokos vidék',
  'felhő|Az égen úszik', 'eső|A felhőkből hull', 'hó|Fehér téli pelyhek', 'nap|Az égen ragyogó csillagunk',
  'hold|A Föld kísérője', 'csillag|Éjjel ragyog', 'szél|Mozgó levegő', 'jég|Fagyott víz',
  'tűz|Lángok és hő', 'kő|Szikladarab', 'homok|A strandon van', 'virág|A kertben nyílik',
  'fa|Törzse és ágai vannak', 'levél|Az ágon lóg', 'gyökér|A növény alatt', 'kutya|Ugat',
  'macska|Nyávog', 'ló|Lovagolni lehet rajta', 'madár|Szárny és toll', 'hal|Úszik a vízben',
  'méh|Mézet készít', 'egér|Kis rágcsáló', 'tehén|Tejet ad', 'juh|Gyapjút ad',
  'kacsa|Hápogó madár', 'bagoly|Éjszakai madár', 'nyúl|Hosszú fülek', 'róka|Ravasz és vörös',
  'medve|Nagy erdei állat', 'oroszlán|Az állatok királya', 'ház|Itt lakunk', 'ajtó|Belépéskor nyitjuk',
  'ablak|Üveg a falban', 'tető|A ház tetején', 'fal|Elválasztja a szobákat', 'szék|Ülni lehet rajta',
  'asztal|Bútor az evéshez', 'ágy|Alváshoz', 'lámpa|Fényt ad', 'óra|Mutatja az időt',
  'könyv|Sok oldala van', 'levélpapír|Erre írunk levelet', 'ceruza|Íráshoz', 'iskola|Tanulás helye',
  'tanár|Gyerekeket tanít', 'orvos|Betegeket gyógyít', 'szakács|A konyhában dolgozik', 'kert|Virágok és ágyások',
  'utca|Út a városban', 'híd|A folyón át vezet', 'város|Sok ház és ember', 'falu|Kis település',
  'autó|Négy kerék', 'vonat|Síneken jár', 'hajó|A tengeren úszik', 'repülő|A levegőben száll',
  'bicikli|Két kerék és pedál', 'tej|Fehér ital', 'víz|Inni való', 'sajt|Tejből készül',
  'méz|Édes a méhektől', 'cukor|Édesít', 'só|Ízt ad', 'leves|Meleg étel',
  'torta|Édes ünnepre', 'tojás|A tyúk tojja', 'orr|Szagláshoz', 'szem|Látáshoz',
  'fül|Halláshoz', 'száj|Beszédhez', 'kéz|Öt ujj', 'láb|Járáshoz',
  'szív|Pumpálja a vért', 'fej|A test tetején', 'haj|A fejen nő', 'fog|Harapáshoz',
  'cipő|A lábon hordjuk', 'kalap|A fejen hordjuk', 'kabát|Meleg felsőruha', 'gyűrű|Ékszer az ujjon',
  'szín|Piros, kék vagy zöld', 'zene|Hangok és dalok', 'dal|Énekelni lehet', 'játék|Szórakoztató',
  'labda|Kerek játékszer', 'reggel|A nap kezdete', 'este|A nap vége', 'éjszaka|Sötét idő',
  'hét|Vasárnappal zárul', 'év|Tizenkét hónap', 'nyár|Meleg évszak', 'tél|Hideg évszak',
  'ősz|Hullanak a levelek', 'tavasz|Virágzás évszaka', 'barát|Kedves ember', 'család|Szülők és gyerekek',
  'gyerek|Kis ember', 'név|Így hívnak', 'pénz|Fizetéshez', 'piac|Vásárlás helye',
  'térkép|Mutatja az utat', 'álom|Képek alvás közben', 'fény|Világosságot ad', 'árnyék|Sötét mögötted',
];

const List<String> kProverbsHu = [
  'Gyakorlat teszi a mestert', 'Jobb későn mint soha', 'Aki korán kel aranyat lel', 'Ki mint vet úgy arat',
  'Lassan járj tovább érsz', 'Sok kicsi sokra megy', 'Ki keres az talál', 'Nem mind arany ami fénylik',
  'Addig üsd a vasat amíg meleg', 'Aki másnak vermet ás maga esik bele', 'Ajándék lónak ne nézd a fogát', 'Okos enged szamár szenved',
  'Amit ma megtehetsz ne halaszd holnapra', 'Lassú víz partot mos', 'Ahol sok a szakács ott sótlan a leves', 'Az alma nem esik messze a fájától',
  'Szegény embert még az ág is húzza', 'Nem a ruha teszi az embert', 'Kutyából nem lesz szalonna', 'A türelem rózsát terem',
  'Ugató kutya nem harap', 'Addig nyújtózkodj ameddig a takaród ér', 'A hazug embert hamarabb utolérik mint a sánta kutyát',
];

const List<String> kGroupsHu = [
  'Gyümölcsök|alma körte cseresznye banán szőlő citrom narancs', 'Zöldségek|répa krumpli hagyma paradicsom uborka saláta spenót', 'Állatok|kutya macska ló tehén juh kecske szamár', 'Madarak|galamb varjú bagoly sas veréb gólya papagáj',
  'Színek|piros kék zöld sárga fehér fekete barna', 'Bútorok|szék asztal ágy szekrény kanapé polc komód', 'Test|fej kéz láb orr szem fül térd', 'Ruhák|ing nadrág szoknya kabát dzseki zokni ruha',
  'Foglalkozások|orvos tanár szakács pék pilóta festő kertész', 'Italok|víz tej gyümölcslé kávé tea kakaó limonádé', 'Időjárás|eső hó szél köd jégeső vihar mennydörgés', 'Járművek|autó vonat busz hajó bicikli repülő traktor',
  'Hangszerek|hegedű gitár furulya dob zongora hárfa trombita', 'Szerszámok|kalapács fűrész fogó fúró lapát reszelő olló',
];

const List<String> kSynonymsHu = [
  'gyors|sebes', 'nagy|óriási', 'kicsi|apró', 'szép|csinos',
  'okos|eszes', 'kezd|elkezd', 'vidám|jókedvű', 'vég|befejezés',
  'ösvény|gyalogút', 'bátorság|merészség', 'beszél|társalog', 'néz|figyel',
  'megy|halad', 'csend|nyugalom',
];

const List<String> kAntonymsHu = [
  'nagy|kicsi', 'hosszú|rövid', 'meleg|hideg', 'világos|sötét',
  'gyors|lassú', 'öreg|fiatal', 'tele|üres', 'fent|lent',
  'nappal|éjszaka', 'kemény|puha', 'sok|kevés', 'közel|távol',
  'könnyű|nehéz', 'szegény|gazdag', 'korán|későn', 'nyitott|zárt',
  'beteg|egészséges', 'egyszerű|bonyolult',
];
