import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/bookmark_provider.dart';
import 'package:news_app/screens/bookmark_screen.dart';
import 'package:news_app/theme/app_theme.dart';
import 'package:news_app/widgets/article_card.dart';
import 'package:news_app/widgets/state_views.dart';

Widget _createTestWidget(BookmarkProvider bookmarkProvider) {
  return ChangeNotifierProvider<BookmarkProvider>.value(
    value: bookmarkProvider,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: const BookmarkScreen(),
    ),
  );
}

void main() {
  group('BookmarkScreen Tests', () {
    const article1 = Article(
      sourceName: 'Kompas Tekno',
      title: 'Artikel Favorit 1',
      url: 'https://example.com/fav-1',
    );
    const article2 = Article(
      sourceName: 'Detik Inet',
      title: 'Artikel Favorit 2',
      url: 'https://example.com/fav-2',
    );

    testWidgets('Menampilkan EmptyView saat belum ada artikel favorit', (WidgetTester tester) async {
      final bookmarkProvider = BookmarkProvider();

      await tester.pumpWidget(_createTestWidget(bookmarkProvider));
      await tester.pump();

      expect(find.text('Artikel Favorit'), findsOneWidget);
      expect(find.byType(EmptyView), findsOneWidget);
      expect(find.textContaining('Belum ada artikel favorit'), findsOneWidget);
    });

    testWidgets('Menampilkan daftar ArticleCard saat terdapat artikel favorit', (WidgetTester tester) async {
      final bookmarkProvider = BookmarkProvider()
        ..addBookmark(article1)
        ..addBookmark(article2);

      await tester.pumpWidget(_createTestWidget(bookmarkProvider));
      await tester.pump();

      expect(find.byType(ArticleCard), findsNWidgets(2));
      expect(find.text('Artikel Favorit 1'), findsOneWidget);
      expect(find.text('Artikel Favorit 2'), findsOneWidget);
    });

    testWidgets('Menghapus artikel dari favorit langsung memperbarui tampilan', (WidgetTester tester) async {
      final bookmarkProvider = BookmarkProvider()..addBookmark(article1);

      await tester.pumpWidget(_createTestWidget(bookmarkProvider));
      await tester.pump();

      expect(find.byType(ArticleCard), findsOneWidget);

      final removeBtn = find.byIcon(Icons.bookmark_remove_rounded);
      expect(removeBtn, findsOneWidget);

      await tester.tap(removeBtn);
      await tester.pump();

      expect(bookmarkProvider.isBookmarked(article1), isFalse);
      expect(find.byType(ArticleCard), findsNothing);
      expect(find.byType(EmptyView), findsOneWidget);
    });

    testWidgets('Mengetuk kartu artikel membuka DetailScreen', (WidgetTester tester) async {
      final bookmarkProvider = BookmarkProvider()..addBookmark(article1);

      await tester.pumpWidget(_createTestWidget(bookmarkProvider));
      await tester.pump();

      await tester.tap(find.text('Artikel Favorit 1'));
      await tester.pumpAndSettle();

      expect(find.text('Detail Berita'), findsOneWidget);
    });
  });
}

