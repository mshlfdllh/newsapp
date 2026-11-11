import 'package:flutter/foundation.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/services/news_service.dart';

enum NewsStatus {
  loading,
  sukses,
  error,
  kosong,
}

class NewsProvider extends ChangeNotifier {
  final NewsService newsService;

  NewsStatus _status = NewsStatus.loading;
  List<Article> _articles = [];
  String _errorMessage = '';
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  NewsProvider({required this.newsService});

  NewsStatus get status => _status;
  List<Article> get articles => List.unmodifiable(_articles);
  String get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  bool get isLoading => _status == NewsStatus.loading;
  bool get isSukses => _status == NewsStatus.sukses;
  bool get isError => _status == NewsStatus.error;
  bool get isKosong => _status == NewsStatus.kosong;

  Future<void> setCategory(String category) async {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    await fetchArticles(
      category: category == 'Semua' ? null : category,
      query: _searchQuery,
    );
  }

  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    await fetchArticles(
      category: _selectedCategory == 'Semua' ? null : _selectedCategory,
      query: query,
    );
  }

  Future<void> clearSearch() async {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    await fetchArticles(
      category: _selectedCategory == 'Semua' ? null : _selectedCategory,
      query: '',
    );
  }

  Future<void> fetchArticles({
    String? category,
    String? query,
  }) async {
    _status = NewsStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final activeCategory = category ?? (_selectedCategory == 'Semua' ? null : _selectedCategory);
      final activeQuery = query ?? _searchQuery;

      final results = await newsService.fetchArticles(
        category: activeCategory,
        query: activeQuery,
      );

      _articles = results;

      if (_articles.isEmpty) {
        _status = NewsStatus.kosong;
      } else {
        _status = NewsStatus.sukses;
      }
    } catch (e) {
      _status = NewsStatus.error;
      // Membersihkan teks 'Exception: ' agar pesan yang tampil berupa teks ramah pengguna
      final rawMessage = e.toString();
      _errorMessage = rawMessage.startsWith('Exception: ')
          ? rawMessage.replaceFirst('Exception: ', '')
          : rawMessage;
    } finally {
      notifyListeners();
    }
  }
}