# Aplikasi Catatan Pengeluaran - Flutter

## Status Pengembangan
✅ Aplikasi sudah selesai dikembangkan dengan lengkap
⚠️ Build APK memerlukan server dengan RAM lebih besar (minimal 8GB)

## Fitur yang Sudah Dibuat

### ✅ Fitur Lengkap:
1. **Catat Pengeluaran** - Tambah, edit, hapus pengeluaran dengan jumlah, kategori, tanggal, dan catatan
2. **Kategori Pengeluaran** - 8 kategori default (Makanan, Transport, Belanja, Tagihan, Hiburan, Kesehatan, Pendidikan, Lainnya)
3. **Database Lokal (SQLite)** - Data tersimpan offline di device
4. **Laporan & Statistik** - Pie chart dan breakdown per kategori
5. **Filter per Bulan** - Navigasi bulan dengan total pengeluaran

## Struktur Aplikasi

```
lib/
├── main.dart                          # Entry point aplikasi
├── models/
│   ├── kategori.dart                  # Model data kategori
│   └── pengeluaran.dart               # Model data pengeluaran
├── database/
│   └── database_helper.dart           # SQLite helper dengan CRUD
├── providers/
│   └── pengeluaran_provider.dart      # State management (Provider)
├── screens/
│   ├── home_screen.dart               # Halaman utama (daftar pengeluaran)
│   ├── tambah_pengeluaran_screen.dart # Form tambah/edit pengeluaran
│   └── laporan_screen.dart            # Halaman laporan & statistik
└── widgets/                           # (kosong, bisa ditambahkan nanti)
```

## Teknologi yang Digunakan

- **Framework:** Flutter 3.44.4
- **Language:** Dart
- **Database:** SQLite (sqflite ^2.3.0)
- **State Management:** Provider ^6.1.1
- **Charts:** fl_chart ^0.66.0
- **Date Formatting:** intl ^0.19.0

## Cara Build APK

### Opsi 1: Build di Server dengan RAM Cukup (Recommended)
```bash
cd /root/catatan_pengeluaran
flutter clean
flutter pub get
flutter build apk --release
```

APK akan tersimpan di: `build/app/outputs/flutter-apk/app-release.apk`

### Opsi 2: Build dengan Split Per ABI (File lebih kecil)
```bash
flutter build apk --release --split-per-abi
```

Akan menghasilkan 3 file APK:
- `app-armeabi-v7a-release.apk` (untuk device 32-bit)
- `app-arm64-v8a-release.apk` (untuk device 64-bit modern)
- `app-x86_64-release.apk` (untuk emulator)

### Opsi 3: Build Debug APK (Lebih cepat, file lebih besar)
```bash
flutter build apk --debug
```

## Catatan Penting

### Masalah Memory pada Build
Server saat ini memiliki RAM terbatas (~4GB) yang menyebabkan:
- Gradle daemon crash (Out of Memory)
- Flutter build process terminated (exit code 137)
- R8 compiler metaspace error

**Solusi:**
- Build di komputer lokal dengan RAM minimal 8GB
- Atau gunakan CI/CD service seperti GitHub Actions, Codemagic, atau AppCenter

## Cara Menjalankan di Komputer Lokal

1. **Install Flutter:**
   - Download dari https://flutter.dev
   - Tambahkan ke PATH

2. **Install Android Studio & SDK:**
   - Download dari https://developer.android.com/studio
   - Install Android SDK dan Build Tools

3. **Clone/Copy Project:**
   ```bash
   # Copy folder catatan_pengeluaran ke komputer lokal
   ```

4. **Install Dependencies:**
   ```bash
   cd catatan_pengeluaran
   flutter pub get
   ```

5. **Build APK:**
   ```bash
   flutter build apk --release
   ```

## Testing di Emulator/Device

```bash
# Jalankan di device yang terhubung
flutter run

# Atau build dan install debug APK
flutter build apk --debug
adb install build/app/outputs/flutter-apk/app-debug.apk
```

## Screenshot Fitur

### 1. Home Screen
- Daftar pengeluaran dengan icon kategori
- Total pengeluaran per bulan
- Navigasi bulan (prev/next)
- Floating button untuk tambah data

### 2. Form Tambah/Edit
- Input jumlah (Rupiah)
- Grid selector kategori dengan icon & warna
- Date picker dan time picker
- Field catatan (opsional)

### 3. Laporan & Statistik
- Pie chart distribusi per kategori
- Progress bar dengan persentase
- Total pengeluaran dan jumlah transaksi
- Breakdown detail per kategori

## Kategori Default

| Icon | Nama | Warna |
|------|------|-------|
| 🍔 | Makanan & Minuman | Orange (FF5722) |
| 🚗 | Transport | Blue (2196F3) |
| 🛒 | Belanja | Purple (9C27B0) |
| 💰 | Tagihan | Red (F44336) |
| 🎮 | Hiburan | Green (4CAF50) |
| ⚕️ | Kesehatan | Pink (E91E63) |
| 📚 | Pendidikan | Indigo (3F51B5) |
| 📦 | Lainnya | Grey (607D8B) |

## Database Schema

### Tabel: kategori
```sql
CREATE TABLE kategori (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nama TEXT NOT NULL,
  icon TEXT NOT NULL,
  warna TEXT NOT NULL
)
```

### Tabel: pengeluaran
```sql
CREATE TABLE pengeluaran (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  jumlah REAL NOT NULL,
  kategori_id INTEGER NOT NULL,
  catatan TEXT,
  tanggal TEXT NOT NULL,
  FOREIGN KEY (kategori_id) REFERENCES kategori (id)
)
```

## Pengembangan Selanjutnya (Opsional)

- [ ] Export data ke Excel/PDF
- [ ] Backup & restore database
- [ ] Notifikasi pengingat
- [ ] Budget limit per kategori
- [ ] Dark mode
- [ ] Multi-user/sync cloud
- [ ] Widget home screen
- [ ] Biometric authentication

## Lokasi File

- **Source Code:** `/root/catatan_pengeluaran/`
- **Dokumentasi:** `/root/catatan_pengeluaran/APLIKASI_SIAP.md`

## Kontak Support

Jika ada kendala dalam build APK, silakan:
1. Gunakan komputer dengan RAM minimal 8GB
2. Atau kirim folder project ke developer lain untuk di-build
3. Atau gunakan online build service

---

**Status:** ✅ Kode aplikasi 100% selesai dan siap di-build
**Tanggal:** 1 Juli 2026
**Versi:** 1.0.0
