import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/services/mock_news_service.dart';
import 'package:news_app/services/news_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MockNewsService Tests', () {
    test('MockNewsService mengimplementasikan antarmuka abstrak NewsService', () {
      final MockNewsService service = MockNewsService();
      expect(service, isA<NewsService>());
    });

    test('Mengembalikan daftar artikel saat simulatedState bernilai MockState.success', () async {
      final service = MockNewsService(
        delay: Duration.zero, // Nolkan jeda agar unit test berjalan cepat
        simulatedState: MockState.success,
      );

      final articles = await service.fetchArticles();

      expect(articles, isNotEmpty);
      expect(articles.length, 5);
      expect(articles.first, isA<Article>());
      expect(articles.first.title, contains('Flutter 3'));
    });

    test('Melempar Exception saat simulatedState diubah menjadi MockState.error', () async {
      final service = MockNewsService(
        delay: Duration.zero,
        simulatedState: MockState.error,
      );

      expect(
        () async => await service.fetchArticles(),
        throwsA(isA<Exception>()),
      );
    });

    test('Mengembalikan list kosong saat simulatedState diubah menjadi MockState.empty', () async {
      final service = MockNewsService(
        delay: Duration.zero,
        simulatedState: MockState.empty,
      );

      final articles = await service.fetchArticles();

      expect(articles, isEmpty);
      expect(articles, isA<List<Article>>());
    });

    test('Menyaring artikel berdasarkan kata kunci pencarian (query)', () async {
      final service = MockNewsService(
        delay: Duration.zero,
        simulatedState: MockState.success,
      );

      final results = await service.fetchArticles(query: 'Kecerdasan Buatan');

      expect(results.length, 1);
      expect(results.first.title, contains('Kecerdasan Buatan'));
    });

    test('Menyaring artikel berdasarkan kata kunci yang tidak ada menghasilkan list kosong', () async {
      final service = MockNewsService(
        delay: Duration.zero,
        simulatedState: MockState.success,
      );

      final results = await service.fetchArticles(query: 'KataKunciYangTidakPernahAda12345');

      expect(results, isEmpty);
    });

    test('Memverifikasi penerapan durasi jeda buatan (delay)', () async {
      final service = MockNewsService(
        delay: const Duration(milliseconds: 150),
        simulatedState: MockState.empty,
      );

      final stopwatch = Stopwatch()..start();
      await service.fetchArticles();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
    });
  });
}

