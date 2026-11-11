import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/bookmark_provider.dart';

void main() {
  group('BookmarkProvider Tests', () {
    const article1 = Article(
      title: 'Judul Berita 1',
      url: 'https://example.com/1',
    );
    const article2 = Article(
      title: 'Judul Berita 2',
      url: 'https://example.com/2',
    );

    test('Kondisi awal: daftar bookmark kosong', () {
      final provider = BookmarkProvider();
      expect(provider.isEmpty, isTrue);
      expect(provider.count, 0);
      expect(provider.bookmarkedArticles, isEmpty);
      expect(provider.isBookmarked(article1), isFalse);
    });

    test('addBookmark menambahkan artikel ke favorit dan memanggil notifyListeners', () {
      final provider = BookmarkProvider();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.addBookmark(article1);

      expect(provider.count, 1);
      expect(provider.isBookmarked(article1), isTrue);
      expect(notifyCount, 1);

      // Menambahkan artikel yang sama tidak akan menduplikasi
      provider.addBookmark(article1);
      expect(provider.count, 1);
      expect(notifyCount, 1); // Tidak ada notify tambahan karena tidak bertambah
    });

    test('removeBookmark menghapus artikel dari favorit dan memanggil notifyListeners', () {
      final provider = BookmarkProvider();
      provider.addBookmark(article1);
      provider.addBookmark(article2);

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.removeBookmark(article1);

      expect(provider.count, 1);
      expect(provider.isBookmarked(article1), isFalse);
      expect(provider.isBookmarked(article2), isTrue);
      expect(notifyCount, 1);
    });

    test('toggleBookmark bergantian menambah dan menghapus artikel', () {
      final provider = BookmarkProvider();

      // Pertama kali: menambah
      provider.toggleBookmark(article1);
      expect(provider.isBookmarked(article1), isTrue);
      expect(provider.count, 1);

      // Kedua kali: menghapus
      provider.toggleBookmark(article1);
      expect(provider.isBookmarked(article1), isFalse);
      expect(provider.count, 0);
    });
  });
}

