// sv: kelime ailesinin ipucu, atasözü, kategori ve eş/zıt anlam içeriği.
// Stüdyonun kendi metinleri; atasözleri halk malıdır (kamu malı).

const List<String> kCluesSv = [
  'äpple|Röd eller grön frukt', 'bröd|Bakas i ugnen', 'flod|Rinnande vatten', 'hav|Stort salt vatten',
  'holme|Liten ö i vattnet', 'berg|Mycket hög kulle', 'skog|Många träd', 'öken|Torrt sandland',
  'moln|Svävar på himlen', 'regn|Faller från molnen', 'snö|Vita vinterflingor', 'sol|Dagens stjärna',
  'måne|Jordens följeslagare', 'stjärna|Lyser på natten', 'vind|Luft i rörelse', 'is|Fruset vatten',
  'eld|Lågor och värme', 'sten|Bit av berget', 'sand|Finns på stranden', 'blomma|Växer i rabatten',
  'träd|Stam och grenar', 'löv|Sitter på grenen', 'rot|Under växten', 'hund|Husdjur som skäller',
  'katt|Husdjur som jamar', 'häst|Man rider på den', 'fågel|Vingar och fjädrar', 'fisk|Simmar med gälar',
  'bi|Gör honung', 'mus|Liten gnagare', 'ko|Ger mjölk', 'får|Ger ull',
  'anka|Fågel som kvackar', 'uggla|Nattfågel', 'kanin|Långa öron', 'räv|Listig och röd',
  'björn|Stort skogsdjur', 'lejon|Djurens kung', 'hus|Där man bor', 'dörr|Öppnas för att gå in',
  'fönster|Glas i väggen', 'tak|Ovanpå huset', 'vägg|Skiljer rummen', 'stol|Att sitta på',
  'bord|Möbel att äta vid', 'säng|Att sova i', 'lampa|Ger ljus', 'klocka|Visar tiden',
  'bok|Har många sidor', 'brev|Kommer med posten', 'penna|Att skriva med', 'skola|Plats för lärande',
  'lärare|Undervisar barn', 'läkare|Botar sjuka', 'kock|Arbetar i köket', 'trädgård|Blommor och rabatter',
  'gata|Väg i staden', 'bro|Går över floden', 'stad|Många hus och människor', 'by|Liten ort',
  'bil|Fyra hjul', 'tåg|Går på räls', 'fartyg|Seglar på havet', 'flygplan|Flyger i luften',
  'cykel|Två hjul och pedaler', 'mjölk|Vit dryck', 'vatten|Att dricka', 'ost|Görs av mjölk',
  'honung|Sött från bin', 'socker|Gör sött', 'salt|Ger smak', 'soppa|Varm rätt',
  'tårta|Sött till kalas', 'ägg|Hönan värper det', 'näsa|Att lukta med', 'öga|Att se med',
  'öra|Sitter på sidan av huvudet', 'mun|Att prata med', 'hand|Fem fingrar', 'fot|Går i skon',
  'hjärta|Pumpar blodet', 'huvud|Överst på kroppen', 'hår|Växer på huvudet', 'tand|Att bita med',
  'sko|Bärs på foten', 'hatt|Bärs på huvudet', 'rock|Varm ytterplagg', 'ring|Smycke på fingret',
  'färg|Röd, blå eller grön', 'musik|Toner och sånger', 'sång|Sjungs', 'lek|Är roligt',
  'boll|Rund att spela med', 'morgon|Dagens början', 'kväll|Dagens slut', 'natt|Mörk tid',
  'vecka|Sju dagar', 'år|Tolv månader', 'sommar|Varm årstid', 'vinter|Kall årstid',
  'höst|Löven faller', 'vår|Blommornas årstid', 'vän|Kär person', 'familj|Föräldrar och barn',
  'barn|Ung människa', 'namn|Det du heter', 'pengar|Att betala med', 'marknad|Plats att handla',
  'karta|Visar vägen', 'dröm|Bilder i sömnen', 'ljus|Motsatsen till mörker', 'skugga|Mörk bakom dig',
];

const List<String> kProverbsSv = [
  'Övning ger färdighet', 'Den som väntar på något gott väntar aldrig för länge', 'Lagom är bäst', 'Borta bra men hemma bäst',
  'Bättre sent än aldrig', 'Ingen ko på isen', 'Man ska inte sälja skinnet innan björnen är skjuten', 'Den som gräver en grop åt andra faller själv däri',
  'Många bäckar små gör en stor å', 'Det finns inget dåligt väder bara dåliga kläder', 'Morgonstund har guld i mund', 'Skrattar bäst som skrattar sist',
  'Lite är bättre än inget', 'Ända in i kaklet', 'Tala är silver tiga är guld', 'Ju fler kockar desto sämre soppa',
  'Har man sagt A får man säga B', 'Liten tuva stjälper ofta stort lass', 'Allt är inte guld som glimmar', 'Var sak har sin tid',
  'Man ska inte kasta sten när man sitter i glashus',
];

const List<String> kGroupsSv = [
  'Frukt|äpple päron körsbär banan druva citron apelsin', 'Grönsaker|morot potatis lök tomat gurka sallad spenat', 'Djur|hund katt häst ko får get åsna', 'Fåglar|duva kråka uggla örn sparv stork papegoja',
  'Färger|röd blå grön gul vit svart brun', 'Möbler|stol bord säng skåp soffa hylla byrå', 'Kroppen|huvud hand fot näsa öga öra knä', 'Kläder|skjorta byxor kjol rock jacka strumpa klänning',
  'Yrken|läkare lärare kock bagare pilot målare trädgårdsmästare', 'Drycker|vatten mjölk saft kaffe te choklad läsk', 'Väder|regn snö vind dimma hagel storm åska', 'Fordon|bil tåg buss fartyg cykel flygplan traktor',
  'Instrument|fiol gitarr flöjt trumma piano harpa trumpet', 'Verktyg|hammare såg tång borr spade fil sax',
];

const List<String> kSynonymsSv = [
  'snabb|kvick', 'stor|enorm', 'liten|pytteliten', 'vacker|fin',
  'klok|smart', 'börja|starta', 'glad|munter', 'slut|avslut',
  'stig|väg', 'mod|tapperhet', 'prata|tala', 'titta|se',
  'gå|vandra', 'lugn|stillhet',
];

const List<String> kAntonymsSv = [
  'stor|liten', 'lång|kort', 'varm|kall', 'ljus|mörk',
  'snabb|långsam', 'gammal|ung', 'full|tom', 'uppe|nere',
  'dag|natt', 'hård|mjuk', 'mycket|lite', 'nära|långt',
  'lätt|tung', 'fattig|rik', 'tidig|sen', 'öppen|stängd',
  'sjuk|frisk', 'enkel|svår',
];
