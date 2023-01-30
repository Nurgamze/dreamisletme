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

class YeniStokReferans extends StatefulWidget {
  final String stokKodu;
  YeniStokReferans(this.stokKodu);
  @override
  _YeniStokReferansState createState() => _YeniStokReferansState();
}

class _YeniStokReferansState extends State<YeniStokReferans> {

  TextEditingController _unvanController = new TextEditingController();
  TextEditingController _yetkiliController = new TextEditingController();
  TextEditingController _telefonController = new TextEditingController();
  TextEditingController _epostaController = new TextEditingController();
  TextEditingController _sehirController = new TextEditingController();
  TextEditingController _aciklamaController = new TextEditingController();
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
              Navigator.pop(context,true);
              return Future.value(true);
            }else{
              return _onWillPop();
            }
          },
          child: Container(
            child: Scaffold(
              backgroundColor: Colors.grey.shade300,
              appBar: AppBar(
                title: Text("Yeni Stok Referansı"),
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
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                              counterText: '',
                              hintText: "Cari Ünvan",
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
                          controller: _yetkiliController,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              hintText: "Yetkili",
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
                          controller: _telefonController,
                          style: TextStyle(color: Colors.black),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              hintText: "Cep",
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
                          controller: _epostaController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              hintText: "E-Posta",
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
                          controller: _sehirController,
                          style: TextStyle(color: Colors.black),
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                              hintText: "Şehir",
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
                          controller: _aciklamaController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          style: TextStyle(color: Colors.black),
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                              hintText: "Açıklama",
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
                          height: 40,
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
                            onTap: () async {
                              if(_unvanController.text.isEmpty || _sehirController.text.isEmpty || _yetkiliController.text.isEmpty || _telefonController.text.isEmpty || _epostaController.text.isEmpty){
                                Fluttertoast.showToast(
                                    msg: "Tüm alanları doldurduğunuzdan emin olun.",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    textColor: Colors.white,
                                    backgroundColor: Colors.black,
                                    fontSize: 15.0
                                );
                                return;
                              }
                              final createdResult = await showOkCancelAlertDialog(context: context,message: "Referans Müşterisi girdiğiniz bilgilerle kaydedilsin mi?",okLabel: "Evet",cancelLabel: "Hayır");
                              if(createdResult == OkCancelResult.ok){
                                kaydedildiMi = true;
                                _yeniAdayCari();
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


    var body = jsonEncode({
      "unvan" :  _unvanController.text.replaceAll("'", "''").trimRight(),
      "sehir" :  _sehirController.text.replaceAll("'", "''").trimRight(),
      "yetkili" :  _yetkiliController.text.replaceAll("'", "''").trimRight(),
      "tel" :  _telefonController.text.replaceAll("'", "''").trimRight(),
      "eposta" :  _epostaController.text.replaceAll("'", "''").trimRight(),
      "detay" :  _aciklamaController.text.replaceAll("'", "''").trimRight(),
      "Mobile" : true,
      "DevInfo" : TelefonBilgiler.userDeviceInfo,
      "AppVer" : TelefonBilgiler.userAppVersion,
      "kullaniciId" : UserInfo.activeUserId,
      "stokKodu" : widget.stokKodu
    });
    var response = await http.post(Uri.parse(
        "${Sabitler.url}/api/YeniStokReferans"),
        headers: {
          "apiKey": Sabitler.apiKey,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body
    );
    setState(() {
      sending = false;
    });
    if (response.statusCode == 200) {
     await showOkAlertDialog(context: context,message: "Yeni Referans Oluşturuldu",okLabel: "Tamam");
      Navigator.of(context).pop(true);
    }else{
     await showOkAlertDialog(context: context,message: "Yeni Referans Oluşturulamadı",okLabel: "Tamam");
    }
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
