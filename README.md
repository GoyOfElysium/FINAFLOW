# FinaFlow - Aplikasi Pengelolaan Keuangan Digital

> Rancangan Aplikasi Web Pengelolaan Keuangan Digital  
> Program Studi Multimedia – Politeknik Negeri Media Kreatif Jakarta, 2026

---

## 📱 Deskripsi

**FinaFlow** adalah aplikasi Flutter untuk manajemen keuangan digital yang dirancang khusus bagi **freelancer**, **pekerja kreatif**, dan **agensi digital**. Aplikasi ini menyederhanakan pencatatan arus kas, pemantauan anggaran, dan analisis finansial dengan antarmuka Clean UI berwarna ungu khas FinaFlow.

---

## 🗂️ Struktur Proyek

```
lib/
├── main.dart                        # Entry point + Splash Screen
├── theme/
│   └── app_theme.dart               # Tema & warna ungu FinaFlow
├── models/
│   ├── transaction_model.dart       # Model transaksi & kategori
│   └── budget_model.dart            # Model anggaran & status
├── providers/
│   └── finance_provider.dart        # State management (ChangeNotifier)
├── widgets/
│   └── currency_formatter.dart      # Format Rupiah & tanggal
└── screens/
    ├── auth/
    │   ├── login_screen.dart        # Halaman Login
    │   └── register_screen.dart     # Halaman Registrasi
    ├── main_screen.dart             # Bottom Navigation (4 tab)
    ├── dashboard/
    │   └── dashboard_screen.dart    # Dashboard + Line Chart + notifikasi
    ├── transaction/
    │   ├── transaction_screen.dart  # Daftar transaksi + filter
    │   └── add_transaction_screen.dart  # Form tambah transaksi
    ├── budget/
    │   └── budget_screen.dart       # Anggaran + progress bar + warning
    └── report/
        └── report_screen.dart       # Laporan + Pie Chart + Bar Chart
```

---

## ✅ Fitur (sesuai Use Case Diagram & Flowchart)

| Use Case | Implementasi |
|----------|-------------|
| **Login** | `login_screen.dart` – validasi email & password |
| **Registrasi** | `register_screen.dart` – pilihan peran (Freelancer, dll) |
| **Lihat Dashboard** | `dashboard_screen.dart` – saldo, ringkasan bulan ini, grafik 6 bulan, transaksi terbaru |
| **Kelola Transaksi** | `add_transaction_screen.dart` – form input dengan selection controls kategori, tag proyek, tanggal |
| **Kelola Anggaran** | `budget_screen.dart` – tetapkan budget per kategori, progress bar, warning otomatis |
| **Notifikasi Peringatan** | Banner merah/kuning otomatis saat budget ≥75% atau melebihi batas |
| **Akses Laporan** | `report_screen.dart` – pie chart pengeluaran per kategori + bar chart 6 bulan |
| **Keluar Aplikasi** | Tombol logout di dashboard dengan konfirmasi dialog |

---

## 🚀 Cara Menjalankan

### 1. Prasyarat
```bash
flutter --version  # Flutter 3.x atau lebih baru
```

### 2. Install dependensi
```bash
flutter pub get
```

### 3. Jalankan aplikasi
```bash
flutter run
```

### 4. Build APK (Android)
```bash
flutter build apk --release
```

---

## 📦 Dependencies

| Package | Fungsi |
|---------|--------|
| `provider ^6.1.2` | State management |
| `fl_chart ^0.68.0` | Line chart, Bar chart, Pie chart |
| `intl ^0.19.0` | Format mata uang IDR & tanggal Indonesia |
| `uuid ^4.4.0` | Generate ID unik transaksi & anggaran |
| `shared_preferences ^2.2.3` | Local storage (opsional untuk persistence) |
| `google_fonts ^6.2.1` | Tipografi modern |

---

## 🎨 Desain

- **Warna utama**: Ungu (#6B21A8) sesuai logo FinaFlow
- **Prinsip**: Clean UI, intuitive UX (tidak perlu latar belakang akuntansi)
- **Format mata uang**: Rupiah (Rp) dengan locale `id_ID`
- **Kategori**: Freelance, Proyek, Konsultasi, Operasional, Software/Tools, Marketing, Transportasi, dll.

---

## 👥 Tim Pengembang

| Nama | NIM |
|------|-----|
| Mohamad Azmi Nurfaiz | 2490343078 |
| Rafi Putra Ramadhan | 2490343124 |
| Ryan Prasetyo | 2490343142 |

---

*Program Studi Multimedia – Politeknik Negeri Media Kreatif Jakarta, 2026*
