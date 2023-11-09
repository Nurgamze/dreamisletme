import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sdsdream_flutter/Stoklar/models/stok.dart';
import 'package:sdsdream_flutter/modeller/GridModeller.dart';
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/Stoklar/StokAcikSiparislerSayfasi.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'StokAlternatifleriSayfasi.dart';
import 'StokFiyatlariSayfasi.dart';
import 'StokKimlerdenAlinmis.dart';
import 'StokKimlereSatilmisSayfasi.dart';
import 'StokReferanslarSayfasi.dart';

class StokDetaySayfasi extends StatefulWidget {
  final StoklarGridModel data;
  const StokDetaySayfasi({super.key, required this.data,});
  @override
  _StokDetaySayfasiState createState() => _StokDetaySayfasiState();
}

class _StokDetaySayfasiState extends State<StokDetaySayfasi> {

  int _currentSelection = 0;
  bool depo1Mi = false;
  final formatter = new NumberFormat("#,##0.00");
  bool satislarVisible = true;
  bool _btnStokFiyat = true;
  Color myBlue = Colors.blue.shade900;
  int seciliButon = 0;
  PageController? controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
    if(UserInfo.activeDB =="MikroDB_V16_12"){
      seciliButon = 1;
    }else{
      seciliButon = 0;
    }
    if(UserInfo.fullAccess == true || UserInfo.satisDetay == true){
      setState(() {
        satislarVisible = true;
      });
    }else{
      setState(() {
        satislarVisible = false;
      });
    }
    if (!UserInfo.fullAccess)
    {
      _btnStokFiyat = false;
    }
    if (UserInfo.alisDetayYetkisi)
    {
      _btnStokFiyat = true;
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    AutoOrientation.fullAutoMode();
  }
  @override
  Widget build(BuildContext context) {
    double toplam = depo1Mi ? widget.data.D1SdsToplamStokMerkezDahil : widget.data.sdsToplamStokMerkezDahil;
    double sube = depo1Mi ? widget.data.depo1StokMiktar : widget.data.tumDepolarStokMiktar;
    
    
    
    controller = PageController(initialPage: seciliButon);

    return ConstScreen(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Container(color: myBlue,),
        ),
        body: Padding(
          padding: EdgeInsets.only(bottom: Device.get().isIphoneX ? 16 : 0),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width-50,
                  child: Column(
                    children: [
                      Container(
                          height: MediaQuery.of(context).size.height*4/25,
                          width: MediaQuery.of(context).size.width-50,
                          padding: EdgeInsets.only(left: 10,top: 15),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  child: Text(widget.data.stokKodu,style: GoogleFonts.roboto(fontSize: 17,color: Colors.blue.shade900,fontWeight: FontWeight.bold),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                  onTap: () {
                                    Clipboard.setData((new ClipboardData(text: widget.data.stokKodu)));
                                    Fluttertoast.showToast(
                                        msg: "Stok kodu panoya kopyalandı.",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        textColor: Colors.white,
                                        backgroundColor: Colors.black,
                                        fontSize: 16.0
                                    );
                                  },
                                ),
                                SizedBox(height: 2,),
                                InkWell(
                                  child: Text(widget.data.stokIsim,style: GoogleFonts.roboto(fontSize: 15,color: Colors.black),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                  onTap: () {
                                    Clipboard.setData((new ClipboardData(text: widget.data.stokIsim)));
                                    Fluttertoast.showToast(
                                        msg: "Stok adı panoya kopyalandı.",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        textColor: Colors.white,
                                        backgroundColor: Colors.black,
                                        fontSize: 16.0
                                    );
                                  },
                                ),
                                SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(child: Container(
                                      child: Column(
                                        children: [
                                          Text("TOPLAM",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.w500))),
                                          Text(formatter.format(toplam),style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Foksiyonlar.moneyColor(toplam),fontWeight: FontWeight.w500))),
                                        ],
                                      ),
                                    ),),
                                    Expanded(child: Container(
                                      child: Column(
                                        children: [
                                          Text("ŞUBE",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.w500))),
                                          Text(formatter.format(sube),style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Foksiyonlar.moneyColor(sube),fontWeight: FontWeight.w500))),
                                        ],
                                      ),
                                    ),),
                                    InkWell(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade500.withOpacity(0.2),
                                              spreadRadius: 2,
                                              blurRadius: 3,
                                              offset: Offset(0, 0.5),
                                            ),
                                          ],
                                        ),
                                        margin: EdgeInsets.only(right: (MediaQuery.of(context).size.width-50)/12,),
                                        width: (MediaQuery.of(context).size.width-50)/4+10,
                                        height: 50,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text("SİPARİŞ",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.w500))),
                                            Text(formatter.format(widget.data.alinanSiparisKalan),style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Foksiyonlar.moneyColor(widget.data.alinanSiparisKalan),fontWeight: FontWeight.w500))),
                                          ],
                                        ),
                                      ),
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StokAcikSiparislerSayfasi(false, data: widget.data,))),
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                      ),
                      Container(
                        color: Colors.grey.shade800,
                        height: 1,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height*12/25+50,
                        width: MediaQuery.of(context).size.width-50,
                        child: PageView(
                          controller: controller,
                          onPageChanged: (value) {
                            setState(() {
                              seciliButon = value;
                            });
                          },
                          children: <Widget>[
                            sdsDepolar(),
                            zenitledDepolar(),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.grey.shade800,
                        height: 1,
                      ),
                      Expanded(child:
                      Container(
                          height:MediaQuery.of(context).size.height*7/25-30,
                          width: MediaQuery.of(context).size.width-50,
                          child: GridView.count(
                            padding: EdgeInsets.only(left: 7,right: 7,top: 5),
                            crossAxisCount: 2,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            childAspectRatio: ((MediaQuery.of(context).size.width-50)/2-6)/75,
                            children: menuListSet(context),
                          )
                      )),

                    ],
                  ),
                ),
              ),
              Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Colors.blue.shade900
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            color: Colors.blue.shade900,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  child: Container(
                                    height: 40,
                                    width: 50,
                                    child: Icon(Icons.arrow_back_ios_outlined,color: Colors.white,),
                                  ),
                                  onTap: () => Navigator.pop(context),
                                ),
                                RotatedBox(
                                    quarterTurns:3,
                                    child: Center(child: Text('Özet',style: TextStyle(color: Colors.white,fontSize: 21),),)
                                ),
                              ],
                            ),
                            height: MediaQuery.of(context).size.height*4/25,
                            width: 50,
                          ),
                          Container(
                            color: Colors.grey.shade800,
                            height: 1,
                          ),
                          InkWell(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              color: seciliButon == 0 ? Colors.indigo.shade900 : myBlue,
                              child: RotatedBox(
                                  quarterTurns:3,
                                  child: Center(child: Image.asset("assets/images/sdswhite.png",),)
                              ),
                              height: MediaQuery.of(context).size.height*6/25+25,
                              width: 50,
                            ),
                            onTap: () {
                              setState(() {
                                seciliButon = 0;
                                controller!.animateToPage(0, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
                              });
                            },
                          ),
                          InkWell(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              color: seciliButon == 1 ? Colors.indigo.shade900 : myBlue,
                              child: RotatedBox(
                                  quarterTurns:3,
                                  child: Center(child: Image.asset("assets/images/zenitwhite.png",),)
                              ),
                              height: MediaQuery.of(context).size.height*6/25+25,
                              width: 50,
                            ),
                            onTap: () {
                              setState(() {
                                seciliButon = 1;
                                controller!.animateToPage(1, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
                              });
                            },
                          ),
                          Container(
                            color: Colors.grey.shade800,
                            height: 1,
                          ),
                          Expanded(child: Container(
                            color: Colors.blue.shade900,
                            child: RotatedBox(
                                quarterTurns:3,
                                child: Center(child: Text('Menü',style: TextStyle(color: Colors.white,fontSize: 21),),)
                            ),
                            height:MediaQuery.of(context).size.height*7/25-20,
                            width: 50,
                          ),)
                        ],
                      )
                  )
              ),
            ],
          ),
        )
      )
    );


  }

  Widget sdsDepolar(){
    double eurasia = depo1Mi ? widget.data.D1SdsEurasia : widget.data.sdsEurasia;
    double merkez = depo1Mi ? widget.data.D1SdsMerkez : widget.data.sdsMerkez;
    double izmir = depo1Mi ? widget.data.D1SdsIzmir : widget.data.sdsizmir;
    double adana = depo1Mi ? widget.data.D1SdsAdana : widget.data.sdsAdana;
    double antalya = depo1Mi ? widget.data.D1SdsAntalya : widget.data.sdsAntalya;
    double seyrantepe = depo1Mi ? widget.data.D1SdsSeyrantepe : widget.data.sdsSeyrantepe;
    double ankara = depo1Mi ? widget.data.D1SdsAnkara : widget.data.sdsAnkara;
    double bursa = depo1Mi ? widget.data.D1SdsBursa : widget.data.sdsBursa;
    double anadolu = depo1Mi ? widget.data.D1SdsAnadolu : widget.data.sdsAnadolu;
    double izmit = depo1Mi ? widget.data.D1SdsIzmit : widget.data.sdsIzmit;
    double bodrum = depo1Mi ? widget.data.D1SdsBodrum: widget.data.sdsBodrum;
    double kayseri = depo1Mi ? widget.data.D1SdsKayseri: widget.data.sdsKayseri;
    double? sivas = depo1Mi ? widget.data.D1SdsSivas: widget.data.sdsSivas;

    return Stack(
      children: [
        Align(
          child: ListView(
            padding: EdgeInsets.only(left: 10,right: 10),
            children: [
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      child: Container(
                        decoration: Sabitler.dreamBoxDecoration,
                        width: (MediaQuery.of(context).size.width-50)/2-15,
                        height: 50,
                        padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(" MERKEZ ",style: GoogleFonts.roboto(fontSize: 15,color: Colors.black,fontWeight: FontWeight.w500),),
                                FaIcon(FontAwesomeIcons.infoCircle,size: 15,color: Colors.blue.shade900,)
                              ],
                            ),
                            Text(formatter.format(merkez),style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(merkez)),maxLines: 1,)
                          ],
                        ),
                      ),
                      onTap: () {
                        if(UserInfo.fullAccess){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => StokAcikSiparislerSayfasi(true,data: widget.data)));
                        }
                      }
                  ),
                  Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: (MediaQuery.of(context).size.width-50)/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("İZMİR",style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text(formatter.format(izmir),style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(izmir)),)
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: (MediaQuery.of(context).size.width-50)/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ADANA",style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text(formatter.format(adana),style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(adana)),)
                      ],
                    ),
                  ),
                  Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: (MediaQuery.of(context).size.width-50)/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ANTALYA",style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text(formatter.format(antalya),style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(antalya)),)
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: (MediaQuery.of(context).size.width-50)/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("SEYRANTEPE",style: GoogleFonts.roboto(fontSize: 15,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text(formatter.format(seyrantepe),style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(seyrantepe)),)
                      ],
                    ),
                  ),
                  Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: (MediaQuery.of(context).size.width-50)/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ANKARA",style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text(formatter.format(ankara),style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(ankara)),)
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: (MediaQuery.of(context).size.width-50)/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("EURAISA",style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text(formatter.format(eurasia),style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(eurasia)),)
                      ],
                    ),
                  ),
                  Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: (MediaQuery.of(context).size.width-50)/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("BURSA",style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text(formatter.format(bursa),style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(bursa)),)
                      ],
                    ),
                  ),

                ],
              ),
              SizedBox(height: 7,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: (MediaQuery.of(context).size.width-50)/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ANADOLU",style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text(formatter.format(anadolu),style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(anadolu)),)
                      ],
                    ),
                  ),
                  Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: (MediaQuery.of(context).size.width-50)/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("BODRUM",style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text(formatter.format(bodrum),style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(bodrum)),)
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 7,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: (MediaQuery.of(context).size.width-50)/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text( "KAYSERİ",style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text(formatter.format(kayseri),style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(kayseri)),)
                      ],
                    ),
                  ),
                  Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: ( MediaQuery.of(context).size.width-50 )/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("İZMİT",style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text(formatter.format(izmit),style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(izmit)),)
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox (height: 7),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: ( MediaQuery.of(context).size.width-50 )/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("SİVAS", style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text(formatter.format(sivas),style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(sivas!)),)
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7,),
              SizedBox(height: 7,),
            ],
          ),
        ),
        Align(
          child: Container(
            margin: EdgeInsets.only(bottom: 10),
            child: CupertinoSlidingSegmentedControl(
              onValueChanged: (value) {
                setState(() {
                  _currentSelection = int.parse(value.toString());
                  if(value ==1){
                    setState(() {
                      depo1Mi = true;
                    });
                  }else{
                    depo1Mi = false;
                  }
                });
              },
              groupValue: _currentSelection,
              children: _children,
            ),
          ),
          alignment: Alignment.bottomRight,
        ),
      ],
    );
}
  Widget zenitledDepolar(){
    return Stack(
      children: [
        Align(
          child:ListView(
            padding: EdgeInsets.only(left: 10,right: 10),
            children: [
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: (MediaQuery.of(context).size.width-50)/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("LOJİSTİK",style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text("${formatter.format(widget.data.zenitledMerkez)}",style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(widget.data.zenitled)),)
                      ],
                    ),
                  ),Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: (MediaQuery.of(context).size.width-50)/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("KEYAP",style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text("${formatter.format(widget.data.zenitled)}",style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(widget.data.zenitled)),)
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: (MediaQuery.of(context).size.width-50)/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ADANA",style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text("${formatter.format(widget.data.zenitledAdana)}",style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(widget.data.zenitledAdana)),)
                      ],
                    ),
                  ),
                  Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: (MediaQuery.of(context).size.width-50)/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("BURSA",style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text(formatter.format(widget.data.zenitledBursa),style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(widget.data.zenitledBursa)),)
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: (MediaQuery.of(context).size.width-50)/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ANTALYA",style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text(formatter.format(widget.data.zenitledAntalya),style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(widget.data.zenitledBursa),))
                      ],
                    ),
                  ),
                  Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: (MediaQuery.of(context).size.width-50)/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ANKARA",style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text(formatter.format(widget.data.zenitledAnkara ),style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(widget.data.zenitledAnkara)),)
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 7,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: (MediaQuery.of(context).size.width-50)/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("KONYA",style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text(formatter.format(widget.data.zenitledKonya),style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(widget.data.zenitledKonya)),)
                      ],
                    ),
                  ), Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: (MediaQuery.of(context).size.width-50)/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("PERPA",style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text(formatter.format(widget.data.zenitledPerpa),style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(widget.data.zenitledPerpa)),)
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: Sabitler.dreamBoxDecoration,
                    width: (MediaQuery.of(context).size.width-50)/2-15,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("E-TİCARET",style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                        Text(formatter.format(widget.data.zenitledETicaret),style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(widget.data.zenitledETicaret)),)
                      ],
                    ),
                  ),
                  Visibility(
                    child: Container(
                      decoration: Sabitler.dreamBoxDecoration,
                      width: (MediaQuery.of(context).size.width-50)/2-15,
                      height: 50,
                      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("FABRİKA",style: GoogleFonts.roboto(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500),),
                          Text(formatter.format(widget.data.zenitledUretim ),style: GoogleFonts.roboto(fontSize: 16,color: Foksiyonlar.moneyColor(widget.data.zenitledUretim)),)
                        ],
                      ),
                    ),
                    visible: UserInfo.zenitUretimYetki,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> menuListSet(BuildContext context){
    List<Widget> menuList = [];
    if(_btnStokFiyat) {
      menuList.add( InkWell(
        child: Container(
          width: (MediaQuery.of(context).size.width-50)/2-6,
          height: 75,
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
              color: Colors.white
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15,top: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text("Fiyatlar",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 15,bottom: 10),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FaIcon(FontAwesomeIcons.tags,color: Colors.blue.shade900,size: 30,),
                ),
              ),
            ],
          ),
        ),
        onTap: () async{
          if(await Foksiyonlar.internetDurumu(context)){
            Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight,child: StokFiyatlariSayfasi(stokKodu: widget.data.stokKodu)));
          }
        },
      ));
    }
    menuList.add(InkWell(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 75,
        ),
        child: Container(
          width: (MediaQuery.of(context).size.width-50)/2-6,
          height: 75,
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
              color: Colors.white
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15,top: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text("Satışlar",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 15,bottom: 10),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FaIcon(FontAwesomeIcons.shoppingBasket,color: Colors.blue.shade900,size: 30,),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () async{
        if(await Foksiyonlar.internetDurumu(context)){
          Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight,child: StokKimlereSatilmisSayfasi(stokKodu: widget.data.stokKodu)));
        }
      },
    ));
    if(UserInfo.alisDetayYetkisi) {
      menuList.add(InkWell(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 80,
          ),
          child: Container(
            width: (MediaQuery.of(context).size.width-50)/2-6,
            height: 75,
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
                color: Colors.white
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 15,top: 10),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text("Alışlar",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15,bottom: 10),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FaIcon(FontAwesomeIcons.handHoldingMedical,color: Colors.blue.shade900,size: 30,),
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () async{
          if(await Foksiyonlar.internetDurumu(context)){
            Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight,child: StokKimlerdenAlinmisSayfasi(stokKodu: widget.data.stokKodu)));
          }
        },
      ));
    }
    menuList.add(InkWell(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 75,
        ),
        child: Container(
          width: (MediaQuery.of(context).size.width-50)/2-6,
          height: 75,
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
              color: Colors.white
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15,top: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text("Alternatifler",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 15,bottom: 10),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FaIcon(FontAwesomeIcons.puzzlePiece,color: Colors.blue.shade900,size: 30,),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () async{
        if(await Foksiyonlar.internetDurumu(context)){
          Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight,child: StokAlternatifleriSayfasi(data: widget.data)));
        }
      },
    ),);
    menuList.add(InkWell(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 75,
        ),
        child: Container(
          width: (MediaQuery.of(context).size.width-50)/2-6,
          height: 75,
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
              color: Colors.white
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15,top: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text("Referans\nMüşteriler",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 15,bottom: 10),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FaIcon(FontAwesomeIcons.users,color: Colors.blue.shade900,size: 30,),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () async{
        if(await Foksiyonlar.internetDurumu(context)){
          Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight,child: StokReferanslarSayfasi(stokKodu: widget.data.stokKodu,stokAdi: widget.data.stokIsim)));
        }
      },
    ),);
    return menuList;
  }

  Map<int, Widget> _children = {
    0: Text('Hepsi'),
    1: Text('Depo 1'),
  };
  
  
}
