class ErrorFormatter {
  static String format(dynamic error) {
    if (error == null) return 'Terjadi kesalahan yang tidak diketahui.';

    final message = error.toString().toLowerCase();

    if (message.contains('invalid login credentials')) {
      return 'Email atau password salah. Silakan periksa kembali.';
    }
    if (message.contains('user already registered')) {
      return 'Email ini sudah terdaftar. Silakan gunakan email lain atau masuk.';
    }
    if (message.contains('password should be at least 6 characters') ||
        message.contains('weak_password')) {
      return 'Kata sandi terlalu lemah. Gunakan minimal 6 karakter.';
    }
    if (message.contains('email not confirmed') ||
        message.contains('email_not_confirmed')) {
      return 'Email Anda belum dikonfirmasi. Silakan periksa kotak masuk atau spam email Anda.';
    }
    if (message.contains('invalid email')) {
      return 'Format email tidak valid. Pastikan penulisan email sudah benar.';
    }
    if (message.contains('network') ||
        message.contains('socketexception') ||
        message.contains('connection refused') ||
        message.contains('handshake') ||
        message.contains('xmlhttprequest') ||
        message.contains('failed host lookup')) {
      return 'Gagal terhubung ke server. Periksa koneksi internet Anda dan coba lagi.';
    }
    if (message.contains('row-level security') ||
        message.contains('violates row-level security') ||
        message.contains('rls')) {
      return 'Akses ditolak. Anda tidak memiliki izin untuk mengelola data ini.';
    }
    if (message.contains('violates unique constraint') ||
        message.contains('duplicate key')) {
      return 'Data tersebut sudah ada di sistem.';
    }
    if (message.contains('violates foreign key constraint') ||
        message.contains('foreign key')) {
      return 'Gagal menyimpan karena data referensi (Kategori atau Proyek) tidak ditemukan.';
    }
    if (message.contains('jwt expired') ||
        message.contains('invalid jwt') ||
        message.contains('invalid_grant')) {
      return 'Sesi Anda telah berakhir. Silakan keluar dan masuk kembali.';
    }

    // Bersihkan nama exception teknis di depan teks pesan
    String cleanMsg = error.toString();
    if (cleanMsg.startsWith('Exception: ')) {
      cleanMsg = cleanMsg.replaceFirst('Exception: ', '');
    } else if (cleanMsg.startsWith('AuthException: ')) {
      cleanMsg = cleanMsg.replaceFirst('AuthException: ', '');
    } else if (cleanMsg.startsWith('PostgrestException: ')) {
      cleanMsg = cleanMsg.replaceFirst('PostgrestException: ', '');
    }

    return cleanMsg;
  }
}
