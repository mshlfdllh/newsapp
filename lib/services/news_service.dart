import 'package:news_app/models/article.dart';

/// Kelas abstrak [NewsService] berfungsi sebagai kontrak antarmuka (titik sambung)
/// untuk mengambil data berita.
///
/// Catatan edukasi:
/// Sesuai PRD, lapisan tampilan (UI) dan state management HANYA bergantung pada
/// kelas abstrak [NewsService], tidak pernah langsung pada [MockNewsService].
/// Dengan arsitektur ini, siswa dapat dengan mudah mengganti implementasi data tiruan
/// ke API nyata ([ApiNewsService]) pada tahap integrasi tanpa merusak kode tampilan.
abstract class NewsService {
  /// Mengambil daftar artikel berita secara asynchronous.
  ///
  /// Mengembalikan [Future] berisi [List<Article>].
  /// [Future] merepresentasikan nilai yang akan tersedia di masa mendatang,
  /// baik berupa data sukses maupun pelemparan error jika gagal.
  ///
  /// Parameter opsional:
  /// - [category]: Nama kategori berita untuk penyaringan (opsional).
  /// - [query]: Kata kunci pencarian judul atau deskripsi artikel (opsional).
  Future<List<Article>> fetchArticles({
    String? category,
    String? query,
  });
}

