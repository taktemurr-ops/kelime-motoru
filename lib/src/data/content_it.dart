// it: kelime ailesinin ipucu, atasözü, kategori ve eş/zıt anlam içeriği.
// Stüdyonun kendi metinleri; atasözleri halk malıdır (kamu malı).

const List<String> kCluesIt = [
  'mela|Frutto rosso o verde', 'pane|Si cuoce nel forno', 'fiume|Acqua che scorre', 'mare|Grande acqua salata',
  'isola|Terra circondata dall’acqua', 'montagna|Rilievo molto alto', 'bosco|Tanti alberi insieme', 'deserto|Terra secca di sabbia',
  'nuvola|Galleggia nel cielo', 'pioggia|Cade dalle nuvole', 'neve|Fiocchi bianchi d’inverno', 'sole|Stella del giorno',
  'luna|Satellite della Terra', 'stella|Brilla di notte', 'vento|Aria in movimento', 'ghiaccio|Acqua gelata',
  'fuoco|Fiamme e calore', 'pietra|Pezzo di roccia', 'sabbia|Sulla spiaggia', 'fiore|Sboccia in giardino',
  'albero|Tronco e rami', 'foglia|Pende dal ramo', 'radice|Sotto la pianta', 'cane|Animale che abbaia',
  'gatto|Animale che miagola', 'cavallo|Si cavalca', 'uccello|Ali e piume', 'pesce|Nuota con le pinne',
  'ape|Fa il miele', 'topo|Piccolo roditore', 'mucca|Dà il latte', 'pecora|Dà la lana',
  'anatra|Uccello che fa qua qua', 'gufo|Uccello notturno', 'coniglio|Orecchie lunghe', 'volpe|Astuta e rossa',
  'orso|Grande animale del bosco', 'leone|Re degli animali', 'casa|Dove si abita', 'porta|Si apre per entrare',
  'finestra|Vetro nel muro', 'tetto|Copre la casa', 'muro|Divide le stanze', 'sedia|Per sedersi',
  'tavolo|Mobile per mangiare', 'letto|Per dormire', 'lampada|Fa luce', 'orologio|Segna l’ora',
  'libro|Ha tante pagine', 'lettera|Arriva per posta', 'matita|Per scrivere', 'scuola|Luogo per imparare',
  'maestro|Insegna ai bambini', 'medico|Cura i malati', 'cuoco|Lavora in cucina', 'giardino|Fiori e piante',
  'strada|Via della città', 'ponte|Attraversa il fiume', 'città|Tante case e persone', 'paese|Piccolo centro',
  'macchina|Ha quattro ruote', 'treno|Corre sui binari', 'nave|Naviga sul mare', 'aereo|Vola nel cielo',
  'bicicletta|Due ruote e pedali', 'latte|Bevanda bianca', 'acqua|Da bere', 'formaggio|Fatto col latte',
  'miele|Dolce delle api', 'zucchero|Rende dolce', 'sale|Dà sapore', 'zuppa|Piatto caldo',
  'torta|Dolce di festa', 'uovo|Lo fa la gallina', 'naso|Per sentire gli odori', 'occhio|Per vedere',
  'orecchio|Per sentire', 'bocca|Per parlare', 'mano|Ha cinque dita', 'piede|Va nella scarpa',
  'cuore|Pompa il sangue', 'testa|Parte alta del corpo', 'capelli|Crescono sulla testa', 'dente|Serve a mordere',
  'scarpa|Si porta al piede', 'cappello|Si porta in testa', 'cappotto|Giaccone invernale', 'anello|Gioiello del dito',
  'colore|Rosso, blu o verde', 'musica|Note e canzoni', 'canzone|Si canta', 'gioco|È divertente',
  'palla|Rotonda per giocare', 'mattina|Inizio del giorno', 'sera|Fine del giorno', 'notte|Ora buia',
  'settimana|Sette giorni', 'anno|Dodici mesi', 'estate|Stagione calda', 'inverno|Stagione fredda',
  'autunno|Cadono le foglie', 'primavera|Stagione dei fiori', 'amico|Persona cara', 'famiglia|Genitori e figli',
  'bambino|Persona piccola', 'nome|Come ti chiami', 'denaro|Per pagare', 'mercato|Luogo di acquisti',
  'mappa|Mostra la strada', 'sogno|Immagini nel sonno', 'luce|Illumina', 'ombra|Scura dietro di te',
];

const List<String> kProverbsIt = [
  'Chi dorme non piglia pesci', 'Chi va piano va sano e va lontano', 'Tra il dire e il fare c’è di mezzo il mare', 'Chi cerca trova',
  'Meglio tardi che mai', 'Chi trova un amico trova un tesoro', 'Il tempo è denaro', 'Non tutto il male vien per nuocere',
  'Chi semina vento raccoglie tempesta', 'Roma non fu fatta in un giorno', 'Can che abbaia non morde', 'Chi fa da sé fa per tre',
  'A buon intenditor poche parole', 'Ride bene chi ride ultimo', 'Chi ben comincia è a metà dell’opera', 'Volere è potere',
  'Paese che vai usanza che trovi', 'Ogni medaglia ha il suo rovescio', 'Chi si accontenta gode', 'Rosso di sera bel tempo si spera',
  'Una mela al giorno toglie il medico di torno', 'Patti chiari amicizia lunga', 'L’esercizio rende perfetti', 'Non è tutto oro quel che luccica',
  'Chi lascia la strada vecchia per la nuova sa quello che lascia ma non sa quello che trova',
];

const List<String> kGroupsIt = [
  'Frutta|mela pera ciliegia banana uva limone arancia', 'Verdura|carota patata cipolla pomodoro cetriolo lattuga spinaci', 'Animali|cane gatto cavallo mucca pecora capra asino', 'Uccelli|piccione corvo gufo aquila passero cicogna pappagallo',
  'Colori|rosso blu verde giallo bianco nero marrone', 'Mobili|sedia tavolo letto armadio divano scaffale comò', 'Corpo|testa mano piede naso occhio orecchio ginocchio', 'Vestiti|camicia pantaloni gonna cappotto giacca calzino vestito',
  'Mestieri|medico maestro cuoco fornaio pilota pittore giardiniere', 'Bevande|acqua latte succo caffè tè cioccolata limonata', 'Tempo|pioggia neve vento nebbia grandine temporale tuono', 'Veicoli|macchina treno autobus nave bicicletta aereo trattore',
  'Strumenti|violino chitarra flauto tamburo pianoforte arpa tromba', 'Attrezzi|martello sega pinza trapano pala lima forbici',
];

const List<String> kSynonymsIt = [
  'veloce|rapido', 'grande|enorme', 'piccolo|minuscolo', 'bello|carino',
  'furbo|astuto', 'iniziare|cominciare', 'allegro|contento', 'fine|termine',
  'sentiero|viottolo', 'coraggio|audacia', 'parlare|discorrere', 'guardare|osservare',
  'camminare|passeggiare', 'calma|quiete',
];

const List<String> kAntonymsIt = [
  'grande|piccolo', 'lungo|corto', 'caldo|freddo', 'chiaro|scuro',
  'veloce|lento', 'vecchio|giovane', 'pieno|vuoto', 'sopra|sotto',
  'giorno|notte', 'duro|morbido', 'molto|poco', 'vicino|lontano',
  'leggero|pesante', 'povero|ricco', 'presto|tardi', 'aperto|chiuso',
  'malato|sano', 'facile|difficile',
];
