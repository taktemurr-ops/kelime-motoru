// fil: kelime ailesinin ipucu, atasözü, kategori ve eş/zıt anlam içeriği.
// Stüdyonun kendi metinleri; atasözleri halk malıdır (kamu malı).

const List<String> kCluesFil = [
  'mansanas|Pula o berdeng prutas', 'tinapay|Niluluto sa hurno', 'ilog|Umaagos na tubig', 'dagat|Malawak na maalat na tubig',
  'isla|Lupa sa gitna ng tubig', 'bundok|Napakataas na lupa', 'gubat|Maraming puno', 'ulap|Lumulutang sa langit',
  'ulan|Bumabagsak mula sa ulap', 'araw|Bituin sa umaga', 'buwan|Ilaw sa gabi', 'bituin|Kumikislap sa gabi',
  'hangin|Umiihip sa labas', 'apoy|Liyab at init', 'bato|Matigas na piraso ng lupa', 'buhangin|Nasa dalampasigan',
  'bulaklak|Namumukadkad sa hardin', 'puno|May katawan at sanga', 'damo|Berde sa bakuran', 'dahon|Tumutubo sa sanga',
  'ugat|Nasa ilalim ng lupa', 'aso|Tumatahol na alaga', 'pusa|Ngumingiyaw na alaga', 'kabayo|Sinasakyang hayop',
  'ibon|May pakpak at balahibo', 'isda|Lumalangoy sa tubig', 'bubuyog|Gumagawa ng pulot', 'daga|Maliit na ngumangatngat',
  'baka|Nagbibigay ng gatas', 'tupa|Nagbibigay ng lana', 'pato|Ibong lumalangoy', 'kuwago|Ibon sa gabi',
  'kuneho|Mahaba ang tainga', 'tigre|Malaking pusang may guhit', 'leon|Hari ng kagubatan', 'unggoy|Mahilig umakyat sa puno',
  'ahas|Gumagapang nang walang paa', 'pagong|May bahay sa likod', 'kalabaw|Katulong ng magsasaka', 'bahay|Tirahan',
  'pinto|Daanan papasok', 'bintana|Salamin sa dingding', 'bubong|Itaas ng bahay', 'dingding|Naghihiwalay ng silid',
  'upuan|Para sa pag-upo', 'mesa|Kinakainan', 'kama|Tinutulugan', 'ilaw|Nagbibigay liwanag',
  'orasan|Nagpapakita ng oras', 'aklat|Maraming pahina', 'liham|Ipinapadala sa koreo', 'lapis|Panulat na kahoy',
  'paaralan|Lugar ng pag-aaral', 'guro|Nagtuturo sa mga bata', 'doktor|Gumagamot ng maysakit', 'kusinero|Nagluluto sa kusina',
  'hardin|May mga halaman', 'kalsada|Daanan ng sasakyan', 'tulay|Tumatawid sa ilog', 'lungsod|Maraming gusali at tao',
  'nayon|Maliit na pamayanan', 'kotse|Apat ang gulong', 'tren|Tumatakbo sa riles', 'barko|Naglalayag sa dagat',
  'eroplano|Lumilipad sa langit', 'bisikleta|Dalawang gulong at pedal', 'gatas|Puting inumin', 'tubig|Iniinom kapag nauuhaw',
  'keso|Gawa sa gatas', 'pulot|Matamis mula sa bubuyog', 'asukal|Pampatamis', 'asin|Pampaalat',
  'sabaw|Mainit na likido ng ulam', 'kakanin|Katutubong matamis', 'itlog|Galing sa manok', 'ilong|Pang-amoy',
  'mata|Pantingin', 'tainga|Pandinig', 'bibig|Pangsalita', 'kamay|May limang daliri',
  'paa|Ginagamit sa paglakad', 'puso|Nagbobomba ng dugo', 'ulo|Pinakaitaas ng katawan', 'buhok|Tumutubo sa ulo',
  'ngipin|Pangnguya', 'sapatos|Isinusuot sa paa', 'sumbrero|Isinusuot sa ulo', 'dyaket|Pampainit na damit',
  'singsing|Alahas sa daliri', 'kulay|Pula o asul', 'musika|Tunog at ritmo', 'awit|Inaawit',
  'laro|Libangan', 'bola|Bilog na laruan', 'umaga|Simula ng araw', 'gabi|Madilim na oras',
  'linggo|Pitong araw', 'taon|Labindalawang buwan', 'kaibigan|Malapit na kasama', 'pamilya|Magulang at anak',
  'pangalan|Tawag sa iyo', 'pera|Pambayad', 'palengke|Pamilihan', 'mapa|Nagtuturo ng daan',
  'panaginip|Larawan sa pagtulog', 'anino|Dilim sa likod mo', 'kanin|Lutong bigas', 'adobo|Ulam na may suka at toyo',
];

const List<String> kProverbsFil = [
  'Ang hindi lumingon sa pinanggalingan ay hindi makararating sa paroroonan', 'Kapag may tiyaga may nilaga',
  'Nasa Diyos ang awa nasa tao ang gawa', 'Ang taong nagigipit sa patalim kumakapit',
  'Habang maikli ang kumot matutong mamaluktot', 'Walang mahirap na gawa kapag dinaan sa tiyaga',
  'Aanhin pa ang damo kung patay na ang kabayo', 'Kung ano ang puno siya ang bunga',
  'Pag may isinuksok may madudukot', 'Ang sakit ng kalingkingan damdam ng buong katawan',
  'Bato-bato sa langit ang tamaan ay huwag magagalit', 'Daig ng maagap ang masipag',
  'Madaling maging tao mahirap magpakatao', 'Ang pagsasabi ng tapat ay pagsasama ng maluwat',
  'Ubos-ubos biyaya bukas nakatunganga', 'Sa oras ng kagipitan makikilala ang tunay na kaibigan',
  'Ang hipong tulog ay tinatangay ng agos', 'Matibay ang walis palibhasa ay magkabigkis',
  'Ang lumalakad nang matulin kung matinik ay malalim', 'Ang buhay ay parang gulong minsan nasa ibabaw minsan nasa ilalim',
  'Pagkahaba-haba man ng prusisyon sa simbahan din ang tuloy', 'Walang matimtimang birhen sa matiyagang manalangin',
  'Kung may itinanim may aanihin',
];

const List<String> kGroupsFil = [
  'Prutas|mansanas saging mangga dalandan ubas pinya papaya pakwan',
  'Gulay|karot patatas sibuyas kamatis kangkong repolyo talong',
  'Alagang hayop|aso pusa kabayo baka tupa kambing baboy',
  'Ibon|agila kalapati uwak maya tagak loro kuwago',
  'Kulay|pula asul berde dilaw puti itim kayumanggi',
  'Kasangkapan|upuan mesa kama aparador sopa istante bangko',
  'Bahagi ng katawan|ulo kamay paa ilong mata tainga tuhod',
  'Damit|kamiseta pantalon palda dyaket medyas bestida barong',
  'Hanapbuhay|doktor guro magsasaka mangingisda piloto pulis mananahi',
  'Inumin|tubig gatas katas kape tsaa tsokolate salabat',
  'Panahon|ulan hangin ulap bagyo kidlat kulog ambon',
  'Sasakyan|kotse tren bus barko bisikleta eroplano trak',
  'Instrumento|gitara biyolin plawta tambol piyano kudyapi trumpeta',
  'Kagamitan|martilyo lagari plais pala itak kutsilyo turnilyo',
];

const List<String> kSynonymsFil = [
  'maganda|marikit', 'matalino|marunong', 'masaya|maligaya', 'malungkot|mapanglaw',
  'mabilis|matulin', 'kaibigan|katoto', 'bahay|tahanan', 'pera|salapi',
  'sagot|tugon', 'takot|sindak', 'galit|poot', 'matanda|gurang',
  'pagod|hapo', 'regalo|handog', 'mahirap|dukha',
];

const List<String> kAntonymsFil = [
  'malaki|maliit', 'mahaba|maikli', 'mainit|malamig', 'maliwanag|madilim',
  'mabilis|mabagal', 'matanda|bata', 'mataas|mababa', 'araw|gabi',
  'matigas|malambot', 'marami|kaunti', 'malapit|malayo', 'magaan|mabigat',
  'mahirap|mayaman', 'maaga|huli', 'bukas|sarado', 'maingay|tahimik',
  'pasok|labas', 'masaya|malungkot',
];
