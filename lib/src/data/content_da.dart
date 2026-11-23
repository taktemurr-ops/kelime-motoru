// da: kelime ailesinin ipucu, atasözü, kategori ve eş/zıt anlam içeriği.
// Stüdyonun kendi metinleri; atasözleri halk malıdır (kamu malı).

const List<String> kCluesDa = [
  'æble|Rød eller grøn frugt', 'brød|Bages i ovnen', 'flod|Rindende vand', 'hav|Stort salt vand',
  'holm|Lille ø i vandet', 'bjerg|Meget høj bakke', 'skov|Mange træer', 'ørken|Tørt sandland',
  'sky|Svæver på himlen', 'regn|Falder fra skyerne', 'sne|Hvide vinterfnug', 'sol|Dagens stjerne',
  'måne|Jordens følgesvend', 'stjerne|Lyser om natten', 'vind|Luft i bevægelse', 'is|Frosset vand',
  'ild|Flammer og varme', 'sten|Stykke klippe', 'sand|Findes på stranden', 'blomst|Vokser i bedet',
  'træ|Stamme og grene', 'blad|Sidder på grenen', 'rod|Under planten', 'hund|Kæledyr der gør',
  'kat|Kæledyr der miaver', 'hest|Man rider på den', 'fugl|Vinger og fjer', 'fisk|Svømmer med gæller',
  'bi|Laver honning', 'mus|Lille gnaver', 'ko|Giver mælk', 'får|Giver uld',
  'and|Fugl der rapper', 'ugle|Natfugl', 'kanin|Lange ører', 'ræv|Snu og rød',
  'bjørn|Stort skovdyr', 'løve|Dyrenes konge', 'hus|Hvor man bor', 'dør|Åbnes for at gå ind',
  'vindue|Glas i væggen', 'tag|Øverst på huset', 'væg|Skiller rummene', 'stol|Til at sidde på',
  'bord|Møbel at spise ved', 'seng|Til at sove i', 'lampe|Giver lys', 'ur|Viser tiden',
  'bog|Har mange sider', 'brev|Kommer med posten', 'blyant|Til at skrive med', 'skole|Sted for læring',
  'lærer|Underviser børn', 'læge|Hjælper syge', 'kok|Arbejder i køkkenet', 'have|Blomster og bede',
  'gade|Vej i byen', 'bro|Går over floden', 'by|Mange huse og mennesker', 'landsby|Lille sted',
  'bil|Fire hjul', 'tog|Kører på skinner', 'skib|Sejler på havet', 'fly|Har vinger og passagerer',
  'cykel|To hjul og pedaler', 'mælk|Hvid drik', 'vand|Til at drikke', 'ost|Laves af mælk',
  'honning|Sødt fra bier', 'sukker|Gør sødt', 'salt|Giver smag', 'suppe|Varm ret',
  'kage|Sødt til fest', 'æg|Lægges af hønen', 'næse|Til at lugte med', 'øje|Til at se med',
  'øre|Sidder på siden af hovedet', 'mund|Til at tale med', 'hånd|Fem fingre', 'fod|Går i skoen',
  'hjerte|Pumper blodet', 'hoved|Øverst på kroppen', 'hår|Vokser på hovedet', 'tand|Til at bide med',
  'sko|Bæres på foden', 'hat|Bæres på hovedet', 'frakke|Varmt overtøj', 'ring|Smykke på fingeren',
  'farve|Rød, blå eller grøn', 'musik|Toner og sange', 'sang|Bliver sunget', 'leg|Er sjovt',
  'bold|Rund at spille med', 'morgen|Dagens start', 'aften|Dagens slutning', 'nat|Mørk tid',
  'uge|Syv dage', 'år|Tolv måneder', 'sommer|Varm årstid', 'vinter|Kold årstid',
  'efterår|Bladene falder', 'forår|Blomsternes årstid', 'ven|Kær person', 'familie|Forældre og børn',
  'barn|Ungt menneske', 'navn|Det du hedder', 'penge|Til at betale med', 'marked|Sted at handle',
  'kort|Viser vejen', 'drøm|Billeder i søvnen', 'lys|Modsat mørke', 'skygge|Mørk bag dig',
];

const List<String> kProverbsDa = [
  'Øvelse gør mester', 'Bedre sent end aldrig', 'Den der ler sidst ler bedst', 'Mange bække små gør en stor å',
  'Ude godt men hjemme bedst', 'Tale er sølv tavshed er guld', 'Hastværk er lastværk', 'Den der intet vover intet vinder',
  'Det er ikke guld alt der glimrer', 'Hvor der er vilje er der vej', 'Morgenstund har guld i mund', 'Man skal ikke sælge skindet før bjørnen er skudt',
  'Kommer tid kommer råd', 'Små tuer vælter store læs', 'Lige børn leger bedst', 'Den der graver en grav for andre falder selv i den',
  'Alle gode gange tre', 'Ingen roser uden torne', 'Glemt er ikke gemt', 'Man skal ikke skue hunden på hårene',
  'Rom blev ikke bygget på en dag', 'Gammel kærlighed ruster ikke', 'Man skal ikke kaste med sten når man bor i et glashus', 'Det er bedre at give end at modtage',
];

const List<String> kGroupsDa = [
  'Frugt|æble pære kirsebær banan drue citron appelsin', 'Grøntsager|gulerod kartoffel løg tomat agurk salat spinat', 'Dyr|hund kat hest ko får ged æsel', 'Fugle|due krage ugle ørn spurv stork papegøje',
  'Farver|rød blå grøn gul hvid sort brun', 'Møbler|stol bord seng skab sofa hylde kommode', 'Kroppen|hoved hånd fod næse øje øre knæ', 'Tøj|skjorte bukser nederdel frakke jakke strømpe kjole',
  'Erhverv|læge lærer kok bager pilot maler gartner', 'Drikke|vand mælk saft kaffe te kakao sodavand', 'Vejr|regn sne vind tåge hagl storm torden', 'Køretøjer|bil tog bus skib cykel fly traktor',
  'Instrumenter|violin guitar fløjte tromme klaver harpe trompet', 'Værktøj|hammer sav tang bor skovl fil saks',
];

const List<String> kSynonymsDa = [
  'hurtig|rask', 'stor|kæmpe', 'lille|bitte', 'smuk|køn',
  'klog|snedig', 'begynde|starte', 'glad|munter', 'ende|slutning',
  'sti|vej', 'mod|tapperhed', 'tale|snakke', 'kigge|se',
  'gå|vandre', 'ro|stilhed',
];

const List<String> kAntonymsDa = [
  'stor|lille', 'lang|kort', 'varm|kold', 'lys|mørk',
  'hurtig|langsom', 'gammel|ung', 'fuld|tom', 'oppe|nede',
  'dag|nat', 'hård|blød', 'meget|lidt', 'nær|fjern',
  'let|tung', 'fattig|rig', 'tidlig|sen', 'åben|lukket',
  'syg|rask', 'nem|svær',
];
