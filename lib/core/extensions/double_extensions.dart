import 'package:intl/intl.dart';

extension DoubleExtensions on double {
  String get twoDecimalFormat => NumberFormat("#,##0.00").format(this);
}