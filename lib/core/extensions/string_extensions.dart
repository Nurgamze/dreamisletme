import 'dart:convert';

import 'package:crypto/crypto.dart';

extension StringExtensions on String {
  String get turkishClean =>
      replaceAll("I", "i").
      replaceAll("ı", "i").
      replaceAll("Ü", "u").
      replaceAll("ü", "u").
      replaceAll("Ş", "s").
      replaceAll("ş", "s").
      replaceAll("Ç", "c").
      replaceAll("ç", "c").
      replaceAll("Ğ", "g").
      replaceAll("ğ", "g").
      replaceAll("Ö", "o").
      replaceAll("ö", "o");

  String get convertMD5 => md5.convert(utf8.encode(this)).toString();
}