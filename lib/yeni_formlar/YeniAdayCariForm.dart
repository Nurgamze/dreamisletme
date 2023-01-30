import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';

class YeniAdayCariForm extends StatefulWidget {
  @override
  _YeniAdayCariFormState createState() => _YeniAdayCariFormState();
}

class _YeniAdayCariFormState extends State<YeniAdayCariForm> {

  TextEditingController _unvanController = new TextEditingController();
  TextEditingController _yetkiliKisiController = new TextEditingController();
  TextEditingController _yetkiliCepController = new TextEditingController();
  TextEditingController _yetkiliEpostaController = new TextEditingController();
  TextEditingController _fizikselAdresController = new TextEditingController();
  TextEditingController _bolgeKodContoller = new TextEditingController();
  TextEditingController _telefonController = new TextEditingController();
  TextEditingController _webAdresiController = new TextEditingController();
  TextEditingController _epostaAdresiController = new TextEditingController();
  TextEditingController _vergiDaireNoController = new TextEditingController();
  String bosString = "";
  bool kaydedildiMi = false;

  bool sending = false;

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    double formHeight = 50;
    return ConstScreen(
      child: WillPopScope(
          onWillPop: () {
            if(kaydedildiMi){
              Navigator.pop(context);
              return Future.value(true);
            }else{
              return _onWillPop();
            }
          },
          child: Container(
            child: Scaffold(
              backgroundColor: Colors.grey.shade300,
              appBar: AppBar(
                title: Text("Yeni Aday Cari"),
                centerTitle: true,
                backgroundColor: Colors.blue.shade900,
              ),
              body: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      SizedBox(height: 15,),
                      Container(
                        height: formHeight,
                        decoration: new BoxDecoration(
                            color: Colors.white,
                            border: new Border.all(
                                color: Colors.blue.shade900,
                                width: 2.0
                            ),
                            borderRadius: new BorderRadius.circular(5.0)
                        ),
                        child: TextFormField(
                          cursorColor: Colors.black,
                          controller: _unvanController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              hintText: "Ünvan",
                              hintStyle: TextStyle(color: Colors.grey),
                              focusedBorder: null,
                              focusColor: Colors.transparent,
                              border: InputBorder.none
                          ),
                        ),
                        padding: const EdgeInsets.all(5.0),
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                      ),
                      SizedBox(height: 2,),
                      Container(
                        height: formHeight,
                        decoration: new BoxDecoration(
                            color: Colors.white,
                            border: new Border.all(
                                color: Colors.blue.shade900,
                                width: 2.0
                            ),
                            borderRadius: new BorderRadius.circular(5.0)
                        ),
                        child: TextFormField(
                          cursorColor: Colors.black,
                          controller: _yetkiliKisiController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              hintText: "Yetkili Kişi",
                              hintStyle: TextStyle(color: Colors.grey),
                              focusedBorder: null,
                              focusColor: Colors.transparent,
                              border: InputBorder.none
                          ),
                        ),
                        padding: const EdgeInsets.all(5.0),
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                      ),
                      SizedBox(height: 2,),
                      Container(
                        height: formHeight,
                        decoration: new BoxDecoration(
                            color: Colors.white,
                            border: new Border.all(
                                color: Colors.blue.shade900,
                                width: 2.0
                            ),
                            borderRadius: new BorderRadius.circular(5.0)
                        ),
                        child: TextFormField(
                          cursorColor: Colors.black,
                          controller: _yetkiliCepController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              hintText: "Yetkili Cep",
                              hintStyle: TextStyle(color: Colors.grey),
                              focusedBorder: null,
                              focusColor: Colors.transparent,
                              border: InputBorder.none
                          ),
                        ),
                        padding: const EdgeInsets.all(5.0),
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                      ),
                      SizedBox(height: 2,),
                      Container(
                        height: formHeight,
                        decoration: new BoxDecoration(
                            color: Colors.white,
                            border: new Border.all(
                                color: Colors.blue.shade900,
                                width: 2.0
                            ),
                            borderRadius: new BorderRadius.circular(5.0)
                        ),
                        child: TextFormField(
                          cursorColor: Colors.black,
                          controller: _yetkiliEpostaController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              hintText: "Yetkili E-Posta",
                              hintStyle: TextStyle(color: Colors.grey),
                              focusedBorder: null,
                              focusColor: Colors.transparent,
                              border: InputBorder.none
                          ),
                        ),
                        padding: const EdgeInsets.all(5.0),
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                      ),
                      SizedBox(height: 2,),
                      Container(
                        decoration: new BoxDecoration(
                            color: Colors.white,
                            border: new Border.all(
                                color: Colors.blue.shade900,
                                width: 2.0
                            ),
                            borderRadius: new BorderRadius.circular(5.0)
                        ),
                        child: TextFormField(
                          cursorColor: Colors.black,
                          controller: _fizikselAdresController,
                          style: TextStyle(color: Colors.black),
                          maxLines: 2,
                          maxLength: 50,
                          decoration: InputDecoration(
                              hintText: "Fiziksel Adres (Maks. 50 Karakter)",
                              hintStyle: TextStyle(color: Colors.grey),
                              focusedBorder: null,
                              focusColor: Colors.transparent,
                              border: InputBorder.none
                          ),
                        ),
                        padding: const EdgeInsets.all(5.0),
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                      ),
                      SizedBox(height: 2,),
                      Row(
                        children: [
                          Container(
                            height: formHeight,
                            width: MediaQuery.of(context).size.width/3,
                            decoration: new BoxDecoration(
                                color: Colors.white,
                                border: new Border.all(
                                    color: Colors.blue.shade900,
                                    width: 2.0
                                ),
                                borderRadius: new BorderRadius.circular(5.0)
                            ),
                            child: TextFormField(
                              cursorColor: Colors.black,
                              controller: _bolgeKodContoller,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(5),
                              ],
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                  hintText: "Bölge Kod",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  focusedBorder: null,
                                  focusColor: Colors.transparent,
                                  border: InputBorder.none
                              ),
                            ),
                            padding: const EdgeInsets.all(5.0),
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(horizontal: 5),
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width/3*2-15,
                              height: formHeight,
                              decoration: new BoxDecoration(
                                  color: Colors.white,
                                  border: new Border.all(
                                      color: Colors.blue.shade900,
                                      width: 2.0
                                  ),
                                  borderRadius: new BorderRadius.circular(5.0)
                              ),
                              child: TextFormField(
                                cursorColor: Colors.black,
                                controller: _telefonController,
                                inputFormatters: <TextInputFormatter>[
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                    hintText: "Telefon",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    focusedBorder: null,
                                    focusColor: Colors.transparent,
                                    border: InputBorder.none
                                ),
                              ),
                              padding: const EdgeInsets.all(5.0),
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(right: 5)
                          ),
                        ],
                      ),
                      SizedBox(height: 2,),
                      Container(
                        height: formHeight,
                        decoration: new BoxDecoration(
                            color: Colors.white,
                            border: new Border.all(
                                color: Colors.blue.shade900,
                                width: 2.0
                            ),
                            borderRadius: new BorderRadius.circular(5.0)
                        ),
                        child: TextFormField(
                          cursorColor: Colors.black,
                          controller: _webAdresiController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              hintText: "Web Adresi",
                              hintStyle: TextStyle(color: Colors.grey),
                              focusedBorder: null,
                              focusColor: Colors.transparent,
                              border: InputBorder.none
                          ),
                        ),
                        padding: const EdgeInsets.all(5.0),
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                      ),
                      SizedBox(height: 2,),
                      Container(
                        height: formHeight,
                        decoration: new BoxDecoration(
                            color: Colors.white,
                            border: new Border.all(
                                color: Colors.blue.shade900,
                                width: 2.0
                            ),
                            borderRadius: new BorderRadius.circular(5.0)
                        ),
                        child: TextFormField(
                          cursorColor: Colors.black,
                          controller: _epostaAdresiController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              hintText: "E-Posta Adresi",
                              hintStyle: TextStyle(color: Colors.grey),
                              focusedBorder: null,
                              focusColor: Colors.transparent,
                              border: InputBorder.none
                          ),
                        ),
                        padding: const EdgeInsets.all(5.0),
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                      ),
                      SizedBox(height: 2,),
                      Container(
                        height: formHeight,
                        decoration: new BoxDecoration(
                            color: Colors.white,
                            border: new Border.all(
                                color: Colors.blue.shade900,
                                width: 2.0
                            ),
                            borderRadius: new BorderRadius.circular(5.0)
                        ),
                        child: TextFormField(
                          cursorColor: Colors.black,
                          controller: _vergiDaireNoController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              hintText: "Vergi Daire/No",
                              hintStyle: TextStyle(color: Colors.grey),
                              focusedBorder: null,
                              focusColor: Colors.transparent,
                              border: InputBorder.none
                          ),
                        ),
                        padding: const EdgeInsets.all(5.0),
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                      ),
                      SizedBox(height: 5,),
                      Container(
                          height: 50,
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.blue.shade900,
                          ),
                          child: InkWell(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(FontAwesomeIcons.save,color: Colors.white,size: 27,),
                                SizedBox(width: 10,),
                                Text("KAYDET",style: GoogleFonts.roboto(color: Colors.white,fontSize: 22)),
                              ],
                            ),
                            onTap: () {
                              if (_unvanController.text.isNotEmpty ) {
                                showDialog(context: context,builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  content: Text("Aday cari girdiğiniz bilgilerle kaydedilsin mi?"),
                                  actions: [
                                    TextButton(child: Text("Hayır"),onPressed: () => Navigator.pop(context),),
                                    TextButton(child: Text("Evet"),onPressed: () {
                                      kaydedildiMi = true;
                                      Navigator.pop(context);
                                      _yeniAdayCari();
                                    },),
                                  ],
                                ));
                              }else{
                                Fluttertoast.showToast(msg: "Ünvan girmelisiniz.",backgroundColor: Colors.black,textColor: Colors.white);
                              }
                            },
                          )
                      ),
                      SizedBox(height: 5,),
                    ],
                  )
              ),
            ),
          )
      )
    );

  }

  _yeniAdayCari() async {
    if(sending){
      return;
    }
    setState(() {
      sending = true;
    });
    _unvanController.text = _unvanController.text.replaceAll("'", "''");
    _vergiDaireNoController.text = _vergiDaireNoController.text.replaceAll("'", "''");
    _webAdresiController.text = _webAdresiController.text.replaceAll("'", "''");
    _epostaAdresiController.text = _epostaAdresiController.text.replaceAll("'", "''");
    _fizikselAdresController.text = _fizikselAdresController.text.replaceAll("'", "''");
    _bolgeKodContoller.text = _bolgeKodContoller.text.replaceAll("'", "''");
    _telefonController.text = _telefonController.text.replaceAll("'", "''");
    _yetkiliKisiController.text = _yetkiliKisiController.text.replaceAll("'", "''");
    _yetkiliCepController.text = _yetkiliCepController.text.replaceAll("'", "''");
    _yetkiliEpostaController.text = _yetkiliEpostaController.text.replaceAll("'", "''");

    var body = jsonEncode({
      "vtname" : UserInfo.activeDB,
      "unvan" : _unvanController.text,
      "vdaireno" : _vergiDaireNoController.text,
      "temsilci" : bosString,
      "sektor" : bosString,
      "bolge" : bosString,
      "grup" : bosString,
      "web" : _webAdresiController.text,
      "eposta" : _epostaAdresiController.text,
      "fadres" : _fizikselAdresController.text,
      "telBolge" : _bolgeKodContoller.text,
      "tel" : _telefonController.text,
      "yetkili" : _yetkiliKisiController.text,
      "ycep" : _yetkiliCepController.text,
      "yeposta" : _yetkiliEpostaController.text,
      "Mobile" : true,
      "DevInfo" : TelefonBilgiler.userDeviceInfo,
      "AppVer" : TelefonBilgiler.userAppVersion,
      "UserId" : UserInfo.activeUserId
    });
    var response = await http.post(Uri.parse(
        "${Sabitler.url}/api/YeniAdayCari"),
      headers: {
          "apiKey": Sabitler.apiKey,
          'Content-Type': 'application/json; charset=UTF-8',
      },
        body: body
    );
    if (response.statusCode == 200) {
      final createdResult = await showOkAlertDialog(context: context,message: "Aday Cari Oluşturuldu",okLabel: "Tamam");
      if(createdResult == OkCancelResult.ok){
        FocusScope.of(context).requestFocus(new FocusNode());
      }
    }else{
      print(response.statusCode);
      print(response.body);
      print(response.statusCode);
      showDialog(context: context, builder: (_) => AlertDialog(
        content: SelectableText(jsonDecode(response.body)["Message"]),
      ));
      //final createdResult = await showOkAlertDialog(context: context,message: jsonDecode(response.body)["Message"],okLabel: "Tamam");

    }
    setState(() {
      sending = false;
    });
  }


  Future<bool> _onWillPop() async {
    return await showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Text("Kaydetmeden çıkmak istiyor musunuz?"),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text("Hayır")
        ),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text("Evet")
        )
      ],
    )) ??  false;
  }
}
