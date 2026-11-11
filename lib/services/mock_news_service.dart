import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/services/news_service.dart';

/// Enum [MockState] merepresentasikan pilihan simulasi status jaringan untuk pengembang.
/// Digunakan untuk menguji ketiga state tampilan UI (sukses, error, kosong)
/// tanpa perlu mengubah kode UI atau bergantung pada koneksi internet.
enum MockState {
  /// Mengembalikan data artikel dari file JSON tiruan.
  success,

  /// Melempar error/exception untuk mensimulasikan kegagalan jaringan atau server.
  error,

  /// Mengembalikan list kosong [] untuk mensimulasikan tidak adanya berita yang ditemukan.
  empty,
}

/// [MockNewsService] adalah implementasi [NewsService] berbasis data lokal
/// dari file aset `assets/mock/articles.json`.
///
/// Layanan ini dilengkapi:
/// 1. Jeda buatan ([delay]) untuk mensimulasikan latensi jaringan di dunia nyata.
/// 2. Pengaturan [simulatedState] untuk memaksa skenario sukses, error, atau kosong.
class MockNewsService implements NewsService {
  /// Pengaturan simulasi state untuk mempermudah pengujian tampilan:
  /// - [MockState.success]: Mengembalikan data artikel normal.
  /// - [MockState.error]: Melemparkan exception error koneksi.
  /// - [MockState.empty]: Mengembalikan daftar artikel kosong.
  MockState simulatedState;

  /// Lama jeda buatan saat pemanggilan data (default 1 detik sesuai PRD).
  Duration delay;

  /// Path lokasi file aset JSON mock.
  final String assetPath;

  /// Bundle aset opsional (mempermudah unit testing dengan custom bundle).
  final AssetBundle? bundle;

  /// Cache string JSON agar tidak perlu membaca aset dari disk berulang kali.
  static String? _cachedJson;

  MockNewsService({
    this.simulatedState = MockState.success,
    this.delay = const Duration(seconds: 1),
    this.assetPath = 'assets/mock/articles.json',
    this.bundle,
  });

  /// Alias kategori bahasa Indonesia dan bahasa Inggris untuk pencocokan data mock.
  static const Map<String, List<String>> _categoryAliases = {
    'bisnis': ['bisnis', 'business', 'ekonomi'],
    'business': ['bisnis', 'business', 'ekonomi'],
    'teknologi': ['teknologi', 'technology', 'tekno'],
    'technology': ['teknologi', 'technology', 'tekno'],
    'olahraga': ['olahraga', 'sports', 'sport'],
    'sports': ['olahraga', 'sports', 'sport'],
    'kesehatan': ['kesehatan', 'health'],
    'health': ['kesehatan', 'health'],
    'sains': ['sains', 'science', 'energi'],
    'science': ['sains', 'science', 'energi'],
    'hiburan': ['hiburan', 'entertainment'],
    'entertainment': ['hiburan', 'entertainment'],
  };

  /// Mengambil data artikel secara asynchronous dari file JSON lokal.
  ///
  /// Catatan edukasi:
  /// - `async`: Menandakan fungsi ini berjalan secara asynchronous dan menghasilkan [Future].
  /// - `await`: Menghentikan sementara eksekusi kode di baris tersebut hingga [Future] selesai,
  ///   sehingga UI tetap responsif tanpa mengalami pembekuan (freeze).
  @override
  Future<List<Article>> fetchArticles({
    String? category,
    String? query,
  }) async {
    // 1. Mensimulasikan jeda jaringan menggunakan Future.delayed
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }

    // 2. Evaluasi status simulasi jaringan
    switch (simulatedState) {
      case MockState.error:
        // Mensimulasikan kondisi kegagalan jaringan, API key salah, atau server down
        throw Exception('Simulasi gagal memuat berita: Terjadi gangguan koneksi internet atau server.');

      case MockState.empty:
        // Mensimulasikan kondisi respons tanpa artikel
        return <Article>[];

      case MockState.success:
        // Membaca file JSON dari cache, file lokal (saat test), atau asset bundle
        if (_cachedJson == null) {
          final file = File(assetPath);
          if (file.existsSync()) {
            _cachedJson = file.readAsStringSync();
          } else {
            final activeBundle = bundle ?? rootBundle;
            _cachedJson = await activeBundle.loadString(assetPath);
          }
        }
        final jsonString = _cachedJson!;

        // Mem-parsing teks JSON mentah menjadi Map Dart
        final Map<String, dynamic> decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        final List<dynamic> articlesJson = (decoded['articles'] as List<dynamic>?) ?? [];

        // Mengubah list JSON menjadi List<Article> menggunakan Article.fromJson
        List<Article> articles = articlesJson
            .map((item) => Article.fromJson(item as Map<String, dynamic>))
            .toList();

        // 3. Menyaring berita berdasarkan kata kunci pencarian (query) jika diisi
        if (query != null && query.trim().isNotEmpty) {
          final cleanQuery = query.trim().toLowerCase();
          articles = articles.where((article) {
            final titleMatch = article.title.toLowerCase().contains(cleanQuery);
            final descMatch = article.description?.toLowerCase().contains(cleanQuery) ?? false;
            return titleMatch || descMatch;
          }).toList();
        }

        // 4. Menyaring berita berdasarkan kategori jika dipilih dan bukan 'semua'
        if (category != null && category.trim().isNotEmpty && category.trim().toLowerCase() != 'semua') {
          final cleanCategory = category.trim().toLowerCase();
          final aliases = _categoryAliases[cleanCategory] ?? [cleanCategory];
          articles = articles.where((article) {
            return aliases.any((alias) {
              final titleMatch = article.title.toLowerCase().contains(alias);
              final descMatch = article.description?.toLowerCase().contains(alias) ?? false;
              final contentMatch = article.content?.toLowerCase().contains(alias) ?? false;
              final sourceMatch = article.sourceName?.toLowerCase().contains(alias) ?? false;
              return titleMatch || descMatch || contentMatch || sourceMatch;
            });
          }).toList();
        }

        return articles;
    }
  }
}
