// nb: kelime ailesinin ipucu, atasözü, kategori ve eş/zıt anlam içeriği.
// Stüdyonun kendi metinleri; atasözleri halk malıdır (kamu malı).

const List<String> kCluesNb = [
  'eple|Rød eller grønn frukt', 'brød|Bakes i ovnen', 'elv|Rennende vann', 'hav|Stort salt vann',
  'holme|Liten øy i vannet', 'fjell|Svært høy topp', 'skog|Mange trær', 'ørken|Tørt sandland',
  'sky|Svever på himmelen', 'regn|Faller fra skyene', 'snø|Hvite vinterfnugg', 'sol|Dagens stjerne',
  'måne|Jordens følgesvenn', 'stjerne|Lyser om natten', 'vind|Luft i bevegelse', 'is|Frosset vann',
  'ild|Flammer og varme', 'stein|Bit av berget', 'sand|Finnes på stranden', 'blomst|Vokser i bedet',
  'tre|Stamme og greiner', 'blad|Sitter på greina', 'rot|Under planten', 'hund|Kjæledyr som bjeffer',
  'katt|Kjæledyr som mjauer', 'hest|Man rir på den', 'fugl|Vinger og fjær', 'fisk|Svømmer med gjeller',
  'bie|Lager honning', 'mus|Liten gnager', 'ku|Gir melk', 'sau|Gir ull',
  'and|Fugl som kvakker', 'ugle|Nattfugl', 'kanin|Lange ører', 'rev|Lur og rød',
  'bjørn|Stort skogsdyr', 'løve|Dyrenes konge', 'hus|Der man bor', 'dør|Åpnes for å gå inn',
  'vindu|Glass i veggen', 'tak|Øverst på huset', 'vegg|Skiller rommene', 'stol|Til å sitte på',
  'bord|Møbel å spise ved', 'seng|Til å sove i', 'lampe|Gir lys', 'klokke|Viser tiden',
  'bok|Har mange sider', 'brev|Kommer med posten', 'blyant|Til å skrive med', 'skole|Sted for læring',
  'lærer|Underviser barn', 'lege|Hjelper syke', 'kokk|Jobber på kjøkkenet', 'hage|Blomster og bed',
  'gate|Vei i byen', 'bro|Går over elva', 'by|Mange hus og mennesker', 'landsby|Lite sted',
  'bil|Fire hjul', 'tog|Går på skinner', 'skip|Seiler på havet', 'fly|Har vinger og passasjerer',
  'sykkel|To hjul og pedaler', 'melk|Hvit drikke', 'vann|Til å drikke', 'ost|Lages av melk',
  'honning|Søtt fra bier', 'sukker|Gjør søtt', 'salt|Gir smak', 'suppe|Varm rett',
  'kake|Søtt til fest', 'egg|Høna verper det', 'nese|Til å lukte med', 'øye|Til å se med',
  'øre|Sitter på siden av hodet', 'munn|Til å snakke med', 'hånd|Fem fingre', 'fot|Går i skoen',
  'hjerte|Pumper blodet', 'hode|Øverst på kroppen', 'hår|Vokser på hodet', 'tann|Til å bite med',
  'sko|Brukes på foten', 'hatt|Brukes på hodet', 'frakk|Varmt yttertøy', 'ring|Smykke på fingeren',
  'farge|Rød, blå eller grønn', 'musikk|Toner og sanger', 'sang|Blir sunget', 'lek|Er gøy',
  'ball|Rund å leke med', 'morgen|Dagens start', 'kveld|Dagens slutt', 'natt|Mørk tid',
  'uke|Sju dager', 'år|Tolv måneder', 'sommer|Varm årstid', 'vinter|Kald årstid',
  'høst|Bladene faller', 'vår|Blomstenes årstid', 'venn|Kjær person', 'familie|Foreldre og barn',
  'barn|Ungt menneske', 'navn|Det du heter', 'penger|Til å betale med', 'marked|Sted å handle',
  'kart|Viser veien', 'drøm|Bilder i søvne', 'lys|Motsatt av mørke', 'skygge|Mørk bak deg',
];

const List<String> kProverbsNb = [
  'Øvelse gjør mester', 'Bedre sent enn aldri', 'Den som ler sist ler best', 'Mange bekker små gjør en stor å',
  'Borte bra men hjemme best', 'Tale er sølv taushet er gull', 'Hastverk er lastverk', 'Den som intet våger intet vinner',
  'Det er ikke gull alt som glimrer', 'Morgenstund har gull i munn', 'Man skal ikke selge skinnet før bjørnen er skutt', 'Kommer tid kommer råd',
  'Liten tue kan velte stort lass', 'Like barn leker best', 'Den som graver en grav for andre faller selv i den', 'Alle gode ting er tre',
  'Ingen roser uten torner', 'Det er ingen sak å være etterpåklok', 'Rom ble ikke bygd på en dag', 'Ut på tur aldri sur',
  'Det finnes ikke dårlig vær bare dårlige klær',
];

const List<String> kGroupsNb = [
  'Frukt|eple pære kirsebær banan drue sitron appelsin', 'Grønnsaker|gulrot potet løk tomat agurk salat spinat', 'Dyr|hund katt hest ku sau geit esel', 'Fugler|due kråke ugle ørn spurv stork papegøye',
  'Farger|rød blå grønn gul hvit svart brun', 'Møbler|stol bord seng skap sofa hylle kommode', 'Kroppen|hode hånd fot nese øye øre kne', 'Klær|skjorte bukse skjørt frakk jakke sokk kjole',
  'Yrker|lege lærer kokk baker pilot maler gartner', 'Drikke|vann melk saft kaffe te kakao brus', 'Vær|regn snø vind tåke hagl storm torden', 'Kjøretøy|bil tog buss skip sykkel fly traktor',
  'Instrumenter|fiolin gitar fløyte tromme piano harpe trompet', 'Verktøy|hammer sag tang bor spade fil saks',
];

const List<String> kSynonymsNb = [
  'rask|kjapp', 'stor|diger', 'liten|bitte', 'vakker|pen',
  'klok|smart', 'begynne|starte', 'glad|munter', 'slutt|avslutning',
  'sti|vei', 'mot|tapperhet', 'snakke|prate', 'se|titte',
  'gå|vandre', 'ro|stillhet',
];

const List<String> kAntonymsNb = [
  'stor|liten', 'lang|kort', 'varm|kald', 'lys|mørk',
  'rask|treg', 'gammel|ung', 'full|tom', 'oppe|nede',
  'dag|natt', 'hard|myk', 'mye|lite', 'nær|fjern',
  'lett|tung', 'fattig|rik', 'tidlig|sen', 'åpen|lukket',
  'syk|frisk', 'enkel|vanskelig',
];
