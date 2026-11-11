import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/bookmark_provider.dart';
import 'package:news_app/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// [DetailScreen] menampilkan isi lengkap artikel berita yang dipilih dari Beranda atau Favorit.
///
/// Sesuai PRD, layar ini menampilkan:
/// 1. Gambar artikel (dengan penanganan placeholder jika null atau gagal dimuat).
/// 2. Judul lengkap artikel.
/// 3. Informasi metadata (penulis, nama sumber, dan tanggal publikasi).
/// 4. Ringkasan deskripsi dan isi konten berita.
/// 5. Tombol "Baca selengkapnya" (membuka tautan web asli via url_launcher).
class DetailScreen extends StatelessWidget {
  /// Data artikel yang akan ditampilkan.
  final Article article;

  const DetailScreen({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Berita'),
        actions: [
          // Tombol aksi bookmark pada AppBar layar detail
          Consumer<BookmarkProvider>(
            builder: (context, bookmarkProvider, child) {
              final isBookmarked = bookmarkProvider.isBookmarked(article);
              return IconButton(
                icon: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isBookmarked
                      ? AppTheme.favoriteColor
                      : AppTheme.textPrimaryColor,
                  size: AppTheme.spacing24,
                ),
                tooltip: isBookmarked ? 'Hapus dari favorit' : 'Simpan ke favorit',
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
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Artikel atau Placeholder
            _buildImage(),

            // 2. Konten Utama
            Padding(
              padding: AppTheme.padding16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sumber Berita & Tanggal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge Nama Sumber
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing8,
                          vertical: AppTheme.spacing8 / 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryContainerColor,
                          borderRadius: AppTheme.borderRadius8,
                        ),
                        child: Text(
                          article.sourceName?.trim().isNotEmpty == true
                              ? article.sourceName!
                              : 'Berita',
                          style: AppTheme.bodyPrimaryStyle.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Waktu Publikasi
                      Text(
                        _formatDate(article.publishedAt),
                        style: AppTheme.bodyStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing16),

                  // Judul Berita
                  Text(
                    article.title,
                    style: AppTheme.titleStyle,
                  ),
                  const SizedBox(height: AppTheme.spacing8),

                  // Penulis Artikel
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: AppTheme.spacing16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: AppTheme.spacing8 / 2),
                      Expanded(
                        child: Text(
                          article.author?.trim().isNotEmpty == true
                              ? 'Oleh: ${article.author!}'
                              : 'Penulis tidak dicantumkan',
                          style: AppTheme.bodyStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  const Divider(color: AppTheme.borderColor),
                  const SizedBox(height: AppTheme.spacing16),

                  // Deskripsi Berita
                  if (article.description != null &&
                      article.description!.trim().isNotEmpty) ...[
                    Text(
                      article.description!.trim(),
                      style: AppTheme.bodyPrimaryStyle.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                  ],

                  // Konten Lengkap Berita
                  Text(
                    article.content != null && article.content!.trim().isNotEmpty
                        ? article.content!.trim()
                        : 'Konten lengkap artikel dapat dibaca melalui tautan sumber asli di bawah ini.',
                    style: AppTheme.bodyStyle,
                  ),
                  const SizedBox(height: AppTheme.spacing32),

                  // Tombol "Baca selengkapnya" (Sudah dihubungkan dengan url_launcher)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (article.url != null && article.url!.isNotEmpty) {
                          bukaArtikel(context, article.url!);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tautan artikel tidak tersedia.'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.open_in_new_rounded,
                        size: AppTheme.spacing16,
                      ),
                      label: const Text('Baca selengkapnya'),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun visual gambar utama dengan penanganan placeholder jika URL bernilai null atau error.
  Widget _buildImage() {
    final imageUrl = article.urlToImage;

    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return _buildPlaceholder();
    }

    return SizedBox(
      height: AppTheme.detailImageHeight,
      width: double.infinity,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(isLoading: true);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      ),
    );
  }

  /// Placeholder visual yang konsisten menggunakan palet warna [AppTheme].
  Widget _buildPlaceholder({bool isLoading = false}) {
    return Container(
      height: AppTheme.detailImageHeight,
      width: double.infinity,
      color: AppTheme.placeholderColor,
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: AppTheme.spacing32,
                height: AppTheme.spacing32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryColor,
                ),
              )
            : const Icon(
                Icons.image_not_supported_outlined,
                size: AppTheme.spacing48,
                color: AppTheme.textSecondaryColor,
              ),
      ),
    );
  }

  /// Memformat waktu publikasi [DateTime] menjadi tanggal berbahasa Indonesia tanpa package eksternal.
  String _formatDate(DateTime? date) {
    if (date == null) return 'Waktu tidak tersedia';
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = monthNames[date.month - 1];
    final year = date.year;
    return '$day $month $year';
  }
}

/// Fungsi helper untuk meluncurkan URL eksternal menggunakan package url_launcher
Future<void> bukaArtikel(BuildContext context, String url) async {
  final berhasil = await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  );
  
  if (!berhasil && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tidak bisa membuka tautan artikel.')),
    );
  }
}


