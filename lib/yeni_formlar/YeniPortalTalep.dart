import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';

class YeniPortalTalep extends StatefulWidget {
  @override
  _YeniPortalTalepState createState() => _YeniPortalTalepState();
}

class _YeniPortalTalepState extends State<YeniPortalTalep> {



  TextEditingController _baslikController = new TextEditingController();
  TextEditingController _aciklamaController = new TextEditingController();
  String bosString = "";
  bool kaydedildiMi = false;
  FocusNode currentNode = FocusNode();
  FocusNode nextNode = FocusNode();
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
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.grey.shade300,
              appBar: AppBar(
                title: Text("Yeni Talep Formu"),
                centerTitle: true,
                backgroundColor: Colors.blue.shade900,
                actions: [
                  IconButton(onPressed: () async {
                    if (_baslikController.text.isNotEmpty && _aciklamaController.text.isNotEmpty) {
                      final result = await showOkCancelAlertDialog(
                        context: context,
                        message: "Portal talebiniz girdiğiniz bilgilerle oluşturulsun mu?",
                        okLabel: "Evet",
                        cancelLabel: "Hayır",
                      );
                      if(result == OkCancelResult.ok){
                        kaydedildiMi = true;
                        _createIssue();
                      }
                    }else{
                      Fluttertoast.showToast(msg: "Tüm alanları doldurmalısınız",backgroundColor: Colors.blue.shade900,textColor: Colors.white);
                    }
                  }, icon: FaIcon(FontAwesomeIcons.paperPlane))
                ],
              ),
              body: Form(
                  key: _formKey,
                  child: Container(
                    padding: EdgeInsets.only(bottom: Device.get().isIphoneX ? 16 :0),
                    color: Colors.white,
                    child: Column(
                      children: [
                        SizedBox(height: 15,),
                        Container(
                          height: formHeight,
                          child: TextFormField(
                              cursorColor: Colors.black,
                              focusNode: currentNode,
                              controller: _baslikController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  labelText: "Talep Başlığı",
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.blue.shade900,
                                        width: 2
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.blue.shade900,
                                        width: 2
                                    ),
                                  )
                              ),
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (term){
                                currentNode.unfocus();
                                FocusScope.of(context).requestFocus(nextNode);
                              }
                          ),
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(horizontal: 5),
                        ),
                        SizedBox(height: 10,),
                        Expanded(child: Container(
                          height: MediaQuery.of(context).size.height-350,
                          color: Colors.white,
                          child: TextFormField(
                            focusNode: nextNode,
                            cursorColor: Colors.black,
                            controller: _aciklamaController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                labelText: "Talebinizle ilgili açıklama",
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors.blue.shade900,
                                      width: 2
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors.blue.shade900,
                                      width: 2
                                  ),
                                )
                            ),
                            maxLines: 100,
                            textInputAction: TextInputAction.done,
                          ),
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.symmetric(horizontal: 5),
                        ),),
                        SizedBox(height: 5,),
                      ],
                    ),
                  )
              ),
            ),
          )
      )
    );

  }

  _sendMail(String baslik,String aciklama,String talepNo,String uuid) async{
    var body = '''DREAM UYGULAMASINDAN -> SDS BULUT UYGULAMASINA
İş #$talepNo, ${UserInfo.mikroPersonelKod} tarafından açıldı.

----------------------------------------
GÖREV #$talepNo: $baslik
https://bulut.sds.com.tr/taskdetail/$uuid

*Yazar: ${UserInfo.mikroPersonelKod}
*Durum: Yeni
*Öncelik: Düşük
----------------------------------------
$aciklama
                

----------------------------------------
Dream B2B İşletme & SDS Bulut Uygulamaları
by
SDS INFORMATION TECHNOLOGY DEPARTMENT
    ''';
    String gidecekBaslik = "[Dream B2B İşletme - IT DESTEK #$talepNo] (Yeni) $baslik";
    var jsonBody = jsonEncode({
      "body" : body,
      "subject" : gidecekBaslik,
      "uuid" : UserInfo.portalUserId
    });
    var response = await http.post(Uri.parse(
        "${Sabitler.url}/api/MailGonderme"),
        headers: {
          "apiKey": Sabitler.apiKey,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonBody
    );
    print(response.statusCode);
    print(response.body);
    print(response.headers);
    if(response.statusCode == 200) {
      return true;
    }else{
      return false;
    }

  }

  _createIssue() async {
    if(sending){
      return;
    }
    setState(() {
      sending = true;
    });
    String mesaj = "";
    String baslik;
    String aciklama;
    aciklama = _aciklamaController.text.replaceAll("'", "''");
    baslik = _baslikController.text.replaceAll("'", "''");
    var response = await http.get(Uri.parse("${Sabitler.url}/api/PortalCreateIssue?pUserId=${UserInfo.portalUserId}&strBaslik=$baslik&strAciklama=$aciklama"),headers: {"apiKey" : Sabitler.apiKey});
    if(response.statusCode == 200) {
      String data = jsonDecode(response.body).toString();
      List<String> ids = data.split(';');
      mesaj = "Talebiniz ${ids[0]} numarası ile oluşturulmuştur. ";
      var result = await _sendMail(baslik, aciklama, ids[0],ids[1]);
      result ? mesaj+= "Uygulamadan kontrol edebilirsiniz" : mesaj+= "Ancak maili gönderilemedi, bilişime haber vermenizi rica ederiz.";
      final createdResult = await showOkAlertDialog(context: context,message: mesaj,okLabel: "Tamam");
      if(createdResult == OkCancelResult.ok){
        _aciklamaController.clear();
        _baslikController.clear();
        Navigator.pop(context);

      }
    }else{
      print(response.body);
      print(response.statusCode);
      final createdResult = await showOkAlertDialog(context: context,message: "Talebiniz oluşturulmadı biraz bekledikten sonra tekrar oluşturunuz",okLabel: "Tamam");
      if(createdResult == OkCancelResult.ok){
        FocusScope.of(context).requestFocus(new FocusNode());
      }
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
