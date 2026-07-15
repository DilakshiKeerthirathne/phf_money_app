import 'package:intl/intl.dart';

import '../../features/settings/data/currency_storage.dart';

class AppFormatters {
  AppFormatters._();

  static String currency(double amount) {
    final symbol = CurrencyStorage().getCurrency();

    return NumberFormat.currency(
      symbol: '$symbol ',
      decimalDigits: 2,
    ).format(amount);
  }

  static String date(DateTime date) {
    return DateFormat(
      'dd MMM yyyy',
    ).format(date);
  }
}
