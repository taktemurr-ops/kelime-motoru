// id: kelime ailesinin ipucu, atasözü, kategori ve eş/zıt anlam içeriği.
// Stüdyonun kendi metinleri; atasözleri halk malıdır (kamu malı).

const List<String> kCluesId = [
  'apel|Buah merah atau hijau', 'roti|Dipanggang dalam oven', 'sungai|Air yang mengalir', 'laut|Air asin yang luas',
  'pulau|Daratan di tengah air', 'gunung|Bukit yang sangat tinggi', 'hutan|Banyak pohon', 'gurun|Tanah kering berpasir',
  'awan|Melayang di langit', 'hujan|Turun dari awan', 'salju|Putih di musim dingin', 'matahari|Bintang siang hari',
  'bulan|Bersinar di malam hari', 'bintang|Titik cahaya malam', 'angin|Udara yang bergerak', 'api|Nyala dan panas',
  'batu|Benda keras dari gunung', 'pasir|Ada di pantai', 'bunga|Mekar di taman', 'pohon|Punya batang dan dahan',
  'rumput|Hijau di lapangan', 'daun|Tumbuh di ranting', 'akar|Di bawah tanah', 'anjing|Hewan yang menggonggong',
  'kucing|Hewan yang mengeong', 'kuda|Hewan tunggangan', 'burung|Bersayap dan berbulu', 'ikan|Bernapas dengan insang',
  'lebah|Membuat madu', 'tikus|Hewan pengerat kecil', 'sapi|Memberi susu', 'domba|Memberi wol',
  'bebek|Unggas yang berenang', 'kelinci|Telinganya panjang', 'harimau|Kucing besar bergaris', 'gajah|Berbelalai',
  'monyet|Suka memanjat pohon', 'ular|Melata tanpa kaki', 'penyu|Kura laut', 'rumah|Tempat tinggal',
  'pintu|Jalan masuk', 'jendela|Kaca di dinding', 'atap|Bagian atas rumah', 'dinding|Pembatas ruangan',
  'kursi|Tempat duduk', 'meja|Tempat makan', 'kasur|Alas tidur', 'lampu|Memberi cahaya',
  'jam|Menunjukkan waktu', 'buku|Punya banyak halaman', 'surat|Dikirim lewat pos', 'pensil|Alat tulis dari kayu',
  'sekolah|Tempat belajar', 'guru|Mengajar murid', 'dokter|Mengobati orang sakit', 'koki|Memasak di dapur',
  'kebun|Tempat menanam', 'jalan|Dilalui kendaraan', 'jembatan|Melintasi sungai', 'kota|Banyak gedung dan orang',
  'desa|Permukiman kecil', 'mobil|Beroda empat', 'kereta|Melaju di atas rel', 'kapal|Berlayar di laut',
  'pesawat|Terbang di langit', 'sepeda|Dua roda dan pedal', 'susu|Minuman putih', 'air|Untuk diminum',
  'keju|Dibuat dari susu', 'madu|Manis dari lebah', 'gula|Pemanis', 'garam|Rasa asin di dapur',
  'sup|Makanan berkuah', 'kue|Kudapan manis', 'telur|Dari ayam', 'hidung|Untuk mencium',
  'mata|Untuk melihat', 'telinga|Untuk mendengar', 'mulut|Untuk berbicara', 'tangan|Punya lima jari',
  'kaki|Untuk berjalan', 'jantung|Memompa darah', 'kepala|Bagian tubuh teratas', 'rambut|Tumbuh di kepala',
  'gigi|Untuk mengunyah', 'sepatu|Dipakai di kaki', 'topi|Dipakai di kepala', 'jaket|Pakaian penghangat',
  'cincin|Perhiasan di jari', 'warna|Merah atau biru', 'musik|Nada dan irama', 'lagu|Dinyanyikan',
  'bola|Bulat untuk bermain', 'pagi|Awal hari', 'malam|Waktu gelap', 'minggu|Tujuh hari',
  'tahun|Dua belas bulan', 'teman|Orang dekat', 'keluarga|Orang tua dan anak', 'anak|Manusia muda',
  'nama|Panggilan diri', 'uang|Untuk membayar', 'pasar|Tempat jual beli', 'peta|Menunjukkan arah',
  'mimpi|Gambaran saat tidur', 'cahaya|Membuat terang', 'bayangan|Gelap di belakangmu', 'nasi|Makanan pokok dari padi',
  'batik|Kain bermotif khas',
];

const List<String> kProverbsId = [
  'Air beriak tanda tak dalam', 'Ada gula ada semut',
  'Bagai air di daun talas', 'Berat sama dipikul ringan sama dijinjing',
  'Bersatu kita teguh bercerai kita runtuh', 'Sedikit demi sedikit lama-lama menjadi bukit',
  'Tak ada gading yang tak retak', 'Ada udang di balik batu',
  'Bagai pinang dibelah dua', 'Hemat pangkal kaya',
  'Rajin pangkal pandai', 'Malu bertanya sesat di jalan',
  'Nasi sudah menjadi bubur', 'Di mana bumi dipijak di situ langit dijunjung',
  'Air susu dibalas air tuba', 'Besar pasak daripada tiang',
  'Seperti katak dalam tempurung', 'Tong kosong nyaring bunyinya',
  'Buah jatuh tak jauh dari pohonnya', 'Sekali dayung dua tiga pulau terlampaui',
  'Gajah mati meninggalkan gading', 'Lain lubuk lain ikannya',
  'Bagai kacang lupa kulitnya', 'Berakit-rakit ke hulu berenang-renang ke tepian',
  'Air tenang menghanyutkan',
];

const List<String> kGroupsId = [
  'Buah|apel pisang mangga jeruk anggur nanas pepaya semangka',
  'Sayur|wortel kentang bawang tomat bayam kubis terong',
  'Hewan ternak|sapi kambing domba kerbau ayam bebek kuda',
  'Hewan liar|harimau gajah singa monyet beruang rusa serigala',
  'Burung|elang merpati gagak kakatua bangau pipit beo',
  'Warna|merah biru hijau kuning putih hitam ungu',
  'Perabot|kursi meja lemari kasur sofa rak bufet',
  'Anggota tubuh|kepala tangan kaki hidung mata telinga lutut',
  'Pakaian|kemeja celana rok jaket kaus kebaya sarung',
  'Profesi|dokter guru petani nelayan pilot polisi penjahit',
  'Minuman|air susu jus kopi teh cokelat sirup',
  'Cuaca|hujan salju angin kabut badai petir gerimis',
  'Kendaraan|mobil kereta bus kapal sepeda pesawat truk',
  'Alat musik|gitar biola seruling drum piano angklung gamelan',
];

const List<String> kSynonymsId = [
  'cepat|lekas', 'besar|raya', 'kecil|mungil', 'cantik|elok',
  'pintar|pandai', 'senang|gembira', 'sedih|pilu', 'marah|murka',
  'hadiah|kado', 'jawab|balas', 'rumah|kediaman', 'teman|kawan',
  'uang|duit', 'bohong|dusta', 'lelah|capek',
];

const List<String> kAntonymsId = [
  'besar|kecil', 'panjang|pendek', 'panas|dingin', 'terang|gelap',
  'cepat|lambat', 'tua|muda', 'penuh|kosong', 'atas|bawah',
  'siang|malam', 'keras|lunak', 'banyak|sedikit', 'dekat|jauh',
  'ringan|berat', 'miskin|kaya', 'pagi|sore', 'buka|tutup',
  'ramai|sepi', 'sakit|sehat',
];
