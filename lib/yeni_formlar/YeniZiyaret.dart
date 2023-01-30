import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/widgets/Dialoglar.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';


class YeniZiyaretSayfasi extends StatefulWidget {
  final String cariKod;
  final String cariUnvan;
  YeniZiyaretSayfasi(this.cariKod,this.cariUnvan);

  @override
  _YeniZiyaretSayfasiState createState() => _YeniZiyaretSayfasiState();
}

class _YeniZiyaretSayfasiState extends State<YeniZiyaretSayfasi> {


  int _currentSelection = 0;

  String dateYear = DateTime.now().year.toString();
  String dateMonth = new DateFormat.MMMM('tr').format(DateTime.now());
  String dateDay = DateTime.now().day.toString();
  DateTime secilenTarih = DateTime.now();
  TextEditingController _aciklamaController = new TextEditingController();

  List ziyaretTurleri = ["Ziyaret","Telefon","E-Posta","Fuar","Toplantı"];
  List ziyaretTurIds = [4, 0, 1, 8, 5];
  int ziyaretTurId = 4;

  bool musteriGorsunMu = false;
  String ziyaretTuru = "Ziyaret";
  bool sending = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstScreen(
      child: Scaffold(
        // backgroundColor: Colors.deepOrange,
          appBar: AppBar(
            title: Container(
                child: Text("Yeni Ziyaret Oluştur")
            ),
            centerTitle: true,
            backgroundColor: Colors.blue.shade900,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  stops: [0.5, 0.9],
                                  colors: [Colors.blue.shade900, Colors.blue.shade700])),
                          child: Center(child: Text(
                            widget.cariKod,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0),
                          ),)
                      ),
                    ),
                    VerticalDivider(width: 2,),
                    Expanded(
                      child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  stops: [0.5, 0.9],
                                  colors: [Colors.blue.shade900, Colors.blue.shade700])),
                          child: Center(child: Text(
                            widget.cariUnvan,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0),
                          ),)
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topRight: Radius.circular(5),topLeft: Radius.circular(5)),
                      color: Colors.deepOrange,
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 1),
                    height: 30,
                    width: TelefonBilgiler.isTablet ? MediaQuery.of(context).size.width/2 : MediaQuery.of(context).size.width,
                    child: Center(child: Text("ZİYARET TÜRÜ",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
                ),
                Container(
                  height: 35,
                  width: TelefonBilgiler.isTablet ? MediaQuery.of(context).size.width/2 : MediaQuery.of(context).size.width,
                  child: CupertinoSlidingSegmentedControl(
                    onValueChanged: (value) {
                      setState(() {
                        _currentSelection = int.parse(value.toString());
                        ziyaretTurId = ziyaretTurIds[int.parse(value.toString())];
                        print(ziyaretTurId);
                      });
                    },
                    groupValue: _currentSelection,
                    children: _children,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 1),
                ),
                TelefonBilgiler.isTablet ? Container(height: 10,) : Divider(),
                InkWell(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),topLeft: Radius.circular(5)),
                            color: Colors.blue.shade900,
                          ),
                          margin: EdgeInsets.only(left: 1),
                          height: 50,
                          width: MediaQuery.of(context).size.width/5,
                          child: Center(child: Text("TARİHİ:",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
                      ),
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(5),topRight: Radius.circular(5)),
                              border: Border.all(color: Colors.blue.shade900),
                              color: Colors.white
                          ),
                          margin: EdgeInsets.only(right: 1),
                          height: 50,
                          width: TelefonBilgiler.isTablet ? MediaQuery.of(context).size.width/10*3 : MediaQuery.of(context).size.width/5*4-4,
                          child: Center(child:
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(dateDay,style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.bold))),
                              Text(dateMonth,style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.bold))),
                              Text(dateYear,style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.bold)))
                            ],
                          ),)
                      ),
                    ],
                  ),
                  onTap: () => callDatePicker(),
                ),
                TelefonBilgiler.isTablet ? Container(height: 10,) : Divider(),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topRight: Radius.circular(5),topLeft: Radius.circular(5)),
                      color: Colors.blue.shade900,
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 1),
                    height: 30,
                    width: TelefonBilgiler.isTablet ? MediaQuery.of(context).size.width/2 : MediaQuery.of(context).size.width,
                    child: Center(child: Text("AÇIKLAMA",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
                ),
                Container(
                  width: TelefonBilgiler.isTablet ? MediaQuery.of(context).size.width/2 : MediaQuery.of(context).size.width,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    border: new Border.all(
                        color: Colors.blue.shade900,
                        width: 2.0
                    ),
                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(5),bottomLeft: Radius.circular(5)),
                  ),
                  child: TextFormField(
                    cursorColor: Colors.black,
                    controller: _aciklamaController,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(color: Colors.black),
                    maxLines: 10,
                    decoration: InputDecoration(
                      isCollapsed: false,
                        hintText: "Açıklama",
                        hintStyle: TextStyle(color: Colors.grey),
                        focusedBorder: null,
                        focusColor: Colors.transparent,
                        border: InputBorder.none
                    ),
                  ),
                  padding: const EdgeInsets.all(5.0),
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: 1),
                ),
                TelefonBilgiler.isTablet ? Container(height: 10,) : Divider(),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    width: TelefonBilgiler.isTablet ? MediaQuery.of(context).size.width/2 : MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Bu ziyareti müşteri görebilsin mi?"),
                        CupertinoSwitch(
                          activeColor: Colors.deepOrange,
                          value: musteriGorsunMu,
                          onChanged: (value) {
                            setState(() {
                              musteriGorsunMu = value;
                            });
                          },
                        )
                      ],
                    )
                ),
                TelefonBilgiler.isTablet ? Container(height: 10,) : Divider(),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: TelefonBilgiler.isTablet ? MediaQuery.of(context).size.width/2 : MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue.shade900
                  ),
                  child: TextButton(
                    child: Text("KAYDET",style: TextStyle(color: Colors.white,fontSize: 18),),
                    onPressed: () async{
                      if(await Foksiyonlar.internetDurumu(context)){
                        if(_aciklamaController.text.isEmpty) Fluttertoast.showToast(msg: "Açıklama eklemeniz gerekiyor.",textColor: Colors.white,backgroundColor: Colors.black);
                        else{
                          _yeniZiyaretNotu();
                        }
                      }
                    },
                  ),
                ),
                SizedBox(height: 10,)
              ],
            ),
          )
      )
    );

  }

  _yeniZiyaretNotu() async {
    if(sending){
      return;
    }
    setState(() {
      sending = true;
    });
    _aciklamaController.text = _aciklamaController.text.replaceAll("'", "''");
    var body = jsonEncode({
      "vtname" : UserInfo.activeDB,
      "chkod" : widget.cariKod,
      "aciklama" : _aciklamaController.text,
      "zaman" : secilenTarih.toString().substring(0,23),
      "MikroPersonelKod" : UserInfo.mikroPersonelKod,
      "IrtibatSekli" : ziyaretTurId,
      "PlanId" : 0,
      "MusteriGorebilir" : musteriGorsunMu,
      "Mobile" : true,
      "DevInfo" : TelefonBilgiler.userDeviceInfo,
      "AppVer" : TelefonBilgiler.userAppVersion,
      "UserId" : UserInfo.activeUserId
    });
    var response = await http.post(Uri.parse(
        "${Sabitler.url}/api/YeniZiyaretNotuEkle"),
        headers: {
          "apiKey": Sabitler.apiKey,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body
    );
    if (response.statusCode == 200) {
      showDialog(context: context,builder: (context) => BilgilendirmeDialog("Ziyaret notu başarıyla kaydedilmiştir"));
    }else{
      showDialog(context: context,builder: (context) => AlertDialog(
        title: Text("Hata"),
        content: Text("Ekran görüntüsü alıp SDS Bilişim ile paylaşınız!"),
        actions: [
          TextButton(child: Text("Tamam"),onPressed: () => Navigator.pop(context),)
        ],
      ));
    }
    setState(() {
      sending = false;
    });
  }

  Future<DateTime?> getDate() {
    return showDatePicker(
      locale: Locale('tr',''),
      helpText: "ZİYARET TARİHİNİ SEÇİNİZ",
      confirmText: "TAMAM",
      cancelText: "İPTAL",
      context: context,
      initialDate: secilenTarih,
      firstDate: DateTime(2005),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.from(colorScheme: ColorScheme.light(background: Colors.white,onSurface: Colors.black,primary: Colors.blue.shade900)),
          child: child!,
        );
      },
    );
  }
  void callDatePicker() async {
    var order = await getDate();
    if(order != null){
      setState(() {
        secilenTarih = order;
        dateYear = order.year.toString();
        dateMonth = new DateFormat.MMMM('tr').format(order);
        dateDay = order.day.toString();
      });
    }
  }

  Map<int, Widget> _children = {
    0: Text('Ziyaret'),
    1: Text('Telefon'),
    2: Text('E-Posta'),
    3: Text('Fuar'),
    4: Text('Toplantı')
  };
}
