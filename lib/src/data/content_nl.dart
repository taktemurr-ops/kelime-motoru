// nl: kelime ailesinin ipucu, atasözü, kategori ve eş/zıt anlam içeriği.
// Stüdyonun kendi metinleri; atasözleri halk malıdır (kamu malı).

const List<String> kCluesNl = [
  'appel|Rood of groen fruit', 'brood|Gebakken in de oven', 'rivier|Stromend water', 'zee|Groot zout water',
  'eiland|Land in het water', 'berg|Heel hoge heuvel', 'bos|Veel bomen bij elkaar', 'woestijn|Droog zandland',
  'wolk|Zweeft in de lucht', 'regen|Valt uit de wolken', 'sneeuw|Witte wintervlokken', 'zon|Ster van de dag',
  'maan|Satelliet van de aarde', 'ster|Licht aan de nachthemel', 'wind|Bewegende lucht', 'ijs|Bevroren water',
  'vuur|Vlammen en hitte', 'steen|Stuk rots', 'zand|Op het strand', 'bloem|Bloeit in de tuin',
  'boom|Stam en takken', 'blad|Hangt aan de tak', 'wortel|Onder de plant', 'hond|Huisdier dat blaft',
  'kat|Huisdier dat miauwt', 'paard|Rijdier met manen', 'vogel|Vleugels en veren', 'vis|Zwemt met kieuwen',
  'bij|Maakt honing', 'muis|Klein knaagdier', 'koe|Geeft melk', 'schaap|Geeft wol',
  'eend|Watervogel die kwaakt', 'uil|Nachtvogel', 'konijn|Lange oren', 'vos|Slim en rood',
  'beer|Groot bosdier', 'leeuw|Koning der dieren', 'huis|Plek om te wonen', 'deur|Gaat open om binnen te gaan',
  'raam|Glas in de muur', 'dak|Bovenop het huis', 'muur|Scheidt kamers', 'stoel|Om op te zitten',
  'tafel|Meubel om aan te eten', 'bed|Om in te slapen', 'lamp|Geeft licht', 'klok|Geeft de tijd aan',
  'boek|Heeft veel bladzijden', 'brief|Komt met de post', 'pen|Om mee te schrijven', 'school|Plek om te leren',
  'leraar|Geeft les aan kinderen', 'dokter|Helpt zieken', 'kok|Werkt in de keuken', 'tuin|Bloemen en planten',
  'straat|Weg in de stad', 'brug|Over de rivier', 'stad|Veel huizen en mensen', 'dorp|Kleine plaats',
  'auto|Vier wielen', 'trein|Rijdt op rails', 'schip|Vaart over zee', 'vliegtuig|Vliegt in de lucht',
  'fiets|Twee wielen en trappers', 'melk|Wit drankje', 'water|Om te drinken', 'kaas|Gemaakt van melk',
  'honing|Zoet van bijen', 'suiker|Maakt zoet', 'zout|Geeft smaak', 'soep|Warm gerecht',
  'taart|Zoet voor een feest', 'ei|Gelegd door de kip', 'neus|Om te ruiken', 'oog|Om te zien',
  'oor|Om te horen', 'mond|Om te praten', 'hand|Vijf vingers', 'voet|Gaat in de schoen',
  'hart|Pompt het bloed', 'hoofd|Bovenaan het lichaam', 'haar|Groeit op je hoofd', 'tand|Om te bijten',
  'schoen|Draag je aan je voet', 'hoed|Draag je op je hoofd', 'jas|Draag je buiten als het koud is', 'ring|Sieraad aan je vinger',
  'kleur|Rood, blauw of groen', 'muziek|Noten en liedjes', 'lied|Wordt gezongen', 'spel|Is leuk',
  'bal|Rond om mee te spelen', 'ochtend|Begin van de dag', 'avond|Einde van de dag', 'nacht|Donkere tijd',
  'week|Zeven dagen', 'jaar|Twaalf maanden', 'zomer|Warm seizoen', 'winter|Koud seizoen',
  'herfst|Bladeren vallen', 'lente|Seizoen van bloesem', 'vriend|Dierbaar persoon', 'familie|Ouders en kinderen',
  'kind|Jong mens', 'naam|Zo heet je', 'geld|Om mee te betalen', 'markt|Plek om te kopen',
  'kaart|Toont de weg', 'droom|Beelden in je slaap', 'licht|Maakt het helder', 'schaduw|Donker achter je',
];

const List<String> kProverbsNl = [
  'Oefening baart kunst', 'Wie het laatst lacht lacht het best', 'Beter laat dan nooit', 'Haastige spoed is zelden goed',
  'Wie niet waagt wie niet wint', 'Blaffende honden bijten niet', 'Alle begin is moeilijk', 'De appel valt niet ver van de boom',
  'Wie zoekt die vindt', 'Zoals de waard is vertrouwt hij zijn gasten', 'Een goed begin is het halve werk', 'Wie goed doet goed ontmoet',
  'Spreken is zilver zwijgen is goud', 'Vele handen maken licht werk', 'Tijd is geld', 'Eén zwaluw maakt nog geen zomer',
  'Waar rook is is vuur', 'Wie a zegt moet ook b zeggen', 'Eerlijk duurt het langst', 'Na regen komt zonneschijn',
  'Rome is niet in één dag gebouwd', 'Gedeelde vreugde is dubbele vreugde', 'Beter een goede buur dan een verre vriend', 'Wie niet sterk is moet slim zijn',
  'De beste stuurlui staan aan wal',
];

const List<String> kGroupsNl = [
  'Fruit|appel peer kers banaan druif citroen sinaasappel', 'Groente|wortel aardappel ui tomaat komkommer sla spinazie', 'Dieren|hond kat paard koe schaap geit ezel', 'Vogels|duif kraai uil adelaar mus ooievaar papegaai',
  'Kleuren|rood blauw groen geel wit zwart bruin', 'Meubels|stoel tafel bed kast bank plank ladekast', 'Lichaam|hoofd hand voet neus oog oor knie', 'Kleding|hemd broek rok jas jurk sok trui',
  'Beroepen|dokter leraar kok bakker piloot schilder tuinman', 'Dranken|water melk sap koffie thee chocolademelk limonade', 'Weer|regen sneeuw wind mist hagel storm onweer', 'Voertuigen|auto trein bus schip fiets vliegtuig tractor',
  'Instrumenten|viool gitaar fluit trommel piano harp trompet', 'Gereedschap|hamer zaag tang boor schop vijl schaar',
];

const List<String> kSynonymsNl = [
  'snel|vlug', 'groot|enorm', 'klein|piepklein', 'mooi|knap',
  'slim|pienter', 'beginnen|starten', 'blij|vrolijk', 'einde|slot',
  'pad|weg', 'moed|durf', 'praten|spreken', 'kijken|zien',
  'lopen|wandelen', 'rust|stilte',
];

const List<String> kAntonymsNl = [
  'groot|klein', 'lang|kort', 'warm|koud', 'licht|donker',
  'snel|traag', 'oud|jong', 'vol|leeg', 'boven|onder',
  'dag|nacht', 'hard|zacht', 'veel|weinig', 'dichtbij|ver',
  'licht|zwaar', 'arm|rijk', 'vroeg|laat', 'open|dicht',
  'ziek|gezond', 'makkelijk|moeilijk',
];
