import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Sayim/SayimModulu.dart';


class Depo extends StatefulWidget {
  @override
  _DepoState createState() => _DepoState();
}


class _DepoState extends State<Depo> {


  @override
  void initState() {
    super.initState();
    print("depo modulune tıklandı");
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Container(
          child: Image(image: AssetImage("assets/images/appbartitledream.png"),width: 180,height: 50,),
        ),
        backgroundColor: Colors.blue.shade900,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                              child: Text("Sayım",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
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
                    width: (MediaQuery.of(context).size.width-30)/2,
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SayimModuluSayfasi()));
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
                              child: Text("Etiketleme",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
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
                    width: (MediaQuery.of(context).size.width-30)/2,
                  ),
                  onTap: () {

                  }
              )
            ],
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                              child: Text("Stok Virman",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
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
                    width: (MediaQuery.of(context).size.width-30)/2,
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
                              child: Text("Depolar",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 15,bottom: 10),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: FaIcon(FontAwesomeIcons.warehouse,color: Colors.blue.shade900,size: 30,),
                          ),
                        ),
                      ],
                    ),
                    height: 80,
                    width: (MediaQuery.of(context).size.width-30)/2,
                  ),
                  onTap: () async {

                  }
              )
            ],
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                              child: Text("Reyonlar",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 15,bottom: 10),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: FaIcon(FontAwesomeIcons.store,color: Colors.blue.shade900,size: 30,),
                          ),
                        ),
                      ],
                    ),
                    height: 80,
                    width: (MediaQuery.of(context).size.width-30)/2,
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
                              child: Text("Raflar",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 15,bottom: 10),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: FaIcon(FontAwesomeIcons.gripLines,color: Colors.blue.shade900,size: 30,),
                          ),
                        ),
                      ],
                    ),
                    height: 80,
                    width: (MediaQuery.of(context).size.width-30)/2,
                  ),
                  onTap: () async {

                  }
              )
            ],
          ),
        ],
      ),
    );
  }


}