import 'package:intl/intl.dart';

class MoneyFormat {
  static final _aud = NumberFormat.currency(locale: 'en_AU', symbol: '\$');

  static String aud(double amount) => _aud.format(amount);
}
