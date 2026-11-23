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

stats = {}
for l, al in ALPHA.items():
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
