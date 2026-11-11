import 'package:flutter/material.dart';
import 'package:news_app/theme/app_theme.dart';

/// Tampilan state saat aplikasi sedang mengambil data berita ([NewsStatus.loading]).
class LoadingView extends StatelessWidget {
  /// Pesan yang ditampilkan di bawah indikator loading.
  final String message;

  const LoadingView({
    super.key,
    this.message = 'Memuat berita terbaru...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppTheme.padding16,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              message,
              style: AppTheme.bodyStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tampilan state saat terjadi kegagalan pemanggilan data ([NewsStatus.error]).
/// Dilengkapi tombol aksi "Coba Lagi" untuk mengulang proses.
class ErrorView extends StatelessWidget {
  /// Pesan kesalahan yang akan ditampilkan ke pengguna.
  final String message;

  /// Callback aksi saat pengguna menekan tombol "Coba Lagi".
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: AppTheme.padding24,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: AppTheme.spacing48,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: AppTheme.spacing16),
            const Text(
              'Gagal Memuat Berita',
              style: AppTheme.titleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              message.isNotEmpty
                  ? message
                  : 'Terjadi gangguan koneksi internet. Silakan coba kembali.',
              style: AppTheme.bodyStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: AppTheme.spacing16),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tampilan state saat data berita berhasil diambil tetapi hasilnya kosong ([NewsStatus.kosong]).
class EmptyView extends StatelessWidget {
  /// Pesan informasi bahwa tidak ada berita.
  final String message;

  /// Callback aksi opsional untuk memuat ulang data.
  final VoidCallback? onRetry;

  const EmptyView({
    super.key,
    this.message = 'Belum ada berita yang tersedia untuk saat ini.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: AppTheme.padding24,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.newspaper_outlined,
              size: AppTheme.spacing48,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: AppTheme.spacing16),
            const Text(
              'Tidak Ada Berita',
              style: AppTheme.titleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              message,
              style: AppTheme.bodyStyle,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppTheme.spacing24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: AppTheme.spacing16),
                label: const Text('Muat Ulang'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

