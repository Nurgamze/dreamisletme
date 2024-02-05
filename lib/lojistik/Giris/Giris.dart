
/*
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sdsdream_flutter/lojistik/Giris/%C4%B0adeKabul.dart';
import 'package:sdsdream_flutter/lojistik/Giris/SayimGiris.dart';
import 'PlanliMalKabul.dart';
import 'PlansizMalKabul.dart';


class Giris extends StatefulWidget {
  @override
  _GirisState createState() => _GirisState();
}


class _GirisState extends State<Giris> {
  int?  evrakId=5;
  String?  depoAdi="Keyap";



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Container(
            child: Image(image: AssetImage("assets/images/appbar_title2.png"),width: 120),
          ),
          backgroundColor: Colors.blue.shade900,
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 15),
          child: ListView(
            children: [
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                      child: Container(
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
                                  child: Text("Planlı\nMal Kabul",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 15,bottom: 10),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: FaIcon(FontAwesomeIcons.solidFileAlt,color: Colors.blue.shade900,size: 30,),
                              ),
                            ),
                          ],
                        ),
                        height: 80,
                        width: (MediaQuery.of(context).size.width-35)/2,
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PlanliMalKabul()));
                      }
                  ),
                  SizedBox(width: 5,),
                  InkWell(
                      child: Container(
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
                                  child: Text("Plansız\nMal Kabul",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 15,bottom: 10),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: FaIcon(FontAwesomeIcons.barcode,color: Colors.blue.shade900,size: 30,),
                              ),
                            ),
                          ],
                        ),
                        height: 80,
                        width: (MediaQuery.of(context).size.width-35)/2,
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PlansizMalKabul()));
                      }
                  )
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                      child: Container(
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
                                  child: Text("İade Kabul",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 15,bottom: 10),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: FaIcon(FontAwesomeIcons.exchangeAlt,color: Colors.blue.shade900,size: 30,),
                              ),
                            ),
                          ],
                        ),
                        height: 80,
                        width: (MediaQuery.of(context).size.width-35)/2,
                      ),
                      onTap: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => IadeKabul()));

                      }
                  ),
                  SizedBox(width: 5,),
                  InkWell(
                      child: Container(
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
                                  child: Text("Sayım Giriş",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 15,bottom: 10),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: FaIcon(FontAwesomeIcons.barcode,color: Colors.blue.shade900,size: 30,),
                              ),
                            ),
                          ],
                        ),
                        height: 80,
                        width: (MediaQuery.of(context).size.width-35)/2,
                      ),
                      onTap: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SayimGiris()));
                      }
                  )
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                 /* InkWell(
                      child: Container(
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
                                  child: Text("Depo Nakliye\nKontrol",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 15,bottom: 10),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: FaIcon(FontAwesomeIcons.exchangeAlt,color: Colors.blue.shade900,size: 30,),
                              ),
                            ),
                          ],
                        ),
                        height: 80,
                        width: (MediaQuery.of(context).size.width-35)/2,
                      ),
                      onTap: () async {
                      }
                  ),*/
                  SizedBox(width: 5,),
                 /* InkWell(
                      child: Container(
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
                                  child: Text("Sayım Giriş",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 15,bottom: 10),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: FaIcon(FontAwesomeIcons.barcode,color: Colors.blue.shade900,size: 30,),
                              ),
                            ),
                          ],
                        ),
                        height: 80,
                        width: (MediaQuery.of(context).size.width-35)/2,
                      ),
                      onTap: () async {

                      }
                  )*/
                ],
              ),
              SizedBox(height: 10,),
           /*   Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                      child: Container(
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
                                  child: Text("Devir Giriş",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 15,bottom: 10),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: FaIcon(FontAwesomeIcons.exchangeAlt,color: Colors.blue.shade900,size: 30,),
                              ),
                            ),
                          ],
                        ),
                        height: 80,
                        width: (MediaQuery.of(context).size.width-35)/2,
                      ),
                      onTap: () async {
                      }
                  ),
                  SizedBox(width: 5,),
                ],
              ),*/

            ],
          ),
        )
    );
  }


}
*/
