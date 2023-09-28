import 'dart:convert';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sdsdream_flutter/widgets/Dialoglar.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../GirisYapYeni.dart';
import '../widgets/beautiful_popup/beautiful_popup.dart';

TextStyle headerStyle = TextStyle(color: Colors.white, fontSize: 12);
CustomColumnSizer customColumnSizer = CustomColumnSizer();

SfDataGridThemeData myGridTheme = SfDataGridThemeData(
  headerColor: Color.fromRGBO(235, 90, 12, 1),
  selectionColor: Colors.blue,
  sortIconColor: Colors.white,
);

GridColumn dreamColumn(
    {required columnName,
    required label,
    Alignment alignment = Alignment.center,
    double minWidth = double.nan,
    bool visible = true}) {
  return GridColumn(
      columnName: columnName,
      label: Container(
          child: Text(
            label,
            style: headerStyle,
          ),
          padding: EdgeInsets.only(left: 10, right: 10),
          alignment: alignment),
      minimumWidth: minWidth,
      visible: visible);
}

double toOADate(DateTime date) {
  var msDateObj = (date.millisecondsSinceEpoch / 86400000) + (25569);
  return msDateObj;
}

DateTime fromOADate(int oadate) {
  var date = DateTime.fromMillisecondsSinceEpoch((oadate - 25569) * 86400000);
  return date;
}

dynamic formatValue(dynamic value, {bool formatDort = false}) {
  if (value.runtimeType == double) {
    if (formatDort) {
      return NumberFormat("#,####0.0000").format(value);
    } else {
      return NumberFormat("#,##0.00").format(value);
    }
  } else if (value.runtimeType == DateTime) {
    return DateFormat("dd/MM/yyyy").format(DateTime.parse(value.toString()));
  } else {
    return value;
  }
}

AlignmentGeometry alignValue(dynamic value) {
  if (value.runtimeType == double) {
    return Alignment.centerRight;
  } else if (value.runtimeType == String) {
    return Alignment.centerLeft;
  } else {
    return Alignment.center;
  }
}

String removeAllHtmlTags(String htmlText) {
  RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

  return htmlText.replaceAll(exp, '');
}

class CustomColumnSizer extends ColumnSizer {
  @override
  double computeCellWidth(
      GridColumn column, DataGridRow row, Object? cellValue, TextStyle style) {
    cellValue = formatValue(cellValue);
    return super.computeCellWidth(column, row, cellValue, style);
  }
}

class Subeler {
  static var dbZenitSubelerTuzla = jsonDecode(
      '[{"Tuzla" : "0","Keyap" : "1","Adana" : "2","Bursa" : "3","Antalya" : "4","Ankara" : "5","Konya" : "6","Perpa" :"8",]');
  static List<String> zenitSubelerTuzla = [
    "Tuzla",
    "Keyap",
    "Adana",
    "Bursa",
    "Antalya",
    "Ankara",
    "Konya",
    "Perpa",
  ];
  static List<String> zenitSubelerKodTuzla = [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "8",
  ];

  static var dbZenitSubeler = jsonDecode(
      '[{"Keyap" : "1","Adana" : "2","Bursa" : "3","Antalya" : "4","Ankara" : "5","Konya" : "6", "Perpa" : "8",]');
  static List<String> zenitSubeler = [
    "Keyap",
    "Adana",
    "Bursa",
    "Antalya",
    "Ankara",
    "Konya",
    "Perpa",
  ];
  static List<String> zenitSubelerKod = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "8",
  ];

  static String dbSube(String subeAdi) {
    String subeDbName = "";
    for (var sube in dbZenitSubelerTuzla) {
      if (sube[subeAdi] != null) subeDbName = sube[subeAdi];
    }
    return subeDbName;
  }
}

class UserInfo {
  static int? activeUserId;
  static String? ldapUser = "";
  static String? mikroUserKod = "";
  static String? mikroPersonelKod = "";
  static String? ad = "";
  static String? soyAd = "";
  static bool? isSuperUser = false;
  static bool? isCriticUser = false;
  static bool? isCiroRapor = false;
  static bool? isPortfoyCekRapor = false;
  static bool? isStokSatisKarlilikRapor = false;
  static bool? isButceRapor = false;
  static String? activeDB;
  static String? aktifSubeNo = "1";
  static String? description = "";
  static bool? showDescription = false;
  static int? versisonCode;
  static int? versionMin;
  static String portalUserId = "";
  static String? versionName;
  static bool? force;
  static String? googlePlayId;
  static String? appStoreId;
  static bool fullAccess = false;
  static bool satisDetay = false;
  static bool riskFoyuDonemselBakiye = false;
  static bool alisDetayYetkisi = false;
  static bool onlineHesabimYetkisi = false;
  static bool zenitUretimYetki = false;
}

class TelefonBilgiler {
  static String userDevicePlatform = "";
  static String userDeviceInfo = "";
  static String userAppVersion = "";
  static String appVersion = "";
  static bool isTablet = false;
}

class Foksiyonlar {
  static String formatMoney(dynamic money) {
    if (money is num) {
      money = money.toStringAsFixed(2);
    }

    return money
        .toString()
        .replaceAllMapped(
            RegExp(r"(\d)(?=(\d{3})+\.)"), (m) => "${m.group(1)}.")
        .replaceAllMapped(RegExp(r"\.(\d+)$"), (m) => ",${m.group(1)}");
  }

  static String turkceTemizle(String value) {
    return value
        .replaceAll("Ş", "S")
        .replaceAll("ş", "s")
        .replaceAll("Ü", "U")
        .replaceAll("ü", "u")
        .replaceAll("İ", "I")
        .replaceAll("ı", "i")
        .replaceAll("Ö", "O")
        .replaceAll("ö", "o")
        .replaceAll("Ğ", "G")
        .replaceAll("ğ", "g")
        .replaceAll("Ç", ",C")
        .replaceAll("ç", "c");
  }

  static String formatDate(String date) {
    String sonuc;
    if (date.contains('T')) {
      sonuc = date.replaceAll("T00:00:00", "");
    } else if (date == null) {
      sonuc = " ";
    } else {
      sonuc = date.replaceAll(" 00:00:00", "");
    }
    return sonuc;
  }

  static Color moneyColor(double money) {
    if (money <= 0) {
      return Colors.red;
    } else {
      return Colors.blue.shade900;
    }
  }

  static Future<bool> internetDurumu(BuildContext context) async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      return true;
    }
    var sonuc = await Connectivity().checkConnectivity();
    if (sonuc == ConnectivityResult.none) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("İnternet Bağlantınızı Kontrol Edin!"),
              actions: <Widget>[
                TextButton(
                  child: Text("Ayarlar"),
                  onPressed: () {
                    //AppSettings.openDataRoamingSettings();//
                  },
                ),
                TextButton(
                  child: Text("Tamam"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
          barrierDismissible: false);
      return false;
    }
    return true;
  }

  static Future<bool?> checkAppEngine(BuildContext context, bool girisMi) async {
    var response = await http.get(Uri.parse("${Sabitler.url}/api/GetUserDatabaseDetails?userId=${UserInfo.activeUserId}&dbName=${UserInfo.activeDB}&platform=${TelefonBilgiler.userDevicePlatform}"),
        headers: {"apiKey": Sabitler.apiKey});
    if (response.statusCode == 200) {
      var yetkiler = jsonDecode(response.body);
      for (var yetki in yetkiler) {
        UserInfo.fullAccess = yetki["FullAccess"];
        UserInfo.satisDetay = yetki["SatisDetay"];
        UserInfo.onlineHesabimYetkisi = yetki["OnlineHesabimYetkisi"];
        UserInfo.zenitUretimYetki = yetki["ZenitUretimYetki"];
        UserInfo.riskFoyuDonemselBakiye = yetki["RiskFoyuveDonemselBakiye"];
        UserInfo.alisDetayYetkisi = yetki["AlisDetayYetkisi"];
        UserInfo.googlePlayId = yetki["GooglePlayId"];
        UserInfo.appStoreId = yetki["AppStoreId"];
        UserInfo.description = yetki["Description"];
        UserInfo.showDescription = yetki["ShowDescription"];
        UserInfo.versisonCode = int.parse(yetki["VersionCode"].toString());
        UserInfo.versionMin = yetki["VersionMin"];
        UserInfo.versionName = yetki["VersionName"];
        UserInfo.force = yetki["force"];
      }
      bool versiyonCheck = false;
      if (girisMi) Navigator.pop(context);
      /*versiyonCheck = (await versiyonKontrol(context)) ?? false;
      if (!versiyonCheck) {
        return true;
      }else{
        return false;
      }*/
      return true;
    } else {
      showDialog(
              context: context,
              builder: (context) => BilgilendirmeDialog(
                  "Kullanıcı hesabınızla tekrar giriş yapmanız gerekmektedir."))
          .then((value) => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => GirisYapSayfasi()),
                (Route<dynamic> route) => false,
              ));
    }
    return false;
  }

  static bool updateMessage = false;
  static Future<bool?> versiyonKontrol(BuildContext context) async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      return true;
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String projeVersiyonCode = packageInfo.buildNumber;
    print(projeVersiyonCode);
    print(UserInfo.versisonCode);
    if (int.parse(projeVersiyonCode) >= UserInfo.versisonCode!) return true;

    if (updateMessage) return true;

    final firstPopup = BeautifulPopup(context: context, template: TemplateTerm);
    firstPopup.recolor(Colors.blue.shade900);
    var message = "Sizler için uygulamamızı sürekli güncelleştiriyoruz.\n" +
        "Yeni özellikleri edinmek ve daha iyi bir SDS B2B İşletme deneyimi için uygulamayı son sürümüne yükseltiniz.";
    if (UserInfo.showDescription!)
      message =
          "Son Geliştirmeler:\n${UserInfo.description}\n--------------------\n" +
              message;
    if (UserInfo.force!) {
      message =
          "Uygulamayı kullanmaya devam edebilmek için güncellemelisiniz.\n--------------------\n" +
              message +
              "\n--------------------\n";
      firstPopup.show(
        title: Text("Güncelleme Gerekli",
            style: GoogleFonts.roboto(
                fontSize: 20,
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold)),
        content: Container(
            child: ListView(
          children: [
            Text(
              message,
              style: GoogleFonts.openSans(
                  fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.start,
            ),
          ],
        )),
        actions: [
          firstPopup.button(
              label: "Şimdi Güncelle",
              onPressed: () {
                StoreRedirect.redirect(
                    androidAppId: UserInfo.googlePlayId,
                    iOSAppId: UserInfo.appStoreId);
              }),
        ],
        barrierDismissible: false,
        close: Container(),
      );
    }

    //Zorunlu tuttugum minimum versiyonun altindaysa
    //Force guncellemeyi indirmeyen, ardindan gelen minor guncellemede zorunlu tutulmayacak. O da buraya yakalanacak.
    if (int.parse(projeVersiyonCode) < UserInfo.versionMin!) {
      firstPopup.show(
        title: Text("Güncelleme Gerekli",
            style: GoogleFonts.roboto(
                fontSize: 20,
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold)),
        content: Container(
            child: ListView(
          children: [
            Text(
              message,
              style: GoogleFonts.openSans(
                  fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.start,
            ),
          ],
        )),
        actions: [
          firstPopup.button(
              label: "Şimdi Güncelle",
              onPressed: () {
                StoreRedirect.redirect(
                    androidAppId: UserInfo.googlePlayId,
                    iOSAppId: UserInfo.appStoreId);
              }),
        ],
        barrierDismissible: false,
        close: Container(),
      );
    } else {
      firstPopup.show(
        title: Text("Güncelleme Mevcut",
            style: GoogleFonts.roboto(
                fontSize: 20,
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold)),
        content: Container(
            child: ListView(
          children: [
            Text(
              message,
              style: GoogleFonts.openSans(
                  fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.start,
            ),
          ],
        )),
        actions: [
          firstPopup.button(
              label: "Daha Sonra",
              onPressed: () {
                Navigator.pop(context);
                updateMessage = true;
                return;
              }),
          firstPopup.button(
              label: "Şimdi Güncelle",
              onPressed: () {
                StoreRedirect.redirect(
                    androidAppId: UserInfo.googlePlayId,
                    iOSAppId: UserInfo.appStoreId);
              }),
        ],
        barrierDismissible: false,
        close: Container(),
      );
      updateMessage = true;
    }
    return null;
  }

  static stringNullCheck(String? data) {
    if (data == null || data == "null") {
      return "";
    } else {
      return data;
    }
  }
}

class Sabitler {
  static String url = "http://api.sds.com.tr";
  static String apiKey = "l75pq03ejewq1qdkap1e19u9jwdk2qdm5dAsd321CnsfWWlosmCs123y";

  static BoxDecoration dreamBoxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade500.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 3,
          offset: Offset(0, 0.5),
        ),
      ],
      color: Colors.white);
}
