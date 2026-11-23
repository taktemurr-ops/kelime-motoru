// ro: kelime ailesinin ipucu, atasözü, kategori ve eş/zıt anlam içeriği.
// Stüdyonun kendi metinleri; atasözleri halk malıdır (kamu malı).

const List<String> kCluesRo = [
  'măr|Fruct roșu sau verde', 'pâine|Se coace în cuptor', 'râu|Apă curgătoare', 'mare|Apă sărată întinsă',
  'insulă|Pământ înconjurat de apă', 'munte|Înălțime foarte mare', 'pădure|Mulți copaci', 'deșert|Ținut uscat cu nisip',
  'nor|Plutește pe cer', 'ploaie|Cade din nori', 'zăpadă|Fulgi albi de iarnă', 'soare|Steaua zilei',
  'lună|Satelitul Pământului', 'stea|Strălucește noaptea', 'vânt|Aer în mișcare', 'gheață|Apă înghețată',
  'foc|Flăcări și căldură', 'piatră|Bucată de rocă', 'nisip|Pe plajă', 'floare|Înflorește în grădină',
  'copac|Trunchi și ramuri', 'frunză|Atârnă de ramură', 'rădăcină|Sub plantă', 'câine|Latră',
  'pisică|Miaună', 'cal|Se poate călări', 'pasăre|Aripi și pene', 'pește|Înoată în apă',
  'albină|Face miere', 'șoarece|Rozător mic', 'vacă|Dă lapte', 'oaie|Dă lână',
  'rață|Pasăre care măcăie', 'bufniță|Pasăre de noapte', 'iepure|Urechi lungi', 'vulpe|Șireată și roșcată',
  'urs|Animal mare al pădurii', 'leu|Regele animalelor', 'casă|Loc de locuit', 'ușă|Se deschide la intrare',
  'fereastră|Geam în perete', 'acoperiș|Deasupra casei', 'perete|Desparte camerele', 'scaun|Pentru stat jos',
  'masă|Mobilă pentru mâncat', 'pat|Pentru dormit', 'lampă|Dă lumină', 'ceas|Arată ora',
  'carte|Are multe pagini', 'scrisoare|Vine prin poștă', 'creion|Pentru scris', 'școală|Loc de învățat',
  'profesor|Îi învață pe copii', 'doctor|Vindecă bolnavii', 'bucătar|Lucrează în bucătărie', 'grădină|Flori și straturi',
  'stradă|Drum prin oraș', 'pod|Trece peste râu', 'oraș|Multe case și oameni', 'sat|Localitate mică',
  'mașină|Patru roți', 'tren|Merge pe șine', 'vapor|Navighează pe mare', 'avion|Zboară prin aer',
  'bicicletă|Două roți și pedale', 'lapte|Băutură albă', 'apă|De băut', 'brânză|Făcută din lapte',
  'miere|Dulce de la albine', 'zahăr|Îndulcește', 'sare|Dă gust', 'supă|Mâncare caldă',
  'tort|Dulce de sărbătoare', 'ou|Îl face găina', 'nas|Pentru mirosit', 'ochi|Pentru văzut',
  'ureche|Pentru auzit', 'gură|Pentru vorbit', 'mână|Cinci degete', 'picior|Pentru mers',
  'inimă|Pompează sângele', 'cap|Sus pe corp', 'păr|Crește pe cap', 'dinte|Pentru mușcat',
  'pantof|Se poartă în picior', 'pălărie|Se poartă pe cap', 'palton|Haină groasă', 'inel|Bijuterie pe deget',
  'culoare|Roșu, albastru sau verde', 'muzică|Note și cântece', 'cântec|Se cântă', 'joc|Este distractiv',
  'minge|Rotundă pentru joacă', 'dimineață|Începutul zilei', 'seară|Sfârșitul zilei', 'noapte|Timp întunecat',
  'săptămână|Șapte zile', 'an|Douăsprezece luni', 'vară|Anotimp cald', 'iarnă|Anotimp rece',
  'toamnă|Cad frunzele', 'primăvară|Anotimpul florilor', 'prieten|Om drag', 'familie|Părinți și copii',
  'copil|Om mic', 'nume|Cum te cheamă', 'bani|Pentru plată', 'piață|Loc de cumpărături',
  'hartă|Arată drumul', 'vis|Imagini în somn', 'lumină|Luminează', 'umbră|Întunecată în spatele tău',
  'elev|Învață la școală', 'înger|Ființă cu aripi din povești', 'xilofon|Instrument cu plăci', 'țară|Stat cu granițe',
  'ecou|Repetă vocea în munți', 'ied|Puiul caprei',
];

const List<String> kProverbsRo = [
  'Cine se scoală de dimineață departe ajunge', 'Mai bine mai târziu decât niciodată', 'Picătura chinezească găurește piatra', 'Ce ție nu îți place altuia nu face',
  'Graba strică treaba', 'Ziua bună se cunoaște de dimineață', 'Cine sapă groapa altuia cade singur în ea', 'Nu tot ce zboară se mănâncă',
  'Cine caută găsește', 'Vorba dulce mult aduce', 'Lupul își schimbă părul dar năravul ba', 'Fiecare pasăre pe limba ei piere',
  'Prietenul la nevoie se cunoaște', 'Ai carte ai parte', 'Socoteala de acasă nu se potrivește cu cea din târg', 'Bate fierul cât e cald',
  'Cine se aseamănă se adună', 'Paza bună trece primejdia rea', 'Ochii care nu se văd se uită', 'Câinele care latră nu mușcă',
  'Nu lăsa pe mâine ce poți face astăzi',
];

const List<String> kGroupsRo = [
  'Fructe|măr pară cireașă banană strugure lămâie portocală', 'Legume|morcov cartof ceapă roșie castravete salată spanac', 'Animale|câine pisică cal vacă oaie capră măgar', 'Păsări|porumbel cioară bufniță vultur vrabie barză papagal',
  'Culori|roșu albastru verde galben alb negru maro', 'Mobilă|scaun masă pat dulap canapea raft comodă', 'Corp|cap mână picior nas ochi ureche genunchi', 'Haine|cămașă pantaloni fustă palton geacă șosetă rochie',
  'Meserii|doctor profesor bucătar brutar pilot pictor grădinar', 'Băuturi|apă lapte suc cafea ceai cacao limonadă', 'Vreme|ploaie zăpadă vânt ceață grindină furtună tunet', 'Vehicule|mașină tren autobuz vapor bicicletă avion tractor',
  'Instrumente|vioară chitară flaut tobă pian harpă trompetă', 'Unelte|ciocan fierăstrău clește burghiu lopată pilă foarfecă',
];

const List<String> kSynonymsRo = [
  'rapid|iute', 'mare|imens', 'mic|mărunt', 'frumos|arătos',
  'deștept|isteț', 'începe|porni', 'vesel|bucuros', 'sfârșit|final',
  'cărare|potecă', 'curaj|bărbăție', 'vorbi|grăi', 'privi|uita',
  'merge|umbla', 'liniște|pace',
];

const List<String> kAntonymsRo = [
  'mare|mic', 'lung|scurt', 'fierbinte|rece', 'luminos|întunecat',
  'rapid|încet', 'bătrân|tânăr', 'plin|gol', 'sus|jos',
  'zi|noapte', 'tare|moale', 'mult|puțin', 'aproape|departe',
  'ușor|greu', 'sărac|bogat', 'devreme|târziu', 'deschis|închis',
  'bolnav|sănătos', 'simplu|complicat',
];
