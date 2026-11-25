# Taş (hece/küme) yazılı diller için kelime listeleri: zh, ko, vi, hi, bn, th.
#
# Bu dillerde tek harf taşı anlamlı değildir; oyunlar kelimeyi "taş" dizisi
# olarak oynar:
#   zh  her Çince karakter bir taş (2-4 karakterli kelimeler ve 4'lü deyimler/成语)
#   ko  her Hangıl hecesi bir taş (klavyeli türler Dart tarafında jamoya ayırır)
#   vi  her hece bir taş (çok heceli kelimeler, ses tonu işaretiyle birlikte)
#   hi, bn  her akşara (ünsüz + bitişik ünsüzler + sesli işareti) bir taş
#   th  her Tay hecesi bir taş
#
# Kaynaklar (tool/raw/ altında, git'e girmez):
#   zh  jieba dict.txt (MIT): kelime, sıklık, sözcük türü (özel adlar nr/ns/nt/nz ayıklanır;
#       deyimler "i"). Sıklık wordfreq (zh) ile birleştirilir. Okunuş: pypinyin (MIT).
#   ko  wordfreq (ko; veri CC BY-SA 4.0) biçimbirim listesi; hunspell-ko (dictionary-ko,
#       GPL/LGPL/MPL) yalnızca "ad" bayraklı (10, 25) giriş süzgeci olarak kullanılır.
#   vi  pyvi words.txt (MIT) ve UD Vietnamese-VTB (CC BY-SA 4.0) çok heceli kelimeleri; sıra
#       VTB sayımı + wordfreq (vi) hece sıklığı ile; VTB'deki özel adlar (PROPN) ayıklanır.
#   hi  wordfreq (hi) + LibreOffice hi_IN hunspell (yalnızca süzgeç, GPL; dağıtılmaz).
#   bn  wordfreq (bn) + LibreOffice bn_BD hunspell kökleri (yalnızca süzgeç; dağıtılmaz).
#   th  PyThaiNLP words_th.txt + tnc_freq.txt (CC0); ad/il/ülke listeleri ve
#       küfür listesi yalnızca süzgeç. Heceleme: PyThaiNLP syllable_tokenize (dict).
#   Uygunsuz kelime: LDNOOBW (CC BY 4.0) + elle eklenen listeler.
#
# Kullanım: python3 -m venv v && v/bin/pip install wordfreq pypinyin pythainlp hanzidentifier
#           v/bin/python -I tool/build_tiles.py [zh ko vi hi bn th]
#
# Çıktı biçimi (lib/src/data/words_<dil>.dart): kelimeler boşlukla ayrılır;
# zh ve ko'da her karakter bir taştır; vi, hi, bn, th'de taşlar '+' ile ayrılır.
import os, re, sys, json, unicodedata

R = os.path.dirname(os.path.abspath(__file__)) + '/raw'
OUT = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + '/lib/src/data'
MAX = 12000


def nfc(s):
    return unicodedata.normalize('NFC', s.strip())


def bad_file(l):
    p = f'{R}/bad_{l}.txt'
    if not os.path.exists(p):
        return set()
    return {nfc(x) for x in open(p, encoding='utf-8', errors='ignore') if x.strip()}


# Elle eklenen kaba söz ve yetişkin içerik süzgeci.
BAD = {
    'zh': set('赌博 赌场 毒品 吸毒 自杀 杀人 强奸 色情 卖淫 妓女 嫖娼 裸体 做爱 性交 屁股 混蛋 王八蛋 笨蛋 傻瓜 他妈 妈的 屎 尸体 枪支 炸弹 恐怖分子 鸦片 海洛因 大麻 酒鬼 白痴 贱人 婊子'.split()),
    'ko': set('도록 다면 인지 라면 이랑 인가 대로 만큼 듯이 한데 도박 마약 자살 살인 강간 섹스 매춘 창녀 시체 총기 폭탄 바보 병신 새끼 개새끼 미친 젠장 씨발 엿 대마초 성교 알몸 매춘부 테러리스트'.split()),
    'vi': set('khủng_bố đụ địt lồn cặc buồi đéo đĩ điếm cave chó_chết mẹ_kiếp đồ_chó con_đĩ ma_túy cờ_bạc tự_tử giết_người hiếp_dâm khiêu_dâm mại_dâm thuốc_phiện heroin cần_sa xác_chết súng_đạn bom_mìn ngu_ngốc thằng_ngu'.split()),
    'hi': set('ऑफ ऑफ़ एंड अफ मौत मृत्यु मार हत्याएं खून लाश हमला जेल चूतिया चूत लंड गांड गाण्ड भोसड़ी भोसडी मादरचोद बहनचोद रंडी हरामी कुत्ता कमीना कमीने साला साली बलात्कार हत्या आत्महत्या जुआ शराब नशा ड्रग्स वेश्या सेक्स नंगा बेवकूफ़ बेवकूफ उल्लू लाश बम बंदूक'.split()),
    'bn': set('অফ অব নিহত খুন হামলা গুলি যৌন মৃত্যু আহত গ্রেফতার আটক চোদা চুদি চুদা বাল খানকি মাগি শালা শালী হারামি হারামজাদা কুত্তা বেশ্যা ধর্ষণ হত্যা আত্মহত্যা জুয়া মদ মাদক সেক্স নগ্ন বোকা গাধা লাশ বোমা বন্দুক পাছা'.split()),
    'th': set('เย็ด ควย หี แตด สัส สัด เหี้ย ไอ้สัตว์ ห่า ระยำ ดอกทอง กะหรี่ โสเภณี เซ็กส์ ฆ่า ฆาตกรรม ข่มขืน ยาเสพติด กัญชา เฮโรอีน การพนัน พนัน ฆ่าตัวตาย ศพ ระเบิด ปืน เหล้า ไอ้โง่ โง่'.split()),
}

# İşlev sözcükleri (edat, zamir, yardımcı fiil): oyun kelimesi olarak anlamsız.
STOP = {
    'hi': set('और पर एक नहीं कर इस यह गया किया आप साथ अपने रहा कुछ कोई दिया तक बाद हम किसी वह बात जब बहुत लेकिन फिर नही हुआ हुए जाता गए गई चाहिए कभी तरह कई करता करें इन उस कम लोगों सब सकता सकते लिया अपना एवं मेरी तुम बस अधिक ज्यादा ओर मेरा खुद केवल क्योंकि जिस आया उनका यहां लगता जाएगा इसलिए उन होना करने करना करते रहे रही अपनी होता होती होते थी थे था वाले वाली वाला उनके उनकी उसके उसकी इसके इसकी जैसे कैसे क्या क्यों कहां कौन किसे जिसे जिसका तथा तब यदि अगर इसे उसे हमें तुम्हें मुझे आपको आपके आपकी हमारे हमारी हमारा तुम्हारा मैंने उन्होंने इसमें उसमें जिसमें यही वही वहां सभी कुल बिना दौरान द्वारा लिए होगा होगी होंगे रहेगा जाने जाती जाते गयी किये किए लगा लगी लगे दें देना देने देता देती'.split()),
    'bn': set('করে এবং এই থেকে আর জন্য তার হয় করা এর একটি আমি হবে সাথে আমার তিনি এক কিছু আমাদের হয়ে কোন ছিল আমরা কিন্তু তাদের মধ্যে তারা অনেক একটা দিয়ে করার আছে পর সব একজন এখন নয় নেই কাছে বলে যদি হতে এটা সেই তাকে আপনি তবে আগে তাই কেউ কেন তুমি করি মতো যাবে এখানে পরে আবার মত প্রতি হল তখন তোমার প্রায় কোনো সঙ্গে তাঁর শুধু তাহলে হলো আরো আরও যার চাই দেয় যারা হলে সবাই সেখানে যেন করেন করছে করেছে করবে করতে হচ্ছে হয়েছে যায় পারে আপনার যা সে যে ও ছিলেন হয়নি থাকে থাকা থাকবে দিতে নিয়ে নিয়েছে গেছে গিয়ে এমন যখন উনি ওই ওরা ওদের তোমরা তোমাদের আমাকে তোমাকে যাকে এসব সেটা কোথায় কখন কীভাবে কেমন'.split()),
}

# Elle eklenen özel ad süzgeci (kişi, yer, ülke, din/kurum adları).
NAMES = {
    'ko': set('이승만 김정은 김정일 김일성 트럼프 오바마 바이든 푸틴 서울 부산 대구 인천 광주 대전 울산 세종 제주 경기 강원 충북 충남 전북 전남 경북 경남 한국 대한민국 미국 일본 중국 북한 남한 영국 프랑스 독일 러시아 캐나다 호주 인도 베트남 태국 이탈리아 스페인 유럽 아시아 아프리카 '
              '조선 고려 신라 백제 고구려 이순신 세종대왕 김구 박정희 김대중 노무현 이명박 박근혜 문재인 윤석열 삼성 현대 엘지 서울대 '
              '김 이 박 최 정 강 조 윤 장 임 한 오 서 신 권 황 안 송 류 홍 철수 영희 민수 지수 민준 서준 하준 지민 서연 예준 도윤 시우 '
              '한강 낙동강 한라산 백두산 설악산 지리산 독도 경주 전주 수원 성남 청주 포항 창원 춘천 강릉 평양 도쿄 베이징 뉴욕 런던 파리 '
              '하나님 예수 그리스도 부처 석가모니 기독교 천주교 불교 이슬람'.split()),
    'zh': set('中国 美国 日本 韩国 朝鲜 英国 法国 德国 俄罗斯 印度 北京 上海 广州 深圳 天津 重庆 香港 澳门 台湾 南京 武汉 西安 成都 杭州 毛泽东 邓小平 孙中山 孔子 老子 孟子 '
              '长江 黄河 长城 泰山 欧洲 亚洲 非洲 美洲 澳洲 联合国 共产党 国民党 中华 华夏 汉族 清朝 明朝 唐朝 宋朝 汉朝 秦朝 耶稣 上帝 佛祖 观音 菩萨 阿拉'.split()),
    'vi': set(),
    'hi': set('भारत हिंदुस्तान हिन्दुस्तान पाकिस्तान चीन अमेरिका इंग्लैंड जापान रूस नेपाल बांग्लादेश दिल्ली मुंबई कोलकाता चेन्नई बंगलौर बेंगलुरु हैदराबाद पुणे लखनऊ पटना जयपुर भोपाल '
              'गंगा यमुना हिमालय कश्मीर पंजाब बिहार गुजरात राजस्थान महाराष्ट्र केरल बंगाल उड़ीसा ओडिशा असम गोवा तमिलनाडु कर्नाटक आंध्र तेलंगाना झारखंड उत्तराखंड हरियाणा '
              'राम कृष्ण शिव विष्णु ब्रह्मा गणेश हनुमान लक्ष्मी सरस्वती दुर्गा पार्वती सीता राधा अर्जुन भीम युधिष्ठिर रावण लक्ष्मण भरत शंकर महादेव '
              'गांधी नेहरू मोदी इंदिरा सोनिया राहुल अमित नरेंद्र मनमोहन अटल अंबेडकर पटेल टैगोर विवेकानंद सुभाष भगत '
              'मोहन सोहन राजू राजेश रमेश सुरेश महेश दिनेश गणेश मुकेश राकेश विकास आकाश प्रकाश सुनील अनिल कपिल राहुल रोहित अमित सुमित सचिन विराट धोनी '
              'सीमा रीता गीता सुनीता अनीता पूजा प्रिया नेहा रेखा मीना कविता ममता लता आशा उषा सुषमा अंजलि '
              'अल्लाह मोहम्मद ईसा यीशु बुद्ध महावीर नानक गुरु'.split()),
    'bn': set('বারাক ওবামা ট্রাম্প বাইডেন পুতিন রহমান খান বিএনপি আওয়ামী লীগ সৌদি ইসলাম মুসলিম হিন্দু মার্কিন ফেসবুক জানুয়ারি ফেব্রুয়ারি মার্চ এপ্রিল মে জুন জুলাই আগস্ট সেপ্টেম্বর অক্টোবর নভেম্বর ডিসেম্বর বাংলাদেশ ভারত পাকিস্তান চীন আমেরিকা জাপান রাশিয়া নেপাল ঢাকা চট্টগ্রাম খুলনা রাজশাহী সিলেট বরিশাল রংপুর ময়মনসিংহ কলকাতা দিল্লি মুম্বাই '
              'পদ্মা মেঘনা যমুনা গঙ্গা ব্রহ্মপুত্র সুন্দরবন কক্সবাজার পশ্চিমবঙ্গ আসাম ত্রিপুরা '
              'রবীন্দ্রনাথ নজরুল শেখ মুজিব মুজিবুর হাসিনা খালেদা জিয়া গান্ধী নেহরু '
              'রহিম করিম রফিক জামাল কামাল আলম হাসান হোসেন আহমেদ মোহাম্মদ মুহাম্মদ আলী ফাতেমা আয়েশা রাম কৃষ্ণ শিব দুর্গা কালী লক্ষ্মী সরস্বতী গণেশ রাধা সীতা '
              'আল্লাহ যীশু বুদ্ধ'.split()),
    'th': set(),
}


def content_words(l):
    """content_<dil>.dart içindeki ipucu yanıtları, kategori kelimeleri, eş/zıt anlam
    çiftleri ve atasözü sözcükleri (taş envanterine eklenecek taşlar için)."""
    p = f'{OUT}/content_{l}.dart'
    if not os.path.exists(p):
        return []
    out, section = [], ''
    for line in open(p, encoding='utf-8'):
        m = re.match(r'const List<String> k(\w+?)[A-Z][a-z]+ =', line)
        if m:
            section = m.group(1)
        for q in re.findall(r"'((?:[^'\\]|\\.)*)'", line):
            if section == 'Clues':
                out.append(q.split('|')[0])
            elif section == 'Groups':
                out += q.split('|', 1)[-1].split(' ')
            elif section in ('Synonyms', 'Antonyms'):
                out += q.split('|')
            elif section == 'Proverbs':
                out += q.split(' ')
    return [nfc(w).lower() for w in out if w.strip()]


PUNCT = re.compile(r'[，。、！？；：“”‘’（）《》,.!?;:\-]')


def extra_tiles(l, words):
    """Kelime listesinde geçmeyen ama içerikte geçen taşlar (sabit sırayla)."""
    have = {t for w in words for t in w.split('+')}
    extra = []
    for w in content_words(l):
        w = PUNCT.sub('', w)
        if not w:
            continue
        if l == 'vi':
            parts = w.split(' ')
        elif l in ('hi', 'bn'):
            parts = aksaras(w.replace(' ', ''), DEVA if l == 'hi' else BENG) or []
        else:
            from pythainlp.tokenize import syllable_tokenize
            parts = [t for t in syllable_tokenize(w.replace(' ', ''), engine='dict') if t.strip()]
        for t in parts:
            if t and t not in have:
                have.add(t)
                extra.append(t)
    return extra


def write(l, words, src, extra=''):
    name = 'words' + l[0].upper() + l[1:]
    body = ' '.join(words)
    assert "'" not in body and '\\' not in body and '$' not in body
    with open(f'{OUT}/words_{l}.dart', 'w', encoding='utf-8') as f:
        f.write(f'// Kaynak: {src}\n// Bu dosya tool/build_tiles.py ile üretilir; elle değiştirmeyin.\n')
        f.write(f"const String {name} = '{body}';\n")
        if extra:
            f.write(extra)


# ---------- Hint ve Bengal yazısı: akşara (hece kümesi) bölme ----------
def _aksara_re(c, nukta, virama, ind, matra, sign):
    C = f'[{c}]{nukta}?'
    return re.compile(f'(?:{C}(?:{virama}[‌‍]?{C})*(?:{matra}|{virama}(?![{c}]))?|{ind}){sign}*')


DEVA = _aksara_re('क-हक़-य़ॸ-ॿ', '़', '्',
                  '[ऄ-औॠॡॲ-ॷ]', '[ऺऻा-ौॎॏॕ-ॗॢॣ]',
                  '[ऀ-ः]')
BENG = _aksara_re('ক-হড়-য়ৎৰৱ', '়', '্',
                  '[অ-ঔৠৡ]', '[া-ৌৗৢৣ]', '[ঁ-ঃ]')


def aksaras(w, rx):
    out, i = [], 0
    while i < len(w):
        m = rx.match(w, i)
        if not m or m.end() == i:
            return None
        out.append(m.group())
        i = m.end()
    return out


def build_indic(l):
    import wordfreq
    rx = DEVA if l == 'hi' else BENG
    if l == 'hi':
        dic = {nfc(x.split('/')[0]) for i, x in enumerate(open(f'{R}/hi_IN.dic', encoding='utf-8')) if i > 0}
    else:
        dic = set()
        for i, x in enumerate(open(f'{R}/bn_BD.dic', encoding='utf-8')):
            if i == 0 or x.startswith('*'):
                continue
            w = nfc(x.split('/')[0])
            if w and not w.endswith('.'):
                dic.add(w)
    bl = BAD[l] | bad_file(l) | STOP[l]
    names = NAMES[l]
    out, seen = [], set()
    for w in wordfreq.top_n_list(l, 400000):
        w = nfc(w).replace('‌', '').replace('‍', '')
        if w in seen or w in bl or w in names or w not in dic:
            continue
        t = aksaras(w, rx)
        if not t or not (2 <= len(t) <= 6):
            continue
        if len(set(t)) == 1:
            continue
        seen.add(w)
        out.append('+'.join(t))
        if len(out) >= MAX:
            break
    return out


# ---------- Vietnamca ----------
VI_LET = set('aăâbcdđeêghiklmnoôơpqrstuưvxyáàảãạắằẳẵặấầẩẫậéèẻẽẹếềểễệíìỉĩịóòỏõọốồổỗộớờởỡợúùủũụứừửữựýỳỷỹỵ')


VI_STOP = set('''có của ở không được thể một như những thì là các và với cho này đó nào khi sẽ đã đang bị mà nên vì nếu thế ra vào lại đi từ
số rồi cũng chỉ còn rất hay hoặc nhưng tại theo về trên dưới trong ngoài sau trước đây kia ấy gì ai đâu sao bao cả mỗi mọi nhiều ít
hơn nhất lắm quá vẫn đều cùng chưa chẳng chăng đến tới để do bởi nhà người con cái chiếc việc sự'''.split())


def vi_corpus():
    """UD Vietnamese-VTB (CC BY-SA 4.0): çok heceli kelime sayımları ve özel adlar."""
    cnt, propn = {}, set()
    for f in ('train', 'dev', 'test'):
        p = f'{R}/vi_vtb-ud-{f}.conllu'
        if not os.path.exists(p):
            continue
        for line in open(p, encoding='utf-8'):
            a = line.rstrip('\n').split('\t')
            if len(a) < 4 or line.startswith('#') or ' ' not in a[1]:
                continue
            w = nfc(a[1]).lower()
            if a[3] == 'PROPN' or a[1][0].isupper() and a[3] not in ('NOUN', 'VERB', 'ADJ'):
                propn.add(w)
            elif a[3] in ('NOUN', 'VERB', 'ADJ', 'ADV', 'NUM'):
                cnt[w] = cnt.get(w, 0) + 1
    return cnt, propn


def build_vi():
    import math, wordfreq
    bl = {b.replace('_', ' ') for b in BAD['vi']}
    cnt, propn = vi_corpus()
    zipf = {}

    def z(p):
        if p not in zipf:
            zipf[p] = wordfreq.zipf_frequency(p, 'vi')
        return zipf[p]

    words = set()
    for line in open(f'{R}/pyvi_words.txt', encoding='utf-8'):
        w = nfc(line)
        if w and w == w.lower():  # büyük harfli girişler: özel ad ya da kısaltma
            words.add(w)
    words |= set(cnt)
    cands = []
    for w in words:
        parts = w.split(' ')
        if not (2 <= len(parts) <= 4) or any(not p or any(ch not in VI_LET for ch in p) for p in parts):
            continue
        if w in propn or w in bl or any(p in bl for p in parts) or len(set(parts)) == 1:
            continue
        # Her hece derlemde geçmeli (yazım hatası ve yabancı söz ayıklanır).
        if any(z(p) < 2.0 for p in parts):
            continue
        stops = sum(1 for p in parts if p in VI_STOP)
        if stops == len(parts) and cnt.get(w, 0) < 2:
            continue
        score = 3.0 * math.log(1 + cnt.get(w, 0)) + sum(z(p) for p in parts) / len(parts) - 1.6 * stops
        cands.append((-score, w))
    cands.sort()
    return ['+'.join(w.split(' ')) for _, w in cands[:MAX]]


# ---------- Çince ----------
def build_zh():
    import wordfreq, hanzidentifier
    from pypinyin import pinyin, Style
    bad = BAD['zh'] | bad_file('zh')
    skip_pos = {'nr', 'nrt', 'nrfg', 'ns', 'nt', 'nz', 'x', 'eng', 'm', 'mq', 'q', 'ng', 'tg', 'vg', 'ag', 'dg', 'rg', 'mg', 'yg', 'zg', 'uj', 'ul', 'uz', 'ug', 'uv', 'ud', 'e', 'o', 'y', 'c', 'u', 'p', 'j', 'k', 'h'}
    cands = []
    for line in open(f'{R}/dict.txt', encoding='utf-8'):
        p = line.split()
        if len(p) < 3:
            continue
        w, fj, pos = nfc(p[0]), int(p[1]), p[2]
        if not (2 <= len(w) <= 4) or pos in skip_pos or fj < (20 if pos == 'i' else 60):
            continue
        if any(not ('一' <= ch <= '鿿') for ch in w) or len(set(w)) == 1:
            continue
        if w in NAMES['zh'] or w in bad or any(b in w for b in bad if len(b) >= 2):
            continue
        if not hanzidentifier.is_simplified(w):
            continue
        z = wordfreq.zipf_frequency(w, 'zh')
        if z < (1.5 if pos == 'i' else 2.4):
            continue
        cands.append((-(z + (0.6 if pos == 'i' else 0)), w))
    cands.sort()
    words = [w for _, w in cands[:MAX]]
    py = [''.join('-'.join(s[0] for s in pinyin(w, style=Style.TONE, heteronym=False)).split()) for w in words]
    extra = '\n/// Kelimelerin okunuşu (pinyin, aynı sırayla; heceler kısa çizgiyle).\n'
    extra += f"const String wordsZhPinyin = '{' '.join(py)}';\n"
    return words, extra


# ---------- Korece ----------
def build_ko():
    import wordfreq
    dic = {}
    for line in open(f'{R}/dic_ko.dic', encoding='utf-8'):
        a = unicodedata.normalize('NFC', line.strip()).split('/')
        dic.setdefault(a[0], set()).add(a[1] if len(a) > 1 else '')
    bl = BAD['ko'] | bad_file('ko')
    out, seen = [], set()
    for w in wordfreq.top_n_list('ko', 400000):
        w = nfc(w)
        if w in seen or not (2 <= len(w) <= 5) or any(not ('가' <= ch <= '힣') for ch in w):
            continue
        fl = dic.get(w)
        if not fl or not (fl & {'10', '25'}):
            continue
        if w in bl or w in NAMES['ko'] or any(b in w for b in bl if len(b) >= 2):
            continue
        if len(set(w)) == 1:
            continue
        seen.add(w)
        out.append(w)
        if len(out) >= MAX:
            break
    return out


# ---------- Tayca ----------
def build_th():
    import pythainlp
    from pythainlp.tokenize import syllable_tokenize
    d = os.path.dirname(pythainlp.__file__) + '/corpus/'
    words = {nfc(x) for x in open(d + 'words_th.txt', encoding='utf-8')}
    skip = set()
    for f in ('person_names_male_th.txt', 'person_names_female_th.txt', 'family_names_th.txt', 'countries_th.txt'):
        skip |= {nfc(x) for x in open(d + f, encoding='utf-8') if not x.startswith('#')}
    for line in open(d + 'thailand_provinces_th.csv', encoding='utf-8'):
        skip |= {nfc(x) for x in line.split(',')}
    bad = BAD['th'] | bad_file('th') | {nfc(x) for x in open(d + 'profanity_th.txt', encoding='utf-8') if not x.startswith('#')}
    out, seen = [], set()
    for line in open(d + 'tnc_freq.txt', encoding='utf-8'):
        w = nfc(line.split('\t')[0])
        if w in seen or w not in words or w in skip or w in bad:
            continue
        if any(not ('ก' <= ch <= '๎') for ch in w) or 'ๆ' in w or 'ฯ' in w:
            continue
        if any(b in w for b in bad if len(b) >= 3):
            continue
        t = syllable_tokenize(w, engine='dict')
        if ''.join(t) != w or not (2 <= len(t) <= 5) or len(set(t)) == 1:
            continue
        seen.add(w)
        out.append('+'.join(t))
        if len(out) >= MAX:
            break
    return out


SRC = {
    'zh': 'jieba dict.txt (MIT), sıra wordfreq (zh, CC BY-SA 4.0) ile; özel adlar sözcük türüyle ayıklandı. Pinyin: pypinyin (MIT). Süzgeç: LDNOOBW.',
    'ko': 'wordfreq (ko), CC BY-SA 4.0. Süzgeç: hunspell-ko ad girişleri (yalnızca süzgeç, dağıtılmaz), LDNOOBW.',
    'vi': 'pyvi words.txt (MIT) + UD Vietnamese-VTB (CC BY-SA 4.0); sıra VTB sayımı ve wordfreq (vi, CC BY-SA 4.0) ile. Taşlar heceler (+ ile ayrılır).',
    'hi': 'wordfreq (hi), CC BY-SA 4.0. Süzgeç: LibreOffice hi_IN hunspell (yalnızca süzgeç, dağıtılmaz). Taşlar akşaralar (+ ile ayrılır).',
    'bn': 'wordfreq (bn), CC BY-SA 4.0. Süzgeç: LibreOffice bn_BD hunspell kökleri (yalnızca süzgeç, dağıtılmaz). Taşlar akşaralar (+ ile ayrılır).',
    'th': 'PyThaiNLP words_th.txt ve tnc_freq.txt (CC0), heceleme PyThaiNLP. Süzgeç: ad/il/ülke listeleri, LDNOOBW, PyThaiNLP profanity. Taşlar heceler (+ ile ayrılır).',
}

if __name__ == '__main__':
    stats = {}
    for l in sys.argv[1:] or ['zh', 'ko', 'vi', 'hi', 'bn', 'th']:
        extra = ''
        if l == 'zh':
            words, extra = build_zh()
        elif l == 'ko':
            words = build_ko()
        elif l == 'vi':
            words = build_vi()
        elif l in ('hi', 'bn'):
            words = build_indic(l)
        else:
            words = build_th()
        if l in ('vi', 'hi', 'bn', 'th'):
            ex = extra_tiles(l, words)
            assert not any("'" in t or ' ' in t for t in ex)
            extra += f'\n/// İçerikte (ipucu, kategori, atasözü) geçip listede olmayan taşlar (kodları kelimelerden sonra).\n'
            extra += f"const String tiles{l[0].upper() + l[1:]} = '{' '.join(ex)}';\n"
        write(l, words, SRC[l], extra)
        tiles = [w.split('+') if '+' in w or l in ('vi', 'hi', 'bn', 'th') else list(w) for w in words]
        by = {}
        for t in tiles:
            by[len(t)] = by.get(len(t), 0) + 1
        stats[l] = {'words': len(words), 'tiles': len({x for t in tiles for x in t}), 'byLen': dict(sorted(by.items()))}
    print(json.dumps(stats, ensure_ascii=False))
