import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/intl.dart';
import 'package:sdsdream_flutter/cariler/CariAcikSiparisler.dart';
import 'package:sdsdream_flutter/cariler/cari_donemsel_bakiye_view.dart';
import 'package:sdsdream_flutter/cariler/cari_ekstre_view.dart';
import 'package:sdsdream_flutter/cariler/cari_satislar_view.dart';
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/widgets/Dialoglar.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'package:sdsdream_flutter/core/extensions/double_extensions.dart';
import '../ZiyaretlerSayfasi.dart';
import 'AdresleriSayfasi.dart';
import 'AlislarSayfasi.dart';
import 'OrtalamaVadeSayfasi.dart';
import '../OdemeYap.dart';
import 'cari_risk_foyu_view.dart';
import 'models/cari.dart';


class CariDetaySayfasi extends StatefulWidget {
  final DreamCari data;
  CariDetaySayfasi({required this.data});
  @override
  _CariDetaySayfasiState createState() => _CariDetaySayfasiState();
}

class _CariDetaySayfasiState extends State<CariDetaySayfasi> {

  bool submitting = true;
  bool riskFoyuDonemsel = true;
  bool satislarVisible = true;
  String maliYil = DateTime.now().year.toString();
  static DateTime now = DateTime.now();
  String currentDay = DateFormat('dd-MM-yyyy').format(now);
  int seciliButon = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
    if(UserInfo.fullAccess || UserInfo.riskFoyuDonemselBakiye) {
      riskFoyuDonemsel = true;
    } else {
      riskFoyuDonemsel = false;
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
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    AutoOrientation.fullAutoMode();
  }
  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double myFontSize;
    myFontSize = screenWidth <= 375 ? 12.5 : 16;
    Color myBlue = Colors.blue.shade900;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return ConstScreen(
      child: Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: Container(color: myBlue,),
          ),
          body: Stack(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: MediaQuery.of(context).size.width-50,
                height: screenHeight,
                child: Column(
                  children: [
                    Container(
                        height: MediaQuery.of(context).size.height*2/25+20,
                        width: MediaQuery.of(context).size.width-50,
                        padding: const EdgeInsets.only(left: 5,top: 5,right: 5),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                child: Text(widget.data.kod ?? "",style: GoogleFonts.roboto(fontSize: 18,color: Colors.blue.shade900,fontWeight: FontWeight.bold),),
                                onTap: () {
                                  Clipboard.setData((ClipboardData(text: widget.data.kod)));
                                  Fluttertoast.showToast(
                                      msg: "Cari kod panoya kopyalandı.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      textColor: Colors.white,
                                      backgroundColor: Colors.black,
                                      fontSize: 16.0
                                  );
                                },
                              ),
                              const SizedBox(height: 4,),
                              InkWell(
                                child: Text(widget.data.unvan ?? "",style: GoogleFonts.roboto(fontSize: 18,color: Colors.black),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                onTap: () {
                                  Clipboard.setData((ClipboardData(text: widget.data.unvan)));
                                  Fluttertoast.showToast(
                                      msg: "Ünvan panoya kopyalandı.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      textColor: Colors.white,
                                      backgroundColor: Colors.black,
                                      fontSize: 16.0
                                  );
                                },
                              )
                            ],
                          ),
                        )
                    ),
                    const Divider(color: Colors.black,),
                    Container(
                        height: MediaQuery.of(context).size.height*5.8/25-5,
                        width: MediaQuery.of(context).size.width-50,
                        padding: const EdgeInsets.only(left: 2,right: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade500.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 3,
                                          offset: Offset(0, 0.5),
                                        ),
                                      ],
                                      color: Colors.green
                                  ),
                                  width: (MediaQuery.of(context).size.width-50)/2-6,
                                  height: MediaQuery.of(context).size.height*5.8/25/3.5+3,
                                  padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Text("BAKİYE",style: GoogleFonts.roboto(fontSize: myFontSize-1,color: Colors.white,fontWeight: FontWeight.w500),),
                                      Text(widget.data.bakiye!.twoDecimalFormat,style: GoogleFonts.roboto(fontSize: myFontSize+3,color: Colors.white),)
                                    ],
                                  ),
                                ),
                                InkWell(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade500.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 3,
                                            offset: Offset(0, 0.5),
                                          ),
                                        ],
                                        color: Colors.red
                                    ),
                                    width: (MediaQuery.of(context).size.width-50)/2-6,
                                    height: MediaQuery.of(context).size.height*5.8/25/3.5+3,
                                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text("RİSK ",style: GoogleFonts.roboto(fontSize: myFontSize-1,color: Colors.white,fontWeight: FontWeight.w500,),maxLines: 1,),
                                            FaIcon(FontAwesomeIcons.circleInfo,size: 15,color: Colors.white,)
                                          ],
                                        ),
                                        Text(widget.data.risk!.twoDecimalFormat,style: TextStyle(fontSize: myFontSize+3,color: Colors.white),maxLines: 1,textAlign: TextAlign.end,overflow: TextOverflow.clip,softWrap: false,),
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    if(await Foksiyonlar.internetDurumu(context)){
                                      Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight,child: CariRiskFoyuView(data: widget.data,)));
                                    }
                                  },
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: (MediaQuery.of(context).size.width-50)/2-6,
                                  height: MediaQuery.of(context).size.height*5.8/25/3.5+3,
                                  decoration: Sabitler.dreamBoxDecoration,
                                  padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Text("KREDİ",style: GoogleFonts.roboto(fontSize: myFontSize-1,color: Colors.black,fontWeight: FontWeight.w500),),
                                      Text(widget.data.kredi!.twoDecimalFormat,style: GoogleFonts.roboto(fontSize: myFontSize+3,color: myBlue),)
                                    ],
                                  ),
                                ),
                                Container(
                                  width: (MediaQuery.of(context).size.width-50)/2-6,
                                  height: MediaQuery.of(context).size.height*5.8/25/3.5+3,
                                  decoration: Sabitler.dreamBoxDecoration,
                                  padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Text("KALAN KREDİ",style: GoogleFonts.roboto(fontSize: myFontSize-1,color: Colors.black,fontWeight: FontWeight.w500),),
                                      Text(widget.data.kalanKredi!.twoDecimalFormat,style: GoogleFonts.roboto(fontSize: myFontSize+3,color: myBlue),maxLines: 1,textAlign: TextAlign.end,overflow: TextOverflow.clip,softWrap: false,)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: Sabitler.dreamBoxDecoration,
                                  width: (MediaQuery.of(context).size.width-50)/2-6,
                                  height: MediaQuery.of(context).size.height*5.8/25/3.5+3,
                                  padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Text("VADE",style: GoogleFonts.roboto(fontSize: myFontSize-1,color: Colors.black,fontWeight: FontWeight.w500),),
                                      Text(widget.data.vade ?? "",style: GoogleFonts.roboto(fontSize: myFontSize+3,color: myBlue),)
                                    ],
                                  ),
                                ),
                                Container(
                                  width: (MediaQuery.of(context).size.width-50)/2-6,
                                  height: MediaQuery.of(context).size.height*5.8/25/3.5+3,
                                  decoration: Sabitler.dreamBoxDecoration,
                                  padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Text("TEMSİLCİ",style: GoogleFonts.roboto(fontSize: myFontSize-1,color: Colors.black,fontWeight: FontWeight.w500),maxLines: 1,),
                                      Text(widget.data.temsilci ?? "",style: GoogleFonts.roboto(fontSize: myFontSize+3,color: myBlue),maxLines: 1,textAlign: TextAlign.end,overflow: TextOverflow.clip,softWrap: false,)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                    ),
                    Divider(
                      color: Colors.black,
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height*4.2/25-5,
                        width: MediaQuery.of(context).size.width-50,
                        padding: EdgeInsets.only(left: 2,right: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: (MediaQuery.of(context).size.width-50)/2-6,
                                  height: MediaQuery.of(context).size.height*4/25/4,
                                  decoration: Sabitler.dreamBoxDecoration,
                                  padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                  child: FittedBox(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("BÖLGE",style: GoogleFonts.roboto(fontSize: myFontSize,color: Colors.black,fontWeight: FontWeight.w500),),
                                        Text(widget.data.bolge ?? "",style: GoogleFonts.roboto(fontSize: myFontSize,color: myBlue),)
                                      ],
                                    ),
                                  )
                                ),
                                Container(
                                  width: (MediaQuery.of(context).size.width-50)/2-6,
                                  height: MediaQuery.of(context).size.height*4/25/4,
                                  decoration: Sabitler.dreamBoxDecoration,
                                  padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("SEKTÖR",style: GoogleFonts.roboto(fontSize: myFontSize,color: Colors.black,fontWeight: FontWeight.w500),),
                                      Expanded(child: Text(widget.data.sektor ?? "",style: GoogleFonts.roboto(fontSize: myFontSize,color: myBlue),maxLines: 1,overflow: TextOverflow.ellipsis,textAlign: TextAlign.end,))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: (MediaQuery.of(context).size.width-50)/2-6,
                                  height: MediaQuery.of(context).size.height*4/25/4,
                                  decoration: Sabitler.dreamBoxDecoration,
                                  padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("GRUP",style: GoogleFonts.roboto(fontSize: myFontSize,color: Colors.black,fontWeight: FontWeight.w500),),
                                      Text(widget.data.grup ?? "",style: GoogleFonts.roboto(fontSize: myFontSize,color: myBlue),)
                                    ],
                                  ),
                                ),
                                Container(
                                  width: (MediaQuery.of(context).size.width-50)/2-6,
                                  height: MediaQuery.of(context).size.height*4/25/4,
                                  decoration: Sabitler.dreamBoxDecoration,
                                  padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("M. TİPİ",style: GoogleFonts.roboto(fontSize: myFontSize,color: Colors.black,fontWeight: FontWeight.w500),),
                                      Text(widget.data.musteriTipi ?? "",style: GoogleFonts.roboto(fontSize: myFontSize,color: myBlue),)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  child: Container(
                                    width: (MediaQuery.of(context).size.width-50)/2-6,
                                    height: MediaQuery.of(context).size.height*4/25/4,
                                    decoration: Sabitler.dreamBoxDecoration,
                                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                    child: FittedBox(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text("V.D. ",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: myFontSize+1,color: Colors.black,fontWeight: FontWeight.w500)),textAlign: TextAlign.center,),
                                              Icon(Icons.copy,size: myFontSize+4,)
                                            ],
                                          ),width: 55),
                                          SizedBox(child: Text(widget.data.vDairesi ?? "",style: GoogleFonts.roboto(fontSize: myFontSize,color: myBlue),overflow: TextOverflow.ellipsis,maxLines: 1,textAlign: TextAlign.end,),width: ((MediaQuery.of(context).size.width-50)/2-6)-75,)
                                        ],
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Clipboard.setData((ClipboardData(text: widget.data.vDairesi ?? "")));
                                    Fluttertoast.showToast(
                                        msg: "Vergi dairesi panoya kopyalandı.",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        textColor: Colors.white,
                                        backgroundColor: Colors.black,
                                        fontSize: 16.0
                                    );
                                  },
                                ),
                                InkWell(
                                  child: Container(
                                    width: (MediaQuery.of(context).size.width-50)/2-6,
                                    height: MediaQuery.of(context).size.height*4/25/4,
                                    decoration: Sabitler.dreamBoxDecoration,
                                    padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text("V.N. ",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: myFontSize+1,color: Colors.black,fontWeight: FontWeight.w500)),textAlign: TextAlign.center,),
                                            Icon(Icons.copy,size: myFontSize+3,)
                                          ],
                                        ),width: 55,),
                                        SizedBox(child: Text(widget.data.vNo ?? "",style: GoogleFonts.roboto(fontSize: myFontSize,color: myBlue),overflow: TextOverflow.ellipsis,maxLines: 1,textAlign: TextAlign.end,),width: ((MediaQuery.of(context).size.width-50)/2-6)-75,)
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    Clipboard.setData((ClipboardData(text: widget.data.vNo ?? "")));
                                    Fluttertoast.showToast(
                                        msg: "Vergi numarası panoya kopyalandı.",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        textColor: Colors.white,
                                        backgroundColor: Colors.black,
                                        fontSize: 16.0
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        )
                    ),
                    const Divider(
                      color: Colors.black,
                    ),
                    Expanded(child: Container(
                        child: ListView(
                          padding: EdgeInsets.only(left: 2,right: 2,),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 2,),
                                InkWell(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 80,
                                    ),
                                    child: Container(
                                      width: (MediaQuery.of(context).size.width-50)/2-6,
                                      height: 65,
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
                                                child: Text("Ziyaretler",style: GoogleFonts.roboto(fontSize: 18,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(right: 15,bottom: 10),
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: FaIcon(FontAwesomeIcons.streetView,color: Colors.blue.shade900,size: 30,),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onTap: () async{
                                    if(await Foksiyonlar.internetDurumu(context)){
                                      Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight,child: ZiyaretlerSayfasi(false,data: widget.data)));
                                    }
                                  },
                                ),
                                SizedBox(width: 4,),
                                Visibility(
                                  child: InkWell(
                                    child: Container(
                                      width: (MediaQuery.of(context).size.width-50)/2-6,
                                      height: 65,
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
                                                child: Text("Cari\nEkstre",style: GoogleFonts.roboto(fontSize: 18,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(right: 15,bottom: 10),
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: FaIcon(FontAwesomeIcons.fileInvoiceDollar,color: Colors.blue.shade900,size: 30,),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () async{
                                      if(await Foksiyonlar.internetDurumu(context)){
                                        callDatePicker();
                                      }
                                    },
                                  ),
                                  visible: UserInfo.fullAccess,),
                              ],
                            ),
                            SizedBox(height: 7,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 2,),
                                Visibility(
                                  child: InkWell(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: 80,
                                      ),
                                      child: Container(
                                        width: (MediaQuery.of(context).size.width-50)/2-6,
                                        height: 65,
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
                                                  child: Text("Risk\nFöyü",style: GoogleFonts.roboto(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(right: 15,bottom: 10),
                                              child: Align(
                                                alignment: Alignment.bottomRight,
                                                child: FaIcon(FontAwesomeIcons.exclamationTriangle,color: Colors.blue.shade900,size: 30,),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    onTap: () async{
                                      if(await Foksiyonlar.internetDurumu(context)){
                                        Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight,child: CariRiskFoyuView(data:  widget.data)));
                                      }
                                    },
                                  ),
                                  visible: riskFoyuDonemsel,),
                                Visibility(
                                  child:  SizedBox(width: 4,),
                                  visible: riskFoyuDonemsel,),
                                Visibility(
                                  child: InkWell(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: 80,
                                      ),
                                      child: Container(
                                        width: (MediaQuery.of(context).size.width-50)/2-6,
                                        height: 65,
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
                                                  child: Text("Dönemsel\nBakiye",style: GoogleFonts.roboto(fontSize: 18,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(right: 15,bottom: 10),
                                              child: Align(
                                                alignment: Alignment.bottomRight,
                                                child: FaIcon(FontAwesomeIcons.calendarAlt,color: Colors.blue.shade900,size: 30,),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    onTap: () async{
                                      if(await Foksiyonlar.internetDurumu(context)){
                                        maliYil = DateTime.now().year.toString();
                                        Picker(
                                            adapter: DateTimePickerAdapter(type: 13,minValue: DateTime(2005),maxValue: DateTime(DateTime.now().year)),
                                            title: new Text("Mali Yılı Seçin"),
                                            textAlign: TextAlign.right,
                                            selectedTextStyle: TextStyle(color: Colors.blue),
                                            cancel: TextButton(
                                              child: Text("İPTAL",style: TextStyle(color: Colors.red),),
                                              onPressed: (){
                                                Navigator.pop(context);
                                                },
                                            ),
                                            confirm: TextButton(
                                              child: Text("DEVAM ET",style: TextStyle(color: Colors.green),),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft,child: CariDonemselBakiyeView(maliYili: maliYil,data: widget.data)));
                                              },
                                            ),
                                            hideHeader: true,
                                            onSelect: (Picker picker, int index, List<int> selecteds) {
                                              this.setState(() {
                                                maliYil = picker.adapter.toString().substring(0,4);
                                              });
                                            }

                                        ).showDialog(context);
                                      }
                                    },
                                  ),
                                  visible: riskFoyuDonemsel,),
                              ],
                            ),
                            SizedBox(height: 7,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 2,),
                                Visibility(
                                  child: InkWell(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: 80,
                                      ),
                                      child: Container(
                                        width: (MediaQuery.of(context).size.width-50)/2-6,
                                        height: 65,
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
                                                  child: Text("Satışlar",style: GoogleFonts.roboto(fontSize: 18,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
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
                                        Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight,child: CariSatislarView(widget.data.kod,widget.data.unvan)));
                                      }
                                    },
                                  ),
                                  visible: satislarVisible,),
                                Visibility(
                                  child: SizedBox(width: 4,),
                                  visible: satislarVisible,),
                                Visibility(
                                  child: InkWell(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: 80,
                                      ),
                                      child: Container(
                                        width: (MediaQuery.of(context).size.width-50)/2-6,
                                        height: 65,
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
                                                  child: Text("Ortalama\nVade",style: GoogleFonts.roboto(fontSize: 18,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(right: 15,bottom: 10),
                                              child: Align(
                                                alignment: Alignment.bottomRight,
                                                child: FaIcon(FontAwesomeIcons.chartLine,color: Colors.blue.shade900,size: 30,),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    onTap: () async{
                                      if(await Foksiyonlar.internetDurumu(context)){
                                        if((widget.data.bakiye ?? 0) <= 0){
                                          showDialog(context: context,builder: (context) => BilgilendirmeDialog("Borç bakiyeniz bulunmadığı için ortalama vade hesaplaması yapılamamaktır. Cari Ekstrenizi incelebilirsiniz."));
                                        }else{
                                          Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight,child: OrtalamaVade(data: widget.data,)));
                                        }
                                      }
                                    },
                                  ),
                                  visible: UserInfo.fullAccess,),
                              ],
                            ),
                            SizedBox(height: 7,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 2,),
                                InkWell(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: 80,
                                    ),
                                    child: Container(
                                      width: (MediaQuery.of(context).size.width-50)/2-6,
                                      height: 65,
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
                                                child: Text("Adresler",style: GoogleFonts.roboto(fontSize: 18,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(right: 15,bottom: 10),
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: FaIcon(FontAwesomeIcons.mapMarkedAlt,color: Colors.blue.shade900,size: 30,),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onTap: () async{
                                    if(await Foksiyonlar.internetDurumu(context)){
                                      Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight,child: AdresleriSayfasi(widget.data.kod ?? "")));
                                    }
                                  },
                                ),
                                SizedBox(width: 4,),
                                InkWell(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: 80,
                                    ),
                                    child: Container(
                                      width: (MediaQuery.of(context).size.width-50)/2-6,
                                      height: 65,
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
                                                child: Text("Açık\nSiparişler",style: GoogleFonts.roboto(fontSize: 18,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(right: 15,bottom: 10),
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: FaIcon(FontAwesomeIcons.shoppingCart,color: Colors.blue.shade900,size: 30,),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onTap: () async{
                                    if(await Foksiyonlar.internetDurumu(context)){
                                      Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight,child: CariAcikSiparislerSayfasi(data: widget.data)));
                                    }
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 7,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 2,),
                                Visibility(
                                  visible: UserInfo.alisDetayYetkisi,
                                  child: InkWell(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: 80,
                                      ),
                                      child: Container(
                                        width: (MediaQuery.of(context).size.width-50)/2-6,
                                        height: 65,
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
                                                  child: Text("Alışlar",style: GoogleFonts.roboto(fontSize: 18,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
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
                                        Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight,child: AlislarSayfasi(data: widget.data)));
                                      }
                                    },
                                  ),),
                                Visibility(
                                  child: SizedBox(width: 4,),
                                  visible: UserInfo.alisDetayYetkisi,),
                                InkWell(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxHeight: 80,
                                      ),
                                      child: Container(
                                        width: (MediaQuery.of(context).size.width-50)/2-6,
                                        height: 65,
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
                                                  child: Text("Ziyaret\nPlanı",style: GoogleFonts.roboto(fontSize: 18,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(right: 15,bottom: 10),
                                              child: Align(
                                                alignment: Alignment.bottomRight,
                                                child: FaIcon(FontAwesomeIcons.calendarCheck,color: Colors.blue.shade900,size: 30,),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    onTap: ()=> showDialog(context: context,builder: (context) => BilgilendirmeDialog("Bu modül şuan geliştirilmektedir.\nYakın zamanda aktif edilmesini planlamaktayız."))
                                ),
                              ],
                            ),
                            SizedBox(height: 7,),
                          ],
                        )
                    ),)
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(top: 5,right: 5),
                child: FloatingActionButton(
                  backgroundColor: Colors.blue.shade900,
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Image.asset("assets/images/odemeBtn.png",),
                  ),
                  onPressed: () {
                    Clipboard.setData((new ClipboardData(text: widget.data.vNo ?? "")));
                    Fluttertoast.showToast(
                        msg: "Vergi no panoya kopyalandı.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        textColor: Colors.white,
                        backgroundColor: Colors.black,
                        fontSize: 16.0
                    );
                    if(UserInfo.activeDB == "MikroDB_V16_12")
                      Navigator.push(context, MaterialPageRoute(builder: (context) => OdemeSayfasi(true)));
                    else
                      Navigator.push(context, MaterialPageRoute(builder: (context) => OdemeSayfasi(false)));
                  },
                ),
              ),
            ),
            Align(
                alignment: Alignment.centerLeft,
                child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: 50,
                    decoration: BoxDecoration(
                        color: Colors.blue.shade900
                    ),
                    child: Column(
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
                            ],
                          ),
                          height: MediaQuery.of(context).size.height*2/25+20,
                          width: 50,
                        ),
                        Divider(color: Colors.black,),
                        Container(
                          color: Colors.blue.shade900,
                          child: RotatedBox(
                              quarterTurns:3,
                              child: Center(child: Text('Finansal',style: TextStyle(color: Colors.white,fontSize: 21),),)
                          ),
                          height: MediaQuery.of(context).size.height*5.8/25-5,
                          width: 50,
                        ),
                        Divider(color: Colors.black,),
                        Container(
                          color: Colors.blue.shade900,
                          child: RotatedBox(
                              quarterTurns:3,
                              child: Center(child: Text('Sektörel',style: TextStyle(color: Colors.white,fontSize: 21),),)
                          ),
                          height: MediaQuery.of(context).size.height*4.2/25-5,
                          width: 50,
                        ),
                        Divider(color: Colors.black,),
                        Expanded(child: Container(
                          color: Colors.blue.shade900,
                          child: RotatedBox(
                              quarterTurns:3,
                              child: Center(child: Text('Menü',style: TextStyle(color: Colors.white,fontSize: 21),),)
                          ),
                          height: MediaQuery.of(context).size.height*10/25-10,
                          width: 50,
                        ),)
                      ],
                    )
                )
            ),
          ],
        )
      )
    );

  }

  void callDatePicker() async {
    var date = await getDate();
    if(date != null){
      Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight,child: CariEkstreView(ekstreTarihi: date,data: widget.data,)));
      setState(() {});
    }
  }

  Future<DateTime?> getDate() {
    return showDatePicker(
      locale: Locale('tr',''),
      helpText: "EKSTRE BAŞLANGIÇ TARİHİNİ SEÇİNİZ",
      confirmText: "EKSTRE GETİR",
      cancelText: "İPTAL",
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.from(colorScheme: ColorScheme.light(background: Colors.white,onSurface: Colors.black,primary: Colors.blue.shade900)),
          child: child!,
        );
      },
    );
  }
}
