import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/main.dart';
import 'package:news_app/widgets/article_card.dart';

void main() {
  testWidgets('NewsApp menampilkan HomeScreen dan kartu berita di Beranda', (WidgetTester tester) async {
    // Membangun aplikasi NewsApp
    await tester.pumpWidget(const NewsApp());

    // Menunggu seluruh proses asynchronous dan frame animasi selesai
    await tester.pumpAndSettle();

    // Memverifikasi bahwa judul halaman 'Berita Terkini' tampil di AppBar
    expect(find.text('Berita Terkini'), findsOneWidget);

    // Memverifikasi bahwa ArticleCard berhasil dirender di layar
    expect(find.byType(ArticleCard), findsWidgets);
    expect(find.textContaining('Flutter 3'), findsOneWidget);
  });
}
