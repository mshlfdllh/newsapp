import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/providers/news_provider.dart';
import 'package:news_app/services/mock_news_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NewsProvider Tests', () {
    test('Status awal adalah NewsStatus.loading', () {
      final mockService = MockNewsService(delay: Duration.zero);
      final provider = NewsProvider(newsService: mockService);

      expect(provider.status, NewsStatus.loading);
      expect(provider.isLoading, isTrue);
      expect(provider.articles, isEmpty);
    });

    test('fetchArticles berhasil mengubah status ke NewsStatus.sukses saat data tersedia', () async {
      final mockService = MockNewsService(
        delay: Duration.zero,
        simulatedState: MockState.success,
      );
      final provider = NewsProvider(newsService: mockService);

      // Listener untuk memverifikasi pemanggilan notifyListeners
      int notificationCount = 0;
      provider.addListener(() {
        notificationCount++;
      });

      await provider.fetchArticles();

      expect(provider.status, NewsStatus.sukses);
      expect(provider.isSukses, isTrue);
      expect(provider.articles.length, 5);
      expect(provider.articles.first.title, contains('Flutter 3'));
      expect(notificationCount, greaterThanOrEqualTo(2)); // Loading state dan Sukses state
    });

    test('fetchArticles mengubah status ke NewsStatus.kosong saat tidak ada artikel', () async {
      final mockService = MockNewsService(
        delay: Duration.zero,
        simulatedState: MockState.empty,
      );
      final provider = NewsProvider(newsService: mockService);

      await provider.fetchArticles();

      expect(provider.status, NewsStatus.kosong);
      expect(provider.isKosong, isTrue);
      expect(provider.articles, isEmpty);
    });

    test('fetchArticles mengubah status ke NewsStatus.error saat terjadi kegagalan layanan', () async {
      final mockService = MockNewsService(
        delay: Duration.zero,
        simulatedState: MockState.error,
      );
      final provider = NewsProvider(newsService: mockService);

      await provider.fetchArticles();

      expect(provider.status, NewsStatus.error);
      expect(provider.isError, isTrue);
      expect(provider.errorMessage, isNotEmpty);
      expect(provider.errorMessage, contains('Simulasi gagal memuat berita'));
    });

    test('setCategory memperbarui kategori dan memfilter artikel', () async {
      final mockService = MockNewsService(
        delay: Duration.zero,
        simulatedState: MockState.success,
      );
      final provider = NewsProvider(newsService: mockService);

      // Kategori awal
      expect(provider.selectedCategory, 'Semua');

      // Pilih kategori Teknologi
      provider.setCategory('Teknologi');
      await Future<void>.delayed(Duration.zero);

      expect(provider.selectedCategory, 'Teknologi');
      expect(provider.status, NewsStatus.sukses);
      expect(provider.articles, isNotEmpty);
    });

    test('setSearchQuery dan clearSearch memfilter dan mereset artikel', () async {
      final mockService = MockNewsService(
        delay: Duration.zero,
        simulatedState: MockState.success,
      );
      final provider = NewsProvider(newsService: mockService);

      // Cari artikel dengan kata kunci tertentu
      provider.setSearchQuery('Kecerdasan Buatan');
      await Future<void>.delayed(Duration.zero);

      expect(provider.searchQuery, 'Kecerdasan Buatan');
      expect(provider.status, NewsStatus.sukses);
      expect(provider.articles.length, 1);
      expect(provider.articles.first.title, contains('Kecerdasan Buatan'));

      // Hapus pencarian
      provider.clearSearch();
      await Future<void>.delayed(Duration.zero);

      expect(provider.searchQuery, isEmpty);
      expect(provider.articles.length, 5);
    });
  });
}
