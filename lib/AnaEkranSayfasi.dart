import 'dart:async';
import 'dart:convert';
import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:sdsdream_flutter/DovizKurlariSayfasi.dart';
import 'package:sdsdream_flutter/GirisYapYeni.dart';
import 'package:sdsdream_flutter/Raporlar/CiroTablosuSayfasi.dart';
import 'package:sdsdream_flutter/Raporlar/PortfoydekiCeklerSayfasi.dart';
import 'package:sdsdream_flutter/Raporlar/SatisTahsilatAnaliziSayfasi.dart';
import 'package:sdsdream_flutter/Raporlar/SatisTahsilatOzet.dart';
import 'package:sdsdream_flutter/Raporlar/StokSatisKarlilikRaporuSayfasi.dart';
import 'package:sdsdream_flutter/Raporlar/TahsilatBakiyeAnaliziSayfasi.dart';
import 'package:sdsdream_flutter/siparisler/TumAcikSiparis.dart';
import 'package:sdsdream_flutter/widgets/Dialoglar.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'package:sdsdream_flutter/Yagiz/YagizOzelSayfa.dart';
import 'package:sdsdream_flutter/ZiyaretPlaniSayfasi.dart';
import 'package:sdsdream_flutter/ortalama_vade_hesapla.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'OdemeYap.dart';
import 'aday_cariler/AdayCarilerSayfasi.dart';
import 'BilisimTalepleriSayfasi.dart';
import 'cariler/cariler.dart';
import 'modeller/Modeller.dart';
import 'OnlineHesabimSayfasi.dart';
import 'Raporlar/ButceGerceklesenRaporu.dart';
import 'Raporlar/SatisCiroKaybi.dart';
import 'Raporlar/SatisTahsilatTemsilci.dart';
import 'Raporlar/TahsilatlarSayfasi.dart';
import 'Stoklar/StoklarSayfasi.dart';
import 'Stoklar/ZenitStoklar.dart';

class AnaEkranSayfasi extends StatefulWidget {
  @override
  _AnaEkranSayfasiState createState() => _AnaEkranSayfasiState();
}

class _AnaEkranSayfasiState extends State<AnaEkranSayfasi> {
  FixedExtentScrollController? scrollController;
  FixedExtentScrollController? zenitScrollController;
  final TextEditingController _sifreController = TextEditingController();
  final TextEditingController _kullaniciBilgiController = TextEditingController();
  final TextEditingController _kullaniciAdiController = TextEditingController();
  final TextEditingController _kullaniciEskiSifreController = TextEditingController();
  final TextEditingController _kullaniciYeniSifreController = TextEditingController();
  final TextEditingController _kullaniciYeniSifreTekrarController = TextEditingController();

  int seciliButon = 0;
  bool rememberMe = false;
  bool confettiGoster = false;
  bool onlineGoster = false;
  bool yagizGoster = false;
  String selectedPage = " ";
  bool passwordVisible = true;

  PageController controller = PageController();
  List<VeriTabanlari> veriTabanlariList = [];
  late bool btnPortfoydekiCekler,
            btnCiroTablosu,
            btnStokSatisKarlilikRaporu,
            btnTahsilatlarKonsolide;

  DovizKurlariSayfasi dd = DovizKurlariSayfasi(true);

  @override
  void initState() {
    if (UserInfo.activeDB == "MikroDB_V16_Z17_YAGIZ") {
       yagizGoster = true;
    }
    print("init aktif ${UserInfo.aktifSubeNo}");
    UserInfo.aktifSubeNo ??= "0";
    super.initState();
    if (UserInfo.isCriticUser!) {
      btnPortfoydekiCekler = btnCiroTablosu = btnStokSatisKarlilikRaporu = btnTahsilatlarKonsolide = false;
    } else {
      btnPortfoydekiCekler = btnCiroTablosu = btnStokSatisKarlilikRaporu = btnTahsilatlarKonsolide = true;
      btnCiroTablosu = !UserInfo.isCiroRapor!;
      btnPortfoydekiCekler = !UserInfo.isPortfoyCekRapor!;
      btnStokSatisKarlilikRaporu = !UserInfo.isStokSatisKarlilikRapor!;
    }
    if (UserInfo.activeDB == null) {
           _showDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    if (UserInfo.activeDB == null) {
          UserInfo.fullAccess = false;
          btnPortfoydekiCekler = btnCiroTablosu = btnStokSatisKarlilikRaporu = btnTahsilatlarKonsolide = true;
          btnCiroTablosu = true;
          btnPortfoydekiCekler = true;
          btnStokSatisKarlilikRaporu = true;
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: ConstScreen(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Image(
              image: AssetImage("assets/images/b2b_isletme_v3.png"),
              width: 150,
            ), leading: IconButton(
            onPressed: (){
              _scaffoldKey.currentState?.openDrawer();
            },
            icon: Icon(Icons.menu),
          ),

            centerTitle: true,
            backgroundColor: Colors.blue.shade900,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.powerOff,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (!Device.get().isTablet){
                        AutoOrientation.portraitUpMode();
                    };
                    Navigator.pushAndRemoveUntil(
                      context, MaterialPageRoute(
                          builder: (context) => GirisYapSayfasi()),
                            (Route<dynamic> route) => false,
                    );
                  })
            ],
          ),drawer: Drawer(
          width: MediaQuery.of(context).size.width/2,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue.shade900,
                ),
                child: Center(
                  child: Text( 'Merhaba ${UserInfo.ad}!', style: TextStyle( color: Colors.white, fontSize: 24 ),),
                ),
              ),
              ListTile(
                leading: Container(
                  height: 55,
                  width:  55,
                  decoration:  BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.coins,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
                title: Text('Döviz Kurları'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DovizKurlariSayfasi(false)));
                },
              ),SizedBox(height: 10,),
              ListTile(
                leading: Container(
                  height: 55,
                  width:  55,
                  decoration:  BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.stripeS,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
                title: Text('SDS e-Tahsilat'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => OdemeSayfasi(false)));
                },
              ),SizedBox(height: 10,),
              ListTile(
                leading: Container(
                  height: 55,
                  width:  55,
                  decoration:  BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.hryvnia,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
                title: Text('Zenitled e-Tahsilat'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => OdemeSayfasi(true)));
                },
              ),
              SizedBox(height: 10,),
              ListTile(
                leading: Container(
                  height: 55,
                  width:  55,
                  decoration:  BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.questionCircle,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
                title: Text('Şifremi Değiştir'),
                onTap: () {
                  _kullaniciAdiController.clear();
                  _kullaniciEskiSifreController.clear();
                  _kullaniciYeniSifreController.clear();
                  _kullaniciYeniSifreTekrarController.clear();
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      insetPadding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 10),
                      backgroundColor: Colors.white,
                      child: Container(
                        height: 314,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 22,
                                child: Text("Şifremi Değiştir",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18),
                                ),
                                margin: EdgeInsets.only(top: 15),
                              ),
                              SizedBox(height: 10,),
                              Container(
                                height: 45,
                                child: TextFormField(
                                  controller: _kullaniciAdiController,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: "Kullanıcı adı",
                                    hintText: "ad.soyad",
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  cursorColor: Colors.blue.shade900,
                                  style: TextStyle(color: Colors.black),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                              SizedBox(height: 5),
                              Container(
                                height: 45,
                                child: TextFormField(
                                  controller: _kullaniciEskiSifreController,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: "Eski şifre",
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  cursorColor: Colors.blue.shade900,
                                  style: TextStyle(color: Colors.black),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                              SizedBox(height: 5,),
                              Container(
                                height: 45,
                                child: TextFormField(
                                  controller: _kullaniciYeniSifreController,
                                  maxLines: 1,
                                  obscureText: passwordVisible,
                                  decoration: InputDecoration(
                                    labelText: "Yeni şifre",
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  cursorColor: Colors.blue.shade900,
                                  style: TextStyle(color: Colors.black),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                              SizedBox(height: 5,),
                              Container(
                                height: 45,
                                child: TextFormField(
                                  controller: _kullaniciYeniSifreTekrarController,
                                  maxLines: 1,
                                  obscureText: passwordVisible,
                                  decoration: InputDecoration(
                                    labelText: "Yeni şifre tekrar",
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),          suffixIcon: IconButton(
                                    icon: Icon(
                                        passwordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.blue.shade900),
                                    onPressed: () {
                                      setState(() {
                                        passwordVisible = !passwordVisible;
                                      });
                                    },
                                  ),
                                  ),
                                  cursorColor: Colors.blue.shade900,
                                  style: TextStyle(color: Colors.black),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 5),
                                color: Colors.grey,
                                height: 1,
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                          onPressed: () async {
                                            if (_kullaniciEskiSifreController.text == UserInfo.password && _kullaniciAdiController.text==UserInfo.ldapUser){
                                              if(_kullaniciYeniSifreController.text==_kullaniciYeniSifreTekrarController.text){
                                                _sifremiDegistir();
                                              }else{
                                                Fluttertoast.showToast(
                                                  msg: "Yeni şifreler eşleşmiyor.",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.red,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0,
                                                );
                                              }
                                            }else{
                                              print("eski şifre aynı değil");
                                              Fluttertoast.showToast(
                                                msg: "Eski şifreniz ya da Kullanıcı adınız yanlış. Lütfen doğru bir şekilde girin.",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                                fontSize: 16.0,
                                              );
                                            }
                                          }, child: Text( "GÖNDER", style: TextStyle(color: Colors.blue),)),
                                    ),
                                    Container(width: 1, color: Colors.grey, height: 50,),
                                    Expanded(
                                      child: TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text("İPTAL", style: TextStyle(color: Colors.blue))),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

            ],
          ),
        ),
          body: Stack(
            children: [
              Container(
                color: Colors.white,
                child: Row(
                  children: [
                    Container(
                        width: 50,
                        decoration: BoxDecoration(color: Colors.blue.shade900),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: InkWell(
                                child: const RotatedBox(
                                    quarterTurns: 3,
                                    child: Center(
                                      child: AutoSizeText(
                                        ' İlk elden, güvenle...',
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    )),
                                onTap: () {
                                  setState(() {
                                    confettiGoster = true;
                                    Timer(Duration(milliseconds: 4000), () {
                                      setState(() {
                                        confettiGoster = false;
                                      });
                                    });
                                  });
                                },
                              ),
                            ),
                            InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: seciliButon == 0 ? Colors.orange.shade900 : Colors.orange.shade800),
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(60)),
                                    color: seciliButon == 0 ? Colors.orange.shade900 : Colors.orange.shade800),
                                child: const RotatedBox(
                                    quarterTurns: 3,
                                    child: Center(
                                      child: Text(
                                        'Modüller',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 21),
                                      ),
                                    )),
                                height:
                                MediaQuery.of(context).size.height * 2 / 9,
                                width: 50,
                              ),
                              onTap: () {
                                setState(() {
                                  seciliButon = 0;
                                  controller.animateToPage(0,
                                      duration: Duration(milliseconds: 200),
                                      curve: Curves.easeIn);
                                });
                              },
                            ),
                            InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: seciliButon == 1
                                            ? Colors.orange.shade900
                                            : Colors.orange.shade800),
                                    color: seciliButon == 1
                                        ? Colors.orange.shade900
                                        : Colors.orange.shade800),
                                child: const RotatedBox(
                                    quarterTurns: 3,
                                    child: Center(
                                      child: Text('Raporlar', style: TextStyle(color: Colors.white, fontSize: 21),),
                                    )),
                                height:
                                MediaQuery.of(context).size.height * 2 / 9,
                                width: 50,
                              ),
                              onTap: () {
                                setState(() {
                                  seciliButon = 1;
                                  controller.animateToPage(1, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
                                });
                              },
                            ),
                            InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.orange.shade800), color: Colors.orange.shade800),
                                child: const RotatedBox(
                                    quarterTurns: 3,
                                    child: Center(
                                      child: Text('Menü', style: TextStyle(color: Colors.white, fontSize: 21),),
                                    )),
                                height:
                                MediaQuery.of(context).size.height * 2 / 9,
                                width: 50,
                              ),
                              onTap: () {
                                setState(() {
                                  enabled = !enabled;
                                });
                                Timer(Duration(milliseconds: 300), () {
                                  setState(() {
                                    enabled = false;
                                  });
                                });
                              },
                            )
                          ],
                        )),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(child: Container(
                            width: MediaQuery.of(context).size.width - 50,
                            decoration: BoxDecoration(color: Colors.deepOrange),
                            child: PageView(
                              controller: controller,
                              onPageChanged: (value) {
                                setState(() {
                                  seciliButon = value;
                                });
                              },
                              children: <Widget>[
                                moduller(),
                                raporlar(),
                              ],
                            ),
                          ),),
                          ShakeAnimatedWidget(
                              enabled: enabled,
                              duration: Duration(milliseconds: 200),
                              shakeAngle: Rotation.deg(z: 2),
                              curve: Curves.linear,
                              child: Container(
                                height: MediaQuery.of(context).size.height * 2 / 9,
                                width: MediaQuery.of(context).size.width - 50,
                                padding:
                                EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                        top: BorderSide(color: Colors.orange.shade800))),
                                child: Row(
                                  children: [
                                    InkWell(
                                      child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxHeight: 80,
                                          ),
                                          child: Container(
                                            width: (MediaQuery.of(context).size.width - 50) / 2 - 13,
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
                                                color: Colors.white),
                                            child: Stack(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 10, top: 10),
                                                  child: Align(
                                                      alignment: Alignment.topLeft,
                                                      child: Text( "Şube Seçimi",
                                                        style: GoogleFonts.roboto(
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.w600,
                                                            color:
                                                            Colors.grey.shade800),
                                                      )),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only( right: 15, bottom: 10),
                                                  child: Align(
                                                    alignment: Alignment.bottomRight,
                                                    child: FaIcon(
                                                      FontAwesomeIcons.solidBuilding,
                                                      color: Colors.blue.shade900,
                                                      size: 30,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                      onTap: () async {
                                        var databaseOk = await _getDatabases();
                                        if (databaseOk) {
                                          showDialog(
                                              context: context,
                                              barrierColor:
                                              Colors.black.withOpacity(0.5),
                                              builder: (context) => subeSecimiDialog());
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5,),
                                    InkWell(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: 80,
                                        ),
                                        child: Container(
                                          width:
                                          (MediaQuery.of(context).size.width - 50) / 2 - 13,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.all(Radius.circular(5)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.3),
                                                  spreadRadius: 2,
                                                  blurRadius: 5,
                                                  offset: Offset(2, 5),
                                                ),
                                              ],
                                              color: Colors.white),
                                          child: Stack(
                                            children: [
                                              Padding(
                                                padding:
                                                EdgeInsets.only(left: 10, top: 10),
                                                child: Align(
                                                    alignment: Alignment.topLeft,
                                                    child: Text(
                                                      "Döviz Kurları",
                                                      style: GoogleFonts.roboto(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.grey.shade800),
                                                    )),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: 15, bottom: 10),
                                                child: Align(
                                                  alignment: Alignment.bottomRight,
                                                  child: FaIcon(
                                                    FontAwesomeIcons.coins,
                                                    color: Colors.blue.shade900,
                                                    size: 30,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DovizKurlariSayfasi(true))),
                                    ),
                                  ],
                                ),
                              )
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              confettiGoster ?
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.transparent,
                  child: Lottie.asset("assets/images/confetti.json",
                      fit: BoxFit.fill),
                ),
              ) : Container()
            ],
          ),
        ),
      ),
    );
  }

  _showDialog() async {
    var databaseOk = await _getDatabases();
    if (databaseOk) {
      await Future.delayed(Duration(milliseconds: 50));
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return subeSecimiDialog();
          }).then((value) {
        if (UserInfo.activeDB == null) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return BilgilendirmeDialog(
                    "Şube seçmediniz uygulamayı kullanabilmeniz için şube seçmeniz gerekmektedir");
              });
        }
      });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BilgilendirmeDialog(
                "Birkaç dakika sonra tekrar deneyiniz hatayı almaya devam ederseniz SDS Bilişim ekibiyle iletişime geçiniz");
          });
    }
  }

  
  bool enabled = false;
  _getDatabases() async {
    var response = await http.get(
        Uri.parse("${Sabitler.url}/api/GetUserDatabases?userId=${UserInfo.activeUserId}"),
        headers: {"apiKey": Sabitler.apiKey});
    veriTabanlariList.clear();
    if (response.statusCode == 200) {
      var veriTabanlariJson = jsonDecode(response.body);
      print("veritabanaları $veriTabanlariJson");

      for (var veriTabanlari in veriTabanlariJson) {
        VeriTabanlari veriTabani = VeriTabanlari(veriTabanlari['vtIsim'], veriTabanlari['vtAciklama'],veriTabanlari['vtSubeKod']);
        setState(() {
          veriTabanlariList.add(veriTabani);
        });
      }
      return true;
    } else {
      showDialog(
          context: context,
          builder: (context) => BilgilendirmeDialog(
              "Bir hata oluştu biraz bekledikten sonra tekrar deneyin.\nHatayı almaya devam ederseniz SDS Bilişimle iletişime geçiniz."));
      return false;
    }
  }

  _portalUserControl() async {
    var response = await http.get(
        Uri.parse(
            "${Sabitler.url}/api/PortalFindUserId?userId=${UserInfo.activeUserId}&userName=${UserInfo.ldapUser}"),
        headers: {"apiKey": Sabitler.apiKey});
    if (response.statusCode == 200) {
      print(response.body);
      var gelenId = jsonDecode(response.body);
      if (gelenId == null) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                content: Text(
                    "Bulut'a daha önce hiç giriş yapmamış görünüyorsunuz.\n\n"
                    "Açılacak sayfaya bilgisayar kullanıcı adı ve şifreniz ile giriş yaptıktan sonra Bulut kullanıcınız oluşacak, ardından Dream üzerinden taleplerinizi görüntüleyebilecek ve yeni talep oluşturabileceksiniz.\n\n"
                    "Hazır olduğunuzda Tamam'a basarak devam edin."),
                actions: [
                  TextButton(
                    child: Text("Tamam"),
                    onPressed: () async {
                      Navigator.pop(context);
                      await launchUrl(
                        Uri.parse("http://bulut.sds.com.tr"),
                      );
                    },
                  ),
                ],
              );
            });
      } else {
        UserInfo.portalUserId = gelenId;
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => BilisimTalepleriSayfasi()));
      }
    } else if (response.statusCode == 404) {}
  }

  _aktifVtDegis(VeriTabanlari veriTabani) async {
    var response = await http.get(
        Uri.parse(
            "${Sabitler.url}/api/SetUserActiveDb?userId=${UserInfo.activeUserId}&activeDb=${veriTabani.vtIsim}"),
        headers: {"apiKey": Sabitler.apiKey});
    if (response.statusCode == 200) {
      UserInfo.activeDB = veriTabani.vtIsim;
      SharedPreferences pref = await SharedPreferences.getInstance();
      if(veriTabani.vtIsim != "MikroDB_V16_12"){
        pref.setString("zenitSubeKod", veriTabani.vtSubeKod);
        UserInfo.aktifSubeNo = veriTabani.vtSubeKod;
      }
      return true;
    } else if (response.statusCode == 404) {
      return false;
    }
  }

  Widget subeSecimiDialog() {
    bool noDataBase;
    if (UserInfo.activeDB == null)
      noDataBase = true;
    else
      noDataBase = false;
    String aktifVeriTabani = "";
    if (UserInfo.activeDB == null) {
      scrollController = FixedExtentScrollController(initialItem: 0);
    } else {
      for (int i = 0; i < veriTabanlariList.length; i++) {
        if(veriTabanlariList[i].vtIsim == "MikroDB_V16_12"){
          if (veriTabanlariList[i].vtIsim == UserInfo.activeDB) {
            aktifVeriTabani = veriTabanlariList[i].vtAciklama;
            scrollController = FixedExtentScrollController(initialItem: i);
          }
        }else{
          if (veriTabanlariList[i].vtIsim == UserInfo.activeDB && veriTabanlariList[i].vtSubeKod == UserInfo.aktifSubeNo) {
            aktifVeriTabani = veriTabanlariList[i].vtAciklama;
            scrollController = FixedExtentScrollController(initialItem: i);
          }
        }

      }
      if(scrollController == null){
        scrollController = FixedExtentScrollController(initialItem: 0);
      }
    }

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          height: 325,
          width: 250,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            children: [
              Container(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Center(
                    child: Column(
                  children: [
                    Text("Şube Seçiniz",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.blue.shade900)),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Aktif Şube :  $aktifVeriTabani",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.blue.shade900)),
                    Divider(
                      thickness: 2,
                    ),
                    Container(
                        color: Colors.white10,
                        height: 180,
                        child: Stack(
                          children: [
                            ListWheelScrollView(
                              controller: scrollController,
                              physics: const FixedExtentScrollPhysics(),
                              perspective: 0.01,
                              itemExtent: 40,
                              children: List.generate(veriTabanlariList.length,
                                  (index) {
                                return Container(
                                  child: Center(
                                    child: Text(
                                      veriTabanlariList[index].vtAciklama,
                                      style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17),
                                    ),
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                );
                              }),
                            ),
                            Align(
                                alignment: Alignment(0, 0.2),
                                child: Container(
                                  child: Divider(
                                    color: Colors.grey,
                                  ),
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                )),
                            Align(
                                alignment: Alignment(0, -0.2),
                                child: Container(
                                  child: Divider(
                                    color: Colors.grey,
                                  ),
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                )),
                          ],
                        )),
                    Container(
                      padding: EdgeInsets.only(right: 10, left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: Text(
                                "İptal Et",
                                style: TextStyle(color: Colors.grey.shade200),
                              ),
                              onPressed: () {
                                if (UserInfo.activeDB != null) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: () async {
                                  bool result = await _aktifVtDegis(veriTabanlariList[scrollController!.selectedItem]);
                                  String resultDb = veriTabanlariList[
                                  scrollController!.selectedItem]
                                      .vtAciklama;
                                  if (result) {
                                    UserInfo.activeDB = "MikroDB_V16_12";
                                    if (veriTabanlariList[scrollController!.selectedItem].vtIsim == "MikroDB_V16_12") {
                                      if (noDataBase) {
                                        Navigator.pop(context);
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                zenitSubeSecimiDialog(true),
                                            barrierDismissible: false);
                                      } else {
                                        Navigator.pop(context);
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                zenitSubeSecimiDialog(false),
                                            barrierDismissible: false);
                                      }
                                    } else {
                                      if (noDataBase) {
                                        Navigator.pop(context);
                                        showDialog(
                                            context: context,
                                            builder: (context) => BilgilendirmeDialog(
                                                "Şubenizi ${veriTabanlariList[scrollController!.selectedItem].vtAciklama} olarak değiştirdiniz.Tekrardan giriş yapınız."))
                                          ..then((value) =>
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        GirisYapSayfasi()),
                                                    (Route<dynamic> route) => false,
                                              ));
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                                backgroundColor: Colors.transparent,
                                                insetPadding: EdgeInsets.only(
                                                    bottom: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                        3),
                                                elevation: 0,
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                      2,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                      2,
                                                  child: Image.asset(
                                                      "assets/images/sdsLoading.gif"),
                                                )));
                                        await _getUserInfo();
                                        Navigator.pop(context);
                                        setState(() {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AnaEkranSayfasi(),
                                              ));
                                          showDialog(
                                              context: context,
                                              builder: (context) => BilgilendirmeDialog(
                                                  "Şubenizi $resultDb olarak değiştirdiniz."));
                                        });
                                      }
                                    }
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (context) => BilgilendirmeDialog(
                                            "Şube değişirken sorun oluştu"));
                                  }
                                },
                                child: Text(
                                  "Şube Değiştir",
                                  style: TextStyle(color: Colors.grey.shade200),
                                ),
                          ))
                        ],
                      ),
                    )
                  ],
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getUserInfo() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var userName = pref.getString("userMail");
    var password = pref.getString("password");
    http.Response response;
    var body = jsonEncode({"userName": userName, "password": password});
    response = await http.post(Uri.parse("${Sabitler.url}/api/GetUserInfo"),
        headers: {
          "apiKey": Sabitler.apiKey,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body);
    if (response.statusCode == 200) {
      print(UserInfo.aktifSubeNo);
      var user = jsonDecode(response.body);
      for (var data in user) {
        print(data);
        UserInfo.activeUserId = data["id"];
        UserInfo.ldapUser = data["LdapUser"];
        UserInfo.mikroUserKod = data["MikroUserKod"];
        UserInfo.mikroPersonelKod = data["MikroPersonelKod"];
        UserInfo.ad = data["Ad"];
        UserInfo.soyAd = data["SoyAd"];
        UserInfo.password = data["Password"];
        UserInfo.isSuperUser = data["IsSuperUser"];
        UserInfo.isCiroRapor = data["IsCiroRapor"];
        UserInfo.isCriticUser = data["IsCriticUser"];
        UserInfo.isPortfoyCekRapor = data["IsPortfoyCekRapor"];
        UserInfo.isStokSatisKarlilikRapor = data["IsStokSatisKarlilikRapor"];
        UserInfo.isButceRapor = data["IsButceRapor"];
        UserInfo.activeDB = data["ActiveDB"];
      }
      await Foksiyonlar.checkAppEngine(context, true);
    }
  }

  Widget zenitSubeSecimiDialog(bool noDatabase) {
    List<String> zenitSubeler;
    List<String> zenitSubelerKod;
    if (UserInfo.zenitUretimYetki) {
      zenitSubeler = Subeler.zenitSubelerTuzla;
      zenitSubelerKod = Subeler.zenitSubelerKodTuzla;
    } else {
      zenitSubeler = Subeler.zenitSubeler;
      zenitSubelerKod = Subeler.zenitSubelerKod;
    }
    String aktifZenitSube = "";

    print("şube numarası ${UserInfo.aktifSubeNo}");
    for (int i = 0; i < zenitSubeler.length; i++) {
      print("iiii ${zenitSubelerKod[i]}");
      if (zenitSubelerKod[i] == UserInfo.aktifSubeNo) {
        aktifZenitSube = zenitSubeler[i];
        zenitScrollController = FixedExtentScrollController(initialItem: i);
        break;
      }
      if (i == zenitSubeler.length - 1 && zenitSubelerKod[i] != UserInfo.aktifSubeNo) {
        zenitScrollController = FixedExtentScrollController(initialItem: 1);
      }
    }
    return MediaQuery(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          height: 325,
          width: 250,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            children: [
              Container(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Center(
                    child: Column(
                  children: [
                    Text("Zenitled Şubesini Seçiniz",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue.shade900)),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Aktif Zenitled Şube :  $aktifZenitSube",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blue.shade900)),
                    Divider(
                      thickness: 2,
                    ),
                    Container(
                        color: Colors.white10,
                        height: 180,
                        child: Stack(
                          children: [
                            ListWheelScrollView(
                              controller: zenitScrollController,
                              physics: const FixedExtentScrollPhysics(),
                              perspective: 0.01,
                              itemExtent: 40,
                              children:
                                  List.generate(zenitSubeler.length, (index) {
                                return Container(
                                  child: Center(
                                    child: Text(
                                      zenitSubeler[index],
                                      style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17),
                                    ),
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                );
                              }),
                            ),
                            Align(
                                alignment: Alignment(0, 0.2),
                                child: Container(
                                  child: Divider(
                                    color: Colors.grey,
                                  ),
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                )),
                            Align(
                                alignment: Alignment(0, -0.2),
                                child: Container(
                                  child: Divider(
                                    color: Colors.grey,
                                  ),
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                )),
                          ],
                        )),
                    Container(
                      padding: EdgeInsets.only(right: 10, left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: Text(
                              "Şube Değiştir",
                              style: TextStyle(color: Colors.grey.shade200),
                            ),
                            onPressed: () async {
                              SharedPreferences pref = await SharedPreferences.getInstance();
                              String activeZenitSube = "";
                              pref.setString("zenitSubeKod", zenitSubelerKod[zenitScrollController!.selectedItem]);
                              activeZenitSube = zenitSubeler[zenitScrollController!.selectedItem];
                              UserInfo.aktifSubeNo = zenitSubelerKod[zenitScrollController!.selectedItem];

                              print("UserInfo.aktifSubeNo ,${UserInfo.aktifSubeNo}");

                              if (noDatabase) {
                                showDialog(
                                    context: context,
                                    builder: (context) => BilgilendirmeDialog(
                                        "Şubenizi Zenitled $activeZenitSube olarak değiştirdiniz. Tekrardan giriş yapınız.")).then(
                                    (value) => Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  GirisYapSayfasi()),
                                          (Route<dynamic> route) => false,
                                        ));
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                3),
                                        elevation: 0,
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          child: Image.asset(
                                              "assets/images/sdsLoading.gif"),
                                        )));
                                await _getUserInfo();
                                Navigator.pop(context);
                                setState(() {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AnaEkranSayfasi(),
                                      ));
                                  showDialog(
                                      context: context,
                                      builder: (context) => BilgilendirmeDialog(
                                          "Şubenizi Zenitled $activeZenitSube olarak değiştirdiniz."));
                                });
                              }
                            },
                          ))
                        ],
                      ),
                    )
                  ],
                )),
              ),
            ],
          ),
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Dikkat!',
              style: GoogleFonts.raleway(
                  fontSize: 15, fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Uygulamadan çıkmak istiyor musunuz?',
              style: GoogleFonts.raleway(
                  fontSize: 12, fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Hayır',
                  style: GoogleFonts.raleway(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () =>
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
                /*Navigator.of(context).pop(true)*/
                child: Text(
                  'Evet',
                  style: GoogleFonts.raleway(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget moduller() {
    return Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(6),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: modullerListSet(context),
          ),
        ));
  }

  Widget raporlar() {
    return Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(6),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: raporlarListSet(context),
          ),
        ));
  }

  List<Widget> raporlarListSet(BuildContext context) {
    List<Widget> menuList = [];
    menuList.add(InkWell(
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
              color: Colors.white),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10, top: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Satış Tahsilat\nAnalizi",
                      style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800),
                    )),
              ),
              Padding(
                padding: EdgeInsets.only(right: 15, bottom: 10),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FaIcon(
                    FontAwesomeIcons.chartArea,
                    color: Colors.blue.shade900,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          height: 80,
          width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
        ),
        onTap: () async {
          bool? checkAll = await Foksiyonlar.checkAppEngine(context, false);
          if (checkAll == false) return;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SatisTahsilatAnaliziSayfasi()));
        }));
    menuList.add(
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
              color: Colors.white),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10, top: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Döviz Kurları",
                      style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800),
                    )),
              ),
              Padding(
                padding: EdgeInsets.only(right: 15, bottom: 10),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FaIcon(
                    FontAwesomeIcons.coins,
                    color: Colors.blue.shade900,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          height: 80,
          width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
        ),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => DovizKurlariSayfasi(true))),
      ),
    );
    if (UserInfo.fullAccess) {
      menuList.add(InkWell(
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
                color: Colors.white),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Tahsilatlar",
                        style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15, bottom: 10),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FaIcon(
                      FontAwesomeIcons.moneyBillWave,
                      color: Colors.blue.shade900,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            height: 80,
            width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
          ),
          onTap: () async {
            bool? checkAll = await Foksiyonlar.checkAppEngine(context, false);
            if (checkAll == false) return;
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => TahsilatlarSayfasi()));
          }));
    }
    if (!btnCiroTablosu) {
      menuList.add(InkWell(
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
                color: Colors.white),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Ciro Tablosu",
                        style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15, bottom: 10),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FaIcon(
                      FontAwesomeIcons.chartPie,
                      color: Colors.blue.shade900,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            height: 80,
            width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
          ),
          onTap: () async {
            bool? checkAll = await Foksiyonlar.checkAppEngine(context, false);
            if (checkAll == false) return;
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CiroTablosuSayfasi()));
          }));
    }
    if (!btnStokSatisKarlilikRaporu) {
      menuList.add(
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
                  color: Colors.white),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10, top: 10),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Stok Satış\nKarlılık",
                          style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 15, bottom: 10),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: FaIcon(
                        FontAwesomeIcons.chartLine,
                        color: Colors.blue.shade900,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              height: 80,
              width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
            ),
            onTap: () async {
              bool? checkAll = await Foksiyonlar.checkAppEngine(context, false);
              if (checkAll == false) return;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StokSatisKarlilikRaporuSayfasi()));
            }),
      );
    }
    if (!btnPortfoydekiCekler) {
      menuList.add(
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
                  color: Colors.white),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10, top: 10),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Portföydeki\nÇekler",
                          style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 15, bottom: 10),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: FaIcon(
                        FontAwesomeIcons.moneyCheckAlt,
                        color: Colors.blue.shade900,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              height: 80,
              width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
            ),
            onTap: () async {
              bool? checkAll = await Foksiyonlar.checkAppEngine(context, false);
              if (checkAll == false) return;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PortfoydekiCeklerSayfasi()));
            }),
      );
    }
    if (!btnTahsilatlarKonsolide) {
      menuList.add(InkWell(
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
                color: Colors.white),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Tahsilat Bakiye\nAnalizi",
                        style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15, bottom: 10),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FaIcon(
                      FontAwesomeIcons.fileInvoiceDollar,
                      color: Colors.blue.shade900,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            height: 80,
            width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
          ),
          onTap: () async {
            bool? checkAll = await Foksiyonlar.checkAppEngine(context, false);
            if (checkAll == false) return;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TahsilatBakiyeAnaliziSayfasi()));
          }));
    }
    menuList.add(InkWell(
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
                color: Colors.white),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Satış/Ciro\nKaybı",
                        style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15, bottom: 10),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FaIcon(
                      FontAwesomeIcons.chartBar,
                      color: Colors.blue.shade900,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            height: 80,
            width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
          ),
          onTap: () async {
            bool? checkAll = await Foksiyonlar.checkAppEngine(context, false);
            if (checkAll == false) return;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SatisCiroKaybiSayfasi()));
          }),);
    menuList.add(InkWell(
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
                color: Colors.white),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Satış Tahsilat\n(Temsilci)",
                        style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15, bottom: 10),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FaIcon(
                      FontAwesomeIcons.userTie,
                      color: Colors.blue.shade900,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            height: 80,
            width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
          ),
          onTap: () async {
            bool? checkAll = await Foksiyonlar.checkAppEngine(context, false);
            if (checkAll == false) return;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SatisTahsilatTemsilciSayfasi()));
          }),);
    menuList.add(InkWell(
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
                color: Colors.white),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Satış Tahsilat\n(Özet)",
                        style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15, bottom: 10),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FaIcon(
                      FontAwesomeIcons.clipboardList,
                      color: Colors.blue.shade900,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            height: 80,
            width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
          ),
          onTap: () async {
            bool? checkAll = await Foksiyonlar.checkAppEngine(context, false);
            if (checkAll == false) return;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SatisTahsilatOzetSayfasi()));
          }),);

    if(UserInfo.isButceRapor == true) {
      menuList.add(
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
                  color: Colors.white),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10, top: 10),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Bütçe\nGerçekleşen",
                          style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 15, bottom: 10),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: FaIcon(
                        FontAwesomeIcons.handHoldingUsd,
                        color: Colors.blue.shade900,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              height: 80,
              width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
            ),
            onTap: () async {
              bool? checkAll = await Foksiyonlar.checkAppEngine(context, false);
              if (checkAll == false) return;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ButceGerceklesenRaporuSayfasi()));
            }),
      );
    }
    return menuList;
  }

  List<Widget> modullerListSet(BuildContext context) {
    List<Widget> menuList = [];
    menuList.add(
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
                color: Colors.white),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Cariler",
                        style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15, bottom: 10),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FaIcon(
                      FontAwesomeIcons.users,
                      color: Colors.blue.shade900,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            height: 80,
            width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
          ),
          onTap: () async {
            bool? checkAll = await Foksiyonlar.checkAppEngine(context, false);
            if (checkAll == false) return;
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CariAramaView()));
          }),
    );
    menuList.add(InkWell(
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
              color: Colors.white),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10, top: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Stoklar",
                      style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800),
                    )),
              ),
              Padding(
                padding: EdgeInsets.only(right: 15, bottom: 10),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FaIcon(
                    FontAwesomeIcons.boxOpen,
                    color: Colors.blue.shade900,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          height: 80,
          width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
        ),
        onTap: () async {
          bool? checkAll = await Foksiyonlar.checkAppEngine(context, false);
          if (checkAll == false) return;
          if(UserInfo.activeDB == "MikroDB_V16_12"){
            print("zenit");
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ZenitStoklarSayfasi()));

          }else{
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => StoklarSayfasi()));
          }
        }));
    menuList.add(
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
                color: Colors.white),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Aday Cariler",
                        style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15, bottom: 10),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FaIcon(
                      FontAwesomeIcons.userClock,
                      color: Colors.blue.shade900,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            height: 80,
            width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
          ),
          onTap: () async {
            bool? checkAll = await Foksiyonlar.checkAppEngine(context, false);
            if (checkAll == false) return;
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AdayCarilerSayfasi()));
          }),
    );
    menuList.add(InkWell(
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
              color: Colors.white),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10, top: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Bilişim\nTalepleri",
                      style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800),
                    )),
              ),
              Padding(
                padding: EdgeInsets.only(right: 15, bottom: 10),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FaIcon(
                    FontAwesomeIcons.laptopCode,
                    color: Colors.blue.shade900,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          height: 80,
          width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
        ),
        onTap: () async {
          bool? checkAll = await Foksiyonlar.checkAppEngine(context, false);
          if (checkAll == false) return;
          _portalUserControl();
        }));
    menuList.add(
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
                color: Colors.white),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Ziyaretler",
                        style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15, bottom: 10),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FaIcon(
                      FontAwesomeIcons.mapMarkedAlt,
                      color: Colors.blue.shade900,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            height: 80,
            width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
          ),
          onTap: () async {
            bool? checkAll = await Foksiyonlar.checkAppEngine(context, false);
            if (checkAll == false) return;
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ZiyaretPlaniSayfasi()));
          }),
    );

    if (yagizGoster) {
      menuList.add(
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
                  color: Colors.white),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10, top: 10),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Yağız Süt",
                          style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 15, bottom: 10),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: FaIcon(
                        FontAwesomeIcons.yahoo,
                        color: Colors.blue.shade900,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              height: 80,
              width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
            ),
            onTap: () async {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => YagizOzelSayfa()));
            }),
      );
    }
    if (UserInfo.onlineHesabimYetkisi) {
      menuList.add(InkWell(
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
                color: Colors.white),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Bankalar",
                        style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15, bottom: 10),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FaIcon(
                      FontAwesomeIcons.wallet,
                      color: Colors.blue.shade900,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            height: 80,
            width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
          ),
          onTap: () async {
            bool? checkAll = await Foksiyonlar.checkAppEngine(context, false);
            if (checkAll == false) return;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OnlineHesabimSayfasi()));
          }));
    }

    menuList.add(
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
                color: Colors.white),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Ortalama Vade\nHesaplama",
                        style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15, bottom: 10),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FaIcon(
                      FontAwesomeIcons.calculator,
                      color: Colors.blue.shade900,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            height: 80,
            width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
          ),
          onTap: () async {
            bool? checkAll = await Foksiyonlar.checkAppEngine(context, false);
            if (checkAll == false) return;
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => OVHSayfasi()));
          }),
    );
    menuList.add(
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
                color: Colors.white),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Siparişler",
                        style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15, bottom: 10),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FaIcon(
                      FontAwesomeIcons.cartShopping,
                      color: Colors.blue.shade900,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            height: 80,
            width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
          ),
          onTap: () async {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TumAcikSiparis()));

          }),
    );
    menuList.add(
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
                color: Colors.white),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text( "Lojistik", style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade800),)),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15, bottom: 10),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FaIcon(
                      FontAwesomeIcons.truck,
                      color: Colors.blue.shade900,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            height: 80,
            width: (MediaQuery.of(context).size.width - 50) / 2 - 10,
          ),
          onTap: () async {
            bool? checkAll = await Foksiyonlar.checkAppEngine(context, false);
            if (checkAll == false) return;
            else{
              Fluttertoast.showToast(
                  msg: "Modül geliştirme aşamasındadır!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
              return;
            }
           // Navigator.push(context, MaterialPageRoute(builder: (context) => LojistikSayfasi()));
          }),
          );

    return menuList;
  }






  _sifremiUnuttum() async {
    var body = jsonEncode({
      "kullaniciBilgisi": _kullaniciBilgiController.text,
      "telefonBilgi" : TelefonBilgiler.userDeviceInfo
    });
    var response = await http.post(Uri.parse("${Sabitler.url}/api/DreamSifremiUnuttum"),
        headers: {
          "apiKey": Sabitler.apiKey,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body);
    if (response.statusCode == 200) {
      showDialog(
          context: context,
          builder: (context) => BilgilendirmeDialog(
              "Şifreniz kayıtlı mail adresinize gönderildi.\nMailinizi kontrol etmeyi unutmayınız."))
          .then(
              (value) => FocusScope.of(context).requestFocus(new FocusNode()));
    } else if (response.statusCode == 404) {
      showDialog(
          context: context,
          builder: (context) => BilgilendirmeDialog(
              "Bu bilgiye ait kullanıcı bulunamadı.\nBilginizi kontrol edip tekrar deneyebilirsiniz."))
          .then(
              (value) => FocusScope.of(context).requestFocus(new FocusNode()));
    } else {
      showDialog(
          context: context,
          builder: (context) => BilgilendirmeDialog(
              "Şuan sisteme erişilemiyor. Daha sonra tekrar deneyiniz.")).then(
              (value) => FocusScope.of(context).requestFocus(new FocusNode()));
    }
  }

  _sifremiDegistir() async {
    print("debug1");
    print("_kullaniciYeniSifreController.text ${_kullaniciYeniSifreController.text}");
    print("_id ${UserInfo.activeUserId}");

    var response = await http.post(Uri.parse("${Sabitler.url}/api/DreamSifreDegistir?yeniSifre=${_kullaniciYeniSifreController.text}&id=${UserInfo.activeUserId}"),
      headers: {
        "apiKey": Sabitler.apiKey,
      },
    );
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "şifre başarıyla değiştirildi.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Şifre değiştirme başarısız, tekrar deneyin.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }  Navigator.pop(context);
  }
}

class VeriTabanlari {
  String vtIsim;
  String vtAciklama;
  String vtSubeKod;
  VeriTabanlari(this.vtIsim, this.vtAciklama,this.vtSubeKod);
}
