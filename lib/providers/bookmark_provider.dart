import 'package:flutter/foundation.dart';
import 'package:news_app/models/article.dart';

/// [BookmarkProvider] mengelola status artikel yang ditandai (favorit) di dalam memori.
///
/// Sesuai batasan PRD & AGENTS.md:
/// - Bookmark disimpan di memori selama aplikasi berjalan (tanpa penyimpanan permanen seperti SQLite/SharedPreferences).
/// - Menggunakan [ChangeNotifier] untuk memberitahu UI ([Consumer] atau `context.watch`)
///   saat daftar bookmark berubah melalui panggilan [notifyListeners].
class BookmarkProvider extends ChangeNotifier {
  /// Koleksi artikel yang disimpan di memori.
  final List<Article> _bookmarkedArticles = [];

  // ===========================================================================
  // GETTERS
  // ===========================================================================

  /// Mengembalikan daftar artikel favorit yang tidak dapat dimodifikasi langsung dari luar.
  List<Article> get bookmarkedArticles => List.unmodifiable(_bookmarkedArticles);

  /// Jumlah total artikel yang telah ditandai.
  int get count => _bookmarkedArticles.length;

  /// Mengecek apakah daftar artikel favorit masih kosong.
  bool get isEmpty => _bookmarkedArticles.isEmpty;

  /// Memeriksa apakah suatu artikel sudah ada di dalam daftar favorit.
  ///
  /// Catatan edukasi:
  /// Evaluasi kesetaraan memanfaatkan implementasi `operator ==` pada model [Article]
  /// yang membandingkan kesamaan judul dan URL.
  bool isBookmarked(Article article) {
    return _bookmarkedArticles.contains(article);
  }

  // ===========================================================================
  // OPERASI STATE
  // ===========================================================================

  /// Menambahkan atau menghapus artikel dari daftar favorit (toggle).
  ///
  /// Catatan edukasi Provider:
  /// Metode [notifyListeners] wajib dipanggil setelah melakukan perubahan data
  /// agar semua widget yang mendengarkan ([Consumer<BookmarkProvider>]) melakukan rebuild.
  void toggleBookmark(Article article) {
    if (isBookmarked(article)) {
      _bookmarkedArticles.remove(article);
    } else {
      _bookmarkedArticles.add(article);
    }
    notifyListeners();
  }

  /// Menambahkan artikel ke daftar favorit secara eksplisit.
  void addBookmark(Article article) {
    if (!isBookmarked(article)) {
      _bookmarkedArticles.add(article);
      notifyListeners();
    }
  }

  /// Menghapus artikel dari daftar favorit secara eksplisit.
  void removeBookmark(Article article) {
    if (isBookmarked(article)) {
      _bookmarkedArticles.remove(article);
      notifyListeners();
    }
  }
}

