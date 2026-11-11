import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:news_app/providers/bookmark_provider.dart';
import 'package:news_app/providers/news_provider.dart';
import 'package:news_app/screens/bookmark_screen.dart';
import 'package:news_app/screens/detail_screen.dart';
import 'package:news_app/theme/app_theme.dart';
import 'package:news_app/widgets/article_card.dart';
import 'package:news_app/widgets/state_views.dart';

/// [HomeScreen] menampilkan layar Beranda utama aplikasi berita.
///
/// Fitur yang didukung sesuai PRD:
/// 1. Kolom pencarian berita berbasis kata kunci.
/// 2. Chip filter kategori (Semua, Teknologi, Bisnis, Olahraga, Sains).
/// 3. Penanganan 4 status jaringan ([NewsStatus.loading], [NewsStatus.sukses],
///    [NewsStatus.error], [NewsStatus.kosong]).
/// 4. Pull-to-refresh untuk memuat ulang daftar artikel.
/// 5. Bookmark langsung dari kartu berita.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Controller untuk mengelola input teks pencarian berita.
  late final TextEditingController _searchController;

  /// Daftar pilihan kategori berita resmi yang tersedia di NewsAPI.org.
  static const List<String> _categories = [
    'Semua',
    'Bisnis',
    'Teknologi',
    'Olahraga',
    'Kesehatan',
    'Sains',
    'Hiburan',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Mendengarkan perubahan input agar tombol hapus teks pencarian responsif
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita Terkini'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmarks_rounded),
            tooltip: 'Artikel Favorit',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookmarkScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Kolom Pencarian Berita
          Padding(
            padding: AppTheme.paddingHorizontal16,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari berita...',
                hintStyle: AppTheme.bodyStyle,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppTheme.textSecondaryColor,
                  size: AppTheme.spacing24,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: AppTheme.textSecondaryColor,
                          size: AppTheme.spacing16,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          context.read<NewsProvider>().clearSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.surfaceColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing16,
                  vertical: AppTheme.spacing8,
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: AppTheme.borderRadius8,
                  borderSide: BorderSide(color: AppTheme.borderColor),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: AppTheme.borderRadius8,
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              onSubmitted: (query) {
                context.read<NewsProvider>().setSearchQuery(query);
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),

          // 2. Daftar Chip Kategori Berita
          SizedBox(
            height: AppTheme.spacing48,
            child: Consumer<NewsProvider>(
              builder: (context, newsProvider, child) {
                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                      PointerDeviceKind.stylus,
                    },
                  ),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: AppTheme.paddingHorizontal16,
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) => const SizedBox(
                      width: AppTheme.spacing8,
                    ),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = newsProvider.selectedCategory == category;
                      return Center(
                        child: InkWell(
                          borderRadius: AppTheme.borderRadius16,
                          onTap: () {
                            newsProvider.setCategory(category);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacing16,
                              vertical: AppTheme.spacing8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.surfaceColor,
                              borderRadius: AppTheme.borderRadius16,
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.borderColor,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              category,
                              style: isSelected
                                  ? AppTheme.bodyPrimaryStyle.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    )
                                  : AppTheme.bodyStyle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),

          // 3. Tampilan Konten Dinamis Berdasarkan Status Jaringan
          Expanded(
            child: Consumer<NewsProvider>(
              builder: (context, newsProvider, child) {
                switch (newsProvider.status) {
                  case NewsStatus.loading:
                    return const LoadingView();

                  case NewsStatus.error:
                    return ErrorView(
                      message: newsProvider.errorMessage,
                      onRetry: () => newsProvider.fetchArticles(),
                    );

                  case NewsStatus.kosong:
                    final message = newsProvider.searchQuery.isNotEmpty
                        ? 'Tidak ada berita yang cocok dengan kata kunci "${newsProvider.searchQuery}".'
                        : 'Belum ada berita untuk kategori "${newsProvider.selectedCategory}".';
                    return EmptyView(
                      message: message,
                      onRetry: () {
                        _searchController.clear();
                        newsProvider.clearSearch();
                        newsProvider.setCategory('Semua');
                      },
                    );

                  case NewsStatus.sukses:
                    return RefreshIndicator(
                      color: AppTheme.primaryColor,
                      onRefresh: () => newsProvider.fetchArticles(),
                      child: ListView.separated(
                        padding: AppTheme.padding16,
                        itemCount: newsProvider.articles.length,
                        separatorBuilder: (context, index) => const SizedBox(
                          height: AppTheme.spacing16,
                        ),
                        itemBuilder: (context, index) {
                          final article = newsProvider.articles[index];
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
                            trailing: Consumer<BookmarkProvider>(
                              builder: (context, bookmarkProvider, child) {
                                final isBookmarked = bookmarkProvider.isBookmarked(article);
                                return IconButton(
                                  icon: Icon(
                                    isBookmarked
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    color: isBookmarked
                                        ? AppTheme.favoriteColor
                                        : AppTheme.textSecondaryColor,
                                    size: AppTheme.spacing24,
                                  ),
                                  tooltip: isBookmarked ? 'Hapus bookmark' : 'Simpan bookmark',
                                  onPressed: () {
                                    final currentlyBookmarked = bookmarkProvider.isBookmarked(article);
                                    bookmarkProvider.toggleBookmark(article);
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: const Duration(seconds: 1),
                                        backgroundColor: AppTheme.textPrimaryColor,
                                        content: Text(
                                          currentlyBookmarked
                                              ? 'Artikel dihapus dari favorit'
                                              : 'Artikel disimpan ke favorit',
                                          style: AppTheme.bodyStyle.copyWith(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
