import 'package:intl/intl.dart';

abstract final class AppFormatters {
  static final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
  static final _date = DateFormat('MMM d, yyyy');
  static final _dateTime = DateFormat('MMM d, yyyy • HH:mm');
  static final _relative = DateFormat('MMM d');

  static String currency(double amount, {String? symbol}) {
    if (symbol != null) {
      return NumberFormat.currency(symbol: symbol, decimalDigits: 0)
          .format(amount);
    }
    return _currency.format(amount);
  }

  static String date(DateTime date) => _date.format(date);

  static String dateTime(DateTime date) => _dateTime.format(date);

  static String relative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return _relative.format(date);
  }
}
