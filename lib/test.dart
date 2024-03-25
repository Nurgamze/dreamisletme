import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:mobile_number/sim_card.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sdsdream_flutter/AnaEkranSayfasi.dart';
import 'package:sdsdream_flutter/OdemeYap.dart';
import 'package:sdsdream_flutter/widgets/Dialoglar.dart';
import 'package:sdsdream_flutter/widgets/MailGondermePopUp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DovizKurlariSayfasi.dart';
import 'modeller/Modeller.dart';
import 'widgets/const_screen.dart';
import 'package:sms_autofill/sms_autofill.dart';

class GirisYapSayfasi extends StatefulWidget {
  @override
  _GirisYapSayfasiState createState() => _GirisYapSayfasiState();
}
class _GirisYapSayfasiState extends State<GirisYapSayfasi> {
  final TextEditingController _mailAdresiController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  final TextEditingController _kullaniciBilgiController = TextEditingController();

  final TextEditingController _kullaniciMailController = TextEditingController();
  final TextEditingController _kullaniciSifreController = TextEditingController();

  TextEditingController _kayitMailKodController = new TextEditingController();
  String dogrulamaKodu = '';
  bool tekrarGonder = false;
  Timer? _timer;
  bool rememberMe = false;
  bool passwordVisible = true;
  String gunYazisi = "";
  String kullaniciIsmi = "";
  FocusNode passFocusNode = new FocusNode();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String _mobileNumber = '';
  List<SimCard> _simCard = <SimCard>[];
  String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());


  final SmsAutoFill _autoFill = SmsAutoFill();
//  final completePhoneNumber =  _autoFill.hint;

  ScrollController _loginController = ScrollController();

  static const platform = const MethodChannel('bluetooth.channel');

  @override
  void initState() {
    super.initState();
    if (!Device.get().isTablet){
      AutoOrientation.portraitAutoMode();
    };
    if (DateTime.now().hour >= 0 && DateTime.now().hour < 6) {
      gunYazisi = "İyi geceler";
    } else if (DateTime.now().hour >= 6 && DateTime.now().hour < 10) {
      gunYazisi = "Günaydın";
    } else if (DateTime.now().hour >= 10 && DateTime.now().hour < 18) {
      gunYazisi = "İyi günler";
    } else if (DateTime.now().hour >= 18 && DateTime.now().hour < 22) {
      gunYazisi = "İyi akşamlar";
    } else if (DateTime.now().hour >= 22 && DateTime.now().hour <= 24) {
      gunYazisi = "İyi geceler";
    }
    Future.delayed(Duration(milliseconds: 500), () {
      try {
        _loginController.jumpTo(_loginController.position.maxScrollExtent);
      } catch (e) {}
    });
    getDeviceInfo();
    checkRemember();
    MobileNumber.listenPhonePermission((isPermissionGranted) {
      if (isPermissionGranted) {
        initMobileNumberState();
      } else {}
    });

    initMobileNumberState();
  }



  @override
  Widget build(BuildContext context) {
    print("rememberMeeeeeeee1  $rememberMe");
    return ConstScreen(
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.only(bottom: Device.get().isIphoneX ? 16 : 0),
            child: !rememberMe ? girisYapNoUser() : girisYapYesUser(),
          ),
        ));
  }

  Future<void> initMobileNumberState() async {
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return;
    }
    try {
      _mobileNumber = (await MobileNumber.mobileNumber)!;
      _simCard = (await MobileNumber.getSimCards)!;
    } on PlatformException catch (e) {
      debugPrint("nedeniyle cep telefonu numarası alınamadı '${e.message}'");
    }

    if (!mounted) return;

    setState(() {});
  }

  Widget fillCards() {
    List<Widget> widgets = _simCard
        .map((SimCard sim) => Text(
        'Sim Card Number: (${sim.countryPhonePrefix}) - ${sim.number}\nCarrier Name: ${sim.carrierName}\nCountry Iso: ${sim.countryIso}\nDisplay Name: ${sim.displayName}\nSim Slot Index: ${sim.slotIndex}\n\n'))
        .toList();
    return Column(children: widgets);
  }

  //ilk giriş
  Widget girisYapNoUser() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    if (TelefonBilgiler.isTablet) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: screenHeight - 150,
              child: Column(
                children: [
                  Container(
                      child: Image(image: AssetImage('assets/images/b2b_isletme_v2.png'), width: 275,
                      )),
                  Container(
                    child: Center(
                      child: AutoSizeText(gunYazisi,
                        style: GoogleFonts.comfortaa(
                          fontWeight: FontWeight.w900,
                        ),
                        minFontSize: 40,
                        maxFontSize: 50,
                      ),
                    ),
                  ),
                  SizedBox( height: screenHeight / 16 ),
                  Container(
                      height: 50,
                      width: 300,
                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                      margin: EdgeInsets.symmetric(horizontal: 30.0,),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.blue.shade900)),
                      child: Center(
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _mailAdresiController,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            hintText: "Kullanıcı adı ",
                            hintStyle: TextStyle(fontWeight: FontWeight.bold),
                            border: InputBorder.none,
                          ),
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(passFocusNode);
                          },
                        ),
                      )),
                  SizedBox(height: 15,),
                  Container(
                      height: 50,
                      width: 300,
                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                      margin: EdgeInsets.symmetric(horizontal: 30.0,),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.blue.shade900)),
                      child: Center(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _sifreController,
                          obscureText: passwordVisible,
                          focusNode: passFocusNode,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: 'Şifreniz',
                            hintStyle: TextStyle(fontWeight: FontWeight.bold),
                            // Here is key idea
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(
                                  passwordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.blue.shade900),
                              onPressed: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            ),
                          ),
                          onFieldSubmitted: (value) async {
                            if (await Foksiyonlar.internetDurumu(context) == true) {
                              if (_mailAdresiController.text == "" || _sifreController.text == "") {

                                showDialog(context: context, builder: (context) => BilgilendirmeDialog("Gerekli alanları doldurduğunuzdan emin olun."));
                              } else {
                                // _checkLogin(_mailAdresiController.text, _sifreController.text, TelefonBilgiler.userDevicePlatform);
                              }
                            }
                          },
                        ),
                      )),
                  SizedBox(height: 10,),
                  Container(
                    height: 50,
                    width: 300,
                    margin: EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.blue.shade900),
                      color: Colors.blue.shade900,
                    ),
                    child: TextButton(
                        onPressed: () async {
                          if (await Foksiyonlar.internetDurumu(context) == true) {
                            if (_mailAdresiController.text == "" || _sifreController.text == "") {
                              showDialog(
                                  context: context,
                                  builder: (context) => BilgilendirmeDialog("Gerekli alanları doldurduğunuzdan emin olun."));
                            } else {
                              print("buradayım1");
                              _checkLogin(_mailAdresiController.text, _sifreController.text, TelefonBilgiler.userDevicePlatform);
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Giriş", style: GoogleFonts.roboto(fontSize: 20, color: Colors.white),)
                          ],
                        )),
                  ),
                ],
              ),
            ),
            Container(
              height: 150,
              child: Stack(
                children: [
                  Align(
                    child: Container(
                      height: 100,
                      color: Color.fromRGBO(22, 65, 147, 1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            child: Container(
                              color: Colors.transparent,
                              height: 90,
                              width: screenWidth / 5,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 34,
                                  ),
                                  Container(
                                    child: Center(
                                      child: Text(
                                        "Şifremi Unuttum?",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(color: Colors.white,fontSize: 19),

                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              _kullaniciBilgiController.clear();
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  insetPadding: EdgeInsets.symmetric(
                                      horizontal:
                                      MediaQuery.of(context).size.width /
                                          10),
                                  backgroundColor: Colors.white,
                                  child: Container(
                                    height: 165,
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          height: 20,
                                          child: Text("Şifremi Unuttum",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18),
                                          ),
                                          margin: EdgeInsets.only(top: 15),
                                        ),
                                        Container(
                                            height: 35,
                                            margin: EdgeInsets.only(top: 20, bottom: 10), padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                            child: Center(
                                              child: TextFormField(
                                                controller: _kullaniciBilgiController,
                                                maxLines: 1,
                                                decoration: InputDecoration(
                                                  contentPadding: EdgeInsets.only(top: 2, left: 5),
                                                  hintText: "Kullanıcı Adı veya Mail giriniz",
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.grey),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.grey),
                                                  ),
                                                ),
                                                cursorColor: Colors.blue.shade900,
                                                style: TextStyle(color: Colors.black),
                                                keyboardType: TextInputType.emailAddress,
                                              ),
                                            )),
                                        Container(
                                          margin: EdgeInsets.only(top: 14),
                                          color: Colors.grey,
                                          height: 1,
                                        ),
                                        Container(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextButton(
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      await _sifremiUnuttum();
                                                    },
                                                    child: Text( "GÖNDER", style: TextStyle(color: Colors.blue),)),
                                              ),
                                              Container(
                                                width: 1,
                                                color: Colors.grey,
                                                height: 50,
                                              ),
                                              Expanded(
                                                child: TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text("İPTAL",
                                                        style: TextStyle(
                                                            color:
                                                            Colors.blue))),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    alignment: Alignment.bottomCenter,
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text(
                          "V${TelefonBilgiler.appVersion}",
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      );
    }





    else {
      return SingleChildScrollView(
        controller: _loginController,
        child: Column(
          children: [
            Container(
              height: Device.get().isIphoneX ? screenHeight - (screenHeight / 5.5 + 66) : screenHeight - (screenHeight / 5.5 + 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20,),
                  Container(
                      child: Image(
                        image: AssetImage('assets/images/b2b_isletme_v2.png'),
                        width: 210,
                      )),
                  Container(
                    child: Center(
                      child: AutoSizeText(gunYazisi, style: GoogleFonts.comfortaa(fontWeight: FontWeight.w900,),
                        minFontSize: 40,
                        maxFontSize: 50,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight / 18,),
                  Container(
                      height: MediaQuery.of(context).size.height / 15,
                      // padding: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                      margin: EdgeInsets.symmetric(horizontal: 30.0,),
                      //decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.blue.shade900)),
                      child: Center(
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _mailAdresiController,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            labelText: "Kullanıcı adı",
                            hintText: "ad.soyad",
                            contentPadding: EdgeInsets.only(top: 2, left: 26),
                            hintStyle: TextStyle(fontWeight: FontWeight.bold),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue.shade900),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue.shade900),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(passFocusNode);
                          },
                        ),
                      )),
                  SizedBox(height: 5,),
                  Container(
                      height: MediaQuery.of(context).size.height / 15,
                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                      margin: EdgeInsets.symmetric(horizontal: 30.0,),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.blue.shade900)),
                      child: Center(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _sifreController,
                          obscureText: passwordVisible,
                          focusNode: passFocusNode,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: 'Şifreniz',
                            hintStyle: TextStyle(fontWeight: FontWeight.bold),
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(passwordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.blue.shade900),
                              onPressed: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            ),
                          ),
                          onFieldSubmitted: (value) async {
                            if (await Foksiyonlar.internetDurumu(context) == true) {
                              if (_mailAdresiController.text == "" || _sifreController.text == "") {

                                showDialog(context: context, builder: (context) => BilgilendirmeDialog("Gerekli alanları doldurduğunuzdan emin olun."));
                              } else {
                                // _checkLogin(_mailAdresiController.text, _sifreController.text, TelefonBilgiler.userDevicePlatform);
                              }
                            }
                          },
                        ),
                      )),
                  SizedBox(height: 25,),
                  Container(
                    height: MediaQuery.of(context).size.height / 15,
                    margin: EdgeInsets.symmetric(horizontal: 30.0,),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.blue.shade900),
                      color: Colors.blue.shade900,
                    ),
                    child: TextButton(
                        onPressed: () async {
                          if (await Foksiyonlar.internetDurumu(context) == true) {
                            if (_mailAdresiController.text == "" || _sifreController.text == "") {
                              showDialog(context: context, builder: (context) => BilgilendirmeDialog("Gerekli alanları doldurduğunuzdan emin olun."));
                            } else {
                              print("kullanıcı maila adresi yani adı::  ${_mailAdresiController.text}");
                              _kayitMailKodController.clear();
                              _checkLogin(_mailAdresiController.text, _sifreController.text, TelefonBilgiler.userDevicePlatform);
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Giriş", style: GoogleFonts.roboto(fontSize: 20, color: Colors.white),)
                          ],
                        )),
                  ),
                ],
              ),
            ),



            ///////////////////////////////////////////////////////////////////////


            Container(
              height: screenHeight / 5.5 + 50,
              child: Stack(
                children: [
                  Align(
                    child: Container(
                      height: 41,
                      // decoration: BoxDecoration(
                      //     image: DecorationImage(
                      //         image: AssetImage("assets/images/shape1.png"),
                      //         fit: BoxFit.fill)
                      // ),
                    ),
                    alignment: Alignment.topCenter,
                  ),
                  Align(
                    child: Container(
                      height: screenHeight / 12,
                      color: Color.fromRGBO(22, 65, 147, 1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            child: Container(
                              color: Colors.transparent,
                              //  height: screenHeight < 700 ? screenHeight / 4 / 1.75 : screenHeight / 4 / 2,
                              width: screenWidth / 2,
                              child: Center(
                                child: Text("Şifremi unuttum?", textAlign: TextAlign.center, style: GoogleFonts.roboto( color: Colors.white),),
                              ),
                            ),
                            onTap: () {
                              _kullaniciBilgiController.clear();
                              showDialog(
                                context: context, builder: (context) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                insetPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 10),
                                backgroundColor: Colors.white,
                                child: Container(
                                  height: 165,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        height: 20,
                                        child: Text("Şifremi Unuttum", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),),
                                        margin: EdgeInsets.only(top: 15),
                                      ),
                                      Container(
                                          height: 35,
                                          margin: EdgeInsets.only(top: 20, bottom: 10),
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                          child: Center(
                                            child: TextFormField(
                                              controller: _kullaniciBilgiController,
                                              maxLines: 1,
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.only(top: 2, left: 5),
                                                hintText: "Kullanıcı Adı veya Mail giriniz",
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.grey),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.grey),
                                                ),
                                              ),
                                              cursorColor: Colors.blue.shade900,
                                              style: TextStyle(color: Colors.black),
                                              keyboardType: TextInputType.emailAddress,
                                            ),
                                          )),
                                      Container(
                                        margin: EdgeInsets.only(top: 14),
                                        color: Colors.grey,
                                        height: 1,
                                      ),
                                      Container(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextButton(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    await _sifremiUnuttum();
                                                  },
                                                  child: Text("GÖNDER", style: TextStyle(color: Colors.blue),)),
                                            ),
                                            Container(
                                              width: 1,
                                              color: Colors.grey,
                                              height: 50,
                                            ),
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
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    alignment: Alignment.bottomCenter,
                  ),
                  SizedBox(width: 11,),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text("V${TelefonBilgiler.appVersion}",
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  //ikinci giriş
  Widget girisYapYesUser() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    if (TelefonBilgiler.isTablet) {
      return Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              color: Color.fromRGBO(22, 65, 147, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    color: Colors.transparent,
                    height: 90,
                    width: screenWidth / 5,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 34,
                        ),
                        Container(
                          child: Center(
                            child: Text(
                              "Şifremi Unuttum?",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(color: Colors.white,fontSize: 19),

                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  "V${TelefonBilgiler.appVersion}",
                  style: TextStyle(color: Colors.white),
                ),
              )),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: screenHeight / 4 * 3,
              child: Column(
                children: [
                  Container(
                      child: Image(
                        image: AssetImage('assets/images/b2b_isletme_v2.png'),
                        width: 275,
                      )),
                  Container(
                    child: Center(
                      child: AutoSizeText(
                        "$gunYazisi,",
                        style: GoogleFonts.comfortaa(
                          fontWeight: FontWeight.w900,
                        ),
                        minFontSize: 40,
                        maxFontSize: 50,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    child: Center(
                      child: AutoSizeText(kullaniciIsmi,
                        style: GoogleFonts.comfortaa(
                          fontWeight: FontWeight.w900,
                        ),
                        minFontSize: 40,
                        maxFontSize: 50,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight / 16,
                  ),
                  InkWell(
                    child: Container(
                      child: Center(
                        child: AutoSizeText("Yoksa $kullaniciIsmi değil misin?",
                          style: GoogleFonts.comfortaa(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade900),
                          minFontSize: 15,
                          maxFontSize: 20,
                        ),
                      ),
                    ),
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          content: Text("Hesabınızdan çıkış yapılacaktır onaylıyor musunuz?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: Text("Hayır")),
                            TextButton(onPressed: () => Navigator.pop(context,true), child: Text("Evet")),
                          ],
                        ),
                      ).then((value) async {
                        if(value == true){
                          SharedPreferences pref = await SharedPreferences.getInstance();
                          pref.clear();
                          _sifreController.clear();
                          _mailAdresiController.clear();
                          setState(() {
                            rememberMe = false;
                          });
                        }
                      });

                    },
                  ),
                  SizedBox(height: 20,),
                  Container(
                    height: 50,
                    width: 300,
                    margin: EdgeInsets.symmetric(horizontal: 30.0,),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.blue.shade900),
                      color: Colors.blue.shade900,
                    ),
                    child: TextButton(
                        onPressed: () async {
                          if (await Foksiyonlar.internetDurumu(context) ==
                              true) {
                            _checkLogin2(_mailAdresiController.text, _sifreController.text, TelefonBilgiler.userDevicePlatform);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Giriş", style: GoogleFonts.roboto(fontSize: 20, color: Colors.white),)
                          ],
                        )),
                  ),
                ],
              ),
            ),
          )
        ],
      );
    }
    else {
      return Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(
                bottom: screenHeight / 5.5 + 9,
              ),
              // child: Image.asset("assets/images/shape1.png")
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight / 12,
              color: Color.fromRGBO(22, 65, 147, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    child: Center(
                      child: Text("Şifremi unuttum!", textAlign: TextAlign.center, style: GoogleFonts.roboto(color: Colors.white),),
                    ),
                    onTap: () {
                      _kullaniciBilgiController.clear();
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          insetPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 10),
                          backgroundColor: Colors.white,
                          child: Container(
                            height: 165,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: 20,
                                  child: Text("Şifremi Unuttum",
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),),
                                  margin: EdgeInsets.only(top: 15),
                                ),
                                Container(height: 35,
                                    margin: EdgeInsets.only(top: 20, bottom: 10),
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                    child: Center(
                                      child: TextFormField(
                                        controller: _kullaniciBilgiController,
                                        maxLines: 1,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.only(top: 2, left: 5),
                                          hintText: "Kullanıcı Adı veya Mail giriniz",
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey),
                                          ),
                                        ),
                                        cursorColor: Colors.blue.shade900,
                                        style: TextStyle(color: Colors.black),
                                        keyboardType: TextInputType.emailAddress,
                                      ),
                                    )),
                                Container(
                                  margin: EdgeInsets.only(top: 14),
                                  color: Colors.grey,
                                  height: 1,
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);await _sifremiUnuttum();
                                            },
                                            child: Text("GÖNDER", style: TextStyle(color: Colors.blue),)),
                                      ),
                                      Container( width: 1, color: Colors.grey, height: 50,),
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
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 0),
                child: Text("V${TelefonBilgiler.appVersion}",
                  style: TextStyle(color: Colors.white),
                ),
              )),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: screenHeight / 4 * 3,
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(child: Image(
                    image: AssetImage('assets/images/b2b_isletme_v2.png',),
                    fit: BoxFit.cover,
                    width: 250,
                  )),
                  Container(
                    child: Center(
                      child: AutoSizeText("$gunYazisi,",
                        style: GoogleFonts.comfortaa(fontWeight: FontWeight.w900,),
                        minFontSize: 40,
                        maxFontSize: 50,
                      ),
                    ),
                  ),
                  SizedBox(height: 5,),
                  Container(
                    child: Center(
                      child: AutoSizeText(kullaniciIsmi, style: GoogleFonts.comfortaa(fontWeight: FontWeight.w900,),
                        minFontSize: 40,
                        maxFontSize: 50,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight / 18,),
                  InkWell(
                    child: Container(
                      child: Center(
                        child: AutoSizeText("Yoksa $kullaniciIsmi değil misin?",
                          style: GoogleFonts.comfortaa(fontWeight: FontWeight.w600, color: Colors.blue.shade900),
                          minFontSize: 15,
                          maxFontSize: 20,
                        ),
                      ),
                    ),
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          content: Text("Hesabınızdan çıkış yapılacaktır onaylıyor musunuz?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: Text("Hayır")),
                            TextButton(onPressed: () => Navigator.pop(context,true), child: Text("Evet")),
                          ],
                        ),
                      ).then((value) async {
                        if(value == true){
                          SharedPreferences pref = await SharedPreferences.getInstance();
                          pref.clear();
                          _sifreController.clear();
                          _mailAdresiController.clear();
                          setState(() {
                            rememberMe = false;
                          });
                        }
                      });
                    },
                  ),
                  SizedBox(height: 20,),
                  Container(
                    height: MediaQuery.of(context).size.height / 15,
                    margin: EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.blue.shade900),
                      color: Colors.blue.shade900,
                    ),
                    child: TextButton(
                        onPressed: () async {
                          if (await Foksiyonlar.internetDurumu(context) == true) {
                            _checkLogin2(_mailAdresiController.text, _sifreController.text, TelefonBilgiler.userDevicePlatform);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //Text("Giriş3", style: GoogleFonts.roboto(fontSize: 20, color: Colors.white),)
                            Text("Giriş", style: GoogleFonts.roboto(fontSize: 20, color: Colors.white),)
                          ],
                        )),
                  ),
                ],
              ),
            ),
          )
        ],
      );
    }
  }


  Future checkRemember() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getString("userMail") != null) {
      setState(() {
        _mailAdresiController.text = pref.getString("userMail")!;
        _sifreController.text = pref.getString("password")!;
        kullaniciIsmi = pref.getString("userName")!;
        try {
          UserInfo.aktifSubeNo = pref.getString("zenitSubeKod");
        } catch (e) {
          UserInfo.aktifSubeNo = "";
        }
        rememberMe = true;
        print("burada işim bitti");
      });
    } else {
      print("burada işim bitmedi");
      rememberMe = false;
    }
  }

  void _kodGonder (String userName) async {
    print("id ye bakıyoss ${userName}");
    var response  = await http.get(Uri.parse("${Sabitler.url}/api/Dogrulama?userName=${userName}",),
      headers: {
        "apiKey": Sabitler.apiKey,
      },
    );
    if(response.statusCode == 200){
      dogrulamaKodu  = response.body;
      print("doğrulamakodu ${dogrulamaKodu }");
      dogrulamaKodu  = json.decode(response.body);
      _timerCheck();
    }else{
      dogrulamaKodu  = 'Failed to fetch verification code';
    }
    return;
  }

  _timerCheck() {
    _timer = Timer(Duration(seconds: 125), () {
      setState(() {
        tekrarGonder = true;
      });
    });
  }

  _checkLogin(String userName, String password, String platform ) async {
    showDialog(
        context: context,
        builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 3),
            elevation: 0,
            child: Container(
              height: MediaQuery.of(context).size.width / 2,
              width: MediaQuery.of(context).size.width / 2,
              child: Image.asset("assets/images/sdsLoading.gif"),
            )));

    print("debug1");
    late http.Response response;
    var body = jsonEncode({"userName": userName, "password": password});

    _kodGonder(userName);
    await showDialog(context: context, builder: (context)=>Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Column(
          children: [
            Container(height: 20,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  keyboardType: TextInputType.number ,
                  textAlign: TextAlign.center,
                  controller: _kayitMailKodController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Mailinize gelen kodu giriniz.',
                  ),
                  inputFormatters:[
                    LengthLimitingTextInputFormatter(6),
                  ]
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Center(
                  child: Column(
                    children: [
                      Container(
                        child:  Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  child: Text("Tekrar Gönder",style: TextStyle(color: Colors.grey.shade200),),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                        side: BorderSide(color: tekrarGonder ? Colors.blue : Colors.grey,)
                                    ),
                                  ),
                                  onPressed: () {
                                    print("kod kontrolü");
                                    if (_kayitMailKodController.text.isNotEmpty && dogrulamaKodu != null) {
                                      // Doğrulama kodu kontrolü
                                      if (_kayitMailKodController.text == dogrulamaKodu) {
                                        print("_kayitMailKodController.text ${_kayitMailKodController.text}");
                                        print("dogrulamaKodu ${dogrulamaKodu}");
                                        // Doğrulama kodu doğru ise anasayfaya yönlendirme
                                        _kayitMailKodController.clear();

                                        Navigator.push(context, MaterialPageRoute(builder: (context) => AnaEkranSayfasi()),);
                                        _timer!.cancel();
                                      } else {
                                        // Doğrulama kodu yanlış ise uyarı gösterme
                                        Fluttertoast.showToast(
                                            msg:  "Girdiğiniz kod yanlış",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            textColor: Colors.white,
                                            backgroundColor: Colors.green.shade600,
                                            fontSize: 16.0
                                        );
                                      }
                                    }else{

                                      setState(() {
                                        // kayitKod = "9999999";
                                        tekrarGonder = false;
                                      });
                                      _kodGonder(userName);
                                      Fluttertoast.showToast(
                                          msg:  "Mailinize doğrulama amaçlı kod gönderilmiştir kontrol ediniz.",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          textColor: Colors.white,
                                          backgroundColor: Colors.blue.shade900,
                                          fontSize: 16.0
                                      );
                                    }
                                  },
                                ),),
                              SizedBox(width: 10,),
                              Expanded(
                                  child: ElevatedButton(
                                    child: Text("Onayla",style: TextStyle(color: Colors.grey.shade200),),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                          side: BorderSide(color: Colors.green)
                                      ),
                                    ),
                                    onPressed: () async {
                                      print("dogrulamakoduuuuuu ${dogrulamaKodu}");
                                      print("_kayitMailKodController.text ${_kayitMailKodController.text}");
                                      print("_dogrulamaKodu ${dogrulamaKodu}");
                                      if(_kayitMailKodController.text == dogrulamaKodu){
                                        //kod doğruysa giriş yap sayafasındaki checklogin ile giriş yapmalılar
                                        print("giriş yapabilir");

                                        try {
                                          response = await http.post(Uri.parse("${Sabitler.url}/api/GetUserInfoV2"),
                                              headers: {
                                                "apiKey": Sabitler.apiKey,
                                                'Content-Type': 'application/json; charset=UTF-8',
                                              },
                                              body: body)
                                              .timeout(Duration(seconds: 15));
                                          print(response.request);
                                          print(body);
                                          print(response.headers);
                                        } on TimeoutException catch (e) {
                                          Navigator.pop(context);
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return BilgilendirmeDialog(
                                                    "Sunucuya bağlanılamadı internetinizi kontrol ediniz");
                                              });
                                        } on Error catch (e) {
                                          Navigator.pop(context);
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return BilgilendirmeDialog(
                                                    "Sunucuya bağlanılamadı internetinizi kontrol ediniz");
                                              });
                                        }
                                        if (response.statusCode == 200) {
                                          rememberMe = true;
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
                                            UserInfo.lastLoginDate = data["LastLoginDate"];
                                            UserInfo.dateTimeNow = data["NowDate"];
                                          }
                                          SharedPreferences pref = await SharedPreferences.getInstance();
                                          bool? checkAll = await Foksiyonlar.checkAppEngine(context, true);
                                          if (checkAll == true) {

                                            if (rememberMe) {
                                              print("rememberMe true");
                                              pref.setBool("_rememberMe", true);
                                              pref.setString("userMail", userName);
                                              pref.setString("password", password);
                                              pref.setString("userName", UserInfo.ad == null ? "" : UserInfo.ad!);
                                              pref.setString("lastLoginDate",formattedDate);
                                              print("sonDate :${formattedDate}");

                                            } else {

                                              pref.setBool("_rememberMe", false);
                                              pref.setString("userMail", "");
                                              pref.setString("password", "");
                                            }
                                            try {
                                              print("AAAAAAAAAA");
                                              UserInfo.aktifSubeNo = pref.getString("zenitSubeKod");
                                              print("aktifSubeNo = ${UserInfo.aktifSubeNo}");
                                              print("tel no  = $_mobileNumber");
                                              Navigator.push(context, MaterialPageRoute(builder: (context)=>AnaEkranSayfasi()));

                                            } catch (e) {
                                              UserInfo.aktifSubeNo = "";
                                            }
                                          } else {
                                            if (rememberMe) {
                                              pref.setBool("_rememberMe", true);
                                              pref.setString("userMail", userName);
                                              pref.setString("password", password);
                                              pref.setString("userName", UserInfo.ad == null ? "" : UserInfo.ad!);
                                            } else {
                                              pref.setBool("_rememberMe", false);
                                              pref.setString("userMail", "");
                                              pref.setString("password", "");
                                            }
                                            try {
                                              UserInfo.aktifSubeNo = pref.getString("zenitSubeKod");
                                            } catch (e) {
                                              UserInfo.aktifSubeNo = "";
                                            }
                                            UserInfo.activeDB = null;
                                          }
                                        }
                                        else if (response.statusCode == 404) {
                                          Navigator.pop(context);
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  insetPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/10),
                                                  child: Container(
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                            child: Text("Giriş yapılamadı...\nKullanıcı bilgilerinizi kontrol edip tekrar deneyiniz.",style: TextStyle(color: Colors.black,fontSize: 17),maxLines: 4,textAlign: TextAlign.center,),
                                                            margin: EdgeInsets.only(top: 10,bottom: 10),
                                                            padding: EdgeInsets.only(left: 5,top: 10,bottom: 0,right: 5)
                                                        ),
                                                        Divider(color: Colors.grey,thickness: 1,),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.of(context).pop("ok");
                                                              Navigator.push(context, MaterialPageRoute(builder: (context)=>GirisYapSayfasi()));
                                                            } ,
                                                            child: Container(
                                                              child: Text("TAMAM",style: TextStyle(color: Colors.blue,),textAlign: TextAlign.center,),
                                                              width: double.infinity,
                                                            )
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });

                                          print("buradan devam ");
                                          //  _checkLogin(_mailAdresiController.text, _sifreController.text, TelefonBilgiler.userDevicePlatform);
                                        } else {
                                          Navigator.pop(context);
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return BilgilendirmeDialog("Biraz sonra tekrar deneyiniz, aynı hatayı almaya devam ederseniz\nSDS BİLİŞİM ekibiyle iletişime geçiniz");
                                              });
                                        }
                                        // _checkLogin(_mailAdresiController.text, _sifreController.text, TelefonBilgiler.userDevicePlatform);
                                        //  _timer!.cancel();
                                      }else{
                                        _kayitMailKodController.clear();
                                        Fluttertoast.showToast(
                                            msg:  "Girdiğiniz kod yanlış",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            textColor: Colors.white,
                                            backgroundColor: Colors.green.shade600,
                                            fontSize: 16.0
                                        );
                                      }
                                    },
                                  ))
                            ],
                          ),
                        ),
                      )
                    ],
                  )
              ),
            ),
          ],
        ),
      ),
    ),);
  }

  _checkLogin2(String userName, String password, String platform ) async {
    showDialog(
        context: context,
        builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 3),
            elevation: 0,
            child: Container(
              height: MediaQuery.of(context).size.width / 2,
              width: MediaQuery.of(context).size.width / 2,
              child: Image.asset("assets/images/sdsLoading.gif"),
            )));

    late http.Response response;
    var body = jsonEncode({"userName": userName, "password": password});
    try {
      response = await http.post(Uri.parse("${Sabitler.url}/api/GetUserInfoV2"),
          headers: {
            "apiKey": Sabitler.apiKey,
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: body).timeout(Duration(seconds: 15));
      print(response.request);
      print(body);
      print(response.headers);
      print("response.bodysi ${response.body}");

    } on TimeoutException catch (e) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BilgilendirmeDialog(
                "Sunucuya bağlanılamadı internetinizi kontrol ediniz");
          });
    } on Error catch (e) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BilgilendirmeDialog(
                "Sunucuya bağlanılamadı internetinizi kontrol ediniz");
          });
    }
    if (response.statusCode == 200) {
      print("responsstatuskod 200 ise");
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
        UserInfo.lastLoginDate = data["LastLoginDate"];
        UserInfo.dateTimeNow = data["NowDate"];

        DateTime? lastLoginDate = DateTime.tryParse(data["LastLoginDate"]);
        DateTime? nowDate = DateTime.tryParse(data["NowDate"]);

        print("son giriş ${lastLoginDate}");
        print("şimdi  ${nowDate}");

        Duration difference = nowDate!.difference(lastLoginDate!);
        print("gün farkı ${difference}");

        if (difference.inDays > 5) {
          print("5 günden faazla");
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Uygulamaya son girişinizin üzerinden bir haftadan fazla gün geçti.\nLütfen tekrar giriş yapın"),
              ),
              actions: [
                Container(
                  child: TextButton(onPressed: () => Navigator.pop(context,true), child: Text("Tamam",style: TextStyle(color: Colors.black,fontSize: 15),)),
                  width: double.infinity,
                ),
              ],
            ),
          ).then((value) async {
            if(value == true){
              SharedPreferences pref = await SharedPreferences.getInstance();
              pref.clear();
              _sifreController.clear();
              _mailAdresiController.clear();
              setState(() {
                rememberMe = true;
                Navigator.push(context, MaterialPageRoute(builder: (context)=>GirisYapSayfasi()));
              });
            }}
          );}
        else{
          print("5 günden az");
          SharedPreferences pref = await SharedPreferences.getInstance();
          bool? checkAll = await Foksiyonlar.checkAppEngine(context, true);
          if (checkAll == true) {
            if (rememberMe) {
              pref.setBool("_rememberMe", true);
              pref.setString("userMail", userName);
              pref.setString("password", password);
              pref.setString("userName", UserInfo.ad == null ? "" : UserInfo.ad!);
              pref.setString("lastLoginDate giriş iki ",formattedDate);
              print("sonDate giriş iki :${formattedDate}");
            } else {
              pref.setBool("_rememberMe", false);
              pref.setString("userMail", "");
              pref.setString("password", "");
            }
            try {
              print("AAAAAAAAAA");
              UserInfo.aktifSubeNo = pref.getString("zenitSubeKod");
              print("aktifSubeNo = ${UserInfo.aktifSubeNo}");
              print("tel no  = $_mobileNumber");
              Navigator.push(context, MaterialPageRoute(builder: (context)=>AnaEkranSayfasi()));

            } catch (e) {
              UserInfo.aktifSubeNo = "";
            }
          } else {
            if (rememberMe) {
              pref.setBool("_rememberMe", true);
              pref.setString("userMail", userName);
              pref.setString("password", password);
              pref.setString("userName", UserInfo.ad == null ? "" : UserInfo.ad!);
              print("1");

            } else {
              pref.setBool("_rememberMe", false);
              pref.setString("userMail", "");
              pref.setString("password", "");
              print("2");
            }
            try {
              UserInfo.aktifSubeNo = pref.getString("zenitSubeKod");
            } catch (e) {
              UserInfo.aktifSubeNo = "";
            }
            UserInfo.activeDB = null;
          }
        }
      }
    }
    else if (response.statusCode == 404) {
      print("responsstatuskod 404 ise");
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Text("Kullanıcı bilgileriniz hatalıdır.\n Lütfen tekrar giriş yapınız!"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Hayır")),
            TextButton(onPressed: () => Navigator.pop(context,true), child: Text("Evet")),
          ],
        ),
      ).then((value) async {
        if(value == true){
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.clear();
          _sifreController.clear();
          _mailAdresiController.clear();
          setState(() {
            rememberMe = true;
            Navigator.push(context, MaterialPageRoute(builder: (context)=>GirisYapSayfasi()));
          });
        }
      });
    } else {
      print("responsstatuskod 4sfsdfsd4 ise");
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BilgilendirmeDialog("Biraz sonra tekrar deneyiniz, aynı hatayı almaya devam ederseniz\nSDS BİLİŞİM ekibiyle iletişime geçiniz");
          });
    }
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
    print("mailBilgisi ${_kullaniciMailController.text}");
    print("sifreBilgisi ${_kullaniciSifreController.text}");
    print("telefonBilgi ${TelefonBilgiler.userDeviceInfo}");

    var body = jsonEncode({
      "mailBilgisi":_kullaniciMailController.text,
      "sifreBilgisi":_kullaniciSifreController.text,
      "telefonBilgi" : TelefonBilgiler.userDeviceInfo
    });
    print( "mailBilgisi:${_kullaniciMailController.text}");
    print( "sifreBilgisi:${_kullaniciSifreController.text}");

    var response = await http.post(Uri.parse("${Sabitler.url}/api/DreamSifremiDegistir"),
        headers: {
          "apiKey": Sabitler.apiKey,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body);
    if (response.statusCode == 200) {
      showDialog(
          context: context,
          builder: (context) => BilgilendirmeDialog(
              "Şifreniz başarılı bir şekilde değiştirildi.")).then(
              (value) => FocusScope.of(context).requestFocus(new FocusNode()));
    } else if (response.statusCode == 404) {
      showDialog(
          context: context,
          builder: (context) => BilgilendirmeDialog("Bu bilgiye ait kullanıcı bulunamadı.\nBilginizi kontrol edip tekrar deneyebilirsiniz."))
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






  Future getDeviceInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (Platform.isAndroid) {
      String deviceName = await platform.invokeMethod("deviceName");
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      TelefonBilgiler.userDevicePlatform = "SDSDreamFAndroid";
      TelefonBilgiler.userDeviceInfo = "${androidInfo.brand}  | ${androidInfo.model} | ${androidInfo.version.release} | ${deviceName.replaceAll("'", "''")}";
      TelefonBilgiler.userAppVersion = packageInfo.version + " | " + packageInfo.buildNumber + " | F";
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      String model = "";
      switch (iosInfo.utsname.machine) {
        case "iPhone6,1":
          {
            model = "iPhone 5s";
          }
          break;
        case "iPhone6,2":
          {
            model = "iPhone 5s";
          }
          break;
        case "iPhone7,2":
          {
            model = "iPhone 6";
          }
          break;
        case "iPhone7,1":
          {
            model = "iPhone 6 Plus";
          }
          break;
        case "iPhone8,1":
          {
            model = "iPhone 6s";
          }
          break;
        case "iPhone8,2":
          {
            model = "iPhone 6s Plus";
          }
          break;
        case "iPhone9,1":
          {
            model = "iPhone 7";
          }
          break;
        case "iPhone9,3":
          {
            model = "iPhone 7";
          }
          break;
        case "iPhone9,2":
          {
            model = "iPhone 7 Plus";
          }
          break;
        case "iPhone9,4":
          {
            model = "iPhone 7 Plus";
          }
          break;
        case "iPhone8,4":
          {
            model = "iPhone SE";
          }
          break;
        case "iPhone10,1":
          {
            model = "iPhone 8";
          }
          break;
        case "iPhone10,4":
          {
            model = "iPhone 8";
          }
          break;
        case "iPhone10,2":
          {
            model = "iPhone 8 Plus";
          }
          break;
        case "iPhone10,5":
          {
            model = "iPhone 8 Plus";
          }
          break;
        case "iPhone10,3":
          {
            model = "iPhone X";
          }
          break;
        case "iPhone10,6":
          {
            model = "iPhone X";
          }
          break;
        case "iPhone11,2":
          {
            model = "iPhone XS";
          }
          break;
        case "iPhone11,4":
          {
            model = "iPhone XS Max";
          }
          break;
        case "iPhone11,6":
          {
            model = "iPhone XS Max";
          }
          break;
        case "iPhone11,8":
          {
            model = "iPhone XR";
          }
          break;
        case "iPhone12,1":
          {
            model = "iPhone 11";
          }
          break;
        case "iPhone12,3":
          {
            model = "iPhone 11 Pro";
          }
          break;
        case "iPhone12,5":
          {
            model = "iPhone 11 Pro Max";
          }
          break;
        default:
          {
            model = "iPhone";
          }
          break;
      }
      TelefonBilgiler.userDevicePlatform = "SDSDreamFXiOS";
      TelefonBilgiler.userDeviceInfo = "Apple | $model | ${iosInfo.systemVersion} | ${iosInfo.name?.replaceAll("'", "''")}";
      TelefonBilgiler.userAppVersion = packageInfo.version + " | " + packageInfo.buildNumber + " | F";
    }
  }


}
