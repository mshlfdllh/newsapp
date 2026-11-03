# Aturan proyek News App

## Konteks
Proyek belajar siswa: aplikasi berita Flutter (Dart). Acuan utama adalah
 docs/PRD.md. PRD ini khusus front end, jadi data memakai file JSON contoh,
bukan API sungguhan.

## Cara bekerja
Kerjakan hanya satu langkah dari "Urutan pengerjaan front end" di PRD per
permintaan. Setelah itu berhenti dan jelaskan perubahannya.
Jangan menambah fitur, layar, atau package di luar PRD. Package yang
diizinkan:  provider`. Package 'http baru dipakai pada tahap integrasi AΡΙ.
Jika sebuah permintaan bertentangan dengan PRD, sampaikan dulu dan tanyakan
sebelum mengerjakan.

## Struktur dan arsitektur
Ikuti struktur folder di PRD: models, services, providers, screens,
widgets, theme.
UI hanya bergantung pada kelas abstrak NewsService`, tidak pernah langsung
pada MockNewsService`.
State jaringan memakai Provider dengan empat status: loading, sukses,
error, kosong.
Bookmark disimpan di memori lewat 'BookmarkProvider', tanpa penyimpanan
permanen.

## Gaya kode
Beri komentar singkat berbahasa Indonesia pada kode 'Future',
 async/await', 'fromJson', dan Provider supaya siswa bisa belajar dari
kodenya.
Gunakan nama variabel dan file yang jelas. Satu widget memegang satu
tanggung jawab.
Semua warna, ukuran teks, dan jarak diambil dari
 lib/theme/app_theme.dart', tidak ditulis langsung di widget.
Tangani nilai kosong (null) pada setiap field artikel.
Teks yang tampil ke pengguna memakai bahasa Indonesia.

## Keamanan
Jangan menulis API key di kode atau di file yang ikut masuk Git.

## Sebelum selesai
Jalankan flutter analyze dan pastikan tidak ada error.
Ringkas apa yang diubah dan apa yang perlu dites siswa.