import 'dart:convert';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/widgets/DreamCogsGif.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'package:url_launcher/url_launcher.dart';
class AdresleriSayfasi extends StatefulWidget {
  final String cariKod;
  AdresleriSayfasi(this.cariKod);
  @override
  _AdresleriSayfasiState createState() => _AdresleriSayfasiState();
}

class _AdresleriSayfasiState extends State<AdresleriSayfasi> {

  List<Adresler> listAdresler = [];
  bool loading = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _adresGetir();
    AutoOrientation.fullAutoMode();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
  }
  @override
  Widget build(BuildContext context) {
    return ConstScreen(
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/dreambg.jpg"), fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.blue.shade900,
            title: Text("Cari Adresleri"),
          ),
          body: !loading ? DreamCogs() :
          ListView.builder(
              itemCount: listAdresler.length,
              itemBuilder: (context, index){
                return Card(
                  shadowColor: Colors.blueAccent,
                  margin: EdgeInsets.only(top: 20,left: 15,right: 15),
                  child:  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text("Adres " + (index+1).toString()),
                        ),
                        Divider(thickness: 2,color: Colors.blue.shade900,),
                        ListTile(
                          title: Text("İl"),
                          subtitle: Text(listAdresler[index].il),
                          leading: FaIcon(FontAwesomeIcons.city),
                        ),
                        ListTile(
                          title: Text("İlçe"),
                          subtitle: Text(listAdresler[index].ilce),
                          leading: FaIcon(FontAwesomeIcons.building),
                        ),
                        ListTile(
                          title: Text("Cadde"),
                          subtitle: Text(listAdresler[index].cadde),
                          leading:FaIcon(FontAwesomeIcons.streetView),
                        ),
                        ListTile(
                          title: Text("Tel 1"),
                          subtitle: Text(listAdresler[index].bolge+ listAdresler[index].tel1,style: TextStyle(color: Colors.blue,decoration: TextDecoration.underline),),
                          leading: FaIcon(FontAwesomeIcons.phone),
                          trailing: IconButton(
                            onPressed: () {
                              String aranacakNo = listAdresler[index].bolge+ listAdresler[index].tel1.replaceAll(' ', '');
                              if(aranacakNo.isEmpty) return;
                              if(!aranacakNo.startsWith('0')){
                                aranacakNo = "0"+aranacakNo;
                              }
                              Clipboard.setData((ClipboardData(text: aranacakNo)));
                              Fluttertoast.showToast(
                                  msg: "Telefon numarası kopyalandı",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  textColor: Colors.white,
                                  backgroundColor: Colors.grey,
                                  fontSize: 16.0
                              );
                            },
                            icon: FaIcon(FontAwesomeIcons.solidClipboard),
                          ),
                          onTap: () {
                            String aranacakNo = listAdresler[index].bolge+ listAdresler[index].tel1.replaceAll(' ', '');
                            if(!aranacakNo.startsWith('0')) aranacakNo = "0"+aranacakNo;
                            launch('tel:$aranacakNo');
                          },
                        ),
                        ListTile(
                          title: Text("Diğer"),
                          subtitle: Text(listAdresler[index].diger,style: TextStyle(color: Colors.blue,decoration: TextDecoration.underline),),
                          leading: FaIcon(FontAwesomeIcons.mobileAlt),
                          trailing: IconButton(
                            onPressed: () {
                              String aranacakNo = listAdresler[index].bolge+ listAdresler[index].tel1.replaceAll(' ', '');
                              if(aranacakNo.isEmpty) return;
                              if(!aranacakNo.startsWith('0')){
                                aranacakNo = "0"+aranacakNo;
                              }
                              Clipboard.setData((ClipboardData(text: aranacakNo)));
                              Fluttertoast.showToast(
                                  msg: "Telefon numarası kopyalandı",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  textColor: Colors.white,
                                  backgroundColor: Colors.grey,
                                  fontSize: 16.0
                              );
                            },
                            icon: FaIcon(FontAwesomeIcons.solidClipboard),
                          ),
                          onTap: () {
                            String aranacakNo = listAdresler[index].diger.replaceAll(' ', '');
                            if(!aranacakNo.startsWith('0')) aranacakNo = "0"+aranacakNo;
                            launch('tel:$aranacakNo');
                          },
                        ),
                        ListTile(
                          title: Text("Kod"),
                          subtitle: Text(listAdresler[index].kod),
                          leading: FaIcon(FontAwesomeIcons.tty),
                        ),
                      ],
                    ),
                  ),
                );
              }) ,
        ),
      )
    );
  }

  _adresGetir() async {
    var response = await http.get(Uri.parse("${Sabitler.url}/api/CariAdresleri?VtIsim=${UserInfo.activeDB}&cariKod=${widget.cariKod}"),headers: {"apiKey" : Sabitler.apiKey});
    if(response.statusCode == 200){
      var adresler = jsonDecode(response.body);
      for(var adres in adresler) {
        Adresler yeniAdres = Adresler(adres['il'].toString(), adres['ilce'].toString(), adres['bolge'].toString(), adres['cadde'].toString(), adres['diger'].toString(), adres['kod'].toString(), adres['tel1'].toString());
        setState(() {
          listAdresler.add(yeniAdres);
          loading = true;
        });
      }

    }
  }
}

class Adresler {
  final String il;
  final String ilce;
  final String cadde;
  final String tel1;
  final String kod;
  final String bolge;
  final String diger;
  Adresler(this.il,this.ilce,this.bolge,this.cadde,this.diger,this.kod,this.tel1);
}