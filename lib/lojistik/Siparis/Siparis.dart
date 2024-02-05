import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';


class Siparis extends StatefulWidget {
  @override
  _SiparisState createState() => _SiparisState();
}


class _SiparisState extends State<Siparis> {




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
                                child: Text("Depolar Arası\nSipariş",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
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
                     // Navigator.push(context, MaterialPageRoute(builder: (context) => DepolarArasiSiparisFisi()));
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
                                child: Text("Verilen\nSipariş",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
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
                                child: Text("Alınan\nSipariş",style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade800),)
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
          ],
        ),
      )
    );
  }
}

