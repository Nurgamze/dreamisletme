import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sdsdream_flutter/AnaEkranSayfasi.dart';
import 'package:sdsdream_flutter/OdemeYap.dart';
import 'package:sdsdream_flutter/widgets/Dialoglar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_redirect/store_redirect.dart';
import 'DovizKurlariSayfasi.dart';
import 'modeller/Modeller.dart';
import 'widgets/const_screen.dart';

class GirisYapSayfasi extends StatefulWidget {
  @override
  _GirisYapSayfasiState createState() => _GirisYapSayfasiState();
}

class _GirisYapSayfasiState extends State<GirisYapSayfasi> {
  final TextEditingController _mailAdresiController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  final TextEditingController _kullaniciBilgiController =
      TextEditingController();

  bool rememberMe = false;
  bool passwordVisible = true;
  String gunYazisi = "";
  String kullaniciIsmi = "";
  FocusNode passFocusNode = new FocusNode();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

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
  }

  @override
  Widget build(BuildContext context) {
    return ConstScreen(
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.only(bottom: Device.get().isIphoneX ? 16 : 0),
            child: !rememberMe ? girisYapNoUser() : girisYapYesUser(),
      ),
    ));
  }

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
                      child: Image(
                    image: AssetImage('assets/images/b2b_isletme_v2.png'),
                    width: 275,
                  )),
                  Container(
                    child: Center(
                      child: AutoSizeText(
                        gunYazisi,
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
                            hintText: "Kullanıcı adı",
                            hintStyle: TextStyle(fontWeight: FontWeight.bold),
                            border: InputBorder.none,
                          ),
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(passFocusNode);
                          },
                        ),
                      )),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      height: 50,
                      width: 300,
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                      margin: EdgeInsets.symmetric(
                        horizontal: 30.0,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.blue.shade900)),
                      child: Center(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _sifreController,
                          obscureText: passwordVisible,
                          focusNode: passFocusNode,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: 'Şifreniz',
                            hintStyle: TextStyle(fontWeight: FontWeight.bold),
                            // Here is key idea
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(
                                  // Based on passwordVisible state choose the icon
                                  passwordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.blue.shade900),
                              onPressed: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            ),
                          ),
                          onFieldSubmitted: (value) async {
                            if (await Foksiyonlar.internetDurumu(context) == true) {
                              if (_mailAdresiController.text == "" ||
                                  _sifreController.text == "") {
                                showDialog(
                                    context: context,
                                    builder: (context) => BilgilendirmeDialog(
                                        "Gerekli alanları doldurduğunuzdan emin olun."));
                              } else {
                                _checkLogin(
                                    _mailAdresiController.text,
                                    _sifreController.text,
                                    TelefonBilgiler.userDevicePlatform);
                              }
                            }
                          },
                        ),
                      )),
                  SizedBox(
                    height: 10,
                  ),
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
                          if (await Foksiyonlar.internetDurumu(context) ==
                              true) {
                            if (_mailAdresiController.text == "" ||
                                _sifreController.text == "") {
                              showDialog(
                                  context: context,
                                  builder: (context) => BilgilendirmeDialog(
                                      "Gerekli alanları doldurduğunuzdan emin olun."));
                            } else {
                              _checkLogin(
                                  _mailAdresiController.text,
                                  _sifreController.text,
                                  TelefonBilgiler.userDevicePlatform);
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Giriş",
                              style: GoogleFonts.roboto(
                                  fontSize: 20, color: Colors.white),
                            )
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
                      height: 150,
                      color: Color.fromRGBO(22, 65, 147, 1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            child: Container(
                              color: Colors.transparent,
                              height: 110,
                              width: screenWidth / 5,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Center(
                                        child: FaIcon(
                                          FontAwesomeIcons.coins,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    child: Center(
                                      child: Text(
                                        "Döviz\nkurları",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              if(!rememberMe){
                                return;
                              }
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DovizKurlariSayfasi(false)));
                            },
                          ),
                          InkWell(
                            child: Container(
                              color: Colors.transparent,
                              height: 110,
                              width: screenWidth / 5,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Center(
                                        child: FaIcon(
                                          FontAwesomeIcons.stripeS,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    child: Center(
                                      child: Text(
                                        "SDS\ne-Tahsilat",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          OdemeSayfasi(false)));
                            },
                          ),
                          InkWell(
                            child: Container(
                              color: Colors.transparent,
                              height: 110,
                              width: screenWidth / 5,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Center(
                                        child: FaIcon(
                                          FontAwesomeIcons.hryvnia,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    child: Center(
                                      child: Text(
                                        "Zenitled\ne-Tahsilat",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          OdemeSayfasi(true)));
                            },
                          ),
                          InkWell(
                            child: Container(
                              color: Colors.transparent,
                              height: 110,
                              width: screenWidth / 5,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Center(
                                        child: FaIcon(
                                          FontAwesomeIcons.question,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    child: Center(
                                      child: Text(
                                        "Şifremi\nunuttum",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                            color: Colors.white),
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
                                          child: Text(
                                            "Şifremi Unuttum",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18),
                                          ),
                                          margin: EdgeInsets.only(top: 15),
                                        ),
                                        Container(
                                            height: 35,
                                            margin: EdgeInsets.only(
                                                top: 20, bottom: 10),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 0),
                                            child: Center(
                                              child: TextFormField(
                                                controller:
                                                    _kullaniciBilgiController,
                                                maxLines: 1,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          top: 2, left: 5),
                                                  hintText:
                                                      "Kullanıcı Adı veya Mail giriniz",
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                                cursorColor:
                                                    Colors.blue.shade900,
                                                style: TextStyle(
                                                    color: Colors.black),
                                                keyboardType:
                                                    TextInputType.emailAddress,
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
                                                    child: Text(
                                                      "GÖNDER",
                                                      style: TextStyle(
                                                          color: Colors.blue),
                                                    )),
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
    } else {
      return SingleChildScrollView(
        controller: _loginController,
        child: Column(
          children: [
            Container(
              height: Device.get().isIphoneX
                  ? screenHeight - (screenHeight / 5.5 + 66)
                  : screenHeight - (screenHeight / 5.5 + 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      child: Image(
                    image: AssetImage('assets/images/b2b_isletme_v2.png'),
                    width: 210,
                  )),
                  Container(
                    child: Center(
                      child: AutoSizeText(
                        gunYazisi,
                        style: GoogleFonts.comfortaa(
                          fontWeight: FontWeight.w900,
                        ),
                        minFontSize: 40,
                        maxFontSize: 50,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight / 18,
                  ),
                  Container(
                      height: MediaQuery.of(context).size.height / 15,
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                      margin: EdgeInsets.symmetric(
                        horizontal: 30.0,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.blue.shade900)),
                      child: Center(
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _mailAdresiController,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: "Kullanıcı adı",
                            hintStyle: TextStyle(fontWeight: FontWeight.bold),
                            border: InputBorder.none,
                          ),
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(passFocusNode);
                          },
                        ),
                      )),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      height: MediaQuery.of(context).size.height / 15,
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                      margin: EdgeInsets.symmetric(
                        horizontal: 30.0,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.blue.shade900)),
                      child: Center(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _sifreController,
                          obscureText: passwordVisible,
                          focusNode: passFocusNode,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: 'Şifreniz',
                            hintStyle: TextStyle(fontWeight: FontWeight.bold),
                            // Here is key idea
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(
                                  // Based on passwordVisible state choose the icon
                                  passwordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.blue.shade900),
                              onPressed: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            ),
                          ),
                          onFieldSubmitted: (value) async {
                            if (await Foksiyonlar.internetDurumu(context) ==
                                true) {
                              if (_mailAdresiController.text == "" ||
                                  _sifreController.text == "") {
                                showDialog(
                                    context: context,
                                    builder: (context) => BilgilendirmeDialog(
                                        "Gerekli alanları doldurduğunuzdan emin olun."));
                              } else {
                                _checkLogin(
                                    _mailAdresiController.text,
                                    _sifreController.text,
                                    TelefonBilgiler.userDevicePlatform);
                              }
                            }
                          },
                        ),
                      )),
                  SizedBox(
                    height: 10,
                  ),
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
                          if (await Foksiyonlar.internetDurumu(context) ==
                              true) {
                            if (_mailAdresiController.text == "" ||
                                _sifreController.text == "") {
                              showDialog(
                                  context: context,
                                  builder: (context) => BilgilendirmeDialog(
                                      "Gerekli alanları doldurduğunuzdan emin olun."));
                            } else {
                              _checkLogin(
                                  _mailAdresiController.text,
                                  _sifreController.text,
                                  TelefonBilgiler.userDevicePlatform);
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Giriş",
                              style: GoogleFonts.roboto(
                                  fontSize: 20, color: Colors.white),
                            )
                          ],
                        )),
                  ),
                ],
              ),
            ),
            Container(
              height: screenHeight / 5.5 + 50,
              child: Stack(
                children: [
                  Align(
                    child: Container(
                      height: 41,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/images/shape1.png"),
                              fit: BoxFit.fill)),
                    ),
                    alignment: Alignment.topCenter,
                  ),
                  Align(
                    child: Container(
                      height: screenHeight / 5.5 + 10,
                      color: Color.fromRGBO(22, 65, 147, 1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            child: Container(
                              color: Colors.transparent,
                              height: screenHeight < 700
                                  ? screenHeight / 4 / 1.75
                                  : screenHeight / 4 / 2,
                              width: screenWidth / 5,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Center(
                                        child: FaIcon(
                                          FontAwesomeIcons.coins,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    child: Center(
                                      child: Text(
                                        "Döviz\nkurları",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              if(!rememberMe){
                                return;
                              }
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DovizKurlariSayfasi(false)));
                            },
                          ),
                          InkWell(
                            child: Container(
                              color: Colors.transparent,
                              height: screenHeight < 700
                                  ? screenHeight / 4 / 1.75
                                  : screenHeight / 4 / 2,
                              width: screenWidth / 5,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Center(
                                        child: FaIcon(
                                          FontAwesomeIcons.stripeS,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    child: Center(
                                      child: Text(
                                        "SDS\ne-Tahsilat",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          OdemeSayfasi(false)));
                            },
                          ),
                          InkWell(
                            child: Container(
                              color: Colors.transparent,
                              height: screenHeight < 700
                                  ? screenHeight / 4 / 1.75
                                  : screenHeight / 4 / 2,
                              width: screenWidth / 5,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Center(
                                        child: FaIcon(
                                          FontAwesomeIcons.hryvnia,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    child: Center(
                                      child: Text(
                                        "Zenitled\ne-Tahsilat",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          OdemeSayfasi(true)));
                            },
                          ),
                          InkWell(
                            child: Container(
                              color: Colors.transparent,
                              height: screenHeight < 700
                                  ? screenHeight / 4 / 1.75
                                  : screenHeight / 4 / 2,
                              width: screenWidth / 5,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Center(
                                        child: FaIcon(
                                          FontAwesomeIcons.question,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    child: Center(
                                      child: Text(
                                        "Şifremi\nunuttum",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                            color: Colors.white),
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
                                          child: Text(
                                            "Şifremi Unuttum",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18),
                                          ),
                                          margin: EdgeInsets.only(top: 15),
                                        ),
                                        Container(
                                            height: 35,
                                            margin: EdgeInsets.only(
                                                top: 20, bottom: 10),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 0),
                                            child: Center(
                                              child: TextFormField(
                                                controller:
                                                    _kullaniciBilgiController,
                                                maxLines: 1,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          top: 2, left: 5),
                                                  hintText:
                                                      "Kullanıcı Adı veya Mail giriniz",
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                                cursorColor:
                                                    Colors.blue.shade900,
                                                style: TextStyle(
                                                    color: Colors.black),
                                                keyboardType:
                                                    TextInputType.emailAddress,
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
                                                    child: Text(
                                                      "GÖNDER",
                                                      style: TextStyle(
                                                          color: Colors.blue),
                                                    )),
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
            )
          ],
        ),
      );
    }
  }

  Widget girisYapYesUser() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    if (TelefonBilgiler.isTablet) {
      return Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 150,
              color: Color.fromRGBO(22, 65, 147, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    child: Container(
                      color: Colors.transparent,
                      height: 110,
                      width: screenWidth / 5,
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.coins,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                "Döviz\nkurları",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      if(!rememberMe){
                        return;
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DovizKurlariSayfasi(false)));
                    },
                  ),
                  InkWell(
                    child: Container(
                      color: Colors.transparent,
                      height: 110,
                      width: screenWidth / 5,
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.stripeS,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                "SDS\ne-Tahsilat",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OdemeSayfasi(false)));
                    },
                  ),
                  InkWell(
                    child: Container(
                      color: Colors.transparent,
                      height: 110,
                      width: screenWidth / 5,
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.hryvnia,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                "Zenitled\ne-Tahsilat",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OdemeSayfasi(true)));
                    },
                  ),
                  InkWell(
                    child: Container(
                      color: Colors.transparent,
                      height: 110,
                      width: screenWidth / 5,
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.question,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                "Şifremi\nunuttum",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(color: Colors.white),
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
                                  MediaQuery.of(context).size.width / 10),
                          backgroundColor: Colors.white,
                          child: Container(
                            height: 165,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: 20,
                                  child: Text(
                                    "Şifremi Unuttum",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18),
                                  ),
                                  margin: EdgeInsets.only(top: 15),
                                ),
                                Container(
                                    height: 35,
                                    margin:
                                        EdgeInsets.only(top: 20, bottom: 10),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 0),
                                    child: Center(
                                      child: TextFormField(
                                        controller: _kullaniciBilgiController,
                                        maxLines: 1,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              EdgeInsets.only(top: 2, left: 5),
                                          hintText:
                                              "Kullanıcı Adı veya Mail giriniz",
                                          enabledBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                          ),
                                        ),
                                        cursorColor: Colors.blue.shade900,
                                        style: TextStyle(color: Colors.black),
                                        keyboardType:
                                            TextInputType.emailAddress,
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
                                            child: Text(
                                              "GÖNDER",
                                              style:
                                                  TextStyle(color: Colors.blue),
                                            )),
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
                                                    color: Colors.blue))),
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
                      child: AutoSizeText(
                        kullaniciIsmi,
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
                        child: AutoSizeText(
                          "Yoksa $kullaniciIsmi değil misin?",
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
                          SharedPreferences pref =
                              await SharedPreferences.getInstance();
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
                  SizedBox(
                    height: 20,
                  ),
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
                          if (await Foksiyonlar.internetDurumu(context) ==
                              true) {
                            _checkLogin(
                                _mailAdresiController.text,
                                _sifreController.text,
                                TelefonBilgiler.userDevicePlatform);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Giriş",
                              style: GoogleFonts.roboto(
                                  fontSize: 20, color: Colors.white),
                            )
                          ],
                        )),
                  ),
                ],
              ),
            ),
          )
        ],
      );
    } else {
      return Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                margin: EdgeInsets.only(
                  bottom: screenHeight / 5.5 + 9,
                ),
                child: Image.asset("assets/images/shape1.png")),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight / 5.5 + 10,
              color: Color.fromRGBO(22, 65, 147, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    child: Container(
                      color: Colors.transparent,
                      height: screenHeight < 700
                          ? screenHeight / 4 / 1.75
                          : screenHeight / 4 / 2,
                      width: screenWidth / 5,
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.coins,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                "Döviz\nkurları",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      if(!rememberMe){
                        return;
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DovizKurlariSayfasi(false)));
                    },
                  ),
                  InkWell(
                    child: Container(
                      color: Colors.transparent,
                      height: screenHeight < 700
                          ? screenHeight / 4 / 1.75
                          : screenHeight / 4 / 2,
                      width: screenWidth / 5,
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.stripeS,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                "SDS\ne-Tahsilat",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OdemeSayfasi(false)));
                    },
                  ),
                  InkWell(
                    child: Container(
                      color: Colors.transparent,
                      height: screenHeight < 700
                          ? screenHeight / 4 / 1.75
                          : screenHeight / 4 / 2,
                      width: screenWidth / 5,
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.hryvnia,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                "Zenitled\ne-Tahsilat",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OdemeSayfasi(true)));
                    },
                  ),
                  InkWell(
                    child: Container(
                      color: Colors.transparent,
                      height: screenHeight < 700
                          ? screenHeight / 4 / 1.75
                          : screenHeight / 4 / 2,
                      width: screenWidth / 5,
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.question,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                "Şifremi\nunuttum",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(color: Colors.white),
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
                                  MediaQuery.of(context).size.width / 10),
                          backgroundColor: Colors.white,
                          child: Container(
                            height: 165,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: 20,
                                  child: Text(
                                    "Şifremi Unuttum",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18),
                                  ),
                                  margin: EdgeInsets.only(top: 15),
                                ),
                                Container(
                                    height: 35,
                                    margin:
                                        EdgeInsets.only(top: 20, bottom: 10),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 0),
                                    child: Center(
                                      child: TextFormField(
                                        controller: _kullaniciBilgiController,
                                        maxLines: 1,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              EdgeInsets.only(top: 2, left: 5),
                                          hintText:
                                              "Kullanıcı Adı veya Mail giriniz",
                                          enabledBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                          ),
                                        ),
                                        cursorColor: Colors.blue.shade900,
                                        style: TextStyle(color: Colors.black),
                                        keyboardType:
                                            TextInputType.emailAddress,
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
                                            child: Text(
                                              "GÖNDER",
                                              style:
                                                  TextStyle(color: Colors.blue),
                                            )),
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
                                                    color: Colors.blue))),
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
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      child: Image(
                    image: AssetImage(
                      'assets/images/b2b_isletme_v2.png',
                    ),
                    fit: BoxFit.cover,
                    width: 250,
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
                      child: AutoSizeText(
                        kullaniciIsmi,
                        style: GoogleFonts.comfortaa(
                          fontWeight: FontWeight.w900,
                        ),
                        minFontSize: 40,
                        maxFontSize: 50,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight / 18,
                  ),
                  InkWell(
                    child: Container(
                      child: Center(
                        child: AutoSizeText(
                          "Yoksa $kullaniciIsmi değil misin?",
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
                          SharedPreferences pref =
                          await SharedPreferences.getInstance();
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
                  SizedBox(
                    height: 20,
                  ),
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
                          if (await Foksiyonlar.internetDurumu(context) ==
                              true) {
                            _checkLogin(
                                _mailAdresiController.text,
                                _sifreController.text,
                                TelefonBilgiler.userDevicePlatform);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Giriş",
                              style: GoogleFonts.roboto(
                                  fontSize: 20, color: Colors.white),
                            )
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


  _checkLogin(String userName, String password, String platform) async {
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

    //String girisBilgisi = userName.replaceAll('(', '').replaceAll(')', '').replaceAll(' ', '').trimRight();
   // password.trimRight();
    late http.Response response;
    var body = jsonEncode({"userName": userName, "password": password});
    try {
      response = await http.post(Uri.parse("${Sabitler.url}/api/GetUserInfo"),
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
        UserInfo.isSuperUser = data["IsSuperUser"];
        UserInfo.isCiroRapor = data["IsCiroRapor"];
        UserInfo.isCriticUser = data["IsCriticUser"];
        UserInfo.isPortfoyCekRapor = data["IsPortfoyCekRapor"];
        UserInfo.isStokSatisKarlilikRapor = data["IsStokSatisKarlilikRapor"];
        UserInfo.isButceRapor = data["IsButceRapor"];
        UserInfo.activeDB = data["ActiveDB"];
      }
      SharedPreferences pref = await SharedPreferences.getInstance();
      bool? checkAll = await Foksiyonlar.checkAppEngine(context, true);
      if (checkAll == true) {
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
          print("AAAAAAAAAA");
          UserInfo.aktifSubeNo = pref.getString("zenitSubeKod");
        } catch (e) {
          UserInfo.aktifSubeNo = "";
        }

        Navigator.push(context, MaterialPageRoute( builder: (context) => AnaEkranSayfasi(),));
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
        Navigator.push(context, MaterialPageRoute(builder: (context) => AnaEkranSayfasi(),));
      }
    } else if (response.statusCode == 404) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BilgilendirmeDialog(
                "Giriş yapılamadı...\nKullanıcı bilgilerinizi kontrol edip tekrar deneyiniz.");
          });
    } else {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BilgilendirmeDialog(
                "Biraz sonra tekrar deneyiniz, aynı hatayı almaya devam ederseniz\nSDS BİLİŞİM ekibiyle iletişime geçiniz");
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
      });
    } else {
      rememberMe = false;
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
