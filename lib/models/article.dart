/// [Article] merepresentasikan satu entitas berita yang diambil dari API.
/// Sesuai PRD, seluruh field diperbolehkan bernilai null (opsional) kecuali [title].
class Article {
  /// Nama sumber penerbit berita (misal: "Kompas Tekno", "Detik Inet").
  final String? sourceName;

  /// Penulis artikel (opsional/bisa null).
  final String? author;

  /// Judul berita (wajib ada/tidak boleh null).
  final String title;

  /// Ringkasan atau deskripsi singkat berita (opsional/bisa null).
  final String? description;

  /// Tautan web asli artikel berita (opsional/bisa null).
  final String? url;

  /// Tautan URL gambar ilustrasi berita (opsional/bisa null).
  final String? urlToImage;

  /// Waktu publikasi artikel dalam format [DateTime] (opsional/bisa null).
  final DateTime? publishedAt;

  /// Isi konten lengkap artikel berita (opsional/bisa null).
  final String? content;

  const Article({
    this.sourceName,
    this.author,
    required this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  /// Factory constructor [fromJson] untuk mem-parsing data JSON (Map) menjadi objek [Article].
  ///
  /// Catatan edukasi:
  /// - Format respons NewsAPI.org membungkus sumber dalam objek: `source: {"id": "...", "name": "..."}`.
  /// - Field [title] diberi nilai default jika null agar tidak menyebabkan runtime error.
  /// - [DateTime.tryParse] digunakan agar tidak crash jika format tanggal tidak valid atau null.
  factory Article.fromJson(Map<String, dynamic> json) {
    // Mengekstrak nama sumber berita dari nested object 'source' atau field 'sourceName'
    String? extractedSourceName;
    final sourceData = json['source'];
    if (sourceData is Map<String, dynamic>) {
      extractedSourceName = sourceData['name'] as String?;
    } else if (json['sourceName'] is String) {
      extractedSourceName = json['sourceName'] as String?;
    }

    // Mem-parsing tanggal jika tersedia dalam bentuk string ISO-8601
    DateTime? parsedPublishedAt;
    final rawPublishedAt = json['publishedAt'];
    if (rawPublishedAt is String) {
      parsedPublishedAt = DateTime.tryParse(rawPublishedAt);
    } else if (rawPublishedAt is DateTime) {
      parsedPublishedAt = rawPublishedAt;
    }

    return Article(
      sourceName: extractedSourceName,
      author: json['author'] as String?,
      // Judul wajib ada; jika kosong pada data, beri nilai cadangan
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? (json['title'] as String).trim()
          : 'Tanpa Judul',
      description: json['description'] as String?,
      url: json['url'] as String?,
      urlToImage: json['urlToImage'] as String?,
      publishedAt: parsedPublishedAt,
      content: json['content'] as String?,
    );
  }

  /// Mengubah objek [Article] kembali menjadi [Map] JSON.
  Map<String, dynamic> toJson() {
    return {
      'source': {
        'name': sourceName,
      },
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt?.toIso8601String(),
      'content': content,
    };
  }

  /// Helper untuk menyalin artikel dengan properti yang diperbarui.
  Article copyWith({
    String? sourceName,
    String? author,
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    DateTime? publishedAt,
    String? content,
  }) {
    return Article(
      sourceName: sourceName ?? this.sourceName,
      author: author ?? this.author,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      urlToImage: urlToImage ?? this.urlToImage,
      publishedAt: publishedAt ?? this.publishedAt,
      content: content ?? this.content,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Article &&
        other.url == url &&
        other.title == title;
  }

  @override
  int get hashCode => Object.hash(url, title);

  @override
  String toString() {
    return 'Article(title: $title, sourceName: $sourceName, author: $author)';
  }
}

