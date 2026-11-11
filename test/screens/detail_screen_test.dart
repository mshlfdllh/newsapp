import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/bookmark_provider.dart';
import 'package:news_app/screens/detail_screen.dart';
import 'package:news_app/theme/app_theme.dart';

Widget _createTestWidget(Article article, [BookmarkProvider? bookmarkProvider]) {
  return ChangeNotifierProvider<BookmarkProvider>.value(
    value: bookmarkProvider ?? BookmarkProvider(),
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: DetailScreen(article: article),
    ),
  );
}

void main() {
  group('DetailScreen Tests', () {
    testWidgets('Menampilkan seluruh informasi artikel lengkap dengan rapi', (WidgetTester tester) async {
      final article = Article(
        sourceName: 'Kompas Tekno',
        author: 'Rizky Pratama',
        title: 'Flutter 3 Dirilis Resmi',
        description: 'Ringkasan mengenai pembaruan framework.',
        url: 'https://tekno.kompas.com/read/flutter-3',
        urlToImage: 'https://images.unsplash.com/photo-test.jpg',
        publishedAt: DateTime(2026, 10, 13, 8, 30),
        content: 'Konten lengkap mengenai arsitektur baru Impeller pada Flutter 3.',
      );

      await tester.pumpWidget(_createTestWidget(article));
      await tester.pump();

      expect(find.text('Detail Berita'), findsOneWidget);
      expect(find.text('Flutter 3 Dirilis Resmi'), findsOneWidget);
      expect(find.text('Kompas Tekno'), findsOneWidget);
      expect(find.text('Oleh: Rizky Pratama'), findsOneWidget);
      expect(find.text('13 Okt 2026'), findsOneWidget);
      expect(find.text('Ringkasan mengenai pembaruan framework.'), findsOneWidget);
      expect(find.text('Konten lengkap mengenai arsitektur baru Impeller pada Flutter 3.'), findsOneWidget);
      expect(find.text('Baca selengkapnya'), findsOneWidget);
    });

    testWidgets('Tetap tampil rapi saat author, description, urlToImage bernilai null', (WidgetTester tester) async {
      const article = Article(
        title: 'Berita Tanpa Penulis dan Gambar',
        sourceName: null,
        author: null,
        description: null,
        urlToImage: null,
        publishedAt: null,
        content: null,
      );

      await tester.pumpWidget(_createTestWidget(article));
      await tester.pump();

      expect(find.text('Berita Tanpa Penulis dan Gambar'), findsOneWidget);
      expect(find.text('Penulis tidak dicantumkan'), findsOneWidget);
      expect(find.text('Waktu tidak tersedia'), findsOneWidget);
      expect(find.text('Berita'), findsOneWidget); // Fallback nama sumber
      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
    });

    testWidgets('Menekan tombol Baca selengkapnya saat URL kosong memunculkan SnackBar informasi', (WidgetTester tester) async {
      const article = Article(
        title: 'Berita Uji Coba Tombol',
        url: null,
      );

      await tester.pumpWidget(_createTestWidget(article));
      await tester.pump();

      final button = find.text('Baca selengkapnya');
      expect(button, findsOneWidget);

      await tester.tap(button);
      await tester.pump(); // memicu SnackBar tampil

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Tautan artikel tidak tersedia.'), findsOneWidget);
    });

    testWidgets('Menekan tombol bookmark di AppBar menyimpan dan menghapus artikel dari favorit', (WidgetTester tester) async {
      const article = Article(
        title: 'Berita Uji Coba Bookmark',
        url: 'https://example.com/berita-bookmark',
      );
      final bookmarkProvider = BookmarkProvider();

      await tester.pumpWidget(_createTestWidget(article, bookmarkProvider));
      await tester.pump();

      expect(bookmarkProvider.isBookmarked(article), isFalse);

      // Tekan tombol bookmark untuk menyimpan ke favorit
      final bookmarkButton = find.byTooltip('Simpan ke favorit');
      expect(bookmarkButton, findsOneWidget);

      await tester.tap(bookmarkButton);
      await tester.pump();

      expect(bookmarkProvider.isBookmarked(article), isTrue);
      expect(find.text('Artikel disimpan ke favorit'), findsOneWidget);

      // Tunggu hingga SnackBar pertama selesai
      await tester.pumpAndSettle();

      // Tekan kembali untuk menghapus dari favorit
      final removeButton = find.byTooltip('Hapus dari favorit');
      expect(removeButton, findsOneWidget);

      await tester.tap(removeButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(bookmarkProvider.isBookmarked(article), isFalse);
      expect(find.text('Artikel dihapus dari favorit'), findsOneWidget);
    });
  });
}

