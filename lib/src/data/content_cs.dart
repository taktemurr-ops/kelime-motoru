// cs: kelime ailesinin ipucu, atasözü, kategori ve eş/zıt anlam içeriği.
// Stüdyonun kendi metinleri; atasözleri halk malıdır (kamu malı).

const List<String> kCluesCs = [
  'jablko|Červené nebo zelené ovoce', 'chléb|Peče se v troubě', 'řeka|Tekoucí voda', 'moře|Velká slaná voda',
  'ostrov|Země obklopená vodou', 'hora|Velmi vysoký kopec', 'les|Mnoho stromů', 'poušť|Suchá písečná krajina',
  'mrak|Pluje po nebi', 'déšť|Padá z mraků', 'sníh|Bílé zimní vločky', 'slunce|Hvězda dne',
  'měsíc|Družice Země', 'hvězda|Svítí v noci', 'vítr|Pohyb vzduchu', 'led|Zmrzlá voda',
  'oheň|Plameny a teplo', 'kámen|Kus skály', 'písek|Je na pláži', 'květina|Kvete na zahradě',
  'strom|Kmen a větve', 'list|Visí na větvi', 'kořen|Pod rostlinou', 'pes|Štěká',
  'kočka|Mňouká', 'kůň|Dá se na něm jezdit', 'pták|Křídla a peří', 'ryba|Plave ve vodě',
  'včela|Dělá med', 'myš|Malý hlodavec', 'kráva|Dává mléko', 'ovce|Dává vlnu',
  'kachna|Pták co kváká', 'sova|Noční pták', 'králík|Dlouhé uši', 'liška|Chytrá a zrzavá',
  'medvěd|Velké lesní zvíře', 'lev|Král zvířat', 'dům|Místo k bydlení', 'dveře|Otvírají se při vstupu',
  'okno|Sklo ve zdi', 'střecha|Nahoře na domě', 'zeď|Dělí místnosti', 'židle|K sezení',
  'stůl|Nábytek k jídlu', 'postel|Ke spaní', 'lampa|Dává světlo', 'hodiny|Ukazují čas',
  'kniha|Má mnoho stran', 'dopis|Přijde poštou', 'tužka|Na psaní', 'škola|Místo učení',
  'učitel|Učí děti', 'lékař|Léčí nemocné', 'kuchař|Pracuje v kuchyni', 'zahrada|Květiny a záhony',
  'ulice|Cesta ve městě', 'most|Vede přes řeku', 'město|Mnoho domů a lidí', 'vesnice|Malá obec',
  'auto|Čtyři kola', 'vlak|Jede po kolejích', 'loď|Pluje po moři', 'letadlo|Létá ve vzduchu',
  'kolo|Dvě kola a pedály', 'mléko|Bílý nápoj', 'voda|K pití', 'sýr|Vyrobený z mléka',
  'med|Sladký od včel', 'cukr|Sladí', 'sůl|Dodává chuť', 'polévka|Teplé jídlo',
  'dort|Sladký k oslavě', 'vejce|Snáší ho slepice', 'nos|K čichání', 'oko|K vidění',
  'ucho|K slyšení', 'ústa|K mluvení', 'ruka|Pět prstů', 'noha|K chůzi',
  'srdce|Pumpuje krev', 'hlava|Nahoře na těle', 'vlasy|Rostou na hlavě', 'zub|Ke kousání',
  'bota|Nosí se na noze', 'klobouk|Nosí se na hlavě', 'kabát|Teplý svrchník', 'prsten|Šperk na prst',
  'barva|Červená, modrá nebo zelená', 'hudba|Tóny a písně', 'píseň|Zpívá se', 'hra|Je zábavná',
  'míč|Kulatý na hraní', 'ráno|Začátek dne', 'večer|Konec dne', 'noc|Tmavá doba',
  'týden|Sedm dní', 'rok|Dvanáct měsíců', 'léto|Teplé roční období', 'zima|Studené roční období',
  'podzim|Padá listí', 'jaro|Období květů', 'přítel|Blízký člověk', 'rodina|Rodiče a děti',
  'dítě|Malý člověk', 'jméno|Tak se jmenuješ', 'peníze|K placení', 'trh|Místo nákupů',
  'mapa|Ukazuje cestu', 'sen|Obrazy ve spánku', 'světlo|Rozjasní', 'stín|Tmavý za tebou',
  'elektřina|Proud v drátech', 'inkoust|Tekutina do pera', 'fotbal|Hra s míčem a brankou', 'guma|Maže tužku',
  'čaj|Horký nápoj z lístků', 'ježek|Má bodliny', 'energie|Síla k práci',
];

const List<String> kProverbsCs = [
  'Bez práce nejsou koláče', 'Kdo jinému jámu kopá sám do ní padá', 'Ranní ptáče dál doskáče', 'Lepší pozdě než nikdy',
  'Opakování je matka moudrosti', 'Kdo hledá najde', 'Mluviti stříbro mlčeti zlato', 'Darovanému koni na zuby nehleď',
  'Jablko nepadá daleko od stromu', 'Komu není rady tomu není pomoci', 'Všeho moc škodí', 'Kdo se směje naposled ten se směje nejlépe',
  'Kdo šetří má za tři', 'Lepší vrabec v hrsti nežli holub na střeše', 'Co se v mládí naučíš ve stáří jako když najdeš', 'Kdo pozdě chodí sám sobě škodí',
  'Jedna vlaštovka jaro nedělá', 'Není všechno zlato co se třpytí', 'Pomalu ale jistě', 'Trpělivost růže přináší',
  'Co můžeš udělat dnes neodkládej na zítřek',
];

const List<String> kGroupsCs = [
  'Ovoce|jablko hruška třešeň banán hrozen citron pomeranč', 'Zelenina|mrkev brambor cibule rajče okurka salát špenát', 'Zvířata|pes kočka kůň kráva ovce koza osel', 'Ptáci|holub vrána sova orel vrabec čáp papoušek',
  'Barvy|červená modrá zelená žlutá bílá černá hnědá', 'Nábytek|židle stůl postel skříň pohovka police komoda', 'Tělo|hlava ruka noha nos oko ucho koleno', 'Oblečení|košile kalhoty sukně kabát bunda ponožka šaty',
  'Povolání|lékař učitel kuchař pekař pilot malíř zahradník', 'Nápoje|voda mléko džus káva čaj kakao limonáda', 'Počasí|déšť sníh vítr mlha kroupy bouřka hrom', 'Vozidla|auto vlak autobus loď kolo letadlo traktor',
  'Nástroje|housle kytara flétna buben klavír harfa trubka', 'Nářadí|kladivo pila kleště vrtačka lopata pilník nůžky',
];

const List<String> kSynonymsCs = [
  'rychlý|hbitý', 'velký|obrovský', 'malý|drobný', 'krásný|hezký',
  'chytrý|bystrý', 'začít|započít', 'veselý|radostný', 'konec|závěr',
  'stezka|pěšina', 'odvaha|statečnost', 'mluvit|hovořit', 'dívat|hledět',
  'jít|kráčet', 'klid|ticho',
];

const List<String> kAntonymsCs = [
  'velký|malý', 'dlouhý|krátký', 'horký|studený', 'světlý|tmavý',
  'rychlý|pomalý', 'starý|mladý', 'plný|prázdný', 'nahoře|dole',
  'den|noc', 'tvrdý|měkký', 'hodně|málo', 'blízko|daleko',
  'lehký|těžký', 'chudý|bohatý', 'brzy|pozdě', 'otevřený|zavřený',
  'nemocný|zdravý', 'snadný|těžký',
];
