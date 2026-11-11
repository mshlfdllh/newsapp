import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:news_app/providers/bookmark_provider.dart';
import 'package:news_app/providers/news_provider.dart';
import 'package:news_app/screens/home_screen.dart';
import 'package:news_app/services/api_news_service.dart';
import 'package:news_app/services/mock_news_service.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/theme/app_theme.dart';

void main() {
  runApp(const NewsApp());
}

/// [NewsApp] merupakan root widget utama untuk aplikasi berita News App.
///
/// Catatan integrasi:
/// - Jika [NEWS_API_KEY] tersedia lewat environment (`--dart-define-from-file=env.json`),
///   aplikasi akan menggunakan [ApiNewsService] untuk memuat berita nyata dari NewsAPI.org.
/// - Jika tidak ada API key yang dipasang (misalnya saat widget testing), aplikasi
///   secara otomatis menggunakan [MockNewsService] agar pengujian tetap stabil tanpa koneksi internet.
class NewsApp extends StatelessWidget {
  /// Layanan berita yang dapat di-inject secara manual (misalnya untuk kebutuhan testing).
  final NewsService? newsService;

  const NewsApp({super.key, this.newsService});

  @override
  Widget build(BuildContext context) {
    // Mengecek ketersediaan API key dari environment
    const apiKey = String.fromEnvironment('NEWS_API_KEY');
    final activeNewsService = newsService ??
        (apiKey.isNotEmpty ? ApiNewsService() : MockNewsService());

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NewsProvider>(
          create: (context) => NewsProvider(
            newsService: activeNewsService,
          )..fetchArticles(),
        ),
        ChangeNotifierProvider<BookmarkProvider>(
          create: (context) => BookmarkProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'News App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Mengizinkan gesture scroll & drag menggunakan mouse, trackpad, dan touch
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.stylus,
          },
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
