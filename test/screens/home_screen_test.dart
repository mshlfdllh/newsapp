import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:news_app/providers/bookmark_provider.dart';
import 'package:news_app/providers/news_provider.dart';
import 'package:news_app/screens/home_screen.dart';
import 'package:news_app/services/mock_news_service.dart';
import 'package:news_app/theme/app_theme.dart';
import 'package:news_app/widgets/article_card.dart';
import 'package:news_app/widgets/state_views.dart';

Widget _createTestWidget(NewsProvider provider, [BookmarkProvider? bookmarkProvider]) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<NewsProvider>.value(value: provider),
      ChangeNotifierProvider<BookmarkProvider>.value(
        value: bookmarkProvider ?? BookmarkProvider(),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeScreen State Views Tests', () {
    testWidgets('Menampilkan LoadingView saat status loading', (WidgetTester tester) async {
      final mockService = MockNewsService(
        delay: Duration.zero,
      );
      // Inisialisasi provider tanpa memanggil fetchArticles sehingga status tetap NewsStatus.loading
      final provider = NewsProvider(newsService: mockService);

      await tester.pumpWidget(_createTestWidget(provider));
      await tester.pump();

      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.text('Memuat berita terbaru...'), findsOneWidget);
    });

    testWidgets('Menampilkan ErrorView dengan tombol Coba Lagi saat status error', (WidgetTester tester) async {
      final mockService = MockNewsService(
        delay: Duration.zero,
        simulatedState: MockState.error,
      );
      final provider = NewsProvider(newsService: mockService);
      await provider.fetchArticles();

      await tester.pumpWidget(_createTestWidget(provider));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Gagal Memuat Berita'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('Menampilkan EmptyView saat status kosong', (WidgetTester tester) async {
      final mockService = MockNewsService(
        delay: Duration.zero,
        simulatedState: MockState.empty,
      );
      final provider = NewsProvider(newsService: mockService);
      await provider.fetchArticles();

      await tester.pumpWidget(_createTestWidget(provider));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyView), findsOneWidget);
      expect(find.text('Tidak Ada Berita'), findsOneWidget);
    });

    testWidgets('Menampilkan daftar ArticleCard saat status sukses dan dapat dinavigasikan ke DetailScreen', (WidgetTester tester) async {
      final mockService = MockNewsService(
        delay: Duration.zero,
        simulatedState: MockState.success,
      );
      final provider = NewsProvider(newsService: mockService);
      await provider.fetchArticles();

      await tester.pumpWidget(_createTestWidget(provider));
      await tester.pumpAndSettle();

      expect(find.byType(ArticleCard), findsWidgets);
      final firstArticle = find.textContaining('Flutter 3');
      expect(firstArticle, findsOneWidget);

      // Menekan kartu artikel pertama untuk memicu navigasi ke DetailScreen
      await tester.tap(firstArticle);
      await tester.pumpAndSettle();

      // Memverifikasi bahwa layar Detail berhasil dibuka
      expect(find.text('Detail Berita'), findsOneWidget);
      expect(find.text('Baca selengkapnya'), findsOneWidget);
    });

    testWidgets('Menampilkan kolom cari dan chip kategori di Beranda serta dapat memfilter data', (WidgetTester tester) async {
      final mockService = MockNewsService(
        delay: Duration.zero,
        simulatedState: MockState.success,
      );
      final provider = NewsProvider(newsService: mockService);
      await provider.fetchArticles();

      await tester.pumpWidget(_createTestWidget(provider));
      await tester.pumpAndSettle();

      // Memverifikasi keberadaan TextField pencarian dan chip kategori
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Cari berita...'), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Teknologi'), findsOneWidget);
      expect(find.text('Bisnis'), findsOneWidget);

      // Mengetuk kategori 'Bisnis'
      await tester.tap(find.text('Bisnis'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(provider.selectedCategory, 'Bisnis');

      // Menguji pencarian melalui TextField onSubmitted
      final textField = tester.widget<TextField>(find.byType(TextField));
      textField.onSubmitted?.call('Kecerdasan');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(provider.searchQuery, 'Kecerdasan');
    });
  });
}
