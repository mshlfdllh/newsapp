import 'package:flutter/material.dart';

/// [AppTheme] mengatur seluruh palet warna, tipografi, dan jarak antar elemen
/// dalam aplikasi News App sesuai spesifikasi PRD.
///
/// Aturan proyek:
/// - Semua warna, ukuran teks, dan jarak wajib diambil dari file ini.
/// - Material 3 dengan satu warna utama dan warna netral.
/// - Dua tingkat tipografi saja: judul dan isi.
/// - Jarak antar elemen menggunakan kelipatan 8.
class AppTheme {
  // Private constructor agar kelas ini tidak diinstansiasi secara langsung.
  AppTheme._();

  // ===========================================================================
  // PALET WARNA (Satu warna utama & warna netral)
  // ===========================================================================

  /// Warna utama aplikasi (Primary Color) - Biru tua bernuansa editorial berita.
  static const Color primaryColor = Color(0xFF1E3A8A);

  /// Warna aksen / varian terang dari warna utama.
  static const Color primaryLightColor = Color(0xFF3B82F6);

  /// Warna latar belakang lembut untuk badge/label kategori & sumber (Soft Blue).
  static const Color primaryContainerColor = Color(0xFFDBEAFE);

  /// Warna latar belakang layar utama (Neutral Background - Slate 50).
  static const Color backgroundColor = Color(0xFFF8FAFC);

  /// Warna kartu dan bidang permukaan (Neutral Surface - Putih).
  static const Color surfaceColor = Color(0xFFFFFFFF);

  /// Warna teks utama / judul (Neutral Dark - Slate 900).
  static const Color textPrimaryColor = Color(0xFF0F172A);

  /// Warna teks sekunder / deskripsi / isi (Neutral Muted - Slate 500).
  static const Color textSecondaryColor = Color(0xFF64748B);

  /// Warna garis pembatas / border kartu (Neutral Border - Slate 200).
  static const Color borderColor = Color(0xFFE2E8F0);

  /// Warna placeholder gambar saat kosong atau gagal memuat (Slate 300).
  static const Color placeholderColor = Color(0xFFCBD5E1);

  /// Warna untuk state error / peringatan (Merah).
  static const Color errorColor = Color(0xFFDC2626);

  /// Warna untuk status sukses / konfirmasi (Hijau).
  static const Color successColor = Color(0xFF16A34A);

  /// Warna penanda bookmark / favorit aktif (Merah Rose).
  static const Color favoriteColor = Color(0xFFEF4444);

  // ===========================================================================
  // JARAK & SPACING (Kelipatan 8)
  // ===========================================================================

  /// Jarak terkecil: 8 piksel.
  static const double spacing8 = 8.0;

  /// Jarak sedang: 16 piksel (kelipatan 8).
  static const double spacing16 = 16.0;

  /// Jarak besar: 24 piksel (kelipatan 8).
  static const double spacing24 = 24.0;

  /// Jarak ekstra besar: 32 piksel (kelipatan 8).
  static const double spacing32 = 32.0;

  /// Jarak 40 piksel (kelipatan 8).
  static const double spacing40 = 40.0;

  /// Jarak 48 piksel (kelipatan 8).
  static const double spacing48 = 48.0;

  /// Tinggi standar gambar pada kartu artikel (192 piksel, kelipatan 8).
  static const double cardImageHeight = 192.0;

  /// Tinggi standar gambar pada halaman detail artikel (240 piksel, kelipatan 8).
  static const double detailImageHeight = 240.0;

  // Helper Padding konsisten
  static const EdgeInsets padding8 = EdgeInsets.all(spacing8);
  static const EdgeInsets padding16 = EdgeInsets.all(spacing16);
  static const EdgeInsets padding24 = EdgeInsets.all(spacing24);
  static const EdgeInsets paddingHorizontal16 = EdgeInsets.symmetric(horizontal: spacing16);
  static const EdgeInsets paddingVertical8 = EdgeInsets.symmetric(vertical: spacing8);

  // Helper Radius kelipatan 8
  static const double radius8 = 8.0;
  static const double radius16 = 16.0;
  static const BorderRadius borderRadius8 = BorderRadius.all(Radius.circular(radius8));
  static const BorderRadius borderRadius16 = BorderRadius.all(Radius.circular(radius16));

  // ===========================================================================
  // TIPOGRAFI (Dua tingkat saja: Judul dan Isi)
  // ===========================================================================

  /// Ukuran font judul artikel dan judul layar.
  static const double titleFontSize = 18.0;
  static const FontWeight titleFontWeight = FontWeight.w700;

  /// Ukuran font isi berita, deskripsi, dan metadata.
  static const double bodyFontSize = 14.0;
  static const FontWeight bodyFontWeight = FontWeight.w400;

  /// Gaya teks tingkat 1: Judul (Warna teks utama gelap, bobot tebal).
  static const TextStyle titleStyle = TextStyle(
    fontSize: titleFontSize,
    fontWeight: titleFontWeight,
    color: textPrimaryColor,
    height: 1.3,
  );

  /// Gaya teks tingkat 2: Isi berita / deskripsi (Warna sekunder abu-abu, bobot normal).
  static const TextStyle bodyStyle = TextStyle(
    fontSize: bodyFontSize,
    fontWeight: bodyFontWeight,
    color: textSecondaryColor,
    height: 1.5,
  );

  /// Varian gaya teks isi dengan warna kontras utama (misal: penulis artikel atau nama sumber).
  static const TextStyle bodyPrimaryStyle = TextStyle(
    fontSize: bodyFontSize,
    fontWeight: bodyFontWeight,
    color: textPrimaryColor,
    height: 1.5,
  );

  // ===========================================================================
  // TEMA MATERIAL 3
  // ===========================================================================

  /// Konfigurasi [ThemeData] utama berbasis Material 3.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: titleStyle,
      ),
      cardTheme: const CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius16,
          side: BorderSide(color: borderColor),
        ),
        margin: EdgeInsets.zero,
      ),
      textTheme: const TextTheme(
        titleLarge: titleStyle,
        titleMedium: titleStyle,
        titleSmall: titleStyle,
        bodyLarge: bodyPrimaryStyle,
        bodyMedium: bodyStyle,
        bodySmall: bodyStyle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: borderRadius8),
          padding: const EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing8),
          textStyle: bodyPrimaryStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: const RoundedRectangleBorder(borderRadius: borderRadius8),
          padding: const EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing8),
          textStyle: bodyPrimaryStyle.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: spacing16,
      ),
    );
  }
}
