# Dokumentasi Proyek Renjana

Dokumen ini menjelaskan aplikasi **Renjana** secara menyeluruh: struktur folder, isi tiap file, hubungan antar file, operasi CRUD, pemakaian class, sampai fungsi-fungsi kecil seperti `context.pop()` dan apa yang terjadi saat sebuah tombol ditekan.

---

## Daftar Isi

1. [Ringkasan Proyek](#1-ringkasan-proyek)
2. [Arsitektur & Aturan Lapisan](#2-arsitektur--aturan-lapisan)
3. [Peta Folder dan File](#3-peta-folder-dan-file)
4. [Alur Hidup Aplikasi](#4-alur-hidup-aplikasi)
5. [Lapisan Core](#5-lapisan-core)
6. [Lapisan Data](#6-lapisan-data)
7. [Lapisan Services](#7-lapisan-services)
8. [Lapisan Presentation](#8-lapisan-presentation)
9. [Ringkasan Operasi CRUD](#9-ringkasan-operasi-crud)
10. [Logika Kunci Dijelaskan Mendalam](#10-logika-kunci-dijelaskan-mendalam)
11. [Kamus Fungsi & Idiom](#11-kamus-fungsi--idiom)
12. [Contoh Alur Data End-to-End](#12-contoh-alur-data-end-to-end)
13. [Keterbatasan yang Diketahui](#13-keterbatasan-yang-diketahui)

---

## 1. Ringkasan Proyek

**Renjana** — "Museum Indonesia Dalam Genggaman" — aplikasi Flutter edukasi sejarah dan budaya Indonesia.

| Aspek | Keterangan |
|---|---|
| Framework | Flutter (Material 3), Dart |
| Database | SQLite lokal lewat `sqflite` |
| Penyimpanan sesi | `shared_preferences` |
| State management | `setState` bawaan Flutter (tanpa Provider/Bloc/Riverpod) |
| Navigasi | Imperatif (`Navigator.push`) lewat extension, **bukan** named routes |
| Backend | Tidak ada. Sepenuhnya offline |

**Dependensi dan alasannya:**

| Paket | Dipakai untuk |
|---|---|
| `sqflite` | Database SQLite |
| `path` | `join()` untuk merangkai path file database |
| `shared_preferences` | Menyimpan status login & data user |
| `google_fonts` | Font DM Serif Display, Playfair Display, Plus Jakarta Sans |
| `intl` | Format tanggal berbahasa Indonesia (`EEEE, dd MMMM yyyy`) |
| `lottie` | Animasi ikon bottom navigation & splash |
| `image_picker` | Admin memilih gambar dari galeri |
| `permission_handler` | Meminta izin akses galeri |

Fitur utama: sorotan sejarah & budaya harian, katalog budaya 8 kategori, destinasi wisata, kuis interaktif dengan pembahasan, bookmark per akun, dan panel admin CRUD.

---

## 2. Arsitektur & Aturan Lapisan

Proyek memakai pemisahan tiga lapisan:

```
┌─────────────────────────────────────────────┐
│  PRESENTATION  (halaman & widget)           │  ← yang dilihat user
│  home/, detail/, quiz/, admin/, ...         │
└───────────────────┬─────────────────────────┘
                    │ memanggil
┌───────────────────▼─────────────────────────┐
│  DATA — REPOSITORIES                        │  ← satu-satunya pintu ke database
│  BudayaRepository, QuizRepository, ...      │
└───────────────────┬─────────────────────────┘
                    │ memakai
┌───────────────────▼─────────────────────────┐
│  DATA — LOCAL (DbHelper) + MODELS           │  ← SQLite & bentuk data
└─────────────────────────────────────────────┘

CORE      = bahan pakai bersama (warna, font, widget umum, extension)
SERVICES  = PreferenceHandler (SharedPreferences)
```

**Aturan yang dipegang:**

1. Halaman **tidak pernah** memanggil `sqflite` langsung. Semua lewat repository.
2. Halaman **tidak** meng-import data seed (`data/local/seed/`). Data seed hanya urusan database.
3. Model tidak tahu apa-apa soal UI; ia hanya bentuk data + konversi Map.
4. `core/` tidak boleh bergantung pada `presentation/`, supaya bisa dipakai halaman mana pun.

Arah ketergantungan selalu **satu arah ke bawah**: Presentation → Repository → DbHelper/Model. Ini yang membuat, misalnya, mengganti SQLite dengan Firebase nanti cukup mengubah isi repository tanpa menyentuh satu pun halaman.

---

## 3. Peta Folder dan File

### 3.1 Tingkat akar proyek

```
RenjanaApp/
├── android/             Proyek native Android (manifest, Gradle, ikon launcher)
├── assets/              Berkas statis yang ikut dibundel ke dalam aplikasi
│   ├── animations/      6 file Lottie (.json) — ikon navigasi & loading splash
│   ├── icons/           Rlogos.png — sumber ikon launcher
│   └── images/          10 gambar — foto konten & latar onboarding
├── build/               Hasil kompilasi. Dibuat otomatis, tidak perlu disentuh
├── lib/                 Seluruh kode Dart aplikasi (dijelaskan di bawah)
├── analysis_options.yaml  Aturan linter (gaya penulisan kode)
├── pubspec.yaml         Daftar dependensi, aset, dan versi aplikasi
├── pubspec.lock         Versi persis tiap paket. Dibuat otomatis
├── README.md            Catatan singkat proyek
└── DOKUMENTASI.md       Dokumen ini
```

> Proyek ini hanya menargetkan Android, jadi tidak ada folder `ios/`, `web/`, maupun `windows/`.

| Folder/file | Penjelasan singkat |
|---|---|
| `android/` | Bagian native. Diubah hanya saat mengurus izin, nama aplikasi, atau ikon |
| `assets/` | Semua isinya harus didaftarkan di `pubspec.yaml` agar bisa dipakai |
| `build/` | Keluaran build. Aman dihapus; akan dibuat ulang saat build berikutnya |
| `lib/` | Tempat semua pekerjaan pemrograman berlangsung |
| `pubspec.yaml` | Satu-satunya tempat menambah paket baru dan mendaftarkan folder aset |

### 3.2 Struktur `lib/`

```
lib/
├── main.dart                    Titik masuk aplikasi
│
├── core/                        Bahan pakai bersama, tidak terikat satu fitur
│   ├── constants/               Nilai tetap: warna, gaya teks, tema, katalog kategori
│   ├── extensions/              Tambahan method untuk class bawaan Flutter
│   └── widgets/                 Komponen UI yang dipakai berulang di banyak halaman
│
├── data/                        Segala hal tentang data
│   ├── local/                   Database SQLite
│   │   ├── db_helper.dart       Pembuat, pembuka, dan pemigrasi database
│   │   └── seed/                Data awal pengisi database saat pertama dibuat
│   ├── models/                  Bentuk data + konversi ke/dari Map & JSON
│   └── repositories/            Satu-satunya pintu operasi CRUD ke database
│
├── services/                    Layanan lintas fitur non-database
│   └── preference_handler.dart  Pembungkus SharedPreferences (sesi login)
│
└── presentation/                Semua yang terlihat pengguna, dipisah per fitur
    ├── splash/                  Layar pembuka
    ├── onboarding/              Tiga slide perkenalan
    ├── auth/                    Login & registrasi
    ├── main/                    Kerangka utama + bottom navigation
    ├── home/                    Beranda
    │   └── widgets/             Bagian-bagian penyusun beranda
    ├── koleksi/                 Daftar budaya per kategori
    ├── detail/                  Halaman detail sejarah & budaya
    │   └── widgets/             Komponen khusus halaman detail
    ├── bookmark/                Koleksi tersimpan
    ├── quiz/                    Menu kuis, layar mengerjakan, dan hasil
    ├── profile/                 Tab profil
    └── admin/                   Panel pengelolaan konten & kuis
        └── widgets/             Komponen khusus panel admin
```

### 3.3 Peran tiap folder

| Folder | Perannya | Aturan yang dipegang |
|---|---|---|
| **`core/`** | Berisi hal-hal yang dipakai di mana-mana dan tidak dimiliki oleh satu fitur pun. Kalau sebuah komponen hanya dipakai satu halaman, tempatnya bukan di sini | Tidak boleh meng-import apa pun dari `presentation/` atau `data/repositories/` |
| `core/constants/` | Sumber kebenaran nilai tetap: `AppColors` (warna), `AppTypography` (gaya teks), `AppTheme` (tema global), `budaya_kategori` (katalog 8 kategori). Bila sebuah warna atau ukuran font muncul lebih dari sekali, tempatnya di sini | Tidak ada warna atau gaya teks yang ditulis langsung di halaman |
| `core/extensions/` | Menambah kemampuan pada class bawaan Flutter tanpa mewarisinya. Saat ini hanya `navigation.dart` yang memendekkan pemanggilan `Navigator` | — |
| `core/widgets/` | Komponen UI yang muncul di beberapa halaman: tombol, input, penampil gambar, app bar, header seksi | Tidak boleh memanggil repository; data selalu dioper dari halaman |
| **`data/`** | Semua urusan data: dari mana asalnya, bentuknya apa, dan cara mengambilnya | Tidak tahu apa pun tentang tampilan |
| `data/local/` | Sumber data lokal. `db_helper.dart` memegang skema tabel, versi database, dan migrasi | Hanya repository yang boleh memakainya |
| `data/local/seed/` | Data awal (contoh budaya, sejarah, dan bank soal) yang diisikan sekali saat database pertama kali dibuat, sekaligus jadi cadangan bila tabel kosong | Isinya **hanya konstanta data**, tanpa fungsi. Tidak boleh di-import halaman |
| `data/models/` | Kelas yang mewakili satu baris tabel, lengkap dengan `toMap`/`fromMap` karena SQLite hanya mengenal tipe sederhana | Tidak boleh meng-import Flutter UI |
| `data/repositories/` | Lapisan yang menerjemahkan kebutuhan halaman menjadi perintah SQL. Setiap tabel punya satu repository | Satu-satunya tempat `sqflite` dipanggil |
| **`services/`** | Layanan lintas fitur yang bukan database. Saat ini hanya penyimpanan sesi login | — |
| **`presentation/`** | Seluruh tampilan, dipecah **per fitur** (bukan per jenis widget), sehingga semua berkas satu layar berdekatan | Tidak boleh memanggil `sqflite` atau meng-import `data/local/seed/` |
| `presentation/<fitur>/widgets/` | Potongan UI yang hanya dipakai fitur itu. Bila kelak dipakai fitur lain, barulah dipindahkan ke `core/widgets/` | — |

**Kenapa `presentation/` dipisah per fitur, bukan per jenis?**
Alternatifnya adalah mengelompokkan semua halaman di `pages/` dan semua widget di `widgets/`. Cara itu membuat berkas satu layar tersebar jauh. Dengan pembagian per fitur, mengerjakan beranda cukup membuka satu folder `home/`, dan menghapus sebuah fitur cukup menghapus satu folder.

**Kenapa `core/` dan `data/` dipisah dari `presentation/`?**
Karena arah ketergantungannya satu arah: tampilan boleh bergantung pada data, tetapi data tidak boleh bergantung pada tampilan. Itulah yang membuat repository bisa diganti (misalnya SQLite → Firebase) tanpa menyentuh satu pun halaman.

### 3.4 Isi `lib/` per file

| File | Perannya |
|---|---|
| **main.dart** | Titik masuk aplikasi. Inisialisasi & `runApp` |
| **core/constants/app_colors.dart** | Semua warna aplikasi sebagai konstanta |
| **core/constants/app_typography.dart** | Semua gaya teks (ukuran, tebal, font) |
| **core/constants/app_theme.dart** | `ThemeData` global untuk `MaterialApp` |
| **core/constants/budaya_kategori.dart** | Katalog 8 kategori budaya + pembuat ID tag |
| **core/extensions/navigation.dart** | Pemendek `Navigator`: `context.push()`, `context.pop()` |
| **core/widgets/app_button.dart** | Tombol standar (primary & outlined) |
| **core/widgets/app_text_field.dart** | Input teks standar berlabel |
| **core/widgets/app_image.dart** | Penampil gambar cerdas (aset / file / placeholder) |
| **core/widgets/custom_app_bar.dart** | AppBar berlogo RENJANA |
| **core/widgets/detail_section_block.dart** | Blok "Judul + garis + paragraf" di halaman detail |
| **core/widgets/detail_top_bar.dart** | Tombol melayang di detail: back, home, bookmark, share |
| **core/widgets/section_header.dart** | `SectionHeader` & `SectionBadgeTitle` untuk judul seksi |
| **data/local/db_helper.dart** | Membuat, membuka, memigrasi, dan mengisi database |
| **data/local/seed/budaya_seed.dart** | Data awal budaya (6 item) |
| **data/local/seed/sejarah_seed.dart** | Data awal sejarah |
| **data/local/seed/quiz_seed.dart** | Bank soal awal |
| **data/models/user_model.dart** | `UserSQLModel` + daftar akun admin |
| **data/models/sejarah_model.dart** | `SejarahModel` & `TimelineItemModel` |
| **data/models/budaya_model.dart** | `BudayaModel` |
| **data/models/quiz_model.dart** | `QuizSQLModel` |
| **data/models/bookmark_model.dart** | `BookmarkItemModel` (gabungan bookmark + isinya) |
| **data/repositories/user_repository.dart** | Register & login |
| **data/repositories/sejarah_repository.dart** | CRUD sejarah |
| **data/repositories/budaya_repository.dart** | CRUD budaya + kategori + destinasi |
| **data/repositories/quiz_repository.dart** | CRUD kuis & tema |
| **data/repositories/bookmark_repository.dart** | CRUD bookmark per user |
| **services/preference_handler.dart** | Simpan/baca sesi login di SharedPreferences |
| **presentation/splash/splash_page.dart** | Layar pembuka 3 detik + penentu tujuan |
| **presentation/onboarding/onboarding_page.dart** | 3 slide perkenalan |
| **presentation/auth/login_page.dart** | Form login |
| **presentation/auth/register_page.dart** | Form daftar akun |
| **presentation/main/main_page.dart** | Kerangka utama + bottom navigation 5 tab |
| **presentation/home/home_page.dart** | Beranda (sorotan harian & daftar) |
| **presentation/home/widgets/** | 5 widget penyusun beranda |
| **presentation/koleksi/koleksi_kategori_page.dart** | Daftar budaya dalam satu kategori |
| **presentation/detail/detail_sejarah_page.dart** | Detail sejarah + timeline |
| **presentation/detail/detail_budaya_page.dart** | Detail budaya |
| **presentation/detail/widgets/timeline_item_widget.dart** | Satu titik pada timeline |
| **presentation/bookmark/bookmark_page.dart** | Koleksi tersimpan + pencarian |
| **presentation/quiz/quiz_page.dart** | Menu kuis (kategori & rekomendasi tema) |
| **presentation/quiz/quiz_play_page.dart** | Layar mengerjakan soal |
| **presentation/quiz/quiz_result_page.dart** | Skor & pembahasan |
| **presentation/profile/profile_page.dart** | Tab Profil (tombol logout) |
| **presentation/admin/manage_content_page.dart** | CRUD sejarah & budaya |
| **presentation/admin/manage_quiz_page.dart** | CRUD tema kuis |
| **presentation/admin/admin_quiz_theme_detail_page.dart** | CRUD soal dalam satu tema |
| **presentation/admin/widgets/admin_drawer.dart** | Menu samping khusus admin |
| **presentation/admin/widgets/app_image_picker_widget.dart** | Pemilih gambar (aset/galeri/path) |

---

## 4. Alur Hidup Aplikasi

### 4.1 `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await PreferenceHandler.init();

  runApp(const RenjanaApp());
}
```

Baris per baris:

- **`WidgetsFlutterBinding.ensureInitialized()`** — menyalakan "jembatan" antara kode Dart dan kode native Android. Wajib dipanggil bila sebelum `runApp` kita ingin memakai plugin (di sini: SharedPreferences). Tanpa ini aplikasi crash dengan pesan *"Binding has not yet been initialized"*.
- **`await initializeDateFormatting('id_ID', null)`** — memuat data lokal bahasa Indonesia untuk paket `intl`. Inilah yang membuat `DateFormat('EEEE, dd MMMM yyyy', 'id_ID')` di beranda menghasilkan "Rabu, 20 Agustus 2026" dan bukan "Wednesday, 20 August 2026".
- **`await PreferenceHandler.init()`** — membuka SharedPreferences sekali di awal, supaya seluruh aplikasi bisa membacanya secara *sinkron* (tanpa `await`) setelahnya.
- **`runApp(...)`** — memasang widget root ke layar.

`RenjanaApp` adalah `StatelessWidget` yang mengembalikan `MaterialApp`:

```dart
MaterialApp(
  title: 'Renjana',
  debugShowCheckedModeBanner: false,   // menyembunyikan pita "DEBUG" merah
  theme: AppTheme.lightTheme,          // tema global dari core/constants
  home: const SplashPage(),            // halaman pertama
)
```

### 4.2 Rantai navigasi awal

```
SplashPage (3 detik)
   │
   ├─ sudah login  ──────────────► MainPage
   └─ belum login  ──► OnboardingPage ──► LoginPage ──► MainPage
                                             │
                                             └─► RegisterPage ──► kembali ke LoginPage
```

`SplashPage.initState()` memanggil `_checkLoginAndNavigate()`:

```dart
Future<void> _checkLoginAndNavigate() async {
  await Future.delayed(const Duration(seconds: 3));
  if (!mounted) return;
  if (PreferenceHandler.isLogin) {
    context.pushAndRemoveAll(MainPage(currentUser: ..., isAdmin: ...));
  } else {
    context.pushAndRemoveAll(const OnboardingPage());
  }
}
```

- **`Future.delayed`** menunda 3 detik supaya logo & animasi sempat terlihat.
- **`if (!mounted) return;`** — pengaman penting. Selama 3 detik itu user bisa saja menutup layar. `mounted` bernilai `false` bila widget sudah dilepas dari layar; memakai `context` setelah itu menyebabkan error. Pola ini dipakai di **seluruh** proyek setiap kali ada `await` sebelum menyentuh `context` atau `setState`.
- **`context.pushAndRemoveAll`** — pindah halaman sambil **menghapus semua halaman sebelumnya** dari tumpukan. Dipakai di sini supaya tombol "back" dari MainPage tidak kembali ke splash.

---

## 5. Lapisan Core

### 5.1 `app_colors.dart`

Kelas berisi konstanta warna. Perhatikan konstruktor privatnya:

```dart
class AppColors {
  AppColors._();   // konstruktor privat: mencegah `AppColors()` dibuat
  static const Color primary = Color(0xFFC9362B);
  ...
}
```

`AppColors._()` membuat kelas ini murni sebagai wadah konstanta — tidak ada gunanya membuat objeknya. Pola yang sama dipakai `AppTypography._()` dan `AppTheme._()`.

Format `Color(0xFFC9362B)` = `0x` (heksadesimal) + `FF` (alpha/opasitas penuh) + `C9362B` (RGB merah bata). Kalau alpha-nya `0x80` berarti 50% transparan — itulah `textMuted` dan `backgroundSoft`.

| Kelompok | Token |
|---|---|
| Utama | `primary`, `primaryDark` |
| Latar | `background`, `backgroundSoft`, `backgroundTransparent`, `surface`, `surfaceMuted` |
| Teks | `textPrimary`, `textSecondary`, `textDeep`, `textMuted` |
| Garis | `border`, `borderPrimary`, `borderLight`, `scrollTrack` |
| Status | `success`, `error`, `warning`, `gold` |
| Aksen | `accentBudaya` (cokelat untuk badge budaya) |

### 5.2 `app_typography.dart`

Kumpulan *method* yang mengembalikan `TextStyle`. Ditulis sebagai method (bukan konstanta) supaya warnanya bisa diganti saat dipanggil:

```dart
static TextStyle headingLarge({Color color = AppColors.textPrimary}) =>
    GoogleFonts.dmSerifDisplay(fontSize: 42, fontWeight: FontWeight.bold, color: color);
```

Pemakaian: `AppTypography.headingLarge()` untuk warna bawaan, atau `AppTypography.headingLarge(color: Colors.white)` di atas gambar gelap.

Tiga keluarga font dengan pembagian tugas:

- **DM Serif Display** — judul besar & merek (`headingLarge`, `headingMedium`, `headingSmall`, `brandTitle`)
- **Playfair Display** — judul seksi bergaya editorial (`editorialHeading`, `editorialSubheading`)
- **Plus Jakarta Sans** — teks isi & UI (`bodyLarge`, `bodyMedium`, `bodySmall`, `buttonText`, `labelBold`, `tag`)

`.copyWith(...)` sering dipakai untuk menimpa satu properti saja, misalnya `AppTypography.headingLarge().copyWith(fontSize: 90)` untuk watermark angka di beranda.

### 5.3 `app_theme.dart`

Mengembalikan `ThemeData` yang dipasang di `MaterialApp`. Isinya menetapkan default global: warna latar Scaffold, `colorScheme` dari `seedColor`, font bawaan (`GoogleFonts.plusJakartaSansTextTheme()`), gaya AppBar, dan gaya Divider. Karena ini tema global, `Divider()` polos di beranda otomatis berwarna merah primary tanpa perlu diatur.

### 5.4 `budaya_kategori.dart`

Katalog kategori — satu-satunya sumber kebenaran, dipakai oleh data seed, form admin, dan beranda.

```dart
class BudayaKategori {
  final String kode;   // 'RMH'
  final String nama;   // 'Rumah Adat'
  String get label => nama.toUpperCase();   // 'RUMAH ADAT'
}
```

Delapan kategori: `RMH` Rumah Adat, `TRN` Tarian Tradisional, `PKN` Pakaian Adat, `UPC` Upacara dan Tradisi Adat, `MSK` Alat Musik dan Lagu Daerah, `SNJT` Senjata Tradisional, `SRK` Seni Rupa dan Kriya, `BHS` Bahasa dan Sastra Daerah.

Fungsi pendukung:

| Fungsi | Kegunaan |
|---|---|
| `kategoriByKode('RMH')` | Cari objek kategori dari kodenya, `null` bila tak dikenal |
| `namaKategori('RMH')` | Ambil nama tampilan; kembalikan kodenya sendiri bila tak dikenal (aman untuk data lama) |
| `buatKodeTagBudaya(...)` | Merangkai ID tag: `BUD-RMH-1` atau `BUD-RMH-1-D` |
| `kodeDestinasiSuffix` | Konstanta `'-D'` penanda destinasi wisata |

```dart
String buatKodeTagBudaya({required String jenis, required int urutan, bool isDestinasi = false}) {
  final base = 'BUD-${jenis.trim().toUpperCase()}-$urutan';
  return isDestinasi ? '$base$kodeDestinasiSuffix' : base;
}
```

`.trim()` membuang spasi di ujung, `.toUpperCase()` menyeragamkan huruf besar — jadi input `" rmh "` tetap menghasilkan `BUD-RMH-1`.

### 5.5 `navigation.dart` — extension untuk Navigator

Ini **extension method**: menempelkan method baru ke class `BuildContext` yang bukan milik kita.

```dart
extension ExtendedNavigator on BuildContext {
  Future<dynamic> push(Widget page, {String? name}) async { ... }
}
```

Setelah file ini di-import, setiap `BuildContext` punya `.push()`, sehingga `Navigator.push(context, MaterialPageRoute(builder: (_) => HalamanX()))` yang panjang cukup ditulis `context.push(HalamanX())`.

**Konsep tumpukan (stack) navigasi.** Flutter menumpuk halaman seperti tumpukan kartu. Halaman teratas yang terlihat.

| Method | Yang terjadi pada tumpukan | Dipakai di mana |
|---|---|---|
| `context.push(page)` | Menambah halaman baru **di atas** | Beranda → Detail, Detail → Detail lain |
| `context.pushReplacement(page)` | Mengganti halaman teratas | Onboarding → Login, Kuis → Hasil |
| `context.pushAndRemoveAll(page)` | Membuang **semua** halaman, sisakan yang baru | Splash → Main, Login → Main, Logout → Login |
| `context.pop()` | Membuang halaman teratas (kembali) | Tombol back mana pun |

**`context.pop()` secara rinci:**

```dart
void pop<T extends Object?>([T? result]) {
  Navigator.of(this).pop(result);
}
```

- `Navigator.of(this)` mencari Navigator terdekat di atas widget ini pada widget tree.
- `pop(result)` melepas halaman teratas. Parameter `result` opsional: nilai yang dikirim balik ke halaman pemanggil. Karena `context.push()` mengembalikan `Future`, halaman pemanggil bisa menunggu hasilnya:

  ```dart
  await context.push(DetailBudayaPage(budaya: item));
  await _loadItems();   // dijalankan setelah user menekan back dari detail
  ```

  Pola "await push lalu reload" ini dipakai di `PilihanDestinasiList`, `KoleksiBudayaList`, dan `BookmarkPage` supaya data ikut segar setelah user kembali.
- Tanda `<T extends Object?>` adalah *generic*: tipe hasilnya bebas.

Perhatikan: di beberapa tempat dipakai `Navigator.pop(ctx)` langsung, bukan `context.pop()`. Itu terjadi pada dialog dan bottom sheet, karena yang perlu ditutup adalah dialognya — `ctx` di sana adalah context milik dialog, bukan halaman.

### 5.6 `core/widgets/`

#### `AppButton`

Tombol dengan dua varian lewat `enum AppButtonType { primary, outlined }`.

```dart
AppButton(text: 'Login', onPressed: _isLoading ? null : _login)
AppButton.outlined(text: 'Kembali', onPressed: _previous)
```

- `AppButton.outlined` adalah **named constructor** yang menetapkan `type = AppButtonType.outlined` lewat *initializer list* (`: type = ...`).
- `onPressed` bertipe `VoidCallback?` (fungsi tanpa parameter & tanpa nilai balik, boleh null). **Memberi `null` membuat tombol otomatis nonaktif dan berwarna abu-abu** — inilah cara halaman login mencegah klik ganda saat proses berjalan.
- Lebar selalu `double.infinity` (memenuhi lebar induk), tinggi tetap 52.

#### `AppTextField`

Membungkus `TextFormField` plus label di atasnya.

- `controller` — `TextEditingController` untuk membaca/menulis isi input.
- `validator` — fungsi yang mengembalikan `String` (pesan error) atau `null` (valid). Dipanggil saat `_formKey.currentState!.validate()` dijalankan.
- `obscureText` — untuk password (menampilkan titik-titik).
- `onChanged` — dipanggil setiap ketikan; dipakai di halaman register untuk indikator kekuatan password secara langsung.
- `suffixIcon` — biasanya `IconButton` mata untuk memperlihatkan/menyembunyikan password.

#### `AppImageView`

Widget penting: sumber gambar di aplikasi ini bisa **aset bawaan** atau **file hasil pilihan admin dari galeri**. Logikanya:

```dart
if (imagePath kosong)               → placeholder abu-abu berikon
else if (path diawali 'assets/')    → Image.asset(path)
else if (File(path).existsSync())   → Image.file(File(path))
else                                → Image.asset('assets/images/1308history.png')
```

- `File(path).existsSync()` mengecek keberadaan file secara sinkron. Ini melindungi dari kasus admin memilih foto lalu foto itu dihapus dari galeri — aplikasi tidak crash, hanya menampilkan gambar cadangan.
- `errorBuilder` pada `Image` menangkap kegagalan dekode (file rusak) dan menampilkan placeholder.
- `borderRadius` opsional; bila diisi, hasilnya dibungkus `ClipRRect` untuk memotong sudut gambar.

#### `CustomAppBar`

```dart
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
```

Properti `appBar:` pada `Scaffold` hanya menerima widget yang mengimplementasikan `PreferredSizeWidget`, karena Scaffold perlu tahu tinggi AppBar **sebelum** menggambarnya. `kToolbarHeight` adalah konstanta Flutter (56 piksel).

#### `DetailTopBar`

Deretan tombol bulat melayang di atas gambar halaman detail. Isinya: kiri = **back** + **home**, kanan = **bookmark** + **share**.

```dart
onTap: onBack ?? () => context.pop(),
onTap: onHome ?? () => Navigator.of(context).popUntil((route) => route.isFirst),
```

- `??` adalah *null-coalescing*: "pakai `onBack` bila diisi, kalau tidak pakai perilaku bawaan". Ini membuat widget bisa dipakai ulang dengan perilaku khusus bila perlu.
- **`popUntil((route) => route.isFirst)`** — tombol home menutup halaman terus-menerus sampai tersisa halaman paling bawah (MainPage). Dipakai `popUntil`, bukan `pop`, karena dari detail user bisa membuka detail lain berkali-kali sehingga tumpukan bisa dalam. `route.isFirst` bernilai true untuk route paling bawah.
- `Material` + `InkWell` dipakai bersama supaya muncul efek riak (*ripple*) saat disentuh; `customBorder: CircleBorder()` membuat riaknya berbentuk lingkaran mengikuti tombol.

#### `SectionHeader` & `SectionBadgeTitle`

`SectionHeader` = judul + garis bawah pendek, bisa rata tengah (`isCenter`). `SectionBadgeTitle` = teks di atas kotak merah, dipakai untuk label "Sejarah Hari Ini" / "Budaya Hari Ini".

#### `DetailSectionBlock`

Blok "judul + garis + paragraf" yang berulang di halaman detail (Ringkasan, Deskripsi, Makna Spiritual, Konteks Budaya). Parameter `padding` bisa diatur supaya jarak antar-blok bisa dirapatkan.

---

## 6. Lapisan Data

### 6.1 `db_helper.dart` — jantung database

#### Pola Singleton

```dart
class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  static Database? _database;
```

- `DbHelper._internal()` — konstruktor privat, hanya bisa dipanggil dari dalam kelas.
- `static final _instance` — satu-satunya objek yang pernah dibuat, dibuat sekali saat pertama diakses.
- `factory DbHelper() => _instance` — **factory constructor**: berbeda dengan konstruktor biasa, ia tidak wajib membuat objek baru; di sini ia selalu mengembalikan objek yang sama.

Akibatnya, walaupun lima repository masing-masing menulis `DbHelper()`, semuanya menunjuk objek yang sama dan berbagi satu koneksi database. Tanpa ini, database bisa terbuka berkali-kali dan boros memori.

#### Membuka database secara malas (lazy)

```dart
Future<Database> get database async {
  if (_database != null) return _database!;
  _database = await _initDB();
  return _database!;
}
```

Database baru dibuka saat pertama kali dibutuhkan, lalu disimpan di `_database` supaya pembukaan berikutnya instan. Tanda `!` adalah *null assertion* — "saya jamin ini tidak null" — aman di sini karena barusan diperiksa.

#### `openDatabase` dan siklus versinya

```dart
return await openDatabase(
  path,
  version: _dbVersion,            // 7
  onCreate: (db, version) async {  // dijalankan HANYA saat file DB belum ada
    await _createTables(db);
    await _seedInitialData(db);
  },
  onUpgrade: (db, oldVersion, newVersion) async {  // saat versi naik
    await _createTables(db);
    await _migrateSchema(db);
    await _seedInitialData(db);
  },
);
```

- `getDatabasesPath()` memberi folder database milik aplikasi; `join(dbPath, 'renjana.db')` merangkainya jadi path lengkap dengan pemisah yang benar untuk platform tersebut.
- **`onCreate`** hanya jalan sekali seumur instalasi — saat pengguna baru pertama membuka aplikasi.
- **`onUpgrade`** jalan bila `version` di kode lebih besar daripada versi database yang tersimpan di perangkat. Inilah tempat migrasi.

> Catatan desain: dulu ada `onOpen` yang menjalankan pembuatan tabel setiap kali database dibuka. Itu dihapus karena memboroskan waktu di setiap start aplikasi; pembuatan tabel cukup di `onCreate`/`onUpgrade`.

#### Skema tabel

Semua SQL disimpan sebagai konstanta (`_userTableSql`, `_quizTableSql`, `_sejarahTableSql`, `_budayaTableSql`, `_bookmarkTableSql`) supaya bisa dipakai ulang oleh migrasi.

| Tabel | Kolom | Catatan |
|---|---|---|
| `user` | id, nama, **email UNIQUE**, noHp, password | `UNIQUE` membuat pendaftaran email ganda otomatis gagal |
| `quiz` | id, kategori, tema, **soal UNIQUE**, daftarJawaban, jawabanBenar, gambar, penjelasan | `daftarJawaban` disimpan sebagai teks JSON |
| `sejarah` | id, **kodeTag UNIQUE**, tanggalKey, urutan, judul, subtitle, ringkasan, gambarUtama, alurPeristiwa | `alurPeristiwa` = JSON daftar timeline |
| `budaya` | id, **kodeTag UNIQUE**, jenis, urutan, judul, kategoriLabel, tagline, deskripsi, gambarUtama, maknaSpiritual, gambarMaknaSpiritual, konteksBudaya, gambarKonteksBudaya | |
| `bookmark` | id, userEmail, itemType, kodeTag, createdAt, **UNIQUE(userEmail, kodeTag)** | Kunci ganda: satu user tidak bisa menyimpan item sama dua kali, tapi dua user boleh menyimpan item yang sama |

**Kenapa ada JSON di dalam kolom?** SQLite tidak punya tipe "daftar objek". Alur peristiwa sejarah adalah daftar `{date, title, desc, imgPath, hasImage}`. Dua pilihan: bikin tabel terpisah dengan relasi, atau simpan sebagai teks JSON dalam satu kolom. Proyek ini memilih JSON karena timeline selalu dibaca bersama induknya, tidak pernah dicari sendiri. Konversinya memakai `jsonEncode` saat menyimpan dan `jsonDecode` saat membaca.

#### Riwayat migrasi (`_migrateSchema`)

| Versi | Perubahan | Cara |
|---|---|---|
| v5 | Menambah kolom `penjelasan` pada `quiz` | `ALTER TABLE quiz ADD COLUMN` setelah cek `PRAGMA table_info` |
| v6 | `bookmark` jadi per user | Bangun ulang tabel: rename → buat baru → salin → hapus lama |
| v6 | Kategori budaya dibakukan | `UPDATE` baris lama sesuai peta `_budayaKategoriMigration`, plus perbarui `kodeTag` di bookmark |
| v6 | Tabel `content` dibuang | `DROP TABLE IF EXISTS content` |
| v7 | Kolom `relatedItems` dibuang dari `sejarah` & `budaya` | `_dropKolomRelatedItems()`: bangun ulang tabel |

**Kenapa membangun ulang tabel, bukan `DROP COLUMN`?** Perintah `ALTER TABLE ... DROP COLUMN` baru ada di SQLite 3.35 (2021). Banyak perangkat Android membawa SQLite lebih tua. Teknik "rename–create–copy–drop" berjalan di semua versi:

```dart
await db.transaction((txn) async {
  await txn.execute('ALTER TABLE $tabel RENAME TO ${tabel}_lama');
  await txn.execute(createSql);                       // tabel baru tanpa kolom itu
  await txn.execute('INSERT INTO $tabel (kolom...) SELECT kolom... FROM ${tabel}_lama');
  await txn.execute('DROP TABLE ${tabel}_lama');
});
```

`db.transaction` membungkus semuanya jadi satu kesatuan: bila salah satu langkah gagal, seluruhnya dibatalkan sehingga data tidak setengah jadi.

`PRAGMA table_info(namaTabel)` adalah perintah SQLite untuk melihat daftar kolom sebuah tabel. Dipakai untuk mengecek apakah migrasi sudah pernah dijalankan:

```dart
final info = await db.rawQuery('PRAGMA table_info($tabel)');
final punyaRelatedItems = info.any((col) => col['name'] == 'relatedItems');
if (!punyaRelatedItems) return;   // sudah bersih, tidak perlu apa-apa
```

Pengecekan seperti ini membuat migrasi **idempoten** — aman dijalankan berulang.

#### Pengisian data awal (`_seedInitialData`)

```dart
final budayaCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM budaya'));
if (budayaCount == 0) { for (final b in defaultBudayaList) { await db.insert('budaya', {...}); } }
```

- `Sqflite.firstIntValue(...)` pembantu untuk mengambil satu angka dari hasil query `COUNT(*)`.
- Data hanya diisi **bila tabel kosong**, supaya data buatan admin tidak tertimpa saat aplikasi diperbarui.
- Khusus kuis syaratnya `count <= 2` — warisan dari versi awal yang punya 2 soal contoh; agar bank soal lengkap tetap masuk.
- `conflictAlgorithm: ConflictAlgorithm.replace` pada seed kuis: bila ada soal dengan teks sama (kolom `soal` UNIQUE), timpa saja daripada melempar error.

### 6.2 `data/local/seed/` — data awal

Tiga file berisi **hanya konstanta data**, tanpa fungsi:

- `budaya_seed.dart` → `defaultBudayaList` (Keris, Borobudur, Badik, Tari Saman, Tongkonan, Gamelan)
- `sejarah_seed.dart` → `defaultSejarahList` (Detik Proklamasi, dll., lengkap dengan alur peristiwa)
- `quiz_seed.dart` → `defaultQuizList` (bank soal Sejarah/Budaya/Kedaerahan)

Perannya ada dua:

1. **Diisikan ke database** saat pertama kali dibuat (`onCreate`).
2. **Cadangan darurat** di repository bila tabel kosong: `if (maps.isEmpty) return defaultBudayaList;` sehingga layar tidak pernah benar-benar kosong.

Data seed **tidak pernah** di-import oleh halaman. Halaman hanya bicara dengan repository.

### 6.3 `data/models/` — bentuk data

Model adalah kelas Dart biasa yang mewakili satu baris tabel. Semua punya pola konversi yang sama:

| Method | Arah | Kapan dipakai |
|---|---|---|
| `toMap()` | Objek → `Map<String, dynamic>` | Sebelum `db.insert` / `db.update` |
| `fromMap()` | `Map` → Objek | Setelah `db.query` |
| `toJson()` | Objek → `String` | Menyimpan ke SharedPreferences |
| `fromJson()` | `String` → Objek | Membaca dari SharedPreferences |

`fromMap` selalu memakai pola bertahan-hidup:

```dart
nama: map['nama'] as String? ?? '',
id: map['id'] != null ? map['id'] as int : null,
```

`as String?` melakukan *cast* dengan mengizinkan null, lalu `?? ''` memberi nilai cadangan. Artinya kolom yang kosong atau bertipe tak terduga tidak akan membuat aplikasi crash.

#### `UserSQLModel`

Field: `id`, `nama`, `email`, `noHp`, `password`.

Di file yang sama ada penentu hak admin:

```dart
const Set<String> adminAccountNames = {'admin1', 'admin2'};

bool isAdminAccountName(String nama) =>
    adminAccountNames.contains(nama.toLowerCase().trim());
```

`Set` dipilih ketimbang `List` karena pengecekan `contains` pada Set lebih cepat dan isinya dijamin unik. Method turunan:

- `copyWith(...)` — membuat salinan dengan sebagian field diganti. Diperlukan karena semua field `final` (tidak bisa diubah setelah dibuat).
- `sanitized()` — salinan dengan `password: ''`, dipakai sebelum menyimpan sesi ke SharedPreferences supaya kata sandi tidak ikut tersimpan.
- `isAdminAccount` — getter yang memanggil `isAdminAccountName(nama)`.

#### `SejarahModel` & `TimelineItemModel`

```dart
class SejarahModel {
  final String kodeTag;    // 'HIS-170845-1'
  final String tanggalKey; // '170845'  (ddMMyy)
  final int urutan;        // 1 = sorotan utama hari itu
  final String judul, subtitle, ringkasan, gambarUtama;
  final List<TimelineItemModel> alurPeristiwa;
}
```

`TimelineItemModel` punya `date`, `title`, `desc`, `imgPath`, dan `hasImage`. Field `hasImage` dipakai sebagai saklar: di halaman detail, gambar hanya ditampilkan bila `item.hasImage` true — sehingga admin bisa menonaktifkan gambar tanpa menghapus path-nya.

#### `BudayaModel`

Selain field data, ada dua getter turunan:

```dart
bool get isDestinasi => kodeTag.trim().toUpperCase().endsWith(kodeDestinasiSuffix);
String get namaKategoriBudaya => namaKategori(jenis);
```

Getter adalah properti yang dihitung saat diakses, bukan disimpan. `item.isDestinasi` terlihat seperti field biasa padahal setiap kali dipanggil ia memeriksa akhiran `-D` pada ID tag. Keuntungannya: status destinasi tidak perlu kolom database tersendiri dan tidak mungkin tidak sinkron dengan ID tag-nya.

#### `QuizSQLModel`

```dart
final List<String> daftarJawaban;
final int jawabanBenar;   // INDEKS pada daftarJawaban, bukan teksnya
```

`jawabanBenar` menyimpan **indeks** (0, 1, 2, 3). Karena SQLite tidak bisa menyimpan `List<String>`, `toMap()` mengubahnya jadi teks JSON dan `fromMap()` mengembalikannya:

```dart
if (map['daftarJawaban'] is String) {
  try {
    parsedJawaban = List<String>.from(jsonDecode(map['daftarJawaban'] as String));
  } catch (_) { parsedJawaban = []; }
}
```

Blok `try/catch` melindungi dari JSON rusak: soal itu akan tampil tanpa pilihan jawaban, tapi aplikasi tetap hidup.

#### `BookmarkItemModel`

Model gabungan: baris bookmark **plus** objek isinya.

```dart
final String itemType;          // 'sejarah' | 'budaya'
final String kodeTag;
final SejarahModel? sejarah;    // salah satu diisi,
final BudayaModel? budaya;      // yang lain null
```

Getter-nya menyembunyikan percabangan itu dari UI:

```dart
String get title => itemType == 'sejarah' ? (sejarah?.judul ?? '') : (budaya?.judul ?? '');
```

Sehingga `bookmark_page.dart` cukup memanggil `item.title`, `item.subtitle`, `item.description`, `item.imagePath` tanpa peduli jenis isinya. `sejarah?.judul` memakai *null-aware operator* `?.` — bila `sejarah` null, hasilnya null (tidak crash), lalu `?? ''` memberi teks kosong.

### 6.4 `data/repositories/` — semua operasi database

Seluruh query memakai **parameter terikat**:

```dart
await db.query('budaya', where: 'kodeTag = ?', whereArgs: [kodeTag]);
```

Tanda `?` adalah placeholder yang diisi dari `whereArgs`. Ini bukan sekadar gaya penulisan: menyambung string secara langsung (`where: "kodeTag = '$kodeTag'"`) membuka celah **SQL injection** dan gagal bila teks mengandung tanda kutip.

#### `UserRepository`

| Method | SQL | Dipanggil dari |
|---|---|---|
| `userRegister(user)` | `INSERT INTO user` | `register_page.dart` |
| `loginUser(email, password)` | `SELECT ... WHERE email = ? AND password = ?` | `login_page.dart` |

`userRegister` mengembalikan `bool`:

```dart
try {
  final id = await db.insert('user', user.toMap());
  return id > 0;
} catch (e) { return false; }
```

`db.insert` mengembalikan id baris baru. Bila email sudah terdaftar, batasan `UNIQUE` membuat SQLite melempar exception — ditangkap `catch` dan diubah jadi `false`, yang lalu ditampilkan sebagai pesan "Email sudah terdaftar".

`loginUser` mengembalikan `UserSQLModel?` — objek user bila cocok, `null` bila tidak.

#### `SejarahRepository`

| Method | Operasi | Keterangan |
|---|---|---|
| `getAllSejarah()` | READ | Ambil semua, urut `id DESC`, decode JSON timeline |
| `getSejarahHariIni()` | READ | Cocokkan tanggal hari ini (lihat §10.1) |
| `getSejarahByKodeTag(kodeTag)` | READ | Untuk memuat isi bookmark |
| `getRandomSejarahList(count, exclude)` | READ | Kartu "Sejarah Lainnya" di halaman detail |
| `tambahSejarah(model)` | CREATE | Admin |
| `updateSejarah(model, previousKodeTag)` | UPDATE | Admin |
| `deleteSejarah(kodeTag)` | DELETE | Admin, sekaligus bersihkan bookmark |

`updateSejarah` punya dua kehalusan:

```dart
where: model.id != null ? 'id = ?' : 'kodeTag = ?',
whereArgs: [model.id ?? oldKodeTag],
```

Update dicari berdasarkan `id` bila ada. Ini penting karena bila admin mengubah ID tag, mencari berdasarkan `kodeTag` baru tidak akan menemukan baris mana pun sehingga penyimpanan gagal diam-diam. Lalu:

```dart
if (oldKodeTag != model.kodeTag) {
  await db.rawUpdate('UPDATE OR IGNORE bookmark SET kodeTag = ? WHERE kodeTag = ?',
      [model.kodeTag, oldKodeTag]);
}
```

Bookmark menyimpan `kodeTag`, jadi saat ID tag berubah, bookmark ikut dipindahkan agar tidak menggantung. `OR IGNORE` mencegah error bila hasil pemindahan bentrok dengan batasan UNIQUE.

`deleteSejarah` juga menghapus bookmark yang menunjuk item terhapus, supaya tidak ada bookmark "hantu".

#### `BudayaRepository`

| Method | Operasi | Keterangan |
|---|---|---|
| `getAllBudaya()` | READ | Sumber semua method lain di bawah |
| `getBudayaHariIni()` | READ | Acak berbenih tanggal (§10.2) |
| `getBudayaByJenis(jenis)` | READ | Isi halaman kategori, urut `urutan` |
| `getBudayaGroupedByJenis()` | READ | `Map<kode, List<Budaya>>` untuk kartu kategori di beranda |
| `getDestinasiList(acak, limit)` | READ | Item ber-akhiran `-D` |
| `getDestinasiCount()` | READ | Untuk pesan tombol acak ulang |
| `getBudayaByKodeTag(kodeTag)` | READ | Memuat isi bookmark |
| `getRandomBudayaList(count, exclude)` | READ | Kartu "Budaya Lainnya" |
| `tambahBudaya(model)` | CREATE | Admin |
| `updateBudaya(model, previousKodeTag)` | UPDATE | Admin |
| `deleteBudaya(kodeTag)` | DELETE | Admin + bersihkan bookmark |

Menarik: sebagian besar method **tidak** melakukan query sendiri, melainkan memanggil `getAllBudaya()` lalu menyaring di memori:

```dart
Future<List<BudayaModel>> getBudayaByJenis(String jenis) async {
  final list = await getAllBudaya();
  final target = jenis.trim().toUpperCase();
  final result = list.where((b) => b.jenis.trim().toUpperCase() == target).toList();
  result.sort((a, b) => a.urutan.compareTo(b.urutan));
  return result;
}
```

Alasannya: penyaringan butuh perbandingan yang tidak peka huruf besar-kecil dan cadangan `defaultBudayaList` saat tabel kosong — dua hal yang merepotkan bila ditulis sebagai SQL. Dengan data puluhan baris, biayanya tidak terasa. Bila kelak datanya ribuan, inilah tempat pertama yang perlu diubah jadi query `WHERE`.

`.where(...)` menyaring, `.toList()` mengubah hasilnya jadi List, `.sort((a,b) => a.urutan.compareTo(b.urutan))` mengurutkan naik (`compareTo` mengembalikan negatif/nol/positif).

#### `QuizRepository`

| Method | Operasi | Dipakai di |
|---|---|---|
| `tambahQuiz(quiz)` | CREATE | Admin (buat tema & tambah soal) |
| `getAllQuizzes()` | READ | Menu kuis & daftar tema admin |
| `getQuizByTema(tema)` | READ | Halaman detail tema admin |
| `getRandomQuizzesByCategory(kategori, limit)` | READ | Mulai kuis per kategori |
| `getQuizCountByKategori(kategori)` | READ | Menampilkan "Total bank soal tersedia" |
| `updateQuiz(quiz)` | UPDATE | Edit satu soal |
| `updateThemeInfo(...)` | UPDATE | Ubah nama tema/kategori/cover **untuk semua soal sekaligus** |
| `deleteQuiz(id)` | DELETE | Hapus satu soal |
| `deleteQuizzesByTema(tema)` | DELETE | Hapus seluruh tema |

Dua yang perlu disorot:

```dart
final results = await db.query('quiz',
  where: 'UPPER(kategori) = ?', whereArgs: [kategori.toUpperCase()],
  orderBy: 'RANDOM()', limit: limit);
```

- `UPPER(kategori)` adalah fungsi SQL yang membuat pencocokan tidak peka huruf besar-kecil, sehingga `'Sejarah'` di UI cocok dengan `'SEJARAH'` di database.
- **`ORDER BY RANDOM()`** menyuruh SQLite mengacak baris, lalu `limit` mengambil sekian teratas. Ini cara mengambil sampel acak tanpa memuat seluruh tabel ke memori.

```dart
Future<bool> updateThemeInfo({required String oldTema, required String newTema, ...}) {
  return db.update('quiz', values, where: 'tema = ?', whereArgs: [oldTema]);
}
```

Satu `UPDATE` menyentuh banyak baris sekaligus — karena "tema" bukan tabel tersendiri melainkan sekadar nilai kolom yang sama di banyak soal. Mengganti nama tema berarti mengganti nilai itu di semua soalnya.

#### `BookmarkRepository`

Repository ini juga bergantung pada dua repository lain (untuk memuat isi bookmark) dan pada `PreferenceHandler` (untuk tahu siapa yang login):

```dart
BookmarkRepository({DbHelper? dbHelper, SejarahRepository? sejarahRepository, BudayaRepository? budayaRepository})
    : _dbHelper = dbHelper ?? DbHelper(), ...
```

Parameter opsional dengan cadangan `?? DbHelper()` disebut *dependency injection*: pemakaian normal cukup `BookmarkRepository()`, tapi saat pengujian bisa disuntikkan versi tiruan.

| Method | Operasi | Keterangan |
|---|---|---|
| `isBookmarked(kodeTag)` | READ | Menentukan ikon bookmark terisi atau kosong |
| `toggleBookmark(itemType, kodeTag)` | CREATE/DELETE | Cek dulu, lalu tambah atau hapus |
| `addBookmark(itemType, kodeTag)` | CREATE | `createdAt` diisi `DateTime.now().toIso8601String()` |
| `removeBookmark(kodeTag)` | DELETE | |
| `getAllBookmarks()` | READ | Gabungkan tiap baris dengan isi sejarah/budayanya |

Semua query menyertakan `userEmail = ?` sehingga bookmark terpisah per akun. Emailnya diambil lewat getter privat:

```dart
String get _currentUserEmail {
  try { return PreferenceHandler.userEmail.toLowerCase().trim(); }
  catch (_) { return ''; }
}
```

`getAllBookmarks()` melakukan penggabungan manual — untuk setiap baris bookmark, ia memanggil repository yang sesuai:

```dart
if (itemType == 'sejarah') {
  final sejarah = await _sejarahRepository.getSejarahByKodeTag(kodeTag);
  if (sejarah != null) items.add(BookmarkItemModel.fromMap(map, sejarah: sejarah));
}
```

Perhatikan `if (sejarah != null)`: bila item aslinya sudah dihapus admin, bookmark itu **dilewati** dan tidak ditampilkan.

---

## 7. Lapisan Services

### `preference_handler.dart`

Pembungkus SharedPreferences (penyimpanan pasangan kunci–nilai sederhana, cocok untuk data kecil seperti status login).

```dart
static late SharedPreferences _prefs;
static Future<void> init() async { _prefs = await SharedPreferences.getInstance(); }
```

`late` berarti "variabel ini pasti diisi sebelum dipakai, percayalah". Berkat `init()` yang dipanggil di `main()`, seluruh getter di bawah bisa **sinkron** (tanpa `await`) — sangat memudahkan pemakaian di dalam `build()` yang tidak boleh async.

| Anggota | Fungsi |
|---|---|
| `init()` | Membuka SharedPreferences (dipanggil sekali di `main`) |
| `saveUser(user)` | Menyimpan sesi: flag login, data user (tanpa password), flag admin, nama, email |
| `isLogin` | Getter bool — dipakai SplashPage |
| `isAdmin` | Getter bool |
| `userName` / `userEmail` | Getter String |
| `user` | Getter `UserSQLModel?` — mem-parse JSON tersimpan |
| `logOut()` | Menghapus kelima kunci sesi |

```dart
static Future<void> saveUser(UserSQLModel user) async {
  await _prefs.setBool(_keyIsLogin, true);
  await _prefs.setString(_keyUserData, user.sanitized().toJson());
  await _prefs.setBool(_keyIsAdmin, user.isAdminAccount);
  ...
}
```

`user.sanitized()` mengosongkan password sebelum disimpan. `logOut()` sengaja menghapus kunci satu per satu, **bukan** `_prefs.clear()`, supaya pengaturan lain (bila nanti ada) tidak ikut terhapus.

Getter `user` membungkus parsing dengan `try/catch` dan mengembalikan `null` bila JSON-nya rusak — sehingga data lama yang formatnya berbeda tidak membuat aplikasi gagal jalan.

---

## 8. Lapisan Presentation

### 8.1 `splash_page.dart`

Sudah dibahas di §4.2. Widget-nya menampilkan logo, nama aplikasi, tagline, dan `Lottie.asset('assets/animations/loading.json')`. Parameter `frameRate: FrameRate(90)` menaikkan kehalusan animasi.

### 8.2 `onboarding_page.dart`

Tiga slide dalam `PageView.builder` yang dikendalikan `PageController`.

```dart
final PageController _pageController = PageController();
int _currentPage = 0;

@override
void dispose() { _pageController.dispose(); super.dispose(); }
```

**`dispose()`** adalah method siklus hidup `State` yang dipanggil saat widget dilepas selamanya. Controller (PageController, TextEditingController, ScrollController, Timer) **wajib** dibuang di sini; bila tidak, ia terus memakai memori — inilah *memory leak*. Pola ini muncul di banyak file proyek ini.

Tombol:

```dart
void _next() {
  if (_currentPage < _items.length - 1) {
    _pageController.nextPage(duration: Duration(milliseconds: 550), curve: Curves.easeInOut);
  } else {
    context.pushReplacement(LoginPage());
  }
}
```

- Selama belum slide terakhir, tombol menggeser halaman dengan animasi (`curve` = pola percepatan; `easeInOut` = pelan–cepat–pelan).
- Pada slide terakhir, teks tombol berubah jadi "Mulai" dan menuju login dengan `pushReplacement` (onboarding tidak perlu bisa di-back).
- `onPageChanged` memperbarui `_currentPage` lewat `setState`, yang membuat indikator titik di bawah ikut menyesuaikan lebarnya lewat `AnimatedContainer`.

Latar tiap slide adalah `Stack`: gambar penuh layar, lalu `Container` bergradasi transparan → warna latar yang membuat teks di bawah tetap terbaca.

### 8.3 `login_page.dart`

```dart
final _formKey = GlobalKey<FormState>();
final _emailController = TextEditingController();
bool _obscurePassword = true;
bool _isLoading = false;
```

Alur saat tombol **Login** ditekan:

```dart
void _login() async {
  if (!_formKey.currentState!.validate()) return;   // 1
  setState(() => _isLoading = true);                // 2
  final user = await _userRepository.loginUser(email, password);  // 3
  if (!mounted) return;                             // 4
  setState(() => _isLoading = false);
  if (user != null) {                               // 5
    await PreferenceHandler.saveUser(user);
    if (!mounted) return;
    context.pushAndRemoveAll(MainPage(currentUser: user));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(...); // 6
  }
}
```

1. **`_formKey.currentState!.validate()`** menjalankan semua `validator` di dalam `Form`. Bila ada yang mengembalikan pesan, pesan itu muncul di bawah input dan fungsi berhenti. `GlobalKey` adalah "gagang" untuk menyentuh state widget lain dari luar.
2. `_isLoading = true` → teks tombol berubah jadi "Memuat..." dan `onPressed` diberi `null` sehingga tombol nonaktif. Ini mencegah pengguna menekan dua kali.
3. `await` menunggu query database selesai tanpa membekukan tampilan.
4. Cek `mounted` karena ada `await` sebelumnya.
5. Bila user ditemukan: simpan sesi, lalu ke MainPage dengan menghapus seluruh riwayat.
6. **`ScaffoldMessenger.of(context).showSnackBar(...)`** menampilkan pesan singkat di bawah layar. `ScaffoldMessenger` dipakai (bukan `Scaffold.of`) agar pesan tetap hidup walau halamannya berganti.

Validator email: wajib diisi dan harus mengandung `@`. Validator password: wajib diisi, minimal 8 karakter.

Ikon mata memakai `setState(() => _obscurePassword = !_obscurePassword)` — membalik nilai bool sehingga teks password ditampilkan/disembunyikan.

### 8.4 `register_page.dart`

Serupa login, dengan tambahan:

**Indikator syarat password secara langsung.** `AppTextField` password memakai `onChanged: _onPasswordChanged`:

```dart
void _onPasswordChanged(String value) {
  setState(() {
    _hasText = value.isNotEmpty;
    _hasMinLength = value.length >= 8;
    _hasComplexChars = value.contains(RegExp(r'[A-Z]')) &&
        value.contains(RegExp(r'[a-z]')) &&
        value.contains(RegExp(r'[0-9]'));
  });
}
```

`RegExp(r'[A-Z]')` adalah *regular expression*; `r'...'` adalah *raw string* supaya backslash tidak diartikan khusus. Setiap ketikan memicu `setState`, sehingga ikon centang/silang di kotak "Ketentuan Kata Sandi" berubah seketika.

**Validator konfirmasi password** membandingkan dengan controller lain:

```dart
validator: (val) => val != _passwordController.text ? 'Password tidak cocok' : null,
```

**Validator nomor HP** memakai `int.tryParse(val) == null` untuk memastikan isinya hanya angka. `tryParse` mengembalikan `null` (bukan melempar error) bila gagal — versi aman dari `int.parse`.

Setelah berhasil, halaman menampilkan SnackBar hijau lalu `context.pushReplacement(const LoginPage())`.

### 8.5 `main_page.dart` — kerangka utama

```dart
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
int _selectedIndex = 0;
```

`_scaffoldKey` dipakai untuk membuka drawer dari widget anak:

```dart
onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
```

Tombol menu berada di dalam `HomePage`, sedangkan `Drawer` milik `Scaffold` di `MainPage`. Karena `Scaffold.of(context)` dari dalam HomePage tidak menemukan Scaffold yang benar, dipakailah GlobalKey — `currentState` memberi akses ke `ScaffoldState` beserta method `openDrawer()`. Tanda `?.` menjaga bila state-nya belum siap.

Penentuan hak admin:

```dart
bool get _isAdmin {
  final user = widget.currentUser ?? PreferenceHandler.user;
  if (user != null) return user.isAdminAccount;
  return widget.isAdmin ?? PreferenceHandler.isAdmin;
}
```

Prioritasnya: data user yang sebenarnya → baru flag yang dioper/tersimpan. Konsekuensinya, sesi lama yang terlanjur bertanda admin otomatis turun status bila namanya bukan `admin1`/`admin2`.

`widget.` dipakai di dalam class `State` untuk mengakses properti widget-nya (`MainPage`). Ini karena `State` dan `Widget` adalah dua objek terpisah.

**Bottom navigation** dibuat manual (bukan `BottomNavigationBar`) agar bisa memakai animasi Lottie:

```dart
isSelected
  ? Lottie.asset(_activeIcons[index], repeat: false, ...)
  : Icon(_inactiveIcons[index], ...)
```

Tab aktif memainkan animasi sekali (`repeat: false`), tab lain memakai ikon statis. `AnimatedContainer` dengan `width: isSelected ? 36 : 0` membuat garis penanda tumbuh dari nol dengan animasi 300 ms. `GestureDetector` dengan `behavior: HitTestBehavior.opaque` membuat seluruh area kolom bisa disentuh, bukan hanya ikonnya.

Halaman ditampilkan dengan `pages[_selectedIndex]`. Karena `_getPages()` dipanggil setiap `build`, berpindah tab akan **membangun ulang** halaman — inilah sebabnya beranda memuat ulang datanya setiap kali tab dibuka.

### 8.6 `home_page.dart`

State-nya dua nilai yang bisa null:

```dart
SejarahModel? _sejarahHariIni;
BudayaModel? _budayaHariIni;

@override
void initState() { super.initState(); _loadFromRepository(); }

Future<void> _loadFromRepository() async {
  final sejarah = await _sejarahRepository.getSejarahHariIni();
  final budaya = await _budayaRepository.getBudayaHariIni();
  if (!mounted) return;
  setState(() { _sejarahHariIni = sejarah; _budayaHariIni = budaya; });
}
```

Selama masih `null`, ditampilkan `_HighlightPlaceholder` (kotak berbingkai dengan lingkaran loading). Setelah data tiba, `setState` memicu `build` ulang dan kartu asli muncul.

**Struktur tampilan:** `NestedScrollView` + `SliverAppBar(floating: true)`. `floating` membuat header muncul kembali begitu user menggulir ke atas sedikit, tanpa harus sampai puncak.

**Menekan logo RENJANA = refresh:**

```dart
GestureDetector(
  behavior: HitTestBehavior.opaque,
  onTap: () async {
    await _loadFromRepository();
    if (context.mounted) { ...showSnackBar('Halaman beranda diperbarui'); }
  },
```

**Ikon bookmark di kanan** membuka koleksi tersimpan: `onPressed: () => context.push(const BookmarkPage())`.

**Tanggal berbahasa Indonesia:**

```dart
DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now())
```

`EEEE` = nama hari lengkap, `dd` = tanggal dua digit, `MMMM` = nama bulan lengkap, `yyyy` = tahun. Argumen `'id_ID'` inilah yang butuh `initializeDateFormatting` di `main()`.

Urutan isi beranda: sapaan & tanggal → 01 Sejarah Hari Ini → 02 Budaya Hari Ini → 03 Koleksi Budaya → 04 Pilihan Destinasi → banner kontribusi.

### 8.7 Widget beranda

#### `sejarah_highlight_card.dart` & `budaya_highlight_card.dart`

Keduanya `StatelessWidget` yang menerima model **wajib** (`required this.data`) — data selalu datang dari HomePage, tidak ada lagi cadangan internal.

Sentuhan visual yang perlu dijelaskan:

```dart
Stack(
  clipBehavior: Clip.none,
  children: [
    Positioned(right: -15, top: -40, child: Text('01', style: ...fontSize: 90)),
    Column(...),
  ],
)
```

- `Stack` menumpuk anak-anaknya. `Positioned` dengan nilai negatif menaruh watermark angka sedikit **di luar** batas induk; `clipBehavior: Clip.none` mengizinkannya terlihat (bawaannya akan dipotong).

```dart
Transform.rotate(
  angle: -1 * (math.pi / 180),
  child: Container(... border: Border.all(color: Colors.white, width: 5, strokeAlign: BorderSide.strokeAlignOutside)),
)
```

- `Transform.rotate` memiringkan gambar. Sudut dalam radian, jadi `-1 * (pi/180)` = miring 1 derajat berlawanan jarum jam — meniru foto yang ditempel agak miring.
- `strokeAlignOutside` menggambar bingkai putih di luar kotak sehingga gambar tidak terpotong.

Tombol **"Masuki Kisah"** → `context.push(DetailSejarahPage(sejarah: data))`. Pada kartu budaya, baris "Pelajari lebih lanjut" dibungkus `GestureDetector` dengan tujuan `DetailBudayaPage`.

#### `koleksi_budaya_list.dart`

Menampilkan **8 kartu kategori** (bukan daftar item), digulir mendatar.

```dart
Future<void> _loadItems() async {
  final grouped = await _budayaRepository.getBudayaGroupedByJenis();
  setState(() { _grouped = grouped; _isLoading = false; });
}
```

Untuk tiap kategori dari `budayaKategoriList`:

```dart
final items = _grouped[kategori.kode] ?? const <BudayaModel>[];
final coverImage = items.isNotEmpty ? items.first.gambarUtama : null;
```

Sampulnya diambil dari item pertama kategori itu; bila kategori masih kosong, `coverImage` bernilai `null` dan `AppImageView` menampilkan placeholder. Teks "N koleksi" memakai `items.length`.

Saat kartu disentuh:

```dart
onTap: () async {
  await context.push(KoleksiKategoriPage(kategori: kategori));
  await _loadItems();   // menyegarkan hitungan setelah kembali
},
```

`Scrollbar` + `ScrollbarTheme` memberi indikator gulir berwarna primary di bawah daftar; keduanya berbagi `ScrollController` yang sama dengan `SingleChildScrollView` — bila controller-nya berbeda, scrollbar tidak akan bergerak.

#### `pilihan_destinasi_list.dart`

Menampilkan budaya yang juga tempat wisata:

```dart
Future<void> _loadItems({bool acak = true}) async {
  final list = await _budayaRepository.getDestinasiList(acak: acak, limit: _jumlahTampil);
  final total = await _budayaRepository.getDestinasiCount();
  setState(() { _items = list; _totalDestinasi = total; _isLoading = false; _isRefreshing = false; });
}
```

Tombol **"Tampilkan destinasi lain"**:

```dart
Future<void> _refreshDestinasi() async {
  if (_isRefreshing) return;                     // penjaga klik ganda
  setState(() => _isRefreshing = true);
  final messenger = ScaffoldMessenger.of(context);   // diambil SEBELUM await
  await _loadItems(acak: true);
  if (!mounted) return;
  messenger.showSnackBar(SnackBar(content: Text(
    _totalDestinasi > _jumlahTampil
        ? 'Menampilkan pilihan destinasi lainnya'
        : 'Baru ada $_totalDestinasi destinasi, urutannya diacak ulang')));
}
```

Tiga hal yang disengaja:

1. `messenger` diambil **sebelum** `await`. Mengambil `ScaffoldMessenger.of(context)` setelah `await` berisiko bila widget sudah dilepas. Pola ini dipakai konsisten di seluruh proyek.
2. Pesan menyesuaikan kenyataan: bila destinasi yang ada belum melebihi jumlah yang ditampilkan, aplikasi jujur mengatakan urutannya hanya diacak, bukan mengklaim ada yang baru.
3. Ikon tombol berubah jadi lingkaran loading kecil saat `_isRefreshing`, dan `onPressed` diberi `null` sehingga nonaktif.

Refresh ini **tidak** menyentuh sorotan harian di atasnya — itulah maksud "refresh khusus bagian ini".

#### `banner_melestarikan.dart`

Kartu ajakan berkontribusi. Tombolnya memakai `onContribute ?? () {}` — bila induk tidak memberi aksi, tombol tetap bisa ditekan tapi tidak melakukan apa-apa (belum diimplementasikan).

### 8.8 `koleksi_kategori_page.dart`

Halaman daftar untuk satu kategori. Menerima objek kategori lewat konstruktor:

```dart
const KoleksiKategoriPage({super.key, required this.kategori});
```

Isinya:

- `_isLoading` → lingkaran loading
- daftar kosong → `_buildEmptyState()` dengan pesan "Belum ada koleksi <nama kategori>"
- ada isi → `ListView.separated` di dalam `RefreshIndicator`

**`ListView.separated`** membangun item **dan** pemisah antar item:

```dart
itemCount: _items.length,
separatorBuilder: (context, index) => const SizedBox(height: 16),
itemBuilder: (context, index) => _buildItemCard(_items[index]),
```

Berbeda dengan `ListView(children: [...])` yang membangun semua anak sekaligus, versi `builder` hanya membangun item yang terlihat — hemat memori untuk daftar panjang.

**`RefreshIndicator`** memberi gestur "tarik ke bawah untuk menyegarkan"; `onRefresh` harus mengembalikan `Future` — indikator berputar sampai Future itu selesai.

Kartu itemnya memakai `Row` dengan gambar 110 px di kiri:

```dart
SizedBox(width: 110, child: AspectRatio(aspectRatio: 1, child: AppImageView(...)))
```

`AspectRatio(aspectRatio: 1)` memaksa tinggi = lebar (bujur sangkar) apa pun rasio file aslinya. Ini juga alasan `CrossAxisAlignment.stretch` tidak dipakai: di dalam `ListView`, tinggi `Row` tidak terbatas, dan `stretch` akan meminta anaknya setinggi tak hingga sehingga layout gagal.

Badge "DESTINASI" hanya muncul bila `item.isDestinasi`, memakai *spread operator* kondisional:

```dart
if (item.isDestinasi) ...[
  const SizedBox(width: 6),
  Container(color: AppColors.accentBudaya, child: Text('DESTINASI')),
],
```

`...[ ]` (spread) menyisipkan beberapa widget sekaligus ke dalam daftar `children`.

### 8.9 Halaman detail

`detail_sejarah_page.dart` dan `detail_budaya_page.dart` berpola sama.

```dart
@override
void initState() {
  super.initState();
  _checkBookmarkStatus();
  _loadOtherSejarah();
}
```

**Status bookmark:**

```dart
Future<void> _checkBookmarkStatus() async {
  final bookmarked = await _bookmarkRepository.isBookmarked(data.kodeTag);
  if (!mounted) return;
  setState(() => _isBookmarked = bookmarked);
}
```

Hasilnya menentukan ikon di `DetailTopBar`: `Icons.bookmark` (terisi) atau `Icons.bookmark_border` (garis luar).

**Menekan tombol bookmark:**

```dart
onBookmarkToggle: () async {
  final messenger = ScaffoldMessenger.of(context);
  final nowBookmarked = await _bookmarkRepository.toggleBookmark('sejarah', data.kodeTag);
  if (!mounted) return;
  setState(() => _isBookmarked = nowBookmarked);
  messenger.clearSnackBars();
  messenger.showSnackBar(SnackBar(content: Text(
      nowBookmarked ? 'Berhasil disimpan ke Bookmark' : 'Berhasil dihapus dari Bookmark')));
}
```

`toggleBookmark` mengembalikan status **setelah** operasi, sehingga UI dan pesan langsung sinkron tanpa query tambahan. `clearSnackBars()` menghapus pesan sebelumnya supaya tidak menumpuk saat tombol ditekan berkali-kali.

**Susunan tampilan:** gambar utama besar dengan gradasi menuju warna latar (`Color(0x00F4F0E7)` → `AppColors.background`) yang membuat gambar "melebur" ke halaman. Judul diletakkan dengan `Positioned(top: -100)` di dalam `Stack` sehingga naik menimpa area gambar.

**Timeline (khusus sejarah):**

```dart
...List.generate(data.alurPeristiwa.length, (index) {
  final item = data.alurPeristiwa[index];
  final bool isLast = index == data.alurPeristiwa.length - 1;
  return TimelineItemWidget(
    date: item.date, title: item.title, description: item.desc,
    imagePath: item.hasImage ? item.imgPath : null,
    isLast: isLast,
  );
})
```

`isLast` dipakai `TimelineItemWidget` untuk **tidak** menggambar garis penghubung vertikal pada item terakhir. Garis itu dibuat dengan `Positioned(top: 8, bottom: -10, left: 3, child: Container(width: 1.5))` — `bottom: -10` memanjangkannya sedikit melewati batas agar menyambung ke item berikutnya.

**Daftar "Lainnya"** memakai `getRandomSejarahList(count: 5, exclude: widget.sejarah)` sehingga item yang sedang dibuka tidak muncul lagi. Menyentuh kartu memanggil `context.push(DetailSejarahPage(sejarah: other))` — menumpuk halaman detail baru; inilah alasan tombol home memakai `popUntil`.

### 8.10 `bookmark_page.dart`

State: `_bookmarks`, `_isLoading`, `_searchQuery`, `_selectedTab`.

**Penyaringan dilakukan lewat getter**, bukan disimpan sebagai state terpisah:

```dart
List<BookmarkItemModel> get _filteredBookmarks {
  return _bookmarks.where((item) {
    final matchesTab = _selectedTab == 'SEMUA' || item.itemType.toUpperCase() == _selectedTab;
    final matchesQuery = _searchQuery.isEmpty ||
        item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        item.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        item.description.toLowerCase().contains(_searchQuery.toLowerCase());
    return matchesTab && matchesQuery;
  }).toList();
}
```

Karena getter dihitung ulang setiap `build`, cukup `setState` mengubah `_searchQuery` atau `_selectedTab` dan daftarnya otomatis menyesuaikan. Pencarian menyamakan huruf kecil di kedua sisi supaya tidak peka huruf besar-kecil.

Chip tab menampilkan hitungan: `'Sejarah ($totalSejarah)'`, dihitung dengan `_bookmarks.where((b) => b.itemType == 'sejarah').length`.

**Membuka detail lalu menyegarkan:**

```dart
void _openDetail(BookmarkItemModel item) async {
  ScaffoldMessenger.of(context).clearSnackBars();
  if (item.itemType == 'sejarah' && item.sejarah != null) {
    await context.push(DetailSejarahPage(sejarah: item.sejarah!));
  } ...
  _loadBookmarks();   // jika user melepas bookmark di halaman detail, daftar ikut terbarui
}
```

**Menghapus bookmark** memakai `_removeBookmark(item)` yang menghapus, memberi SnackBar berisi judul item, lalu memuat ulang daftar.

`_loadBookmarks` memakai `try/finally`:

```dart
try { ... setState(() => _bookmarks = list); }
finally { if (mounted) setState(() => _isLoading = false); }
```

Blok `finally` selalu dijalankan — sukses maupun gagal — sehingga indikator loading tidak pernah tersangkut selamanya.

### 8.11 `quiz_page.dart` — menu kuis

Dua bagian: **kategori** (3 kartu tetap) dan **rekomendasi tema** (dibuat dari data).

**Pengelompokan tema:**

```dart
List<_ThemeRecommendation> get _themeRecommendations {
  final Map<String, List<QuizSQLModel>> grouped = {};
  for (final q in _allQuizzes) {
    if (q.tema.trim().isEmpty) continue;
    grouped.putIfAbsent(q.tema, () => []).add(q);
  }
  ...
}
```

`putIfAbsent(kunci, () => [])` mengambil daftar untuk tema itu, atau membuat daftar kosong baru bila belum ada — idiom standar untuk mengelompokkan. `_ThemeRecommendation` adalah class privat (`_` di depan) yang hanya dipakai file ini, berisi tema, kategori, sampul, jumlah soal, contoh soal, dan daftar soalnya.

Sampul tema dicari dari soal pertama yang punya gambar:

```dart
for (final q in e.value) {
  if (q.gambar != null && q.gambar!.trim().isNotEmpty) { coverImage = q.gambar; break; }
}
```

**Menekan kartu kategori** membuka bottom sheet lewat `_showCategoryQuizModal`:

```dart
final availableCount = await _quizRepository.getQuizCountByKategori(categoryName);
int selectedCount = availableCount > 0 ? (availableCount < 10 ? availableCount : 10) : 10;
```

Nilai awal = 10, atau seluruh soal yang ada bila kurang dari 10.

Di dalam bottom sheet dipakai **`StatefulBuilder`**:

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (modalCtx) => StatefulBuilder(
    builder: (ctx, setModalState) { ... }
  ),
);
```

Bottom sheet berada di "lapisan" berbeda dari halaman, sehingga `setState` halaman **tidak** membangun ulang isinya. `StatefulBuilder` menyediakan `setModalState` — fungsi setState mini khusus untuk isi sheet. Ini dipakai agar chip pilihan (10/20/50) langsung berubah warna saat dipilih.

`isScrollControlled: true` mengizinkan sheet lebih tinggi dari setengah layar, dan `padding: EdgeInsets.only(bottom: MediaQuery.of(modalCtx).viewInsets.bottom)` mendorong isi ke atas saat keyboard muncul (`viewInsets.bottom` = tinggi keyboard).

**Menekan "Mulai Kuis":**

```dart
final inputVal = int.tryParse(customController.text.trim()) ?? selectedCount;
final targetCount = inputVal > 0 ? inputVal : 10;
Navigator.pop(modalCtx);                       // tutup sheet dulu
final questions = await _quizRepository.getRandomQuizzesByCategory(categoryName, targetCount);
if (!mounted) return;
if (questions.isEmpty) { ...SnackBar('Belum ada soal untuk kategori ...'); return; }
context.push(QuizPlayPage(title: 'Kuis $categoryName', category: categoryName, questions: questions));
```

**Menekan kartu rekomendasi tema** (`_startThemeQuiz`) tidak query ulang — soal-soalnya sudah ada di objek rekomendasi, tinggal diacak:

```dart
final shuffled = List<QuizSQLModel>.from(rec.questions)..shuffle();
```

Tanda `..` adalah *cascade operator*: `..shuffle()` menjalankan shuffle lalu **tetap mengembalikan list-nya** (bukan hasil shuffle yang `void`). Menyalin dulu dengan `List.from` penting supaya daftar aslinya tidak ikut teracak.

`RefreshIndicator` di halaman ini memanggil `_loadData` untuk memuat ulang bank soal, berguna setelah admin menambah soal.

### 8.12 `quiz_play_page.dart` — mengerjakan soal

**Class pendamping** yang menyimpan keadaan tiap soal selama permainan:

```dart
class PlayQuestionItem {
  final QuizSQLModel original;
  final List<String> shuffledOptions;
  final int correctShuffledIndex;
  int? selectedIndex;
  bool isAnswered = false;

  bool get isCorrect => selectedIndex != null && selectedIndex == correctShuffledIndex;
}
```

**Pengacakan pilihan jawaban** (dijelaskan lengkap di §10.3):

```dart
void _setupQuestions() {
  _playItems = widget.questions.map((q) {
    final String correctText = (q.daftarJawaban.isNotEmpty && q.jawabanBenar < q.daftarJawaban.length)
        ? q.daftarJawaban[q.jawabanBenar]
        : (q.daftarJawaban.isNotEmpty ? q.daftarJawaban.first : '');
    final List<String> options = List<String>.from(q.daftarJawaban)..shuffle();
    final int newCorrectIndex = options.indexOf(correctText);
    return PlayQuestionItem(original: q, shuffledOptions: options,
        correctShuffledIndex: newCorrectIndex >= 0 ? newCorrectIndex : 0);
  }).toList();
}
```

**Timer:**

```dart
void _startTimer() {
  _timer = Timer.periodic(const Duration(seconds: 1), (_) {
    if (mounted) setState(() => _elapsedSeconds++);
  });
}

@override
void dispose() { _timer?.cancel(); super.dispose(); }
```

`Timer.periodic` menjalankan callback tiap detik. **Wajib** di-`cancel()` di `dispose`, kalau tidak ia terus berjalan setelah halaman ditutup dan memanggil `setState` pada widget mati.

Format tampilan waktu:

```dart
String _formatDuration(int totalSeconds) {
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
```

`~/` adalah pembagian bulat (125 ~/ 60 = 2), `%` adalah sisa bagi (125 % 60 = 5), `padLeft(2, '0')` menambah nol di depan → `"02:05"`.

**Memilih jawaban:**

```dart
void _selectAnswer(int index) {
  final current = _playItems[_currentIndex];
  if (current.isAnswered) return;      // sekali jawab, tidak bisa diubah
  setState(() { current.selectedIndex = index; current.isAnswered = true; });
}
```

Setelah dijawab, `build` mewarnai opsi: jawaban benar hijau (`AppColors.success`) dengan ikon centang, jawaban salah yang dipilih merah dengan ikon silang, sisanya tetap netral. Kotak pembahasan muncul dengan `quiz.penjelasan` bila ada, atau kalimat cadangan "Jawaban yang benar adalah ...".

`AppColors.success.withValues(alpha: 0.12)` membuat versi transparan dari warna untuk latar kotak.

**Tombol lanjut:**

```dart
void _nextQuestion() {
  if (_currentIndex < _playItems.length - 1) { setState(() => _currentIndex++); }
  else { _finishQuiz(); }
}
```

Teks dan ikon tombol berubah di soal terakhir menjadi "Lihat Hasil Kuis".

`LinearProgressIndicator(value: progress)` di bawah AppBar memakai `progress = (_currentIndex + 1) / _playItems.length` — nilai 0..1.

**Mencegah keluar tak sengaja:**

```dart
PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, result) async {
    if (didPop) return;
    final shouldExit = await _onWillPop();
    if (shouldExit && context.mounted) Navigator.pop(context);
  },
  child: Scaffold(...),
)
```

`canPop: false` menahan tombol back sistem. `onPopInvokedWithResult` dipanggil saat user mencoba keluar; `_onWillPop()` menampilkan dialog konfirmasi dan mengembalikan `bool` lewat `Navigator.pop(ctx, true/false)`. Perhatikan `showDialog<bool>` — tipe generic-nya menentukan tipe nilai yang dikembalikan dialog. `return shouldExit ?? false` memperlakukan "dialog ditutup di luar tombol" sebagai batal.

**Selesai:**

```dart
void _finishQuiz() {
  _timer?.cancel();
  int correct = 0, incorrect = 0;
  for (final item in _playItems) { item.isCorrect ? correct++ : incorrect++; }
  context.pushReplacement(QuizResultPage(
    title: widget.title, category: widget.category, playItems: _playItems,
    correctCount: correct, incorrectCount: incorrect, elapsedSeconds: _elapsedSeconds));
}
```

`pushReplacement` dipakai supaya tombol back dari halaman hasil tidak kembali ke soal yang sudah selesai.

### 8.13 `quiz_result_page.dart`

**Perhitungan skor & umpan balik bertingkat:**

```dart
final scorePercent = total > 0 ? (widget.correctCount / total) * 100 : 0;

if (scorePercent == 100)      { 'Sempurna!',      AppColors.gold }
else if (scorePercent >= 70)  { 'Hebat Sekali!',  AppColors.success }
else if (scorePercent >= 50)  { 'Cukup Bagus!',   AppColors.warning }
else                          { 'Jangan Menyerah!', AppColors.error }
```

Penjagaan `total > 0` mencegah pembagian dengan nol.

**Filter pembahasan** memakai pola getter yang sama seperti bookmark:

```dart
List<PlayQuestionItem> get _filteredItems {
  if (_selectedFilter == 1) return widget.playItems.where((i) => i.isCorrect).toList();
  if (_selectedFilter == 2) return widget.playItems.where((i) => !i.isCorrect).toList();
  return widget.playItems;
}
```

**Tombol "Ulangi Kuis":**

```dart
void _restartQuiz() {
  context.pushReplacement(QuizPlayPage(
    title: widget.title,
    category: widget.category,
    questions: widget.playItems.map((item) => item.original).toList(),
  ));
}
```

Daftar soal dibangun ulang dari `playItems` — setiap item menyimpan `original`-nya. Navigasi dilakukan memakai `context` **halaman hasil sendiri**.

> Ini penting dan pernah jadi bug: sebelumnya halaman hasil menerima callback `onRestart` yang dibuat di `QuizPlayPage` dan menangkap `context` milik halaman itu. Karena halaman soal sudah di-`pushReplacement` (dilepas dari tree), context-nya mati, dan menekan "Ulangi" melempar *"This widget has been unmounted, so the State no longer has a context"*. Solusinya bukan menambal dengan cek `mounted`, melainkan menghapus callback-nya sama sekali sehingga navigasi dilakukan oleh halaman yang masih hidup.

**Tombol "Menu Kuis"** cukup `Navigator.pop(context)` — kembali ke `QuizPage`.

### 8.14 `profile_page.dart`

Tab Profil. Isinya satu tombol logout:

```dart
onPressed: () async {
  final messenger = ScaffoldMessenger.of(context);
  await PreferenceHandler.logOut();
  if (!context.mounted) return;
  messenger.clearSnackBars();
  context.pushAndRemoveAll(const LoginPage());
  messenger.showSnackBar(const SnackBar(content: Text("Berhasil Logout")));
}
```

Urutannya: hapus sesi → pindah ke login sambil membuang seluruh riwayat → tampilkan pesan. Karena `messenger` diambil sebelum navigasi, pesannya tetap muncul di halaman login.

### 8.15 Panel Admin

Panel hanya bisa dicapai bila `_isAdmin` bernilai true — `MainPage` memberi `drawer:` bernilai `null` untuk pengguna biasa, sehingga menunya benar-benar tidak ada.

#### `admin_drawer.dart`

Dua menu: **Manage Quiz** dan **Manage Konten Utama**. Keduanya berpola:

```dart
onTap: () {
  Navigator.pop(context);              // tutup drawer dulu
  context.push(const AdminManageQuizPage());
}
```

Menutup drawer sebelum berpindah supaya saat kembali, drawer tidak masih terbuka.

#### `manage_content_page.dart` — CRUD Sejarah & Budaya

```dart
class _AdminManageContentPageState extends State<AdminManageContentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() { _tabController = TabController(length: 2, vsync: this); ... }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }
```

`SingleTickerProviderStateMixin` menyediakan `vsync` — sinkronisasi animasi dengan refresh layar supaya animasi tab tidak berjalan saat halaman tak terlihat (hemat baterai). `with` adalah cara Dart menempelkan *mixin*.

**Form Sejarah** berisi ID tag, tanggal key, urutan, judul, subtitle, ringkasan, pemilih gambar, dan **editor timeline**. Item timeline dikelola sebagai list lokal:

```dart
List<TimelineItemModel> timelineItems = isEditing ? List.from(sejarahToEdit.alurPeristiwa) : [contoh];
```

- Menambah: `_showTimelineItemDialog(... onSave: (newItem) => setModalState(() => timelineItems.add(newItem)))`
- Menghapus: `setModalState(() => timelineItems.removeAt(idx))`
- Menyimpan: seluruh list masuk ke `SejarahModel.alurPeristiwa`, lalu di-`jsonEncode` oleh repository.

`_showTimelineItemDialog` memakai parameter `required ValueChanged<TimelineItemModel> onSave` — **callback**. Dialog tidak tahu apa yang akan dilakukan dengan hasilnya; ia hanya memanggil `onSave(item)`, dan pemanggilnya yang memutuskan (menambah atau mengganti). Ini membuat satu dialog bisa dipakai untuk "tambah" maupun "edit".

**Form Budaya** memakai kontrol yang lebih ketat:

```dart
String selectedJenis = (isEditing ? kategoriByKode(budayaToEdit.jenis) : null)?.kode
    ?? budayaKategoriList.first.kode;
bool isDestinasi = isEditing ? budayaToEdit.isDestinasi : false;

void syncKodeTag() {
  kodeTagController.text = buatKodeTagBudaya(
    jenis: selectedJenis,
    urutan: int.tryParse(urutanController.text.trim()) ?? 1,
    isDestinasi: isDestinasi,
  );
}
```

- **Dropdown kategori** — hanya 8 pilihan resmi, tidak bisa mengetik bebas. `onChanged` memanggil `setModalState(() { selectedJenis = val; syncKodeTag(); })`.
- **Switch "Juga tempat wisata (Destinasi)"** — `SwitchListTile.adaptive` (tampil ala Material di Android, ala iOS di iPhone). Mengubahnya menambah/menghapus akhiran `-D` lewat `syncKodeTag()`.
- **ID Tag** `readOnly: true` — selalu diturunkan otomatis dari kategori + urutan + status destinasi.
- **Kategori Label** ditampilkan sebagai teks saja, diisi otomatis `kategoriByKode(selectedJenis)?.label`.

Saat disimpan:

```dart
if (isEditing) {
  await _budayaRepository.updateBudaya(model, previousKodeTag: budayaToEdit.kodeTag);
} else {
  await _budayaRepository.tambahBudaya(model);
}
await _loadAllData();
if (modalCtx.mounted) Navigator.pop(modalCtx);
```

`previousKodeTag` dioper supaya baris yang benar ditemukan dan bookmark ikut dipindahkan bila ID tag berubah.

Tombol tambah memakai `FloatingActionButton` yang aksinya bergantung tab aktif — membuka form sejarah atau form budaya.

#### `manage_quiz_page.dart` — CRUD Tema Kuis

Soal-soal dikelompokkan per tema dengan pola `putIfAbsent` yang sama, lalu disaring berdasarkan kategori terpilih dan kata kunci pencarian.

| Aksi | Apa yang sebenarnya terjadi di database |
|---|---|
| **Buat Tema Kuis** | `tambahQuiz()` — sebuah tema "lahir" bersama soal pertamanya, karena tema hanyalah nilai kolom |
| **Edit Tema** | `updateThemeInfo(oldTema:, newTema:, newKategori:, newCoverImage:)` — satu UPDATE untuk semua soal bertema itu |
| **Hapus Tema** | `deleteQuizzesByTema(tema)` — DELETE semua soal bertema itu |
| **Kelola Soal** | Membuka `AdminQuizThemeDetailPage` |

Dialog hapus memberi peringatan jumlah: `'Seluruh ${group.questions.length} soal dalam tema "${group.tema}" akan dihapus permanen.'`

#### `admin_quiz_theme_detail_page.dart` — CRUD Soal

Menerima `tema` dan `kategori` lewat konstruktor, lalu `getQuizByTema(widget.tema)`.

Form soal berisi: pertanyaan, 4 pilihan jawaban, penanda jawaban benar (`selectedCorrectIndex`), gambar opsional, dan penjelasan. Saat disimpan:

```dart
final model = QuizSQLModel(
  id: isEditing ? questionToEdit.id : null,   // id null = baris baru
  kategori: widget.kategori, tema: widget.tema,
  soal: ..., daftarJawaban: answers, jawabanBenar: selectedCorrectIndex,
  gambar: ..., penjelasan: ...,
);
success = isEditing ? await _quizRepository.updateQuiz(model)
                    : await _quizRepository.tambahQuiz(model);
```

`kategori` dan `tema` diambil dari halaman, bukan diketik ulang — mencegah soal "nyasar" ke tema lain.

#### `app_image_picker_widget.dart` — pemilih gambar

`StatelessWidget` dengan callback `ValueChanged<String?> onImageSelected`. Ia tidak menyimpan gambar; ia hanya melaporkan path terpilih ke form pemanggil.

Tiga cara memilih:

1. **Galeri Aset** — daftar `defaultAssets` (9 gambar bawaan) dalam `GridView`.
2. **Galeri perangkat** — lewat `image_picker`.
3. **Path manual** — mengetik path file secara langsung.

Alur izin galeri:

```dart
Future<bool> _requestGalleryPermission(BuildContext context) async {
  try {
    PermissionStatus status = await Permission.photos.request();
    if (!status.isGranted && !status.isLimited) {
      status = await Permission.storage.request();
    }
    if (status.isPermanentlyDenied) { _showPermissionDialog(...); return false; }
    return true;
  } catch (_) { return true; }
}
```

- `Permission.photos` untuk Android 13+ / iOS; bila gagal, dicoba `Permission.storage` untuk Android lama.
- `isLimited` = izin sebagian (iOS: user hanya memilih beberapa foto) — tetap dianggap boleh.
- `isPermanentlyDenied` = user memilih "jangan tanya lagi"; aplikasi tidak bisa meminta ulang, jadi ditampilkan dialog dengan tombol **`openAppSettings()`** yang membuka halaman pengaturan aplikasi.
- `catch (_) => true` supaya di platform yang tidak butuh izin (desktop) alurnya tidak terhambat.

Pengambilan gambar:

```dart
final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
if (image != null) { onImageSelected(image.path); Navigator.pop(context); }
```

`imageQuality: 85` mengompres agar file tidak terlalu besar. Yang disimpan ke database hanyalah **path**-nya (string), bukan isi gambarnya — itulah sebabnya `AppImageView` perlu mengecek `File(path).existsSync()`.

---

## 9. Ringkasan Operasi CRUD

| Entitas | CREATE | READ | UPDATE | DELETE |
|---|---|---|---|---|
| **User** | `userRegister()` ← RegisterPage | `loginUser()` ← LoginPage | – | – |
| **Sejarah** | `tambahSejarah()` ← form admin | `getAllSejarah`, `getSejarahHariIni`, `getSejarahByKodeTag`, `getRandomSejarahList` | `updateSejarah()` | `deleteSejarah()` (+ bersihkan bookmark) |
| **Budaya** | `tambahBudaya()` ← form admin | `getAllBudaya`, `getBudayaHariIni`, `getBudayaByJenis`, `getBudayaGroupedByJenis`, `getDestinasiList`, `getDestinasiCount`, `getBudayaByKodeTag`, `getRandomBudayaList` | `updateBudaya()` | `deleteBudaya()` (+ bersihkan bookmark) |
| **Quiz** | `tambahQuiz()` ← form tema & form soal | `getAllQuizzes`, `getQuizByTema`, `getRandomQuizzesByCategory`, `getQuizCountByKategori` | `updateQuiz()`, `updateThemeInfo()` | `deleteQuiz()`, `deleteQuizzesByTema()` |
| **Bookmark** | `addBookmark()` ← tombol bookmark | `isBookmarked`, `getAllBookmarks` | – (tidak ada yang bisa diubah) | `removeBookmark()` |

Empat operasi SQL dasar yang dipakai `sqflite`:

| Method sqflite | SQL | Nilai balik |
|---|---|---|
| `db.insert(tabel, map)` | `INSERT INTO` | id baris baru (int) |
| `db.query(tabel, where:, whereArgs:, orderBy:, limit:)` | `SELECT` | `List<Map<String, dynamic>>` |
| `db.update(tabel, map, where:, whereArgs:)` | `UPDATE` | jumlah baris terpengaruh |
| `db.delete(tabel, where:, whereArgs:)` | `DELETE` | jumlah baris terhapus |
| `db.rawQuery(sql, args)` / `db.rawUpdate(sql, args)` | SQL bebas | untuk kasus yang tidak tertangani method di atas |

Pola pelaporan hasil yang konsisten: method CREATE/UPDATE/DELETE mengembalikan `bool` (`id > 0` atau `count > 0`) atau `int`, yang lalu dipakai UI untuk memilih pesan sukses/gagal.

---

## 10. Logika Kunci Dijelaskan Mendalam

### 10.1 Bagaimana "Sejarah Hari Ini" mencocokkan tanggal

```dart
Future<SejarahModel> getSejarahHariIni() async {
  final list = await getAllSejarah();
  final now = DateTime.now();
  final dayStr = now.day.toString().padLeft(2, '0');      // 5  → "05"
  final monthStr = now.month.toString().padLeft(2, '0');  // 8  → "08"
  final todayPrefix = '$dayStr$monthStr';                 // → "0508"

  try {
    return list.firstWhere(
      (s) => s.tanggalKey.startsWith(todayPrefix) && s.urutan == 1,
    );
  } catch (_) {
    return list.isNotEmpty ? list.first : defaultSejarahList.first;
  }
}
```

Langkah demi langkah:

1. Setiap data sejarah punya `tanggalKey` berformat **ddMMyy**, misalnya Proklamasi = `'170845'` (17 Agustus 1945).
2. `DateTime.now()` memberi tanggal perangkat saat ini.
3. `now.day` bertipe int, jadi tanggal 5 menghasilkan `"5"` — bukan `"05"`. **`padLeft(2, '0')`** menambal nol di depan hingga panjangnya 2 karakter. Tanpa ini, 5 Agustus akan menghasilkan prefix `"58"` dan tidak akan pernah cocok dengan apa pun.
4. Hari dan bulan digabung jadi `todayPrefix`, misalnya `"1708"`.
5. **`startsWith(todayPrefix)`** membandingkan hanya bagian **ddMM**, mengabaikan **yy**. Inilah intinya: peristiwa tahun 1945 tetap cocok setiap tanggal 17 Agustus, tahun berapa pun sekarang. Kalau dibandingkan penuh (`tanggalKey == ...`), sorotan hanya akan muncul sekali seumur hidup.
6. **`&& s.urutan == 1`** memastikan yang diambil adalah sorotan utama, bila satu tanggal punya beberapa peristiwa.
7. **`firstWhere`** mengembalikan elemen pertama yang cocok, dan **melempar `StateError` bila tidak ada satu pun**. Karena itu ia dibungkus `try/catch`.
8. Cadangan bertingkat: item pertama database, atau — bila database benar-benar kosong — item pertama data seed. Beranda tidak pernah tampil hampa.

### 10.2 Bagaimana "Budaya Hari Ini" tetap acak tapi tidak berubah saat refresh

```dart
Future<BudayaModel> getBudayaHariIni() async {
  final list = await getAllBudaya();
  if (list.isEmpty) return defaultBudayaList.first;

  final pool = List<BudayaModel>.from(list)..sort((a, b) => a.kodeTag.compareTo(b.kodeTag));
  final now = DateTime.now();
  final benihHariIni = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch
      ~/ Duration.millisecondsPerDay;
  return pool[Random(benihHariIni).nextInt(pool.length)];
}
```

Kuncinya ada pada **benih (seed)** generator acak:

- `Random()` tanpa argumen menghasilkan urutan berbeda setiap kali dibuat. Itu yang dulu dipakai, dan itulah kenapa sorotan berubah tiap kali beranda dimuat ulang.
- `Random(benih)` dengan benih yang sama **selalu** menghasilkan urutan angka yang sama persis. Acak, tapi dapat diulang.
- `DateTime(now.year, now.month, now.day)` membuang jam/menit/detik sehingga seluruh hari punya nilai sama.
- `.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay` mengubahnya jadi "nomor hari" sejak 1 Januari 1970. Nilai ini tetap sepanjang hari dan bertambah 1 setiap tengah malam.

Hasilnya: pilihan terasa acak, tidak berubah walau di-refresh berkali-kali atau aplikasi ditutup-buka, dan berganti sendiri keesokan harinya.

Kenapa daftarnya diurutkan dulu? Karena `getAllBudaya()` mengurutkan `id DESC`. Bila admin menambah satu data budaya, seluruh posisi indeks bergeser dan sorotan hari itu ikut berubah di tengah hari. Mengurutkan berdasarkan `kodeTag` membuat urutannya stabil.

### 10.3 Bagaimana pilihan jawaban kuis diacak tanpa merusak kunci jawaban

Masalahnya: database menyimpan jawaban benar sebagai **indeks** (`jawabanBenar: 0`). Kalau pilihan diacak tapi indeksnya tidak, jawaban benar jadi salah tempat.

Solusinya tiga langkah:

```dart
// 1. Ambil TEKS jawaban benar sebelum diacak
final String correctText = q.daftarJawaban[q.jawabanBenar];

// 2. Acak salinan daftar pilihan
final List<String> options = List<String>.from(q.daftarJawaban)..shuffle();

// 3. Cari lagi di mana teks itu sekarang berada
final int newCorrectIndex = options.indexOf(correctText);
```

Teks jawaban dijadikan "jangkar" yang tidak berubah. Setelah pengacakan, `indexOf` menemukan posisi barunya. Nilai itu disimpan di `correctShuffledIndex` dan dipakai `isCorrect`.

Pengaman di sepanjang jalan:

- `q.jawabanBenar < q.daftarJawaban.length` — melindungi dari data rusak yang indeksnya melebihi jumlah pilihan.
- `newCorrectIndex >= 0 ? newCorrectIndex : 0` — `indexOf` mengembalikan `-1` bila tidak ketemu (mustahil, kecuali ada duplikasi aneh); dijatuhkan ke 0 agar tidak crash.
- `List.from(...)` menyalin dulu, sehingga `daftarJawaban` milik model asli tidak ikut teracak.

### 10.4 Bagaimana bookmark dipisah per akun

Skema `bookmark` punya `UNIQUE(userEmail, kodeTag)` — pasangan, bukan satu kolom. Artinya user A dan user B boleh sama-sama menyimpan `BUD-RMH-1-D`, tapi satu user tidak bisa menyimpannya dua kali.

Setiap operasi menyertakan pemiliknya:

```dart
where: 'kodeTag = ? AND userEmail = ?', whereArgs: [kodeTag, _currentUserEmail]
```

**Klaim data lama.** Bookmark dari versi aplikasi sebelumnya tidak punya pemilik (`userEmail` diisi `''` saat migrasi). Agar tidak hilang:

```dart
Future<Database> _db() async {
  final db = await _dbHelper.database;
  if (!_legacyClaimed) {
    _legacyClaimed = true;
    final email = _currentUserEmail;
    if (email.isNotEmpty) {
      await db.rawUpdate("UPDATE OR IGNORE bookmark SET userEmail = ? WHERE userEmail = ''", [email]);
    }
  }
  return db;
}
```

`_legacyClaimed` bertipe `static` sehingga hanya dijalankan sekali per proses aplikasi. `OR IGNORE` mencegah error bila klaim menghasilkan pasangan ganda.

### 10.5 Bagaimana ID tag menandai destinasi

Alih-alih menambah kolom `isDestinasi` di database, statusnya dititipkan pada akhiran ID tag:

```
BUD-RMH-1     → koleksi budaya biasa
BUD-RMH-1-D   → koleksi budaya yang juga tempat wisata
```

- Pembacaan: `bool get isDestinasi => kodeTag.trim().toUpperCase().endsWith('-D');`
- Penulisan: `buatKodeTagBudaya(jenis:, urutan:, isDestinasi:)`
- Penyaringan: `list.where((b) => b.isDestinasi)`

Keuntungannya: tidak ada kolom baru yang perlu dimigrasi, dan statusnya terbaca langsung dari ID tag yang tampil di layar. Konsekuensinya: ID tag tidak boleh diketik bebas — karena itulah field-nya dibuat `readOnly` dan selalu dihasilkan otomatis oleh form admin.

---

## 11. Kamus Fungsi & Idiom

### Siklus hidup widget

| Istilah | Arti |
|---|---|
| `StatelessWidget` | Widget tanpa state; digambar ulang hanya bila induknya berubah |
| `StatefulWidget` + `State` | Widget yang punya data berubah; `State` bertahan walau widget dibangun ulang |
| `initState()` | Dipanggil sekali saat State dibuat. Tempat memuat data awal |
| `build()` | Dipanggil setiap kali perlu menggambar. Harus cepat & bebas efek samping |
| `dispose()` | Dipanggil sekali saat State dibuang. Tempat `cancel()`/`dispose()` controller |
| `setState(() {...})` | Mengubah data **dan** memberi tahu Flutter untuk menggambar ulang |
| `mounted` | `true` selama State masih terpasang. Selalu dicek setelah `await` |
| `widget.xxx` | Mengakses properti StatefulWidget dari dalam class State |

### Async

| Istilah | Arti |
|---|---|
| `Future<T>` | Janji nilai bertipe T yang tersedia nanti |
| `async` | Menandai fungsi yang boleh memakai `await` |
| `await` | Menunggu Future selesai tanpa membekukan tampilan |
| `try / catch (_)` | Menangkap error; `_` berarti objek error-nya tidak dipakai |
| `finally` | Blok yang selalu dijalankan, sukses maupun gagal |

### Operator Dart

| Operator | Arti | Contoh di proyek |
|---|---|---|
| `?` (tipe) | Boleh null | `BudayaModel? budaya` |
| `??` | Nilai cadangan bila null | `onBack ?? () => context.pop()` |
| `?.` | Akses aman; null bila objeknya null | `sejarah?.judul` |
| `!` | Jaminan tidak null | `_formKey.currentState!` |
| `..` | Cascade — kembalikan objeknya, bukan hasil method | `List.from(x)..shuffle()` |
| `...` | Spread — sisipkan banyak elemen | `...List.generate(...)` |
| `~/` | Pembagian bulat | `totalSeconds ~/ 60` |
| `%` | Sisa bagi | `totalSeconds % 60` |
| `late` | Diisi belakangan sebelum dipakai | `late SharedPreferences _prefs` |

### Method koleksi

| Method | Fungsi |
|---|---|
| `.map((e) => ...)` | Ubah tiap elemen jadi bentuk lain |
| `.where((e) => ...)` | Saring elemen yang memenuhi syarat |
| `.firstWhere((e) => ...)` | Elemen pertama yang cocok; **error** bila tidak ada |
| `.any((e) => ...)` | `true` bila ada minimal satu yang cocok |
| `.toList()` | Ubah hasil `map`/`where` jadi List |
| `.sort((a,b) => a.x.compareTo(b.x))` | Urutkan naik |
| `.shuffle()` | Acak urutan |
| `.indexOf(nilai)` | Posisi nilai; `-1` bila tidak ada |
| `.putIfAbsent(k, () => [])` | Ambil nilai kunci, buat bila belum ada |
| `.padLeft(2, '0')` | Tambal karakter di depan string |

### Widget layout yang sering muncul

| Widget | Fungsi |
|---|---|
| `Column` / `Row` | Susun vertikal / horizontal |
| `Stack` + `Positioned` | Tumpuk widget; posisikan bebas |
| `Expanded` | Isi sisa ruang dalam Row/Column |
| `Flexible` | Boleh menyusut agar tidak meluber |
| `SizedBox` | Kotak berukuran tetap; juga dipakai sebagai jarak |
| `Padding` | Jarak dalam |
| `Container` | Gabungan padding + margin + dekorasi |
| `AspectRatio` | Kunci rasio lebar:tinggi |
| `ConstrainedBox` | Batasi ukuran, mis. `maxWidth: 800` agar rapi di layar lebar |
| `SingleChildScrollView` | Buat isi bisa digulir |
| `ListView.builder` / `.separated` | Daftar yang membangun item sesuai kebutuhan |
| `AnimatedContainer` | Container yang menganimasikan perubahan propertinya |
| `GestureDetector` | Menangkap sentuhan pada widget apa pun |
| `InkWell` | Sentuhan + efek riak (butuh `Material` di atasnya) |

### Interaksi & umpan balik

| Elemen | Fungsi |
|---|---|
| `ScaffoldMessenger.of(context).showSnackBar(...)` | Pesan singkat di bawah layar |
| `.clearSnackBars()` | Hapus pesan yang masih tampil agar tidak menumpuk |
| `showDialog<T>(...)` | Dialog tengah layar; `T` = tipe nilai balik |
| `showModalBottomSheet(...)` | Panel dari bawah layar |
| `StatefulBuilder` + `setModalState` | State lokal untuk isi dialog/sheet |
| `RefreshIndicator` | Gestur tarik-untuk-menyegarkan |
| `PopScope` | Mengontrol/menahan aksi tombol back |
| `MediaQuery.of(ctx).viewInsets.bottom` | Tinggi keyboard, untuk mendorong isi ke atas |

### Database

| Istilah | Arti |
|---|---|
| `?` + `whereArgs` | Parameter terikat; mencegah SQL injection |
| `ConflictAlgorithm.replace` | Bila bentrok UNIQUE, timpa baris lama |
| `ORDER BY RANDOM()` | Acak urutan hasil di sisi SQLite |
| `PRAGMA table_info(t)` | Lihat daftar kolom sebuah tabel |
| `db.transaction` | Beberapa perintah jadi satu kesatuan; gagal satu, batal semua |
| `jsonEncode` / `jsonDecode` | Objek Dart ⇄ teks JSON, untuk menyimpan list di satu kolom |

---

## 12. Contoh Alur Data End-to-End

### Contoh A: User menekan ikon bookmark di halaman detail budaya

```
1. DetailTopBar        onTap → onBookmarkToggle()
2. DetailBudayaPage    _bookmarkRepository.toggleBookmark('budaya', data.kodeTag)
3. BookmarkRepository  isBookmarked(kodeTag)
                         └─ SELECT * FROM bookmark WHERE kodeTag=? AND userEmail=?
4.                     belum ada → addBookmark('budaya', kodeTag)
                         └─ INSERT INTO bookmark (userEmail, itemType, kodeTag, createdAt)
5.                     mengembalikan true
6. DetailBudayaPage    setState(() => _isBookmarked = true)   → ikon jadi terisi
7.                     showSnackBar('Berhasil disimpan ke Bookmark')
```

Saat halaman Bookmark dibuka kemudian:

```
8. BookmarkPage        _bookmarkRepository.getAllBookmarks()
9. BookmarkRepository  SELECT * FROM bookmark WHERE userEmail=? ORDER BY id DESC
10.                    untuk tiap baris → BudayaRepository.getBudayaByKodeTag(kodeTag)
11.                    gabungkan jadi BookmarkItemModel(budaya: ...)
12. BookmarkPage       ListView menampilkan item.title, item.description, item.imagePath
```

### Contoh B: Admin menambah koleksi budaya baru

```
1. AdminDrawer            "Manage Konten Utama" → context.push(AdminManageContentPage())
2. AdminManageContentPage FloatingActionButton (tab Budaya) → _showBudayaFormDialog()
3. Form                   pilih kategori 'PKN' → syncKodeTag() → ID tag jadi "BUD-PKN-1"
4.                        aktifkan switch destinasi → ID tag jadi "BUD-PKN-1-D"
5.                        pilih gambar → AppImagePickerWidget → onImageSelected(path)
6. Tombol "Tambah Budaya" formKey.currentState!.validate()
7.                        buat BudayaModel(kodeTag: buatKodeTagBudaya(...), jenis:'PKN',
                             kategoriLabel: kategoriByKode('PKN')!.label, ...)
8. BudayaRepository       tambahBudaya(model) → INSERT INTO budaya
9. AdminManageContentPage _loadAllData() → daftar diperbarui
10.                       Navigator.pop(modalCtx) → sheet ditutup
11.                       showSnackBar('Data budaya baru berhasil ditambahkan!')
```

Dampaknya di beranda tanpa kode tambahan:

```
12. KoleksiBudayaList     getBudayaGroupedByJenis() → kartu "Pakaian Adat" kini "1 koleksi"
13. PilihanDestinasiList  getDestinasiList() → item baru ikut muncul (karena -D)
14. KoleksiKategoriPage   getBudayaByJenis('PKN') → tampil di daftar kategori itu
```

### Contoh C: User mengerjakan kuis kategori Sejarah

```
1. QuizPage        tap kartu "Sejarah" → _showCategoryQuizModal('Sejarah')
2. QuizRepository  getQuizCountByKategori('Sejarah') → "Total bank soal: 12 soal"
3. Modal           user pilih chip "10 Soal" → setModalState
4. Tombol Mulai    Navigator.pop(modalCtx)
5. QuizRepository  getRandomQuizzesByCategory('Sejarah', 10)
                     └─ SELECT ... WHERE UPPER(kategori)=? ORDER BY RANDOM() LIMIT 10
6. QuizPage        context.push(QuizPlayPage(questions: ...))
7. QuizPlayPage    _setupQuestions() → acak opsi + hitung ulang indeks benar
8.                 _startTimer() → Timer.periodic tiap detik
9.                 user menjawab → _selectAnswer() → warna & pembahasan muncul
10.                soal terakhir → _finishQuiz() → hitung benar/salah, timer dibatalkan
11.                context.pushReplacement(QuizResultPage(...))
12. QuizResultPage hitung persentase → tentukan tier umpan balik
13.                "Ulangi Kuis" → _restartQuiz() → pushReplacement(QuizPlayPage) dengan
                     soal yang sama dari playItems.map((i) => i.original)
```

---

## 13. Keterbatasan yang Diketahui

Hal-hal berikut disadari dan belum dikerjakan:

1. **Tab "Jelajah" dan "Peta" belum ada.** `main_page.dart` mengembalikan `HomePage` yang sama untuk indeks 0, 1, dan 2.
2. **Password disimpan apa adanya** di tabel `user`. Disengaja untuk tahap pengembangan; rencananya digantikan Firebase Authentication yang menangani kredensial di sisi server. Yang sudah diamankan: password tidak ikut tersimpan di SharedPreferences (`user.sanitized()`).
3. **Hak admin berbasis daftar nama** (`admin1`, `admin2`) di `user_model.dart`. Karena kolom `nama` tidak unik, siapa pun bisa mendaftar dengan nama itu sebelum akun aslinya dibuat. Penutupan sesungguhnya nanti lewat *custom claims* Firebase + Security Rules; menyembunyikan menu di UI bukan pengamanan.
4. **Penyaringan dilakukan di memori**, bukan lewat `WHERE` SQL, pada `getBudayaByJenis`, `getDestinasiList`, dan sejenisnya. Aman untuk puluhan baris; perlu ditinjau bila datanya membesar.
5. **Tombol share** di `DetailTopBar` dan tombol "Mulai Melestarikan" pada banner belum punya aksi.
6. **Gambar dari galeri disimpan sebagai path**, bukan disalin ke folder aplikasi. Bila file aslinya dihapus pengguna, `AppImageView` akan menampilkan gambar cadangan.

---

*Dokumen ini menggambarkan kode pada kondisi terakhir setelah pembersihan struktur dan penghapusan kode mati.*
