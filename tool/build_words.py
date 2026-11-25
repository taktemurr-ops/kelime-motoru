# Kelime listeleri: FrequencyWords (OpenSubtitles 2018, CC BY-SA 4.0) sıklık listesi,
# hunspell sözlüğüyle yalnızca süzgeç olarak (sözlük içeriği dağıtılmaz) ve
# LDNOOBW (CC BY 4.0) + elle eklenen uygunsuz kelime süzgeci.
# Çıktı: kelime-motoru/lib/src/data/words_<dil>.dart (sıklık sırasıyla, boşlukla ayrılmış).
import os, re, unicodedata, json
R = os.path.dirname(os.path.abspath(__file__)) + '/raw'
OUT = '/home/claude/kelime-motoru/lib/src/data'
os.makedirs(OUT, exist_ok=True)

ALPHA = {
    'tr': 'abcçdefgğhıijklmnoöprsştuüvyz',
    'en': 'abcdefghijklmnopqrstuvwxyz',
    'de': 'abcdefghijklmnopqrstuvwxyzäöüß',
    'es': 'abcdefghijklmnñopqrstuvwxyzáéíóúü',
    'fr': 'abcdefghijklmnopqrstuvwxyzàâçéèêëîïôûùüÿœ',
    'it': 'abcdefghijklmnopqrstuvwxyzàèéìòù',
    'pt': 'abcdefghijklmnopqrstuvwxyzáâãàçéêíóôõú',
    'nl': 'abcdefghijklmnopqrstuvwxyz',
    'sv': 'abcdefghijklmnopqrstuvwxyzåäö',
    'da': 'abcdefghijklmnopqrstuvwxyzæøå',
    'nb': 'abcdefghijklmnopqrstuvwxyzæøå',
    'pl': 'aąbcćdeęfghijklłmnńoóprsśtuwyzźż',
    'cs': 'aábcčdďeéěfghiíjklmnňoóprřsštťuúůvwxyýzž',
    'ro': 'aăâbcdefghiîjklmnopqrsștțuvwxyz',
    'hu': 'aábcdeéfghiíjklmnoóöőpqrstuúüűvwxyz',
    'ru': 'абвгдеёжзийклмнопрстуфхцчшщъыьэюя',
    'uk': 'абвгґдеєжзиіїйклмнопрстуфхцчшщьюя',
    'el': 'αβγδεζηθικλμνξοπρστυφχψωάέήίόύώϊϋΐΰς',
}
FW = {'nb': 'no'}
# Elle eklenen ek süzgeç (bütün dillere): kaba sözler, şiddet ve yetişkin içerik çağrışımları.
EXTRA = set('''sex seks porn porno nude nazi hitler kill killer murder rape drug drugs cocaine heroin
casino bahis kumar rulet poker slot bet bets gamble gambling whisky vodka beer bira rakı şarap wine
bomb bomba gun guns silah tabanca ölüm ölmek öldür intihar suicide kys dead death corpse ceset kan blood
nigger nigga fag faggot retard bitch slut whore fuck shit dick cock pussy cunt piss ass arse bastard'''.split())

def norm(w):
    return unicodedata.normalize('NFC', w.strip())

def lower(w, l):
    if l == 'tr':
        w = w.replace('I', 'ı').replace('İ', 'i')
    return w.lower()

def dic_words(l):
    p = f'{R}/dic_{l}.dic'
    keep_upper = l == 'de'
    s = set()
    if not os.path.exists(p):
        return None
    for i, line in enumerate(open(p, encoding='utf-8', errors='ignore')):
        if i == 0 or line.startswith('\t'):
            continue
        w = norm(line.split('/')[0].split('\t')[0])
        if not w:
            continue
        if w[0].isupper() and not keep_upper:
            continue
        s.add(lower(w, l))
    return s

def bad(l):
    b = set(EXTRA)
    for x in (l, 'en'):
        p = f'{R}/bad_{x}.txt'
        if os.path.exists(p) and os.path.getsize(p) > 0 and not open(p, errors='ignore').read(20).startswith('404'):
            for line in open(p, encoding='utf-8', errors='ignore'):
                w = lower(norm(line), x)
                if w and ' ' not in w:
                    b.add(w)
    return b

import sys

# --- 2. dalga diller (fi, id, ms, fil, ar, fa, he, ur, ja) ---
# Kaynaklar (raw/ altında; yalnızca süzgeç olarak kullanılır, içerikleri dağıtılmaz):
#   fw_<dil>.txt      FrequencyWords 2018 (fil: tl_full, ur: ur_full)
#   dic_<dil>.dic/aff LibreOffice hunspell (ar, fa, he, id) -> spylls ile çekimli biçim denetimi
#   kotus_fi.txt      Kotus nykysuomen sanalista (CC BY 4.0) -> fi temel biçim süzgeci
#   wordfreq (Apache-2.0, veri CC BY-SA 4.0) -> ms, fil, ur ikinci derlem; ja sıklık
#   jamdict-data (JMdict, CC BY-SA 4.0) -> ja okunuş (katakana) ve sözcük türü
# Bu diller için: python3 -m venv v && v/bin/pip install wordfreq spylls jamdict jamdict-data
#                 v/bin/python tool/build_words.py fi id ms fil ar fa he ur ja
ALPHA2 = {
    'fi': 'abcdefghijklmnopqrstuvwxyzäö',
    'id': 'abcdefghijklmnopqrstuvwxyz',
    'ms': 'abcdefghijklmnopqrstuvwxyz',
    'fil': 'abcdefghijklmnopqrstuvwxyz',
    'ar': 'ءابةتثجحخدذرزسشصضطظعغفقكلمنهوىيؤئ',
    'fa': 'آابپتثجچحخدذرزژسشصضطظعغفقکگلمنوهیئ',
    'ur': 'آابپتٹثجچحخدڈذرڑزژسشصضطظعغفقکگلمنںوؤہھءیےئ',
    'he': 'אבגדהוזחטיכלמנסעפצקרשת',
    'ja': 'アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポヴー',
}
HARAKAT = dict.fromkeys(map(ord, '\u064b\u064c\u064d\u064e\u064f\u0650\u0651\u0652\u0670\u0640'), None)
NIQQUD = dict.fromkeys(list(range(0x05B0, 0x05BE)) + [0x05BF, 0x05C1, 0x05C2, 0x05C7], None)
FOLD2 = {
    'ar': {'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ٱ': 'ا'},
    'fa': {'ي': 'ی', 'ى': 'ی', 'ك': 'ک', 'ة': 'ه', 'أ': 'ا', 'إ': 'ا', 'ؤ': 'و', 'ۀ': 'ه'},
    'ur': {'ي': 'ی', 'ى': 'ی', 'ك': 'ک', 'ه': 'ہ', 'ۂ': 'ہ', 'ۓ': 'ے', 'أ': 'ا', 'إ': 'ا', 'ة': 'ہ'},
    'he': {'ך': 'כ', 'ם': 'מ', 'ן': 'נ', 'ף': 'פ', 'ץ': 'צ'},
}
# Elle eklenen kaba söz süzgeci (LDNOOBW'de olmayan diller için).
BAD2 = {
    'fil': set('puki puke titi puta putang putangina punyeta punyetang gago tarantado ulol kantot iyot jakol tamod pokpok libog malibog bayag burat pekpek kupal leche pakyu hindot tangina syet'.split()),
    'id': set('kontol memek ngentot bangsat jembut pepek sundal pelacur bajingan keparat tolol pantat lonte perek ngewe colmek'.split()),
    'ms': set('kontol puki pukimak lancau pantat sundal pelacur bangsat keparat jalang'.split()),
    'he': set('זונה כוס זינ שרמוטה מזדיינ לזיינ זיונ מניאק בנזונה כוסית'.split()),
    'ur': set('کتی حرامی چوتیا بہنچود مادرچود گانڈو لنڈ رنڈی کنجر بھڑوا'.split()),
    'ar': set('شرموطة قحبة كس زب منيوك عاهرة خول'.split()),
    'fa': set('کیر کس جنده کونی گاییدن حرومزاده'.split()),
}
# Elle eklenen özel ad süzgeci (derlemlerde sık geçen kişi/yer adları).
NAMES2 = {
    'ur': set('محمد خان علی احمد حسن حسین عمران نواز شریف عمر عثمان ابوبکر فاطمہ عائشہ زرداری بھٹو آصف شاہ راشد رحیم طیب عرفان علوی نقوی قادری چوہدری چودھری اسلام آباد لاہور کراچی پشاور کوئٹہ ملتان پنجاب سندھ بلوچستان امریکہ بھارت انڈیا چین ایران افغانستان سعودی برطانیہ لندن پاکستان اللہ'.split()),
    'fil': set('juan jose maria pedro manuel antonio carlos luis rizal bonifacio aguinaldo marcos aquino duterte estrada arroyo ramos magsaysay quezon manila cebu davao luzon mindanao visayas pasig makati taguig napoles naia binay robredo pacquiao abs cbn gma'.split()),
}

def fold2(w, l):
    w = norm(w)
    if l in ('ar', 'fa', 'ur'):
        w = w.translate(HARAKAT)
    if l == 'he':
        w = w.translate(NIQQUD)
    if l in FOLD2:
        w = ''.join(FOLD2[l].get(ch, ch) for ch in w)
    return lower(w, l)

def fw_list(l):
    p = f'{R}/fw_{l}.txt'
    return [line.split(' ')[0] for line in open(p, encoding='utf-8', errors='ignore') if line.strip()]

def source2(l):
    """(kelime sırası, geçerlilik denetimi) döndürür."""
    import wordfreq
    if l == 'ja':
        return json.load(open(f'{R}/ja_words.json', encoding='utf-8')), (lambda w: True)
    if l in ('ar', 'fa', 'he', 'id'):
        from spylls.hunspell import Dictionary
        d = Dictionary.from_files(f'{R}/dic_{l}')
        return fw_list(l), (lambda w, d=d: d.lookup(w))
    if l == 'fi':
        kot = set(lower(norm(x), 'fi') for x in open(f'{R}/kotus_fi.txt', encoding='utf-8'))
        return fw_list(l), kot.__contains__
    if l == 'ms':
        from spylls.hunspell import Dictionary
        d = Dictionary.from_files(f'{R}/dic_id')
        wf = set(wordfreq.top_n_list('ms', 100000))
        # Malayca: iki bağımsız derlemde geçen ve Endonezce/Malayca ortak sözlükte bulunan biçimler.
        return fw_list(l), (lambda w: w in wf and d.lookup(w))
    if l == 'fil':
        from spylls.hunspell import Dictionary
        en = Dictionary.from_files(f'{R}/dic_en')
        fw = set(lower(norm(x), l) for x in fw_list(l))
        top = wordfreq.top_n_list('fil', 100000)
        rank = {w: i for i, w in enumerate(top)}
        # Filipince: iki derlemde birden geçen ya da wordfreq'te ilk 12 000'de olan, İngilizce olmayan kelimeler.
        return top, (lambda w: (w in fw or rank.get(w, 10**9) < 12000) and not en.lookup(w) and not en.lookup(w.capitalize()))
    if l == 'ur':
        fw = set(lower(norm(x), l).translate(HARAKAT) for x in fw_list(l))
        # Urduca: wordfreq sırası, FrequencyWords derleminde de geçmesi şartıyla.
        return wordfreq.top_n_list('ur', 100000), fw.__contains__
    raise KeyError(l)

def build2(l):
    al = ALPHA2[l]
    order, ok = source2(l)
    bl = set(fold2(b, l) for b in bad(l))
    stems = [b for b in bl if len(b) >= 4]
    # BAD2 ve NAMES2 yalnızca tam eşleşmeyle süzer (kök olarak kullanılırsa masum kelimeleri de keser).
    bl |= set(fold2(b, l) for b in BAD2.get(l, ())) | NAMES2.get(l, set())
    out, seen = [], set()
    for w0 in order:
        raw = norm(w0)
        if l in ('ar', 'fa', 'ur'):
            raw = raw.translate(HARAKAT)
        if l == 'he':
            raw = raw.translate(NIQQUD)
        raw = lower(raw, l)
        w = fold2(w0, l)
        if not (3 <= len(w) <= 10) or w in seen:
            continue
        if any(ch not in al for ch in w) or len(set(w)) == 1:
            continue
        if w in bl or any(w.startswith(s) for s in stems):
            continue
        if not ok(raw):
            continue
        seen.add(w); out.append(w)
        if len(out) >= 14000:
            break
    return out

def write(l, out, src):
    name = 'words' + ''.join(p[0].upper() + p[1:] for p in l.split('_'))
    body = ' '.join(out)
    open(f'{OUT}/words_{l}.dart', 'w', encoding='utf-8').write(
        f"// Kaynak: {src}\n"
        f"// Bu dosya tool/build_words.py ile üretilir; elle değiştirmeyin.\n"
        f"const String {name} = '{body}';\n")

SRC2 = {
    'fi': 'FrequencyWords (OpenSubtitles 2018), CC BY-SA 4.0. Süzgeç: Kotus nykysuomen sanalista (CC BY 4.0), LDNOOBW.',
    'id': 'FrequencyWords (OpenSubtitles 2018), CC BY-SA 4.0. Süzgeç: hunspell (id), LDNOOBW.',
    'ms': 'FrequencyWords (OpenSubtitles 2018), CC BY-SA 4.0. Süzgeç: wordfreq (ms), hunspell (id), LDNOOBW.',
    'fil': 'wordfreq (fil), CC BY-SA 4.0. Süzgeç: FrequencyWords (tl), hunspell (en, İngilizce kelimeleri ayıklamak için), LDNOOBW.',
    'ar': 'FrequencyWords (OpenSubtitles 2018), CC BY-SA 4.0. Süzgeç: hunspell (ar), LDNOOBW. Hareke ve hemze elifleri sadeleştirildi.',
    'fa': 'FrequencyWords (OpenSubtitles 2018), CC BY-SA 4.0. Süzgeç: hunspell (fa), LDNOOBW.',
    'ur': 'wordfreq (ur), CC BY-SA 4.0. Süzgeç: FrequencyWords (ur), LDNOOBW.',
    'he': 'FrequencyWords (OpenSubtitles 2018), CC BY-SA 4.0. Süzgeç: hunspell (he), LDNOOBW. Sonek harfler (ך ם ן ף ץ) düz biçimde saklanır.',
    'ja': 'JMdict (EDRDG, CC BY-SA 4.0) okunuşları, wordfreq (ja) sıklığıyla. Katakana; küçük kana büyük yazılır.',
}

stats = {}
langs = sys.argv[1:] or list(ALPHA) + list(ALPHA2)
for l in langs:
    if l in ALPHA2:
        out = build2(l)
        stats[l] = (len(out), sum(1 for w in out if len(w) == 5))
        write(l, out, SRC2[l])
        continue
    al = ALPHA[l]
    d = dic_words(l)
    bl = bad(l)
    stems = [b for b in bl if len(b) >= 4]
    out, seen = [], set()
    for line in open(f'{R}/fw_{FW.get(l, l)}.txt', encoding='utf-8', errors='ignore'):
        w = lower(norm(line.split(' ')[0]), l)
        if not (3 <= len(w) <= 10) or w in seen:
            continue
        if any(ch not in al for ch in w):
            continue
        if l in ('el',) and w.endswith('ς') is False and 'ς' in w:
            continue
        if d is not None and w not in d:
            continue
        if w in bl or any(w.startswith(s) for s in stems):
            continue
        if len(set(w)) == 1:
            continue
        seen.add(w); out.append(w)
        if len(out) >= 14000:
            break
    stats[l] = (len(out), sum(1 for w in out if len(w) == 5))
    body = ' '.join(out)
    open(f'{OUT}/words_{l}.dart', 'w', encoding='utf-8').write(
        f"// Kaynak: FrequencyWords (OpenSubtitles 2018), CC BY-SA 4.0. Süzgeç: hunspell ({l}), LDNOOBW.\n"
        f"// Bu dosya tool/build_words.py ile üretilir; elle değiştirmeyin.\n"
        f"const String words{l[0].upper()+l[1:]} = '{body}';\n")
print(json.dumps(stats))
