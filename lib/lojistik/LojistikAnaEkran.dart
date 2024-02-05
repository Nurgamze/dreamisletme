import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sdsdream_flutter/AnaEkranSayfasi.dart';
import '../modeller/Modeller.dart';
import 'Cikis/Cikis.dart';
import 'Depo/Depo.dart';
import 'Giris/Giris.dart';
import 'KaliteKontrol/KaliteKontrol.dart';
import 'Siparis/Siparis.dart';
import 'Stoklar/StoklarSayfasi.dart';

class VeriTabanlari {
  String vtIsim;
  String vtAciklama;
  String vtSubeKod;
  VeriTabanlari(this.vtIsim, this.vtAciklama,this.vtSubeKod);
}


class LojistikSayfasi extends StatefulWidget {

  // late final String? aktifSubeNo;
  // LojistikSayfasi({required this.aktifSubeNo});

  @override
  _LojistikSayfasiState createState() => _LojistikSayfasiState();
}


class _LojistikSayfasiState extends State<LojistikSayfasi> {

  FixedExtentScrollController? scrollController;
  FixedExtentScrollController? zenitScrollController;

  late Response response;
  Dio dio = new Dio();
  List <VeriTabanlari> veriTabanlariList = [];
  late bool btnPortfoydekiCekler,
      btnCiroTablosu,
      btnStokSatisKarlilikRaporu,
      btnTahsilatlarKonsolide;

  @override
  void initState() {
    /* if (UserInfo.activeDB == "MikroDB_V16_Z17_YAGIZ") {
      yagizGoster = true;
    }*/
    print("init aktif ANASAYFADA  ${UserInfo.aktifSubeNo}");
    UserInfo.aktifSubeNo ??= "0"; //aktif şube null ise onu 0 yap

    super.initState();
    // if (UserInfo.isCriticUser!) {
    //   btnPortfoydekiCekler = btnCiroTablosu = btnStokSatisKarlilikRaporu = btnTahsilatlarKonsolide = false;
    // } else {
    //   btnPortfoydekiCekler = btnCiroTablosu =
    //       btnStokSatisKarlilikRaporu = btnTahsilatlarKonsolide = true;
    //   btnCiroTablosu = !UserInfo.isCiroRapor!;
    //   btnPortfoydekiCekler = !UserInfo.isPortfoyCekRapor!;
    //   btnStokSatisKarlilikRaporu = !UserInfo.isStokSatisKarlilikRapor!;
    // }

    // if (UserInfo.activeDB == null) {_showDialog();}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Container(color: Colors.blue.shade900,),
        ),
        //PreferredSize apparın üstündeki alarm saat kısmının arka rengi
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                height: screenHeight,
                width: screenWidth,
                child: Column(
                  children: [
                    Container(
                      child: Image(image: AssetImage("assets/images/dream_lojistik.png"),
                          width: MediaQuery.of(context).size.width / 3),
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(2, 5),
                                    ),
                                  ],
                                  color: Colors.white
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 15, top: 10),
                                    child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text("Depo",
                                          style: GoogleFonts.roboto(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade800),)
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right: 15, bottom: 10),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: FaIcon(FontAwesomeIcons.warehouse,
                                        color: Colors.blue.shade900, size: 30,),
                                    ),
                                  ),
                                ],
                              ),
                              height: 80,
                              width: (MediaQuery.of(context).size.width - 30) / 2,
                            ),
                            onTap: () async {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => Depo()));
                            }
                        ),
                        SizedBox(width: 5,),
                        InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(5)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(2, 5),
                                    ),
                                  ],
                                  color: Colors.white
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 15, top: 10),
                                    child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text("Sipariş",
                                          style: GoogleFonts.roboto(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade800),)
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right: 15, bottom: 10),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: FaIcon(
                                        FontAwesomeIcons.shoppingCart,
                                        color: Colors.blue.shade900, size: 30,),
                                    ),
                                  ),
                                ],
                              ),
                              height: 80,
                              width: (MediaQuery.of(context).size.width - 30) / 2,
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => Siparis()));
                            }
                        )
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(5)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(2, 5),
                                    ),
                                  ],
                                  color: Colors.white
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 15, top: 10),
                                    child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text("Giriş",
                                          style: GoogleFonts.roboto(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade800),)
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right: 15, bottom: 10),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: FaIcon(
                                        FontAwesomeIcons.dollyFlatbed,
                                        color: Colors.blue.shade900, size: 30,),
                                    ),
                                  ),
                                ],
                              ),
                              height: 80,
                              width: (MediaQuery.of(context).size.width - 30) / 2,
                            ),
                            onTap: () {
                          //    Navigator.push(context, MaterialPageRoute(builder: (context) => Giris()));
                            }
                        ),
                        SizedBox(width: 5,),
                        InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(5)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(2, 5),
                                    ),
                                  ],
                                  color: Colors.white
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 15, top: 10),
                                    child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text("Çıkış",
                                          style: GoogleFonts.roboto(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade800),)
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right: 15, bottom: 10),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: FaIcon(FontAwesomeIcons.dolly,
                                        color: Colors.blue.shade900, size: 30,),
                                    ),
                                  ),
                                ],
                              ),
                              height: 80,
                              width: (MediaQuery.of(context).size.width - 30) / 2,
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => Cikis()));
                            }
                        )
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                            child: Container(
                              margin: EdgeInsets.only(left: 12.5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(5)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(2, 5),
                                    ),
                                  ],
                                  color: Colors.white
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 15, top: 10),
                                    child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text("Kalite Konrol",
                                          style: GoogleFonts.roboto(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade800),)
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right: 15, bottom: 10),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: FaIcon(FontAwesomeIcons.check,
                                        color: Colors.blue.shade900, size: 30,),
                                    ),
                                  ),
                                ],
                              ),
                              height: 80,
                              width: (MediaQuery.of(context).size.width - 30) / 2,
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => KaliteKontrol()));
                            }
                        ),
                        SizedBox(width: 5,),
                        InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(5)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(2, 5),
                                    ),
                                  ],
                                  color: Colors.white
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 15, top: 10),
                                    child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text("Stoklar",
                                          style: GoogleFonts.roboto(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade800),)
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only( right: 15, bottom: 10 ),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: FaIcon(FontAwesomeIcons.box,
                                        color: Colors.blue.shade900, size: 30,),
                                    ),
                                  ),
                                ],
                              ),
                              height: 80,
                              width: (MediaQuery.of(context).size.width - 30) / 2,
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => StoklarSayfasi()));
                            }
                        ),
                      ],
                    ),
                    SizedBox(height: 80,),

                  ],
                ),
              ),
            ),
            // Align(
            //     alignment: Alignment.topRight,
            //     child: Padding(
            //       padding: EdgeInsets.only(right: 20, top: 10),
            //       child: IconButton(
            //         icon: FaIcon(FontAwesomeIcons.cloudDownloadAlt,
            //           color: Colors.blue.shade900, size: 35,),
            //         onPressed: () async {
            //           bool intVarMi = await Foksiyonlar.internetDurumu(context);
            //           if (!intVarMi) return;
            //           _guncelleOnayDialog();
            //         },
            //       ),
            //     )
            // ),

            Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(right: 15, top: 10),
                  child: Transform.scale(
                    scale: 1.2,
                    child: BackButton(
                      color: Colors.blue.shade900,
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => AnaEkranSayfasi()));
                      },
                    ),
                  ),
                )
            ),
          ],
        )
    );
  }

  // _guncelleOnayDialog() async {
  //   showDialog(context: context,
  //       builder: (context) =>
  //           Container(child: Center(child: CircularProgressIndicator(),),));
  //   bool result = await downloadFile();
  //   if (result) {
  //     Fluttertoast.showToast(
  //         msg: "Veriler güncellendi.",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.CENTER,
  //         textColor: Colors.white,
  //         backgroundColor: Colors.green.shade600,
  //         fontSize: 16.0
  //     );
  //   } else {
  //     Fluttertoast.showToast(
  //         msg: "Verileri güncellenirken sorun oluştu.",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.CENTER,
  //         textColor: Colors.white,
  //         backgroundColor: Colors.red.shade600,
  //         fontSize: 16.0
  //     );
  //   }
  //   Navigator.pop(context);
  // }
  //
  // Future<bool> downloadFile() async {
  //   var dir = await getApplicationDocumentsDirectory();
  //   String dirPath = dir.path + "/flutter.zip";
  //   String dbPath = dir.path + "/flutter.db";
  //   try {
  //     Response response = await Dio().download(
  //       "${Sabitler.url}/api/FileDownloading/download",
  //       dirPath,
  //       options: Options(headers: {"apiKey": Sabitler.apiKey}),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       File fileTry = File(dirPath);
  //       final bytes = File(dirPath).readAsBytesSync();
  //
  //       // Decode the Zip file
  //       final archive = ZipDecoder().decodeBytes(bytes);
  //       for (final file in archive) {
  //         print(file.name);
  //         if (file.name == "flutter.db") {
  //           if (file.isFile) {
  //             final data = file.content as List<int>;
  //             File(dbPath)
  //               ..createSync(recursive: true)
  //               ..writeAsBytesSync(data);
  //           } else {
  //             Directory(dbPath)
  //               ..create(recursive: true);
  //           }
  //         }
  //       }
  //       return true;
  //     } else {
  //       print("Download failed with status code: ${response.statusCode}");
  //       return false;
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //     return false;
  //   }
  // }
}
