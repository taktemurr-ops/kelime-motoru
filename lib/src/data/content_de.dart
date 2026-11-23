// de: kelime ailesinin ipucu, atasözü, kategori ve eş/zıt anlam içeriği.
// Stüdyonun kendi metinleri; atasözleri halk malıdır (kamu malı).

const List<String> kCluesDe = [
  'apfel|Rotes oder grünes Obst', 'brot|Gebackener Laib', 'fluss|Fließendes Gewässer', 'meer|Großes Salzwasser',
  'insel|Land im Wasser', 'berg|Sehr hoher Hügel', 'wald|Viele Bäume', 'wüste|Trockenes Sandland',
  'wolke|Schwebt am Himmel', 'regen|Fällt aus den Wolken', 'schnee|Weiße Winterflocken', 'sonne|Unser Tagesstern',
  'mond|Begleiter der Erde', 'stern|Licht am Nachthimmel', 'wind|Bewegte Luft', 'eis|Gefrorenes Wasser',
  'feuer|Flammen und Hitze', 'stein|Hartes Stück Fels', 'sand|Am Strand und in der Wüste', 'blume|Blüht im Garten',
  'baum|Hat Stamm und Äste', 'gras|Grüner Rasen', 'blatt|Hängt am Ast', 'wurzel|Unter der Pflanze',
  'hund|Bellendes Haustier', 'katze|Miauendes Haustier', 'pferd|Reittier mit Mähne', 'vogel|Hat Flügel und Federn',
  'fisch|Schwimmt mit Kiemen', 'biene|Macht Honig', 'maus|Kleiner Nager', 'kuh|Gibt Milch',
  'schaf|Gibt Wolle', 'ente|Quakender Wasservogel', 'eule|Nachtvogel', 'hase|Langohr',
  'fuchs|Schlaues rotes Tier', 'bär|Großes Waldtier', 'löwe|König der Tiere', 'haus|Ort zum Wohnen',
  'tür|Öffnet einen Raum', 'fenster|Glas in der Wand', 'dach|Oben auf dem Haus', 'wand|Teilt Räume',
  'stuhl|Zum Sitzen', 'tisch|Möbel zum Essen', 'bett|Zum Schlafen', 'lampe|Spendet Licht',
  'uhr|Zeigt die Zeit', 'buch|Hat viele Seiten', 'brief|Kommt mit der Post', 'stift|Zum Schreiben',
  'schule|Ort zum Lernen', 'lehrer|Unterrichtet Kinder', 'arzt|Heilt Kranke', 'koch|Arbeitet in der Küche',
  'garten|Beete und Blumen', 'straße|Weg für Autos', 'brücke|Führt über den Fluss', 'stadt|Viele Häuser und Menschen',
  'dorf|Kleiner Ort', 'auto|Fährt auf vier Rädern', 'zug|Fährt auf Schienen', 'schiff|Fährt über das Meer',
  'flugzeug|Fliegt am Himmel', 'fahrrad|Zwei Räder und Pedale', 'milch|Weißes Getränk', 'wasser|Zum Trinken',
  'käse|Aus Milch gemacht', 'honig|Süß von Bienen', 'zucker|Macht süß', 'salz|Würzt das Essen',
  'suppe|Warmes Gericht im Teller', 'kuchen|Süßes Gebäck', 'ei|Vom Huhn', 'nase|Zum Riechen',
  'auge|Zum Sehen', 'ohr|Zum Hören', 'mund|Zum Sprechen', 'hand|Hat fünf Finger',
  'fuß|Steckt im Schuh', 'herz|Pumpt das Blut', 'kopf|Oben auf dem Körper', 'haar|Wächst auf dem Kopf',
  'zahn|Im Mund zum Beißen', 'schuh|Trägt man am Fuß', 'hut|Trägt man auf dem Kopf', 'mantel|Warme Jacke',
  'ring|Schmuck am Finger', 'farbe|Rot, Blau oder Grün', 'musik|Lieder und Klänge', 'lied|Wird gesungen',
  'spiel|Macht Spaß', 'ball|Rund zum Spielen', 'morgen|Beginn des Tages', 'abend|Ende des Tages',
  'nacht|Dunkle Zeit', 'woche|Sieben Tage', 'jahr|Zwölf Monate', 'sommer|Heiße Jahreszeit',
  'winter|Kalte Jahreszeit', 'frühling|Blühende Jahreszeit', 'herbst|Blätter fallen', 'freund|Vertrauter Mensch',
  'familie|Eltern und Kinder', 'kind|Junger Mensch', 'name|So heißt man', 'geld|Zum Bezahlen',
  'markt|Ort zum Einkaufen', 'karte|Zeigt den Weg', 'glück|Schönes Gefühl', 'traum|Bilder im Schlaf',
  'licht|Macht es hell', 'schatten|Dunkel hinter dir',
];

const List<String> kProverbsDe = [
  'Übung macht den Meister', 'Morgenstund hat Gold im Mund', 'Ohne Fleiß kein Preis', 'Wer rastet der rostet',
  'Aller Anfang ist schwer', 'Lügen haben kurze Beine', 'Reden ist Silber Schweigen ist Gold', 'Der Apfel fällt nicht weit vom Stamm',
  'Viele Köche verderben den Brei', 'Wer zuletzt lacht lacht am besten', 'Was du heute kannst besorgen das verschiebe nicht auf morgen', 'Kleine Kinder kleine Sorgen große Kinder große Sorgen',
  'Ende gut alles gut', 'Wer nicht wagt der nicht gewinnt', 'Hunde die bellen beißen nicht', 'Steter Tropfen höhlt den Stein',
  'Wo ein Wille ist ist auch ein Weg', 'Eile mit Weile', 'Der frühe Vogel fängt den Wurm', 'Rom wurde nicht an einem Tag erbaut',
  'Wer andern eine Grube gräbt fällt selbst hinein', 'Geteilte Freude ist doppelte Freude', 'Der Klügere gibt nach', 'Es ist noch kein Meister vom Himmel gefallen',
  'Besser spät als nie', 'Auch ein blindes Huhn findet mal ein Korn',
];

const List<String> kGroupsDe = [
  'Obst|apfel birne kirsche banane traube pflaume zitrone', 'Gemüse|karotte kartoffel zwiebel tomate gurke paprika spinat', 'Tiere|hund katze pferd kuh schaf ziege esel', 'Vögel|amsel taube rabe eule adler spatz storch',
  'Farben|rot blau grün gelb weiß schwarz braun', 'Möbel|stuhl tisch bett schrank sofa regal kommode', 'Körper|kopf hand fuß nase auge ohr knie', 'Kleidung|hemd hose rock mantel jacke socke kleid',
  'Berufe|arzt lehrer koch bäcker pilot maler gärtner', 'Getränke|wasser milch saft kaffee tee kakao limonade', 'Wetter|regen schnee wind nebel hagel sturm gewitter', 'Fahrzeuge|auto zug bus schiff fahrrad flugzeug traktor',
  'Instrumente|geige gitarre flöte trommel klavier harfe trompete', 'Werkzeuge|hammer säge zange bohrer schaufel feile meißel',
];

const List<String> kSynonymsDe = [
  'schnell|rasch', 'groß|riesig', 'klein|winzig', 'schön|hübsch',
  'klug|schlau', 'beginnen|anfangen', 'leise|still', 'froh|fröhlich',
  'ende|schluss', 'weg|pfad', 'mut|tapferkeit', 'reden|sprechen',
  'sehen|schauen', 'gehen|laufen', 'ruhe|stille',
];

const List<String> kAntonymsDe = [
  'groß|klein', 'lang|kurz', 'heiß|kalt', 'hell|dunkel',
  'schnell|langsam', 'alt|jung', 'voll|leer', 'oben|unten',
  'tag|nacht', 'hart|weich', 'viel|wenig', 'nah|fern',
  'leicht|schwer', 'arm|reich', 'früh|spät', 'offen|geschlossen',
  'laut|leise', 'krank|gesund',
];
