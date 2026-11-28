# Kelime oyunlarının engel listesi ve "yalnızca kabul" listeleri.
#  - data/blocklist.dart: uygunsuz kelimeler (dil başına tam eşleşme + kök önekleri).
#    Kaynak: LDNOOBW (CC BY 4.0) + elle derlenen liste (tool/block_src.json).
#  - data/accept_<dil>.dart: yaygın ama ana listede olmayan kelimeler (çekimli biçimler,
#    işlev kelimeleri). Yalnızca girilen kelimeyi kabul etmek için kullanılır; bölüm
#    cevabı/ızgara kelimesi olarak SEÇİLMEZ. Kaynak: wordfreq (Apache-2.0, veri CC BY-SA 4.0).
import re, json, sys, unicodedata, os, wordfreq
def q(x):
    return x.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')
T = os.path.dirname(os.path.abspath(__file__))
D = sys.argv[1] if len(sys.argv) > 1 else T + '/../lib/src/data'
RAW = sys.argv[2] if len(sys.argv) > 2 else None   # LDNOOBW ve bad_*.txt klasörü (isteğe bağlı)
N = 30000
LETTER = 'tr en de es fr it pt nl sv da nb pl cs ro hu ru uk el fi id ms fil ar fa he ur ja'.split()
B = json.load(open(T + '/block_src.json', encoding='utf-8'))
STEMS = json.load(open(T + '/block_stems.json', encoding='utf-8'))
def base(l):
    s = open(f'{D}/words_{l}.dart', encoding='utf-8').read()
    return [w for x in re.findall(r"'([^']*)'", s) for w in x.split()]
def h2k(w):
    return ''.join(chr(ord(c) + 0x60) if 'ぁ' <= c <= 'ゖ' else c for c in w)
def low(w, l):
    if l == 'tr': w = w.replace('I', 'ı').replace('İ', 'i')
    return unicodedata.normalize('NFC', w.strip().lower())
ext = {}
if RAW:
    for f, l in [('tr','tr'),('de','de'),('es','es'),('fr','fr'),('it','it'),('pt','pt'),('nl','nl'),('sv','sv'),('da','da'),('no','nb'),('pl','pl'),('cs','cs'),('hu','hu'),('ru','ru'),('fil','fil'),
                 ('bad_en.txt','en'),('bad_ar.txt','ar'),('bad_fa.txt','fa'),('bad_fi.txt','fi'),('bad_ja.txt','ja')]:
        p = f'{RAW}/{f}' if f.endswith('.txt') else f'{RAW}/{f}.txt'
        if os.path.exists(p):
            ext.setdefault(l, set()).update(low(x, l) for x in open(p, encoding='utf-8', errors='ignore') if x.strip() and ' ' not in x.strip())
def blocked(w, l):
    if w in B.get(l, '').split() or w in ext.get(l, ()): return True
    return any(w.startswith(s) for s in STEMS.get(l, []))
en_top = {w: wordfreq.word_frequency(w, 'en') for w in wordfreq.top_n_list('en', 20000)}
tot = 0
for l in LETTER:
    b = base(l); bs = set(b); chars = set(''.join(b))
    out = []
    for w in wordfreq.top_n_list(l, N):
        w = unicodedata.normalize('NFC', w)
        if l == 'ja': w = h2k(w)
        if not (3 <= len(w) <= 8) or w in bs or not all(c in chars for c in w): continue
        if blocked(w, l): continue
        if l != 'en' and w in en_top and en_top[w] > wordfreq.word_frequency(w, l): continue
        out.append(w)
    s = ' '.join(out); tot += len(s.encode())
    with open(f'{D}/accept_{l}.dart', 'w', encoding='utf-8') as f:
        f.write('// Kaynak: wordfreq (Apache-2.0; veri CC BY-SA 4.0). tool/build_accept.py ile üretilir; elle değiştirmeyin.\n')
        f.write('// Yalnızca oyuncunun girdiği kelimeyi kabul etmek için: bölüm kelimesi olarak seçilmez.\n')
        f.write(f"const String accept{l[0].upper()+l[1:]} = '{q(s)}';\n")
    print(l, len(out))
print('bytes', tot)
# Engel listesi (çalışma anında bütün listelere uygulanır).
with open(f'{D}/blocklist.dart', 'w', encoding='utf-8') as f:
    f.write('// Uygunsuz kelimeler: kaba söz, hakaret, cinsellik, uyuşturucu, alkol, kumar, ağır şiddet.\n')
    f.write('// Kaynak: LDNOOBW (CC BY 4.0) + elle derlenen liste. tool/build_accept.py ile üretilir.\n')
    f.write('const Map<String, String> kBlockedWords = {\n')
    for l in sorted(set(B) | set(ext)):
        ws = sorted(set(B.get(l, '').split()) | ({x for x in ext.get(l, ()) if len(x) >= 2} if l in ('nb', 'fil') else set()))
        f.write(f"  '{l}': '{q(' '.join(ws))}',\n")
    f.write('};\n\n/// Kök önekleri: bu öneklerle başlayan kelimeler de engellenir.\n')
    f.write('const Map<String, List<String>> kBlockedStems = {\n')
    for l, st in sorted(STEMS.items()):
        f.write(f"  '{l}': [{', '.join(chr(39) + q(s) + chr(39) for s in st)}],\n")
    f.write('};\n')
