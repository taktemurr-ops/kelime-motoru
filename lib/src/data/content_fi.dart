// fi: kelime ailesinin ipucu, atasözü, kategori ve eş/zıt anlam içeriği.
// Stüdyonun kendi metinleri; atasözleri halk malıdır (kamu malı).

const List<String> kCluesFi = [
  'omena|Punainen tai vihreä hedelmä', 'leipä|Paistetaan uunissa', 'joki|Virtaava vesi', 'meri|Suuri suolainen vesi',
  'saari|Maata veden keskellä', 'vuori|Hyvin korkea mäki', 'metsä|Paljon puita', 'pilvi|Leijuu taivaalla',
  'sade|Tulee pilvistä', 'lumi|Valkoista talvella', 'aurinko|Päivän tähti', 'kuu|Maan kiertolainen',
  'tähti|Yötaivaan valo', 'tuuli|Liikkuva ilma', 'jää|Jäätynyttä vettä', 'tuli|Liekit ja kuumuus',
  'kivi|Kova kallion pala', 'hiekka|Rannalla ja aavikolla', 'kukka|Kukkii puutarhassa', 'puu|Runko ja oksat',
  'ruoho|Vihreä nurmi', 'lehti|Kasvaa oksassa', 'koira|Haukkuva lemmikki', 'kissa|Naukuva lemmikki',
  'hevonen|Ratsastettava eläin', 'lintu|Siivet ja höyhenet', 'kala|Ui kiduksilla', 'hiiri|Pieni jyrsijä',
  'lehmä|Antaa maitoa', 'lammas|Antaa villaa', 'ankka|Kvaakkiva vesilintu', 'pöllö|Yön lintu',
  'jänis|Pitkäkorva', 'kettu|Ovela punainen eläin', 'karhu|Metsän iso eläin', 'leijona|Eläinten kuningas',
  'susi|Ulvoo yöllä', 'talo|Paikka asua', 'ovi|Siitä mennään sisään', 'ikkuna|Lasi seinässä',
  'katto|Talon päällä', 'seinä|Erottaa huoneet', 'tuoli|Istumista varten', 'pöytä|Syödään sen ääressä',
  'sänky|Nukkumista varten', 'lamppu|Antaa valoa', 'kello|Näyttää ajan', 'kirja|Monta sivua',
  'kirje|Tulee postissa', 'kynä|Kirjoittamiseen', 'koulu|Oppimisen paikka', 'opettaja|Opettaa lapsia',
  'lääkäri|Hoitaa sairaita', 'kokki|Työskentelee keittiössä', 'puutarha|Kukkapenkkejä', 'katu|Autojen tie',
  'silta|Joen yli', 'kaupunki|Paljon taloja ja ihmisiä', 'kylä|Pieni asutus', 'auto|Neljä pyörää',
  'juna|Kulkee kiskoilla', 'laiva|Kulkee meren yli', 'pyörä|Polkimet ja kaksi rengasta', 'maito|Valkoinen juoma',
  'vesi|Janon sammuttaja', 'juusto|Tehdään maidosta', 'hunaja|Mehiläisten makea', 'sokeri|Makeuttaa',
  'suola|Maustaa ruoan', 'keitto|Lämmin ruoka lautasella', 'kakku|Makea leivonnainen', 'muna|Kanan antama',
  'nenä|Haistamiseen', 'silmä|Näkemiseen', 'korva|Kuulemiseen', 'suu|Puhumiseen',
  'käsi|Viisi sormea', 'jalka|Kenkä sen ympärillä', 'sydän|Pumppaa verta', 'pää|Vartalon yläpää',
  'hammas|Suussa puremiseen', 'kenkä|Jalkaan puettava', 'hattu|Päähän puettava', 'takki|Lämmin päällysvaate',
  'sormus|Koru sormessa', 'väri|Punainen tai sininen', 'musiikki|Säveliä ja rytmiä', 'laulu|Lauletaan',
  'peli|Hauskaa ajanvietettä', 'pallo|Pyöreä leikkikalu', 'aamu|Päivän alku', 'ilta|Päivän loppu',
  'viikko|Seitsemän päivää', 'vuosi|Kaksitoista kuukautta', 'kesä|Lämmin vuodenaika', 'talvi|Kylmä vuodenaika',
  'kevät|Kukkiva vuodenaika', 'syksy|Lehdet putoavat', 'ystävä|Läheinen ihminen', 'perhe|Vanhemmat ja lapset',
  'lapsi|Nuori ihminen', 'nimi|Sillä sinua kutsutaan', 'raha|Maksamiseen', 'kartta|Näyttää tien',
  'uni|Kuvia nukkuessa', 'valo|Tekee valoisaksi', 'varjo|Tumma kuvio takanasi', 'sauna|Löylyä ja lämpöä',
  'järvi|Suomessa niitä on tuhansia',
];

const List<String> kProverbsFi = [
  'Ei oppi ojaan kaada', 'Hiljaa hyvä tulee',
  'Joka kuuseen kurkottaa se katajaan kapsahtaa', 'Parempi myöhään kuin ei milloinkaan',
  'Oma maa mansikka muu maa mustikka', 'Ei savua ilman tulta',
  'Rapatessa roiskuu', 'Aika parantaa haavat',
  'Moni kakku päältä kaunis', 'Ahkeruus kovankin onnen voittaa',
  'Niin metsä vastaa kuin sinne huudetaan', 'Tyhjät tynnyrit kolisevat eniten',
  'Hätä ei lue lakia', 'Suutarin lapsilla ei ole kenkiä',
  'Ei kukaan ole seppä syntyessään', 'Aamu on iltaa viisaampi',
  'Joka toiselle kuoppaa kaivaa se itse siihen lankeaa', 'Puhuminen on hopeaa vaikeneminen kultaa',
  'Oma koti kullan kallis', 'Vahinko ei tule kello kaulassa',
  'Ei omena kauas puusta putoa', 'Paistaa se päivä risukasaankin',
  'Hyvää kannattaa odottaa', 'Kyllä työ tekijänsä neuvoo',
  'Minkä taakseen jättää sen edestään löytää',
];

const List<String> kGroupsFi = [
  'Hedelmät|omena päärynä kirsikka banaani rypäle luumu sitruuna',
  'Vihannekset|porkkana peruna sipuli tomaatti kurkku paprika pinaatti',
  'Kotieläimet|koira kissa hevonen lehmä lammas vuohi sika',
  'Linnut|varis kyyhky korppi pöllö kotka varpunen joutsen',
  'Värit|punainen sininen vihreä keltainen valkoinen musta ruskea',
  'Huonekalut|tuoli pöytä sänky kaappi sohva hylly lipasto',
  'Ruumiinosat|pää käsi jalka nenä silmä korva polvi',
  'Vaatteet|paita housut hame takki villapaita sukka mekko',
  'Ammatit|lääkäri opettaja kokki leipuri lentäjä maalari puutarhuri',
  'Juomat|vesi maito mehu kahvi tee kaakao limonadi',
  'Sää|sade lumi tuuli sumu rae myrsky ukkonen',
  'Kulkuneuvot|auto juna bussi laiva polkupyörä lentokone traktori',
  'Soittimet|viulu kitara huilu rumpu piano harppu trumpetti',
  'Työkalut|vasara saha pihdit pora lapio viila taltta',
];

const List<String> kSynonymsFi = [
  'nopea|ripeä', 'suuri|iso', 'pieni|vähäinen', 'kaunis|sievä',
  'älykäs|viisas', 'iloinen|hilpeä', 'hiljainen|äänetön', 'puhua|jutella',
  'katsoa|tarkastella', 'ystävä|kaveri', 'pelko|kauhu', 'rohkea|urhea',
  'vanha|iäkäs', 'väsynyt|uupunut', 'vihainen|suuttunut',
];

const List<String> kAntonymsFi = [
  'iso|pieni', 'pitkä|lyhyt', 'kuuma|kylmä', 'valoisa|pimeä',
  'nopea|hidas', 'vanha|nuori', 'täysi|tyhjä', 'ylhäällä|alhaalla',
  'päivä|yö', 'kova|pehmeä', 'paljon|vähän', 'lähellä|kaukana',
  'kevyt|raskas', 'köyhä|rikas', 'aikaisin|myöhään', 'auki|kiinni',
  'äänekäs|hiljainen', 'sairas|terve',
];
