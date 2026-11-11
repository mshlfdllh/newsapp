import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import 'news_exception.dart';
import 'news_service.dart';

/// [ApiNewsService] adalah implementasi [NewsService] yang mengambil data berita
/// langsung dari REST API NewsAPI.org.
///
/// Catatan edukasi:
/// - Menggunakan package `http` untuk melakukan panggilan jaringan GET secara asynchronous.
/// - Menjaga keamanan API key melalui [String.fromEnvironment] tanpa hardcode di file yang di-commit.
/// - Memetakan kategori bahasa Indonesia ke parameter resmi yang dikenali oleh NewsAPI.org.
class ApiNewsService implements NewsService {
  /// API key dibaca secara aman lewat environment variable saat runtime.
  static const _apiKey = String.fromEnvironment('NEWS_API_KEY');

  /// Pemetaan nama kategori bahasa Indonesia ke parameter resmi NewsAPI.org.
  static const Map<String, String> _categoryMapping = {
    'bisnis': 'business',
    'business': 'business',
    'teknologi': 'technology',
    'technology': 'technology',
    'olahraga': 'sports',
    'sports': 'sports',
    'kesehatan': 'health',
    'health': 'health',
    'sains': 'science',
    'science': 'science',
    'hiburan': 'entertainment',
    'entertainment': 'entertainment',
    'umum': 'general',
    'general': 'general',
  };

  @override
  Future<List<Article>> fetchArticles({String? query, String? category}) async {
    if (_apiKey.isEmpty) {
      throw const NewsException(
        'API key belum diisi. Jalankan dengan --dart-define-from-file=env.json',
      );
    }

    // 1. Memvalidasi dan memetakan kategori yang dipilih ke format NewsAPI.org
    String? apiCategory;
    if (category != null && category.trim().isNotEmpty && category.trim().toLowerCase() != 'semua') {
      final key = category.trim().toLowerCase();
      apiCategory = _categoryMapping[key] ?? key;
    }

    // 2. Menyusun parameter query URL
    final queryParameters = <String, String>{
      'country': 'us',
      'pageSize': '20',
    };
    if (apiCategory != null) {
      queryParameters['category'] = apiCategory;
    }
    if (query != null && query.trim().isNotEmpty) {
      queryParameters['q'] = query.trim();
    }

    final uri = Uri.https('newsapi.org', '/v2/top-headlines', queryParameters);

    try {
      // 3. Melakukan HTTP GET request dengan header otentikasi X-Api-Key
      final response = await http
          .get(uri, headers: {'X-Api-Key': _apiKey})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw NewsException(_pesanError(response.statusCode));
      }

      // 4. Mem-parsing respons JSON menjadi List<Article>
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['articles'] as List<dynamic>? ?? [];

      return items
          .map((item) => Article.fromJson(item as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const NewsException(
        'Tidak ada koneksi internet. Periksa koneksi jaringan Anda.',
      );
    } on TimeoutException {
      throw const NewsException(
        'Waktu koneksi habis. Server terlalu lama merespons. Coba lagi nanti.',
      );
    } on http.ClientException {
      throw const NewsException(
        'Gagal menghubungi server berita. Periksa jaringan internet Anda.',
      );
    } catch (e) {
      if (e is NewsException) rethrow;
      throw NewsException('Terjadi kesalahan saat memuat berita: $e');
    }
  }

  /// Menghasilkan pesan kesalahan yang ramah pengguna berdasarkan status kode HTTP.
  String _pesanError(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Permintaan tidak valid. Periksa parameter yang dikirim.';
      case 401:
        return 'API key salah atau tidak terkirim. Periksa file env.json.';
      case 429:
        return 'Terlalu banyak permintaan atau kuota harian habis. Coba lagi nanti.';
      default:
        return 'Server bermasalah (kode $statusCode). Coba lagi nanti.';
    }
  }
}
