import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/article.dart';

void main() {
  group('Article Model & fromJson Tests', () {
    test('Mem-parsing JSON lengkap sesuai format NewsAPI.org', () {
      final jsonMap = {
        'source': {
          'id': 'techcrunch',
          'name': 'TechCrunch',
        },
        'author': 'Jane Doe',
        'title': 'Judul Berita Lengkap',
        'description': 'Deskripsi singkat berita.',
        'url': 'https://techcrunch.com/article',
        'urlToImage': 'https://techcrunch.com/image.jpg',
        'publishedAt': '2026-10-13T08:30:00Z',
        'content': 'Konten lengkap berita di sini.',
      };

      // Mem-parsing map JSON menjadi objek model Article
      final article = Article.fromJson(jsonMap);

      expect(article.sourceName, 'TechCrunch');
      expect(article.author, 'Jane Doe');
      expect(article.title, 'Judul Berita Lengkap');
      expect(article.description, 'Deskripsi singkat berita.');
      expect(article.url, 'https://techcrunch.com/article');
      expect(article.urlToImage, 'https://techcrunch.com/image.jpg');
      expect(article.publishedAt, DateTime.parse('2026-10-13T08:30:00Z'));
      expect(article.content, 'Konten lengkap berita di sini.');
    });

    test('Menangani nilai null pada semua field opsional tanpa error', () {
      final jsonWithNulls = <String, dynamic>{
        'source': null,
        'author': null,
        'title': 'Berita Hanya Berjudul',
        'description': null,
        'url': null,
        'urlToImage': null,
        'publishedAt': null,
        'content': null,
      };

      final article = Article.fromJson(jsonWithNulls);

      expect(article.sourceName, isNull);
      expect(article.author, isNull);
      expect(article.title, 'Berita Hanya Berjudul');
      expect(article.description, isNull);
      expect(article.url, isNull);
      expect(article.urlToImage, isNull);
      expect(article.publishedAt, isNull);
      expect(article.content, isNull);
    });

    test('Menangani title null dengan fallback nilai default agar tidak crash', () {
      final jsonNoTitle = <String, dynamic>{
        'source': {'name': 'Media X'},
        'title': null,
      };

      final article = Article.fromJson(jsonNoTitle);

      expect(article.title, 'Tanpa Judul');
      expect(article.sourceName, 'Media X');
    });

    test('Memverifikasi file contoh assets/mock/articles.json berhasil di-parse secara utuh', () {
      // Membaca file contoh langsung dari path assets/mock/articles.json
      final file = File('assets/mock/articles.json');
      expect(file.existsSync(), isTrue, reason: 'File mock articles.json harus ada');

      final rawString = file.readAsStringSync();
      final decoded = jsonDecode(rawString) as Map<String, dynamic>;

      expect(decoded['status'], 'ok');
      expect(decoded['totalResults'], 5);

      final rawArticles = decoded['articles'] as List<dynamic>;
      expect(rawArticles.length, 5);

      // Konversi seluruh elemen list JSON menjadi List<Article>
      final articles = rawArticles
          .map((item) => Article.fromJson(item as Map<String, dynamic>))
          .toList();

      expect(articles.length, 5);

      // Artikel 1: Semua field lengkap
      expect(articles[0].title, contains('Flutter 3'));
      expect(articles[0].sourceName, 'Kompas Tekno');
      expect(articles[0].author, 'Rizky Pratama');
      expect(articles[0].urlToImage, isNotNull);

      // Artikel 2: Author bernilai null
      expect(articles[1].title, contains('Kecerdasan Buatan'));
      expect(articles[1].author, isNull);
      expect(articles[1].sourceName, 'Detik Inet');

      // Artikel 3: Description & urlToImage bernilai null
      expect(articles[2].title, contains('Pertumbuhan Ekonomi Digital'));
      expect(articles[2].description, isNull);
      expect(articles[2].urlToImage, isNull);

      // Artikel 4: Content bernilai null
      expect(articles[3].title, contains('Pentingnya Pembelajaran'));
      expect(articles[3].content, isNull);

      // Artikel 5: Source, author, urlToImage, publishedAt, content bernilai null
      expect(articles[4].sourceName, isNull);
      expect(articles[4].author, isNull);
      expect(articles[4].urlToImage, isNull);
      expect(articles[4].publishedAt, isNull);
      expect(articles[4].title, contains('Inovasi Energi Terbarukan'));
    });

    test('Uji equality (==) dan hashCode berdasarkan url dan title', () {
      const article1 = Article(
        title: 'Judul Sama',
        url: 'https://example.com/1',
      );
      const article2 = Article(
        title: 'Judul Sama',
        url: 'https://example.com/1',
      );
      const article3 = Article(
        title: 'Judul Berbeda',
        url: 'https://example.com/2',
      );

      expect(article1 == article2, isTrue);
      expect(article1.hashCode, article2.hashCode);
      expect(article1 == article3, isFalse);
    });
  });
}

