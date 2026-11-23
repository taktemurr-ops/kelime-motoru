// pl: kelime ailesinin ipucu, atasözü, kategori ve eş/zıt anlam içeriği.
// Stüdyonun kendi metinleri; atasözleri halk malıdır (kamu malı).

const List<String> kCluesPl = [
  'jabłko|Czerwony lub zielony owoc', 'chleb|Pieczony w piecu', 'rzeka|Płynąca woda', 'morze|Wielka słona woda',
  'wyspa|Ląd otoczony wodą', 'góra|Bardzo wysokie wzniesienie', 'las|Dużo drzew', 'pustynia|Sucha piaszczysta kraina',
  'chmura|Płynie po niebie', 'deszcz|Pada z chmur', 'śnieg|Białe zimowe płatki', 'słońce|Gwiazda dnia',
  'księżyc|Satelita Ziemi', 'gwiazda|Świeci nocą', 'wiatr|Poruszające się powietrze', 'lód|Zamarznięta woda',
  'ogień|Płomienie i ciepło', 'kamień|Kawałek skały', 'piasek|Jest na plaży', 'kwiat|Kwitnie w ogrodzie',
  'drzewo|Pień i gałęzie', 'liść|Wisi na gałęzi', 'korzeń|Pod rośliną', 'pies|Szczeka',
  'kot|Miauczy', 'koń|Można na nim jeździć', 'ptak|Skrzydła i pióra', 'ryba|Pływa w wodzie',
  'pszczoła|Robi miód', 'mysz|Mały gryzoń', 'krowa|Daje mleko', 'owca|Daje wełnę',
  'kaczka|Ptak który kwacze', 'sowa|Nocny ptak', 'królik|Długie uszy', 'lis|Sprytny i rudy',
  'niedźwiedź|Duże zwierzę leśne', 'lew|Król zwierząt', 'dom|Miejsce do mieszkania', 'drzwi|Otwierasz je wchodząc',
  'okno|Szkło w ścianie', 'dach|Na górze domu', 'ściana|Dzieli pokoje', 'krzesło|Do siedzenia',
  'stół|Mebel do jedzenia', 'łóżko|Do spania', 'lampa|Daje światło', 'zegar|Pokazuje godzinę',
  'książka|Ma wiele stron', 'list|Przychodzi pocztą', 'ołówek|Do pisania', 'szkoła|Miejsce nauki',
  'nauczyciel|Uczy dzieci', 'lekarz|Leczy chorych', 'kucharz|Pracuje w kuchni', 'ogród|Kwiaty i grządki',
  'ulica|Droga w mieście', 'most|Prowadzi przez rzekę', 'miasto|Wiele domów i ludzi', 'wieś|Mała miejscowość',
  'samochód|Cztery koła', 'pociąg|Jedzie po torach', 'statek|Pływa po morzu', 'samolot|Lata w powietrzu',
  'rower|Dwa koła i pedały', 'mleko|Biały napój', 'woda|Do picia', 'ser|Zrobiony z mleka',
  'miód|Słodki od pszczół', 'cukier|Słodzi', 'sól|Dodaje smaku', 'zupa|Ciepłe danie',
  'ciasto|Słodkie na święto', 'jajko|Znosi je kura', 'nos|Do wąchania', 'oko|Do patrzenia',
  'ucho|Do słuchania', 'usta|Do mówienia', 'ręka|Pięć palców', 'noga|Do chodzenia',
  'serce|Pompuje krew', 'głowa|Na górze ciała', 'włosy|Rosną na głowie', 'ząb|Do gryzienia',
  'but|Nosi się na stopie', 'kapelusz|Nosi się na głowie', 'płaszcz|Ciepłe okrycie', 'pierścionek|Ozdoba na palcu',
  'kolor|Czerwony, niebieski lub zielony', 'muzyka|Dźwięki i piosenki', 'piosenka|Śpiewa się ją', 'gra|Daje zabawę',
  'piłka|Okrągła do gry', 'ranek|Początek dnia', 'wieczór|Koniec dnia', 'noc|Ciemna pora',
  'tydzień|Siedem dni', 'rok|Dwanaście miesięcy', 'lato|Ciepła pora roku', 'zima|Zimna pora roku',
  'jesień|Opadają liście', 'wiosna|Pora kwitnienia', 'przyjaciel|Bliska osoba', 'rodzina|Rodzice i dzieci',
  'dziecko|Mały człowiek', 'imię|Tak się nazywasz', 'pieniądze|Do płacenia', 'targ|Miejsce zakupów',
  'mapa|Pokazuje drogę', 'sen|Obrazy podczas snu', 'światło|Rozjaśnia', 'cień|Ciemny za tobą',
  'arbuz|Duży owoc z pestkami', 'ekran|Na nim oglądasz film', 'herbata|Ciepły napój z liści', 'farba|Do malowania ścian',
  'żaba|Skacze i kumka', 'igła|Do szycia', 'jezioro|Woda otoczona lądem', 'ucieczka|Szybkie oddalenie się',
];

const List<String> kProverbsPl = [
  'Kto rano wstaje temu Pan Bóg daje', 'Lepiej późno niż wcale', 'Gdzie kucharek sześć tam nie ma co jeść', 'Kto pod kim dołki kopie ten sam w nie wpada',
  'Bez pracy nie ma kołaczy', 'Prawdziwych przyjaciół poznaje się w biedzie', 'Co ma wisieć nie utonie', 'Nie wszystko złoto co się świeci',
  'Kropla drąży skałę', 'Mowa jest srebrem a milczenie złotem', 'Apetyt rośnie w miarę jedzenia', 'Darowanemu koniowi w zęby się nie zagląda',
  'Jaki pan taki kram', 'Gdzie dwóch się bije tam trzeci korzysta', 'Kto szuka ten znajdzie', 'Ćwiczenie czyni mistrza',
  'Nie od razu Kraków zbudowano', 'Jedna jaskółka wiosny nie czyni', 'Kto pyta nie błądzi', 'Spiesz się powoli',
  'Lepszy wróbel w garści niż gołąb na dachu', 'Nie chwal dnia przed zachodem słońca',
];

const List<String> kGroupsPl = [
  'Owoce|jabłko gruszka wiśnia banan winogrono cytryna pomarańcza', 'Warzywa|marchew ziemniak cebula pomidor ogórek sałata szpinak', 'Zwierzęta|pies kot koń krowa owca koza osioł', 'Ptaki|gołąb wrona sowa orzeł wróbel bocian papuga',
  'Kolory|czerwony niebieski zielony żółty biały czarny brązowy', 'Meble|krzesło stół łóżko szafa kanapa półka komoda', 'Ciało|głowa ręka noga nos oko ucho kolano', 'Ubrania|koszula spodnie spódnica płaszcz kurtka skarpeta sukienka',
  'Zawody|lekarz nauczyciel kucharz piekarz pilot malarz ogrodnik', 'Napoje|woda mleko sok kawa herbata kakao lemoniada', 'Pogoda|deszcz śnieg wiatr mgła grad burza piorun', 'Pojazdy|samochód pociąg autobus statek rower samolot traktor',
  'Instrumenty|skrzypce gitara flet bęben fortepian harfa trąbka', 'Narzędzia|młotek piła obcęgi wiertarka łopata pilnik nożyczki',
];

const List<String> kSynonymsPl = [
  'szybki|prędki', 'duży|ogromny', 'mały|malutki', 'piękny|ładny',
  'mądry|bystry', 'zaczynać|rozpoczynać', 'wesoły|radosny', 'koniec|finał',
  'ścieżka|dróżka', 'odwaga|męstwo', 'mówić|rozmawiać', 'patrzeć|spoglądać',
  'iść|kroczyć', 'spokój|cisza',
];

const List<String> kAntonymsPl = [
  'duży|mały', 'długi|krótki', 'gorący|zimny', 'jasny|ciemny',
  'szybki|wolny', 'stary|młody', 'pełny|pusty', 'góra|dół',
  'dzień|noc', 'twardy|miękki', 'dużo|mało', 'blisko|daleko',
  'lekki|ciężki', 'biedny|bogaty', 'wcześnie|późno', 'otwarty|zamknięty',
  'chory|zdrowy', 'łatwy|trudny',
];
