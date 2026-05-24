import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(double amount) => _formatter.format(amount);

  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return format(amount);
  }
}

class DateFormatter {
  static String formatFull(DateTime date) =>
      DateFormat('dd MMM yyyy', 'id_ID').format(date);

  static String formatMonth(DateTime date) =>
      DateFormat('MMM yyyy', 'id_ID').format(date);

  static String formatShortMonth(DateTime date) =>
      DateFormat('MMM', 'id_ID').format(date);
}
