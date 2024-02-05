import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'FireCikis.dart';
import 'PlanlıMalSevk.dart';
import 'PlansizMalSeck.dart';
import 'SarfCikis.dart';


class Cikis extends StatefulWidget {
  @override
  _CikisState createState() => _CikisState();
}


class _CikisState extends State<Cikis> {


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
                                  child: Text("Planlı\nMal Sevk",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
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
                      onTap: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>PlanliMalSevk()));
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
                                  child: Text("Plansız\nMal Sevk",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
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
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>PlansizMalSevk()));
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
                                  child: Text("İade Sevk",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
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
                                  child: Text("Üretime\nSevk",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
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
                                  child: Text("Sayım Çıkış",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
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
                                  child: Text("Sarf Çıkış",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
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
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>SarfCikis()));
                      }
                  ),
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
                                  child: Text("Fire Çıkış",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
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
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>FireCikis()));
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
                                  child: Text("Devir Çıkış",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
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
                                  child: Text("Depolar Arası\nSevk",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
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
                  ),
                  SizedBox(width: 5,),
                /*  InkWell(
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
                                child: Text("Depolar Arası\nNakliye",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)

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
                  )*/
                ],
              ),
            ],
          ),
        )
    );
  }


}