import 'dart:async';
import 'dart:convert';

import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/widgets/Dialoglar.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'package:sdsdream_flutter/Yagiz/YagizTabloSayfasi.dart';



class YagizOzelSayfa extends StatefulWidget {
  @override
  _YagizOzelSayfaState createState() => _YagizOzelSayfaState();
}

class _YagizOzelSayfaState extends State<YagizOzelSayfa> {

  TextEditingController _kodController = TextEditingController();
  TextEditingController _kgController = TextEditingController();
  TextEditingController _aciklamaController = TextEditingController();
  final DateFormat formatter = DateFormat('dd-MM-yyyy');

  String kupeNo = "";
  String kimlikNo = "";
  String adi = "";
  String dogumTarihi = "";
  String sonTartimKg =  "";
  String hayvanId =  "";
  String ciftlikKupeNo =  "";
  String grupAdi =  "";
  String turAdi =  "";
  String sonAciklama =  "";
  String yasi = "";
  String secilenTarih = DateFormat('yyyy-MM-dd').format(DateTime.now());
  DateTime now = DateTime.now();
  String dateYear = DateTime.now().year.toString();
  String dateMonth = new DateFormat.MMMM('tr').format(DateTime.now());
  String dateDay = DateTime.now().day.toString();
  bool enabled = false;
  var maskFormatter = new MaskTextInputFormatter(mask: '####.##', filter: { "#": RegExp(r'[0-9]') });
  FocusNode _nodeText5 = FocusNode();

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey.shade200,
      nextFocus: false,
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText5,
          toolbarButtons: [
                (node) {
                  return GestureDetector(
                    onTap: () => node.unfocus(),
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "TAMAM",
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ),
                  );
            },
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstScreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Tartım Ekranı"),
          actions: [
            IconButton(icon: Icon(Icons.table_view),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => YagizTabloSayfasi(),))
            )
          ],
          centerTitle: true,
          backgroundColor: Colors.blue.shade900,
        ),
        body: KeyboardActions(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    margin: const EdgeInsets.only(top: 10,left: 5,bottom: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: Offset(3, 5),
                          ),
                        ],
                        color: Colors.white
                    ),
                    child: Center(
                      child: TextFormField(
                        decoration: InputDecoration(
                            hintText:
                            'Barkod/Kimlik No Ara',
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(Icons.cancel,color: Colors.blue.shade900,),
                              onPressed: () {
                                //_dataGridController.selectedRow = null;
                                _kodController.text = "";
                                FocusScope.of(context).requestFocus(new FocusNode());
                              },
                            )
                        ),
                        controller: _kodController,
                        onFieldSubmitted: (v) {
                          _aciklamaController.clear();
                          _kgController.clear();
                          _bilgiGetir();
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                      ),
                    ),
                    width: MediaQuery.of(context).size.width -75,
                    height: 60,
                  ),
                  InkWell(
                    child: Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Container(
                          margin: EdgeInsets.only(left: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 6,
                                offset: Offset(3, 5),
                              ),
                            ],
                          ),
                          width: 60,
                          height: 60,
                          padding: EdgeInsets.all(5),
                          child: Center(child: FaIcon(FontAwesomeIcons.camera,color: Colors.blue.shade900,size: 18,),)
                      ),
                    ),
                    onTap: () {
                      scanBarcodeNormal();
                    },
                  ),
                ],
              ),
              SizedBox(height: 10,),
              ShakeAnimatedWidget(
                enabled: this.enabled,
                duration: Duration(milliseconds: 200),
                shakeAngle: Rotation.deg(z: 2),
                curve: Curves.linear,
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    height: 300 ,
                    decoration: Sabitler.dreamBoxDecoration,
                    child: Column(
                      children: [
                        Container(
                          height : 25,
                          child: Row(
                            children: [
                              Expanded(child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Küpe No",style: TextStyle(color: Colors.blue.shade900,fontSize: 18,fontWeight: FontWeight.w500),),
                                    Text(kupeNo,style: TextStyle(fontSize: 18)),
                                  ],
                                ),
                              ),),
                              VerticalDivider(thickness: 2,),
                              Expanded(child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Ç.Küpe No",style: TextStyle(color: Colors.blue.shade900,fontSize: 18,fontWeight: FontWeight.w500),),
                                    Text(ciftlikKupeNo,style: TextStyle(fontSize: 18)),
                                  ],
                                ),
                              ))
                            ],
                          ),
                        ),
                        Divider(),
                        Container(
                          height : 25,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Doğum Tarihi",style: TextStyle(color: Colors.blue.shade900,fontSize: 18,fontWeight: FontWeight.w500)),
                              dogumTarihi == "" ? Text("") : Text("($yasi AY) $dogumTarihi",style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                        Divider(),
                        Container(
                          height : 25,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Cinsi",style: TextStyle(color: Colors.blue.shade900,fontSize: 18,fontWeight: FontWeight.w500)),
                              Text(turAdi,style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                        Divider(),
                        Container(
                          height : 25,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Padok",style: TextStyle(color: Colors.blue.shade900,fontSize: 18,fontWeight: FontWeight.w500)),
                              Text(grupAdi,style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                        Divider(),
                        Container(
                          height : 25,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Son Tartım KG",style: TextStyle(color: Colors.blue.shade900,fontSize: 18,fontWeight: FontWeight.w500)),
                              Text(sonTartimKg,style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                        Divider(),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(child: Text("Son Açıklama",style: TextStyle(color: Colors.blue.shade900,fontSize: 18,fontWeight: FontWeight.w500)),width: MediaQuery.of(context).size.width,),
                              Expanded(child: Text(sonAciklama,
                                style: TextStyle(fontSize: 18),overflow: TextOverflow.ellipsis,maxLines: 2,),)
                            ],
                          ),
                        ),
                      ],
                    )
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 10,left: 10),
                margin: EdgeInsets.only(top: 10,right: 5,bottom: 5,left: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(3, 5),
                      ),
                    ],
                    color: Colors.white
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text("Tartılan Kilo",style: TextStyle(color: Colors.blue.shade900,fontSize: 18,fontWeight: FontWeight.w500)),
                    ),
                    Container(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText:
                          '0000.00',
                        ),
                        style: TextStyle(
                            fontSize: 18
                        ),
                        focusNode: _nodeText5,
                        textInputAction: TextInputAction.done,
                        textAlign: TextAlign.end,
                        keyboardType: TextInputType.numberWithOptions(decimal: true,),
                        controller: _kgController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                      ),
                      width: 90,
                    )
                  ],
                ),
                height: 60,
              ),
              Container(
                padding: EdgeInsets.only(right: 10,left: 10),
                margin: EdgeInsets.only(top: 5,right: 5,bottom: 0,left: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(3, 5),
                      ),
                    ],
                    color: Colors.white
                ),
                child: Container(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText:
                        "Açıklama",
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                        fontSize: 18
                    ),

                    textInputAction: TextInputAction.done,
                    maxLines: 3,
                    maxLength: 300,
                    controller: _aciklamaController,
                  ),
                  width: 90,
                ),
                width: MediaQuery.of(context).size.width
              ),
              InkWell(
                child: Container(
                  child:Row(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),topLeft: Radius.circular(5)),
                            color: Colors.blue.shade900,
                          ),
                          margin: EdgeInsets.only(left: 1),
                          height: 50,
                          width: MediaQuery.of(context).size.width/5,
                          child: Center(child: Text("TARİH:",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
                      ),
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(5),topRight: Radius.circular(5)),
                              border: Border.all(color: Colors.blue.shade900),
                              color: Colors.white
                          ),
                          margin: EdgeInsets.only(right: 1),
                          height: 50,
                          width: MediaQuery.of(context).size.width/5*4-12,
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
                  margin: EdgeInsets.only(top: 10,bottom: 5,left: 5,right: 5),
                ),
                onTap: () => callDatePicker(),
              ),
              SizedBox(height: 5,),
              InkWell(
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  margin: EdgeInsets.only(left: 5,right: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: Offset(3, 5),
                        ),
                      ],
                      color: Colors.white
                  ),
                  child: Center(child: Text("Kaydet",style: TextStyle(fontSize: 18,color: Colors.blue.shade900,fontWeight: FontWeight.bold),),),
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                ),
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  _bilgiKaydet();
                },
              ),
              SizedBox(height: 5,),
            ],
          ),
          config: _buildConfig(context),
        )
      )
    );
  }
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "İptal", true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      if(barcodeScanRes != "-1"){
        _kodController.text = barcodeScanRes;
        _bilgiGetir();
      }
    });
  }

  _bilgiGetir() async {
    var response = await http.get(Uri.parse("${Sabitler.url}/api/HayvanBilgi?aranan=${_kodController.text}"),headers: {"apiKey" : Sabitler.apiKey});
    if(response.statusCode == 200){
      var bilgiler = jsonDecode(response.body);
      for(var bilgi in bilgiler){
        setState(() {
          kupeNo = Foksiyonlar.stringNullCheck(bilgi["ht_kupe_no"]);
          kimlikNo = Foksiyonlar.stringNullCheck(bilgi["ht_kimligi"]);
          adi = Foksiyonlar.stringNullCheck(bilgi["ht_adi"]);
          dogumTarihi = formatter.format(DateTime.parse(bilgi["ht_dogum_tarihi"]));
          sonTartimKg = Foksiyonlar.stringNullCheck(bilgi["td_kg"].toString());
          hayvanId = Foksiyonlar.stringNullCheck(bilgi["ht_id"].toString());
          sonAciklama = Foksiyonlar.stringNullCheck(bilgi["td_aciklama"].toString());
          ciftlikKupeNo = Foksiyonlar.stringNullCheck(bilgi["ht_ciftlik_kupe_no"].toString());
          turAdi = Foksiyonlar.stringNullCheck(bilgi["tur_ad"].toString());
          grupAdi = Foksiyonlar.stringNullCheck(bilgi["gr_ad"].toString());
          yasi = bilgi["yasi"].toString();
        });
      }
      setState(() {
        enabled = !enabled;
      });
      Timer(Duration(milliseconds: 300), () {
        setState(() {
          enabled = false;
        });
      });
    }else if(response.statusCode == 400){
      var message = jsonDecode(response.body);
      showDialog(context: context,builder: (context) => BilgilendirmeDialog(message["Message"]));
    }
    print(response.body);
  }

  _bilgiKaydet() async {
    String aciklama = _aciklamaController.text.replaceAll("'", "''");
    if(kupeNo == "" || hayvanId == ""){
      showDialog(context: context,builder: (context) => BilgilendirmeDialog("Tartım yapabilmek için önce aramadan tartımını yapacağınız hayvanın bilgilerini getirin."));
      return;
    }
    var response = await http.get(Uri.parse("${Sabitler.url}/api/HayvanBilgi?hayvanId=$hayvanId&tarih=$secilenTarih"),headers: {"apiKey" : Sabitler.apiKey});
    if(response.statusCode == 400){
      var body = jsonEncode({
        "hayvanId" : hayvanId,
        "tartimTarih": secilenTarih,
        "kilo" : _kgController.text.toString(),
        "aciklama" : aciklama,
        "tdId" : 0,
        "userId" : UserInfo.activeUserId
      });
      response = await http.post(Uri.parse(
          "${Sabitler.url}/api/TartimKaydet"),
          headers: {
            "apiKey": Sabitler.apiKey,
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: body
      ).timeout(Duration(seconds: 20));
      if(response.statusCode == 200){
        Fluttertoast.showToast(
            msg: "Tartım Kaydedildi",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            textColor: Colors.white,
            backgroundColor: Colors.black,
            fontSize: 16.0
        );
        setState(() {
          kupeNo = "";
          kimlikNo = "";
          adi = "";
          dogumTarihi = "";
          sonTartimKg =  "";
          hayvanId =  "";
          _kgController.clear();
          _kodController.clear();
          _aciklamaController.clear();
          ciftlikKupeNo = "";
          grupAdi = "";
          turAdi = "";
          sonAciklama = "";
          yasi = "";
        });
      }else if(response.statusCode == 400){
        var message = jsonDecode(response.body);
        showDialog(context: context,builder: (context) => BilgilendirmeDialog(message["Message"]));
      }
    }else if(response.statusCode == 200){
      var tdId = jsonDecode(response.body);
      showDialog(context: context,builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/10),
            child: Container(
              height: 140,
              child: Column(
                children: [
                  Container(
                    height: 70,
                      child: Text("Bu aya ait tartım mevcut değiştirmek istiyor musunuz?",style: TextStyle(color: Colors.black,fontSize: 17),maxLines: 4,textAlign: TextAlign.center,),
                      margin: EdgeInsets.only(top: 2,bottom: 5),
                      padding: EdgeInsets.only(left: 5,top: 20,bottom: 10,right: 5)
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 10,left: 10),
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: TextButton(
                          child: Text("İptal Et",style: TextStyle(color: Colors.grey.shade200),),
                          /*
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                side: BorderSide(color: Colors.red)),
                            color: Colors.red,*/
                          onPressed: () {
                            if(UserInfo.activeDB != null){
                              Navigator.pop(context);
                            }
                          },
                        ),),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(child: TextButton(
                          child: Text("Tartımı Kaydet",style: TextStyle(color: Colors.grey.shade200),),
                          /*
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                side: BorderSide(color: Colors.green)),
                            color: Colors.green,*/
                          onPressed: () async {
                            var body = jsonEncode({
                              "hayvanId" : hayvanId,
                              "tartimTarih": secilenTarih,
                              "kilo" : _kgController.text.toString(),
                              "aciklama" : aciklama,
                              "tdId" : int.parse(tdId.toString()),
                              "userId" : UserInfo.activeUserId
                            });
                            print(body);
                            response = await http.post(Uri.parse(
                                "${Sabitler.url}/api/TartimKaydet"),
                                headers: {
                                  "apiKey": Sabitler.apiKey,
                                  'Content-Type': 'application/json; charset=UTF-8',
                                },
                                body: body
                            ).timeout(Duration(seconds: 20));
                            Navigator.pop(context);
                            if(response.statusCode == 200){
                              Fluttertoast.showToast(
                                  msg: "Tartım Kaydedildi",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  textColor: Colors.white,
                                  backgroundColor: Colors.black,
                                  fontSize: 16.0
                              );
                              setState(() {
                                kupeNo = "";
                                kimlikNo = "";
                                adi = "";
                                dogumTarihi = "";
                                sonTartimKg =  "";
                                hayvanId =  "";
                                _kgController.clear();
                                _kodController.clear();
                                _aciklamaController.clear();
                                ciftlikKupeNo = "";
                                grupAdi = "";
                                turAdi = "";
                                sonAciklama = "";
                                yasi = "";
                              });
                            }else if(response.statusCode == 400){
                              var message = jsonDecode(response.body);
                              showDialog(context: context,builder: (context) => BilgilendirmeDialog(message["Message"]));
                            }
                          },
                        ))
                      ],
                    ),
                  )
                ],
              ),
            ),
          )));
    }

  }
  Future<DateTime?> getDate() {
    return showDatePicker(
      locale: Locale('tr',''),
      helpText: "TARİH SEÇİNİZ",
      confirmText: "TAMAM",
      cancelText: "İPTAL",
      context: context,
      initialDate: now,
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
        dateDay = order.day.toString();
        dateMonth = new DateFormat.MMMM('tr').format(order);
        dateYear = order.year.toString();
        secilenTarih = DateFormat('yyyy-MM-dd').format(order);
        now = order;
      });
    }
  }
}
