import 'package:flutter/material.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/theme/app_theme.dart';

/// [ArticleCard] adalah komponen kartu berita terpadu yang digunakan di layar Beranda
/// dan layar Favorit sesuai spesifikasi PRD.
///
/// Komponen ini menampilkan:
/// 1. Gambar artikel dengan placeholder jika URL null atau gagal dimuat.
/// 2. Nama sumber penerbit dan waktu publikasi.
/// 3. Judul artikel (maksimal 2 baris).
/// 4. Ringkasan/deskripsi artikel jika tersedia.
/// 5. Tombol aksi opsional di bagian trailing (misalnya tombol bookmark).
class ArticleCard extends StatelessWidget {
  /// Objek data artikel yang ditampilkan pada kartu.
  final Article article;

  /// Callback ketika kartu artikel ditekan oleh pengguna.
  final VoidCallback? onTap;

  /// Widget opsional di pojok kanan metadata (misalnya ikon bookmark).
  final Widget? trailing;

  const ArticleCard({
    super.key,
    required this.article,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar artikel atau Placeholder
            _buildImage(),

            // 2. Konten kartu (Metadata, Judul, Deskripsi)
            Padding(
              padding: AppTheme.padding16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metadata: Sumber, Waktu Terbit, dan Trailing Widget
                  Row(
                    children: [
                      // Nama Sumber Berita
                      Expanded(
                        child: Text(
                          article.sourceName?.trim().isNotEmpty == true
                              ? article.sourceName!
                              : 'Berita',
                          style: AppTheme.bodyPrimaryStyle.copyWith(
                            color: AppTheme.primaryLightColor,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      // Tanggal Publikasi
                      Text(
                        _formatDate(article.publishedAt),
                        style: AppTheme.bodyStyle,
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: AppTheme.spacing8),
                        trailing!,
                      ],
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing8),

                  // Judul Berita
                  Text(
                    article.title,
                    style: AppTheme.titleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Deskripsi Berita (hanya tampil jika tidak null dan tidak kosong)
                  if (article.description != null &&
                      article.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacing8),
                    Text(
                      article.description!.trim(),
                      style: AppTheme.bodyStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun widget gambar artikel dengan penanganan kondisi null,
  /// proses loading, dan error saat memuat gambar.
  Widget _buildImage() {
    final imageUrl = article.urlToImage;

    // Jika tautan gambar tidak tersedia, tampilkan placeholder
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return _buildPlaceholder();
    }

    return SizedBox(
      height: AppTheme.cardImageHeight,
      width: double.infinity,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        // Ditampilkan saat proses mengunduh gambar berlangsung
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(isLoading: true);
        },
        // Ditampilkan jika URL gambar gagal dimuat / 404
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      ),
    );
  }

  /// Placeholder visual konsisten yang menggunakan warna dari [AppTheme].
  Widget _buildPlaceholder({bool isLoading = false}) {
    return Container(
      height: AppTheme.cardImageHeight,
      width: double.infinity,
      color: AppTheme.placeholderColor,
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: AppTheme.spacing24,
                height: AppTheme.spacing24,
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

  /// Memformat waktu publikasi [DateTime] menjadi teks tanggal berbahasa Indonesia
  /// tanpa menggunakan library eksternal (sesuai batasan PRD).
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

