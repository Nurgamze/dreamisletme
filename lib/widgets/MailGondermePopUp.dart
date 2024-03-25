import 'dart:async';
import 'dart:convert';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:sdsdream_flutter/AnaEkranSayfasi.dart';
import 'package:sdsdream_flutter/GirisYapYeni.dart';
import 'package:sdsdream_flutter/modeller/Modeller.dart';

import '../cariler/models/cari.dart';



class MailGonderPopUp extends StatefulWidget {
  final String apiYazisi;
  final String? ekstreTarihi;
  final BuildContext myContext;
  final DreamCari data;
  const MailGonderPopUp(this.myContext,this.apiYazisi,{required this.data,this.ekstreTarihi,Key? key}) : super(key: key);

  @override
  _MailGonderPopUpState createState() => _MailGonderPopUpState();
}

class _MailGonderPopUpState extends State<MailGonderPopUp> {

  TextEditingController _mailGonderController = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mailGonderController.text = "${widget.data.email}";
  }
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/10),
        backgroundColor: Colors.white,
        child: Container(
          height: 180,
          child: Column(
            children: <Widget>[
              Container(
                height: 20,
                child: Text("Mail Giriniz",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w700,fontSize: 18),),
                margin: EdgeInsets.only(top: 15),
              ),
              Container(
                height: 35,
                child: Text("En az bir adres giriniz. Birden fazla Mail için, adresler arasına ; ekleyebilirsiniz.",style: TextStyle(color: Colors.black,fontSize: 14),maxLines: 3,textAlign: TextAlign.center,),
                margin: EdgeInsets.only(top: 5),
                padding: EdgeInsets.symmetric(horizontal: 5),
              ),
              Container(
                  height: 35,
                  margin: EdgeInsets.only(top: 5),
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                  child: Center(child: TextFormField(
                    controller: _mailGonderController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 2,left: 5),
                      hintText: "${widget.data.email}",
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
                  ),)
              ),
              Container(
                margin: EdgeInsets.only(top: 14),
                color: Colors.grey,
                height: 1,
              ),
              Container(
                child: Row(
                  children: [
                    Expanded(child: TextButton(
                        onPressed: () async {
                          var mails = _mailGonderController.text.split(';');
                          for(var mail in mails){
                            if(!checkIsMail(mail)){
                              Clipboard.setData((new ClipboardData(text: _mailGonderController.text)));
                              final createdResult = await showOkAlertDialog(context: context,message: "Girdiğiniz adresler hatalı. Girmiş olduğunuz adres panoya kopyalandı, tekrar denerken yapıştırabilir ve düzeltebilirsiniz.",okLabel: "Tamam");
                            }else{
                              _mailGonder(_mailGonderController.text,context);
                            }
                          }
                        },
                        child: Text("GÖNDER",style: TextStyle(color: Colors.blue),)
                    ),
                    ),
                    Container(width: 1,color: Colors.grey,height: 50,),
                    Expanded(
                      child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("İPTAL",style: TextStyle(color: Colors.blue))),),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
  bool checkIsMail(String mailAdress){
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(mailAdress)) ? false : true;
  }
  _mailGonder(String mailler,BuildContext context1) async{
    var response = await http.get(Uri.parse("${Sabitler.url}/api/EkstreMailRequestKaydet?customer=false&userId=${UserInfo.activeUserId}&userName=${UserInfo.mikroPersonelKod}&dbKod=${UserInfo.activeDB}&cariKod=${widget.data.kod}&cariUnvan=${widget.data.unvan}&cariVade=${widget.data.vade}&tarihYil=${DateTime.now().year}&tarihAy=${DateTime.now().month}&cariMail=$mailler&tip=${widget.apiYazisi}&tarih=${widget.ekstreTarihi}"),headers: {"apiKey" : Sabitler.apiKey});
    if(response.statusCode == 200){
      final createdResult = await showOkAlertDialog(context: context1,title: "Başarılı",message: "Gönderim için sıraya alındı. Hazırlanıp gönderilmesi birkaç dakikayı bulabilir.",okLabel: "Tamam");
      Navigator.pop(context1);
    }else{
      Clipboard.setData((new ClipboardData(text: mailler)));
      final createdResult = await showOkAlertDialog(context: context1,title: "Hata Oluştu",message: "Bir süre sonra tekrar deneyiniz.\nGirmiş olduğunuz adres panoya kopyalandı, tekrar denerken yapıştırabilir ve düzeltebilirsiniz.",okLabel: "Tamam");
      Navigator.pop(context1);
    }
  }
}



class KayitKodGonder extends StatefulWidget {

  final String userName;
  KayitKodGonder(this.userName);
  @override
  _KayitKodGonderState createState() => _KayitKodGonderState();

}

class _KayitKodGonderState extends State<KayitKodGonder> {
//  String kayitKod = "9999";
  String dogrulamaKodu = '';
  bool tekrarGonder = false;
  Timer? _timer;
  TextEditingController _kayitMailKodController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _kodGonder();
  }
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            children: [
              Container(height: 20,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
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
                          padding: EdgeInsets.only(right: 10,left: 10),
                          child:  Row(
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
                                  if(!tekrarGonder){
                                    Fluttertoast.showToast(
                                        msg:  "60 saniye içinde tekrar kod gönderemezsiniz",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        textColor: Colors.white,
                                        backgroundColor: Colors.green.shade600,
                                        fontSize: 16.0
                                    );
                                  }else{
                                    setState(() {
                                     // kayitKod = "9999999";
                                      tekrarGonder = false;
                                    });
                                    _kodGonder();
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

                                  if(_kayitMailKodController.text == dogrulamaKodu){
                                    //kod doğruysa giriş yap sayafasındaki checklogin ile giriş yapmalılar
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>AnaEkranSayfasi()));
                                    print("giriş yapabilir");
                                    _timer!.cancel();
                                  }else{
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
                        )
                      ],
                    )
                ),
              ),
            ],
          ),
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }

 void _kodGonder () async {
    print("id ye bakıyoss ${widget.userName}");
    var response  = await http.get(Uri.parse("${Sabitler.url}/api/Dogrulama?userName=${widget.userName}",),
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
}

