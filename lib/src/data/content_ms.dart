// ms: kelime ailesinin ipucu, atasözü, kategori ve eş/zıt anlam içeriği.
// Stüdyonun kendi metinleri; atasözleri halk malıdır (kamu malı).

const List<String> kCluesMs = [
  'epal|Buah merah atau hijau', 'roti|Dibakar dalam ketuhar', 'sungai|Air yang mengalir', 'laut|Air masin yang luas',
  'pulau|Daratan di tengah air', 'gunung|Bukit yang sangat tinggi', 'hutan|Banyak pokok', 'awan|Terapung di langit',
  'hujan|Turun dari awan', 'salji|Putih pada musim sejuk', 'matahari|Bintang siang hari', 'bulan|Bersinar pada waktu malam',
  'bintang|Titik cahaya malam', 'angin|Udara yang bergerak', 'api|Nyala dan panas', 'batu|Benda keras dari gunung',
  'pasir|Ada di pantai', 'bunga|Mekar di taman', 'pokok|Ada batang dan dahan', 'rumput|Hijau di padang',
  'daun|Tumbuh di ranting', 'akar|Di bawah tanah', 'anjing|Haiwan yang menyalak', 'kucing|Haiwan yang mengiau',
  'kuda|Haiwan tunggangan', 'burung|Bersayap dan berbulu', 'ikan|Bernafas dengan insang', 'lebah|Membuat madu',
  'tikus|Haiwan pengerat kecil', 'lembu|Memberi susu', 'kambing|Berjanggut dan mengembek', 'itik|Unggas yang berenang',
  'arnab|Telinganya panjang', 'harimau|Kucing besar berbelang', 'gajah|Berbelalai', 'monyet|Suka memanjat pokok',
  'ular|Melata tanpa kaki', 'penyu|Bertelur di pantai', 'rumah|Tempat tinggal', 'pintu|Jalan masuk',
  'tingkap|Kaca di dinding', 'bumbung|Bahagian atas rumah', 'dinding|Pemisah bilik', 'kerusi|Tempat duduk',
  'meja|Tempat makan', 'katil|Tempat tidur', 'lampu|Memberi cahaya', 'jam|Menunjukkan waktu',
  'buku|Banyak halaman', 'surat|Dihantar melalui pos', 'pensel|Alat tulis kayu', 'sekolah|Tempat belajar',
  'cikgu|Mengajar murid', 'doktor|Merawat orang sakit', 'kebun|Tempat bercucuk tanam', 'jalan|Dilalui kenderaan',
  'jambatan|Merentasi sungai', 'bandar|Banyak bangunan dan orang', 'kampung|Penempatan kecil', 'kereta|Beroda empat di jalan raya',
  'keretapi|Bergerak di atas landasan', 'kapal|Belayar di laut', 'basikal|Dua roda dan pedal', 'susu|Minuman putih',
  'air|Untuk diminum', 'keju|Dibuat daripada susu', 'madu|Manis daripada lebah', 'gula|Pemanis',
  'garam|Rasa masin di dapur', 'sup|Makanan berkuah', 'kuih|Juadah tradisional', 'telur|Daripada ayam',
  'hidung|Untuk menghidu', 'mata|Untuk melihat', 'telinga|Untuk mendengar', 'mulut|Untuk bercakap',
  'tangan|Ada lima jari', 'kaki|Untuk berjalan', 'jantung|Mengepam darah', 'kepala|Bahagian tubuh teratas',
  'rambut|Tumbuh di kepala', 'gigi|Untuk mengunyah', 'kasut|Dipakai di kaki', 'topi|Dipakai di kepala',
  'jaket|Pakaian penghangat', 'cincin|Perhiasan di jari', 'warna|Merah atau biru', 'muzik|Nada dan irama',
  'lagu|Dinyanyikan', 'bola|Bulat untuk bermain', 'pagi|Awal hari', 'malam|Waktu gelap',
  'minggu|Tujuh hari', 'tahun|Dua belas bulan', 'kawan|Orang yang rapat', 'keluarga|Ibu bapa dan anak',
  'anak|Manusia muda', 'nama|Panggilan diri', 'wang|Untuk membayar', 'pasar|Tempat jual beli',
  'peta|Menunjukkan arah', 'mimpi|Gambaran ketika tidur', 'cahaya|Membuat terang', 'bayang|Gelap di belakangmu',
  'nasi|Makanan ruji daripada padi', 'batik|Kain bercorak tradisional', 'durian|Raja buah berduri', 'wau|Layang tradisional',
];

const List<String> kProverbsMs = [
  'Air dicincang tidak akan putus', 'Bagai aur dengan tebing',
  'Sedikit-sedikit lama-lama jadi bukit', 'Bersatu teguh bercerai roboh',
  'Hendak seribu daya tak hendak seribu dalih', 'Melentur buluh biarlah dari rebungnya',
  'Seperti katak di bawah tempurung', 'Air yang tenang jangan disangka tiada buaya',
  'Bagai kacang lupa kulit', 'Harimau mati meninggalkan belang gajah mati meninggalkan tulang',
  'Indah khabar dari rupa', 'Kalau takut dilambung ombak jangan berumah di tepi pantai',
  'Bagai menatang minyak yang penuh', 'Sambil menyelam minum air',
  'Hujan emas di negeri orang hujan batu di negeri sendiri', 'Alang-alang menyeluk pekasam biar sampai ke pangkal lengan',
  'Tak kenal maka tak cinta', 'Malu bertanya sesat jalan',
  'Ikut resmi padi makin berisi makin tunduk', 'Di mana bumi dipijak di situ langit dijunjung',
  'Berat mata memandang berat lagi bahu memikul', 'Bulat air kerana pembetung bulat manusia kerana muafakat',
  'Nasi sudah menjadi bubur', 'Yang bulat tidak datang bergolek yang pipih tidak datang melayang',
  'Ukur baju di badan sendiri',
];

const List<String> kGroupsMs = [
  'Buah|epal pisang mangga oren anggur nanas betik tembikai',
  'Sayur|lobak kentang bawang tomato bayam kubis terung',
  'Haiwan ternakan|lembu kambing kerbau ayam itik kuda angsa',
  'Haiwan liar|harimau gajah singa monyet beruang rusa serigala',
  'Burung|helang merpati gagak bangau pipit murai tiung',
  'Warna|merah biru hijau kuning putih hitam ungu',
  'Perabot|kerusi meja almari katil sofa rak bangku',
  'Anggota badan|kepala tangan kaki hidung mata telinga lutut',
  'Pakaian|kemeja seluar kebaya jaket baju kain sarung',
  'Pekerjaan|doktor guru petani nelayan juruterbang polis tukang',
  'Minuman|air susu jus kopi teh koko sirap',
  'Cuaca|hujan salji angin kabus ribut petir gerimis',
  'Kenderaan|kereta keretapi bas kapal basikal teksi lori',
  'Alat muzik|gitar biola seruling dram piano kompang gambus',
];

const List<String> kSynonymsMs = [
  'cepat|pantas', 'besar|raya', 'kecil|kerdil', 'cantik|jelita',
  'pandai|bijak', 'gembira|riang', 'sedih|duka', 'marah|berang',
  'hadiah|anugerah', 'kawan|sahabat', 'rumah|kediaman', 'wang|duit',
  'bohong|dusta', 'penat|letih', 'takut|gerun',
];

const List<String> kAntonymsMs = [
  'besar|kecil', 'panjang|pendek', 'panas|sejuk', 'terang|gelap',
  'cepat|lambat', 'tua|muda', 'penuh|kosong', 'atas|bawah',
  'siang|malam', 'keras|lembut', 'banyak|sedikit', 'dekat|jauh',
  'ringan|berat', 'miskin|kaya', 'pagi|petang', 'buka|tutup',
  'ramai|sunyi', 'sakit|sihat',
];
