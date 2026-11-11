import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:news_app/providers/bookmark_provider.dart';
import 'package:news_app/screens/detail_screen.dart';
import 'package:news_app/theme/app_theme.dart';
import 'package:news_app/widgets/article_card.dart';
import 'package:news_app/widgets/state_views.dart';

/// [BookmarkScreen] menampilkan seluruh daftar artikel berita yang disimpan di memori
/// oleh pengguna sebagai favorit.
///
/// Komponen ini memenuhi standar PRD:
/// 1. Menggunakan komponen [ArticleCard] yang sama seperti di Beranda.
/// 2. Menampilkan [EmptyView] yang rapi jika belum ada berita yang ditandai.
/// 3. Memungkinkan pengguna membaca detail atau melepas tanda bookmark langsung dari daftar.
class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel Favorit'),
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, bookmarkProvider, child) {
          // Jika belum ada artikel yang dibookmark, tampilkan EmptyView
          if (bookmarkProvider.isEmpty) {
            return const EmptyView(
              message: 'Belum ada artikel favorit yang disimpan.\n'
                  'Tandai artikel menarik dari Beranda atau Detail untuk membacanya nanti.',
            );
          }

          // Menampilkan daftar artikel yang tersimpan di memori
          final articles = bookmarkProvider.bookmarkedArticles;
          return ListView.separated(
            padding: AppTheme.padding16,
            itemCount: articles.length,
            separatorBuilder: (context, index) => const SizedBox(
              height: AppTheme.spacing16,
            ),
            itemBuilder: (context, index) {
              final article = articles[index];
              return ArticleCard(
                article: article,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(article: article),
                    ),
                  );
                },
                // Tombol aksi untuk melepas bookmark langsung dari layar Favorit
                trailing: IconButton(
                  icon: const Icon(
                    Icons.bookmark_remove_rounded,
                    color: AppTheme.favoriteColor,
                    size: AppTheme.spacing24,
                  ),
                  tooltip: 'Hapus dari favorit',
                  onPressed: () {
                    bookmarkProvider.removeBookmark(article);
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 1),
                        backgroundColor: AppTheme.textPrimaryColor,
                        content: Text(
                          'Artikel dihapus dari favorit',
                          style: AppTheme.bodyStyle.copyWith(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
