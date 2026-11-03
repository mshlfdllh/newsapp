 # PRD Front End: News App untuk Pembelajaran Flutter

Oct 13, 2026 ·

## Ringkasan

News App adalah aplikasi Flutter untuk membaca berita, dibuat sebagai
proyek belajar. PRD ini hanya mencakup front end: semua layar, state
tampilan, dan bookmark, yang berjalan dengan data contoh lokal.

Kami akan memasang sendiri NewsAPI.org dengan API key pribadi pada tahap
integrasi API, sebagai bahan pembelajaran. Karena itu front end dibuat
siap disambung: UI hanya bergantung pada satu kelas NewsService,
sehingga mengganti data contoh dengan API sungguhan tidak mengubah
tampilan.

## Learning objectives

Setelah menyelesaikan proyek ini, kami mampu:

1.  Melakukan network call ke REST API memakai package http.

2.  Menerapkan asynchronous programming dengan Future dan async/await.

3.  Menangani state jaringan: loading, sukses, dan error.

4.  Mem-parsing data JSON menjadi model Dart untuk ditampilkan di UI.

Keempat tujuan ini dicapai dalam dua tahap. PRD ini mengerjakan tahap
front end; tahap integrasi API dikerjakan oleh kami sendiri.

| LO | Tahap front end (PRD ini) | Tahap integrasi API (Kami sendiri) |
|----|----|----|
| 1\. Network call | Belum dikerjakan; disiapkan kelas abstrak NewsService sebagai titik sambung | kami menulis panggilan http ke NewsAPI.org |
| 2\. Asynchronous | Data contoh dimuat lewat Future dengan jeda buatan | Jeda buatan diganti panggilan jaringan sungguhan |
| 3\. State jaringan | UI loading, sukses, error, dan kosong sudah jadi dan bisa dipaksa muncul lewat data contoh | Dihubungkan ke hasil nyata: tanpa internet, key salah, kuota habis |
| 4\. Parsing JSON | Article.fromJson diuji dengan file JSON contoh berformat NewsAPI.org | Parsing respons asli, termasuk field yang kosong |

## Pengguna sasaran

Pengguna utamanya pelajar yang sudah mengenal dasar Dart dan Flutter
(widget, StatelessWidget/StatefulWidget, navigasi sederhana) dan baru
belajar terhubung ke server. dokumen ini dipakai sebagai acuan tugas dan
penilaian.

Pembaca berita dalam aplikasi adalah pengguna umum: ingin melihat daftar
berita terbaru, membuka detailnya, dan menyimpan artikel yang menarik.

## Fitur inti versi 1

Enam fitur wajib ada. Semuanya berjalan dengan data contoh dan tersusun
di tiga layar: Beranda, Detail, dan Favorit.

| No | Fitur | Deskripsi | Layar |
|----|----|----|----|
| 1 | Daftar berita | List kartu berisi gambar, judul, nama sumber, dan waktu terbit; tarik ke bawah untuk memuat ulang | Beranda |
| 2 | State tampilan | Indikator loading, pesan error dengan tombol coba lagi, dan tampilan hasil kosong | Beranda, Favorit |
| 3 | Detail artikel | Gambar, judul, penulis, sumber, tanggal, deskripsi, dan tombol Baca selengkapnya (aksi membuka tautan dipasang di tahap integrasi) | Detail |
| 4 | Bookmark/favorit | Tandai atau lepas tanda dari daftar dan detail; semua artikel yang ditandai tampil di halaman Favorit | Beranda, Detail, Favorit |
| 5 | Pencarian dan kategori | Kolom cari dan chip kategori (bisnis, olahraga, teknologi, dan sejenisnya) yang menyaring data contoh | Beranda |
| 6 | Simulasi state | Pengaturan di MockNewsService untuk memaksa hasil sukses, error, atau kosong dan mengatur lama jeda; dipakai pengembang, bukan pengguna | Kode |

Bookmark disimpan di memori lewat Provider. Daftar favorit hilang saat
aplikasi ditutup, dan itu disengaja pada versi 1.

## Panduan tampilan

Tampilan dibuat konsisten dan sederhana, bukan hasil template bawaan.
Palet warna utama ditentukan oleh pelajar sebelum coding dimulai.

- Material 3 dengan satu warna utama dan warna netral.

- Dua tingkat tipografi saja, judul dan isi, dengan ukuran dan bobot
  tetap di satu file tema.

- Satu komponen ArticleCard dipakai di Beranda dan Favorit; jarak antar
  elemen memakai kelipatan 8.

- Gambar artikel punya placeholder saat kosong atau gagal dimuat.

- Pesan loading, error, dan kosong berbahasa Indonesia yang jelas,
  dengan tombol aksi.

- Warna, ukuran teks, dan jarak diambil dari tema, tidak ditulis
  langsung di widget.

## Di luar cakupan

Hal berikut sengaja belum dibuat di versi 1 supaya fokus tetap pada
learning objectives:

- Panggilan jaringan sungguhan ke NewsAPI.org dan pengelolaan API key,
  yang dikerjakan guru dan siswa pada tahap integrasi API.

- Login, registrasi, dan akun pengguna.

- CRUD berita (menambah, mengubah, menghapus artikel). API publik hanya
  mendukung membaca data.

- Penyimpanan lokal permanen untuk bookmark (SharedPreferences, SQLite,
  Hive).

- Backend sendiri (Firebase, Supabase, json-server).

- Notifikasi, mode offline, dan caching.

- Berbagi artikel ke aplikasi lain.

Ide di atas bisa dijadikan tantangan lanjutan setelah versi 1 selesai.

## Alur pengguna

Setiap kali aplikasi mengambil berita, hasilnya adalah sukses atau
error, dan keduanya harus ditangani di UI.

![alur pengguna · 6 langkah, 1
percabangan](PRD News App untuk Flutter_files/media/image1.png)

alur pengguna · 6 langkah, 1 percabangan

Jika pemanggilan API gagal, siswa melihat pesan error dan menekan tombol
coba lagi, yang mengulang proses loading. Dari daftar berita, siswa
membuka detail artikel atau menandainya sebagai bookmark dan melihatnya
di halaman Favorit.

## Data dan titik sambung API

Selama tahap front end, data berasal dari file JSON contoh. Titik
sambung ke API sungguhan disiapkan sekarang supaya kami bisa memasangnya
nanti tanpa mengubah UI.

| Hal | Rencana |
|----|----|
| Data contoh | assets/mock/articles.json berformat sama dengan respons NewsAPI.org, dimuat lewat MockNewsService dengan jeda buatan 1-2 detik |
| Titik sambung | Kelas abstrak NewsService dengan metode fetchArticles yang mengembalikan Future\<List\<Article\>\>. MockNewsService dibuat sekarang; ApiNewsService dibuat siswa pada tahap integrasi |
| Simulasi state | Satu pengaturan di MockNewsService untuk memaksa hasil sukses, error, atau kosong |
| Sumber data nyata | NewsAPI.org dengan API key pribadi tiap pelajar |
| Endpoint (cek dokumentasi) | GET https://newsapi.org/v2/top-headlines dengan parameter seperti country, category, q, page, dan pageSize; key dikirim lewat header X-Api-Key |
| Bentuk respons | Objek JSON dengan status, totalResults, dan list articles |
| Model Dart | Article dengan sourceName, author, title, description, url, urlToImage, publishedAt, content; semua field dianggap boleh kosong kecuali title |

## Tech stack dan struktur proyek

| Komponen | Fungsi |
|----|----|
| Dart dan Flutter SDK | Bahasa dan framework UI |
| Package http | Memanggil REST API; dipakai pada tahap integrasi API, belum pada tahap front end |
| Provider | State management untuk daftar berita, status jaringan, dan bookmark |
| Git dan GitHub | Version control; siswa commit per fitur dan mengumpulkan lewat repository |

Struktur folder yang disarankan memisahkan tugas setiap bagian:

lib/\
main.dart\
models/ article.dart\
services/ news_service.dart (kelas abstrak, titik sambung)\
mock_news_service.dart (data contoh, tahap front end)\
api_news_service.dart (dibuat pelajar, tahap integrasi)\
providers/ news_provider.dart (loading, sukses, error, kosong)\
bookmark_provider.dart\
screens/ home_screen.dart, detail_screen.dart, bookmark_screen.dart\
widgets/ article_card.dart, state_views.dart\
theme/ app_theme.dart\
assets/mock/ articles.json

## Kriteria keberhasilan dan tahapan

Tahap front end dianggap selesai bila semua poin berikut terpenuhi:

- [ ] Layar Beranda, Detail, dan Favorit berjalan dengan data contoh
  tanpa crash.

- [ ] Tiga state (loading, error dengan tombol coba lagi, hasil kosong)
  bisa ditampilkan hanya dengan mengubah pengaturan di MockNewsService.

- [ ] Artikel dengan gambar, deskripsi, atau penulis kosong tetap tampil
  rapi.

- [ ] Bookmark bisa ditambah dan dihapus, dan tampil konsisten di
  Beranda, Detail, dan Favorit.

- [ ] Article.fromJson lolos uji dengan file JSON contoh berformat
  NewsAPI.org.

- [ ] UI hanya bergantung pada NewsService, tidak langsung pada data
  contoh.

- [ ] Kode ada di GitHub dengan riwayat commit yang jelas.

Urutan pengerjaan front end:

1.  Setup proyek, tambahkan Provider, buat repository GitHub, dan buat
    tema.

2.  Buat model Article dan fromJson, uji dengan JSON contoh.

3.  Buat NewsService abstrak dan MockNewsService dengan jeda buatan dan
    pengaturan simulasi state.

4.  Buat NewsProvider dengan status loading, sukses, error, dan kosong,
    lalu hubungkan ke Beranda.

5.  Buat layar Detail.

6.  Tambahkan BookmarkProvider dan layar Favorit.

7.  Tambahkan pencarian dan kategori, rapikan UI, lalu uji ketiga state.

Tahap integrasi API (dikerjakan oleh kami sendiri, di luar PRD ini):

1.  Daftar di NewsAPI.org dan ambil API key pribadi.

2.  Simpan key di luar kode yang masuk Git (misalnya lewat
    --dart-define) dan pastikan tidak ter-commit.

3.  Tambahkan package http, lalu tulis ApiNewsService dengan async/await
    dan parsing respons.

4.  Ganti MockNewsService dengan ApiNewsService di Provider.

5.  Uji kasus nyata: tanpa internet, key salah, dan kuota harian habis.
